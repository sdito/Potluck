//
//  Values.swift
//  restaurants
//
//  Created by Steven Dito on 7/4/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

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
    static let recipeHomeToDetailTitle = "recipeHomeToDetailTitle"
    static let recipeHomeToDetailImageView = "recipeHomeToDetailImageView"
    static let recipeHomeToDetailStarRatingView = "recipeHomeToDetailStarRatingView"
}
