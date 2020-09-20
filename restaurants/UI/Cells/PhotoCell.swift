//
//  PhotoCell.swift
//  restaurants
//
//  Created by Steven Dito on 7/12/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Photos

class PhotoCell: UICollectionViewCell {
    
    var creationDate: Date?
    var asset: PHAsset?
    var allowsSelection = false
    var imageView: UIImageView!
    var url: String?
    
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
        imageView.addSubview(selectedImage)
        selectedImage.layer.cornerRadius = selectedImage.frame.height / 2.0
        selectedImage.clipsToBounds = true
        
        selectedImage.constrain(.trailing, to: self, .trailing, constant: 10.0)
        selectedImage.constrain(.bottom, to: self, .bottom, constant: 10.0)
        
        selectedImage.isHidden = true
    }
    
    func updateForShowingSelection(selected: Bool, animated: Bool) {
        selectedImage.appIsHiddenAnimated(isHidden: !selected, animated: animated)
        
    }
    
    
    
}
