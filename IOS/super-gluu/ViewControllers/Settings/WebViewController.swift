//
//  WebViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 12/19/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

import UIKit
import WebKit
import SwiftMessages

enum WebDisplay: String {
    case privacy = "Privacy Policy"
    case tos = "Terms of Service"
    
    var urlString: String {
        switch self {
        case .privacy:
            return "https://docs.google.com/document/d/1E1xWq28_f-tam7PihkTZXhlqaXVGZxJbVt4cfx15kB4/edit#heading=h.ifitnnlwr25"
            
        case .tos:
            return "https://gluu.org/docs/supergluu/user-guide/"
        }
    }
}

class WebViewController: UIViewController {
    
    let webView = WKWebView()
    
    var display = WebDisplay.privacy
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDisplay()
        
        title = display.rawValue
        
        webView.load(URLRequest(url: URL(string: display.urlString)!))
        
    }
    
    // MARK: - View Setup
    
    func setupDisplay() {
    
        view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
}
