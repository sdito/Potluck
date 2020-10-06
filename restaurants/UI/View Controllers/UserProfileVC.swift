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
    
    var text = "Do any additional setup after loading the view, typically from a nib."
    private var person: Person?
    private var profile: Person.Profile?
    
    private let mapView = MKMapView()
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private var collectionView: UICollectionView?
    private let reuseIdentifier = "userProfileReuseIdentifier"
    private let padding: CGFloat = 3.0
    private let mapRatio: CGFloat = 0.35
    private var collectionViewTop: NSLayoutConstraint?
    private var mapViewHeight: CGFloat?
    
    private var previousScrollOffset: CGFloat = 0.0
    private var allowChanges = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.navigationItem.title = person?.username
        getPersonData()
        setUpMap()
        setUpCollectionView()
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
        mapView.layoutIfNeeded()
    }
    
    private func setUpCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = padding
        let size = (self.view.frame.width / 2) - padding/2
        
        layout.itemSize = CGSize(width: size, height: size + 30.0)
        
        //layout.estimatedItemSize.height = UICollectionViewFlowLayout.automaticSize.height
        layout.minimumInteritemSpacing = 0.0
        
        collectionView?.showsVerticalScrollIndicator = false
        collectionView!.translatesAutoresizingMaskIntoConstraints = false
        collectionView!.delegate = self
        collectionView!.dataSource = self
        self.view.addSubview(collectionView!)
        collectionView!.constrain(.leading, to: self.view, .leading)
        collectionView!.constrain(.trailing, to: self.view, .trailing)
        collectionView!.constrain(.bottom, to: self.view, .bottom)
        collectionViewTop = collectionView!.constrain(.top, to: mapView, .bottom)
        collectionView!.register(ProfileCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
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
                self.mapView.trueFitAllAnnotations(annotations: self.mapView.annotations, animated: false)
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
        guard let restaurantView = view as? RestaurantAnnotationView, let establishment = restaurantView.establishment else { return }
        let establishmentDetail = EstablishmentDetailVC(establishment: establishment, delegate: nil, mode: .fullScreenBase)
        self.navigationController?.pushViewController(establishmentDetail, animated: true)
    }
}

// MARK: Collection view
extension UserProfileVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProfileCell
        
        return cell
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if allowChanges {
            allowChanges = false
            
            if mapViewHeight == nil {
                mapViewHeight = mapView.frame.height - 10.0
            }
            guard let mapViewHeight = mapViewHeight, let collectionViewTop = collectionViewTop else { return }
            if scrollView == collectionView {
                let offset = scrollView.contentOffset.y
                let difference = previousScrollOffset - offset
                let potentialNewTop = collectionViewTop.constant + difference
                let topRange = -mapViewHeight...0.0
                
                if topRange ~= potentialNewTop {
                    collectionViewTop.constant = potentialNewTop
                    scrollView.contentOffset.y += difference
                    previousScrollOffset = scrollView.contentOffset.y
                    let alpha = 1 - (-potentialNewTop/mapViewHeight)
                    mapView.alpha = alpha
                } else {
                    if potentialNewTop < -mapViewHeight {
                        mapView.alpha = 0.0
                        collectionViewTop.constant = -mapViewHeight
                    } else {
                        mapView.alpha = 1.0
                        collectionViewTop.constant = 0.0
                    }
                }
            }
            allowChanges = true
        }
    }
}


