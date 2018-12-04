
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
    
    func startPlaylist(Name: String) {
        var buf = [URL]()
        let reference = db.reference(withPath: "/audio/\(Name)")
        self.currentPlaylist = Name
        reference.observeSingleEvent(of: .value) { (snap) in
            let songs = snap.children.allObjects as! [DataSnapshot]
            if songs.isEmpty == false {
                for song in songs { if let songUrl = (song.value as! String).toURL() { buf.append(songUrl) } }
                account.removeDislikedSongs()
                self.playlist = buf.random()
                self.reloadQueue()
            }
        }
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
                    self.reloadQueue()
                }
            })
        }
    }
    
    @objc func playerDidFinishPlaying() {
        if account.skipCount < 1 {
            print("[INFO] Player Finished Playing")
            print("[INFO] Skip Limit Reached")
            self.limitReached = true
            self.skip(didFinish: true)
        }
        else {
            print("[INFO] Player Finished Playing")
            account.addSongToRecents()
            self.limitReached = false
            self.skip(didFinish: true)
        }
    }

    func togglePlayback() {
        if self.player.rate == 1.0 { self.player.pause() }
        else { self.player.play() }
    }

    func skip(didFinish: Bool) {
        avWorker.async {
            if self.player.items().isEmpty {
                if didFinish || account.isPremium {
                    print("[INFO] Reloading Queue")
                    self.reloadQueue()
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
                        self.limitReached = false
                        account.updateSkipCount(To: account.skipCount - 1);
                        self.reloadQueue()
                    }
                }
            }
            else {
                if didFinish || account.isPremium {
                    print("[INFO] Advancing To Next Song")
                    if let item = self.player.currentItem {
                        self.player.remove(item)
                        self.player.play()
                        self.metadata = self.fetchMetadata()
                        self.ccUpdate()
                    }
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
                        if let item = self.player.currentItem {
                            self.player.remove(item)
                            self.player.play()
                            self.metadata = self.fetchMetadata()
                            self.ccUpdate()
                        }
                    }
                }
            }
        }
    }
    
    private func reloadQueue() {
        avWorker.async {
            if let item = self.player.currentItem {
                self.player.remove(item)
            }
            if self.playlist.isEmpty {
                self.startPlaylist(Name: self.currentPlaylist)
            }
            else if self.playlist.count >= 5 {
                for url in self.playlist.prefix(5) {
                    self.player.insert(AVPlayerItem(url: url), after: nil)
                }
                self.playlist.removeFirst(5)
                self.player.play()
                self.metadata = self.fetchMetadata()
                self.ccUpdate()
            }
            else {
                for url in self.playlist.prefix(self.playlist.count) {
                    self.player.insert(AVPlayerItem(url: url), after: nil)
                }
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
                        if let songName = property.stringValue {
                            print("[INFO] Song Name: \(songName)")
                            metadata["Name"] = songName
                        }
                        else {
                            print("[ERROR] Song Name: nil")
                            self.skip(didFinish: true)
                        }
                    }
                    else if property.commonKey == AVMetadataKey.commonKeyArtist {
                        if let songArtist = property.stringValue {
                            print("[INFO] Song Artist: \(songArtist)")
                            metadata["Artist"] = songArtist
                        }
                        else {
                            print("[ERROR] Song Artist: nil")
                            self.skip(didFinish: true)
                        }
                    }
                    else if property.commonKey == AVMetadataKey.commonKeyArtwork {
                        if let rawImage = property.dataValue {
                            if let songImage = UIImage(data: rawImage) {
                                self.imageCache.setObject(songImage, forKey: metadata["URL"] as! NSString)
                                metadata["Image"] = songImage
                            }
                        }
                        else {
                            print("[WARNING] Song Image: nil")
                            metadata["Image"] = #imageLiteral(resourceName: "J3Ent375")
                        }
                    }
                }
            }
        }
        if metadata.count == 0 {
            self.skip(didFinish: true)
        }
        print("[INFO] Fetched \(metadata.count) Metadata Items")
        
        return metadata
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
