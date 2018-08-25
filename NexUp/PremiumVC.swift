//
//  PremiumVC.swift
//  NexUp
//
//  Created by Alexander Lester on 7/30/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import UIKit

import FirebaseAuth
import SwiftyStoreKit

class PremiumVC: UIViewController {
    
    @IBAction func purchaseAction(_ sender: Any) { self.fullService() }
    @IBAction func restoreAction(_ sender: Any) { self.restore() }
    @IBAction func termsAction(_ sender: Any) { self.present(TermsVC(), animated: true, completion: nil) }
    @IBAction func privacyAction(_ sender: Any) { self.present(PrivacyVC(), animated: true, completion: nil) }
    @IBAction func learnAction(_ sender: Any) { self.present(LearnMoreVC(), animated: true, completion: nil) }
    @IBAction func cancelAction(_ sender: Any) { self.dismiss(animated: true, completion: nil) }

    // MARK: Purchase Premium Subscription
    private func fullService() {
        SwiftyStoreKit.retrieveProductsInfo(Set(["com.lagbtech.nexup_radio.premium"])) { (result) in
            if result.retrievedProducts.isEmpty == false {
                print("[INFO] Retrieved \(result.retrievedProducts.count) StoreKit Products");
                if let product = result.retrievedProducts.first {
                    SwiftyStoreKit.purchaseProduct(product) { (result) in
                        if case .success(let purchase) = result {
                            if purchase.needsFinishTransaction { SwiftyStoreKit.finishTransaction(purchase.transaction) }
                            let validator = AppleReceiptValidator(service: .production, sharedSecret: "28c35d969edc4f739e985dbe912a963d")
                            SwiftyStoreKit.verifyReceipt(using: validator, completion: { (receiptResult) in
                                if case .success(let receipt) = receiptResult {
                                    let verify = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: "com.lagbtech.nexup_radio.premium", inReceipt: receipt)
                                    switch verify {
                                    case .purchased(let expiryDate, _):
                                        print("[INFO] Purchase Successful")
                                        self.alert(Title: "Success", Description: "Subscription is valid until \(expiryDate)")
                                        self.premify()
                                    case .expired(let expiryDate, _):
                                        print("[INFO] Subscription Expired")
                                        self.alert(Title: "Subscription Expired", Description: "Your subscription expired on \(expiryDate)")
                                    case .notPurchased:
                                        print("[ERROR] Unknown Error - Could Not Purchase")
                                        self.alert(Title: "Error", Description: "Purchase unsuccessful")
                                    }
                                }
                            })
                        }
                    }
                }
            }
            else if result.invalidProductIDs.isEmpty == false {
                print("[ERROR] Invalid Product Identifiers: \(result.invalidProductIDs)")
                self.alert(Title: "Error", Description: "Please Try Again")
            }
            else if result.error != nil {
                print("[ERROR] Unknown Error While Retrieving StoreKit Products")
                self.alert(Title: "Error", Description: "Please Try Again")
            }
        }
    }
    
    // MARK: Make User Premium
    private func premify() {
        if let user = auth.currentUser {
            print("[INFO] User Is Now Premium")
            db.reference(withPath: "users/\(user.uid)/isPremium").setValue(true)
            account.isPremium = true
        }
    }
    
    // MARK: Restore Previous Purchases
    private func restore() {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("[ERROR] Unknown Error - Failed To Restore Products")
                self.alert(Title: "Error", Description: "Sorry, Something Went Wrong. Please Try Again.")
            }
            else if results.restoredPurchases.count > 0 {
                print("[INFO] Restoration Successful")
                self.alert(Title: "Success!", Description: "Welcome Back To NexUp Premium.")
                self.premify()
            }
            else {
                print("[INFO] Nothing To Restore")
                self.alert(Title: "Nothing To Restore", Description: nil)
            }
        }
    }
}
