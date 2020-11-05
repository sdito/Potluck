//
//  TagButton.swift
//  restaurants
//
//  Created by Steven Dito on 11/1/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class TagButton: SizeChangeButton {
    
    init(title: String?, withImage: Bool, normal: Bool) {
        super.init(sizeDifference: .inverse, restingColor: .systemBackground, selectedColor: .systemBackground)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = .mediumBold
        self.clipsToBounds = true
        self.layer.cornerRadius = 5.0
        self.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        self.setContentCompressionResistancePriority(.required, for: .vertical)
        
        if withImage {
            self.setImage(UIImage.xImage.withConfiguration(.small), for: .normal)
        }
        
        if normal {
            self.setTitleColor(.systemBackground, for: .normal)
            self.backgroundColor = Colors.main
        } else {
            self.setTitleColor(Colors.main, for: .normal)
            self.backgroundColor = .secondarySystemBackground
        }
        
        self.tintColor = .secondarySystemBackground
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
