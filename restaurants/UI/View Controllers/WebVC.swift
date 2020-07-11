//
//  WebVC.swift
//  restaurants
//
//  Created by Steven Dito on 7/10/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import WebKit

class WebVC: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    
    init(url: String) {
        super.init(nibName: nil, bundle: nil)
        setUp(url: url)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setUp(url: String) {
        let myURL = URL(string: url)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
}
