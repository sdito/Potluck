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
        self.setTitleColor(.label, for: .normal)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func update(name: String, color: UIColor) {
        self.setTitle(" \(name)", for: .normal)
        let image = UIImage.personCircleImage
        self.setTitleColor(color, for: .normal)
        self.tintColor = color
//        personImageView.backgroundColor = color
//        personImageView.tintColor = color.lighter
        
        self.setImage(image, for: .normal)
    }
    
}
