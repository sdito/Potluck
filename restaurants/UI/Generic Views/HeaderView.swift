//
//  HeaderView.swift
//  restaurants
//
//  Created by Steven Dito on 8/28/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class HeaderView: UIStackView {
    
    let leftButton = SizeChangeButton(sizeDifference: .medium, restingColor: Colors.secondary, selectedColor: Colors.main)
    let rightButton = SizeChangeButton(sizeDifference: .medium, restingColor: Colors.secondary, selectedColor: Colors.main)
    let headerLabel = UILabel()
    
    init(leftButtonTitle: String = "Cancel", rightButtonTitle: String, title: String) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .horizontal
        self.distribution = .fill
        
        leftButton.setTitle(leftButtonTitle, for: .normal)
        leftButton.titleLabel?.font = .largerBold
        self.addArrangedSubview(leftButton)
        leftButton.titleEdgeInsets.left = 15.0
        leftButton.imageEdgeInsets.left = 15.0
        leftButton.contentHorizontalAlignment = .left
        
        rightButton.setTitle(rightButtonTitle, for: .normal)
        rightButton.titleLabel?.font = .largerBold
        self.addArrangedSubview(rightButton)
        rightButton.titleEdgeInsets.right = 15.0
        rightButton.imageEdgeInsets.right = 15.0
        rightButton.contentHorizontalAlignment = .right
        
        leftButton.widthAnchor.constraint(equalTo: rightButton.widthAnchor).isActive = true
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text = title
        headerLabel.font = .createdTitle
        headerLabel.textAlignment = .center
        headerLabel.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        self.insertArrangedSubview(headerLabel, at: 1)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
