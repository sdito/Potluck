//
//  SearchRestaurantsVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/1/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import MapKit

class SearchRestaurantsVC: UIViewController {
    
    private var tableViewDisplay: TableViewDisplay = .none
    
    private var locationResults: [String] = []
    
    private let cellReuseIdentifier: String = "reuseIdentifierSR"
    private let searchBarHeight: CGFloat = 50.0
    private var searchTypeSearchBar: UISearchBar!
    private var locationSearchBar: UISearchBar!
    private var tableView: UITableView!
    private var request: MKLocalSearchCompleter!
    
    private enum TableViewDisplay {
        #warning("need to use")
        case searchType
        case location
        case none
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.title = "Search"
        self.navigationController?.navigationBar.tintColor = Colors.main
        setUpTopSearchBars()
        setUpTableView()
        setUpSearchCompleter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setNavigationBarColor(color: Colors.navigationBarColor)
    }
    
    
    private func setUpTopSearchBars() {
        searchTypeSearchBar = UISearchBar()
        searchTypeSearchBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(searchTypeSearchBar)
        
        NSLayoutConstraint.activate([
            searchTypeSearchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            searchTypeSearchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            searchTypeSearchBar.topAnchor.constraint(equalTo: self.view.topAnchor),
            searchTypeSearchBar.heightAnchor.constraint(equalToConstant: searchBarHeight)
        ])
        
        
        locationSearchBar = UISearchBar()
        locationSearchBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(locationSearchBar)
        
        NSLayoutConstraint.activate([
            locationSearchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            locationSearchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            locationSearchBar.topAnchor.constraint(equalTo: searchTypeSearchBar.bottomAnchor),
            locationSearchBar.heightAnchor.constraint(equalToConstant: searchBarHeight)
        ])
        
        
        searchTypeSearchBar.delegate = self
        locationSearchBar.delegate = self
        
    }
    
    private func setUpTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: locationSearchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
    
    
    private func setUpSearchCompleter() {
        request = MKLocalSearchCompleter()
        request.resultTypes = .query
        // possibilities
        /*[.airport, .amusementPark, .aquarium, .atm, .bakery, .bank, .beach, .brewery, .cafe, .campground, .carRental, .evCharger, .fireStation,
           .fitnessCenter, .foodMarket, .gasStation, .hospital, .hotel, .laundry, .library, .marina, .movieTheater, .museum, .nationalPark,
           .nightlife, .park, .parking, .pharmacy, .police, .postOffice, .publicTransport, .restaurant, .restroom, .school, .stadium, .store,
           .theater, .university, .winery, .zoo,]) */
    
        request.pointOfInterestFilter = .init(including: [.airport, .beach, .campground, .publicTransport])
        request.delegate = self
    }
    
}

// MARK: Table view
extension SearchRestaurantsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableViewDisplay {
        case .searchType:
            return 30
        case .location:
            return locationResults.count
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)!
        var cellText: String {
            switch tableViewDisplay {
            case .searchType:
                return "Search type: \(indexPath.row)"
            case .location:
                return locationResults[indexPath.row]
            case .none:
                return ""
            }
        }
        cell.textLabel?.text = cellText
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        #warning("need to complete")
        
    }
    
}

// MARK: MKLocalSearchCompleterDelegate
extension SearchRestaurantsVC: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        locationResults = completer.results.map({"\($0.title) \($0.subtitle)"})
        if tableViewDisplay == .location {
            tableView.reloadData()
        }
        
    }
}


// MARK: UISearchBarDelegate
extension SearchRestaurantsVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar === locationSearchBar {
            tableViewDisplay = .location
        } else if searchBar == searchTypeSearchBar {
            tableViewDisplay = .searchType
        } else {
            tableViewDisplay = .none
        }
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            request.queryFragment = searchText
        } else {
            locationResults = []
            tableView.reloadData()
        }
    }
    
}
