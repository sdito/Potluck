//
//  UIDevice-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 9/10/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import CoreLocation

extension UIDevice {
    static func vibrateSelectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    static func vibrateSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    static func vibrateError() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    static func readRecentLocationSearchesFromUserDefaults() -> [String] {
        let defaults = UserDefaults.standard
        let previousLocationSearches = defaults.array(forKey: .recentLocationSearchesKey) as? [String] ?? []
        return previousLocationSearches
    }
    
    static func locationServicesEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            return true
        } else {
            return false
        }
    }
    
    static func handleAuthorization() -> (authorized: Bool, needToRequest: Bool) {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            return (false, true)
        case .restricted:
            return (false, false)
        case .denied:
            return (false, false)
        case .authorizedAlways:
            return (true, false)
        case .authorizedWhenInUse:
            return (true, false)
        @unknown default:
            return (false, false)
        }
    }
    
    static func completeLocationEnabled() -> Bool {
        return locationServicesEnabled() && handleAuthorization().authorized
    }
}
