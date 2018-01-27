//
//  DislikeVC.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/24/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import UIKit

class DislikeVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var songs = [[String: Any]]()
    
    var timer = Timer()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if account.dislikes.isEmpty { account.fetchDislikes() }
        
        if let image = audio.metadata?["Image"] as? UIImage { self.backgroundImage?.image = image; self.backgroundImage?.blur() }
        else { self.backgroundImage?.image = #imageLiteral(resourceName: "j3detroit"); self.backgroundImage?.blur() }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in self.updateUserInterface() })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { return 175 } else { return 100 }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if songs.isEmpty { return 1 } else { return songs.count + 1 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteHeader") as! AccountHeaderCell
                cell.cellTitle.text = "Disliked Songs"
                cell.cellDetail.text = "Check Out Your Disliked Songs"
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell") as! SongCell
                cell.cellTitle.text = (songs[indexPath.row - 1]["Name"] as? String)
                cell.cellDetail.text = (songs[indexPath.row - 1]["Artist"] as? String)
                cell.cellImage.image = (songs[indexPath.row - 1]["Image"] as? UIImage)
                cell.cellImage.alpha = 0.50
            
            return cell
        }
    }
    
    private func updateUserInterface() {
        self.songs = account.dislikes
        self.tableView.reloadData()
        
        // if self.songs.count == account.dislikes.count { self.timer.invalidate() }
    }
}
