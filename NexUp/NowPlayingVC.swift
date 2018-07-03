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
import AVFoundation
import GoogleMobileAds
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

let account = Account()
var audio = Audio(PlaylistName: "Hip Hop")

class NowPlayingVC: UIViewController, GADInterstitialDelegate {
    
    let bannerID = "ca-app-pub-3940256099942544/2934735716"
    let fullScreenID = "ca-app-pub-3940256099942544/4411468910"
    
    var timer = Timer()
    var interstitial: GADInterstitial!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var controlCircleConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlCircleView: UIView!
    
    @IBOutlet weak var loadingView: ViewClass!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var loadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sidebar: UIView!
    @IBOutlet weak var revealSidebarButton: ButtonClass!
    @IBAction func revealSidebarAction(_ sender: Any) { self.toggleSidebar() }
    
    @IBOutlet weak var circleButton: ButtonClass!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBAction func rightSwipe(_ sender: Any) { self.toggleSidebar() }
    @IBAction func leftSwipe(_ sender: Any) { self.toggleSidebar() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressBar.progress = 0.0
        
        account.shouldRefreshSkipCount()
        
        if auth.currentUser == nil {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") {
                present(vc, animated: true, completion: nil)
            }
        }
        
        self.toggleLoading(isLoading: true)
        
        if let info = audio.metadata {
            if let image = audio.imageCache.object(forKey: info["URL"] as! NSString) {
                backgroundImage.image = image
                self.circleButton.setImage(image, for: .normal)
                self.toggleLoading(isLoading: false)
            }
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true, block: { (timer) in self.updateUserInterface() })
    }
    
    // MARK: UPDATE UI //
    
    private func updateUserInterface() {
        if let info = audio.metadata {
            if let url = info["URL"] as? NSString {
                if let image = audio.imageCache.object(forKey: url) {
                    backgroundImage.image = image
                    self.circleButton.setImage(image, for: .normal)
                    if let item = audio.player.currentItem { self.progressBar.progress = Float(item.currentTime().seconds / item.duration.seconds) }
                }
            }
            self.toggleLoading(isLoading: false)
        }
        else { self.toggleLoading(isLoading: true) }

        if account.isPremium == false && audio.shouldDisplayAd {
            interstitial = self.createInterstitial();
            audio.shouldDisplayAd = false
        }
    }
    
    // MARK: TOGGLE LOADING //
    
    func toggleLoading(isLoading: Bool) {
        if isLoading {
            self.loadingView?.isHidden = false
            self.loadingSpinner?.startAnimating()
            self.controlCircleConstraint?.constant = 750
            self.loadingConstraint?.constant = -27.5
            
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.controlCircleView?.alpha = 0.0
                self.revealSidebarButton?.alpha = 0.0
            })
        }
        else {
            self.loadingView?.isHidden = true
            self.loadingSpinner?.stopAnimating()
            self.loadingConstraint?.constant = 750
            self.controlCircleConstraint?.constant = 0
            
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.controlCircleView?.alpha = 1.0
                self.revealSidebarButton?.alpha = 1.0
            })
        }
    }
    
    // MARK: TOGGLE SIDEBAR //
    
    func toggleSidebar() {
        let sOrigin = self.sidebar.frame.origin
        let sSize = self.sidebar.frame.size
        let bOrigin = self.revealSidebarButton.frame.origin
        let bSize = self.revealSidebarButton.frame.size
        
        if sOrigin.x == CGFloat(0.0) {
            UIView.animate(withDuration: 0.3, animations: {
                self.sidebar.frame = CGRect(x: sOrigin.x - sSize.width, y: sOrigin.y, width: sSize.width, height: sSize.height)
                self.revealSidebarButton.frame = CGRect(x: bOrigin.x - sSize.width, y: bOrigin.y, width: bSize.width, height: bSize.height)
                self.view.layoutIfNeeded()
            })
        }
        else if sOrigin.x == CGFloat(-175.0) {
            UIView.animate(withDuration: 0.3, animations: {
                self.sidebar.frame = CGRect(x: sOrigin.x + sSize.width, y: sOrigin.y, width: sSize.width, height: sSize.height)
                self.revealSidebarButton.frame = CGRect(x: bOrigin.x + sSize.width, y: bOrigin.y, width: bSize.width, height: bSize.height)
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // MARK: TOGGLE CIRCLE //

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
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) { if account.isPremium == false { ad.present(fromRootViewController: self) } }
    
    deinit { self.timer.invalidate() }
}
