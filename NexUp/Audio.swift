
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
    var playlist = [URL]()
    var queue = [AVPlayerItem]()
    
    var metadata: [String: Any]?
    
    var currentPlaylist = ""
    
    var limitReached = false
    var shouldDisplayAd = false
    
    var progress = 0.0
    var skipCount = 0
    
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
        self.skipCount = self.fetchSkipCount()
        
        if PlaylistName == "Favorites" {
            self.fetchFavorites()
            self.sessionSetup()
        }
        else {
            self.fetchPlaylist(Name: PlaylistName)
            self.sessionSetup()
        }
    }
    
    // -------------- Update Skip Count -------------- //
    // ----------------------------------------------- //
    
    func updateSkipCount(Count: Int) { UserDefaults.standard.set(Count, forKey: "skipCount") }
    
    // --------------- Read Skip Count --------------- //
    // ----------------------------------------------- //
    
    func fetchSkipCount() -> Int {
        if let count = UserDefaults.standard.object(forKey: "skipCount") as? Int { return count }
        else { UserDefaults.standard.set(0, forKey: "skipCount"); return 0 }
    }
    
    // -------------- Fetch URLs From Firebase -------------- //
    // ------------------------------------------------------ //
    
    func fetchPlaylist(Name: String) {
        var buf = [URL]()
        let reference = db.reference(withPath: "/audio/\(Name)")
        reference.observeSingleEvent(of: .value) { (snap) in
            for song in snap.children.allObjects as! [DataSnapshot] { if let songUrl = (song.value as! String).toURL() { buf.append(songUrl) } }
            if buf.isEmpty == false {
                self.playlist = buf.random()
                account.removeDislikes()
                self.updateQueue()
            }
        }
    }
    
    func fetchFavorites() {
        var buf = [URL]()
        
        if let user = auth.currentUser {
            let reference = db.reference(withPath: "/users/\(user.uid)/favorites")
            reference.observeSingleEvent(of: .value, with: { (snap) in
                for song in snap.children.allObjects as! [DataSnapshot] {
                    for property in song.children.allObjects as! [DataSnapshot] {
                        if property.key == "URL" {
                            if let songUrl = (property.value as! String).toURL() {
                                buf.append(songUrl)
                            }
                        }
                    }
                }
            })
        }
        
        if buf.isEmpty == false {
            self.playlist = buf.random()
            account.removeDislikes()
            self.updateQueue()
        }
    }
    
    // ------------ Populate AVQueuePlayer With New AVPlayerItems ------------ //
    // ----------------------------------------------------------------------- //
    
    func updateQueue() {
        for url in self.playlist.prefix(3) { self.player.insert(AVPlayerItem(url: url), after: nil) }
        self.playlist.removeFirst(3)
        
        self.player.play()
        
        audio.metadata = self.fetchMetadata()
        self.metadata = self.fetchMetadata()
        self.ccUpdate()
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
        
        if metadata.count == 0 || metadata.count == 1 {
            self.skip(didFinish: true)
        }
    
        print("[INFO] Fetched \(metadata.count) Metadata Items")
        return metadata
    }
    
    // ------------ Song Finished Listener ------------ //
    // ------------------------------------------------ //
    
    @objc func playerDidFinishPlaying() {
        if let currentItem = self.player.currentItem { self.player.remove(currentItem) }
        account.addToRecents()
        print("[INFO] Player Finished Playing")
        
        if self.player.items().isEmpty { self.updateQueue() }
        else { if let currentItem = self.player.currentItem { self.player.remove(currentItem) } }
        
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
        if account.isPremium { self.cc.nextTrackCommand.isEnabled = true }
        else if self.skipCount > 9 { self.cc.nextTrackCommand.isEnabled = false }
        else { self.cc.nextTrackCommand.isEnabled = true }
        
        if let item = self.player.currentItem
        {
            if let img = self.metadata?["Image"] as? UIImage, let name = self.metadata?["Name"] as? String, let artist = self.metadata?["Artist"] as? String
            {
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
        self.count = self.count + 1
        print("[INFO] Skipping To Next Song")
        
        if let item = self.player.currentItem { self.player.remove(item) }
        
        if didFinish || account.isPremium { self.checkQueue() }
        else {
            if self.skipCount > 9 {
                print("[INFO] Skip Limit Reached")
                self.limitReached = true
            }
            else {
                self.skipCount = self.skipCount + 1
                self.updateSkipCount(Count: self.skipCount)
                self.checkQueue()
            }
        }
        
        if self.count % 3 == 0 { self.shouldDisplayAd = true }
    }
    
    private func checkQueue() {
        if self.count % 3 == 0 { self.updateQueue() }
        else if self.playlist.isEmpty { self.fetchPlaylist(Name: self.currentPlaylist) }
        else { self.player.advanceToNextItem() }
        
        self.metadata = self.fetchMetadata()
        self.ccUpdate()
    }
}
