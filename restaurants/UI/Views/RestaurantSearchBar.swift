//
//  RestaurantSearchBar.swift
//  restaurants
//
//  Created by Steven Dito on 8/9/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Hero

class RestaurantSearchBar: UIView {
    
    var areViewsHidden = false
    private var searchTypeLabel: UILabel!
    private var locationLabel: UILabel!
    private var searchImage: UIImageView!
    private var activityView: UIActivityIndicatorView?
    
    enum SearchOption {
        case type
        case location
    }
    
    init() {
        super.init(frame: .zero)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func update(searchInfo: Network.RestaurantSearch) {
        if let category = searchInfo.yelpCategory {
            searchTypeLabel.text = category.title
        } else {
            searchTypeLabel.text = "Restaurants"
        }
    
        if let location = searchInfo.location {
            locationLabel.text = location
        } else {
            locationLabel.text = "Current location"
        }
        
        if activityView != nil {
            activityView?.removeFromSuperview()
        }
        
        activityView = UIActivityIndicatorView()
        activityView!.translatesAutoresizingMaskIntoConstraints = false
        activityView!.backgroundColor = self.backgroundColor
        self.searchImage.addSubview(activityView!)
        activityView!.startAnimating()
        activityView!.constrainSides(to: self.searchImage)
    }
    
    func doneWithRestaurantSearch() {
        self.activityView?.stopAnimating()
        self.activityView?.removeFromSuperview()
    }
    
    func beginHeroAnimation() {
        areViewsHidden = true
        self.subviews.forEach { (v) in
            v.alpha = 0.0
        }
    }
    
    func endHeroAnimation() {
        areViewsHidden = false
        self.subviews.forEach { (v) in
            UIView.animate(withDuration: 0.3) {
                v.alpha = 1.0
            }
        }
    }
    
    func setUp() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .tertiarySystemBackground
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
        
        let searchStackView = UIStackView()
        searchStackView.translatesAutoresizingMaskIntoConstraints = false
        searchStackView.axis = .horizontal
        searchStackView.distribution = .fill
        searchStackView.alignment = .center
        searchStackView.spacing = 7.0
        
        self.addSubview(searchStackView)
        
        searchStackView.constrainSides(to: self, distance: 4.0)
        
        searchImage = UIImageView(image: .magnifyingGlassImage)
        searchImage.tintColor = Colors.main
        
        searchImage.widthAnchor.constraint(equalTo: searchImage.heightAnchor).isActive = true
        
        searchStackView.addArrangedSubview(searchImage)
        
        searchTypeLabel = UILabel()
        locationLabel = UILabel()
        
        searchTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        searchTypeLabel.font = .mediumBold
        locationLabel.font = .smallBold
        
        searchTypeLabel.textColor = .label
        locationLabel.textColor = .secondaryLabel
        
        searchTypeLabel.text = "Restaurants"
        locationLabel.text = "Current location"
        
        searchTypeLabel.textAlignment = .left
        locationLabel.textAlignment = .left
        
        searchStackView.addArrangedSubview(searchTypeLabel)
        searchStackView.addArrangedSubview(locationLabel)
        
        let fixerView = UIView()
        searchStackView.addArrangedSubview(fixerView)
        
        self.hero.id = .searchBarTransitionType
    }
    
    func findIfSearchTypeOrLocationPressed(point: CGPoint) -> SearchOption {
        
        let middlePointOfViews = searchTypeLabel.frame.maxX
        
        if point.x < middlePointOfViews {
            return .type
        } else {
            return .location
        }
        
    }
    
}
