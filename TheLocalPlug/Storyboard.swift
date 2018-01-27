//
//  StoryboardExt.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 12/28/17.
//  Copyright © 2017 LAGB Technologies. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class ViewClass: UIView {
    @IBInspectable var cornerRadius: CGFloat = 0 { didSet { layer.cornerRadius = cornerRadius } }
    @IBInspectable var shadowColor: CGColor = UIColor.black.cgColor { didSet { layer.shadowColor = shadowColor } }
    @IBInspectable var shadowOpacity: Float = 1.0 { didSet { layer.shadowOpacity = shadowOpacity } }
    @IBInspectable var shadowOffset: CGSize = CGSize.zero { didSet { layer.shadowOffset = shadowOffset } }
    @IBInspectable var shadowRadius: CGFloat = 10 { didSet { layer.shadowRadius = shadowRadius } }
}


@IBDesignable class TableClass: UITableView {
    @IBInspectable var cornerRadius: CGFloat = 0 { didSet { layer.cornerRadius = cornerRadius } }
    
}

@IBDesignable class ButtonClass: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 0 { didSet { layer.cornerRadius = cornerRadius  } }
    
}

@IBDesignable class TextFieldClass: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 0 { didSet { layer.cornerRadius = cornerRadius  } }
    
}

@IBDesignable class ImageViewClass: UIImageView {
    @IBInspectable var cornerRadius: CGFloat = CGFloat.init(exactly: NSNumber(value: 1))! { didSet { layer.cornerRadius = cornerRadius  } }
    
}
