//
//  ProfileCell.swift
//  restaurants
//
//  Created by Steven Dito on 10/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class ProfileCell: UICollectionViewCell {
    
    static let dateLabelFont = UIFont.smallBold
    static let placeLabelFont = UIFont.mediumBold
    static let stackViewSpacing: CGFloat = 10.0
    static let stackViewPadding: CGFloat = 7.5
    static let nameNumberOfLines = 2
    
    var visit: Visit?
    let imageView = UIImageView()
    private let stackView = UIStackView()
    private let ratingStackView = UIStackView()
    private let multipleImagesView = UIImageView(image: .squaresImage)
    private let placeLabel = UILabel()
    private let ratingLabel = UILabel()
    private let dateLabel = UILabel()
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
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
        setUpDateLabel()
        setUpImageView()
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
        stackView.spacing = ProfileCell.stackViewSpacing
        stackView.distribution = .fill
        stackView.alignment = .fill
    }
    
    private func setUpDateLabel() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.numberOfLines = 1
        dateLabel.font = ProfileCell.dateLabelFont
        dateLabel.textColor = .secondaryLabel
        dateLabel.textAlignment = .left
        stackView.addArrangedSubview(dateLabel)
    }
    
    private func setUpImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        heightConstraint = imageView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint?.isActive = true
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
    
    private func setUpNameLabel() {
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        placeLabel.textColor = .label
        placeLabel.font = ProfileCell.placeLabelFont
        placeLabel.numberOfLines = ProfileCell.nameNumberOfLines
        stackView.addArrangedSubview(placeLabel)
    }
    
    private func setUpRatingLabel() {
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.numberOfLines = 1
        ratingLabel.setContentHuggingPriority(.required, for: .horizontal)
        stackView.addArrangedSubview(ratingLabel)
    }
    
    func setUp(with visit: Visit?, width: CGFloat) {
        self.visit = visit
        widthConstraint?.constant = width
        widthConstraint?.isActive = true
        
        let imageHeight = ProfileCell.getVisitImageHeight(visit: visit, width: width)
        heightConstraint?.constant = imageHeight

        guard let visit = visit else {
            hideCell()
            return
        }
        showCell()
        
        placeLabel.text = visit.restaurantName
        if let text = visit.ratingString {
            ratingLabel.isHidden = false
            ratingLabel.attributedText = text
        } else {
            ratingLabel.isHidden = true
        }
        
        dateLabel.text = visit.userDateVisited
        
        if let listPhotos = visit.listPhotos, listPhotos.count > 1 {
            multipleImagesView.isHidden = false
        } else {
            multipleImagesView.isHidden = true
        }
    }
    
    private static func getVisitImageHeight(visit: Visit?, width: CGFloat) -> CGFloat {
        #warning("need to have maximum for the thing")
        if let imageHeight = visit?.mainImageHeight, let imageWidth = visit?.mainImageWidth, visit?.mainImage != nil {
            let ratio = CGFloat(imageHeight) / CGFloat(imageWidth)
            return width * ratio
        } else {
            return 0.0
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
    
    static func calculateHeight(with visit: Visit, width: CGFloat) -> CGFloat {
        let padding = ProfileCell.stackViewPadding * 2
        let dateSize = visit.userDateVisited.heightOfText(font: ProfileCell.dateLabelFont, width: nil)
        let imageSize = ProfileCell.getVisitImageHeight(visit: visit, width: width)
        let nameSize = visit.restaurantName.heightOfText(font: ProfileCell.placeLabelFont, width: width - padding, limitNumberOfLines: ProfileCell.nameNumberOfLines)
        let numberOfStackViewSubviews = visit.rating == nil ? 3 : 4
        let stackViewPadding = CGFloat(numberOfStackViewSubviews) * ProfileCell.stackViewSpacing
        
        var ratingSize: CGFloat {
            if let rating = visit.ratingString {
                return rating.heightOfString(width: nil)
            } else {
                return 0.0
            }
        }
        
        return dateSize + imageSize + nameSize + padding + stackViewPadding + ratingSize
    }
}
