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
    private var imageView = UIImageView()
    private let height: CGFloat = 200.0
    private let options = MKMapSnapshotter.Options()
    
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
        setUpImageView()
        handlePressingMap()
        handleDirections(currentLocation: userLocation, destination: userDestination)
    }
    
    private func setUpImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        imageView.constrainSides(to: self)
        imageView.heightAnchor.constraint(equalToConstant: height).isActive = true
        imageView.backgroundColor = .systemBackground
        imageView.appStartSkeleton()
    }

    
    private func handleDirections(currentLocation: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [weak self] response, error in
            guard let self = self else { return }
            guard let response = response else {
                self.imageView.appEndSkeleton()
                return
            }
            
            self.stepImagesFromDirectionsResponse(response: response) { [weak self] (stepImage, timeInterval) in
                DispatchQueue.main.async {
                    self?.imageView.appEndSkeleton()
                    self?.imageView.image = stepImage
                    self?.addTimeLabel(time: timeInterval)
                }
            }
        }
        
    }
    
    func stepImagesFromDirectionsResponse(response: MKDirections.Response, completionHandler: @escaping (_ image: UIImage?, _ timeInterval: TimeInterval?) -> Void) {
        
        guard let route = response.routes.first else {
            completionHandler(nil, nil)
            return
        }
    
        var boundingRect = route.polyline.boundingMapRect
        boundingRect = boundingRect.insetBy(dx: -boundingRect.width * 0.2, dy: -boundingRect.height * 0.2)
        
        options.region = MKCoordinateRegion(boundingRect)
        options.size = CGSize(width: UIScreen.main.bounds.width, height: height)
        options.traitCollection = self.traitCollection
        options.scale = UIScreen.main.scale
        options.pointOfInterestFilter = .init(excluding: [.restaurant, .cafe])
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start(with: .global(qos: .userInteractive)) { snapshot, error in
            
            guard let snapshot = snapshot else {
                return
            }
            
            let image = snapshot.image
            
            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
            image.draw(at: CGPoint.zero)
            
            // draw the path
            guard let c = UIGraphicsGetCurrentContext() else {
                return
            }
            c.setStrokeColor(UIColor.systemBlue.cgColor)
            c.setLineWidth(4)
            c.beginPath()
            for step in route.steps {
                let coordinates: UnsafeMutablePointer<CLLocationCoordinate2D> = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: step.polyline.pointCount)
                defer { coordinates.deallocate() }
                
                step.polyline.getCoordinates(coordinates, range: NSRange(location: 0, length: step.polyline.pointCount))
                
                for i in 0 ..< step.polyline.pointCount {
                    let p = snapshot.point(for: coordinates[i])
                    if i == 0 {
                        c.move(to: p)
                    } else {
                        c.addLine(to: p)
                    }
                }
            }
            c.strokePath()
            
            let visibleRect = CGRect(origin: CGPoint.zero, size: image.size)
            
            for mapItem in [response.source, response.destination]
                where mapItem.placemark.location != nil {
                var point = snapshot.point(for: mapItem.placemark.location!.coordinate)
                if visibleRect.contains(point) {
                    let isDestination = mapItem.isEqual(response.source)
                    
                    var img: UIImage {
                        if isDestination {
                            return UIImage.mapPinImage.withTintColor(Colors.main)
                        } else {
                            return UIImage.mapPinLocationImage.withTintColor(Colors.main)
                        }
                    }
                    
                    point.x = point.x - (img.size.width / 2)
                    point.y = point.y - (img.size.height / 2)
                    img.draw(at: point)
                    
                }
            }
            
            let stepImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            completionHandler(stepImage, route.expectedTravelTime)
        }
    }
    
    private func handlePressingMap() {
        // lay a button over on top of the view
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        self.addSubview(button)
        button.constrainSides(to: self)
        button.addTarget(self, action: #selector(mapButtonPressed), for: .touchUpInside)
    }
    
    private func addTimeLabel(time: TimeInterval?) {
        guard let time = time else { return }
        let label = PaddingLabel(top: 2.0, bottom: 2.0, left: 5.0, right: 5.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = time.displayForSmallerTimes()
        label.font = .mediumBold
        label.textColor = .white
        label.fadedBackground()
        self.addSubview(label)
        
        label.constrain(.trailing, to: self, .trailing, constant: 5.0)
        label.constrain(.bottom, to: self, .bottom, constant: 5.0)
        
    }
    
    @objc private func mapButtonPressed() {
        if let restaurant = restaurant {
            delegate.locationPressed(name: restaurant.name, destination: restaurant.coordinate)
        }
    }
}

