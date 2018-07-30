//
//  PremiumVC.swift
//  NexUp
//
//  Created by Alexander Lester on 7/30/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import UIKit

class PremiumVC: UIViewController {
    let sub = SubscriptionHandler()
    
    @IBAction func purchaseAction(_ sender: Any) {
        let alert = UIAlertController(title: "We Will Charge $1.99 To Your iTunes Account On A Monthly Basis", message: "For More Information Click On 'Learn More Below'", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (alertAction) in
            self.sub.purchase { (success) in
                if success { self.alert(Title: "Success!", Description: "Welcome To NexUp Premium.") }
                else { self.alert(Title: "Error", Description: "Sorry, Something Went Wrong. Please Try Again.") }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (alertAction) in
            alert.dismiss(animated: true, completion: nil)
        }))
    }
    
    @IBAction func restoreAction(_ sender: Any) {
        sub.restore { (success) in
            if success { self.alert(Title: "Success!", Description: "Welcome Back To NexUp Premium.") }
            else { self.alert(Title: "Error", Description: "Sorry, Something Went Wrong. Please Try Again.") }
        }
    }
    
    @IBAction func termsAction(_ sender: Any) {
        if let url = URL(string: "https://designsbylagb.com/nexup-terms.html") { UIApplication.shared.open(url) }
    }
    
    @IBAction func privacyAction(_ sender: Any) {
        if let url = URL(string: "https://designsbylagb.com/nexup-terms.html") { UIApplication.shared.open(url) }
    }
    
    @IBAction func cancelAction(_ sender: Any) { self.dismiss(animated: true, completion: nil) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if account.isPremium {
            self.alert(Title: "You're Already A Premium User", Description: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
