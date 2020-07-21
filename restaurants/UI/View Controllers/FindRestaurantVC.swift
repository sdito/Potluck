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
    
    private var restaurantListVC: RestaurantListVC!
    private var moreRestaurantsButtonShown = false
    private var locationsSearched: [CLLocationCoordinate2D] = []
    private var restaurants: [Restaurant] = [] {
        didSet {
            if restaurantListVC != nil {
                self.restaurantListVC.restaurants = self.restaurants
            }
        }
    }
    private var containerView: UIView!
    private var childTopAnchor: NSLayoutConstraint!
    private var lastPanOffset: CGFloat?
    private var startingChildSizeConstant: CGFloat?
    
    let locationManager = CLLocationManager()
    
    var mapView: MKMapView!
    private var moreRestaurantsButton: OverlayButton?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        setUp()
        addChildViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setUp () {
        self.title = "Search"
        if self.locationServicesEnabled() {
            if locationManager.handleAuthorization(on: self) {
                mapView.showsUserLocation = true
                mapView.centerOnLocation(locationManager: locationManager)
                Network.shared.getRestaurants(coordinate: locationManager.location?.coordinate ?? .simulatorDefault) { result in
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
    
    private func addChildViewController() {
        #warning("need to put finishing touches")
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerView)
        childTopAnchor = containerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.frame.height/2)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            containerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: -.heightDistanceBetweenChildOverParent),
            childTopAnchor
        ])
        
        
        
        restaurantListVC = RestaurantListVC()
        addChild(restaurantListVC)
        restaurantListVC.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(restaurantListVC.view)
        
        restaurantListVC.view.constrainSides(to: containerView)
        restaurantListVC.didMove(toParent: self)
        
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleFullScreenPanningSelector))
        self.view.addGestureRecognizer(panGestureRecognizer)

    }
    
    @objc private func handleFullScreenPanningSelector(sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view.window)
        switch sender.state {
        case .began:
            lastPanOffset = touchPoint.y
            startingChildSizeConstant = childTopAnchor.constant
        case .changed:
            if let lastPanOffset = lastPanOffset {
            
                let difference = touchPoint.y - lastPanOffset
                childTopAnchor.constant += (difference * 1.5) // 1.5 or else it will scroll back up too slow and require multiple swipes
                
                // if it is going to go too high off the screen
                if childTopAnchor.constant < .heightDistanceBetweenChildOverParent {
                    childTopAnchor.constant = .heightDistanceBetweenChildOverParent
                }
                
                // if it is going to go too low off the screen
                // constant should be 2* .heightDistanceBetweenChildOverParent
                let distanceAboveBottom = self.view.frame.height - childTopAnchor.constant
                let allowedDistance = 2 * CGFloat.heightDistanceBetweenChildOverParent
                if distanceAboveBottom < allowedDistance {
                    childTopAnchor.constant = self.view.frame.height - allowedDistance
                }
                
                self.lastPanOffset = touchPoint.y
            }
        default:
            break
        }
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
                self.restaurants = allRestaurants
                self.mapView.showRestaurants(allRestaurants)
                
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
            let vc = RestaurantDetailVC(restaurant: sendRestaurant, imageAlreadyFound: nil)
            self.navigationController?.pushViewController(vc, animated: true)
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
                    moreRestaurantsButton?.showFromBottom(on: restaurantListVC.view)
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
