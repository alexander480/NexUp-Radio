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
    typealias RecieptVerificationHandler = (String) -> ()
    
    var sharedSecret: String
    var subscriptionIdentifiers: Set<String>
    var subscriptions: Set<SKProduct>?
    
    init(SharedSecret: String, SubscriptionIdentifiers: [String])
    {
        self.sharedSecret = SharedSecret
        self.subscriptionIdentifiers = Set(SubscriptionIdentifiers)
        super.init()
        
        SwiftyStoreKit.retrieveProductsInfo(self.subscriptionIdentifiers) { (result) in
            if result.retrievedProducts.isEmpty == false { print("[INFO] Retrieved \(result.retrievedProducts.count) StoreKit Products"); self.subscriptions = result.retrievedProducts }
            else if result.invalidProductIDs.isEmpty == false { print("[ERROR] Invalid Product Identifiers: \(result.invalidProductIDs)") }
            else if result.error != nil { print("[ERROR] Unknown Error While Retrieving StoreKit Products") }
        }
    }
    
    func purchase(SubscriptionIdentifier: String, completion: @escaping (Bool) -> Void) {
        SwiftyStoreKit.purchaseProduct(SubscriptionIdentifier, atomically: true) { result in
            if case .success(let purchase) = result
            {
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "your-shared-secret")
                SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                    
                    if case .success(let receipt) = result {
                        let purchaseResult = SwiftyStoreKit.verifySubscription(
                            ofType: .autoRenewable,
                            productId: SubscriptionIdentifier,
                            inReceipt: receipt)
                        
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
                    else { print("[ERROR] Reciept Verification Error."); completion(false) }
                }
            }
            else { print("[ERROR] Purchase Verification Error."); completion(false) }
        }
    }
    
    func verify(SubsciptionIdentifier: String, completion: @escaping (Bool) -> Void) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: self.sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: SubsciptionIdentifier, inReceipt: receipt)
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    print("\(SubsciptionIdentifier) is valid until \(expiryDate)\n\(items)\n")
                    completion(true)
                case .expired(let expiryDate, let items):
                    print("\(SubsciptionIdentifier) is expired since \(expiryDate)\n\(items)\n")
                    completion(false)
                case .notPurchased:
                    print("The user has never purchased \(SubsciptionIdentifier)")
                    completion(false)
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
                completion(false)
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
}


