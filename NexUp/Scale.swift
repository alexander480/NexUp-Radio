//
//  ScaleSegue.swift
//  
//
//  Created by Alexander Lester on 6/14/18.
//

import UIKit

class ScaleSegue: UIStoryboardSegue {
    override func perform() { self.scale() }
    private func scale() {
        let destination = self.destination
        let source = self.source
        
        let container = source.view.superview
        let centerOrigin = source.view.center
        
        destination.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        destination.view.center = centerOrigin
        
        container?.addSubview(destination.view)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            destination.view.transform = CGAffineTransform.identity
        }) { (success) in
            source.present(destination, animated: false, completion: nil)
        }
    }
}

class UnwindScaleSegue: UIStoryboardSegue {
    override func perform() {
        self.unwindScale()
    }
    
    private func unwindScale() {
        let destination = self.destination
        let source = self.source
        
        source.view.superview?.insertSubview(destination.view, at: 0)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            source.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        }) { (success) in
            source.dismiss(animated: false, completion: nil)
        }
    }
}
