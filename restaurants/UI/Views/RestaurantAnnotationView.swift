//
//  RestaurantAnnotationView.swift
//  restaurants
//
//  Created by Steven Dito on 7/4/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import MapKit


class RestaurantAnnotationView: MKMarkerAnnotationView {
    
    var restaurant: Restaurant!
    var place: Int!
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let restaurantAnnotation = newValue as? RestaurantAnnotation else { return }
            restaurant = restaurantAnnotation.restaurant
            place = restaurantAnnotation.place

            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            displayPriority = .required
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 5.0
            stackView.addArrangedSubview(StarRatingView(stars: restaurant.rating, numReviews: restaurant.reviewCount, noBackgroundColor: true))
            if let price = restaurant.price {
                stackView.addArrangedSubview(PriceLabel(price: price))
            }
            detailCalloutAccessoryView = stackView
            markerTintColor = Colors.main
            
            #warning("this is how to put the number for each restaurant to match in the list")
            if let place = place {
                glyphText = "\(place)"
            }
        }
    }

    
}
