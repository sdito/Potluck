//
//  Values.swift
//  restaurants
//
//  Created by Steven Dito on 7/4/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import CoreGraphics
import CoreLocation

extension CGSize {
    static let annotationImageSize = CGSize(width: 50, height: 50)
}

extension CLLocationDistance {
    static let distanceToFindNewRestaurants = 3000.0
}

extension CGFloat {
    static let overlayDistanceFromBottom: CGFloat = -25.0
    static let heightDistanceBetweenChildOverParent: CGFloat = 50.0
}

extension String {
    static let photosToSinglePhotoID = "PhotoVC-SinglePhotoVC"
    static let restaurantHomeToDetailTitle = "restaurantHomeToDetailTitle"
    static let restaurantHomeToDetailImageView = "restaurantHomeToDetailImageView"
    static let restaurantHomeToDetailStarRatingView = "restaurantHomeToDetailStarRatingView"
    static let restaurantAnnotationIdentifier = "restaurantAnnotationIdentifier"
    static let searchLocationAnnotationIdentifier = "searchLocationAnnotationIdentifier"
    static let currentLocation = "Current location"
    static let mapLocation = "Map location"
    
    static let searchBarTransitionType = "searchBarTransitionType"
    static let searchBarTransitionLocation = "searchBarTransitionLocation"
}

extension UIImage {
    static let locationImage = UIImage(systemName: "location.fill")!.withTintColor(Colors.locationColor)
    static let mapImage = UIImage(systemName: "map.fill")!.withTintColor(Colors.locationColor)
    static let clearImage = UIImage(systemName: "xmark.circle")!.withTintColor(Colors.main)
    static let bookImage = UIImage(systemName: "book")!
    static let magnifyingGlassImage = UIImage(systemName: "magnifyingglass")
    static let filterButton = UIImage(systemName: "line.horizontal.3.decrease.circle")!
    static let unchecked = UIImage(systemName: "square", withConfiguration: UIImage.SymbolConfiguration(scale: .large))!
    static let checked = UIImage(systemName: "checkmark.square", withConfiguration: UIImage.SymbolConfiguration(scale: .large))!
    
}
