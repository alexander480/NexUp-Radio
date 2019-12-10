//
//  Metadata.swift
//  NexUp
//
//  Created by Alexander Lester on 12/9/19.
//  Copyright © 2019 LAGB Technologies. All rights reserved.
//

import Foundation

class MetadataHandler: NSObject {
    
    var isFirstOpen = true
    
    func populateNowPlaying(npvc: NowPlayingVC) {
        if let info = audio.metadata {
            if let image = audio.imageCache.object(forKey: info["URL"] as! NSString) {
                npvc.circleButton.setImage(image, for: .normal)
                npvc.toggleLoading(isLoading: false)
                npvc.backgroundImage.image = image
            }
        }
    }
    
    func updateInterface(npvc: NowPlayingVC) {
        if let info = audio.metadata {
            if let url = info["URL"] as? NSString {
                if let image = audio.imageCache.object(forKey: url) {
                    npvc.backgroundImage.image = image
                    npvc.circleButton.setImage(image, for: .normal)
                    if let item = audio.player.currentItem {
                        npvc.progressBar.progress = Float(item.currentTime().seconds / item.duration.seconds)
                    }
                }
            }
            npvc.toggleLoading(isLoading: false)
        }
        else {
            npvc.toggleLoading(isLoading: true)
        }
    }
}
