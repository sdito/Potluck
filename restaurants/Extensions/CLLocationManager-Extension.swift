//
//  CLLocationManager-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 6/27/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import CoreLocation

extension CLLocationManager {
    
    func getUserLocation() -> CLLocationCoordinate2D? {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            return self.location?.coordinate
        } else {
            return nil
        }
    }
    
}



