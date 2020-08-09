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
    private var searchTypeResults: Network.YelpCategories = []
    
    private let cellReuseIdentifier: String = "reuseIdentifierSR"
    private let searchBarHeight: CGFloat = 50.0
    private let currentLocation = "Current location"
    
    private var searchTypeSearchBar: UISearchBar!
    private var locationSearchBar: UISearchBar!
    private var tableView: UITableView!
    private var request: MKLocalSearchCompleter!
    
    private enum TableViewDisplay {
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
        setUpOverlaySearchButton()
        setUpSearchCompleter()
        locationResults = [currentLocation]
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
        locationSearchBar.setImage(<#T##iconImage: UIImage?##UIImage?#>, for: <#T##UISearchBar.Icon#>, state: <#T##UIControl.State#>)
        
        
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
    
    private func setUpOverlaySearchButton() {
        let overlayButton = OverlayButton()
        overlayButton.setTitle("Find restaurants", for: .normal)
        self.view.addSubview(overlayButton)
        
        NSLayoutConstraint.activate([
            overlayButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            overlayButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30.0)
        ])
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
            return searchTypeResults.count
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
                return searchTypeResults[indexPath.row].title
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
        tableView.deselectRow(at: indexPath, animated: true)
        switch tableViewDisplay {
        case .searchType:
            #warning("need to complete")
            searchTypeSearchBar.text = searchTypeResults[indexPath.row].title
            searchTypeSearchBar.endEditing(true)
        case .location:
            locationSearchBar.text = locationResults[indexPath.row]
            locationSearchBar.endEditing(true)
        case .none:
            break
        }
        tableViewDisplay = .none
        tableView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            [locationSearchBar, searchTypeSearchBar].forEach { (bar) in
                if let bar = bar {
                    bar.endEditing(true)
                }
            }
        }
    }
    
}

// MARK: MKLocalSearchCompleterDelegate
extension SearchRestaurantsVC: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        locationResults = completer.results.map({"\($0.title) \($0.subtitle)"})
        locationResults.insert(currentLocation, at: 0)
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
        switch tableViewDisplay {
        case .searchType:
            let lowerSearchText = searchText.lowercased()
            if searchText != "" {

                var filteredResults: Network.YelpCategories = []
                
                for element in Network.shared.yelpCategories {
                    let lowerText = element.title.lowercased()
                    if lowerText.contains(lowerSearchText) {
                        filteredResults.append(element)
                    }
                }
                searchTypeResults = filteredResults
                
            } else {
                searchTypeResults = []
            }
        case .location:
            if searchText != "" {
                request.queryFragment = searchText
            } else {
                locationResults = [currentLocation]
            }
        case .none:
            break
        }
        tableView.reloadData()
    }
    
}
