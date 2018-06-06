//
//  SubscriptionHelper.swift
//  NexUp
//
//  Created by Alexander Lester on 2/8/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import StoreKit

class SubscriptionHandler: NSObject
{
    let validator = AppleReceiptValidator(service: .production, sharedSecret: "28c35d969edc4f739e985dbe912a963d")
    
    typealias RecieptVerificationHandler = (String) -> ()
    
    var subscriptionIdentifiers: Set<String>
    var subscriptions: Set<SKProduct>?
    
    init(SubscriptionIdentifiers: [String])
    {
        self.subscriptionIdentifiers = Set(SubscriptionIdentifiers)
        super.init()
        
        SwiftyStoreKit.retrieveProductsInfo(self.subscriptionIdentifiers) { (result) in
            if result.retrievedProducts.isEmpty == false {
                print("[INFO] Retrieved \(result.retrievedProducts.count) StoreKit Products");
                self.subscriptions = result.retrievedProducts
            }
            else if result.invalidProductIDs.isEmpty == false {
                print("[ERROR] Invalid Product Identifiers: \(result.invalidProductIDs)")
            }
            else if result.error != nil {
                print("[ERROR] Unknown Error While Retrieving StoreKit Products")
            }
        }
    }
    
    func purchase(SubscriptionIdentifier: String, completion: @escaping (Bool) -> Void) {
        SwiftyStoreKit.purchaseProduct(SubscriptionIdentifier, atomically: true) { result in
            if case .success(let purchase) = result {
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                SwiftyStoreKit.verifyReceipt(using: self.validator) { result in
                    if case .success(let receipt) = result {
                        let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: SubscriptionIdentifier, inReceipt: receipt)
                        switch purchaseResult {
                        case .purchased(let expiryDate, _):
                            print("Product is valid until \(expiryDate)")
                            completion(true)
                        case .expired(let expiryDate, _):
                            print("Product is expired since \(expiryDate)")
                            completion(false)
                        case .notPurchased:
                            print("This product has never been purchased")
                            completion(false)
                        }
                    }
                    else {
                        print("[ERROR] Reciept Verification Error.")
                        completion(false)
                    }
                }
            }
            else {
                print("[ERROR] Purchase Verification Error.")
                completion(false)
            }
        }
    }
    
    func verify(SubscriptionIdentifier: String, completion: @escaping (Bool) -> Void) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "28c35d969edc4f739e985dbe912a963d")
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: SubscriptionIdentifier, inReceipt: receipt)
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    print("\(SubscriptionIdentifier) is valid until \(expiryDate)\n\(items)\n")
                    completion(true)
                case .expired(let expiryDate, let items):
                    print("\(SubscriptionIdentifier) is expired since \(expiryDate)\n\(items)\n")
                    completion(false)
                case .notPurchased:
                    print("The user has never purchased \(SubscriptionIdentifier)")
                    completion(false)
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
                completion(false)
            }
        }
    }
    
    func verifyGroup(SubscriptionGroup: [String]) {
        let ids = Set(SubscriptionGroup)
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "28c35d969edc4f739e985dbe912a963d")
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: ids, inReceipt: receipt)
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    print("\(ids) are valid until \(expiryDate)\n\(items)\n")
                case .expired(let expiryDate, let items):
                    print("\(ids) are expired since \(expiryDate)\n\(items)\n")
                case .notPurchased:
                    print("The user has never purchased \(ids)")
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
    
    func restore(completion: @escaping (Bool) -> Void) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                completion(false)
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                completion(true)
            }
            else {
                print("Nothing to Restore")
                completion(false)
            }
        }
    }
    
    // ------- UI ------- //
    
    func showAlert(ViewController: UIViewController)
    {
        let alert = UIAlertController(title: "Purchase Premium Account", message: "For $1.99/Month you'll get unlimited skips, the ability to replay songs and absolutely no ads!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Purchase Now", style: .default, handler: { (action) in
            self.purchase(SubscriptionIdentifier: "com.lagbtech.nexup.premium1", completion: { (didSucceed) in
                if didSucceed {
                    alert.dismiss(animated: true, completion: {
                        ViewController.alert(Title: "Success", Description: "Welcome To Premium!")
                    })
                }
                else {
                    alert.dismiss(animated: true, completion: {
                        ViewController.alert(Title: "Error", Description: "Something Went Wrong, Please Try Again.")
                    })
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "Restore Purchase", style: .default, handler: { (action) in
            self.restore(completion: { (didSucceed) in
                if didSucceed {
                    ViewController.alert(Title: "Success", Description: "Welcome To Premium!")
                }
                else {
                    ViewController.alert(Title: "Error", Description: "We're Sorry, We Cannot Find Your Purchase.")
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
    }
}


