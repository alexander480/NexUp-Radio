//
//  NowPlaying.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/6/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import Dispatch

import UIKit
import GoogleMobileAds
import AVFoundation

import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

let account = Account()
var audio = Audio(FromPlaylist: "Hip Hop")

let bannerID = "ca-app-pub-6543648439575950/8381413905"
let fullScreenID = "ca-app-pub-6543648439575950/9063940183"

class NowPlayingVC: UIViewController, GADInterstitialDelegate
{
    var timer = Timer()
    var interstitial: GADInterstitial!
    
    @IBOutlet weak var banner: GADBannerView!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var controlCircleConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loadingView: ViewClass!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var loadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sidebarConstraint: NSLayoutConstraint!
    @IBOutlet weak var revealSidebarButton: ButtonClass!
    @IBAction func revealSidebarAction(_ sender: Any) { self.toggleSidebar() }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        self.banner.adUnitID = bannerID
        self.banner.rootViewController = self
        self.banner.load(GADRequest())
        
        self.backgroundImage?.image = #imageLiteral(resourceName: "j3detroit")
        self.backgroundImage?.blur()
        
        self.toggleLoading(isLoading: true)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in self.updateUserInterface() })
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        ad.present(fromRootViewController: self)
    }
    
    private func updateUserInterface()
    {
        if let info = audio.metadata
        {
            if let image = info["Image"] as? UIImage, let background = self.backgroundImage
            {
                background.removeBlur()
                background.image = image;
                background.isHidden = false
                
            }
            self.toggleLoading(isLoading: false)
        }
        else { self.toggleLoading(isLoading: true) }
        
        if audio.shouldDisplayAd
        {
            interstitial = self.createInterstitial()
            audio.shouldDisplayAd = false
        }
    }

    
    private func toggleLoading(isLoading: Bool)
    {
        if isLoading
        {
            self.loadingView?.isHidden = false
            self.revealSidebarButton?.isHidden = true
            self.loadingSpinner?.startAnimating()
            
            self.controlCircleConstraint?.constant = 750
            self.loadingConstraint?.constant = -27.5
            
            UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
        }
        else
        {
            self.loadingView?.isHidden = true
            self.revealSidebarButton?.isHidden = false
            self.loadingSpinner?.stopAnimating()
            
            self.loadingConstraint?.constant = 750
            self.controlCircleConstraint?.constant = 0
            
            UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
        }
    }
    
    private func toggleCircle()
    {
        if self.controlCircleConstraint?.constant == 0 { self.controlCircleConstraint?.constant = 750 }
        else if self.controlCircleConstraint?.constant == 750 { self.controlCircleConstraint?.constant = 0 }
        
        UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
    }
    
    func toggleSidebar()
    {
        if self.sidebarConstraint?.constant == -274 { self.sidebarConstraint?.constant = -101 }
        else if self.sidebarConstraint?.constant == -101 { self.sidebarConstraint?.constant = -274 }
        
        UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
    }
    
    private func createInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: fullScreenID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        
        return interstitial
    }
    
    deinit { self.timer.invalidate() }
}
