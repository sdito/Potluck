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
    
    init(estimatedSize: CGSize, locationTitle: String, coordinate: CLLocationCoordinate2D?, address: String?) {
        super.init(frame: .zero)
        self.coordinate = coordinate
        self.address = address
        self.locationTitle = locationTitle
        setUpMap()
        self.setUpLocation(size: estimatedSize)

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
    
    private func setUpLocation(size: CGSize) {
        
        if let coordinate = coordinate {
            setUpSnapshot(with: coordinate, size: size)
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
                self.setUpSnapshot(with: location, size: size)
            }
        } else {
            fatalError("Need to have either a coordinate or an address")
        }
        
    }
    
    func setUpSnapshot(with coordinate: CLLocationCoordinate2D, size: CGSize) {
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: CLLocationDistance(wantedDistance), longitudinalMeters: CLLocationDistance(wantedDistance))
        options.size = size
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
                let image = snapshot.image
                
                UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
                image.draw(at: CGPoint.zero)

                var point = snapshot.point(for: coordinate)
                let img = UIImage.mapPinImage.withTintColor(Colors.main).withConfiguration(UIImage.SymbolConfiguration(pointSize: 30.0))
                point.x = point.x - (img.size.width / 2)
                point.y = point.y - (img.size.height / 2)
                img.draw(at: point)
                
                let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                self?.imageView.appEndSkeleton()
                self?.imageView.image = compositeImage
            }
        }
    }
    
    func updateLocation(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        imageView.appStartSkeleton()
        setUpLocation(size: self.bounds.size)
    }
    
    
    
    
}

