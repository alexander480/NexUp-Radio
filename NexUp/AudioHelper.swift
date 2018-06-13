//
//  Session.swift
//  NexUp
//
//  Created by Alexander Lester on 6/12/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import NotificationCenter
import MediaPlayer

class AudioHelper: NSObject {
    let MetadataWorker = DispatchQueue.init(label: "MetadataWorker", qos: DispatchQoS.userInteractive)
    let cc = MPRemoteCommandCenter.shared()
    let info = MPNowPlayingInfoCenter.default()
    let nc = NotificationCenter.default

    func ccSetup()
    {
        self.cc.playCommand.isEnabled = true
        self.cc.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            audio.player.play()
            self.ccUpdate()
            
            return .success
        }
        
        self.cc.pauseCommand.isEnabled = true
        self.cc.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            audio.player.pause()
            self.ccUpdate()
            
            return .success
        }
        
        self.cc.nextTrackCommand.isEnabled = true
        self.cc.nextTrackCommand.addTarget{ (event) -> MPRemoteCommandHandlerStatus in
            audio.skip(songDidFinish: false)
            self.cc.nextTrackCommand.isEnabled = false
            self.ccUpdate()
            
            return .success
        }
        
        print("[INFO] Command Center Setup Complete")
    }
    
    func ccUpdate()
    {
        if account.skipCount <= 0 && account.isPremium == false { self.cc.nextTrackCommand.isEnabled = false }
        else { self.cc.nextTrackCommand.isEnabled = true }
        
        if let item = audio.player.currentItem {
            if let img = audio.metadata?["Image"] as? UIImage, let name = audio.metadata?["Name"] as? String, let artist = audio.metadata?["Artist"] as? String
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
    
    func fetchMetadata() -> [String: Any]? {
        var metadata = [String: Any]()
        MetadataWorker.sync {
            if let item = audio.player.currentItem {
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
        
        // if metadata.count == 0 || metadata.count == 1 { self.skip(didFinish: true) }
        
        print("[INFO] Fetched \(metadata.count) Metadata Items")
        return metadata
    }
}
