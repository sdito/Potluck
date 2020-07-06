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
    
    private var moreRestaurantsButtonShown = false
    private var latestCenter: CLLocationCoordinate2D?
    var mapView: MKMapView!
    private var moreRestaurantsButton: OverlayButton?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
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
                        self.mapView.getCenterAfterAnimation { (location) in
                            self.latestCenter = location
                        }
                    case .failure(let error):
                        print("Error reading restaurants: \(error.localizedDescription)")
                    }
                }
            }
            
        }
    }
    
    private func setUpView() {
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
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
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
            let vc = UIViewController()
            vc.view.backgroundColor = Colors.main

            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false

            label.text = restaurantAnnotationView.restaurant.name
            label.textColor = Colors.secondary
            vc.view.addSubview(label)
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        let newCenter = mapView.region.center
        
        if let latestCenter = latestCenter {
            let distance = latestCenter.distance(from: newCenter)
            if distance > .distanceToFindNewRestaurants {
                if !moreRestaurantsButtonShown {
                    print("Show the button")
                    moreRestaurantsButtonShown = true
                    moreRestaurantsButton = OverlayButton()
                    moreRestaurantsButton!.setTitle("Show more restaurants", for: .normal)
                    mapView.addSubview(moreRestaurantsButton!)
                    moreRestaurantsButton?.showFromBottom(on: mapView)
                }
                
            } else {
                if moreRestaurantsButtonShown {
                    print("Hide the button")
                    moreRestaurantsButtonShown = false
                    moreRestaurantsButton?.hideFromScreen()
                }
            }
            
        }
    }
    
}
