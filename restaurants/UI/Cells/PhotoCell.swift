//
//  PhotoCell.swift
//  restaurants
//
//  Created by Steven Dito on 7/12/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    
    var allowsSelection = false
    var imageView: UIImageView!
    
    private var selectedImage = UIImageView(image: .checkmarkCircleImage)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUp() {
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        imageView.constrainSides(to: self)
        imageView.backgroundColor = .secondarySystemBackground
        imageView.isSkeletonable = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        selectedImage.translatesAutoresizingMaskIntoConstraints = false
        selectedImage.tintColor = Colors.main
        selectedImage.backgroundColor = .secondarySystemBackground
    }
    
    func updateForShowingSelection(selected: Bool) {
        if selected {
            imageView.addSubview(selectedImage)
            selectedImage.constrain(.trailing, to: imageView, .trailing, constant: 10.0)
            selectedImage.constrain(.bottom, to: imageView, .bottom, constant: 10.0)
            selectedImage.layer.cornerRadius = selectedImage.bounds.height / 2.0
            selectedImage.clipsToBounds = true
        } else {
            selectedImage.removeFromSuperview()
        }
    }
    
}
