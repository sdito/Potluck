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
    
    var previousRestaurants: [(name: String, address: String)] = []
    
    private let searchBar = UISearchBar()
    private let cancelButton = SizeChangeButton(sizeDifference: .medium, restingColor: Colors.secondary, selectedColor: Colors.main)
    private let tableView = UITableView()
    private let segmentedControl = UISegmentedControl()
    private let requestCompleter = MKLocalSearchCompleter()
    private let reuseIdentifier = "cell-reuse-identifier"
    
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
        cancelButton.constrain(.top, to: self.view, .top, constant: 30.0)
        cancelButton.constrain(.leading, to: self.view, .leading, constant: 10.0)
        cancelButton.addTarget(self, action: #selector(remove), for: .touchUpInside)
        
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    private func setUpRequest() {
        requestCompleter.resultTypes = .pointOfInterest
        requestCompleter.pointOfInterestFilter = .init(including: [.restaurant])
        requestCompleter.delegate = self
    }
    
    
    
    @objc private func remove() {
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: Table view
extension AddRestaurantVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        let cellInfo = searchResults[indexPath.row]
        cell.textLabel?.text = cellInfo.name
        cell.detailTextLabel?.text = cellInfo.address
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellInfo = searchResults[indexPath.row]
        self.navigationController?.pushViewController(SubmitRestaurantVC(name: cellInfo.name, address: cellInfo.address), animated: true)
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
