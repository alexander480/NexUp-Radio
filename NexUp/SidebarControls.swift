//
//  CircleGenres.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/20/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//


import Foundation
import UIKit

class Sidebar: UIViewController
{
    var timer = Timer()
    var npvc: NowPlayingVC?
    
    @IBOutlet weak var hipHopButton: UIButton!
    @IBAction func hipHopAction(_ sender: Any) { self.startStation(StationName: "Hip Hop") }
    
    @IBOutlet weak var rbButton: UIButton!
    @IBAction func rbAction(_ sender: Any) { self.startStation(StationName: "R&B") }
    
    @IBOutlet weak var jazzButton: UIButton!
    @IBAction func jazzAction(_ sender: Any) { self.startStation(StationName: "Jazz") }
    
    @IBOutlet weak var gospelButton: UIButton!
    @IBAction func gospelAction(_ sender: Any) { self.startStation(StationName: "Gospel") }
    
    @IBOutlet weak var topTenButton: UIButton!
    @IBAction func topTenAction(_ sender: Any) { self.startStation(StationName: "Top Ten") }
    
    @IBOutlet weak var djButton: UIButton!
    @IBAction func djActions(_ sender: Any) { self.startStation(StationName: "DJ") }
    
    @IBOutlet weak var favoritesButton: UIButton!
    @IBAction func favoritesAction(_ sender: Any) { self.startStation(StationName: "Favorites") }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.npvc = self.parent as? NowPlayingVC
        
        account.isPremiumUser()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in self.updateUserInterface() })
    }
    
    private func updateUserInterface()
    {
        if account.isPremium { self.favoritesButton?.isHidden = false }
        else { self.favoritesButton?.isHidden = true }
    }
    
    private func startStation(StationName: String)
    {
        audio.fetchPlaylist(PlaylistName: StationName)
        audio.metadata = audio.fetchMetadata()
        
        self.hide()
        npvc?.toggleLoading(isLoading: true)
    }
    
    private func hide() { let vc = (self.parent as! NowPlayingVC); vc.toggleSidebar() }
}
