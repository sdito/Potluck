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
    private var locationsSearched: [CLLocationCoordinate2D] = []
    private var restaurants: [Restaurant] = []
    let locationManager = CLLocationManager()
    
    var mapView: MKMapView!
    private var moreRestaurantsButton: OverlayButton?
    
    
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
                            self.locationsSearched.append(location)
                        }
                        self.restaurants = restaurants
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
    
    @objc private func findRecipesAgain() {
        moreRestaurantsButton!.showLoadingOnButton()
        let location = mapView.region.center
        Network.shared.getRestaurants(coordinate: location) { (response) in
            
            switch response {
            case .success(let allRestaurants):
                // need to add the restaurants here
                // need to set the new center
                self.locationsSearched.append(location)
                let newRestaurants = allRestaurants.getNewRestaurants(old: self.restaurants)
                self.restaurants.append(contentsOf: newRestaurants)
                self.mapView.showRestaurants(newRestaurants)
                
            case .failure(_):
                print("Error finding new restaurants")
            }
            
            self.moreRestaurantsButtonShown = false
            self.moreRestaurantsButton?.hideFromScreen()
        }
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
        if let restaurantAnnotationView = view as? RestaurantAnnotationView, let sendRestaurant = restaurantAnnotationView.restaurant {
            let vc = RestaurantDetailVC(restaurant: sendRestaurant)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        let newCenter = mapView.region.center
        
        if locationsSearched.count > 0 {
            let distance = newCenter.distance(from: locationsSearched)
            if distance > .distanceToFindNewRestaurants {
                if !moreRestaurantsButtonShown {
                    print("Show the button")
                    moreRestaurantsButtonShown = true
                    moreRestaurantsButton = OverlayButton()
                    moreRestaurantsButton!.setTitle("Show more restaurants", for: .normal)
                    mapView.addSubview(moreRestaurantsButton!)
                    moreRestaurantsButton?.addTarget(self, action: #selector(findRecipesAgain), for: .touchUpInside)
                    moreRestaurantsButton?.showFromBottom(on: mapView)
                }
                
            } else {
                if moreRestaurantsButtonShown {
                    moreRestaurantsButtonShown = false
                    moreRestaurantsButton?.hideFromScreen()
                }
            }
            
        }
    }
    
}
