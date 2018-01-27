//
//  UserAccountVC.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/6/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class UserAccountVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    let options = ["Favorites", "Dislikes", "Recently Played", "Premium"]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
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
        self.updateHeaderCell()
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
    
    private func isAuthorized() -> User?
    {
        if let usr = auth.currentUser
        {
            print("[INFO] User \(usr.uid) Is Logged In")
            return usr
        }
        else
        {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") { present(vc, animated: true, completion: nil) }
            else { print("Error Initalizing AuthVC") }
            return nil
        }
    }
    
    private func updateHeaderCell()
    {
        let row = IndexPath(row: 0, section: 0)
        if let headerCell = self.tableView.cellForRow(at: row) as? AccountHeaderCell
        {
            if let email = self.isAuthorized()?.email
            {
                headerCell.cellDetail.text = email
                self.tableView.reloadRows(at: [row], with: UITableViewRowAnimation.automatic)
            }
        }
    }
    
    private func cellHandler(forRow: Int) -> UITableViewCell
    {
        if forRow == 0
        {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "AccountHeaderCell") as! AccountHeaderCell
            cell.cellImage.image = #imageLiteral(resourceName: "Image Account")
            cell.cellTitle.text = "User Account"
            cell.cellDetail.text = "alexander480@gmail.com"
            
            return cell
        }
        else
        {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "AccountCell") as! AccountCell
            cell.cellTitle.text = options[forRow - 1]
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "FavoriteVC") { present(vc, animated: true, completion: nil) }
        }
        else if indexPath.row == 2 {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "DislikeVC") { present(vc, animated: true, completion: nil) }
        }
        else if indexPath.row == 3 {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "RecentVC") { present(vc, animated: true, completion: nil) }
        }
    }
}
