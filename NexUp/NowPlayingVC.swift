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
    
    var interstitial: GADInterstitial!
    var timer = Timer()
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var controlCircleConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlCircleView: UIView!
    
    @IBOutlet weak var loadingView: ViewClass!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var loadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var revealSidebarButton: ButtonClass!
    @IBAction func revealSidebarAction(_ sender: Any) { self.toggleSidebar() }
    @IBOutlet weak var sidebar: UIView!
    
    @IBOutlet weak var circleButton: ButtonClass!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // account.shouldRefreshSkipCount()
        
        self.circleButton.setImage(#imageLiteral(resourceName: "iTunesArtwork"), for: .normal)
        self.progressBar.progress = 0.0
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in self.updateUserInterface() })
    }
    
    private func updateUserInterface() {
        if let info = audio.metadata {
            if let image = info["Image"] as? UIImage, let background = self.backgroundImage {
                self.circleButton.setImage(image, for: .normal)
                background.removeBlur(); background.image = image; background.isHidden = false;
                if let item = audio.player.currentItem { self.progressBar.progress = Float(item.currentTime().seconds / item.duration.seconds) }
            }
            self.toggleLoading(isLoading: false)
        }
        else { self.toggleLoading(isLoading: true) }
        if audio.shouldDisplayAd { interstitial = self.createInterstitial(); audio.shouldDisplayAd = false }
    }
    
    // MARK: Toggle Loading
    
    func toggleLoading(isLoading: Bool) {
        if isLoading {
            self.sidebar?.isHidden = true
            self.revealSidebarButton?.isHidden = true
            
            self.loadingView?.isHidden = false
            self.loadingSpinner?.startAnimating()
            
            self.controlCircleConstraint?.constant = 750
            self.loadingConstraint?.constant = -27.5
            
            UIView.animate(withDuration: 0.5, animations: { self.view.layoutIfNeeded() })
            
            
        }
        else {
            self.revealSidebarButton?.isHidden = false
            
            self.loadingView?.isHidden = true
            self.loadingSpinner?.stopAnimating()
            self.loadingConstraint?.constant = 750
            
            self.controlCircleView.isHidden = false
            self.controlCircleConstraint?.constant = 0
            
            UIView.animate(withDuration: 0.5, animations: { self.view.layoutIfNeeded() })
            self.sidebar?.isHidden = false
        }
    }
    
    // MARK: Toggle Sidebar //
    
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

    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        let segue = UnwindScaleSegue(identifier: unwindSegue.identifier, source: unwindSegue.source, destination: unwindSegue.destination)
        segue.perform()
    }
    
    deinit { self.timer.invalidate() }
}
