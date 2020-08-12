//
//  WebVC.swift
//  restaurants
//
//  Created by Steven Dito on 7/10/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import WebKit


#warning("UI on detail screen gets messed up when the navigation controller is peeled back on this vc")

class WebVC: UIViewController {
    
    private var webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    private var backButton = UIButton()
    private var forwardButton = UIButton()
    private var containerView = UIView()
    private var lastContentOffset: CGFloat = 0.0
    private var containerViewIsShown = true
    
    init(url: String) {
        super.init(nibName: nil, bundle: nil)
        setUp(url: url)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarColor(color: Colors.navigationBarColor)
    }
    
    private func setUp(url: String) {
        self.title = url
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        view = webView

        setBottomTabForWebView()
        setUpButtonActionsAndAppearance()
        let myURL = URL(string: url)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
    }

    
    private func setBottomTabForWebView() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "arrowtriangle.left.fill"), for: .normal)
        backButton.tintColor = Colors.main
        
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        forwardButton.setImage(UIImage(systemName: "arrowtriangle.right.fill"), for: .normal)
        forwardButton.tintColor = Colors.main
        
        stackView.addArrangedSubview(backButton)
        stackView.addArrangedSubview(forwardButton)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemBackground
        containerView.addSubview(stackView)
        stackView.constrainSides(to: containerView)
        self.view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    private func setUpButtonActionsAndAppearance() {
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(goForward), for: .touchUpInside)
        handleButtonTintsAndAbilityToPress()
    }
    
    @objc private func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc private func goForward() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    private func handleButtonTintsAndAbilityToPress() {
        if webView.canGoBack {
            backButton.isUserInteractionEnabled = true
            backButton.tintColor = Colors.main
        } else {
            backButton.isUserInteractionEnabled = false
            backButton.tintColor = .systemGray
        }
        
        if webView.canGoForward {
            forwardButton.isUserInteractionEnabled = true
            forwardButton.tintColor = Colors.main
        } else {
            forwardButton.isUserInteractionEnabled = false
            forwardButton.tintColor = .systemGray
        }
        
        
    }
    
}


// MARK: WebDelegate
extension WebVC: WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        handleButtonTintsAndAbilityToPress()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        if contentOffset < 150.0 {
            if !containerViewIsShown {
                containerView.showAgainAlignAtBottom()
                containerViewIsShown = true
            }
        } else if contentOffset > lastContentOffset {
            if containerViewIsShown {
                containerView.hideFromScreenSwipe(removeAtEnd: false)
                containerViewIsShown = false
            }
        } else {
            if !containerViewIsShown {
                containerView.showAgainAlignAtBottom()
                containerViewIsShown = true
            }
        }
        lastContentOffset = contentOffset
    }
    
}



