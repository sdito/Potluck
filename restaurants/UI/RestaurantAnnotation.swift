//
//  RestaurantAnnotation.swift
//  restaurants
//
//  Created by Steven Dito on 7/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import MapKit

class RestaurantAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let locationName: String?
    let coordinate: CLLocationCoordinate2D
    let restaurant: Restaurant
    
    init(restaurant: Restaurant) {
        self.title = restaurant.name
        self.locationName = restaurant.price
        self.coordinate = restaurant.coordinate
        self.restaurant = restaurant
    }
    
}
