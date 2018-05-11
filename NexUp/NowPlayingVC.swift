//
//  NowPlaying.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/6/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import AVFoundation
import Foundation
import Dispatch
import UIKit
import GoogleMobileAds
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

let account = Account()
var audio = Audio(PlaylistName: "Hip Hop")
var subscriptions = SubscriptionHandler(SharedSecret: "28c35d969edc4f739e985dbe912a963d", SubscriptionIdentifiers: ["com.lagbtech.nexup.tier1"])

let bannerID = "ca-app-pub-3940256099942544/2934735716"
let fullScreenID = "ca-app-pub-3940256099942544/4411468910"

class NowPlayingVC: UIViewController, GADInterstitialDelegate
{
    var timer = Timer()
    var interstitial: GADInterstitial!
    let screenWidth = UIScreen.main.bounds.width
    
    @IBOutlet weak var banner: GADBannerView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var controlCircleConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingView: ViewClass!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var loadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var sidebarConstraint: NSLayoutConstraint!
    @IBOutlet weak var revealSidebarButton: ButtonClass!
    @IBOutlet weak var sidebarButtonContraint: NSLayoutConstraint!
    
    @IBAction func revealSidebarAction(_ sender: Any) { self.toggleSidebar() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI(didAppear: false)
        
        subscriptions = SubscriptionHandler(SharedSecret: "28c35d969edc4f739e985dbe912a963d", SubscriptionIdentifiers: ["com.lagbtech.nexup.tier1"])
        
        self.setupBanner(BannerView: self.banner)
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in self.updateUserInterface() })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.setupUI(didAppear: true)
    }
    
    private func updateUserInterface() {
        if let info = audio.metadata {
            if let image = info["Image"] as? UIImage, let background = self.backgroundImage {
                background.removeBlur()
                background.image = image
                background.isHidden = false
            }
            self.toggleLoading(isLoading: false)
        }
        else { self.toggleLoading(isLoading: true) }
        
        if audio.shouldDisplayAd { interstitial = self.createInterstitial(); audio.shouldDisplayAd = false }
    }

    func toggleLoading(isLoading: Bool) {
        if isLoading {
            self.loadingView?.isHidden = false
            self.revealSidebarButton?.isHidden = true
            self.loadingSpinner?.startAnimating()
            
            self.controlCircleConstraint?.constant = 750
            self.loadingConstraint?.constant = -27.5
            
            UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
        }
        else {
            self.loadingView?.isHidden = true
            self.revealSidebarButton?.isHidden = false
            self.loadingSpinner?.stopAnimating()
            
            self.loadingConstraint?.constant = 750
            self.controlCircleConstraint?.constant = 0
            
            UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
        }
    }
    
    func toggleSidebar() {
        if self.sidebarConstraint?.constant == -274 { self.sidebarConstraint?.constant = -101 }
        else if self.sidebarConstraint?.constant == -101 { self.sidebarConstraint?.constant = -274 }
        
        UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
    }
    
    private func toggleCircle() {
        if self.controlCircleConstraint?.constant == 0 { self.controlCircleConstraint?.constant = 750 }
        else if self.controlCircleConstraint?.constant == 750 { self.controlCircleConstraint?.constant = 0 }
        
        UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
    }
    
    private func createInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: fullScreenID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        
        return interstitial
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) { ad.present(fromRootViewController: self) }
    
    private func setupUI(didAppear: Bool) {
        if didAppear {
            if screenWidth == 414 {
                self.sidebarButtonContraint?.constant = 25
                UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
            }
            else if screenWidth == 375 {
                self.sidebarButtonContraint?.constant = 37.5
                UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
            }
            else if screenWidth == 320 {
                self.sidebarButtonContraint?.constant = 65.5
                UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
            }
        }
        else {
            self.controlCircleConstraint.constant = 0
            self.view.layoutIfNeeded()
            
            self.backgroundImage?.image = #imageLiteral(resourceName: "j3detroit")
            self.backgroundImage?.blur()
            
            self.toggleLoading(isLoading: true)
        }
    }
    
    deinit { self.timer.invalidate() }
}
