//
//  UIViewController.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/22/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import GoogleMobileAds
import UIKit

public extension UIViewController
{
    func hideKeyboardWhenTappedAround()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(_ sender : UITapGestureRecognizer) { view.endEditing(true) }
    
    func alert(Title: String, Description: String?)
    {
        if let description = Description {
            let alert = UIAlertController(title: Title, message: description, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default) { action in alert.dismiss(animated: true, completion: nil) })
            
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: Title, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default) { action in alert.dismiss(animated: true, completion: nil) })
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
}

extension UIViewController: GADBannerViewDelegate {
    func setupBanner(BannerView: UIView) {
        let banner = BannerView as! GADBannerView
        banner.adUnitID = bannerID
        banner.rootViewController = self
        banner.adSize = kGADAdSizeSmartBannerPortrait
        banner.load(GADRequest())
    }
}








