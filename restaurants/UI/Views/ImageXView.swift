//
//  ImageXView.swift
//  restaurants
//
//  Created by Steven Dito on 8/19/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class ImageXView: UIView {
    
    var representativeIndex = -1
    
    var imageView = UIImageView()
    var cancelButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        imageView.constrainSides(to: self)
        cancelButton.tag = representativeIndex
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setImage(.xImage, for: .normal)
        self.addSubview(cancelButton)
        cancelButton.constrain(.trailing, to: self, .trailing, constant: 3.0)
        cancelButton.constrain(.top, to: self, .top, constant: 3.0)
        cancelButton.tintColor = Colors.main
        cancelButton.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.8)
        cancelButton.clipsToBounds = true
        cancelButton.layoutIfNeeded()
        cancelButton.layer.cornerRadius = cancelButton.frame.height / 4.0
        cancelButton.equalSides()
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        self.clipsToBounds = false
        
        cancelButton.alpha = 0.0
        UIView.animate(withDuration: 0.3) {
            self.cancelButton.alpha = 1.0
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    func setUp(image: UIImage?, size: CGFloat?, tag: Int) {
        imageView.image = image
        self.equalSides(size: size)
        self.representativeIndex = tag
    }

}
