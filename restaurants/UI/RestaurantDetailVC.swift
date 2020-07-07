//
//  RestaurantDetailVC.swift
//  restaurants
//
//  Created by Steven Dito on 7/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class RestaurantDetailVC: UIViewController {
    
    private var restaurant: Restaurant!
    
    // UI values
    private var navigationTitleHidden = true
    private var titleVerticalBottom: CGFloat = 10000.0
    private var distanceOfImageView: CGFloat = 10000.0
    private var latestAlpha = 0.0
    
    
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
        self.title = ""
        self.setNavigationBarColor(color: Colors.navigationBarColor.withAlphaComponent(0.0))
        
        self.navigationController?.navigationBar.tintColor = Colors.main
        
        view.backgroundColor = .systemBackground
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        
        let stackView = UIStackView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never
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
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            imageView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        
        
        imageView.layoutIfNeeded()
        distanceOfImageView = imageView.bounds.height - (self.navigationController?.navigationBar.bounds.height ?? 0.0)
        
        Network.shared.getImage(url: restaurant.imageURL) { (img) in
            imageView.image = img
        }
        
        let starRatingView = StarRatingView(stars: restaurant.rating, numReviews: restaurant.reviewCount)
        
        let titleStackView = UIStackView()
        titleStackView.alignment = .leading
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.axis = .vertical
        titleStackView.spacing = 3.0
        
        let titleLabel = PaddingLabel(top: 2.0, bottom: 2.0, left: 5.0, right: 5.0)
        titleLabel.numberOfLines = 2
        titleLabel.text = restaurant.name
        titleLabel.font = .createdTitle
        titleLabel.textColor = .white
        titleLabel.fadedBackground()
        
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(starRatingView)
        
        imageView.addSubview(titleStackView)
        
        NSLayoutConstraint.activate([
            titleStackView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 10),
            titleStackView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10),
        ])
        
        titleVerticalBottom = titleStackView.frame.maxY; #warning("need to set this")
        
        
        
        Network.shared.setRestaurantReviewInfo(restaurant: &restaurant) { (complete) in
            print("Done adding the reviews, now add them to the UI")
        }
        
        for i in 1...50 {
            let label = UILabel()
            label.text = "\(i)"
            stackView.addArrangedSubview(label)
        }
        
        
        scrollView.setCorrectContentSize()
        
    }
    

}



extension RestaurantDetailVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        print(offset, distanceOfImageView)
        
        if offset > distanceOfImageView {
            
            if navigationTitleHidden {
                self.title = restaurant.name
                navigationTitleHidden = false
            }
            
            if latestAlpha != 1.0 {
                self.setNavigationBarColor(color: Colors.navigationBarColor.withAlphaComponent(1.0))
            }
        } else {
            
            if !navigationTitleHidden {
                self.title = ""
                navigationTitleHidden = true
            }
            
            let ratio = Double((offset / distanceOfImageView) * 100).rounded() / 100
            if ratio > 0.0 && ratio != latestAlpha {
                self.setNavigationBarColor(color: Colors.navigationBarColor.withAlphaComponent(CGFloat(ratio)))
                
                latestAlpha = ratio
            }
        }
        
        
    }
}
