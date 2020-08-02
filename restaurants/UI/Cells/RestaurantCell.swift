//
//  RestaurantCell.swift
//  restaurants
//
//  Created by Steven Dito on 7/18/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit



protocol RestaurantCellDelegate: class {
    func mapButtonPressed(restaurant: Restaurant)
}



class RestaurantCell: UITableViewCell {
    
    private var restaurant: Restaurant!
    private weak var delegate: RestaurantCellDelegate!
    
    var titleLabel: UILabel!
    var restaurantImageView: UIImageView!
    private var stackView: UIStackView!
    private var starRatingView: StarRatingView!
    private var distanceLabel: UILabel!
    private var innerStackView: UIStackView!
    private var outerStackView: UIStackView!
    
    private var reservationsLabel: UILabel!
    private var deliveryLabel: UILabel!
    private var takeoutLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUiElements()
        setUpForSkeleton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpUiElements() {
        setUpMainStackView()
        setUpTitleLabel()
        setUpStarRatingStack()
        setUpImageView()
        setUpOuterStackView()
        setUpInnerStackView()
        setUpTransactions()
    }
    
    private func setUpMainStackView() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 7.5
        self.addSubview(stackView)
        stackView.constrainSides(to: self, distance: 15.0)
    }
    
    private func setUpTitleLabel() {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .createdTitle
        titleLabel.numberOfLines = 0
        stackView.addArrangedSubview(titleLabel)
    }
    
    private func setUpStarRatingStack() {
        let starRatingStackView = UIStackView()
        starRatingStackView.translatesAutoresizingMaskIntoConstraints = false
        starRatingStackView.spacing = 10.0
        starRatingStackView.alignment = .leading
        starRatingStackView.distribution = .fill
    
        starRatingView = StarRatingView(stars: 0, numReviews: 1, forceWhite: false, noBackgroundColor: true)
        
        starRatingStackView.addArrangedSubview(starRatingView)
        
        let mapButton = UIButton()
        mapButton.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(scale: .large)
        let mapImage = UIImage(systemName: "map", withConfiguration: config)!
        mapButton.setImage(mapImage, for: .normal)
        mapButton.tintColor = Colors.main
        mapButton.addTarget(self, action: #selector(mapButtonSelected), for: .touchUpInside)
        
        starRatingStackView.addArrangedSubview(mapButton)
        
        stackView.addArrangedSubview(starRatingStackView)
    }
    
    private func setUpImageView() {
        restaurantImageView = UIImageView()
        restaurantImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let dimension = self.contentView.frame.width / 3.0
        restaurantImageView.heightAnchor.constraint(equalToConstant: dimension).isActive = true
        restaurantImageView.widthAnchor.constraint(equalToConstant: dimension).isActive = true
        restaurantImageView.backgroundColor = .secondarySystemBackground
        restaurantImageView.layer.cornerRadius = 5.0
        restaurantImageView.clipsToBounds = true
    }
    
    private func setUpTransactions() {
        // Set up transactions labels, in stack view
            deliveryLabel = PaddingLabel(top: 3.0, bottom: 3.0, left: 5.0, right: 5.0)
            takeoutLabel = PaddingLabel(top: 3.0, bottom: 3.0, left: 5.0, right: 5.0)
            reservationsLabel = PaddingLabel(top: 3.0, bottom: 3.0, left: 5.0, right: 5.0)
            
            [deliveryLabel, takeoutLabel, reservationsLabel].forEach { (lab) in
                lab?.translatesAutoresizingMaskIntoConstraints = false
                lab?.textAlignment = .left
                lab?.backgroundColor = .secondarySystemBackground
                lab?.layer.cornerRadius = 5.0
                lab?.clipsToBounds = true
            }
            
            
            deliveryLabel.attributedText = NSAttributedString(string: "Delivery")
            takeoutLabel.attributedText = NSAttributedString(string: "Pickup")
            reservationsLabel.attributedText = NSAttributedString(string: "Reservations")
            
        
            let transactionsStackView = UIStackView(arrangedSubviews: [deliveryLabel, takeoutLabel, reservationsLabel])
            // set them all equal widths to each other
            deliveryLabel.widthAnchor.constraint(equalTo: takeoutLabel.widthAnchor).isActive = true
            takeoutLabel.widthAnchor.constraint(equalTo: reservationsLabel.widthAnchor).isActive = true
            
            transactionsStackView.axis = .vertical
            transactionsStackView.spacing = 7.5
            transactionsStackView.distribution = .fillEqually
            transactionsStackView.alignment = .leading
            
            innerStackView.addArrangedSubview(transactionsStackView)
    }
    
    private func setUpOuterStackView() {
        outerStackView = UIStackView()
        outerStackView.translatesAutoresizingMaskIntoConstraints = false
        outerStackView.axis = .horizontal
        outerStackView.addArrangedSubview(restaurantImageView)
        outerStackView.distribution = .fill
        outerStackView.alignment = .leading
        outerStackView.spacing = 5.0
    }
    
    private func setUpInnerStackView() {
        innerStackView = UIStackView()
        innerStackView.translatesAutoresizingMaskIntoConstraints = false
        innerStackView.axis = .vertical
        innerStackView.alignment = .leading
        innerStackView.distribution = .fill
        innerStackView.spacing = 5.0
        
        distanceLabel = UILabel()
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.textColor = .secondaryLabel
        
        innerStackView.addArrangedSubview(distanceLabel)
        
        outerStackView.addArrangedSubview(innerStackView)
        stackView.addArrangedSubview(outerStackView)
    }
    
    func setUp(restaurant: Restaurant, place: Int, vc: UIViewController) {
        self.restaurant = restaurant
        self.delegate = vc as? RestaurantCellDelegate
        self.tag = place - 1
        titleLabel.text = "\(place). \(restaurant.name)"
        starRatingView.updateNumberOfStarsAndReviews(stars: restaurant.rating, numReviews: restaurant.reviewCount)
        let miles = (Measurement(value: restaurant.distance, unit: UnitLength.meters).converted(to: UnitLength.miles).value * 10).rounded() / 10.0
        distanceLabel.text = "\(miles) miles away"
        deliveryLabel.attributedText = "Delivery".getAffirmativeOrNegativeAttributedString(restaurant.transactions.contains(.delivery), font: UIFont.mediumBold)
        takeoutLabel.attributedText = "Pickup".getAffirmativeOrNegativeAttributedString(restaurant.transactions.contains(.pickup), font: UIFont.mediumBold)
        reservationsLabel.attributedText = "Reservations".getAffirmativeOrNegativeAttributedString(restaurant.transactions.contains(.restaurantReservation), font: UIFont.mediumBold)
    }
    
    func setUpForHero() {
        self.titleLabel.hero.id = .restaurantHomeToDetailTitle
        self.restaurantImageView.hero.id = .restaurantHomeToDetailImageView
        self.starRatingView.hero.id = .restaurantHomeToDetailStarRatingView
    }
    
    func removeHeroValues() {
        self.titleLabel.hero.id = ""
        self.restaurantImageView.hero.id = ""
        self.starRatingView.hero.id = ""
    }
    
    func setUpForSkeleton() {
        #warning("not working as expected")
        
        //self.isSkeletonable = true
        self.titleLabel.text = "This is the example title"
        self.titleLabel.isSkeletonable = true
        self.restaurantImageView.isSkeletonable = true
        self.starRatingView.isSkeletonable = true
        
        
    }
    
    @objc private func mapButtonSelected() {
        delegate.mapButtonPressed(restaurant: restaurant)
    }
    
}



