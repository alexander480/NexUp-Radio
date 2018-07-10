//
//  ScaleSegue.swift
//  
//
//  Created by Alexander Lester on 6/14/18.
//

import UIKit

class FromRightSegue: UIStoryboardSegue {
    override func perform() { self.slide() }
    private func slide() {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        
        dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
        src.view.transform = CGAffineTransform(translationX: src.view.frame.size.width * 2, y: 0)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            src.view.transform = CGAffineTransform(translationX: 0, y: 0)
            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { finished in
            src.present(dst, animated: false, completion: nil)
        })
    }
}

class UnwindFromRightSegue: UIStoryboardSegue {
    override func perform() { self.slide() }
    private func slide() {
        let dst = self.destination
        let src = self.source
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            src.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        }) { (success) in
            src.dismiss(animated: false, completion: nil)
        }
    }
}
