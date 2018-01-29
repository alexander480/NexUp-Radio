
//
//  Audio.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 8/22/17.
//  Copyright © 2017 LAGB Technologies. All rights reserved.
//

import Foundation
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
    
    var progress = 0.0
    var skipCount = 0
    var count = 0
    
    let cc = MPRemoteCommandCenter.shared()
    let info = MPNowPlayingInfoCenter.default()
    
    let nc = NotificationCenter.default
    let session = AVAudioSession.sharedInstance()
    
    let AVWorker = DispatchQueue.init(label: "AVWorker", qos: DispatchQoS.userInteractive)
    let MetadataWorker = DispatchQueue.init(label: "MetadataWorker", qos: DispatchQoS.userInteractive)
    
    init(FromPlaylist: String)
    {
        super.init()
        
        print("[INFO] Initializing Audio Class")
        
        self.setup(playlist: FromPlaylist)
    }
    
    
    // -------------- Private Functions -------------- //
    
    func setup(playlist: String)
    {
        self.currentPlaylist = playlist
        
        let reference = db.reference(withPath: "/audio/\(playlist)")
        reference.observeSingleEvent(of: .value) { (snap) in
            self.urls = [URL]()
            
            for song in snap.children.allObjects as! [DataSnapshot] { self.urls.append((song.value as! String).toURL()!) }
            self.urls = self.urls.random()
            
            self.sessionSetup()
            self.player.actionAtItemEnd = .none
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
            
            self.ccSetup()
            self.ccUpdate()
            
            self.repopulate()
            self.metadata = self.fetchMetadata()
        }
    }
    
    private func repopulate()
    {
        self.player.removeAllItems()
        
        if self.urls.isEmpty
        {
            self.setup(playlist: self.currentPlaylist)
        }
        else if self.urls.count < 20
        {
            let lastURLs = self.urls.random()
            self.urls.removeAll()
            
            for url in lastURLs { self.player.insert(AVPlayerItem(url: url), after: nil) }
            self.player.play()
        }
        else
        {
            self.urls = self.urls.random()
            let short = self.urls.prefix(20)
            self.urls.removeFirst(20)
            
            for url in short { self.player.insert(AVPlayerItem(url: url), after: nil) }
            self.player.play()
        }
    }
    
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
        
        print("[INFO] Fetched \(metadata.count) Metadata Items")
        return metadata
    }
    
    @objc func playerDidFinishPlaying()
    {
        print("[INFO] Player Finished Playing")
        if let user = auth.currentUser { print("[INFO] Adding Song To User \(user.uid)'s Recents"); account.recentSong() }
        
        if self.count % 20 == 0 { self.repopulate() }
        else if self.urls.isEmpty { self.repopulate() }
        else { self.skip(didFinish: true) }
        
        self.metadata = self.fetchMetadata()
    }
    
    // -------------- Setup Functions -------------- //
    // --------------------------------------------- //
    
    private func sessionSetup()
    {
        do { try self.session.setActive(true); try self.session.setCategory(AVAudioSessionCategoryPlayback); print("[INFO] Audio Session Setup Complete") }
        catch { print("[ERROR] Could Not Setup Audio Session") }
    }
    
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
    
    private func ccUpdate()
    {
        if self.skipCount > 9 { self.cc.nextTrackCommand.isEnabled = false } else { self.cc.nextTrackCommand.isEnabled = true }
        
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
    
    
    // ------ Public Functions ------ //
    
    func togglePlayback() { if self.player.rate == 1.0 { self.player.pause() } else { self.player.play() } }
    
    func skip(didFinish: Bool)
    {
        if didFinish
        {
            print("[INFO] Skipping To Next Song")
            self.count = self.count + 1
            
            if self.count % 20 == 0 { self.repopulate() }
            else if self.urls.isEmpty { self.repopulate() }
            else { self.player.advanceToNextItem() }
            
            self.metadata = self.fetchMetadata()
        }
        else
        {
            if self.skipCount > 299 { print("[INFO] Skip Limit Reached") }
            else
            {
                print("[INFO] Skipping To Next Song")
                self.skipCount = self.skipCount + 1
                self.count = self.count + 1
                
                if self.count % 20 == 0 { self.repopulate() }
                else if self.urls.isEmpty { self.repopulate() }
                else { self.player.advanceToNextItem() }
                
                self.metadata = self.fetchMetadata()
            }
        }
    }
}







