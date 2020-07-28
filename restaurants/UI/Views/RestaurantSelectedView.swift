//
//  RestaurantSelectedView.swift
//  restaurants
//
//  Created by Steven Dito on 7/27/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class RestaurantSelectedView: UIView {
    
    private var outerStackView: UIStackView!
    private var innerTopStackView: UIStackView!
    private var topRightStackView: UIStackView!
    
    init(restaurant: Restaurant) {
        super.init(frame: .zero)
        setUp(restaurant: restaurant)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUp(restaurant: Restaurant) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .systemPink
        setUpOuterStackView()
        setUpInnerTopStackView()
        setUpImageView(restaurant: restaurant)
        setUpTopRightStackView()
        setUpTopRightContents(restaurant: restaurant)
    }
    
    private func setUpOuterStackView() {
        outerStackView = UIStackView()
        outerStackView.translatesAutoresizingMaskIntoConstraints = false
        outerStackView.axis = .vertical
        outerStackView.spacing = 5.0
        outerStackView.distribution = .fill
        outerStackView.alignment = .fill
        self.addSubview(outerStackView)
        outerStackView.constrainSides(to: self, distance: 10.0)
    }
    
    private func setUpInnerTopStackView() {
        // Image view on left
        // Title, stars, etc in a stack view vertically on the right
        innerTopStackView = UIStackView()
        innerTopStackView.translatesAutoresizingMaskIntoConstraints = false
        innerTopStackView.axis = .horizontal
        innerTopStackView.spacing = 5.0
        innerTopStackView.distribution = .fill
        innerTopStackView.alignment = .fill
        outerStackView.addArrangedSubview(innerTopStackView)
    }
    
    private func setUpImageView(restaurant: Restaurant) {
        // left side of innerTopStackView
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let imageViewWidth = UIScreen.main.bounds.width / 4.0
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.layer.cornerRadius = 4.0
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        imageView.heightAnchor.constraint(equalToConstant: imageViewWidth).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: imageViewWidth).isActive = true
        
        imageView.addImageFromUrl(restaurant.imageURL)
        
        innerTopStackView.addArrangedSubview(imageView)
    }
    
    private func setUpTopRightStackView() {
        topRightStackView = UIStackView()
        topRightStackView.translatesAutoresizingMaskIntoConstraints = false
        topRightStackView.axis = .vertical
        topRightStackView.spacing = 5.0
        topRightStackView.distribution = .fill
        topRightStackView.alignment = .leading
        innerTopStackView.addArrangedSubview(topRightStackView)
    }
    
    private func setUpTopRightContents(restaurant: Restaurant) {
        // Label with title
        // Star view
        // Dollar sign
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = restaurant.name
        title.font = .largerBold
        topRightStackView.addArrangedSubview(title)
        
        let starView = StarRatingView(stars: restaurant.rating, numReviews: restaurant.reviewCount, noBackgroundColor: true)
        topRightStackView.addArrangedSubview(starView)
        
        
    }
    
}
