//
//  ArtistInfoVC.swift
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

//  TODO
// ----------------------------------------------
//

class ArtistInfoVC: UIViewController
{
    var timer = Timer()
    var artist = artistSelected
    
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var artistCircleImage: ImageViewClass!
    @IBOutlet weak var artistBio: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in self.updateUserInterface() })
    }
    
    private func updateUserInterface()
    {
        self.artist = artistSelected
        
        if self.artist.isEmpty == false
        {
            self.artistName?.text = artist["Name"] as? String
            self.artistBio?.text = artist["Bio"] as? String
            self.artistImage?.image = (artist["Image"] as? UIImage)
            self.artistCircleImage?.image = artist["Image"] as? UIImage
            self.artistImage?.blur()
            
            self.timer.invalidate()
        }
    }
}
