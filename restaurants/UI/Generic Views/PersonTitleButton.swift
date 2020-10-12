//
//  PersonTitleButton.swift
//  restaurants
//
//  Created by Steven Dito on 10/11/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class PersonTitleButton: UIButton {
    
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel?.font = .mediumBold
        self.contentHorizontalAlignment = .left
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func update(name: String, color: UIColor) {
        self.setTitle(" \(name)", for: .normal)
        let image = UIImage.personCircleImage.withConfiguration(UIImage.SymbolConfiguration(scale: .large))
        self.setTitleColor(color, for: .normal)
        self.tintColor = color
        self.setImage(image, for: .normal)
    }
    
}
