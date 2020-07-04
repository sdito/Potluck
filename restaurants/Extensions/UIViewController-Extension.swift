//
//  UIViewController-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 6/27/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import CoreLocation

extension UIViewController {
    func locationServicesEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            return true
        } else {
            #warning("alert or something here")
            return false
        }
    }
    
    
    // MARK: Alerts
    func alert(title: String, message: String, button: String = "Ok") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: button, style: .default, handler: nil))
        self.present(alert, animated: true)
    
    }
    
}


