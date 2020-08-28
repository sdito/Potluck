//
//  SelectLocationVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/27/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import MapKit

class SelectLocationVC: UIViewController {
    
    private let topContainer = UIView()
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private let searchBar = UISearchBar()
    private let geoCoder = CLGeocoder()
    private weak var searchTextDelegate: SearchHelperDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .green
        setUpTopPortion()
        setUpTopPortionParts()
        setUpMap()
        setUpChildSearchHelper()
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
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        topContainer.addSubview(searchBar)
        searchBar.constrainSides(to: topContainer)
        searchBar.delegate = self
        searchBar.tintColor = Colors.main
        searchBar.placeholder = "Enter address"
        searchBar.autocapitalizationType = .words
        searchBar.searchTextField.adjustsFontSizeToFitWidth = true
        searchBar.searchTextField.minimumFontSize = 10.0
    }
    
    private func setUpMap() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        self.view.addSubview(mapView)
        mapView.constrain(.top, to: topContainer, .bottom)
        mapView.constrain(.leading, to: self.view, .leading)
        mapView.constrain(.trailing, to: self.view, .trailing)
        mapView.constrain(.bottom, to: self.view, .bottom)
        mapView.centerOnLocation(locationManager: locationManager, distanceAway: 15000)
    }
    
    private func setUpChildSearchHelper() {
        let vc = SearchHelperVC(completionDelegate: self, mode: .allLocations)
        self.addChild(vc)
        self.view.addSubview(vc.tableView)
        vc.didMove(toParent: self)
        searchTextDelegate = vc
        
        vc.tableView.constrain(.top, to: topContainer, .bottom)
        vc.tableView.constrain(.leading, to: self.view, .leading)
        vc.tableView.constrain(.trailing, to: self.view, .trailing)
        vc.tableView.constrain(.bottom, to: self.view, .bottom)
        
        searchTextDelegate?.textChanged(newString: "")
    }
}


// MARK: Map view
extension SelectLocationVC: MKMapViewDelegate {
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

        return annotationView
    }
}


// MARK: Search Bar
extension SelectLocationVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTextDelegate?.textChanged(newString: searchText)
    }
}


// MARK: Search complete delegate
extension SelectLocationVC: SearchHelperComplete {
    func searchFound(search: MKLocalSearchCompletion) {
        
        let addressFound = "\(search.title) \(search.subtitle)"
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

