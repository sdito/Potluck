//
//  FindRestaurantVC.swift
//  restaurants
//
//  Created by Steven Dito on 6/27/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class FindRestaurantVC: UIViewController {
    
    var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        setUpMapView()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        setUp()
        
    }
    
    private func setUp () {
        if self.locationServicesEnabled() {
            if locationManager.handleAuthorization(on: self) {
                mapView.showsUserLocation = true
            }
            
        }
    }
    
    private func setUpMapView() {
        mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }


}




extension FindRestaurantVC: CLLocationManagerDelegate {
    
}
