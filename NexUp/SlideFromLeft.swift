//
//  Slide From Left.Swift
//  
//
//  Created by Alexander Lester on 6/14/18.
//

import UIKit

class FromLeftSegue: UIStoryboardSegue {
    override func perform() {
        self.slide()
    }
    private func slide() {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { finished in
            src.present(dst, animated: false, completion: nil)
        })
    }
}




