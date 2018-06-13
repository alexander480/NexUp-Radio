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
    let bannerID = "ca-app-pub-3940256099942544/2934735716"
    let fullScreenID = "ca-app-pub-3940256099942544/4411468910"
    
    @IBOutlet weak var banner: GADBannerView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
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
        
        self.banner.adUnitID = bannerID
        self.banner.rootViewController = self
        self.banner.adSize = kGADAdSizeSmartBannerPortrait
        self.banner.load(GADRequest())
    }
}
