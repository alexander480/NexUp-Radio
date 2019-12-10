//
//  Advertisments.swift
//  NexUp
//
//  Created by Alexander Lester on 12/9/19.
//  Copyright © 2019 LAGB Technologies. All rights reserved.
//

import Foundation
import GoogleMobileAds

class Advertisments: NSObject {
    
    let bannerID = "ca-app-pub-6543648439575950/8381413905"
    let fullScreenID = "ca-app-pub-6543648439575950/9063940183"
    
    var interstitial: GADInterstitial!
    
    func checkForInterstitial(Delegate: GADInterstitialDelegate) {
        if audio.songCount % 3 == 0 && account.isPremium == false {
            audio.player.pause()
            
            let newInterstitial = GADInterstitial(adUnitID: fullScreenID)
            newInterstitial.delegate = Delegate
            newInterstitial.load(GADRequest())
            
            interstitial = newInterstitial
        }
    }
}
