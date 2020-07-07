//
//  RestaurantDetailVC.swift
//  restaurants
//
//  Created by Steven Dito on 7/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class RestaurantDetailVC: UIViewController {
    
    var restaurant: Restaurant!
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    
    private func setUp() {
        view.backgroundColor = .systemBackground
        let scrollView = UIScrollView()
        let stackView = UIStackView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 3.0
        
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor)
        ])
        
        let imageView = UIImageView()
        stackView.addArrangedSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.6)
        ])
        
        
        
        Network.shared.getImage(url: restaurant.imageURL) { (img) in
            imageView.image = img
        }
        
        let starRatingView = StarRatingView(stars: restaurant.rating)
        
        let titleStackView = UIStackView()
        titleStackView.alignment = .leading
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.axis = .vertical
        let titleLabel = UILabel()
        titleLabel.text = restaurant.name
        titleLabel.font = .createdTitle
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(starRatingView)
        
        imageView.addSubview(titleStackView)
        
        NSLayoutConstraint.activate([
            titleStackView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 10),
            titleStackView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10)
        ])
        
        
        
        
        Network.shared.setRestaurantReviewInfo(restaurant: &restaurant) { (complete) in
            print("Done adding the reviews, now add them to the UI")
        }
        
        
    }
    

}
