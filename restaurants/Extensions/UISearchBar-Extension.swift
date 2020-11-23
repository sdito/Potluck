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
        print("Show loading on search bar is being called")
        guard let leftView = self.searchTextField.leftView else { return }
        let loaderView = LoaderView(style: .small)
        leftView.addSubview(loaderView)
        loaderView.tag = UISearchBar.activityIndicatorTagNumber
        loaderView.backgroundColor = .secondarySystemBackground
        loaderView.constrainSides(to: leftView)
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
    
    var isEmpty: Bool {
        guard let text = self.text else { return true }
        return text.count == 0
    }
    
}
