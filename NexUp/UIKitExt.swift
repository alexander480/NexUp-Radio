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

// MARK: UIViewController Extensions

public extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(_ sender : UITapGestureRecognizer) { view.endEditing(true) }
    
    func alert(Title: String, Description: String?) {
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
    func setupBanner(BannerView: UIView, BannerID: String) {
        let banner = BannerView as! GADBannerView
        banner.adUnitID = BannerID
        banner.rootViewController = self
        banner.adSize = kGADAdSizeSmartBannerPortrait
        banner.load(GADRequest())
    }
}

// MARK: UIImageView Extensions

extension UIImageView
{
    public func imageFromServerURL(urlString: String, tableView : UITableView, indexpath : IndexPath) {
        imageURLString = urlString
        
        if let url = URL(string: urlString) {
            self.image = nil
            if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
                self.image = imageFromCache
                return
            }
            
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if error != nil { print(error as Any); return }
                DispatchQueue.main.async(execute: {
                    if let imgaeToCache = UIImage(data: data!) {
                        if imageURLString == urlString { self.image = imgaeToCache }
                        imageCache.setObject(imgaeToCache, forKey: urlString as AnyObject) // calls when scrolling
                        tableView.reloadRows(at: [indexpath], with: .automatic)
                    }
                })
            }).resume()
        }
    }
    
    public func imageFromURL(urlString: String) {
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            if error != nil { print(error!.localizedDescription); return }
            DispatchQueue.main.async(execute: { () -> Void in let image = UIImage(data: data!); self.image = image })
        }).resume()
    }
    
    func blur()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.bounds
        
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurView)
    }
    
    func lightBlur() {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.bounds
        
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurView)
    }
    
    func removeBlur()
    {
        for subview in self.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
    }
}

// MARK: UIImage Extensions

let imageCache = NSCache<AnyObject, AnyObject>()
var imageURLString : String?

extension UIImage {
    
    // colorize image with given tint color
    // this is similar to Photoshop's "Color" layer blend mode
    // this is perfect for non-greyscale source images, and images that have both highlights and shadows that should be preserved
    // white will stay white and black will stay black as the lightness of the image is preserved
    func tint(tintColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            // draw black background - workaround to preserve color of partially transparent pixels
            context.setBlendMode(.normal)
            UIColor.black.setFill()
            context.fill(rect)
            
            // draw original image
            context.setBlendMode(.normal)
            context.draw(self.cgImage!, in: rect)
            
            // tint image (loosing alpha) - the luminosity of the original image is preserved
            context.setBlendMode(.color)
            tintColor.setFill()
            context.fill(rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }
    
    // fills the alpha channel of the source image with the given color
    // any color information except to the alpha channel will be ignored
    func fillAlpha(fillColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            // draw tint color
            context.setBlendMode(.normal)
            fillColor.setFill()
            context.fill(rect)
            //            context.fillCGContextFillRect(context, rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }
    
    private func modifiedImage( draw: (CGContext, CGRect) -> ()) -> UIImage {
        
        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)
        
        // correctly rotate image
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        draw(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}














