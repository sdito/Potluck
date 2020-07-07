//
//  CLLocationCoordinate2D-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 7/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import CoreLocation


extension CLLocationCoordinate2D {
    func getParams() -> [String:Any] {
        let latitude = self.latitude
        let longitude = self.longitude
        
        let params: [String:Any] = [
            "latitude": latitude,
            "longitude": longitude
        ]
        return params
    }
    
    func distance(from locations: [CLLocationCoordinate2D]) -> CLLocationDistance {
        var longest: CLLocationDistance?
        for location in locations {
            let destination = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let distance = CLLocation(latitude: self.latitude, longitude: self.longitude).distance(from: destination)
            longest = min(distance, longest ?? distance)
        }
        return longest ?? 0.0
    }
    
}
