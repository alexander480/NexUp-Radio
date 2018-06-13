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

class FavoriteVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let bannerID = "ca-app-pub-3940256099942544/2934735716"
    let fullScreenID = "ca-app-pub-3940256099942544/4411468910"
    
    var songs = [[String: String]]()
    var timer = Timer()
    
    @IBOutlet weak var banner: GADBannerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.banner.adUnitID = bannerID
        self.banner.rootViewController = self
        self.banner.adSize = kGADAdSizeSmartBannerPortrait
        self.banner.load(GADRequest())
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if account.favorites.isEmpty { account.fetchFavoriteSongs() }
        
        if let image = audio.metadata?["Image"] as? UIImage {
            self.backgroundImage?.image = image
            self.backgroundImage?.blur()
        }
        else {
            self.backgroundImage?.image = #imageLiteral(resourceName: "iTunesArtwork")
            self.backgroundImage?.blur()
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in self.updateUserInterface() })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { return 175 } else { return 100 }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if songs.isEmpty { return 1 } else { return songs.count + 1 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteHeader") as! AccountHeaderCell
                cell.cellTitle.text = "Favorite Songs"
                cell.cellDetail.text = "Check Out Your Favorite Songs"
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell") as! SongCell
            
            if let name = songs[row - 1]["Name"], let artist = songs[row - 1]["Artist"], let url = songs[row - 1]["Image"] {
                cell.cellTitle.text = name
                cell.cellDetail.text = artist
                cell.cellImage.imageFromServerURL(urlString: url, tableView: self.tableView, indexpath: indexPath)
                cell.cellImage.blur()
            }
            else {
                cell.cellTitle.text = "Loading..."
                cell.cellDetail.text = "Please Wait"
                cell.cellImage.image = nil
            }
            
            return cell
        }
    }
    
    private func updateUserInterface() {
        self.songs = account.favorites
        DispatchQueue.main.async { self.tableView.reloadData() }
        
        if self.songs.count == account.favorites.count { self.timer.invalidate() }
        // if account.favorites.isEmpty { self.timer.invalidate() }
    }
}
