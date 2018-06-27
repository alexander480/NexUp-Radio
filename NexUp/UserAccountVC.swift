//
//  UserAccountVC.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/6/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation

import UIKit
import GoogleMobileAds
import AVFoundation

import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class UserAccountVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let bannerID = "ca-app-pub-3940256099942544/2934735716"
    let fullScreenID = "ca-app-pub-3940256099942544/4411468910"
    
    var timer = Timer()
    var cellIndex: IndexPath?
    
    let options = ["Favorites", "Dislikes", "Recently Played", "Premium"]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var circleButton: ButtonClass!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if let image = audio.metadata?["Image"] as? UIImage {
            self.backgroundImage?.image = image
            self.backgroundImage?.blur()
        }
        else {
            self.backgroundImage?.image = #imageLiteral(resourceName: "iTunesArtwork")
            self.backgroundImage?.blur()
        }
        
        self.circleButton.setImage(#imageLiteral(resourceName: "iTunesArtwork"), for: .normal)
        self.progressBar.progress = 0.0
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in self.updateUserInterface() })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if let user = auth.currentUser { if let email = user.email { self.updateHeaderCell(UserEmail: email) } }
        else { if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") { present(vc, animated: true, completion: nil) } }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { return 215 } else if indexPath.row == 1 { return 90.5 } else { return 100 }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if row == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "AccountHeaderCell") as! AccountHeaderCell
            cell.cellImage.image = #imageLiteral(resourceName: "Image Account")
            cell.cellTitle.text = "User Account"
            cell.selectionStyle = .none
            if let email = auth.currentUser?.email { cell.cellDetail.text = email } else { cell.cellDetail.text = "Please Login or Register" }
            
            return cell
        }
        else if row == 1 {
            let cell: AdCell = tableView.dequeueReusableCell(withIdentifier: "AdCell", for: indexPath) as! AdCell
            let bannerView = cell.cellBannerView(rootVC: self, frame: cell.bounds)
            bannerView.adSize = GADAdSizeFromCGSize(CGSize(width: view.bounds.size.width, height: 90))
            
            for view in cell.contentView.subviews { if view.isMember(of: GADBannerView.self) { view.removeFromSuperview() } }
            
            cell.addSubview(bannerView)
            
            DispatchQueue.global(qos: .background).async() {
                let request = GADRequest()
                request.testDevices = [kGADSimulatorID]
                DispatchQueue.main.async() { bannerView.load(request) }
            }
            
            return cell
        }
        else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "AccountCell") as! AccountCell
            cell.cellTitle.text = options[row - 2]
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    private func updateHeaderCell(UserEmail: String) {
        let row = IndexPath(row: 0, section: 0)
        if let headerCell = self.tableView.cellForRow(at: row) as? AccountHeaderCell {
            headerCell.cellDetail.text = UserEmail
            self.tableView.reloadRows(at: [row], with: UITableViewRowAnimation.automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") { present(vc, animated: true, completion: nil) }
}
        if indexPath.row == 2 {
            if auth.currentUser == nil {
                self.alert(Title: "Please Login or Sign up", Description: nil)
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") {
                    present(vc, animated: true, completion: nil)
                }
            }
            else {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "FavoriteVC") {
                    present(vc, animated: true, completion: nil)
                }
            }
        }
        else if indexPath.row == 3 {
            if auth.currentUser == nil {
                self.alert(Title: "Please Login or Sign up", Description: nil)
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") { present(vc, animated: true, completion: nil) }
            }
            else {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "DislikeVC") { present(vc, animated: true, completion: nil) }
            }
        }
        else if indexPath.row == 4 {
            if auth.currentUser == nil {
                self.alert(Title: "Please Login or Sign up", Description: nil)
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") { present(vc, animated: true, completion: nil) }
            }
            else {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "RecentVC") { present(vc, animated: true, completion: nil) }
            }
        }
        else if indexPath.row == 5 {
            if auth.currentUser == nil {
                self.alert(Title: "Please Login or Sign up", Description: nil)
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") { present(vc, animated: true, completion: nil) }
            }
            else {
                let subscriptions = SubscriptionHandler()
                subscriptions.getInfo()
                subscriptions.showAlert(ViewController: self)
            }
        }
    }
    
    private func updateUserInterface() {
        if let info = audio.metadata {
            if let image = info["Image"] as? UIImage {
                self.circleButton.setImage(image, for: .normal)
                if let item = audio.player.currentItem { self.progressBar.progress = Float(item.currentTime().seconds / item.duration.seconds) }
            }
        }
    }
}
