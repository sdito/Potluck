//
//  TagButton.swift
//  restaurants
//
//  Created by Steven Dito on 11/1/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class TagButton: SizeChangeButton {
    
    init(title: String?, withImage: Bool) {
        super.init(sizeDifference: .inverse, restingColor: .label, selectedColor: .label)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle(title, for: .normal)
        self.setTitleColor(.label, for: .normal)
        self.titleLabel?.font = .mediumBold
        self.clipsToBounds = true
        self.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = 5.0
        self.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        self.setContentCompressionResistancePriority(.required, for: .vertical)
        
        if withImage {
            self.setImage(UIImage.xImage.withConfiguration(.small), for: .normal)
        }
        
        self.tintColor = .secondaryLabel
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
