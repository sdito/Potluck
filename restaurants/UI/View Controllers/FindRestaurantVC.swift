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


protocol SearchUpdatedFromMasterDelegate: class {
    func newSearch(search: Network.RestaurantSearch)
}

class FindRestaurantVC: UIViewController {
    
    weak var delegate: SearchUpdatedFromMasterDelegate?
    
    var searchFilters: [String:Any] = [:] {
        didSet {
            restaurantListVC.updateNotificationCount()
            restaurantSearchBar?.showActivityIndicator()
            getRestaurantsFromPreSetRestaurantSearch(initial: false)
        }
    }
    var restaurantSearchBar: RestaurantSearchBar?
    var restaurantSearch = Network.RestaurantSearch(yelpCategory: nil, location: nil, coordinate: nil) {
        didSet {
            restaurantSearchBar?.update(searchInfo: self.restaurantSearch)
            delegate?.newSearch(search: self.restaurantSearch)
        }
    }
    private var restaurantListVC: RestaurantListVC! {
        didSet {
            delegate = self.restaurantListVC
        }
    }
    private var hasDraggedMap = false
    private var moreRestaurantsButtonShown = false
    private var selectedViewTransitionStyle: RestaurantSelectedView.UpdateStyle = .none
    private var restaurants: [Restaurant] = [] {
        didSet {
            if restaurantListVC != nil {
                self.restaurantListVC.restaurants = self.restaurants
            }
        }
    }
    private let allowedDistance = 2 * CGFloat.heightDistanceBetweenChildOverParent
    private var trueMidPoint: CGFloat = 0.0
    private var containerView = UIView()
    private var childTopAnchor: NSLayoutConstraint!
    private var lastPanOffset: CGFloat?
    private var startingChildSizeConstant: CGFloat?
    private var middleConstraintConstantForChild: CGFloat?
    let locationManager = CLLocationManager()
    var mapView = MKMapView()
    private let reCenterMapButton = OverlayButton()
    private var moreRestaurantsButton: OverlayButton?
    private var childPosition: ChildPosition = .middle {
        didSet {
            self.restaurantListVC.atMiddle = self.childPosition == .middle
        }
    }
    private var restaurantSelectedView: RestaurantSelectedView?
    private var isRestSelectedViewSwipeDismissed = false
    private var userMovedMapView = false
    private var locationAllowed = true {
        didSet {
            self.restaurantListVC.locationAllowed = self.locationAllowed
        }
    }
    private var beginningCenter: CLLocationCoordinate2D?
    private var annotationCompleteRange: CLLocationDegrees?
    
    private let previousIndex = 0
    private let nextIndex = 2
    private let currIndex = 1
    
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
        addChildViewController()
        setUpMapViewPanGestureRecognizer()
        addReCenterMapButton()
        setUpGettingData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    private func setUpGettingData () {
        self.navigationItem.title = "Explore"
        if UIDevice.locationServicesEnabled() {
            let (authorized, needToRequest) = UIDevice.handleAuthorization()
            if authorized {
                locationAllowed = true
                mapView.showsUserLocation = true
                mapView.centerOnLocation(locationManager: locationManager)
                let location = locationManager.location?.coordinate ?? .simulatorDefault
                restaurantSearch = Network.RestaurantSearch(yelpCategory: nil, location: .currentLocation, coordinate: location)
                getRestaurantsFromPreSetRestaurantSearch(initial: true)
            } else if needToRequest {
                locationManager.requestWhenInUseAuthorization()
            } else {
                handleNonCoordinateSearch()
            }
        } else {
            handleNonCoordinateSearch()
        }
    }
    
    private func handleNonCoordinateSearch() {
        locationAllowed = false
        if let previousSearch = UIDevice.readRecentLocationSearchesFromUserDefaults().first {
            restaurantSearch = Network.RestaurantSearch(yelpCategory: nil, location: previousSearch, coordinate: nil)
            getRestaurantsFromPreSetRestaurantSearch(initial: true)
        } else {
            restaurants = []
        }
    }
    
    private func setUpView() {
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsTraffic = false
        mapView.register(RestaurantAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        self.view.addSubview(mapView)
        
        mapView.constrainSides(to: self.view)
        edgesForExtendedLayout = [.top, .left, .right]
    }
    
    private func addChildViewController() {
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
        
        restaurantListVC = RestaurantListVC(owner: self)
        
        addChild(restaurantListVC)
        restaurantListVC.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(restaurantListVC.view)
        
        restaurantListVC.view.constrainSides(to: containerView)
        restaurantListVC.didMove(toParent: self)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleFullScreenPanningSelector))
        self.containerView.addGestureRecognizer(panGestureRecognizer)

        self.view.layoutIfNeeded()
        trueMidPoint = restaurantListVC.view.convert(restaurantListVC.view.frame.origin, to: self.view).y - CGFloat.heightDistanceBetweenChildOverParent
    }
    
    private func addReCenterMapButton() {
        reCenterMapButton.setImage(.locationImage, for: .normal)
        reCenterMapButton.tintColor = Colors.locationColor
        mapView.addSubview(reCenterMapButton)
        reCenterMapButton.constrain(.bottom, to: containerView, .top, constant: 10.0)
        reCenterMapButton.constrain(.trailing, to: mapView, .trailing, constant: 10.0)
        reCenterMapButton.addTarget(self, action: #selector(reCenterMapPressed), for: .touchUpInside)
        reCenterMapButton.appIsHiddenAnimated(isHidden: true, animated: false)
    }
    
    @objc private func handleFullScreenPanningSelector(sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view.window)

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
            
            let accountedDistance = restaurantListVC.view.convert(restaurantListVC.view.frame.origin, to: self.view).y - CGFloat.heightDistanceBetweenChildOverParent// position in total height
        
            let velocityRaw = sender.velocity(in: self.view.window).y
            let absoluteVelocity = abs(velocityRaw)
            if absoluteVelocity > 250.0 { // arbitrary number to decide what counts as a gesture for swiping up/down the whole list
                if velocityRaw < 0.0 {
                    // negative user is scrolling up
                    scrollChildToTop()
                    if accountedDistance > trueMidPoint {
                        // in bottom half, scroll to middle
                        scrollChildToMiddle()
                    } else {
                        scrollChildToTop()
                    }
                } else {
                    // positive user is scrolling down
                    if accountedDistance < trueMidPoint {
                        scrollChildToMiddle()
                    } else {
                        scrollChildToBottom(allowedDistance: allowedDistance)
                    }
                }
            } else {
                let topRange = 0.0..<trueMidPoint*0.5
                let mediumRange = topRange.upperBound..<trueMidPoint*1.33
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
        hasDraggedMap = true
        guard beginningCenter != nil else {
            beginningCenter = mapView.region.center
            return
        }
    }
    
    private func handleAddingReDoSearchButtonIfNeeded() {
        // need to find the distance between the farthest annotations
        // can just find the rect then get top left to bottom right
        
        guard let beginningCenter = beginningCenter else { return }
        
        // test the current center to the beginning center
        let currentCenter = mapView.region.center
        let distance = currentCenter.distance(to: beginningCenter)
        
        print(distance)
        // if !userMovedMapView, the screen doesn't move when child position changes, else the map will stay the same
        if distance > 750 {
            userMovedMapView = true
        } else {
            userMovedMapView = false
        }
        
        if annotationCompleteRange == nil {
            annotationCompleteRange = mapView.getAnnotationBoundsFarthestDistance()
        }
        
        if distance > (annotationCompleteRange ?? 6000) / 2.0 {
            if !moreRestaurantsButtonShown {
                moreRestaurantsButtonShown = true
                moreRestaurantsButton = OverlayButton()
                moreRestaurantsButton!.setTitle("Redo search here", for: .normal)
                self.view.addSubview(moreRestaurantsButton!)
                moreRestaurantsButton?.addTarget(self, action: #selector(findRestaurantsAgain), for: .touchUpInside)
                moreRestaurantsButton?.showFromBottom(on: restaurantListVC.view)
            }
        } else {
            if moreRestaurantsButtonShown {
                moreRestaurantsButton?.hideFromScreen()
                moreRestaurantsButtonShown = false
            }
        }
    }
    
    private func scrollChildToTop() {
        hasDraggedMap = false
        handleShowingReCenterMapButtonFromMapChange(forceHide: true)
        childPosition = .top
        handleShowingOrHidingSelectedView()
        UIView.animate(withDuration: 0.4) {
            self.childTopAnchor.constant = .heightDistanceBetweenChildOverParent
            self.view.layoutIfNeeded()
        }
    }
    
    private func scrollChildToMiddle() {
        // If an annotation is currently selected, scroll to that row in the table view
        hasDraggedMap = false
        if let constant = middleConstraintConstantForChild {
            childPosition = .middle
            handleShowingOrHidingSelectedView()
            
            if !self.userMovedMapView {
                beginningCenter = nil
                mapView.updateAllAnnotationZoom(topHalf: true)
            }
            
            UIView.animate(withDuration: 0.4) {
                self.childTopAnchor.constant = constant
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func scrollChildToBottom(allowedDistance: CGFloat) {
        // See if a restaurant is currently selected, if it is, create the restaurantSelectedView for it
        hasDraggedMap = false
        childPosition = .bottom
        handleShowingOrHidingSelectedView()
        
        if !self.userMovedMapView {
            beginningCenter = nil
            mapView.updateAllAnnotationZoom(topHalf: false)
        }
        
        UIView.animate(withDuration: 0.4) {
            self.childTopAnchor.constant = self.view.frame.height - allowedDistance
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
                
                restaurantSelectedView?.transform = CGAffineTransform(translationX: 0, y: -(restaurantSelectedView!.bounds.height + 35))
                restaurantSelectedView?.layoutIfNeeded()
                
                // prevents the bug where the view will come in from the top left
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 0.4) {
                    self.restaurantSelectedView?.transform = .identity
                }
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
            guard let selectedRest = selectedAnnotation.restaurant else { return }
            
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
        beginningCenter = nil
        let location = mapView.region.center
        restaurantSearch.coordinate = location
        restaurantSearch.location = .mapLocation
        getRestaurantsFromPreSetRestaurantSearch(initial: false)
    }
    
    @objc private func reCenterMapPressed() {
        beginningCenter = nil
        mapView.updateAllAnnotationZoom(topHalf: childPosition == .middle)
        stopShowingMoreRestaurantsButton()
    }
    
    private func getRestaurantsFromPreSetRestaurantSearch(initial: Bool) {
        
        if !initial {
            moreRestaurantsButton?.showLoadingOnButton(withLoaderView: false)
        }
        
        Network.shared.getRestaurants(restaurantSearch: restaurantSearch, filters: searchFilters) { [weak self] (response) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch response {
                case .success(let newRestaurants):
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.mapView.showRestaurants(newRestaurants, fitInTopHalf: self.childPosition == .middle, reCenterMap: self.childPosition != .top)
                    self.restaurantListVC.scrollTableViewToTop()
                    self.restaurants = newRestaurants
                case .failure(_):
                    #warning("need to see if this works, not tested")
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.restaurants = []
                }
                
                self.stopShowingMoreRestaurantsButton()
            }
        }
    }
    
    private func stopShowingMoreRestaurantsButton() {
        self.userMovedMapView = false
        self.restaurantSearchBar?.doneWithRestaurantSearch()
        self.moreRestaurantsButtonShown = false
        self.moreRestaurantsButton?.hideFromScreen()
        self.beginningCenter = nil
        self.annotationCompleteRange = nil
    }
    
    func lowerChildPosition() {
        if childPosition == .top {
            scrollChildToMiddle()
        } else if childPosition == .middle {
            scrollChildToBottom(allowedDistance: allowedDistance)
        }
    }
    
    private func handleShowingReCenterMapButtonFromMapChange(forceHide: Bool = false) {
        guard !forceHide else {
            reCenterMapButton.appIsHiddenAnimated(isHidden: true, animated: false)
            return
        }
        
        let restaurantsCount = mapView.nonUserAnnotations.count
        let bottomDistance = mapView.bounds.height - childTopAnchor.constant
        let visibleMapRect = mapView.getVisibleMapRectForObstructedMapView(distanceFromTop: 0.0, distanceFromBottom: bottomDistance)
        let visibleAnnotationsCount = mapView.annotations(in: visibleMapRect).count
        
        if visibleAnnotationsCount < restaurantsCount {
            reCenterMapButton.appIsHiddenAnimated(isHidden: false)
        } else {
            reCenterMapButton.appIsHiddenAnimated(isHidden: true)
        }
    }
}

// MARK: CLLocationManagerDelegate
extension FindRestaurantVC: CLLocationManagerDelegate {
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("probably need to complete")
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        setUpGettingData()
    }
}

// MARK: MKMapViewDelegate
extension FindRestaurantVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let restaurantAnnotationView = view as? RestaurantAnnotationView, let sendRestaurant = restaurantAnnotationView.restaurant {
            let vc = RestaurantDetailVC(restaurant: sendRestaurant, imageAlreadyFound: nil, allowVisit: true)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // get rest first
        guard let restaurantAnnotation = view as? RestaurantAnnotationView, let annotationRestaurant = restaurantAnnotation.restaurant else { return }
        // if at top, nothing else needs to be done besides show a map view
        guard childPosition != .top else {
            self.showMapDetail(locationTitle: annotationRestaurant.name, coordinate: annotationRestaurant.coordinate, address: nil)
            return
        }
        // Scroll to the correct cell
        restaurantListVC.mapViewAnnotationWasDeselectedOrSelected()
        
        createSelectedRestaurantView(annotationRestaurant: annotationRestaurant)
        
        var bottomDistance = containerView.bounds.height - childTopAnchor.constant
        
        if moreRestaurantsButtonShown, let mrbs = moreRestaurantsButton {
            print("Height added again: \(mrbs.bounds.height)")
            bottomDistance += mrbs.bounds.height + 10.0 // 10.0 for the constraint distance
        }
        
        if let coord = view.annotation?.coordinate {
            mapView.handleMapZooming(distanceFromTop: restaurantSelectedView?.bounds.height ?? 0.0,
                                     distanceFromBottom: bottomDistance,
                                     pointToCheck: coord,
                                     aboveExactCenter: childPosition == .middle)
        }
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        // Deselect runs before select when one is switched, so need to look in the future and see if there are any selected
        // If none are selected, animate the view gone
        
        restaurantListVC.mapViewAnnotationWasDeselectedOrSelected()
        
        if isRestSelectedViewSwipeDismissed {
            isRestSelectedViewSwipeDismissed = false
            UIView.animate(withDuration: 0.2) {
                self.restaurantSelectedView?.frame.origin.y = -(50.0 + (self.restaurantSelectedView?.frame.height ?? 0.0))
            } completion: { _ in
                self.doneWithRestaurantSelectedView()
            }

        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if mapView.selectedAnnotations.count == 0 {
                    self.restaurantSelectedView?.animateRemovingWithCompletion(complete: { (finished) in
                        self.doneWithRestaurantSelectedView()
                    })
                }
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if hasDraggedMap {
            handleShowingReCenterMapButtonFromMapChange()
            handleAddingReDoSearchButtonIfNeeded()
        }
    }

}
// MARK: RestaurantCellDelegate
extension FindRestaurantVC: RestaurantCellDelegate {
    func mapButtonPressed(restaurant: Restaurant) {
        selectRestaurantAnnotation(rest: restaurant)
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
        self.navigationController?.pushViewController(RestaurantDetailVC(restaurant: rest, fromCell: nil, imageAlreadyFound: imageFound, allowVisit: true), animated: true)
    }
    
    func nextButtonSelected(rest: Restaurant) {
        selectRestaurantAnnotationHelper(rest: rest, indexDifference: nextIndex)
    }
    
    func previousButtonSelected(rest: Restaurant) {
        selectRestaurantAnnotationHelper(rest: rest, indexDifference: previousIndex)
    }
    
    private func selectRestaurantAnnotation(rest: Restaurant) {
        selectRestaurantAnnotationHelper(rest: rest, indexDifference: currIndex)
    }
    
    private func selectRestaurantAnnotationHelper(rest: Restaurant, indexDifference: Int)  {
        let allAnnotations = mapView.annotations
        let indexOfCurrRestaurant = restaurants.firstIndex { (r) -> Bool in
            r.id == rest.id
        }
        if let index = indexOfCurrRestaurant {
            let numToFind = index + indexDifference
            for annotation in allAnnotations {
                if let restAnnotation = annotation as? RestaurantAnnotation, restAnnotation.place == numToFind {
                    
                    if indexDifference == previousIndex {
                        selectedViewTransitionStyle = .back
                    } else if indexDifference == nextIndex {
                        selectedViewTransitionStyle = .forward
                    } else {
                        selectedViewTransitionStyle = .none
                    }
                    
                    mapView.selectAnnotation(restAnnotation, animated: true)
                    break
                }
            }
        }
    }
    
    func dismissView() {
        // Need to do a separate remove animation in mapView didDeselect
        isRestSelectedViewSwipeDismissed = true
        mapView.deselectAllAnnotations()
    }
    
    
}

// MARK: SearchRestaurantsVCDelegate
extension FindRestaurantVC: SearchCompleteDelegate {
    func newSearchCompleted(searchType: Network.YelpCategory?, locationText: String?) {
        // use a temp search
        print("Is getting to new search completed")
        var tempSearch = restaurantSearch
        if let locationText = locationText {
            tempSearch.location = locationText
            if locationText == .currentLocation {
                tempSearch.coordinate = locationManager.location?.coordinate ?? .simulatorDefault
            } else if locationText == .mapLocation {
                tempSearch.coordinate = mapView.centerCoordinate
            } else {
                tempSearch.coordinate = nil
            }
        }
        tempSearch.yelpCategory = searchType
        restaurantSearch = tempSearch
        
        
        getRestaurantsFromPreSetRestaurantSearch(initial: false)
    }
    
    func reloadSearchWithSameAttributes() {
        newSearchCompleted(searchType: restaurantSearch.yelpCategory, locationText: restaurantSearch.location)
    }
    
}
