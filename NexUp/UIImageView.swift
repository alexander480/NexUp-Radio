//
//  UIImageView.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/23/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import UIKit

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
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
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
