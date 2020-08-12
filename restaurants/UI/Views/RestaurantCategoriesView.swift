//
//  RestaurantCategoriesView.swift
//  restaurants
//
//  Created by Steven Dito on 7/9/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class RestaurantCategoriesView: UIView {
    
    private var priceLabel = UILabel()
    private var pickupLabel = UILabel()
    private var deliveryLabel = UILabel()
    private var reservationsLabel = UILabel()
    
    private lazy var allLabels = [priceLabel, pickupLabel, deliveryLabel, reservationsLabel]
    
    init(restaurant: Restaurant) {
        super.init(frame: .zero)
        setUp(restaurant: restaurant)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUp(restaurant: Restaurant) {
        print("Being set up")
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .systemBackground
        setUpLabels(restaurant: restaurant)
        setUpStackViews()
    }
    
    private func setUpLabels(restaurant: Restaurant) {
        allLabels.forEach { (label) in
            label.font = .mediumBold
            label.textAlignment = .left
        }
        
        priceLabel.attributedText = (restaurant.price ?? "$$").addImageAtBeginning(image: UIImage(systemName: "dollarsign.circle")!.withTintColor(.systemYellow))
        pickupLabel.attributedText = restaurant.transactions.contains(.pickup) ? "Pickup".getAffirmativeOrNegativeAttributedString(true) : "Pickup".getAffirmativeOrNegativeAttributedString(false)
        deliveryLabel.attributedText = restaurant.transactions.contains(.delivery) ? "Delivery".getAffirmativeOrNegativeAttributedString(true) : "Delivery".getAffirmativeOrNegativeAttributedString(false)
        reservationsLabel.attributedText
            = restaurant.transactions.contains(.restaurantReservation) ? "Reservations".getAffirmativeOrNegativeAttributedString(true) : "Reservations".getAffirmativeOrNegativeAttributedString(false)
        
    }
    
    private func setUpStackViews() {
        // Don't need to keep a reference to the stackViews, just need to keep a reference to the labels inside of them
        // Will be 4 labels
        let outerStackView = UIStackView()
        outerStackView.translatesAutoresizingMaskIntoConstraints = false
        outerStackView.axis = .vertical
        outerStackView.spacing = 25.0
        self.addSubview(outerStackView)
        
        //outerStackView.constrainSidesUnique(to: self, top: 20, leading: 40, bottom: 20, trailing: 40)
        NSLayoutConstraint.activate([
            outerStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 30.0),
            outerStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30.0),
            outerStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        /*
         use price, and all the potential categories
         */
        
        var labels = [pickupLabel, deliveryLabel, reservationsLabel, priceLabel]
        
        for _ in 1...2 {
            // 1 for each stackView needed
            let innerStackView = UIStackView()
            innerStackView.translatesAutoresizingMaskIntoConstraints = false
            innerStackView.axis = .horizontal
            innerStackView.distribution = .fillEqually
            innerStackView.spacing = 10.0
            outerStackView.addArrangedSubview(innerStackView)
            
            for _ in 1...2 {
                let label = labels.popLast()!
                innerStackView.addArrangedSubview(label)
            }
        }
        
    }
    
    
}
