//
//  ProductHandler.swift
//  NexUp
//
//  Created by Alexander Lester on 2/9/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import StoreKit

class ProductHandler: NSObject
{
    var sharedSecret: String
    var productIdentifiers: Set<String>
    var products: Set<SKProduct>?
    
    init(SharedSecret: String, ProductIdentifiers: [String])
    {
        self.sharedSecret = SharedSecret
        self.productIdentifiers = Set(ProductIdentifiers)
        super.init()
        
        SwiftyStoreKit.retrieveProductsInfo(self.productIdentifiers) { (result) in
            if result.retrievedProducts.isEmpty == false { print("[INFO] Retrieved \(result.retrievedProducts.count) StoreKit Products"); self.products = result.retrievedProducts }
            else if result.invalidProductIDs.isEmpty == false { print("[ERROR] Invalid Product Identifiers: \(result.invalidProductIDs)") }
            else if result.error != nil { print("[ERROR] Unknown Error While Retrieving StoreKit Products") }
        }
    }
    
    
    //                       Purchase                         //
    //           Call Fetch Reciept Within Closure            //
    // ------------------------------------------------------ //
    
    func purchase(ProductIdentifier: String, completion: @escaping (Bool) -> Void) {
        SwiftyStoreKit.purchaseProduct(ProductIdentifier, quantity: 1, atomically: true) { result in
            switch result {
            case .success( _):
                print("[INFO] Purchase Successful.")
                completion(true)
            case .error(let error):
                switch error.code {
                case .unknown: print("[ERROR] Unknown error."); completion(false)
                case .clientInvalid: print("[ERROR] Not allowed to make the payment"); completion(false)
                case .paymentCancelled: break;
                case .paymentInvalid: print("[ERROR] The purchase identifier was invalid"); completion(false)
                case .paymentNotAllowed: print("[ERROR] The device is not allowed to make the payment"); completion(false)
                case .storeProductNotAvailable: print("[ERROR] The product is not available in the current storefront"); completion(false)
                case .cloudServicePermissionDenied: print("[ERROR] Access to cloud service information is not allowed"); completion(false)
                case .cloudServiceNetworkConnectionFailed: print("[ERROR] Could not connect to the network"); completion(false)
                case .cloudServiceRevoked: print("[ERROR] User has revoked permission to use this cloud service"); completion(false)
                }
            }
        }
    }
    
    
    //                     Fetch Reciept                      //
    //         Call Reciept Validation Within Closure         //
    // ------------------------------------------------------ //
    
    func fetchReciept(closure: @escaping (String) -> Void) {
        SwiftyStoreKit.fetchReceipt(forceRefresh: true) { result in
            switch result {
            case .success(let receiptData):
                let encryptedReceipt = receiptData.base64EncodedString(options: [])
                print("Fetch receipt success:\n\(encryptedReceipt)")
                closure(encryptedReceipt)
            case .error(let error):
                print("Fetch receipt failed: \(error)")
            }
        }
    }
    
    func recieptValidationFor(EncryptedReciept: String, completion: @escaping (Bool) -> Void) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "your-shared-secret")
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { result in
            switch result {
            case .success(let receipt):
                print("[INFO] Verify receipt success: \(receipt)")
                completion(true)
            case .error(let error):
                print("Verify receipt failed: \(error)")
                completion(false)
            }
        }
    }
    
    
    //                Restore Purchases                //
    // ----------------------------------------------- //
    
    func restore(completion: @escaping (Bool) -> Void) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("[ERROR] Restore Failed.")
                completion(false)
            }
            else if results.restoredPurchases.count > 0 {
                print("[INFO] Restore Successful.")
                completion(true)
            }
            else {
                print("[ERROR] Nothing To Restore.")
                completion(false)
            }
        }
    }
}

