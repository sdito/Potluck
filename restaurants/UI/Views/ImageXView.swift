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
    var uniqueId: Int = -1
    
    var imageView = UIImageView()
    var cancelButton = UIButton()
    private let starView = UIImageView(image: .starCircleImage)
    
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
        
        starView.translatesAutoresizingMaskIntoConstraints = false
        starView.equalSides()
        self.addSubview(starView)
        starView.constrain(.leading, to: self, .leading, constant: 3.0)
        starView.constrain(.bottom, to: self, .bottom, constant: 3.0)
        starView.isHidden = true
        starView.tintColor = .systemYellow
        starView.layer.cornerRadius = starView.bounds.width / 2.0
        starView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
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
    
    
    func setUp(image: UIImage?, size: CGFloat?, tag: Int, uniqueId: Int) {
        imageView.image = image
        self.equalSides(size: size)
        self.representativeIndex = tag
        self.uniqueId = uniqueId
    }
    
    func updateForStarPosition(firstLocation: Bool) {
        if firstLocation {
            starView.isHidden = false
        } else {
            starView.isHidden = true
        }
    }
    
    func showBorderForMoving() {
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.systemYellow.cgColor
    }

}
