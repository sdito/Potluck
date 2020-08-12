//
//  MapCutoutView.swift
//  restaurants
//
//  Created by Steven Dito on 7/8/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation



protocol MapCutoutViewDelegate: class {
    func locationPressed(name: String, destination: CLLocationCoordinate2D)
}



class MapCutoutView: UIView {
    
    weak var delegate: MapCutoutViewDelegate!
    private var restaurant: Restaurant?
    private let locationManager = CLLocationManager()
    private var mapView = MKMapView()
    
    init(userLocation: CLLocationCoordinate2D, userDestination: CLLocationCoordinate2D, restaurant: Restaurant, vc: UIViewController) {
        super.init(frame: .zero)
        self.delegate = vc as? MapCutoutViewDelegate
        self.restaurant = restaurant
        setUp(userLocation: userLocation, userDestination: userDestination, restaurant: restaurant)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUp(userLocation: CLLocationCoordinate2D, userDestination: CLLocationCoordinate2D, restaurant: Restaurant) {
        self.translatesAutoresizingMaskIntoConstraints = false
        setUpMapView()
        showMarksAndRoute(current: userLocation, destination: userDestination)
        addAnnotationForDestination(destination: userDestination, restaurant: restaurant)
        handlePressingMap()
    }
    
    private func setUpMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(mapView)
        mapView.constrainSides(to: self)
        mapView.heightAnchor.constraint(equalToConstant: 200.0).isActive = true
    }

    private func showMarksAndRoute(current: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: current, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let unwrappedResponse = response else { return }
            
            if let route = unwrappedResponse.routes.first, self != nil {
                let travelTime = route.expectedTravelTime
                self!.addTimeLabel(time: travelTime)
                self!.mapView.addOverlay(route.polyline)
                self!.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 30.0, left: 30.0, bottom: 30.0, right: 30.0), animated: false)
            }
        }
    }
    
    private func addAnnotationForDestination(destination: CLLocationCoordinate2D, restaurant: Restaurant) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = destination
        annotation.title = restaurant.name
        mapView.addAnnotation(annotation)
    }
    
    private func handlePressingMap() {
        // lay a button over on top of the view
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        mapView.addSubview(button)
        button.constrainSides(to: mapView)
        button.addTarget(self, action: #selector(mapButtonPressed), for: .touchUpInside)
    }
    
    private func addTimeLabel(time: TimeInterval) {
        let label = PaddingLabel(top: 2.0, bottom: 2.0, left: 5.0, right: 5.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = time.displayForSmallerTimes()
        label.font = .mediumBold
        label.textColor = .white
        label.fadedBackground()
        mapView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -5.0),
            label.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -5.0)
        ])
        
    }
    
    @objc private func mapButtonPressed() {
        if let restaurant = restaurant {
            delegate.locationPressed(name: restaurant.name, destination: restaurant.coordinate)
        }
    }
}


extension MapCutoutView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = .systemBlue
        return renderer
    }
}
