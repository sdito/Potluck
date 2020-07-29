//
//  MKMapView-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 7/2/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//



import MapKit

extension MKMapView {

    
    func centerOnLocation(locationManager: CLLocationManager) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 7_000, longitudinalMeters: 7_000)
            self.setRegion(region, animated: true)
        }
    }
    
    func deselectAllAnnotations() {
        self.annotations.forEach { (annotation) in
            self.deselectAnnotation(annotation, animated: true)
        }
    }
    
    
    func showRestaurants(_ newRestaurants: [Restaurant], fitInTopHalf: Bool, coordinateForNonUserLocationSearch: CLLocationCoordinate2D?) {
        var newAnnotations: [MKAnnotation] = []
        for (index, restaurant) in newRestaurants.enumerated() {
            let newAnnotation = RestaurantAnnotation(restaurant: restaurant, place: index + 1)
            newAnnotations.append(newAnnotation)
        }
        
        if let coordinateForNonUserLocationSearch = coordinateForNonUserLocationSearch {
            let searchAnnotation = MKPointAnnotation()
            searchAnnotation.title = "Search location"
            searchAnnotation.coordinate = coordinateForNonUserLocationSearch
            newAnnotations.append(searchAnnotation)
        }
        
        self.addAnnotations(newAnnotations)
        self.fitAllAnnotations(newAnnotations: newAnnotations, fitInTopHalf: fitInTopHalf)
    }
    
    func fitAllAnnotations(newAnnotations: [MKAnnotation], fitInTopHalf: Bool) {
        var zoomRect = MKMapRect.null
        for annotation in newAnnotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1);
            zoomRect = zoomRect.union(pointRect);
        }
        if fitInTopHalf {
            zoomRect.size.height = zoomRect.size.height * 2
            self.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 20, left: 50, bottom: 100, right: 50), animated: true)
        } else {
            self.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 120, right: 50), animated: true)
        }
    }
    
    func updateAllAnnotationZoom(topHalf: Bool) {
        let annotations = self.annotations.filter({$0 !== self.userLocation}) // need to remove userLocation else zooming will include it when not desired
        fitAllAnnotations(newAnnotations: annotations, fitInTopHalf: topHalf)
    }
    
}
