//
//  StarRatingView.swift
//  restaurants
//
//  Created by Steven Dito on 7/6/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class StarRatingView: UIView {
    
    private var starViews: [UIImageView] = []
    private var numReviewsLabel: UILabel!
    
    init(stars: Double, numReviews: Int, forceWhite: Bool, noBackgroundColor: Bool = false) {
        super.init(frame: .zero)
        setUp(stars: stars, numReviews: numReviews, forceWhite: forceWhite, noBackgroundColor: noBackgroundColor)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateNumberOfStarsAndReviews(stars: Double, numReviews: Int) {
        var numberStarsLeft = stars
        for starView in starViews {
            if numberStarsLeft > 0.99 {
                // add a full star at the end
                starView.image = UIImage(systemName: "star.fill")
                numberStarsLeft -= 1.0
            } else if numberStarsLeft > 0.01 {
                // add a half star at the end
                starView.image = UIImage(systemName: "star.lefthalf.fill")
                numberStarsLeft = 0.0
            } else {
                // add an empty star at the end
                starView.image = UIImage(systemName: "star")
            }
        }
        
        if numReviews > 0 {
            numReviewsLabel.text = "\(numReviews)"
        } else {
            numReviewsLabel.removeFromSuperview()
        }
        
    }
    
    
    private func setUp(stars: Double, numReviews: Int, forceWhite: Bool, noBackgroundColor: Bool = false) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if !noBackgroundColor {
            self.fadedBackground()
        }
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2.0
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 3.0),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3.0),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 3.0),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -3.0)
        ])
        
        var numberStarsLeft = stars
        
        for num in 1...5 {
            let imageView = UIImageView()
            imageView.tag = num
            starViews.append(imageView)
            if numberStarsLeft > 0.99 {
                // add a full star at the end
                imageView.image = UIImage(systemName: "star.fill")
                numberStarsLeft -= 1.0
            } else if numberStarsLeft > 0.01 {
                // add a half star at the end
                imageView.image = UIImage(systemName: "star.lefthalf.fill")
                numberStarsLeft = 0.0
            } else {
                // add an empty star at the end
                imageView.image = UIImage(systemName: "star")
            }
            imageView.tintColor = Colors.main
            stackView.addArrangedSubview(imageView)
        }
        
        if numReviews > 0 {
            numReviewsLabel = UILabel()
            
            numReviewsLabel.textColor = forceWhite ? .white : .label
            
            
            numReviewsLabel.text = "\(numReviews)"
            stackView.addArrangedSubview(numReviewsLabel)
        }
        
        
        self.layer.cornerRadius = 5.0
        
    }
    
    
    
}
