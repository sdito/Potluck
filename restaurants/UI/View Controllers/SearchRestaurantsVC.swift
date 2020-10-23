//
//  SearchRestaurantsVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/1/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import MapKit


protocol SearchCompleteDelegate: class {
    func newSearchCompleted(searchType: Network.YelpCategory, locationText: String?)
}


class SearchRestaurantsVC: UIViewController {
    
    weak var delegate: SearchCompleteDelegate!
    
    private var previousLocationSearches: [String] = []
    private var searchType: Network.YelpCategory!
    private var searchLocation: String!
    
    private var tableViewDisplay: TableViewDisplay = .none
    private var locationResults: [String] = []
    private var searchTypeResults: Network.YelpCategories = Network.commonSearches
    
    private let cellReuseIdentifier: String = "reuseIdentifierSR"
    private let searchBarHeight: CGFloat = 50.0
    
    private var searchTypeSearchBar = UISearchBar()
    private var locationSearchBar = UISearchBar()
    private var tableView: UITableView?
    private var request = MKLocalSearchCompleter()
    private var startWithLocation = false
    private var tableViewConstraintsLaidOut = false
    private var deviceCurrentAndMapLocations: [String] {
        if UIDevice.completeLocationEnabled() {
            return [.currentLocation, .mapLocation]
        } else {
            return [.mapLocation]
        }
    }
    
    private enum TableViewDisplay {
        case searchType
        case location
        case none
    }
    
    init(searchType: Network.YelpCategory?, searchLocation: String?, control: UIViewController, startWithLocation: Bool) {
        self.searchType = searchType ?? ("restaurants", "Restaurants")
        self.searchLocation = searchLocation ?? .currentLocation
        self.delegate = control as? SearchCompleteDelegate
        self.startWithLocation = startWithLocation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.navigationItem.title = "Search"
        self.navigationController?.navigationBar.tintColor = Colors.main
        setUpTopSearchBars()
        setUpTableView()
        setUpExecuteSearch()
        setUpSearchCompleter()
        previousLocationSearches = UIDevice.readRecentLocationSearchesFromUserDefaults()
        locationResults = deviceCurrentAndMapLocations + previousLocationSearches
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.edgesForExtendedLayout = [.bottom]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.setNavigationBarColor()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        locationSearchBar.resignFirstResponder()
        searchTypeSearchBar.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !tableViewConstraintsLaidOut {
            tableViewConstraintsLaidOut = true
            setUpTableViewConstraints()
        }
        
        // if set up before viewDidAppear then it make the presenting extremely slow
        if startWithLocation {
            locationSearchBar.becomeFirstResponder()
        } else {
            searchTypeSearchBar.becomeFirstResponder()
        }
    }
    
    private func setUpTopSearchBars() {
        
        searchTypeSearchBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(searchTypeSearchBar)
        
        NSLayoutConstraint.activate([
            searchTypeSearchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            searchTypeSearchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            searchTypeSearchBar.topAnchor.constraint(equalTo: self.view.topAnchor),
            searchTypeSearchBar.heightAnchor.constraint(equalToConstant: searchBarHeight)
        ])
        
        
        locationSearchBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(locationSearchBar)
        
        NSLayoutConstraint.activate([
            locationSearchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            locationSearchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            locationSearchBar.topAnchor.constraint(equalTo: searchTypeSearchBar.bottomAnchor),
            locationSearchBar.heightAnchor.constraint(equalToConstant: searchBarHeight)
        ])
        
        searchTypeSearchBar.setImage(.bookImage, for: .search, state: .normal)
        locationSearchBar.setImage(.locationImage, for: .search, state: .normal)
        
        searchTypeSearchBar.placeholder = "Restaurant type"
        locationSearchBar.placeholder = "Location"
        
        searchTypeSearchBar.text = searchType.title
        locationSearchBar.text = searchLocation
        
        [searchTypeSearchBar, locationSearchBar].forEach({ (bar) in
            bar.delegate = self
            bar.searchTextField.font = .mediumBold
        })
        
        
        self.view.hero.id = .searchBarTransitionType
        
    }
    
    private func setUpTableView() {
        
        tableView = UITableView()
        tableView!.translatesAutoresizingMaskIntoConstraints = false
        tableView!.delegate = self
        tableView!.dataSource = self
        
        tableView!.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView!.tableFooterView = UIView()
        
        self.view.addSubview(tableView!)
        
        
    }
    
    private func setUpTableViewConstraints() {
        NSLayoutConstraint.activate([
            tableView!.topAnchor.constraint(equalTo: locationSearchBar.bottomAnchor),
            tableView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func setUpExecuteSearch() {
        // lets see how a bar button item is instead
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(executeSearch))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    
    private func setUpSearchCompleter() {
        
        request.resultTypes = .query
        /*
         possibilities
         
           .airport, .amusementPark, .aquarium, .atm, .bakery, .bank, .beach, .brewery, .cafe, .campground, .carRental, .evCharger, .fireStation,
           .fitnessCenter, .foodMarket, .gasStation, .hospital, .hotel, .laundry, .library, .marina, .movieTheater, .museum, .nationalPark,
           .nightlife, .park, .parking, .pharmacy, .police, .postOffice, .publicTransport, .restaurant, .restroom, .school, .stadium, .store,
           .theater, .university, .winery, .zoo
         */
    
        request.pointOfInterestFilter = .init(including: [.airport, .beach, .campground, .publicTransport])
        request.delegate = self
    }
    
    
    @objc private func executeSearch() {
        self.navigationController?.popViewController(animated: true)
        
        if searchLocation != .currentLocation && searchLocation != .mapLocation {
            if !previousLocationSearches.contains(searchLocation) {
                if previousLocationSearches.count > 10 {
                    previousLocationSearches.removeLast()
                }
                UserDefaults.standard.set([searchLocation] + previousLocationSearches, forKey: .recentLocationSearchesKey)
            }
            
        }
        
        delegate.newSearchCompleted(searchType: searchType, locationText: searchLocation)
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
        var cellText: NSAttributedString {
            switch tableViewDisplay {
            case .searchType:
                return NSAttributedString(string: searchTypeResults[indexPath.row].title)
            case .location:
                let locationText = locationResults[indexPath.row]
                if locationText == .currentLocation {
                    return locationText.addImageAtBeginning(image: .locationImage, color: Colors.locationColor)
                } else if locationText == .mapLocation {
                    return locationText.addImageAtBeginning(image: .mapImage, color: Colors.locationColor)
                } else {
                    return NSAttributedString(string: locationText)
                }
                
            case .none:
                return NSAttributedString()
            }
        }
        cell.textLabel?.attributedText = cellText
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch tableViewDisplay {
        case .searchType:
            let newText = searchTypeResults[indexPath.row]
            searchType = newText
            searchTypeSearchBar.text = newText.title
            searchTypeSearchBar.endEditing(true)
        case .location:
            let newText = locationResults[indexPath.row]
            searchLocation = newText
            locationSearchBar.text = newText
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
                bar.endEditing(true)
            }
        }
    }
    
}

// MARK: MKLocalSearchCompleterDelegate
extension SearchRestaurantsVC: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        locationResults = completer.results.map({"\($0.title) \($0.subtitle)"})
        
        locationResults.insert(.mapLocation, at: 0)
        if UIDevice.completeLocationEnabled() {
            locationResults.insert(.currentLocation, at: 0)
        }
        
        if tableViewDisplay == .location {
            tableView?.reloadData()
        }
    }
}


// MARK: UISearchBarDelegate
extension SearchRestaurantsVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        if searchBar === locationSearchBar {
            tableViewDisplay = .location
            searchBar.text = ""
        } else if searchBar == searchTypeSearchBar {
            tableViewDisplay = .searchType
        } else {
            tableViewDisplay = .none
        }
        
        tableView?.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar === locationSearchBar {
            if locationSearchBar.text == "" {
                locationSearchBar.text = searchLocation
            }
        }
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
                
                let matched = searchTypeResults.filter({$0.title.lowercased() == lowerSearchText})
                if matched.count > 0 {
                    searchType = matched[0]
                } else {
                    searchType = (alias: nil, title: searchText)
                }
                // if contains, set to with the alias, else set with alias as nil, always with title to searchType
                
                
            } else {
                searchTypeResults = Network.commonSearches
            }
            
            
        case .location:
            if searchText != "" {
                request.queryFragment = searchText
                searchLocation = searchText
            } else {
                locationResults = deviceCurrentAndMapLocations + previousLocationSearches
            }
            
            
        case .none:
            break
        }
        tableView?.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        executeSearch()
    }
    
}
