//
//  ProfileCell.swift
//  restaurants
//
//  Created by Steven Dito on 10/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class ProfileCell: UICollectionViewCell {
    
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let multipleImagesView = UIImageView(image: .squaresImage)
    private let placeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUiElements()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpUiElements() {
        setUpView()
        setUpStackView()
        setUpImageView()
        setUpLabel()
    }
    
    private func setUpView() {
        self.contentView.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }
    
    private func setUpStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(stackView)
        stackView.constrainSides(to: self.contentView, distance: 5.0)
        stackView.axis = .vertical
        stackView.spacing = 5.0
        stackView.distribution = .fill
        stackView.alignment = .fill
    }
    
    private func setUpImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.equalSides()
        imageView.backgroundColor = .tertiarySystemBackground
        
        multipleImagesView.translatesAutoresizingMaskIntoConstraints = false
        multipleImagesView.tintColor = .white
        imageView.addSubview(multipleImagesView)
        multipleImagesView.constrain(.top, to: imageView, .top, constant: 5.0)
        multipleImagesView.constrain(.trailing, to: imageView, .trailing, constant: 5.0)
        
        stackView.addArrangedSubview(imageView)
    }
    
    private func setUpLabel() {
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        placeLabel.textColor = .label
        placeLabel.font = .smallBold
        placeLabel.text = "This is placeholder text"
        stackView.addArrangedSubview(placeLabel)
    }
    
}
