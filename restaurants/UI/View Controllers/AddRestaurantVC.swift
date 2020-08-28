//
//  AddRestaurantVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/17/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import MapKit

class AddRestaurantVC: UIViewController {
    
    private let searchBar = UISearchBar()
    private let cancelButton = SizeChangeButton(sizeDifference: .medium, restingColor: Colors.secondary, selectedColor: Colors.main)
    private let tableView = UITableView()
    private let segmentedControl = UISegmentedControl()
    private let requestCompleter = MKLocalSearchCompleter()
    private let reuseIdentifier = "cell-reuse-identifier"
    
    private var initialLoadingDone = false {
        didSet {
            if currentSelectedSegment != .search {
                tableView.reloadData()
            }
        }
    }
    private var previousRestaurants: [Establishment] = []
    private var myPlaces: [Establishment] = []
    private var searchResults: [(name: String, address: String)] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var currentSelectedSegment: Segment {
        let currSelected = self.segmentedControl.selectedSegmentIndex
        return Segment.allCases[currSelected]
    }
    
    private enum Segment: String, CaseIterable {
        case search = "Search"
        case myPlaces = "My places"
        case previous = "Previous"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.tintColor = Colors.main
        self.setNavigationBarColor(color: Colors.navigationBarColor)
        setUpCancelButton()
        setUpSearchBar()
        setUpSearchOptions()
        setUpSearchTableView()
        setUpRequest()
        getInitialData()
        

    }
    
    @objc private func startMapToSelectLocation() {
        #warning("delete later")
        let vc = SelectLocationVC()
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    private func setUpCancelButton() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(cancelButton)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .largerBold
        cancelButton.constrain(.top, to: self.view, .top, constant: 50.0)
        cancelButton.constrain(.leading, to: self.view, .leading, constant: 10.0)
        cancelButton.addTarget(self, action: #selector(remove), for: .touchUpInside)
        
        #warning("delete later, just testing")
        let testButton = UIButton()
        testButton.translatesAutoresizingMaskIntoConstraints = false
        testButton.setTitleColor(Colors.main, for: .normal)
        testButton.setTitle("Test", for: .normal)
        testButton.addTarget(self, action: #selector(startMapToSelectLocation), for: .touchUpInside)
        self.view.addSubview(testButton)
        testButton.constrain(.top, to: self.view, .top, constant: 50.0)
        testButton.constrain(.trailing, to: self.view, .trailing, constant: 10.0)
        
    }
    
    private func setUpSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(searchBar)
        searchBar.constrain(.leading, to: self.view, .leading)
        searchBar.constrain(.top, to: cancelButton, .bottom)
        searchBar.constrain(.trailing, to: self.view, .trailing)
        searchBar.placeholder = "Restaurant name"
        searchBar.delegate = self
    }
    
    private func setUpSearchOptions() {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        for (i, segment) in Segment.allCases.enumerated() {
            segmentedControl.insertSegment(withTitle: segment.rawValue, at: i, animated: false)
        }
        
        self.view.addSubview(segmentedControl)
        segmentedControl.constrain(.top, to: searchBar, .bottom)
        segmentedControl.constrain(.leading, to: self.view, .leading, constant: 10.0)
        segmentedControl.constrain(.trailing, to: self.view, .trailing, constant: 10.0)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.mediumBold], for: .normal)
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
    }
    
    private func setUpSearchTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.constrain(.top, to: segmentedControl, .bottom)
        tableView.constrain(.leading, to: self.view, .leading)
        tableView.constrain(.trailing, to: self.view, .trailing)
        tableView.constrain(.bottom, to: self.view, .bottom)
        tableView.register(TwoLevelCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    private func setUpRequest() {
        requestCompleter.resultTypes = .pointOfInterest
        requestCompleter.pointOfInterestFilter = .init(including: [.restaurant])
        requestCompleter.delegate = self
    }
    
    private func getInitialData() {
        Network.shared.getUserEstablishments { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let establishments):
                for establishment in establishments {
                    if establishment.isRestaurant {
                        self.previousRestaurants.append(establishment)
                    } else {
                        self.myPlaces.append(establishment)
                    }
                }
                
                self.previousRestaurants.sortByName()
                self.myPlaces.sortByName()
                
                self.initialLoadingDone = true
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc private func remove() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func segmentedControlChanged() {
        tableView.reloadData()
        print(currentSelectedSegment)
    }
}


// MARK: Table view
extension AddRestaurantVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        tableView.restore()
        
        switch currentSelectedSegment {
        case .search:
            tableView.restore()
            return searchResults.count
        case .myPlaces:
            let count = myPlaces.count
            if count == 0 {
                if initialLoadingDone {
                    tableView.setEmptyWithAction(message: "No places added yet.", buttonTitle: "Add place")
                } else {
                    tableView.showLoadingOnTableView()
                }
                return 0
            } else {
                return count
            }
            
        case .previous:
            
            let count = previousRestaurants.count
            if count == 0 {
                if initialLoadingDone {
                    tableView.setEmptyWithAction(message: "No places previously visited yet.", buttonTitle: "Add visit")
                } else {
                    tableView.showLoadingOnTableView()
                }
                return 0
            } else {
                return count
            }
            
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TwoLevelCell
        
        switch currentSelectedSegment {
        case .search:
            let cellInfo = searchResults[indexPath.row]
            cell.setUpWith(main: cellInfo.name, secondary: cellInfo.address)
        case .myPlaces:
            let establishment = myPlaces[indexPath.row]
            cell.setUpWith(establishment: establishment)
        case .previous:
            let establishment = previousRestaurants[indexPath.row]
            cell.setUpWith(establishment: establishment)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellInfo = searchResults[indexPath.row]
        self.navigationController?.pushViewController(SubmitRestaurantVC(name: cellInfo.name, address: cellInfo.address), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if searchBar.isFirstResponder {
            searchBar.endEditing(true)
        }
    }
}

// MARK: Search bar
extension AddRestaurantVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        requestCompleter.queryFragment = searchText
    }
}

// MARK: MKLocalSearchCompleterDelegate
extension AddRestaurantVC: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let results = completer.results.map({($0.title, $0.subtitle)})
        
        searchResults = results
    }
}
