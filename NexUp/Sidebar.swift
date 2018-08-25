//
//  CircleGenres.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/20/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import UIKit

class Sidebar: UIViewController {
    var timer = Timer()
    
    @IBOutlet weak var hipHopButton: UIButton!
    @IBAction func hipHopAction(_ sender: Any) { audio.player.removeAllItems(); audio.startPlaylist(Name: "Hip Hop"); self.hide() }
    
    @IBOutlet weak var rbButton: UIButton!
    @IBAction func rbAction(_ sender: Any) { audio.player.removeAllItems(); audio.startPlaylist(Name: "R&B"); self.hide() }
    
    @IBOutlet weak var jazzButton: UIButton!
    @IBAction func jazzAction(_ sender: Any) { audio.player.removeAllItems(); audio.startPlaylist(Name: "Jazz"); self.hide() }
    
    @IBOutlet weak var gospelButton: UIButton!
    @IBAction func gospelAction(_ sender: Any) { audio.player.removeAllItems(); audio.startPlaylist(Name: "Gospel"); self.hide() }
    
    @IBOutlet weak var topTenButton: UIButton!
    @IBAction func topTenAction(_ sender: Any) { audio.player.removeAllItems(); audio.startPlaylist(Name: "Top Ten"); self.hide(); }
    
    @IBOutlet weak var djButton: UIButton!
    @IBAction func djActions(_ sender: Any) { audio.player.removeAllItems(); audio.startPlaylist(Name: "DJ"); self.hide() }
    
    @IBOutlet weak var favoritesButton: UIButton!
    @IBAction func favoritesAction(_ sender: Any) { audio.player.removeAllItems(); audio.startFavorites(); self.hide() }
    
    override func viewDidLoad() { super.viewDidLoad(); if account.isPremium { self.favoritesButton?.isHidden = false } else { self.favoritesButton?.isHidden = true } }
    
    private func hide() { if let vc = self.parent as? NowPlayingVC { vc.toggleSidebar(); vc.toggleLoading(isLoading: true) } }
}
