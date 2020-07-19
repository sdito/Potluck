//
//  RestaurantCell.swift
//  restaurants
//
//  Created by Steven Dito on 7/18/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class RestaurantCell: UITableViewCell {
    
    private var titleLabel: UILabel!
    var restaurantImageView: UIImageView!
    private var stackView: UIStackView!
    private var starRatingView: StarRatingView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUiElements()
        setUpForSkeleton()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpUiElements() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        stackView.constrainSides(to: self, distance: 15.0)
        
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .createdTitle
        titleLabel.numberOfLines = 0
        stackView.addArrangedSubview(titleLabel)
        
        starRatingView = StarRatingView(stars: 0, numReviews: 1, noBackgroundColor: true)
        stackView.addArrangedSubview(starRatingView)
        
        restaurantImageView = UIImageView()
        restaurantImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let dimension = self.contentView.frame.width / 4.0
        restaurantImageView.heightAnchor.constraint(equalToConstant: dimension).isActive = true
        restaurantImageView.widthAnchor.constraint(equalToConstant: dimension).isActive = true
        restaurantImageView.backgroundColor = .secondarySystemBackground
        restaurantImageView.layer.cornerRadius = 5.0
        restaurantImageView.clipsToBounds = true
        stackView.addArrangedSubview(restaurantImageView)
        
    }
    
    func setUp(restaurant: Restaurant) {
        titleLabel.text = restaurant.name
        starRatingView.updateNumberOfStarsAndReviews(stars: restaurant.rating, numReviews: restaurant.reviewCount)
    }
    
    func setUpForHero() {
        self.titleLabel.hero.id = .recipeHomeToDetailTitle
        self.restaurantImageView.hero.id = .recipeHomeToDetailImageView
        self.starRatingView.hero.id = .recipeHomeToDetailStarRatingView
    }
    
    func removeHeroValues() {
        self.titleLabel.hero.id = ""
        self.restaurantImageView.hero.id = ""
        self.starRatingView.hero.id = ""
    }
    
    func setUpForSkeleton() {
        #warning("not working")
        self.titleLabel.text = "This is the example title"
        self.titleLabel.isSkeletonable = true
        self.restaurantImageView.isSkeletonable = true
        self.starRatingView.isSkeletonable = true
    }
    
}
