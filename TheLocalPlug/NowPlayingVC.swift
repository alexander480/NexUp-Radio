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
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

let account = Account()
var audio = Audio(FromPlaylist: "HipHop")

var recentlyPlayed = [[String: Any]]()

class NowPlayingVC: UIViewController
{
    var timer = Timer()
    
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
        self.backgroundImage?.image = #imageLiteral(resourceName: "j3detroit")
        self.backgroundImage?.blur()
        
        self.toggleLoading(isLoading: true)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in self.updateUserInterface() })
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
    }
    
    private func toggleLoading(isLoading: Bool)
    {
        if isLoading
        {
            self.loadingView?.isHidden = false
            
            self.loadingSpinner?.startAnimating()
            
            self.controlCircleConstraint?.constant = 750
            self.loadingConstraint?.constant = -27.5
            
            UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
        }
        else
        {
            self.loadingView?.isHidden = true
            
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
        if self.sidebarConstraint?.constant == -101 { self.sidebarConstraint?.constant = -301 }
        else if self.sidebarConstraint?.constant == -301 { self.sidebarConstraint?.constant = -101 }
        
        UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
    }
    
    deinit { self.timer.invalidate() }
}
