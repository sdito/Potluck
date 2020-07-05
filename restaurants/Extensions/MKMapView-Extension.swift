//
//  MKMapView-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 7/2/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//



import MapKit

extension MKMapView {
    func centerOnLocation(locationManager: CLLocationManager) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 7_000, longitudinalMeters: 7_000)
            self.setRegion(region, animated: true)
        }
    }
    
    func showRestaurants(_ restaurants: [Restaurant]) {
        let annotations = restaurants.map({RestaurantAnnotation(restaurant: $0)})
        self.addAnnotations(annotations)
    }
    
}
