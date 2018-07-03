//
//  ArtistInfoVC.swift
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

//  TODO
// ----------------------------------------------
//

class ArtistInfoVC: UIViewController {
    var timer = Timer()
    var artist = artistSelected
    
    @IBOutlet weak var banner: GADBannerView!
    
    @IBOutlet weak var circleButton: ButtonClass!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var artistCircleImage: ImageViewClass!
    @IBOutlet weak var artistBio: UILabel!
    
    @IBAction func fbAction(_ sender: Any) { if let fbLink = self.artist["Facebook"] { UIApplication.shared.open(URL(string : fbLink)!) } }
    @IBAction func twitterAction(_ sender: Any) { if let twitterLink = self.artist["Twitter"] { UIApplication.shared.open(URL(string : twitterLink)!) } }
    @IBAction func instaAction(_ sender: Any) { if let instaLink = self.artist["Instagram"] { UIApplication.shared.open(URL(string : instaLink)!) } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let info = audio.metadata {
            if let image = audio.imageCache.object(forKey: info["URL"] as! NSString) {
                self.circleButton.setImage(image, for: .normal)
            }
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in self.updateUserInterface() })
    }
    
    private func updateUserInterface() {
        self.artist = artistSelected
        if self.artist.isEmpty == false {
            self.artistName?.text = artist["Name"]
            self.artistBio?.text = artist["Bio"]
            self.artistImage?.imageFrom(urlString: artist["ImageURL"]!)
            self.artistCircleImage?.imageFrom(urlString: artist["ImageURL"]!)
            
            self.artistImage?.blur()
        }
        
        if let info = audio.metadata {
            if let image = info["Image"] as? UIImage {
                self.circleButton.setImage(image, for: .normal)
            }
        }
        if let item = audio.player.currentItem {
            self.progressBar.progress = Float(item.currentTime().seconds / item.duration.seconds)
        }
    }
}
