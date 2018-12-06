
//
//  Audio.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 8/22/17.
//  Copyright © 2017 LAGB Technologies. All rights reserved.
//

import Foundation
import CoreData

import AVFoundation
import NotificationCenter
import MediaPlayer

import FirebaseAuth
import FirebaseDatabase

let main = DispatchQueue.main
let background = DispatchQueue.global()

protocol AudioDelegate {
    func didReachLimit()
}

class Audio: NSObject {
    
    var player = AVQueuePlayer()
    var playlist = [URL]()
    
    var currentPlaylist = ""
    var shouldDisplayAd = false
    var limitReached = false
    
    var delegate: AudioDelegate?
    
    let imageCache = NSCache<NSString, UIImage>()
    var metadata: [String: Any]?
    var previousSong: AVPlayerItem?
    
    let avWorker = DispatchQueue.init(label: "AVWorker", qos: DispatchQoS.userInteractive)
    let metadataWorker = DispatchQueue.init(label: "MetadataWorker", qos: DispatchQoS.userInteractive)
    
    let cc = MPRemoteCommandCenter.shared()
    let info = MPNowPlayingInfoCenter.default()
    let nc = NotificationCenter.default
    let session = AVAudioSession.sharedInstance()

    init(PlaylistName: String) {
        super.init()
        
        self.currentPlaylist = PlaylistName
        self.sessionSetup()
        
        if PlaylistName == "Favorites" { self.startFavorites() }
        else { self.startPlaylist(Name: PlaylistName) }
    }
    
    
    
    private func refreshQueue() {
        print("[INFO] Refreshing Queue")
        avWorker.async {
            if let item = self.player.currentItem { self.player.remove(item) }
            if self.playlist.isEmpty { self.startPlaylist(Name: self.currentPlaylist) }
            else if self.playlist.count >= 5 {
                for url in self.playlist.prefix(5) { self.player.insert(AVPlayerItem(url: url), after: nil) }
                self.playlist.removeFirst(5)
                self.player.play()
                self.metadata = self.fetchMetadata()
                self.ccUpdate()
            }
            else {
                for url in self.playlist.prefix(self.playlist.count) { self.player.insert(AVPlayerItem(url: url), after: nil) }
                self.playlist.removeAll()
                self.player.play()
                self.metadata = self.fetchMetadata()
                self.ccUpdate()
            }
        }
    }
    
    func fetchMetadata() -> [String: Any]? {
        var metadata = [String: Any]()
        metadataWorker.sync {
            if let item = self.player.currentItem {
                metadata["URL"] = String(describing: (item.asset as! AVURLAsset).url)
                for property in item.asset.commonMetadata as [AVMetadataItem] {
                    if property.commonKey == AVMetadataKey.commonKeyTitle  {
                        if let songName = property.stringValue { metadata["Name"] = songName }
                        else { print("[ERROR] Couldn't Find Song Name"); self.skip(didFinish: true); return }
                    }
                    else if property.commonKey == AVMetadataKey.commonKeyArtist {
                        if let songArtist = property.stringValue { metadata["Artist"] = songArtist }
                        else { print("[ERROR] Couldn't Find Song Artist"); self.skip(didFinish: true); return }
                    }
                    else if property.commonKey == AVMetadataKey.commonKeyArtwork {
                        if let rawImage = property.dataValue {
                            if let songImage = UIImage(data: rawImage) {
                                self.imageCache.setObject(songImage, forKey: metadata["URL"] as! NSString)
                                metadata["Image"] = songImage
                            }
                        }
                        else { print("[WARNING] Couldn't Find Album Artwork"); metadata["Image"] = #imageLiteral(resourceName: "j3detroit") }
                    }
                }
            }
        }
        
        if metadata.count == 0 { print("[ERROR] Couldn't Retrieve Metadata"); self.skip(didFinish: true) }
        else { print("[INFO] Fetched \(metadata.count) Metadata Items"); print("[METADATA] \(metadata.description)") }
        
        return metadata
    }
    
    @objc func playerDidFinishPlaying() {
        print("[INFO] Player Finished Playing")
        if account.skipCount < 1 {
            print("[INFO] Skip Limit Reached")
            self.limitReached = true
            self.skip(didFinish: true)
        }
        else {
            print("[INFO] Advancing To Next Song")
            account.addSongToRecents()
            self.limitReached = false
            self.skip(didFinish: true)
        }
    }
    
    private func ccSetup() {
        self.cc.playCommand.isEnabled = true
        self.cc.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.player.play()
            self.ccUpdate()
            
            return .success
        }
        
        self.cc.pauseCommand.isEnabled = true
        self.cc.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            self.ccUpdate()
            
            return .success
        }
        
        self.cc.nextTrackCommand.isEnabled = true
        self.cc.nextTrackCommand.addTarget{ (event) -> MPRemoteCommandHandlerStatus in
            self.skip(didFinish: false)
            self.cc.nextTrackCommand.isEnabled = false
            self.ccUpdate()
            
            return .success
        }
        
        print("[INFO] Command Center Setup Complete")
    }
    
    func ccUpdate() {
        if account.isPremium || account.skipCount > 0 { self.cc.nextTrackCommand.isEnabled = true }
        else { self.cc.nextTrackCommand.isEnabled = false }
        
        if let item = self.player.currentItem {
            if let img = self.metadata?["Image"] as? UIImage, let name = self.metadata?["Name"] as? String, let artist = self.metadata?["Artist"] as? String {
                let image = MPMediaItemArtwork.init(boundsSize: img.size, requestHandler: { (size) -> UIImage in return img })
                let duration = Double(item.duration.seconds)
                let current = Double(item.currentTime().seconds)
                
                self.info.nowPlayingInfo = [
                    MPMediaItemPropertyTitle: name,
                    MPMediaItemPropertyArtist: artist,
                    MPMediaItemPropertyArtwork: image,
                    MPMediaItemPropertyPlaybackDuration: duration,
                    MPNowPlayingInfoPropertyElapsedPlaybackTime: current
                ]
                
                print("[INFO] Command Center Update Complete")
            }
        }
    }
    
    private func sessionSetup() {
        do {
            try self.session.setActive(true)
            try self.session.setCategory(AVAudioSessionCategoryPlayback)
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
            self.player.actionAtItemEnd = .none
            self.ccSetup()
            self.ccUpdate()
            
            print("[INFO] Audio Session Setup Complete")
        }
        catch { print("[ERROR] Could Not Setup Audio Session") }
    }
}

extension Audio {
    
    func startPlaylist(Name: String) {
        var buffer = [URL]()
        let reference = db.reference(withPath: "/audio/\(Name)")
        self.currentPlaylist = Name
        reference.observeSingleEvent(of: .value) { (snap) in
            let songs = snap.children.allObjects as! [DataSnapshot]
            if songs.isEmpty == false {
                for song in songs { if let songUrl = (song.value as! String).toURL() { buffer.append(songUrl) } }
                account.removeDislikedSongs()
                self.playlist = buffer.random()
                self.refreshQueue()
            }
        }
        
        print("[INFO] \(Name) Playlist Started")
    }
    
    func startFavorites() {
        var buf = [URL]()
        if let user = auth.currentUser {
            let reference = db.reference(withPath: "/users/\(user.uid)/favorites")
            reference.observeSingleEvent(of: .value, with: { (snap) in
                let songs = snap.children.allObjects as! [DataSnapshot]
                if songs.isEmpty == false {
                    for song in songs {
                        for property in song.children.allObjects as! [DataSnapshot] {
                            if property.key == "URL" {
                                if let songUrl = (property.value as! String).toURL() {
                                    buf.append(songUrl)
                                }
                            }
                        }
                    }
                    account.removeDislikedSongs()
                    self.playlist = buf.random()
                    self.refreshQueue()
                }
            })
        }
        
        print("[INFO] Favorites Playlist Started")
    }
    
    func togglePlayback() {
        if self.player.rate == 1.0 {
            print("[INFO] Player Paused")
            self.player.pause()
        }
        else {
            print("[INFO] Player Resumed")
            self.player.play()
        }
    }
    
    private func nextSong(item: AVPlayerItem) {
        print("[INFO] Removing Current Song")
        self.player.remove(item)
        self.player.play()
        self.metadata = self.fetchMetadata()
        self.ccUpdate()
    }
    
    
    func skip(didFinish: Bool) {
        avWorker.async {
            if self.player.items().isEmpty {
                print("[INFO] Queue")
                if didFinish || account.isPremium {
                    self.refreshQueue()
                }
                else {
                    if account.skipCount < 1 {
                        print("[INFO] Skip Limit Reached")
                        self.limitReached = true
                        self.delegate?.didReachLimit()
                        return
                    }
                    else {
                        print("[INFO] Reloading Queue")
                        account.updateSkipCount(To: account.skipCount - 1);
                        self.limitReached = false
                        self.refreshQueue()
                    }
                }
            }
            else {
                if didFinish || account.isPremium {
                    print("[INFO] Advancing To Next Song")
                    if let item = self.player.currentItem { self.nextSong(item: item) }
                }
                else {
                    if account.skipCount < 1 {
                        print("[INFO] Skip Limit Reached")
                        self.limitReached = true
                        self.delegate?.didReachLimit()
                        
                        return
                    }
                    else {
                        print("[INFO] Advancing To Next Song")
                        account.updateSkipCount(To: account.skipCount - 1);
                        if let item = self.player.currentItem { self.nextSong(item: item) }
                    }
                }
            }
        }
    }
}
