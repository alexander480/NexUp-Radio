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
    @IBOutlet weak var hipHopButton: UIButton!
    @IBAction func hipHopAction(_ sender: Any) { self.startStation(StationName: "HipHop") }
    
    @IBOutlet weak var rbButton: UIButton!
    @IBAction func rbAction(_ sender: Any) { self.startStation(StationName: "R&B") }
    
    @IBOutlet weak var jazzButton: UIButton!
    @IBAction func jazzAction(_ sender: Any) { self.startStation(StationName: "Jazz") }
    
    @IBOutlet weak var gospelButton: UIButton!
    @IBAction func gospelAction(_ sender: Any) { self.startStation(StationName: "Gospel") }
    
    @IBOutlet weak var topTenButton: UIButton!
    @IBAction func topTenAction(_ sender: Any) { self.startStation(StationName: "Top Ten"); }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    private func startStation(StationName: String)
    {
        audio.setup(playlist: StationName)
        self.hide()
    }
    
    private func hide() {
        let vc = self.parent as! NowPlayingVC
        vc.toggleSidebar()
    }
}
