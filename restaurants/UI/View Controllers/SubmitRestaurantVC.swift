//
//  SubmitRestaurantVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/18/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import MapKit

class SubmitRestaurantVC: UIViewController {
    
    private var allowChanges = true
    private var previousScrollOffset: CGFloat = .zero
    private var containerViewHeightAnchor: NSLayoutConstraint!
    private var containerViewBaseHeight: CGFloat!
    private var maxHeight: CGFloat!
    private var selectedPhotos: [ImageSelectorVC.ImageInfo] = []
    
    private let nameLabel = UILabel()
    private let addressLabel = UILabel()
    private let containerView = UIView()
    
    private var nameRawValue: String?
    private var addressRawValue: String?
    private var establishment: Establishment?
    private var restaurant: Restaurant?
    private var mode: Mode?
    
    init(rawValues: (name: String, address: String)?, establishment: Establishment?, restaurant: Restaurant?) {
        self.nameRawValue = rawValues?.name
        self.addressRawValue = rawValues?.address
        self.establishment = establishment
        self.restaurant = restaurant
        if rawValues != nil {
            mode = .rawValue
        } else if establishment != nil {
            mode = .establishment
        } else if restaurant != nil {
            mode = .restaurant
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    enum Mode {
        case rawValue
        case establishment
        case restaurant
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUpLabels()
        setUpMap()
        setUpChildView()
        setUpImageSelector()
        findAssociatedRestaurant()
        setUpNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setUpNavigationBar() {
        let submit = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitPressed))
        navigationItem.rightBarButtonItem = submit
    }
    
    private func setUpLabels() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.numberOfLines = 0
        nameLabel.text = nameRawValue ?? restaurant?.name ?? establishment?.name ?? "Restaurant name"
        nameLabel.font = .createdTitle
        self.view.addSubview(nameLabel)
        nameLabel.constrain(.leading, to: view, .leading, constant: 10.0)
        nameLabel.constrain(.trailing, to: view, .trailing, constant: 10.0)
        nameLabel.constrain(.top, to: view, .top, constant: 10.0)
        
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.numberOfLines = 0
        addressLabel.text = addressRawValue ?? establishment?.displayAddress ?? restaurant?.address.displayAddress?.joined(separator: ", ") ?? "No address"
        addressLabel.font = .largerBold
        addressLabel.textColor = .secondaryLabel
        self.view.addSubview(addressLabel)
        addressLabel.constrain(.top, to: nameLabel, .bottom, constant: 5.0)
        addressLabel.constrain(.leading, to: view, .leading, constant: 10.0)
        addressLabel.constrain(.trailing, to: view, .trailing, constant: 10.0)
    }
    
    private func setUpMap() {
        
        guard let mode = mode else { return }
        
        var name: String = "Restaurant"
        var coordinate: CLLocationCoordinate2D?
        var address: String?
        
        switch mode {
        case .rawValue:
            name = nameRawValue ?? "Restaurant"
            address = addressRawValue
        case .establishment:
            guard let establishment = establishment else { return }
            name = establishment.name
            address = establishment.displayAddress
            coordinate = establishment.coordinate
            
        case .restaurant:
            guard let restaurant = restaurant else { return }
            name = restaurant.name
            address = restaurant.address.displayAddress?.joined(separator: ", ")
            coordinate = restaurant.coordinate
        }
        
        let map = MapLocationView(locationTitle: name, coordinate: coordinate, address: address)
        self.view.addSubview(map)
        map.constrain(.top, to: addressLabel, .bottom, constant: 10.0)
        map.constrain(.leading, to: self.view, .leading)
        map.constrain(.trailing, to: self.view, .trailing)
        map.heightAnchor.constraint(equalToConstant: 150.0).isActive = true
    }
    
    private func setUpChildView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerView)
        containerViewBaseHeight = self.view.bounds.height * 0.45
        maxHeight = self.view.bounds.height * 0.75
        containerViewHeightAnchor = containerView.heightAnchor.constraint(equalToConstant: containerViewBaseHeight!)
        containerViewHeightAnchor?.isActive = true
        containerView.constrain(.bottom, to: self.view, .bottom)
        containerView.constrain(.leading, to: self.view, .leading)
        containerView.constrain(.trailing, to: self.view, .trailing)
        containerView.backgroundColor = .tertiarySystemBackground
        
    }
    
    private func setUpImageSelector() {
        let vc = ImageSelectorVC()
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(vc)
        containerView.addSubview(vc.view)
        vc.view.constrainSides(to: containerView)
        vc.didMove(toParent: self)
        vc.delegate = self
    }
    
    @objc private func submitPressed() {
        print("Need to submit")
    }
    
    private func findAssociatedRestaurant() {
        
        if let mode = mode, mode == .rawValue {
            Network.shared.getRestaurantFromPartialData(name: nameRawValue!, fullAddress: addressRawValue!) { (result) in
                print(result)
                #warning("need to actually use")
            }
        }
        
    }
}


extension SubmitRestaurantVC: ImageSelectorDelegate {
    
    func scrollViewContentOffset(scrollView: UIScrollView) {
        if allowChanges {
            let scrollingMultiplier: CGFloat = 1.5
            let scrollDiff = (scrollView.contentOffset.y - self.previousScrollOffset) * scrollingMultiplier
            let absoluteTop: CGFloat = 0
            let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
            let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
            let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
            var newHeight = self.containerViewHeightAnchor.constant
            if isScrollingDown {
                newHeight = min(self.maxHeight, self.containerViewHeightAnchor.constant + abs(scrollDiff))
            } else if isScrollingUp {
                newHeight = max(self.containerViewBaseHeight, self.containerViewHeightAnchor.constant - abs(scrollDiff))
            }
            if newHeight != self.containerViewHeightAnchor.constant {
                allowChanges = false
                
                if isScrollingDown {
                    let difference = newHeight - self.containerViewHeightAnchor.constant
                    scrollView.contentOffset.y -= difference
                    self.containerViewHeightAnchor.constant = newHeight
                } else if isScrollingUp {
                    if scrollView.contentOffset.y < 10.0 {
                        self.containerViewHeightAnchor.constant = newHeight
                    }
                }
                allowChanges = true
            }
            previousScrollOffset = scrollView.contentOffset.y
        }
    }
    
    func photosUpdated(to selectedPhotos: [ImageSelectorVC.ImageInfo]) {
        self.selectedPhotos = selectedPhotos
        print(self.selectedPhotos.map({$0.indexPath.row}))
        
    }
}
