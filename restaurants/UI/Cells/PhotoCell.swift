//
//  PhotoCell.swift
//  restaurants
//
//  Created by Steven Dito on 7/12/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUp() {
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        imageView.constrainSides(to: self)
        imageView.backgroundColor = .secondarySystemBackground
        imageView.isSkeletonable = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
}
