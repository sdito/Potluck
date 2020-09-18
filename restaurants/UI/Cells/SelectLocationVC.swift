//
//  SelectLocationVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/27/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import MapKit


protocol SelectLocationDelegate: class {
    func locationSelected(coordinate: CLLocationCoordinate2D, fullAddress: String)
}

class SelectLocationVC: UIViewController {
    
    private weak var delegate: SelectLocationDelegate?
    private var locationHasBeenSelected = false
    private let topContainer = UIView()
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private let searchBar = UISearchBar()
    private let geoCoder = CLGeocoder()
    private weak var searchTextDelegate: SearchHelperDelegate?
    private let mapPinImageView = UIImageView(image: .mapPinImage)
    private var previousLocation: CLLocation?
    private var showPin = false
    private var allowPin = false
    private var askPermissionBeforeSending = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .green
        setUpTopPortion()
        setUpTopPortionParts()
        setUpMap()
        setUpChildSearchHelper()
    }
    
    init(owner: SelectLocationDelegate, askPermissionBeforeSending: Bool = false) {
        self.delegate = owner
        self.askPermissionBeforeSending = askPermissionBeforeSending
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpTopPortion() {
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(topContainer)
        topContainer.backgroundColor = .secondarySystemBackground
        topContainer.constrain(.leading, to: self.view, .leading)
        topContainer.constrain(.trailing, to: self.view, .trailing)
        topContainer.constrain(.top, to: self.view, .top)
    }
    
    private func setUpTopPortionParts() {
        
        // need to set up the buttons
        let headerStack = HeaderView(leftButtonTitle: "Cancel", rightButtonTitle: "Done", title: "Find location")
        topContainer.addSubview(headerStack)
        
        headerStack.constrain(.leading, to: topContainer, .leading)
        headerStack.constrain(.trailing, to: topContainer, .trailing)
        headerStack.constrain(.top, to: topContainer, .top, constant: 10.0)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        topContainer.addSubview(searchBar)
        
        searchBar.constrain(.top, to: headerStack, .bottom, constant: 10.0)
        searchBar.constrain(.leading, to: topContainer, .leading)
        searchBar.constrain(.trailing, to: topContainer, .trailing)
        searchBar.constrain(.bottom, to: topContainer, .bottom)
        
        searchBar.delegate = self
        searchBar.tintColor = Colors.main
        searchBar.placeholder = "Search address or drag to location"
        searchBar.autocapitalizationType = .words
        
//        searchBar.searchTextField.minimumFontSize = 10.0
//        searchBar.searchTextField.adjustsFontSizeToFitWidth = true
        
        headerStack.leftButton.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        headerStack.rightButton.addTarget(self, action: #selector(doneWithSelectingLocation), for: .touchUpInside)
    }
    
    private func setUpMap() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        self.view.addSubview(mapView)
        mapView.constrain(.top, to: topContainer, .bottom)
        mapView.constrain(.leading, to: self.view, .leading)
        mapView.constrain(.trailing, to: self.view, .trailing)
        mapView.constrain(.bottom, to: self.view, .bottom)
        mapView.centerOnLocation(locationManager: locationManager, distanceAway: 15000, animated: false)
        
        mapPinImageView.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(mapPinImageView)
        mapPinImageView.tintColor = Colors.main
        mapPinImageView.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
        mapPinImageView.centerYAnchor.constraint(equalTo: mapView.centerYAnchor).isActive = true
        mapPinImageView.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showPin = true
        }
    }
    
    private func setUpChildSearchHelper() {
        let vc = SearchHelperVC(completionDelegate: self, mode: .allLocations)
        self.addChild(vc)
        self.view.addSubview(vc.tableView)
        vc.didMove(toParent: self)
        searchTextDelegate = vc
        vc.tableView.translatesAutoresizingMaskIntoConstraints = false
        vc.tableView.constrain(.top, to: topContainer, .bottom)
        vc.tableView.constrain(.leading, to: self.view, .leading)
        vc.tableView.constrain(.trailing, to: self.view, .trailing)
        vc.tableView.constrain(.bottom, to: self.view, .bottom)
        
        searchTextDelegate?.textChanged(newString: "")
    }
    
    @objc private func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneWithSelectingLocation() {
        if askPermissionBeforeSending {
            self.alert(title: "Are you sure you want to select this location?", message: nil) { [weak self] in
                self?.executeDoneWithSelectingLocation()
            }
        } else {
            executeDoneWithSelectingLocation()
        }
        
    }
    
    private func executeDoneWithSelectingLocation() {
        if let coordinate = previousLocation?.coordinate, let text = searchBar.text, text.count > 0, locationHasBeenSelected {
            self.dismiss(animated: true) {
                self.delegate?.locationSelected(coordinate: coordinate, fullAddress: text)
            }
        } else {
            searchBar.shakeView()
        }
    }
    
}


// MARK: Map view
extension SelectLocationVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        locationHasBeenSelected = true
        let center = mapView.getCenterLocation()
        
        if let previous = previousLocation {
            guard center.distance(from: previous) > 35 else { return }
        }
        
        previousLocation = center
        
        if showPin {
            
            searchBar.endEditing(true)
            
            if mapPinImageView.isHidden {
                mapPinImageView.isHidden = false
            }
            
            if mapView.annotations.count > 0 {
                mapView.removeAnnotations(mapView.annotations)
            }
            
            geoCoder.reverseGeocodeLocation(center) { [weak self] (placeMarks, error) in
                guard let self = self else { return }
                guard let placeMark = placeMarks?.first else {
                    print(error.debugDescription)
                    return
                }
                
                if let name = placeMark.name, let city = placeMark.locality, let zipCode = placeMark.postalCode, let state = placeMark.administrativeArea, let country = placeMark.country {
                    self.searchBar.text = "\(name), \(city) \(zipCode), \(state), \(country)"
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.4) {
            self.showPin = true
        }

        return annotationView
    }
}


// MARK: Search Bar
extension SelectLocationVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            showPin = true
        } else {
            showPin = false
            mapPinImageView.isHidden = true
        }
        searchTextDelegate?.textChanged(newString: searchText)
    }
}


// MARK: Search complete delegate
extension SelectLocationVC: SearchHelperComplete {
    func establishmentSelected(establishment: Establishment) { return }
    
    func searchFound(search: MKLocalSearchCompletion) {
        locationHasBeenSelected = true
        let addressFound = "\(search.title) \(search.subtitle)"
        searchBar.endEditing(true)
        searchBar.text = addressFound
        mapView.removeAnnotations(mapView.annotations)
        
        geoCoder.geocodeAddressString(addressFound) { [weak self] (placeMarks, error) in
            guard let self = self else { return }

            guard let placeMarks = placeMarks, let first = placeMarks.first, let location = first.location?.coordinate else {
                self.showMessage("Unable to locate address")
                return
            }
            let annotation = MKPointAnnotation()
            annotation.title = search.title
            annotation.coordinate = location
            self.mapView.addAnnotation(annotation)
            self.mapView.setRegionAroundAnnotation(annotation: annotation, distance: 2000, animated: true)

        }
        
    }
}

