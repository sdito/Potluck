//
//  LogInButton.swift
//  restaurants
//
//  Created by Steven Dito on 8/15/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class LogInButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 5.0
        self.titleEdgeInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
        self.setTitleColor(.label, for: .normal)
        self.backgroundColor = Colors.main
        self.titleLabel?.font = .largerBold
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        self.setGradientBackground(colorOne: Colors.main, colorTwo: Colors.secondary)
    }
}
