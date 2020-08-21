//
//  MapLocationView.swift
//  restaurants
//
//  Created by Steven Dito on 8/20/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import MapKit

class MapLocationView: UIView {
    
    private var mapView = MKMapView()
    
    private var locationTitle: String?
    private var coordinate: CLLocationCoordinate2D?
    private var address: String?
    
    init(locationTitle: String, coordinate: CLLocationCoordinate2D?, address: String?) {
        super.init(frame: .zero)
        self.coordinate = coordinate
        self.address = address
        self.locationTitle = locationTitle
        setUpMap()
        setUpLocation()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpMap() {
        self.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = false
        mapView.isUserInteractionEnabled = false
        mapView.delegate = self
        self.addSubview(mapView)
        mapView.constrainSides(to: self)
    }
    
    private func setUpLocation() {
        
        let annotation = MKPointAnnotation()
        annotation.title = locationTitle ?? "Location"
        
        if let coordinate = coordinate {
            
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            mapView.setCenter(coordinate, animated: false)
        } else if let address = address {
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address) { [weak self] (placeMarks, error) in
                guard let self = self else { return }
                guard let placeMarks = placeMarks, let first = placeMarks.first else {
                    print("Not able to locate restaurant")
                    return
                }
                guard let location = first.location?.coordinate else {
                    print("Not able to get coordinate from location")
                    return
                }
                annotation.coordinate = location
                self.mapView.addAnnotation(annotation)
                self.mapView.setCenter(location, animated: false)
            }
        } else {
            fatalError("Need to have either a coordinate or an address")
        }
        
        
        
    }
    
}


extension MapLocationView: MKMapViewDelegate {
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
