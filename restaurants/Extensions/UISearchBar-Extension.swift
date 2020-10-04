//
//  UISearchBar-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 10/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

extension UISearchBar {
    
    private static let activityIndicatorTagNumber = 134
    
    func showLoadingOnSearchBar() {
        guard let leftView = self.searchTextField.leftView else { return }
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        leftView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.tag = UISearchBar.activityIndicatorTagNumber
        activityIndicator.backgroundColor = .secondarySystemBackground
        activityIndicator.constrainSides(to: leftView)
        activityIndicator.startAnimating()
    }
    
    func endLoadingOnSearchBar() {
        DispatchQueue.main.async {
            guard let leftView = self.searchTextField.leftView else { return }
            for subView in leftView.subviews {
                if subView.tag == UISearchBar.activityIndicatorTagNumber {
                    subView.removeFromSuperview()
                }
            }
        }
    }
    
}
