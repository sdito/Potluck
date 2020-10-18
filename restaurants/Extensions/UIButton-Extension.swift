//
//  UIButton-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 7/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


extension UIButton {
    
    private static let activityIndicatorTag = 919
    
    override open var intrinsicContentSize: CGSize {
        let intrinsicContentSize = super.intrinsicContentSize

        let adjustedWidth = intrinsicContentSize.width + titleEdgeInsets.left + titleEdgeInsets.right
        let adjustedHeight = intrinsicContentSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom

        return CGSize(width: adjustedWidth, height: adjustedHeight)
    }
    
    func showLoadingOnButton() {
        self.isUserInteractionEnabled = false
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.tag = UIButton.activityIndicatorTag
        self.setTitleColor(.clear, for: .normal)
        self.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        activityIndicator.startAnimating()

    }
    
    func endLoadingOnButton(titleColor: UIColor) {
        self.isUserInteractionEnabled = true
        self.setTitleColor(titleColor, for: .normal)
        for view in self.subviews {
            if view.tag == UIButton.activityIndicatorTag {
                view.removeFromSuperview()
            }
        }
    }

}
