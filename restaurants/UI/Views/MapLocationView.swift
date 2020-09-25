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
    
    private let imageView = UIImageView()
    private var locationTitle: String?
    private var coordinate: CLLocationCoordinate2D?
    private var address: String?
    private var wantedDistance = 4000
    
    
    var mapAlpha: CGFloat {
        return imageView.alpha
    }
    
    init(locationTitle: String, coordinate: CLLocationCoordinate2D?, address: String?) {
        super.init(frame: .zero)
        self.coordinate = coordinate
        self.address = address
        self.locationTitle = locationTitle
        setUpMap()
        
        
        
        #warning("this is really bad")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.setUpLocation()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    private func setUpMap() {
        self.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        imageView.constrainSides(to: self)
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        imageView.appStartSkeleton()
    }
    
    func setAlpha(_ value: CGFloat) {
        self.imageView.alpha = value
    }
    
    private func setUpLocation() {
        
        if let coordinate = coordinate {
            setUpSnapshot(with: coordinate)
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
                self.setUpSnapshot(with: location)
            }
        } else {
            fatalError("Need to have either a coordinate or an address")
        }
        
    }
    
    func setUpSnapshot(with coordinate: CLLocationCoordinate2D) {
        
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: CLLocationDistance(wantedDistance), longitudinalMeters: CLLocationDistance(wantedDistance))
        options.size = imageView.frame.size
        options.scale = UIScreen.main.scale
        options.pointOfInterestFilter = .init(excluding: [.restaurant, .cafe])
        options.traitCollection = self.traitCollection
        
        let snapshotter = MKMapSnapshotter(options: options)

        snapshotter.start(with: .global(qos: .userInteractive)) { [weak self] (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Snapshot error: \(String(describing: error))")
                return
            }
            
            DispatchQueue.main.async {
                let pin = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
                let image = snapshot.image
                
                UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
                image.draw(at: CGPoint.zero)

                var point = snapshot.point(for: coordinate)
                
                point.x = point.x + pin.centerOffset.x - (pin.bounds.size.width / 2)
                point.y = point.y + pin.centerOffset.y - (pin.bounds.size.height / 2)
                
                pin.image?.draw(at: point)
                
                let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                self?.imageView.appEndSkeleton()
                self?.imageView.image = compositeImage
            }
        }
    }
    
    func updateLocation(coordinate: CLLocationCoordinate2D) {
        #warning("would need to do")
        self.coordinate = coordinate
        imageView.appStartSkeleton()
        setUpLocation()
    }
    
    
    
    
}

