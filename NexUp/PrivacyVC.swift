
//
//  PrivacyVC.swift
//  NexUp
//
//  Created by Alexander Lester on 7/30/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import WebKit
import UIKit

class PrivacyVC: UIViewController, WKUIDelegate {
    var webView: WKWebView!
    var doneButton: UIButton!
    
    override func loadView() {
        super.loadView()
        
        let webViewFrame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height - 60.0)
            self.webView = WKWebView(frame: webViewFrame, configuration: WKWebViewConfiguration())
            self.webView.uiDelegate = self
        
        let doneButtonFrame = CGRect(x: 0.0, y: self.view.frame.size.height - 60.0, width: self.view.frame.size.width, height: 60.0)
            self.doneButton = UIButton(frame: doneButtonFrame)
            self.doneButton.backgroundColor = .red
            self.doneButton.setTitle("Done", for: .normal)
            self.doneButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        
        self.view.addSubview(self.webView)
        self.view.addSubview(self.doneButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: "https://designsbylagb.com/documents/Privacy-1.pdf") {
            self.webView.load(URLRequest(url: url))
        }
    }
    
    @objc private func doneAction(sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }
}
