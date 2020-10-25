//
//  EstablishmentCell.swift
//  restaurants
//
//  Created by Steven Dito on 10/13/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import CoreLocation

class EstablishmentCell: UITableViewCell {
    
    var establishment: Establishment?
    
    private let stackView = UIStackView()
    private let mainLabel = UILabel()
    private let detailLabel = UILabel()
    private let mapButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUiElements()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUpWith(establishment: Establishment?) {
        self.establishment = establishment
        guard let establishment = establishment else { return }
        mainLabel.text = establishment.name
        
        let option1 = establishment.displayAddress
        var option2: String? {
            if let date = establishment.firstVisited?.dateString(style: .medium) {
                return "First visited on \(date)"
            }
            return nil
        }
        
        detailLabel.text = option1 ?? option2
    }
    
    private func setUpUiElements() {
        setUpStackView()
        setUpMainLabel()
        setUpDetailLabel()
        setUpMapButton()
    }
    
    private func setUpStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5.0
        stackView.distribution = .fill
        stackView.alignment = .leading
        self.contentView.addSubview(stackView)
        
        stackView.constrain(.leading, to: self.contentView, .leading, constant: 20.0)
        stackView.constrain(.top, to: self.contentView, .top, constant: 12.5)
        stackView.constrain(.bottom, to: self.contentView, .bottom, constant: 12.5)
    }
    
    private func setUpMainLabel() {
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        mainLabel.font = .secondaryTitle
        mainLabel.textColor = .label
        mainLabel.text = "Establishment name here"
        stackView.addArrangedSubview(mainLabel)
    }
    
    private func setUpDetailLabel() {
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.font = .largerBold
        detailLabel.textColor = .secondaryLabel
        detailLabel.text = "Detail text"
        stackView.addArrangedSubview(detailLabel)
    }
    
    private func setUpMapButton() {
        mapButton.translatesAutoresizingMaskIntoConstraints = false
        mapButton.setImage(.mapImage, for: .normal)
        mapButton.tintColor = Colors.locationColor
        self.contentView.addSubview(mapButton)
        mapButton.constrain(.leading, to: stackView, .trailing, constant: 10.0)
        mapButton.constrain(.trailing, to: self.contentView, .trailing, constant: 20.0)
        mapButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        mapButton.addTarget(self, action: #selector(mapButtonAction), for: .touchUpInside)
    }
    
    @objc private func mapButtonAction() {
        guard let establishment = establishment else { return }
        self.findViewController()?.showMapDetail(locationTitle: establishment.name, coordinate: establishment.coordinate, address: establishment.displayAddress)
    }
    
}
