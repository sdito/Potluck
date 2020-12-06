//
//  ProfileMapVC.swift
//  restaurants
//
//  Created by Steven Dito on 9/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import MapKit

class ProfileMapVC: UIViewController {
    
    private let searchDistanceRadius = 5_000
    private let mapView = MKMapView()
    private let searchBar = UISearchBar()
    private var searchBarShown = false
    private let searchBarDistance: CGFloat = 10.0
    private weak var searchHelperDelegate: SearchHelperDelegate?
    private let searchAndCellBackgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
    private var allowHelperToChange = true
    private let geoCoder = CLGeocoder()
    private var vc: SearchHelperVC?
    private let locationButton = OverlayButton()
    private let noEstablishments = OverlayButton()
    private var locationButtonShown = true
    private var establishments: [Establishment] = [] {
        didSet {
            self.vc?.establishments = establishments
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUpNavigationController()
        setUpMap()
        setUpSearchBar()
        setUpSearchHelper()
        setUpLocationButton()
        setUpNoEstablishments()
        setUpAbilityToScrollBackOnMap()
        getRestaurantData()
        edgesForExtendedLayout = []
        NotificationCenter.default.addObserver(self, selector: #selector(establishmentDeleted(notification:)), name: .establishmentDeleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(establishmentUpdated(notification:)), name: .establishmentUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedInStatusChanged), name: .userLoggedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedInStatusChanged), name: .userLoggedOut, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUpNavigationController() {
        //switchPagePressed
        self.setNavigationBarColor()
        self.navigationController?.navigationBar.tintColor = Colors.main
        self.navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "Visit map"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Feed", style: .plain, target: self, action: #selector(switchPagePressed))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .magnifyingGlassImage, style: .plain, target: self, action: #selector(searchBarPressed))
    }
    
    private func getRestaurantData() {
        print("Get restaurant data being called")
        guard Network.shared.loggedIn else {
            establishments = []
            mapView.removeAnnotations(mapView.annotations)
            noEstablishments.setTitle("Not logged in", for: .normal)
            print("Setting isNotHidden from getRestaurantData guard")
            noEstablishments.alpha = 1.0
            return
        }
        
        DispatchQueue.main.async {
            print("Setting isHidden from getRestaurantData")
            self.noEstablishments.hideWithAlphaAnimated()
        }
        
        Network.shared.getUserEstablishments { [weak self] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.mapView.annotations)
                switch result {
                case .success(let establishments):
                    self.establishments = establishments
                    if establishments.count > 0 {
                        for establishment in establishments {
                            let annotation = RestaurantAnnotation(establishment: establishment)
                            self.mapView.addAnnotation(annotation)
                        }
                        self.fitAnnotations()
                    } else {
                        self.noEstablishments.setTitle("No places yet", for: .normal)
                        print("Setting isNotHidden from network request")
                        self.noEstablishments.showWithAlphaAnimated()
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    private func setUpMap() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mapView)
        mapView.constrainSides(to: self.view)
        mapView.delegate = self
        mapView.register(RestaurantAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    private func setUpSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(searchBar)
        searchBar.tintColor = Colors.main
        searchBar.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        searchBar.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.95).isActive = true
        searchBar.constrain(.top, to: self.view, .top, constant: searchBarDistance)
        searchBar.placeholder = "Search place or location"
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.backgroundColor = searchAndCellBackgroundColor
        searchBar.layoutIfNeeded()
        searchBar.delegate = self
        handleSearchBarTransform(animated: false)
    }
    
    private func setUpNoEstablishments() {
        noEstablishments.isUserInteractionEnabled = false
        noEstablishments.setTitle("No places yet", for: .normal)
        noEstablishments.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(noEstablishments)
        noEstablishments.constrain(.bottom, to: self.view, .bottom, constant: 50.0)
        noEstablishments.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        print("Setting isHidden from setUp")
        noEstablishments.alpha = 0.0
    }
    
    private func setUpSearchHelper() {
        vc = SearchHelperVC(completionDelegate: self, mode: .allLocationsAndEstablishments, cellColor: searchAndCellBackgroundColor, establishments: establishments)
        self.addChild(vc!)
        self.view.addSubview(vc!.tableView)
        vc!.didMove(toParent: self)
        searchHelperDelegate = vc!
        vc!.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        searchHelperDelegate?.textChanged(newString: "")
        
        vc!.tableView.constrain(.top, to: searchBar, .bottom)
        vc!.tableView.constrain(.leading, to: self.view, .leading, constant: 20.0)
        vc!.tableView.constrain(.trailing, to: self.view, .trailing, constant: 20.0)
        vc!.tableView.constrain(.bottom, to: self.view, .bottom, constant: 20.0)
        vc!.tableView.layer.cornerRadius = 10.0
        vc!.tableView.clipsToBounds = true
    }
    
    private func setUpLocationButton() {
        locationButton.setImage(.locationImage, for: .normal)
        locationButton.tintColor = Colors.locationColor
        self.view.addSubview(locationButton)
        locationButton.constrain(.trailing, to: self.mapView, .trailing, constant: searchBarDistance)
        locationButton.constrain(.bottom, to: self.mapView, .bottom, constant: searchBarDistance)
        locationButton.addTarget(self, action: #selector(fitAnnotations), for: .touchUpInside)
        locationButton.layoutIfNeeded()
        handleHidingOrShowingLocationButton(animated: false, show: false)
    }
    
    private func setUpAbilityToScrollBackOnMap() {
        #warning("potentially add this same thing on the other view of the page view controller")
        let swipeView = UIView()
        swipeView.translatesAutoresizingMaskIntoConstraints = false
        swipeView.backgroundColor = .clear
        mapView.addSubview(swipeView)
        swipeView.constrain(.leading, to: mapView, .leading)
        swipeView.constrain(.top, to: mapView, .top)
        swipeView.constrain(.bottom, to: mapView, .bottom)
        swipeView.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
    }
    
    private func handleHidingOrShowingLocationButton(animated: Bool, show: Bool) {
        locationButton.appIsHiddenAnimated(isHidden: !show, animated: animated)
    }
    
    private func handleSearchBarTransform(animated: Bool) {
        let animationDuration = 0.3
        
        var newTransformation: CGAffineTransform {
            if searchBarShown {
                return .identity
            } else {
                return CGAffineTransform(translationX: 0, y: -(self.searchBar.bounds.height + self.searchBarDistance))
            }
        }
        
        if animated {
            UIView.animate(withDuration: animationDuration) {
                self.searchBar.transform = newTransformation
            }
        } else {
            self.searchBar.transform = newTransformation
        }
        
    }
    
    @objc private func establishmentDeleted(notification: Notification) {
        if let establishment = notification.userInfo?["establishment"] as? Establishment {
            deleteEstablishment(establishment: establishment)
        }
    }
    
    @objc private func fitAnnotations() {
        self.mapView.fitAllAnnotations(newAnnotations: self.mapView.annotations, fitInTopHalf: false)
    }
    
    @objc private func establishmentUpdated(notification: Notification) {
        if let establishment = notification.userInfo?["establishment"] as? Establishment {
            for annotation in mapView.annotations {
                if let restAnnotation = annotation as? RestaurantAnnotation, restAnnotation.establishment?.djangoID == establishment.djangoID {
                    // update this annotation
                    mapView.removeAnnotation(restAnnotation)
                    break
                }
            }
            
            let newAnnotation = RestaurantAnnotation(establishment: establishment)
            self.mapView.addAnnotation(newAnnotation)
            mapView.selectAnnotation(newAnnotation, animated: true)
        }
    }
    
    func deleteEstablishment(establishment: Establishment) {
        for annotation in mapView.annotations {
            guard let annotation = annotation as? RestaurantAnnotation else { continue }
            if let annotationEstablishment = annotation.establishment {
                if (annotationEstablishment.djangoID == establishment.djangoID) && (annotationEstablishment.name == establishment.name) {
                    mapView.removeAnnotation(annotation)
                    break
                }
            }
        }
        
        establishments = establishments.filter({ $0.djangoID != establishment.djangoID })
    }
    
    @objc private func searchBarPressed() {
        searchBarShown = !searchBarShown
        handleSearchBarTransform(animated: true)
        if searchBarShown {
            searchBar.becomeFirstResponder()
            mapView.deselectAllAnnotations()
        } else {
            searchBar.endEditing(true)
        }
    }
    
    @objc private func switchPagePressed() {
        guard let tabVC = self.tabBarController as? TabVC else { return }
        tabVC.changeActivePageViewController()
    }
    
    @objc private func userLoggedInStatusChanged() {
        getRestaurantData()
    }
    
}

// MARK: Map view
extension ProfileMapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "restaurantAnnotationViewIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if searchBarShown {
            searchBarPressed()
        }
        
        guard let viewAnnotation = view.annotation as? RestaurantAnnotation else { return }
        guard let establishment = viewAnnotation.establishment else { return }
        let childHeight = self.view.bounds.height * 0.6
        let detailVC = EstablishmentDetailVC(establishment: establishment, delegate: self, mode: .halfScreenBase)
        detailVC.view.translatesAutoresizingMaskIntoConstraints = false
        detailVC.view.heightAnchor.constraint(equalToConstant: childHeight).isActive = true
        mapView.handleMapZooming(distanceFromTop: 0.0, distanceFromBottom: childHeight, pointToCheck: viewAnnotation.coordinate, aboveExactCenter: true)
        self.showAddingChildFromBottom(child: detailVC, childHeight: childHeight)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        removeChildViewControllersFromBottomOf(typeToRemove: EstablishmentDetailVC.self) { (_) in return }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let annotationCount = mapView.annotations(in: mapView.visibleMapRect).count
        if annotationCount != establishments.count {
            // show the location view, if not already shown
            handleHidingOrShowingLocationButton(animated: true, show: true)
        } else {
            // hide the location view, if not already hidden
            handleHidingOrShowingLocationButton(animated: true, show: false)
        }
    }
    
}

// MARK: EstablishmentDetailDelegate
extension ProfileMapVC: EstablishmentDetailDelegate {
    
    func detailDismissed() {
        mapView.deselectAllAnnotations()
    }
}


// MARK: Search bar
extension ProfileMapVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if allowHelperToChange {
            print(searchText)
            searchHelperDelegate?.textChanged(newString: searchText)
        }
        
    }
}


// MARK: SearchCompleteDelegate
extension ProfileMapVC: SearchHelperComplete {
    
    func establishmentSelected(establishment: Establishment) {
        allowHelperToChange = false
        searchBar.text = establishment.name
        searchBarShown = false
        handleSearchBarTransform(animated: false)
        searchBar.endEditing(true)
        // select the annotation here
        // first find the annotation
        
        for annotation in mapView.annotations {
            guard let restAnnotation = annotation as? RestaurantAnnotation else { continue }
            guard let annotationEstablishment = restAnnotation.establishment else { continue }
            if establishment.djangoID == annotationEstablishment.djangoID {
                mapView.selectAnnotation(annotation, animated: true)
                break
            }
        }
        
        
        allowHelperToChange = true
    }
    
    func searchFound(search: MKLocalSearchCompletion) {
        let addressFound = "\(search.title) \(search.subtitle)"
        allowHelperToChange = false
        searchBar.text = addressFound
        searchBar.endEditing(true)
        
        geoCoder.geocodeAddressString(addressFound) { [weak self] (placeMarks, error) in
            guard let self = self else { return }
            guard let placeMarks = placeMarks, let first = placeMarks.first, let location = first.location?.coordinate else {
                self.showMessage("Unable to locate address")
                return
            }
            
            self.mapView.setRegionAroundCoordinate(coordinate: location, distance: self.searchDistanceRadius, animated: true)
        }
        allowHelperToChange = true
    }
}
