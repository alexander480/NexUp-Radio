//
//  FavoriteVC.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/24/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class RecentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let bannerID = "ca-app-pub-6543648439575950/8381413905"
    let fullScreenID = "ca-app-pub-6543648439575950/9063940183"
    
    var songs = [[String: String]]()
    var tableTimer = Timer()
    var timer = Timer()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var circleButton: ButtonClass!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if account.recents.isEmpty { account.fetchRecentSongs() }
        
        if let info = audio.metadata {
            if let image = audio.imageCache.object(forKey: info["URL"] as! NSString) {
                backgroundImage.image = image
                backgroundImage.blur()
                self.circleButton.setImage(image, for: .normal)
            }
        }
        
        self.tableTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in self.updateTableData() })
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in self.updateUserInterface() })
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if account.isPremium { if indexPath.row == 0 { return 185 } else { return 100 } }
        else { if indexPath.row == 0 { return 185 } else if indexPath.row == 1 { return 90.5 } else { return 100 } }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if account.isPremium { if songs.isEmpty { return 1 } else { return self.songs.count + 1 } }
        else { if songs.isEmpty { return 2 } else { return self.songs.count + 2 } }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteHeader") as! AccountHeaderCell
            cell.cellTitle.text = "Recently Played"
            cell.cellDetail.text = "Check Out Your Recent Songs"
            
            return cell
        }
        else if row == 1 && account.isPremium == false {
            let cell: AdCell = tableView.dequeueReusableCell(withIdentifier: "AdCell", for: indexPath) as! AdCell
            let bannerView = cell.cellBannerView(rootVC: self, frame: cell.bounds)
            bannerView.adSize = GADAdSizeFromCGSize(CGSize(width: view.bounds.size.width, height: 90))
            for view in cell.contentView.subviews {
                if view.isMember(of: GADBannerView.self) {
                    view.removeFromSuperview() // Make sure that the cell does not have any previously added GADBanner view as it would be reused
                }
            }
            
            cell.addSubview(bannerView)
            
            DispatchQueue.global(qos: .background).async() { // Get the request in the background thread
                let request = GADRequest(); request.testDevices = [kGADSimulatorID]
                DispatchQueue.main.async() { bannerView.load(request) }
            }
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell") as! SongCell
            var x = 2; if account.isPremium { x = 1 }
            if let name = songs[row - x]["Name"], let artist = songs[row - x]["Artist"], let url = songs[row - x]["Image"] {
                cell.cellTitle.text = name
                cell.cellDetail.text = artist
                cell.cellImage.imageFrom(urlString: url)
            }
            else {
                cell.cellTitle.text = "Loading"
                cell.cellDetail.text = nil
                cell.cellImage.image = nil
            }
            
            return cell
        }
    }
    
    private func updateUserInterface() {
        if let info = audio.metadata { if let image = info["Image"] as? UIImage {
            self.circleButton.setImage(image, for: .normal) }
            if let item = audio.player.currentItem { self.progressBar.progress = Float(item.currentTime().seconds / item.duration.seconds) }
        }
    }
    
    private func updateTableData() {
        if self.songs.count != account.recents.count { self.songs = account.recents; DispatchQueue.main.async { self.tableView.reloadData() } }
        else { self.tableTimer.invalidate() }
    }
}
