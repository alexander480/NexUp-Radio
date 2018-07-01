//
//  AuthVC.swift
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

class AuthVC: UIViewController {
    
    let bannerID = "ca-app-pub-3940256099942544/2934735716"
    let fullScreenID = "ca-app-pub-3940256099942544/4411468910"
    
    var timer = Timer()
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var circleButton: ButtonClass!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBAction func register(_ sender: Any) {
        if let email = self.emailField.text, let password = self.passwordField.text {
            auth.createUser(withEmail: email, password: password, completion: { (usr, err) in
                if let user = usr?.user {
                    print("[INFO] User \(user.uid) Account Created")
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "NowPlayingVC") { self.present(vc, animated: true, completion: nil) }
                    account.syncSkipCount()
                    account.syncPremiumStatus()
                }
                else if let error = err {
                    print("[WARNING] Could Not Register User")
                    self.alert(Title: "Error", Description: error.localizedDescription)
                }
            })
        }
    }
    
    @IBAction func login(_ sender: Any) {
        if let email = self.emailField.text, let password = self.passwordField.text {
            auth.signIn(withEmail: email, password: password, completion: { (usr, err) in
                if let user = usr?.user {
                    print("[INFO] User \(user.uid) Signed In")
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "NowPlayingVC") { self.present(vc, animated: true, completion: nil) }
                    account.syncSkipCount()
                    account.syncPremiumStatus()
                }
                else if let error = err {
                    print("[WARNING] Could Not Sign In User")
                    self.alert(Title: "Error", Description: error.localizedDescription)
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        if let info = audio.metadata {
            if let image = audio.imageCache.object(forKey: info["URL"] as! NSString) {
                self.circleButton.setImage(image, for: .normal)
            }
        }
        
        self.timer = Timer(timeInterval: 1.0, repeats: true, block: { (timer) in
            if let info = audio.metadata, let image = info["Image"] as? UIImage {
                if let item = audio.player.currentItem { self.progressBar.progress = Float(item.currentTime().seconds / item.duration.seconds) }
                self.circleButton.setImage(image, for: .normal)
            }
        })
    }
}
