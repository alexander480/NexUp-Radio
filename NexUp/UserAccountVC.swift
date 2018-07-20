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
    let bannerID = "ca-app-pub-6543648439575950/8381413905"
    let fullScreenID = "ca-app-pub-6543648439575950/9063940183"
    
    let options = ["Favorites", "Dislikes", "Recently Played", "Premium"]
    var timer = Timer()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var circleButton: ButtonClass!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if let info = audio.metadata {
            if let image = audio.imageCache.object(forKey: info["URL"] as! NSString) {
                backgroundImage.image = image
                backgroundImage.blur()
                self.circleButton.setImage(image, for: .normal)
            }
        }
        
        self.progressBar.progress = 0.0
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in self.updateUserInterface() })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if let email = auth.currentUser?.email { self.updateHeaderCell(UserEmail: email) } else { self.present(vcid: "AuthVC") }
    }
    
    private func updateUserInterface() {
        if let info = audio.metadata {
            if let image = info["Image"] as? UIImage {
                self.circleButton.setImage(image, for: .normal)
                if let item = audio.player.currentItem { self.progressBar.progress = Float(item.currentTime().seconds / item.duration.seconds) }
            }
        }
    }
    
    private func updateHeaderCell(UserEmail: String) {
        let row = IndexPath(row: 0, section: 0)
        if let headerCell = self.tableView.cellForRow(at: row) as? AccountHeaderCell {
            headerCell.cellDetail.text = UserEmail
            self.tableView.reloadRows(at: [row], with: UITableViewRowAnimation.automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if account.isPremium { if indexPath.row == 0 { return 215 } else { return 100 } }
        else { if indexPath.row == 0 { return 200 } else if indexPath.row == 1 { return 90.5 } else { return 100 } }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if account.isPremium { return options.count + 1 } else { return options.count + 2 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if row == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "AccountHeaderCell") as! AccountHeaderCell
                cell.cellTitle.text = "User Account"
                cell.cellImage.image = #imageLiteral(resourceName: "Image Account")
                cell.selectionStyle = .none
            
                if let email = auth.currentUser?.email { cell.cellDetail.text = email }
                else { cell.cellDetail.text = "Please Login or Register" }
            
            return cell
        }
        else if row == 1 && account.isPremium == false {
            let cell: AdCell = tableView.dequeueReusableCell(withIdentifier: "AdCell", for: indexPath) as! AdCell
            let bannerView = cell.cellBannerView(rootVC: self, frame: cell.bounds)
                bannerView.adSize = GADAdSizeFromCGSize(CGSize(width: view.bounds.size.width, height: 90))
            for view in cell.contentView.subviews {
                if view.isMember(of: GADBannerView.self) {
                    view.removeFromSuperview()
                }
            }
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
                if account.isPremium { cell.cellTitle.text = options[row - 1] }
                else { cell.cellTitle.text = options[row - 2] }
                cell.selectionStyle = .none
            
            return cell
        }
    }
    
    // Variable "x" Is To Account For The IndexPath Offset By Advertisments For Non-Premium Users
    // If User Is Not Premium: x = 1; If User Is Premium: x = 0; "x" Represents The Extra Row Taken Up By Banner Ad
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var x = 1; if account.isPremium { x = 0 }
        
        if indexPath.row == 0 { self.present(vcid: "AuthVC") }
        if indexPath.row == 1 + x {
            if auth.currentUser == nil { self.alert(Title: "Please Login or Sign up", Description: nil); self.present(vcid: "AuthVC") }
            self.present(vcid: "FavoriteVC")
        }
        else if indexPath.row == 2 + x {
            if auth.currentUser == nil { self.alert(Title: "Please Login or Sign up", Description: nil); self.present(vcid: "AuthVC") }
            self.present(vcid: "DislikeVC")
        }
        else if indexPath.row == 3 + x {
            if auth.currentUser == nil { self.alert(Title: "Please Login or Sign up", Description: nil); self.present(vcid: "AuthVC") }
            self.present(vcid: "RecentVC")
        }
        else if indexPath.row == 4 + x {
            if auth.currentUser == nil { self.alert(Title: "Please Login or Sign up", Description: nil); self.present(vcid: "AuthVC") }
            else {
                let subscriptions = SubscriptionHandler()
                subscriptions.getInfo()
                subscriptions.showAlert(ViewController: self)
            }
        }
    }
    
    private func present(vcid: String) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: vcid) {
            present(vc, animated: true, completion: nil)
        }
    }
}
