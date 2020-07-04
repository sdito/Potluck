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
    func handleAuthorization(on vc: UIViewController) -> Bool {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            self.requestWhenInUseAuthorization()
            return false
        case .restricted:
            vc.alert(title: "Error", message: "Location services are restricted.")
            return false
        case .denied:
            vc.alert(title: "Error", message: "Location services are denied. Go into the settings application and allow the location for this application.")
            return false
        case .authorizedAlways:
            return true
        case .authorizedWhenInUse:
            return true
        @unknown default:
            return false
        }
    }
    
}



