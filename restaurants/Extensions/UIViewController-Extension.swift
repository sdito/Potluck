//
//  UIViewController-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 6/27/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

extension UIViewController {
    
    func locationServicesEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            return true
        } else {
            #warning("alert or something here")
            return false
        }
    }
    
    func openMaps(coordinate: CLLocationCoordinate2D, name: String, method: String = "driving") {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = name
        var value: String {
            if method == "driving" {
                return MKLaunchOptionsDirectionsModeDriving
            } else if method == "walk" {
                return MKLaunchOptionsDirectionsModeWalking
            } else if method == "transit" {
                return MKLaunchOptionsDirectionsModeTransit
            } else {
                return MKLaunchOptionsDirectionsModeDefault
            }
        }
        
        #warning("could have option to get a ride with uber")
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : value])
    }
    
    
    // MARK: Alerts
    func alert(title: String, message: String, button: String = "Ok") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: button, style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func actionSheet(title: String? = nil, message: String? = nil, actions: [(title: String, pressed: () -> ())]) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        for action in actions {
            //let act = UIAlertAction(title: action.title, style: .default, handler: action.pressed)
            let act = UIAlertAction(title: action.title, style: .default) { (alertAction) in
                action.pressed()
            }
            actionSheet.addAction(act)
        }
        actionSheet.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true)
        
    }
    
    
    func setNavigationBarColor(color: UIColor) {
        let image = UIImage(color: color)
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        self.navigationController?.navigationBar.shadowImage = image
    }
    
    
    
}


