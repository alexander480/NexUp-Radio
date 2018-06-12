
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
import FirebaseStorage

//  TODO
// ----------------------------------------------
//
// - Display An Alert When Skip Limit Reached
// - Fix Possible Bug In FetchMetadata()
// - Display Full Screen Ad When Skip Limit Reached
//

let main = DispatchQueue.main
let background = DispatchQueue.global()

class Audio: NSObject, AVAssetResourceLoaderDelegate
{
    var player = AVQueuePlayer()
    var queue = [AVPlayerItem]()
    var playlist = [URL]()

    var metadata: [String: Any]?
    
    var currentPlaylist = ""
    
    var shouldDisplayAd = false
    var needQueueReload = false
    
    var progress = 0.0
    
    var count = 0
    
    let AVWorker = DispatchQueue.init(label: "AVWorker", qos: DispatchQoS.userInteractive)
    let MetadataWorker = DispatchQueue.init(label: "MetadataWorker", qos: DispatchQoS.userInteractive)
    
    let cc = MPRemoteCommandCenter.shared()
    let info = MPNowPlayingInfoCenter.default()
    let nc = NotificationCenter.default
    let session = AVAudioSession.sharedInstance()
    
    // ------------ Initialization ------------ //
    // ---------------------------------------- //
    
    init(PlaylistName: String)
    {
        super.init()
        self.currentPlaylist = PlaylistName
        
        if PlaylistName == "Favorites" {
            self.fetchFavorites()
            self.sessionSetup()
        }
        else {
            self.fetchPlaylist(Name: PlaylistName)
            self.sessionSetup()
        }
    }
    
    // -------------- Fetch URLs From Firebase -------------- //
    // ------------------------------------------------------ //
    
    func fetchPlaylist(Name: String) {
        var buf = [URL]()
        let reference = db.reference(withPath: "/audio/\(Name)")
        reference.observeSingleEvent(of: .value) { (snap) in
            let songs = snap.children.allObjects as! [DataSnapshot]
            if songs.isEmpty == false {
                for song in songs { if let songUrl = (song.value as! String).toURL() { buf.append(songUrl) } }
                self.playlist = buf.random()
                account.removeDislikes()
                self.reloadQueue()
            }
        }
    }
    
    func fetchFavorites() {
        var buf = [URL]()
        if let user = auth.currentUser {
            let reference = db.reference(withPath: "/users/\(user.uid)/favorites")
            reference.observeSingleEvent(of: .value, with: { (snap) in
                let songs = snap.children.allObjects as! [DataSnapshot]
                if songs.isEmpty == false {
                    for song in songs {
                        for property in song.children.allObjects as! [DataSnapshot] {
                            if property.key == "URL" { if let songUrl = (property.value as! String).toURL() { buf.append(songUrl) } }
                        }
                    }
                    self.playlist = buf.random()
                    account.removeDislikes()
                    self.reloadQueue()
                }
            })
        }
    }
    
   
    
    // ------------ Fetch Metadata For Current Song ------------ //
    // --------------------------------------------------------- //
    
    func fetchMetadata() -> [String: Any]?
    {
        var metadata = [String: Any]()
        
        MetadataWorker.sync {
            if let item = self.player.currentItem {
                for property in item.asset.commonMetadata as [AVMetadataItem] {
                    if property.commonKey == AVMetadataKey.commonKeyTitle  {
                        if let songName = property.stringValue {
                            print("[INFO] Song Name: \(songName)")
                            metadata["Name"] = songName
                        }
                    }
                    else if property.commonKey == AVMetadataKey.commonKeyArtist {
                        if let songArtist = property.stringValue {
                            print("[INFO] Song Artist: \(songArtist)")
                            metadata["Artist"] = songArtist
                        }
                    }
                    else if property.commonKey == AVMetadataKey.commonKeyArtwork {
                        if let rawImage = property.dataValue {
                            if let songImage = UIImage(data: rawImage) {
                                metadata["Image"] = songImage
                            }
                        }
                        else {
                            print("[WARNING] No Image Available For Current Song")
                            metadata["Image"] = #imageLiteral(resourceName: "J3Ent375")
                        }
                    }
                }
                
                metadata["URL"] = (item.asset as! AVURLAsset).url
            }
        }
        
        // if metadata.count == 0 || metadata.count == 1 {
        //    self.skip(didFinish: true)
        // }
    
        print("[INFO] Fetched \(metadata.count) Metadata Items")
        return metadata
    }
    
    // ------------ Song Finished Listener ------------ //
    // ------------------------------------------------ //
    
    @objc func playerDidFinishPlaying() {
        account.addToRecents()
        print("[INFO] Player Finished Playing")
        self.skip(didFinish: true)
        self.metadata = self.fetchMetadata()
        self.ccUpdate()
    }
    
    // -------------- Setup Audio Session -------------- //
    // ------------------------------------------------- //
    
    private func sessionSetup() {
        do {
            try self.session.setActive(true)
            try self.session.setCategory(AVAudioSessionCategoryPlayback)
            
            self.player.actionAtItemEnd = .none
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
            
            self.ccSetup()
            self.ccUpdate()
            
            print("[INFO] Audio Session Setup Complete")
            
        }
        catch {
            print("[ERROR] Could Not Setup Audio Session")
        }
    }
    
    // ------------ Initialize Command Center ------------ //
    // --------------------------------------------------- //
    
    private func ccSetup()
    {
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
    
    // ------------ Update Command Center ------------ //
    // ----------------------------------------------- //
    
    func ccUpdate()
    {
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
    
    
    // ------------ Play / Pause ------------ //
    // -------------------------------------- //
    
    func togglePlayback() { if self.player.rate == 1.0 { self.player.pause() } else { self.player.play() } }
    
    // ------------ Skip Handler ------------ //
    // -------------------------------------- //
    
    func skip(didFinish: Bool) {
        print("[INFO] Skipping To Next Song")
        
        if self.player.items().isEmpty { self.shouldDisplayAd = true; self.needQueueReload = true; }
        
        if self.needQueueReload {
            if didFinish || account.isPremium { self.reloadQueue() }
            else if account.skipCount > 0 { account.updateSkipCount(To: account.skipCount - 1); self.reloadQueue() }
            else { print("[INFO] Skip Limit Reached") }
        }
        else {
            if didFinish || account.isPremium {
                self.nextSong()
            }
            else if account.skipCount > 0 {
                account.updateSkipCount(To: account.skipCount - 1);
                self.nextSong()
            }
            else { print("[INFO] Skip Limit Reached") }
        }
    }
    
    func reloadQueue() {
        if self.playlist.isEmpty {
            self.fetchPlaylist(Name: self.currentPlaylist)
        }
        else if self.playlist.count >= 5 {
            let shortened = self.playlist.prefix(5)
            self.playlist.removeFirst(5)
            
            for url in shortened {
                let item = AVPlayerItem(url: url)
                self.player.insert(item, after: nil)
            }
            
            self.player.play()
            self.metadata = self.fetchMetadata()
            self.ccUpdate()
        }
        else {
            let shortened = self.playlist.prefix(self.playlist.count)
            self.playlist.removeAll()
            for url in shortened {
                let item = AVPlayerItem(url: url)
                self.player.insert(item, after: nil)
            }
            
            self.player.play()
            self.metadata = self.fetchMetadata()
            self.ccUpdate()
        }
    }
    
    // ------------ Populate AVQueuePlayer With New AVPlayerItems ------------ //
    // ----------------------------------------------------------------------- //
    
    func nextSong() {
        if let item = self.player.currentItem { self.player.remove(item) }
        self.player.play()
        self.metadata = self.fetchMetadata()
        self.ccUpdate()
    }
}
