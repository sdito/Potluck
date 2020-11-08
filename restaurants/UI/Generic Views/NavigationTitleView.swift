//
//  NavigationTitleView.swift
//  restaurants
//
//  Created by Steven Dito on 10/7/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class NavigationTitleView: UIStackView {
    
    private let upperLabel = UILabel()
    private let lowerLabel = UILabel()
    
    // Upper is typically a username, lower is typically the normal navigation name
    init(upperText: String, lowerText: String) {
        super.init(frame: .zero)
        
        upperLabel.translatesAutoresizingMaskIntoConstraints = false
        upperLabel.text = upperText.uppercased()
        upperLabel.textColor = .secondaryLabel
        upperLabel.font = .mediumBold
        self.addArrangedSubview(upperLabel)
        
        lowerLabel.translatesAutoresizingMaskIntoConstraints = false
        lowerLabel.text = lowerText
        lowerLabel.textColor = .label
        lowerLabel.font = .boldSystemFont(ofSize: 17.5)
        self.addArrangedSubview(lowerLabel)
        
        self.axis = .vertical
        self.alignment = .center
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
