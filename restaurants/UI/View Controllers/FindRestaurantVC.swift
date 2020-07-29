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
    private var selectedViewTransitionStyle: RestaurantSelectedView.UpdateStyle = .none
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
    private var childPosition: ChildPosition = .middle
    private var restaurantSelectedView: RestaurantSelectedView?
    private var userMovedMapView = false
    
    private enum ChildPosition {
        case top
        case middle
        case bottom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        setUp()
        addChildViewController()
        setUpMapViewPanGestureRecognizer()
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
                let location = locationManager.location?.coordinate ?? .simulatorDefault
                Network.shared.getRestaurants(coordinate: locationManager.location?.coordinate ?? .simulatorDefault) { result in
                    switch result {
                    case .success(let restaurants):
                        self.userMovedMapView = false
                        self.moreRestaurantsButtonShown = false
                        self.moreRestaurantsButton?.hideFromScreen()
                        self.mapView.showRestaurants(restaurants, fitInTopHalf: true, coordinateForNonUserLocationSearch: nil)
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
        
        mapView.constrainSides(to: self.view)
        
    }
    
    private func addChildViewController() {
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
        self.containerView.addGestureRecognizer(panGestureRecognizer)

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
    
    private func doneWithRestaurantSelectedView() {
        self.restaurantSelectedView?.removeFromSuperview()
        self.restaurantSelectedView = nil
    }
    
    private func setUpMapViewPanGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        panGesture.delegate = self
        mapView.addGestureRecognizer(panGesture)
    }

    @objc private func didDragMap(_ sender: UIGestureRecognizer) {
        /*
        mapView.deselectAllAnnotations()
        
        restaurantSelectedView?.animateRemovingWithCompletion(complete: { (finished) in
            self.doneWithRestaurantSelectedView()
        })
        */
        
        if sender.state == .ended {
            if !userMovedMapView {
                userMovedMapView = true
                moreRestaurantsButtonShown = true
                moreRestaurantsButton = OverlayButton()
                moreRestaurantsButton!.setTitle("Redo search here", for: .normal)
                self.view.addSubview(moreRestaurantsButton!)
                moreRestaurantsButton?.addTarget(self, action: #selector(findRestaurantsAgain), for: .touchUpInside)
                moreRestaurantsButton?.showFromBottom(on: restaurantListVC.view)
            }
        }
    }
    
    private func scrollChildToTop() {
        childPosition = .top
        handleShowingOrHidingSelectedView()
        UIView.animate(withDuration: 0.3) {
            self.childTopAnchor.constant = .heightDistanceBetweenChildOverParent
            self.view.layoutIfNeeded()
        }
    }
    
    private func scrollChildToMiddle() {

        // If an annotation is currently selected, scroll to that row in the table view
        #warning("need to complete")
        
        if let constant = middleConstraintConstantForChild {
            childPosition = .middle
            handleShowingOrHidingSelectedView()
            UIView.animate(withDuration: 0.3) {
                self.childTopAnchor.constant = constant
                if !self.userMovedMapView {
                    self.mapView.updateAllAnnotationZoom(topHalf: true)
                }
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func scrollChildToBottom(allowedDistance: CGFloat) {
        
        // See if a restaurant is currently selected, if it is, create the restaurantSelectedView for it
        childPosition = .bottom
        handleShowingOrHidingSelectedView()
        
        UIView.animate(withDuration: 0.3) {
            self.childTopAnchor.constant = self.view.frame.height - allowedDistance
            if !self.userMovedMapView {
                self.mapView.updateAllAnnotationZoom(topHalf: false)
            }
            self.view.layoutIfNeeded()
        }
        
    }
    
    private func createSelectedRestaurantView(annotationRestaurant: Restaurant) {
        if childPosition == .middle {
            restaurantListVC.scrollToRestaurant(annotationRestaurant)
        } else if childPosition == .bottom {
            let isFirst = restaurants.first?.id == annotationRestaurant.id
            let isLast = restaurants.last?.id == annotationRestaurant.id
            if let restSelectedView = restaurantSelectedView {
                restSelectedView.updateWithNewRestaurant(restaurant: annotationRestaurant, isFirst: isFirst, isLast: isLast, updateStyle: selectedViewTransitionStyle)
                selectedViewTransitionStyle = .none
            } else {
                restaurantSelectedView = RestaurantSelectedView(restaurant: annotationRestaurant, isFirst: isFirst, isLast: isLast, vc: self)
                self.view.addSubview(restaurantSelectedView!)
                NSLayoutConstraint.activate([
                    restaurantSelectedView!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    restaurantSelectedView!.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 35.0),
                    restaurantSelectedView!.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -20.0)
                    
                ])
            }
        }
    }
    
    private func handleShowingOrHidingSelectedView() {
        
        guard mapView.selectedAnnotations.count > 0 else {
            restaurantSelectedView?.animateRemovingWithCompletion(complete: { (finished) in
                self.doneWithRestaurantSelectedView()
            })
            return
        }
        
        if let selectedAnnotation = mapView.selectedAnnotations[0] as? RestaurantAnnotation {
            let selectedRest = selectedAnnotation.restaurant
            
            switch childPosition {
            case .top, .middle:
                restaurantSelectedView?.animateRemovingWithCompletion(complete: { (finished) in
                    self.doneWithRestaurantSelectedView()
                })
                restaurantListVC.scrollToRestaurant(selectedRest)
            case .bottom:
                createSelectedRestaurantView(annotationRestaurant: selectedRest)
            }
        }
        
        
    }
    
    @objc private func findRestaurantsAgain() {
        userMovedMapView = false
        moreRestaurantsButton!.showLoadingOnButton()
        let location = mapView.region.center
        Network.shared.getRestaurants(coordinate: location) { (response) in
            
            switch response {
            case .success(let allRestaurants):
                // need to add the restaurants here
                // need to set the new center
                self.mapView.removeAnnotations(self.mapView?.annotations ?? [])
                self.restaurants = allRestaurants
                self.mapView.showRestaurants(allRestaurants, fitInTopHalf: self.childPosition == .middle, coordinateForNonUserLocationSearch: location)
                self.restaurantListVC.scrollTableViewToTop()
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

// MARK: MKMapViewDelegate
extension FindRestaurantVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let restaurantAnnotationView = view as? RestaurantAnnotationView, let sendRestaurant = restaurantAnnotationView.restaurant {
            let vc = RestaurantDetailVC(restaurant: sendRestaurant, imageAlreadyFound: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Scroll to the correct cell
        if let restaurantAnnotation = view as? RestaurantAnnotationView, let annotationRestaurant = restaurantAnnotation.restaurant {
            createSelectedRestaurantView(annotationRestaurant: annotationRestaurant)
        }
        
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        // Deselect runs before select when one is switched, so need to look in the future and see if there are any selected
        // If none are selected, animate the view gone
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if mapView.selectedAnnotations.count == 0 {
                self.restaurantSelectedView?.animateRemovingWithCompletion(complete: { (finished) in
                    self.doneWithRestaurantSelectedView()
                })
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Only need to handle pin for search center location
        guard annotation is MKPointAnnotation else { return nil }
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        return annotationView
    }

}


// MARK: UIGestureRecognizerDelegate
extension FindRestaurantVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: RestaurantSelectedViewDelegate
extension FindRestaurantVC: RestaurantSelectedViewDelegate {
    func restaurantSelected(rest: Restaurant) {
        var imageFound: UIImage?
        if let restSelectedView = restaurantSelectedView {
            restSelectedView.setUpForHero()
            imageFound = restSelectedView.imageView.image
        }
        self.navigationController?.isHeroEnabled = true
        self.navigationController?.pushViewController(RestaurantDetailVC(restaurant: rest, fromCell: nil, imageAlreadyFound: imageFound), animated: true)
    }
    
    func nextButtonSelected(rest: Restaurant) {
        let allAnnotations = mapView.annotations
        let indexOfCurrRestaurant = restaurants.firstIndex { (r) -> Bool in
            r.id == rest.id
        }
        if let index = indexOfCurrRestaurant {
            let numToFind = index + 2
            for annotation in allAnnotations {
                if let restAnnotation = annotation as? RestaurantAnnotation {
                    if restAnnotation.place == numToFind {
                        selectedViewTransitionStyle = .forward
                        mapView.selectAnnotation(restAnnotation, animated: true)
                    }
                }
            }
        }
    }
    
    func previousButtonSelected(rest: Restaurant) {
        let allAnnotations = mapView.annotations
        let indexOfCurrRestaurant = restaurants.firstIndex { (r) -> Bool in
            r.id == rest.id
        }
        if let index = indexOfCurrRestaurant {
            let numToFind = index
            for annotation in allAnnotations {
                if let restAnnotation = annotation as? RestaurantAnnotation {
                    if restAnnotation.place == numToFind {
                        selectedViewTransitionStyle = .back
                        mapView.selectAnnotation(restAnnotation, animated: true)
                    }
                }
            }
        }
    }
    
}
