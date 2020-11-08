//
//  PersonTitleButton.swift
//  restaurants
//
//  Created by Steven Dito on 10/11/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class PersonTitleButton: UIButton {
    
    
    // use a test image
    private let imageSideSize: CGFloat = 30.0
    
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
        let image = UIImage(named: "test-image")?.resizeImageToSizeButKeepAspectRatio(targetSize: CGSize(width: imageSideSize, height: imageSideSize))
        self.imageView?.layer.cornerRadius = imageSideSize / 2.0
        self.imageView?.clipsToBounds = true
        self.imageView?.layer.borderWidth = 1.0
        self.imageView?.layer.borderColor = color.cgColor
        self.setTitleColor(color, for: .normal)
        self.tintColor = color
        self.setImage(image, for: .normal)
    }
    
}
