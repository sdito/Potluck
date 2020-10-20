//
//  StarRatingView.swift
//  restaurants
//
//  Created by Steven Dito on 7/6/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class StarRatingView: UIView {
    
    private let imageView = UIImageView()
    private let numReviewsLabel = UILabel()
    
    init(stars: Double, numReviews: Int, forceWhite: Bool, noBackgroundColor: Bool = false) {
        super.init(frame: .zero)
        setUp(stars: stars, numReviews: numReviews, forceWhite: forceWhite, noBackgroundColor: noBackgroundColor)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateNumberOfStarsAndReviews(stars: Double, numReviews: Int) {
        
        imageView.image = getImageFor(stars: stars)
        
        if numReviews > 0 {
            numReviewsLabel.isHidden = false
            numReviewsLabel.text = "\(numReviews)"
        } else {
            numReviewsLabel.isHidden = true
        }
        
    }
    
    
    private func setUp(stars: Double, numReviews: Int, forceWhite: Bool, noBackgroundColor: Bool = false) {
        self.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        numReviewsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.contentMode = .scaleAspectFill
        
        stackView.axis = .horizontal
        stackView.spacing = 4.0
        self.addSubview(stackView)
        stackView.constrainSides(to: self, distance: 3.0)
        stackView.addArrangedSubview(imageView)
        
        if forceWhite {
            numReviewsLabel.textColor = .white
        } else {
            numReviewsLabel.textColor = .label
        }
        numReviewsLabel.font = .mediumBold
        stackView.addArrangedSubview(numReviewsLabel)
        
        self.layer.cornerRadius = 5.0
        if !noBackgroundColor {
            self.fadedBackground()
        }
        
        updateNumberOfStarsAndReviews(stars: stars, numReviews: numReviews)
    }
    
    private func getImageFor(stars: Double) -> UIImage {
        var ending: String {
            if stars < 1.0 {
                return "0.0"
            } else if stars < 1.25 {
                return "1.0"
            } else if stars < 1.75 {
                return "1.5"
            } else if stars < 2.25 {
                return "2.0"
            } else if stars < 2.75 {
                return "2.5"
            } else if stars < 3.25 {
                return "3.0"
            } else if stars < 3.75 {
                return "3.5"
            } else if stars < 4.25 {
                return "4.0"
            } else if stars < 4.75 {
                return "4.5"
            } else {
                return "5.0"
            }
        }
        let image = UIImage(named: "stars-\(ending)")!
        return image
        
    }
    
}
