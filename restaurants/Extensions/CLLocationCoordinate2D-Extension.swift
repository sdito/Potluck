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
}
