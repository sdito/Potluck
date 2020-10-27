//
//  MKMapView-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 7/2/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import MapKit

extension MKMapView {
    
    func changeMapZoomLevel(factor: Double) {
        let previousRegion = self.region
        let previousSpan = previousRegion.span
        let newSpan = MKCoordinateSpan(latitudeDelta: previousSpan.latitudeDelta * factor, longitudeDelta: previousSpan.longitudeDelta * factor)
        let newRegion = MKCoordinateRegion(center: previousRegion.center, span: newSpan)
        self.setRegion(newRegion, animated: true)
    }
    
    func getCenterLocation() -> CLLocation {
        let latitude = self.centerCoordinate.latitude
        let longitude = self.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func setRegionAroundAnnotation(annotation: MKPointAnnotation, distance: Int = 7500, animated: Bool = false) {
        setRegionAroundCoordinate(coordinate: annotation.coordinate, distance: distance, animated: animated)
        
    }
    
    func setRegionAroundCoordinate(coordinate: CLLocationCoordinate2D, distance: Int, animated: Bool) {
        let meterSize = CLLocationDistance(exactly: distance)!
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: meterSize, longitudinalMeters: meterSize)
        self.setRegion(region, animated: animated)
    }
    
    func getVisibleMapRectForObstructedMapView(distanceFromTop: CGFloat, distanceFromBottom: CGFloat) -> MKMapRect {
        let span = self.getMapCoordinateRegionForObstructedMapView(distanceFromTop: distanceFromTop, distanceFromBottom: distanceFromBottom)
        let topLeft = CLLocationCoordinate2D(latitude: span.center.latitude + (span.span.latitudeDelta/2), longitude: span.center.longitude - (span.span.longitudeDelta/2))
        let bottomRight = CLLocationCoordinate2D(latitude: span.center.latitude - (span.span.latitudeDelta/2), longitude: span.center.longitude + (span.span.longitudeDelta/2))

        let a = MKMapPoint(topLeft)
        let b = MKMapPoint(bottomRight)

        return MKMapRect(origin: MKMapPoint(x:min(a.x,b.x), y:min(a.y,b.y)), size: MKMapSize(width: abs(a.x-b.x), height: abs(a.y-b.y)))
    }
    
    private func getMapCoordinateRegionForObstructedMapView(distanceFromTop: CGFloat, distanceFromBottom: CGFloat, paddingPercent: CGFloat = 1.0) -> MKCoordinateRegion {
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
        
        let newSpan = MKCoordinateRegion(center: newCenterCoordinate, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(newMapHeight * paddingPercent),
                                                                                             longitudeDelta: CLLocationDegrees(spanWidth * paddingPercent)))
        return newSpan
    }
    
    func handleMapZooming(distanceFromTop: CGFloat, distanceFromBottom: CGFloat, pointToCheck: CLLocationCoordinate2D, aboveExactCenter: Bool) {
        
        let newSpan = self.getMapCoordinateRegionForObstructedMapView(distanceFromTop: distanceFromTop, distanceFromBottom: distanceFromBottom, paddingPercent: 0.8)
        
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
    
    func centerOnLocation(locationManager: CLLocationManager, distanceAway: CLLocationDistance = 7000, animated: Bool = true) {
        let location = locationManager.location?.coordinate ?? .simulatorDefault
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: distanceAway, longitudinalMeters: distanceAway)
        self.setRegion(region, animated: animated)        
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
    
    private func getZoomRectForMapViewAnnotations(annotations: [MKAnnotation]) -> MKMapRect {
        var zoomRect = MKMapRect.null
        for annotation in annotations {
            
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1);
            zoomRect = zoomRect.union(pointRect);
        }
        return zoomRect
    }
    
    func getAnnotationBoundsFarthestDistance() -> CLLocationDistance {
        #warning("need to remove the annotation from the user's location")
        let zoomRect = getZoomRectForMapViewAnnotations(annotations: self.annotations)
        let mapRegion = MKCoordinateRegion(zoomRect)
        
        let span = mapRegion.span
        let center = mapRegion.center
            
        let loc1 = CLLocation(latitude: center.latitude - span.latitudeDelta * 0.5, longitude: center.longitude)
        let loc2 = CLLocation(latitude: center.latitude + span.latitudeDelta * 0.5, longitude: center.longitude)
        let loc3 = CLLocation(latitude: center.latitude, longitude: center.longitude - span.longitudeDelta * 0.5)
        let loc4 = CLLocation(latitude: center.latitude, longitude: center.longitude + span.longitudeDelta * 0.5)
            
        let mLatitude = loc1.distance(from: loc2)
        let mLongitude = loc3.distance(from: loc4)
        
        let length = sqrt((mLatitude * mLatitude) + (mLongitude * mLongitude))
        return CLLocationDistance(length)
    }
    
    func fitAllAnnotations(newAnnotations: [MKAnnotation], fitInTopHalf: Bool, animated: Bool = true) {
        if newAnnotations.count > 0 {
            var zoomRect = self.getZoomRectForMapViewAnnotations(annotations: newAnnotations)
            if fitInTopHalf {
                zoomRect.size.height = zoomRect.size.height * 2
                self.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 20, left: 50, bottom: 100, right: 50), animated: animated)
            } else {
                self.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 120, right: 50), animated: animated)
            }
        }
    }
    
    func trueFitAllAnnotations(annotations: [MKAnnotation], animated: Bool) {
        if annotations.count > 0 {
            var zoomRect = MKMapRect.null
            for annotation in annotations {
                let annotationPoint = MKMapPoint(annotation.coordinate)
                let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1);
                zoomRect = zoomRect.union(pointRect);
            }
            
            // i.e. if there is only one or two annotations close together, this will enable it to not be zoomed in too much
            let minimumSize: Double = 5000.0
            
            if zoomRect.width <= minimumSize && zoomRect.height <= minimumSize {
                // need to calculate my own origin
                print("width: \(zoomRect.width), height: \(zoomRect.height)")
                let oldOrigin = zoomRect.origin
                let newOrigin = MKMapPoint(x: oldOrigin.x - ((minimumSize - zoomRect.width)/2.0), y: oldOrigin.y - ((minimumSize - zoomRect.height)/2.0))
                
                let largerMapRect = MKMapRect(origin: newOrigin, size: MKMapSize(width: minimumSize, height: minimumSize))
                self.setVisibleMapRect(largerMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: animated)
                
            } else {
                self.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: animated)
            }
        }
    }
    
    func updateAllAnnotationZoom(topHalf: Bool) {
        // need to remove userLocation else zooming will include it when not desired
        // test in the future if self.nonUserAnnotations actually works as expected
        fitAllAnnotations(newAnnotations: self.nonUserAnnotations, fitInTopHalf: topHalf)
    }
    
    
    var nonUserAnnotations: [MKAnnotation] {
        return self.annotations.filter({$0 !== self.userLocation})
    }
}
