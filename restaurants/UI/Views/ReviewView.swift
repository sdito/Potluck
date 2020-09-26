//
//  ReviewView.swift
//  restaurants
//
//  Created by Steven Dito on 7/7/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import SkeletonView
import SafariServices

class ReviewView: UIView {
    
    private let stackView = UIStackView()
    private let profileImageView = UIImageView()
    private let textLabel = UILabel()
    private var review: Review?

    init(review: Review) {
        super.init(frame: .zero)
        self.review = review
        self.backgroundColor = .systemBackground
        self.translatesAutoresizingMaskIntoConstraints = false
        setUpStackView()
        setUpNameAndProfile(review: review)
        setUpStars(review: review)
        setUpText(review: review)
        setUpImage(review: review)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    private func setUpStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 5.0
        self.addSubview(stackView)
        stackView.constrainSides(to: self, distance: 8.0)
    }
    
    private func setUpNameAndProfile(review: Review) {
        let nameStackView = UIStackView()
        nameStackView.translatesAutoresizingMaskIntoConstraints = false
        nameStackView.spacing = 7.5
        
        let userName = UILabel()
        userName.font = .secondaryTitle
        userName.text = review.reviewerName
        stackView.addArrangedSubview(nameStackView)

        nameStackView.addArrangedSubview(profileImageView)
        nameStackView.addArrangedSubview(userName)
        
        let profileImageViewWidth = UIScreen.main.bounds.width / 8.0
        profileImageView.backgroundColor = .tertiarySystemBackground
        profileImageView.layer.cornerRadius = profileImageViewWidth / 2.0
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        profileImageView.equalSides(size: profileImageViewWidth)
    }
    
    private func setUpStars(review: Review) {
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
    }
    
    private func setUpText(review: Review) {
        
        textLabel.numberOfLines = 0
        
        let mutableAttributedString = NSMutableAttributedString()
        let body = NSAttributedString(string: review.text, attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
        mutableAttributedString.append(body)
        
        let more = NSAttributedString(string: "MORE", attributes: [NSAttributedString.Key.foregroundColor: UIColor.label, NSAttributedString.Key.font: UIFont.mediumBold])
        mutableAttributedString.append(more)
        
        textLabel.attributedText = mutableAttributedString
        stackView.addArrangedSubview(textLabel)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(moreOnReviewPressed))
        textLabel.isUserInteractionEnabled = true
        textLabel.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setUpImage(review: Review) {
        if let imageUrl = review.imageURL {
            Network.shared.getImage(url: imageUrl) { [weak self] (imageFound) in
                guard let self = self else { return }
                if let imageFound = imageFound {
                    let bounds = self.profileImageView.bounds.size
                    DispatchQueue.global(qos: .background).async {
                        let resized = imageFound.resizeImageToSizeButKeepAspectRatio(targetSize: bounds)
                        DispatchQueue.main.async {
                            self.profileImageView.image = resized
                        }
                    }
                } else {
                    self.setUpWithPlaceholder(imageView: self.profileImageView)
                }
            }
        } else {
            self.setUpWithPlaceholder(imageView: self.profileImageView)
        }
    }
    
    @objc private func moreOnReviewPressed() {
        if let url = review?.url {
            self.findViewController()?.openLink(url: url)
        }
    }
    
    func setUpWithPlaceholder(imageView: UIImageView) {
        imageView.image = UIImage(systemName: "person.crop.circle")
    }

}

