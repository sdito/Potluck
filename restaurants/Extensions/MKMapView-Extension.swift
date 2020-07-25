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
    
    func showRestaurants(_ newRestaurants: [Restaurant]) {
        var newAnnotations: [RestaurantAnnotation] = []
        for (index, restaurant) in newRestaurants.enumerated() {
            let newAnnotation = RestaurantAnnotation(restaurant: restaurant, place: index + 1)
            newAnnotations.append(newAnnotation)
        }
        
        self.addAnnotations(newAnnotations)
        self.fitAllAnnotations(newAnnotations: newAnnotations)
    }
    
    func fitAllAnnotations(newAnnotations: [RestaurantAnnotation]) {
        
        var zoomRect = MKMapRect.null
        for annotation in newAnnotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1);
            zoomRect = zoomRect.union(pointRect);
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
        
    }
    
    func getCenterAfterAnimation(centerFound: @escaping (CLLocationCoordinate2D) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            centerFound(self.region.center)
        }
    }
    
}
