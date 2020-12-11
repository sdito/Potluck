//
//  ProfileCell.swift
//  restaurants
//
//  Created by Steven Dito on 10/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class ProfileCell: UICollectionViewCell {

    var visit: Visit?
    
    let imageView = UIImageView()
    private let stackView = UIStackView()
    private let labelStackView = UIStackView()
    private let multipleImagesView = UIImageView(image: .squaresImage)
    private let placeLabel = UILabel()
    private let ratingLabel = UILabel()
    private var widthConstraint: NSLayoutConstraint?
    private let base = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setUpUiElements()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpUiElements() {
        setUpView()
        setUpStackView()
        setUpImageView()
        setUpLabelStackView()
        setUpNameLabel()
        setUpRatingLabel()
    }
    
    private func setUpView() {
        self.contentView.backgroundColor = .secondarySystemBackground
        base.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(base)
        base.constrainSides(to: contentView, with: UILayoutPriority(999.0))
        widthConstraint = base.widthAnchor.constraint(equalToConstant: 100.0)
    }
    
    private func setUpStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.base.addSubview(stackView)
        stackView.constrainSides(to: self.base, distance: 7.5)
        stackView.axis = .vertical
        stackView.spacing = 10.0
        stackView.distribution = .fill
        stackView.alignment = .fill
    }
    
    private func setUpImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.equalSides()
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        multipleImagesView.translatesAutoresizingMaskIntoConstraints = false
        multipleImagesView.tintColor = .white
        imageView.addSubview(multipleImagesView)
        multipleImagesView.constrain(.top, to: imageView, .top, constant: 5.0)
        multipleImagesView.constrain(.trailing, to: imageView, .trailing, constant: 5.0)
        
        stackView.addArrangedSubview(imageView)
    }
    
    private func setUpLabelStackView() {
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(labelStackView)
        labelStackView.axis = .vertical
        labelStackView.distribution = .fill
    }
    
    private func setUpNameLabel() {
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        placeLabel.textColor = .label
        placeLabel.font = .mediumBold
        placeLabel.numberOfLines = 1
        labelStackView.addArrangedSubview(placeLabel)
    }
    
    private func setUpRatingLabel() {
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.numberOfLines = 1
        labelStackView.addArrangedSubview(ratingLabel)
    }
    
    func setUp(with visit: Visit?, width: CGFloat) {
        self.visit = visit
        widthConstraint?.constant = width
        widthConstraint?.isActive = true
        guard let visit = visit else {
            hideCell()
            return
        }
        showCell()
        
        placeLabel.text = visit.restaurantName
        
        ratingLabel.attributedText = visit.ratingString ?? visit.getDummyRatingString()
        
        if let listPhotos = visit.listPhotos, listPhotos.count > 1 {
            multipleImagesView.isHidden = false
        } else {
            multipleImagesView.isHidden = true
        }
    }
    
    
    
    private func hideCell() {
        self.isUserInteractionEnabled = false
        self.alpha = 0.0
        self.contentView.alpha = 0.0
    }
    
    private func showCell() {
        self.isUserInteractionEnabled = true
        self.alpha = 1.0
        self.contentView.alpha = 1.0
    }
    
}
