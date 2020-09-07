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
    private var establishments: [Establishment] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
        navigationItem.title = "Profile map"
        
        getRestaurantData()
        setUpMap()
        edgesForExtendedLayout = [.top, .left, .right]
    }
    
    private func getRestaurantData() {
        Network.shared.getUserEstablishments { (result) in
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
    
    private func setUpMap() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mapView)
        mapView.constrainSides(to: self.view)
        mapView.delegate = self
        mapView.register(RestaurantAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
}



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
        let detailVC = EstablishmentDetailVC(establishment: establishment, delegate: self)
        detailVC.view.translatesAutoresizingMaskIntoConstraints = false
        detailVC.view.heightAnchor.constraint(equalToConstant: childHeight).isActive = true
        mapView.handleMapZooming(distanceFromTop: 0.0, distanceFromBottom: childHeight, pointToCheck: viewAnnotation.coordinate, aboveExactCenter: true)
        self.showAddingChildFromBottom(child: detailVC, childHeight: childHeight)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        removeChildViewControllersFromBottom { (_) in return }
        
    }
    
}


extension ProfileMapVC: EstablishmentDetailDelegate {
    func detailDismissed() {
        mapView.deselectAllAnnotations()
    }
}
