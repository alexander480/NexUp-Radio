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

class UserAccountVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    let options = ["Favorites", "Dislikes", "Recently Played", "Premium"]
    
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
        
        if let image = audio.metadata?["Image"] as? UIImage {
            self.backgroundImage?.image = image
            self.backgroundImage?.blur()
        }
        else
        {
            self.backgroundImage?.image = #imageLiteral(resourceName: "j3detroit")
            self.backgroundImage?.blur()
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        
        if let user = auth.currentUser { if let email = user.email { self.updateHeaderCell(UserEmail: email) } }
        else { if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") { present(vc, animated: true, completion: nil) } }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { return 185 } else { return 85 }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.cellHandler(forRow: indexPath.row)
        return cell
    }
    
    private func updateHeaderCell(UserEmail: String)
    {
        let row = IndexPath(row: 0, section: 0)
        if let headerCell = self.tableView.cellForRow(at: row) as? AccountHeaderCell
        {
            headerCell.cellDetail.text = UserEmail
            self.tableView.reloadRows(at: [row], with: UITableViewRowAnimation.automatic)
        }
    }
    
    private func cellHandler(forRow: Int) -> UITableViewCell
    {
        if forRow == 0
        {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "AccountHeaderCell") as! AccountHeaderCell
            cell.cellImage.image = #imageLiteral(resourceName: "Image Account")
            cell.cellTitle.text = "User Account"
            cell.selectionStyle = .none
            if let email = auth.currentUser?.email { cell.cellDetail.text = email } else { cell.cellDetail.text = "Please Login or Register" }

            return cell
        }
        else
        {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "AccountCell") as! AccountCell
            cell.cellTitle.text = options[forRow - 1]
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") { present(vc, animated: true, completion: nil) }
}
        if indexPath.row == 1 {
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
        else if indexPath.row == 2 {
            if auth.currentUser == nil {
                self.alert(Title: "Please Login or Sign up", Description: nil)
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") { present(vc, animated: true, completion: nil) }
            }
            else {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "DislikeVC") { present(vc, animated: true, completion: nil) }
            }
        }
        else if indexPath.row == 3 {
            if auth.currentUser == nil {
                self.alert(Title: "Please Login or Sign up", Description: nil)
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") { present(vc, animated: true, completion: nil) }
            }
            else {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "RecentVC") { present(vc, animated: true, completion: nil) }
            }
        }
        else if indexPath.row == 4 {
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
}
