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



extension CGFloat {
    static let overlayDistanceFromBottom: CGFloat = -25.0
    static let heightDistanceBetweenChildOverParent: CGFloat = 50.0
    static let maximumImageRatio: CGFloat = 1.2
}

extension String {
    static let photosToSinglePhotoID = "PhotoVC-SinglePhotoVC"
    static let restaurantHomeToDetailImageView = "restaurantHomeToDetailImageView"
    static let restaurantHomeToDetailStarRatingView = "restaurantHomeToDetailStarRatingView"
    static let restaurantAnnotationIdentifier = "restaurantAnnotationIdentifier"
    static let searchLocationAnnotationIdentifier = "searchLocationAnnotationIdentifier"
    static let currentLocation = "Current location"
    static let mapLocation = "Map location"
    static let searchBarTransitionType = "searchBarTransitionType"
    static let searchBarTransitionLocation = "searchBarTransitionLocation"
    static let recentLocationSearchesKey = "recentLocationSearchesKey"
}


extension UIImage {
    static let locationImage = UIImage(systemName: "location.fill")!.withTintColor(Colors.locationColor)
    static let mapImage = UIImage(systemName: "map")!.withTintColor(Colors.locationColor)
    static let clearImage = UIImage(systemName: "xmark.circle")!.withTintColor(Colors.main)
    static let bookImage = UIImage(systemName: "book")!
    static let magnifyingGlassImage = UIImage(systemName: "magnifyingglass")!
    static let personImage = UIImage(systemName: "person")!
    static let unchecked = UIImage(systemName: "square", withConfiguration: UIImage.SymbolConfiguration(scale: .large))!
    static let checked = UIImage(systemName: "checkmark.square", withConfiguration: UIImage.SymbolConfiguration(scale: .large))!
    static let settingsImage = UIImage(systemName: "gear")!
    static let eyeImage = UIImage(systemName: "eye")!
    static let eyeSlashImage = UIImage(systemName: "eye.slash")!
    static let checkImage = UIImage(systemName: "checkmark")!
    static let xImage = UIImage(systemName: "xmark")!
    static let checkmarkCircleImage = UIImage(systemName: "checkmark.circle.fill")!
    static let mapPinImage = UIImage(systemName: "mappin", withConfiguration: UIImage.SymbolConfiguration(scale: .large))!
    static let mapPinLocationImage = UIImage(systemName: "mappin.and.ellipse", withConfiguration: UIImage.SymbolConfiguration(scale: .large))!
    static let homeImage = UIImage(systemName: "house")!
    static let starCircleImage = UIImage(systemName: "star.circle")!
    static let threeDotsImage = UIImage(systemName: "ellipsis")!
    static let detailImage = UIImage(systemName: "doc.text.magnifyingglass")!
    static let plusImage = UIImage(systemName: "plus")!
    static let minusImage = UIImage(systemName: "minus")!
    static let locationTriangle = UIImage(systemName: "location.fill")!
    static let houseImage = UIImage(systemName: "house")!
    static let personBadgeImage = UIImage(systemName: "person.badge.plus")!
    static let personCircleImage = UIImage(systemName: "person.circle")!
    static let messageImage = UIImage(systemName: "message")!
    static let plusCircleImage = UIImage(systemName: "plus.circle")!
    static let trashImage = UIImage(systemName: "trash")!
    static let squaresImage = UIImage(systemName: "square.stack.fill")!
    static let arrowDownImage = UIImage(systemName: "chevron.down.square")!
    static let circleImage = UIImage(systemName: "circle")!
    static let reloadImage = UIImage(systemName: "arrow.counterclockwise")!
    static let listImage = UIImage(systemName: "list.bullet")!
    static let filterImage = UIImage(systemName: "line.horizontal.3.decrease.circle")!
    static let filterNoCircleImage = UIImage(systemName: "line.horizontal.3.decrease")!
    static let colorPickerIcon = UIImage(systemName: "eyedropper.halffull")!
    static let recentsImage = UIImage(systemName: "clock")!
    static let cameraImage = UIImage(systemName: "camera")!
}



extension UIImage.Configuration {
    static let small = UIImage.SymbolConfiguration(scale: .small)
    static let large = UIImage.SymbolConfiguration(scale: .large)
}
