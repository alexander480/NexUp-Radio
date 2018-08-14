//
//  TermsVC.swift
//  NexUp
//
//  Created by Alexander Lester on 7/30/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import WebKit
import UIKit

class TermsVC: UIViewController, WKUIDelegate {
    var webView: WKWebView!
    
    override func loadView() {
        super.loadView()
        let webViewFrame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.webView = WKWebView(frame: webViewFrame, configuration: WKWebViewConfiguration())
        self.webView.uiDelegate = self
        self.view.addSubview(self.webView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: "https://designsbylagb.com/nexup-terms.html") {
            self.webView.load(URLRequest(url: url))
        }
    }
}
