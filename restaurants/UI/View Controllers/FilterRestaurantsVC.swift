//
//  FilterRestaurantsVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/11/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class FilterRestaurantsVC: UIViewController {
    
    private let headerContainer = UIView()
    private let headerLabel = PaddingLabel(top: 0, bottom: 0, left: 8, right: 8)
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let spacer = SpacerView(size: 1, orientation: .vertical)
    
    private let cancelTag = 2
    private let resetTag = 3
    
    enum Sections: String, CaseIterable {
        case price = "Price"
        case attributes = "Attributes"
        case hours = "Hours"
        
        var parameterKey: String? {
            switch self {
            case .price:
                return "price"
            case .attributes:
                return "attributes"
            case .hours:
                return nil
            }
        }
        
        var cellTitleAlias: [(title: String, alias: String?)] {
            switch self {
            case .price:
                return [("$", "1"), ("$$", "2"), ("$$$", "3"), ("$$$$", "4")]
            case .attributes:
                return [("Hot and new", "hot_and_new"),
                        ("Reservation", "reservation"),
                        ("Waitlist reservation", "waitlist_reservation"),
                        ("Gender neutral restrooms", "gender_neutral_restrooms"),
                        ("Cashback", "cashback"),
                        ("Open to all", "open_to_all"),
                        ("Wheelchair accessible", "wheelchair_accessible")]
            case .hours:
                return [("Open now", "open_now"), ("Open at", "open_at")]
            }
        }
    }
    
    private func requiresSpecialCollection(section: Sections) -> (() -> [String:Any])? {
        switch section {
        case .price:
            return nil
        case .attributes:
            return nil
        case .hours:
            return hoursCollection
        }
    }
    
    private func hoursCollection() -> [String:Any] {
        return ["Special":"Hours"]
    }
    
    private func collectFilters() -> [String:Any] {
        var newParams: [String:Any] = [:]
        for section in Sections.allCases {
            if let special = requiresSpecialCollection(section: section) {
                let params = special()
                print("Params from special: \(params.keys.first!)")
            } else {
                print("Not special: \(section.parameterKey)")
            }
        }
        return newParams
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUpHeadPortion()
        setUpTableView()
    }
    
    private func setUpHeadPortion() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        
        let cancelButton = SizeChangeButton(sizeDifference: .medium, restingColor: Colors.secondary, selectedColor: Colors.main)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.tag = cancelTag
        cancelButton.titleLabel?.font = .largerBold
        stackView.addArrangedSubview(cancelButton)
        cancelButton.addTarget(self, action: #selector(cancelOrResetPressed(sender:)), for: .touchUpInside)
        cancelButton.titleEdgeInsets.left = 20.0
        cancelButton.contentHorizontalAlignment = .left
        
        let resetButton = SizeChangeButton(sizeDifference: .medium, restingColor: Colors.secondary, selectedColor: Colors.main)
        resetButton.setTitle("Reset", for: .normal)
        resetButton.tag = resetTag
        resetButton.titleLabel?.font = .largerBold
        stackView.addArrangedSubview(resetButton)
        resetButton.addTarget(self, action: #selector(cancelOrResetPressed(sender:)), for: .touchUpInside)
        resetButton.titleEdgeInsets.right = 20.0
        resetButton.contentHorizontalAlignment = .right
        
        cancelButton.widthAnchor.constraint(equalTo: resetButton.widthAnchor).isActive = true
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text = "Filter"
        headerLabel.font = .createdTitle
        headerLabel.textAlignment = .center
        headerLabel.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        headerLabel.backgroundColor = .secondarySystemBackground
        headerLabel.layer.cornerRadius = 5.0
        headerLabel.clipsToBounds = true
        
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(headerLabel)
        headerLabel.constrainSides(to: headerContainer)
        
        stackView.insertArrangedSubview(headerContainer, at: 1)
    
        self.view.addSubview(stackView)
        
        stackView.constrain(.top, to: self.view, .top, constant: 10.0)
        stackView.constrain(.leading, to: self.view, .leading)
        stackView.constrain(.trailing, to: self.view, .trailing)
        
        
        self.view.addSubview(spacer)
        
        spacer.constrain(.top, to: stackView, .bottom, constant: 5.0)
        spacer.constrain(.leading, to: self.view, .leading)
        spacer.constrain(.trailing, to: self.view,  .trailing)
    }
    
    private func setUpTableView() {
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.constrain(.top, to: spacer, .bottom)
        tableView.constrain(.leading, to: view, .leading)
        tableView.constrain(.trailing, to: view, .trailing)
        tableView.constrain(.bottom, to: view, .bottom)
        
        tableView.allowsMultipleSelection = true
    }
    
    @objc private func cancelOrResetPressed(sender: UIButton) {
        let tag = sender.tag
        if tag == cancelTag {
            //self.dismiss(animated: true, completion: nil)
            collectFilters()
        } else {
            headerContainer.removeNotificationStyleText()
            tableView.indexPathsForVisibleRows?.forEach({ (indexPath) in
                tableView.deselectRow(at: indexPath, animated: true)
            })
        }
    }
}


extension FilterRestaurantsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Sections.allCases[section].rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Sections.allCases[section].cellTitleAlias.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = Sections.allCases[indexPath.section].cellTitleAlias[indexPath.row].title
        cell.accessoryView = UIImageView(image: .unchecked, highlightedImage: .checked)
        cell.accessoryView?.tintColor = Colors.main
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for selectedIndexPath in selectedIndexPaths {
                if selectedIndexPath.section == indexPath.section && Sections.allCases[indexPath.section] != .attributes {
                    tableView.deselectRow(at: selectedIndexPath, animated: true)
                }
            }
        }
        return indexPath
    }
    
    private func handleShowingNotificationLabel() {
        headerContainer.removeNotificationStyleText()
        if let count = tableView.indexPathsForSelectedRows?.count {
            headerContainer.showNotificationStyleText(str: "\(count)")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleShowingNotificationLabel()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        handleShowingNotificationLabel()
    }
    
}
