//
//  RestaurantAnnotationView.swift
//  restaurants
//
//  Created by Steven Dito on 7/4/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import MapKit


class RestaurantAnnotationView: MKMarkerAnnotationView {
    
    var restaurant: Restaurant?
    var establishment: Establishment?
    var place: Int!
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let restaurantAnnotation = newValue as? RestaurantAnnotation else { return }
            restaurant = restaurantAnnotation.restaurant
            establishment = restaurantAnnotation.establishment
            place = restaurantAnnotation.place
            
            displayPriority = .required
            
            
            if restaurant != nil {
                markerTintColor = Colors.main
                if let place = place {
                    glyphText = "\(place)"
                }
            } else if let establishment = establishment {
                if establishment.isRestaurant {
                    markerTintColor = Colors.main
                    glyphImage = nil
                } else {
                    markerTintColor = Colors.secondary
                    glyphImage = .homeImage
                }
                
            }
            
            
        }
    }

    
}
