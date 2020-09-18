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
    
    private let mapView = MKMapView()
    private let searchBar = UISearchBar()
    private var searchBarShown = false
    private let searchBarDistance: CGFloat = 7.5
    private weak var searchHelperDelegate: SearchHelperDelegate?
    private let searchAndCellBackgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
    private var allowHelperToChange = true
    private let geoCoder = CLGeocoder()
    private var vc: SearchHelperVC?
    private var establishments: [Establishment] = [] {
        didSet {
            self.vc?.establishments = establishments
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
        navigationItem.title = "Profile map"
        
        getRestaurantData()
        setUpMap()
        setUpSearchBar()
        setUpSearchHelper()
        edgesForExtendedLayout = [.top, .left, .right]
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .magnifyingGlassImage, style: .plain, target: self, action: #selector(searchBarPressed))
        
        NotificationCenter.default.addObserver(self, selector: #selector(establishmentDeleted(notification:)), name: .establishmentDeleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(establishmentUpdated(notification:)), name: .establishmentUpdated, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.setNavigationBarColor(color: Colors.navigationBarColor)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func getRestaurantData() {
        Network.shared.getUserEstablishments { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let establishments):
                    self.establishments = establishments
                    for establishment in establishments {
                        let annotation = RestaurantAnnotation(establishment: establishment)
                        self.mapView.addAnnotation(annotation)
                    }
                    self.mapView.fitAllAnnotations(newAnnotations: self.mapView.annotations, fitInTopHalf: false)
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
        searchBar.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        searchBar.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.95).isActive = true
        searchBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: searchBarDistance).isActive = true
        searchBar.placeholder = "Search place or location"
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.backgroundColor = searchAndCellBackgroundColor
        searchBar.layoutIfNeeded()
        searchBar.delegate = self
        handleSearchBarTransform(animated: false)
        
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
        #warning("delete from establishments")
        for annotation in mapView.annotations {
            guard let annotation = annotation as? RestaurantAnnotation else { continue }
            if let annotationEstablishment = annotation.establishment {
                if (annotationEstablishment.djangoID == establishment.djangoID) && (annotationEstablishment.name == establishment.name) {
                    mapView.removeAnnotation(annotation)
                    break
                }
            }
        }
    }
    
    @objc private func searchBarPressed() {
        #warning("dont let stuff be pressed maybe")
        searchBarShown = !searchBarShown
        handleSearchBarTransform(animated: true)
        if searchBarShown {
            searchBar.becomeFirstResponder()
        } else {
            searchBar.endEditing(true)
        }
        
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
            
            self.mapView.setRegionAroundCoordinate(coordinate: location, distance: 15_000, animated: true)
        }
        

        allowHelperToChange = true
    }
}
