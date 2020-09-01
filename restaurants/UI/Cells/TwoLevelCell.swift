//
//  TwoLevelCell.swift
//  restaurants
//
//  Created by Steven Dito on 8/27/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import CoreLocation

class TwoLevelCell: UITableViewCell {
    
    private var name: String?
    private var address: String?
    private var coordinate: CLLocationCoordinate2D?
    
    private let mainLabel = UILabel()
    private let secondLabel = UILabel()
    private let actionButton = SizeChangeButton(sizeDifference: .medium, restingColor: Colors.main, selectedColor: Colors.main)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpLabels()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpLabels() {
        mainLabel.font = .largerBold
        mainLabel.textColor = .label
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        secondLabel.font = .smallerThanNormal
        secondLabel.textColor = .secondaryLabel
        secondLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [mainLabel, secondLabel])
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 3.0
    
        stackView.constrain(.leading, to: self, .leading, constant: 20.0)
        stackView.constrain(.top, to: self, .top, constant: 10.0)
        stackView.constrain(.bottom, to: self, .bottom, constant: 10.0)
        
        stackView.axis = .vertical
        stackView.alignment = .leading
        
        // add the action button
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setImage(.mapImage, for: .normal)
        actionButton.tintColor = Colors.locationColor
        self.addSubview(actionButton)
        
        actionButton.constrain(.leading, to: stackView, .trailing, constant: 5.0)
        actionButton.constrain(.trailing, to: self, .trailing, constant: 20.0)
        actionButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        actionButton.equalSides()
        actionButton.addTarget(self, action: #selector(mapButtonSelected), for: .touchUpInside)
    }
    
    private func resetValues() {
        name = nil
        address = nil
        coordinate = nil
    }
    
    func setUpWith(main: String, secondary: String) {
        resetValues()
        mainLabel.text = main
        secondLabel.text = secondary
        self.address = secondary
        self.name = main
    }
    
    func setUpWith(establishment: Establishment) {
        resetValues()
        mainLabel.text = establishment.name
        
        if let locationDistance = establishment.locationInMilesFromCurrentLocation {
            secondLabel.text = locationDistance
        } else if let address = establishment.displayAddress {
            secondLabel.text = address
        } else if establishment.isRestaurant {
            secondLabel.text = "Restaurant"
        } else {
            secondLabel.text = "My place"
        }
        
        self.coordinate = establishment.coordinate
        self.address = establishment.displayAddress
        self.name = establishment.name
    }
    
    func setUpWith(restaurant: Restaurant) {
        resetValues()
        mainLabel.text = restaurant.name
        secondLabel.text = restaurant.distance?.convertMetersToMiles() ?? restaurant.address.displayAddress?.joined(separator: ", ") ?? "Can't find location"
        self.coordinate = restaurant.coordinate
        self.name = restaurant.name
    }
    
    @objc private func mapButtonSelected() {
        if let vc = self.findViewController() {
            if coordinate != nil || address != nil {
                let mapLocationView = MapLocationView(locationTitle: name ?? "Location", coordinate: coordinate, address: address, userInteractionEnabled: true, wantedDistance: 1000)
                mapLocationView.equalSides(size: UIScreen.main.bounds.width * 0.8)
                mapLocationView.layer.cornerRadius = 25.0
                mapLocationView.clipsToBounds = true
                let newVc = ShowViewVC(newView: mapLocationView)
                newVc.modalPresentationStyle = .overFullScreen
                vc.navigationController?.present(newVc, animated: false, completion: nil)
                
            } else {
                vc.showMessage("No location", on: vc)
            }
        }
    }
    
    
    
}
