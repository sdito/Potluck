//
//  SearchHelperVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/28/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import MapKit

protocol SearchHelperDelegate: class {
    func textChanged(newString: String)
}

protocol SearchHelperComplete: class {
    func searchFound(search: MKLocalSearchCompletion)
    func establishmentSelected(establishment: Establishment)
}

class SearchHelperVC: UITableViewController {
    
    private var mode: Mode = .allLocations
    private weak var delegate: SearchHelperComplete?
    private let reuseIdentifier = "reuseIdentifierTwoLevelCell"
    private var requestCompleter = MKLocalSearchCompleter()
    private var searchResults: [MKLocalSearchCompletion] = []
    private var cellColor: UIColor?
    var establishments: [Establishment] = [] {
        didSet {
            handleUpdatingEstablishments()
        }
    }
    private var filteredEstablishments: [Establishment] = []
    private var recentQueryTerm: String = "" {
        didSet {
            handleUpdatingEstablishments()
        }
    }
    
    init(completionDelegate: SearchHelperComplete, mode: Mode, cellColor: UIColor? = nil, establishments: [Establishment] = []) {
        super.init(style: .plain)
        self.mode = mode
        self.delegate = completionDelegate
        self.cellColor = cellColor
        self.establishments = establishments
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    enum Mode {
        case allLocations
        case allLocationsAndEstablishments
        
        var numberOfSections: Int {
            switch self {
            case .allLocations:
                return 1
            case .allLocationsAndEstablishments:
                return 2
            }
        }
        
        func cellType(section: Int) -> (cellType: SectionType, title: String?) {
            switch self {
            case .allLocations:
                return (.location, nil)
            case .allLocationsAndEstablishments:
                if section == 0 {
                    return (.establishment, "Previously visited")
                } else {
                    return (.location, "Locations")
                }
            }
        }
        
        var locationSection: Int {
            switch self {
            case .allLocations:
                return 0
            case .allLocationsAndEstablishments:
                return 1
            }
        }
    }
    
    enum SectionType {
        case location
        case establishment
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        requestCompleter.resultTypes = .address
        requestCompleter.delegate = self
        self.tableView.register(TwoLevelCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.backgroundColor = .clear
        self.tableView.showsVerticalScrollIndicator = false
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return mode.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let cellType = mode.cellType(section: section).cellType
        switch cellType {
        case .location:
            return searchResults.count
        case .establishment:
            return filteredEstablishments.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mode.cellType(section: section).title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TwoLevelCell
        
        if let cellColor = cellColor {
            cell.backgroundColor = cellColor
        }
        
        let cellType = mode.cellType(section: indexPath.section).cellType
        switch cellType {
        case .location:
            let result = searchResults[indexPath.row]
            cell.setUpWith(main: result.title, secondary: result.subtitle, showButton: false)
        case .establishment:
            let result = filteredEstablishments[indexPath.row]
            cell.setUpWith(establishment: result, showButton: false)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        #warning("need to complete with establishment")
        
        let cellType = mode.cellType(section: indexPath.section).cellType
        
        switch cellType {
        case .establishment:
            let est = filteredEstablishments[indexPath.row]
            delegate?.establishmentSelected(establishment: est)
        case .location:
            let result = searchResults[indexPath.row]
            delegate?.searchFound(search: result)
        }
        
        
        self.tableView.isHidden = true
        self.tableView.layoutIfNeeded()
    }
    
    private func handleUpdatingEstablishments() {
        if mode == .allLocationsAndEstablishments {
            filteredEstablishments = establishments.filter({ (establishment) -> Bool in
                establishment.name.lowercased().contains(recentQueryTerm)
            })
            
            filteredEstablishments = filteredEstablishments.sorted(by: { (e1, e2) -> Bool in
                e1.name < e2.name
            })
            
            tableView.reloadSections(IndexSet([0]), with: .none)
        }
    }
    
    
}


// MARK: Search helper
extension SearchHelperVC: SearchHelperDelegate {
    func textChanged(newString: String) {
        
        if newString == "" {
            self.tableView.isHidden = true
        } else {
            self.tableView.isHidden = false
            requestCompleter.queryFragment = newString
            recentQueryTerm = newString.lowercased()
        }
    }
}

// MARK: MKLocalSearchCompleterDelegate
extension SearchHelperVC: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let results = completer.results
        searchResults = results
        
        let section = mode.locationSection
        tableView.reloadSections(IndexSet([section]), with: .none)
        
    }
}

