//
//  NavigationTitleView.swift
//  restaurants
//
//  Created by Steven Dito on 10/7/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class NavigationTitleView: UIStackView {
    
    // Upper is typically a username, lower is typically the normal navigation name
    init(upperText: String, lowerText: String) {
        super.init(frame: .zero)
        let upperLabel = UILabel()
        let lowerLabel = UILabel()
        upperLabel.translatesAutoresizingMaskIntoConstraints = false
        lowerLabel.translatesAutoresizingMaskIntoConstraints = false
        upperLabel.text = upperText.uppercased()
        lowerLabel.text = lowerText
        upperLabel.textColor = .secondaryLabel
        lowerLabel.textColor = .label
        upperLabel.font = .mediumBold
        lowerLabel.font = .boldSystemFont(ofSize: 17.5)
        
        self.addArrangedSubview(upperLabel)
        self.addArrangedSubview(lowerLabel)
        
        self.axis = .vertical
        self.alignment = .center
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
