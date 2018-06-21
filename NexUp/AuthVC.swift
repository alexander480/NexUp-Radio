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

//  TODO
// ----------------------------------------------
//
//

class AuthVC: UIViewController {
    var timer = Timer()
    let bannerID = "ca-app-pub-3940256099942544/2934735716"
    let fullScreenID = "ca-app-pub-3940256099942544/4411468910"
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var circleButton: ButtonClass!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBAction func register(_ sender: Any) {
        if let email = self.emailField.text, let password = self.passwordField.text {
            auth.createUser(withEmail: email, password: password, completion: { (usr, err) in
                if let user = usr?.user {
                    print("[INFO] User \(user.uid) Account Created")
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserAccountVC") { self.present(vc, animated: true, completion: nil) }
                    else { print("Error Initalizing ArtistVC") }
                }
                else if let error = err {
                    print("[WARNING] Could Not Register User")
                    print(error.localizedDescription)
                    
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
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserAccountVC") { self.present(vc, animated: true, completion: nil) }
                    else { print("Error Initalizing ArtistVC") }
                }
                else if let error = err {
                    print("[WARNING] Could Not Sign In User")
                    print(error.localizedDescription)
                    
                    self.alert(Title: "Error", Description: error.localizedDescription)
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        timer = Timer(timeInterval: 1.0, repeats: true, block: { (timer) in
            if let info = audio.metadata {
                if let image = info["Image"] as? UIImage {
                    self.circleButton.setImage(image, for: .normal)
                }
            }
            if let item = audio.player.currentItem {
                self.progressBar.progress = Float(item.currentTime().seconds / item.duration.seconds)
            }
        })
    }
}
