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
    private var middleConstraintConstantForChild: CGFloat?
    
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
                        self.mapView.showRestaurants(restaurants, fitInTopHalf: true)
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
        middleConstraintConstantForChild = childTopAnchor.constant
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
        let allowedDistance = 2 * CGFloat.heightDistanceBetweenChildOverParent
        let touchPointY = touchPoint.y
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
                
                if distanceAboveBottom < allowedDistance {
                    childTopAnchor.constant = self.view.frame.height - allowedDistance
                }
                
                self.lastPanOffset = touchPoint.y
            }
        case .ended:
            
            // Dragging ended, either need to put all the way at the top, at exact middle, or all the way at the bottom
            // split the screen into thirds, whatever third it ends up in is the position it goes to
            
            let velocityRaw = sender.velocity(in: self.view.window).y
            let absoluteVelocity = abs(velocityRaw)
            
            if absoluteVelocity > 400.0 { // arbitrary number to decide what counts as a gesture for swiping up/down the whole list
                if velocityRaw < 0.0 {
                    // negative is scroll all the way up
                    scrollChildToTop()
                } else {
                    // positive is all the way down
                    scrollChildToBottom(allowedDistance: allowedDistance)
                }
            } else {
               #warning("need to complete, accountedDistance and accountedHeight are accurate values")
                // Either need to scroll to the top, middle, or bottom
                
                // for accountedDistance, 0.0 is the true top
                let accountedDistance = touchPointY - allowedDistance
                let accountedHeight = containerView.frame.height - allowedDistance
                print("Accounted height: \(accountedHeight), Accounted distance: \(accountedDistance)")
                let rangePortion = accountedHeight / 3.0
                
                let topRange = 0.0..<rangePortion
                let mediumRange = topRange.upperBound..<rangePortion*2.0
                let bottomRange = mediumRange.upperBound...
                
                if topRange ~= accountedDistance {
                    scrollChildToTop()
                } else if mediumRange ~= accountedDistance {
                    scrollChildToMiddle()
                } else if bottomRange ~= touchPointY {
                    scrollChildToBottom(allowedDistance: allowedDistance)
                }
                
            }
            
        default:
            break
        }
    }
    
    private func scrollChildToTop() {
        UIView.animate(withDuration: 0.3) {
            self.childTopAnchor.constant = .heightDistanceBetweenChildOverParent
            self.view.layoutIfNeeded()
        }
        
    }
    
    private func scrollChildToMiddle() {
        if let constant = middleConstraintConstantForChild {
            UIView.animate(withDuration: 0.3) {
                self.childTopAnchor.constant = constant
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func scrollChildToBottom(allowedDistance: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.childTopAnchor.constant = self.view.frame.height - allowedDistance
            self.view.layoutIfNeeded()
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
                self.mapView.showRestaurants(allRestaurants, fitInTopHalf: false)
                
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
