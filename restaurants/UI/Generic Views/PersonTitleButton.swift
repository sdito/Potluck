//
//  PersonTitleButton.swift
//  restaurants
//
//  Created by Steven Dito on 10/11/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class PersonTitleView: UIView {
    
    private let imageView = UIImageView()
    private let label = UILabel()
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        setUpImageView()
        setUpLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpImageView() {
        let side: CGFloat = 35.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage.personCircleImage
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        imageView.constrain(.leading, to: self, .leading)
        imageView.constrain(.top, to: self, .top)
        imageView.constrain(.bottom, to: self, .bottom)
        imageView.equalSides(size: side)
        imageView.layer.cornerRadius = side / 2.0
        imageView.layer.borderWidth = 1.0
        imageView.contentMode = .scaleAspectFit
    }
    
    private func setUpLabel() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .mediumBold
        self.addSubview(label)
        label.constrain(.top, to: self, .top)
        label.constrain(.trailing, to: self, .trailing)
        label.constrain(.bottom, to: self, .bottom)
        label.constrain(.leading, to: imageView, .trailing, constant: 5.0)
    }
    
    func update(name: String, color: UIColor, image: UIImage?) {
        label.text = name
        label.textColor = color
        imageView.image = image
        imageView.layer.borderColor = color.cgColor
        imageView.tintColor = color
    }
    
    func startImageSkeleton() {
        self.imageView.appStartSkeleton()
    }
    
    func endImageSkeleton() {
        self.imageView.appEndSkeleton()
    }
    
}
