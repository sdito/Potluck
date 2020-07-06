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
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let restaurantAnnotation = newValue as? RestaurantAnnotation else { return }
            restaurant = restaurantAnnotation.restaurant
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            displayPriority = .required
            
            
        }
    }

    
}
