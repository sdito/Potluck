//
//  UIButton-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 7/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


extension UIButton {
    
    private static let loaderViewTag = 919
    
    override open var intrinsicContentSize: CGSize {
        let intrinsicContentSize = super.intrinsicContentSize

        let adjustedWidth = intrinsicContentSize.width + titleEdgeInsets.left + titleEdgeInsets.right
        let adjustedHeight = intrinsicContentSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom

        return CGSize(width: adjustedWidth, height: adjustedHeight)
    }
    
    
    func showLoadingOnButton(withLoaderView: Bool) {
        self.isUserInteractionEnabled = false
        
        if withLoaderView {
            self.setTitleColor(.clear, for: .normal)
            
            let loaderView = LoaderView(style: .small)
            loaderView.tag = UIButton.loaderViewTag
            self.addSubview(loaderView)
            loaderView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            loaderView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        } else {
            self.setTitleColor(.systemGray, for: .normal)
        }
        
    }
    
    func endLoadingOnButton(titleColor: UIColor) {
        self.isUserInteractionEnabled = true
        self.setTitleColor(titleColor, for: .normal)
        
        for view in self.subviews {
            if view.tag == UIButton.loaderViewTag {
                view.removeFromSuperview()
            }
        }
    }

}
