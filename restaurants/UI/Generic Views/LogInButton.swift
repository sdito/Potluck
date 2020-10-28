//
//  LogInButton.swift
//  restaurants
//
//  Created by Steven Dito on 8/15/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class LogInButton: SizeChangeButton {
    
    static let titleColor = UIColor.systemBackground
    static let backgroundColor = Colors.main
    
    init() {
        super.init(sizeDifference: .inverse, restingColor: LogInButton.titleColor, selectedColor: LogInButton.titleColor)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 5.0
        self.titleEdgeInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
        self.setTitleColor(LogInButton.titleColor, for: .normal)
        self.backgroundColor = LogInButton.backgroundColor
        self.titleLabel?.font = .largerBold
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
