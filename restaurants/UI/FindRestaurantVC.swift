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
        setUpMapView()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        setUp()
        
    }
    
    private func setUp () {
        print("Getting to this point")
        if self.locationServicesEnabled() {
            
            if locationManager.handleAuthorization(on: self) {
                mapView.showsUserLocation = true
                mapView.centerOnLocation(locationManager: locationManager)
                Network.shared.getRestaurants(coordinate: locationManager.location!.coordinate) { result in
                    switch result {
                    case .success(let restaurants):
                        self.mapView.showRestaurants(restaurants)
                    case .failure(let error):
                        print("Error reading restaurants: \(error.localizedDescription)")
                    }
                }
            }
            
        }
    }
    
    private func setUpMapView() {
        mapView = MKMapView()
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsTraffic = false
        mapView.register(RestaurantAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        self.view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}



// MARK: CLLocationManagerDelegate
extension FindRestaurantVC: CLLocationManagerDelegate {
    #warning("see if i need to complete this")
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("probably need to complete")
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Need to complete: \(status.rawValue)")
    }
}

extension FindRestaurantVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let restaurantAnnotationView = view as? RestaurantAnnotationView {
            print(restaurantAnnotationView.restaurant.name)
        }
    }
}
