//
//  ReviewView.swift
//  restaurants
//
//  Created by Steven Dito on 7/7/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import SkeletonView

class ReviewView: UIView {

    init(review: Review) {
        super.init(frame: .zero)
        setUp(review: review)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUp(review: Review) {
        self.backgroundColor = .systemBackground
        self.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 5.0
        self.addSubview(stackView)
        stackView.constrainSides(to: self, distance: 8.0)

        // profile image left and label with name right
        let nameStackView = UIStackView()
        nameStackView.translatesAutoresizingMaskIntoConstraints = false
        nameStackView.spacing = 7.5
        let profileImageView = UIImageView()
        let userName = UILabel()
        userName.font = .secondaryTitle
        stackView.addArrangedSubview(nameStackView)

        nameStackView.addArrangedSubview(profileImageView)
        nameStackView.addArrangedSubview(userName)
        
        let profileImageViewWidth = UIScreen.main.bounds.width / 8.0
        profileImageView.backgroundColor = .tertiarySystemBackground
        profileImageView.layer.cornerRadius = profileImageViewWidth / 2.0
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        NSLayoutConstraint.activate([
            profileImageView.heightAnchor.constraint(equalToConstant: profileImageViewWidth),
            profileImageView.widthAnchor.constraint(equalToConstant: profileImageViewWidth)
        ])
        
        userName.text = review.reviewerName
        
        let starsStackView = UIStackView()
        starsStackView.axis = .horizontal
        starsStackView.spacing = 4.0
        starsStackView.addArrangedSubview(StarRatingView(stars: Double(review.rating), numReviews: 0, forceWhite: false, noBackgroundColor: true))
        
        if let date = review.timeCreated {
            let timeAgoLabel = UILabel()
            timeAgoLabel.text = date.getDisplayTime()
            timeAgoLabel.textColor = .tertiaryLabel
            timeAgoLabel.font = .smallerThanNormal
            starsStackView.addArrangedSubview(timeAgoLabel)
        }
        
        stackView.addArrangedSubview(starsStackView)
            
        let textLabel = UILabel()
        textLabel.text = review.text
        textLabel.textColor = .secondaryLabel
        textLabel.numberOfLines = 0
        stackView.addArrangedSubview(textLabel)
        
        
        if let imageUrl = review.imageURL {
            Network.shared.getImage(url: imageUrl) { [weak self] (imageFound) in
                if let imageFound = imageFound {
                    let bounds = profileImageView.bounds.size
                    DispatchQueue.global(qos: .background).async {
                        let resized = imageFound.resizeImageToSizeButKeepAspectRatio(targetSize: bounds)
                        DispatchQueue.main.async {
                            profileImageView.image = resized
                        }
                    }
                } else {
                    self?.setUpWithPlaceholder(imageView: profileImageView)
                }
            }
        } else {
            self.setUpWithPlaceholder(imageView: profileImageView)
        }
    }
    
    func setUpWithPlaceholder(imageView: UIImageView) {
        imageView.image = UIImage(systemName: "person.crop.circle")
    }

}
