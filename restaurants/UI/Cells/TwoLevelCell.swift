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
    private var establishment: Establishment?
    
    private let mainLabel = UILabel()
    private let secondLabel = UILabel()
    private let stackView = UIStackView()
    private let actionButton = SizeChangeButton(sizeDifference: .medium, restingColor: Colors.main, selectedColor: Colors.main)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpLabels()
        setUpButtons()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpLabels() {
        mainLabel.font = .largerBold
        mainLabel.textColor = .label
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        mainLabel.numberOfLines = 2
        secondLabel.font = .smallerThanNormal
        secondLabel.textColor = .secondaryLabel
        secondLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(mainLabel)
        stackView.addArrangedSubview(secondLabel)
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 3.0
    
        stackView.constrain(.leading, to: contentView, .leading, constant: 20.0)
        stackView.constrain(.top, to: contentView, .top, constant: 10.0)
        stackView.constrain(.bottom, to: contentView, .bottom, constant: 10.0)
        
        stackView.axis = .vertical
        stackView.alignment = .leading
        
        
    }
    
    private func setUpButtons() {
        // add the action button
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.tintColor = Colors.locationColor
        self.addSubview(actionButton)
        
        actionButton.constrain(.leading, to: stackView, .trailing, constant: 5.0)
        actionButton.constrain(.trailing, to: contentView, .trailing, constant: 20.0)
        actionButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        actionButton.equalSides()
        actionButton.addTarget(self, action: #selector(actionButtonSelected), for: .touchUpInside)
        
    }
    
    private func resetValues() {
        name = nil
        address = nil
        coordinate = nil
        establishment = nil
    }
    
    func setUpWith(main: String, secondary: String, showButton: Bool = true) {
        resetValues()
        mainLabel.text = main
        secondLabel.text = secondary
        self.address = secondary
        self.name = main
        
        if showButton {
            mapButton()
        }
    }
    
    func setUpWith(establishment: Establishment, showButton: Bool = true) {
        resetValues()
        self.establishment = establishment
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
        
        if showButton {
            detailButton()
        }
        
    }
    
    func setUpWith(restaurant: Restaurant) {
        resetValues()
        mainLabel.text = restaurant.name
        secondLabel.text = restaurant.distance?.convertMetersToMiles() ?? restaurant.address.displayAddress?.joined(separator: ", ") ?? "Can't find location"
        self.coordinate = restaurant.coordinate
        self.name = restaurant.name
        mapButton()
    }
    
    private func mapButton() {
        self.actionButton.setImage(.mapImage, for: .normal)
        self.actionButton.tintColor = Colors.locationColor
    }
    
    private func detailButton() {
        self.actionButton.setImage(.detailImage, for: .normal)
        self.actionButton.tintColor = Colors.main
    }
    
    @objc private func actionButtonSelected() {
        if let vc = self.findViewController() {
            
            if let establishment = establishment {
                let establishmentDetailVC = EstablishmentDetailVC(establishment: establishment, delegate: nil, mode: .fullScreenHeaderAndMap)
                vc.present(establishmentDetailVC, animated: true, completion: nil)
            } else {
                if coordinate != nil || address != nil {
                    let mapLocationView = MapLocationView(locationTitle: name ?? "Location", coordinate: coordinate, address: address)
                    mapLocationView.equalSides(size: UIScreen.main.bounds.width * 0.8)
                    mapLocationView.layer.cornerRadius = 25.0
                    mapLocationView.clipsToBounds = true
                    
                    let newVc = ShowViewVC(newView: mapLocationView, mode: .middle)
                    newVc.modalPresentationStyle = .overFullScreen
                    vc.navigationController?.present(newVc, animated: false, completion: nil)
                    
                } else {
                    vc.showMessage("No location", on: vc)
                }
            }
        }
    }
    
    
    
}
