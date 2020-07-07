//
//  ReviewView.swift
//  restaurants
//
//  Created by Steven Dito on 7/7/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class ReviewView: UIView {

    init(review: Review) {
        super.init(frame: .zero)
        setUp(review: review)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUp(review: Review) {
        
        self.backgroundColor = .secondarySystemBackground
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

        stackView.addArrangedSubview(StarRatingView(stars: Double(review.rating), numReviews: 0))
        
        
        if let imageURL = review.imageURL {
            Network.shared.getImage(url: imageURL) { (img) in
                profileImageView.image = img
            }
        }
        
    }

}
