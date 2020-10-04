//
//  UserProfileVC.swift
//  restaurants
//
//  Created by Steven Dito on 10/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import MapKit

class UserProfileVC: UIViewController {
    
    private var person: Person?
    private var profile: Person.Profile?
    
    private let mapView = MKMapView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.navigationItem.title = person?.username
        getPersonData()
        setUpMap()
    }
    
    init(person: Person) {
        super.init(nibName: nil, bundle: nil)
        self.person = person
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpMap() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mapView)
        mapView.constrain(.top, to: self.view, .top)
        mapView.constrain(.leading, to: self.view, .leading)
        mapView.constrain(.trailing, to: self.view, .trailing)
        mapView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.35).isActive = true
        mapView.register(RestaurantAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.delegate = self
    }
    
    private func getPersonData() {
        Network.shared.getPersonProfile(person: person) { [weak self] (response) in
            guard let self = self else { return }
            switch response {
            case .success(let profile):
                self.profile = profile
                self.setUpWithProfile(profile: profile)
            case .failure(_):
                print("Failed getting profile")
            }
        }
    }
    
    private func setUpWithProfile(profile: Person.Profile) {
        DispatchQueue.main.async {
            if let establishments = profile.establishments {
                for establishment in establishments {

                    let annotation = RestaurantAnnotation(establishment: establishment)
                    self.mapView.addAnnotation(annotation)
                }
                self.mapView.fitAllAnnotations(newAnnotations: self.mapView.annotations, fitInTopHalf: false, animated: false)
            }
        }
    }
}


// MARK: Map view
extension UserProfileVC: MKMapViewDelegate {
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            mapView.deselectAnnotation(view.annotation, animated: true)
        }
        
        #warning("need to set up establishment ID based on curr user ID")
        
        guard let restaurantView = view as? RestaurantAnnotationView, let establishment = restaurantView.establishment else { return }
        let establishmentDetail = EstablishmentDetailVC(establishment: establishment, delegate: nil, mode: .fullScreenBase)
        self.navigationController?.pushViewController(establishmentDetail, animated: true)
        
    }
}
