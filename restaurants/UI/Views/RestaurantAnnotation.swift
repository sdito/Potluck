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
    let restaurant: Restaurant?
    let establishment: Establishment?
    let place: Int
    
    
    init(restaurant: Restaurant, place: Int) {
        self.title = restaurant.name
        self.locationName = restaurant.price
        self.coordinate = restaurant.coordinate
        self.restaurant = restaurant
        self.establishment = nil
        self.place = place
    }
    
    init(establishment: Establishment) {
        self.title = establishment.name
        self.locationName = establishment.name
        self.coordinate = establishment.coordinate!
        self.establishment = establishment
        self.restaurant = nil
        self.place = -1
    }
    
}
