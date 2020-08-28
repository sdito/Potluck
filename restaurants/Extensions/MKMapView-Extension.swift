//
//  MKMapView-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 7/2/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import MapKit

extension MKMapView {
    
    func setRegionAroundAnnotation(annotation: MKPointAnnotation, distance: Int = 7500, animated: Bool = false) {
        let meterSize = CLLocationDistance(exactly: distance)!
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: meterSize, longitudinalMeters: meterSize)
        self.setRegion(region, animated: animated)
    }
    
    func handleMapZooming(distanceFromTop: CGFloat, distanceFromBottom: CGFloat, pointToCheck: CLLocationCoordinate2D, aboveExactCenter: Bool) {
        let mapRect = self.region
        
        let spanHeight = CGFloat(mapRect.span.latitudeDelta)
        let spanWidth = CGFloat(mapRect.span.longitudeDelta)
        let center = mapRect.center

        let actualViewHeight = self.bounds.height
        
        let topToRemoveRatio = distanceFromTop / actualViewHeight
        let bottomToRemoveRatio = distanceFromBottom / actualViewHeight
        
        let topSpanToRemove = spanHeight * topToRemoveRatio
        let bottomSpanToRemove = spanHeight * bottomToRemoveRatio
        
        let newMapHeight = spanHeight - topSpanToRemove - bottomSpanToRemove
        
        // need to get the new center now
        var originalCoordinateLatitude = center.latitude
        originalCoordinateLatitude += Double(bottomSpanToRemove) / 2.0
        originalCoordinateLatitude -= Double(topSpanToRemove) / 2.0
        
        let newCenterCoordinate = CLLocationCoordinate2D(latitude: originalCoordinateLatitude, longitude: center.longitude)
        
        let paddingPercent: CGFloat = 0.8
        let newSpan = MKCoordinateRegion(center: newCenterCoordinate, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(newMapHeight * paddingPercent),
                                                                                             longitudeDelta: CLLocationDegrees(spanWidth * paddingPercent)))
        /*
        print("\n")
        print("Top ratio: \(topToRemoveRatio), Bottom ratio: \(bottomToRemoveRatio)")
        print("Top to remove: \(topSpanToRemove), Bottom to remove: \(bottomSpanToRemove)")
        print("Span height: \(spanHeight)")
        print("Centers: new: \(newSpan.center.latitude), old: \(mapRect.center.latitude)")
        print("Height: new: \(newSpan.span.latitudeDelta), old: \(mapRect.span.latitudeDelta)")
        print("Coordinates: \(pointToCheck.latitude), \(pointToCheck.longitude)")
        */
        
        // Span should  be good here, now need to figure out if the new point is in the span
        
        // Horizontal
        let minimumLongitude = newSpan.center.longitude - newSpan.span.longitudeDelta / 2.0
        let maximumLongitude = newSpan.center.longitude + newSpan.span.longitudeDelta / 2.0
        
        // Vertical
        let minimumLatitude = newSpan.center.latitude - newSpan.span.latitudeDelta / 2.0
        let maximumLatitude = newSpan.center.latitude + newSpan.span.latitudeDelta / 2.0
        
        let inLongitude = minimumLongitude...maximumLongitude ~= pointToCheck.longitude
        let inLatitude = minimumLatitude...maximumLatitude ~= pointToCheck.latitude
        
        // Some slight issues with horizontal
        // Need to bring them all in by lets say 20%, just alter the span
        
        if !inLongitude || !inLatitude {
            if !aboveExactCenter {
                // set to the exact middle of the map
                self.setCenter(pointToCheck, animated: true)
            } else {
                // child is being shown, show it a little above the center
                // change the center Y coordinate to be in the upper top middle region
                // 37.9547500610352 is an example latitude coordinate
                let latitudeSpan = self.region.span.latitudeDelta
                let quarterDifference = latitudeSpan * 0.2
                let newPointToCheck = CLLocationCoordinate2D(latitude: pointToCheck.latitude - quarterDifference, longitude: pointToCheck.longitude)
                self.setCenter(newPointToCheck, animated: true)
            }
        }
    }
    
    func centerOnLocation(locationManager: CLLocationManager, distanceAway: CLLocationDistance = 7000) {
        let location = locationManager.location?.coordinate ?? .simulatorDefault
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: distanceAway, longitudinalMeters: distanceAway)
        self.setRegion(region, animated: true)
        
    }
    
    func deselectAllAnnotations() {
        self.annotations.forEach { (annotation) in
            self.deselectAnnotation(annotation, animated: true)
        }
    }
    
    
    func showRestaurants(_ newRestaurants: [Restaurant], fitInTopHalf: Bool) {
        var newAnnotations: [MKAnnotation] = []
        for (index, restaurant) in newRestaurants.enumerated() {
            let newAnnotation = RestaurantAnnotation(restaurant: restaurant, place: index + 1)
            newAnnotations.append(newAnnotation)
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
