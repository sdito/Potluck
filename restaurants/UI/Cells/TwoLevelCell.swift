//
//  TwoLevelCell.swift
//  restaurants
//
//  Created by Steven Dito on 8/27/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class TwoLevelCell: UITableViewCell {
    
    private let mainLabel = UILabel()
    private let secondLabel = UILabel()
    
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
    
        stackView.constrain(.leading, to: self, .leading, constant: 30.0)
        stackView.constrain(.trailing, to: self, .trailing, constant: 30.0)
        stackView.constrain(.top, to: self, .top, constant: 10.0)
        stackView.constrain(.bottom, to: self, .bottom, constant: 10.0)
        
        stackView.axis = .vertical
        stackView.alignment = .leading
        
    }
    
    func setUpWith(main: String, secondary: String) {
        mainLabel.text = main
        secondLabel.text = secondary
    }
    
    func setUpWith(establishment: Establishment) {
        mainLabel.text = establishment.name
        
        if let locationDistance = establishment.locationInMilesFromCurrentLocation {
            secondLabel.text = "\(locationDistance) miles away"
        } else if let address = establishment.displayAddress {
            secondLabel.text = address
        } else if establishment.isRestaurant {
            secondLabel.text = "Restaurant"
        } else {
            secondLabel.text = "My place"
        }
    }
    
}
