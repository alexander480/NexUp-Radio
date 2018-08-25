//
//  Array.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/22/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

public extension Array { func random() -> Array { var buf = self; var last = buf.count - 1; while(last > 0) { let rand = Int(arc4random_uniform(UInt32(last))); buf.swapAt(last, rand); last -= 1 }; return buf } }
public extension String { func toURL() -> URL? { if let url = URL(string: self) { return url } else { return nil } } }
public extension AVQueuePlayer { var isPlaying: Bool { return rate != 0 && error == nil } }

public extension UIViewController {
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) { view.endEditing(true) }
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
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

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func imageFrom(urlString: String) {
        if let url = URL(string: urlString) {
            self.image = nil
            if let cachedImage = imageCache.object(forKey: urlString as NSString) { self.image = cachedImage; return }
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
                if let err = error?.localizedDescription { print(err); return }
                DispatchQueue.main.async(execute: { () -> Void in if let image = UIImage(data: data!) { imageCache.setObject(image, forKey: urlString as NSString); self.image = image } })
            }).resume()
        }
    }
    
    func blur() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurView)
    }
}
