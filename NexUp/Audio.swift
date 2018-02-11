
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
    var playlist = [AVPlayerItem]()
    var urls = [URL]()
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
        
        self.skipCount = self.fetchSkipCount()
        self.fetchPlaylist(PlaylistName: PlaylistName)
    }
    
    // -------------- Update Skip Count -------------- //
    // ----------------------------------------------- //
    
    func updateSkipCount(Count: Int) { UserDefaults.standard.set(Count, forKey: "skipCount") }
    
    // --------------- Read Skip Count --------------- //
    // ----------------------------------------------- //
    
    func fetchSkipCount() -> Int
    {
        if let count = UserDefaults.standard.object(forKey: "skipCount") as? Int { return count }
        else { UserDefaults.standard.set(0, forKey: "skipCount"); return 0 }
    }
    
    // -------------- Fetch URLs From Firebase -------------- //
    // ------------------------------------------------------ //
    
    func fetchPlaylist(PlaylistName: String)
    {
        self.currentPlaylist = PlaylistName
        
        if PlaylistName == "Favorites"
        {
            if let user = auth.currentUser
            {
                let reference = db.reference(withPath: "/users/\(user.uid)/favorites")
                reference.observeSingleEvent(of: .value, with: { (snap) in
                    
                    self.urls = [URL]()
                    
                    for song in snap.children.allObjects as! [DataSnapshot] {
                        for property in song.children.allObjects as! [DataSnapshot] {
                            if property.key == "URL" {
                                if let urlStr = (property.value as? String) {
                                    self.urls.append(urlStr.toURL()!)
                                }
                            }
                        }
                    }
                    
                    if self.urls.isEmpty == false { self.sessionSetup(); self.repopulatePlayer(); self.metadata = self.fetchMetadata(); self.ccUpdate(); }
                })
            }
        }
        else
        {
            let reference = db.reference(withPath: "/audio/\(PlaylistName)")
            reference.observeSingleEvent(of: .value) { (snap) in
                self.urls = [URL]()
                
                for song in snap.children.allObjects as! [DataSnapshot] { self.urls.append((song.value as! String).toURL()!) }
                
                self.urls = account.removeUserDislikes(Playlist: self.urls)
                self.urls = self.urls.random()
                
                self.sessionSetup()
                self.repopulatePlayer()
                self.metadata = self.fetchMetadata()
                self.ccUpdate()
            }
        }
    }
    
    // ------------ Populate AVQueuePlayer With New AVPlayerItems ------------ //
    // ----------------------------------------------------------------------- //
    
    private func repopulatePlayer()
    {
        if self.urls.isEmpty {
            self.fetchPlaylist(PlaylistName: self.currentPlaylist)
        }
        else if self.urls.count < 5 {
            self.player.removeAllItems()
            self.urls.removeAll()
            for url in self.urls.random() { self.player.insert(AVPlayerItem(url: url), after: nil) }
            self.player.play()
        }
        else {
            self.player.removeAllItems()
            self.urls = self.urls.random()
            for url in self.urls.prefix(5) { self.player.insert(AVPlayerItem(url: url), after: nil) }
            self.urls.removeFirst(5)
            self.player.play()
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
        
        if metadata.count == 0 || metadata.count == 1 {
            self.skip(didFinish: true)
        }
    
        print("[INFO] Fetched \(metadata.count) Metadata Items")
        return metadata
    }
    
    // ------------ Song Finished Listener ------------ //
    // ------------------------------------------------ //
    
    @objc func playerDidFinishPlaying()
    {
        print("[INFO] Player Finished Playing")
        account.recentSong()
        
        if self.count % 5 == 0 && self.currentPlaylist != "Favorites" { self.repopulatePlayer() }
        else if self.player.items().isEmpty { self.fetchPlaylist(PlaylistName: self.currentPlaylist) }
        else { self.skip(didFinish: true) }
        
        self.metadata = self.fetchMetadata()
        self.ccUpdate()
    }
    
    // -------------- Setup Audio Session -------------- //
    // ------------------------------------------------- //
    
    private func sessionSetup() {
        do
        {
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
    
    func togglePlayback()
    {
        if self.player.rate == 1.0 { self.player.pause() }
        else { self.player.play() }
    }
    
    // ------------ Skip Handler ------------ //
    // -------------------------------------- //
    
    func skip(didFinish: Bool)
    {
        print("[INFO] Skipping To Next Song")
        self.count = self.count + 1
        
        if let item = self.player.currentItem { self.player.remove(item) }
        
        if didFinish || account.isPremium
        {
            if self.count % 5 == 0 { self.repopulatePlayer() }
            else if self.urls.isEmpty { self.repopulatePlayer() }
            else { self.player.advanceToNextItem() }
            
            self.metadata = self.fetchMetadata()
            self.ccUpdate()
        }
        else
        {
            if self.skipCount > 9
            {
                print("[INFO] Skip Limit Reached")
                self.limitReached = true
            }
            else
            {
                self.skipCount = self.skipCount + 1
                self.updateSkipCount(Count: self.skipCount)
                
                if self.count % 5 == 0 { self.repopulatePlayer() }
                else if self.urls.isEmpty { self.repopulatePlayer() }
                else { self.player.advanceToNextItem() }
                
                self.metadata = self.fetchMetadata()
                self.ccUpdate()
            }
        }
        
        if self.count % 3 == 0 { self.shouldDisplayAd = true }
    }
}






