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

class NowPlayingVC: UIViewController, GADInterstitialDelegate, AudioDelegate {
    
    let bannerID = "ca-app-pub-6543648439575950/8381413905"
    let fullScreenID = "ca-app-pub-6543648439575950/9063940183"

    var timer = Timer()
    
    let metadata = MetadataHandler()
    let ads = Advertisments()
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var controlCircleConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlCircleView: UIView!
    
    @IBOutlet weak var launchScreenCircleLogo: UIImageView!
    @IBOutlet weak var launchScreenDeltaVel: UIImageView!
    
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
        
        metadata.populateNowPlaying(npvc: self)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true, block: { (timer) in self.updateUserInterface() })
    }
    
    private func updateUserInterface() {
        if auth.currentUser == nil {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") {
                self.present(vc, animated: true, completion: nil)
            }
        }
        else {
            metadata.updateInterface(npvc: self)
            //ads.checkForInterstitial(Delegate: self)
        }
    }
    
    func didReachLimit() {
        print("[INFO] Skip Limit Reached")
        let alert = UIAlertController(title: "Skip Limit Reached.", message: "Please wait", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func toggleLoading(isLoading: Bool) {
        if isLoading {
            self.loadingView?.isHidden = true
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
            self.launchScreenCircleLogo.isHidden = true
            self.launchScreenDeltaVel.isHidden = true
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
    
    private func toggleCircle() {
        if self.controlCircleConstraint?.constant == 0 {
            self.controlCircleConstraint?.constant = 750
        }
        else if self.controlCircleConstraint?.constant == 750 {
            self.controlCircleConstraint?.constant = 0
        }
        UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if account.isPremium == false {
            ad.present(fromRootViewController: self)
        }
    }
    
    deinit { self.timer.invalidate() }
}
