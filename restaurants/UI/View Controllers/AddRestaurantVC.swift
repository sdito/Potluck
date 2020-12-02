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
    private let headerView = HeaderView(leftButtonTitle: "Cancel", rightButtonTitle: "", title: "Add Visit")
    private let tableView = UITableView()
    private let segmentedControl = UISegmentedControl()
    private let requestCompleter = MKLocalSearchCompleter()
    private let reuseIdentifier = "cell-reuse-identifier"
    private var searchOptionsStack: UIStackView!
    private let searchNormalTitle = "Restaurant name"
    private let myPlacesTitle = "New place name"
    private let myPlacesButton = SizeChangeButton(sizeDifference: .medium, restingColor: Colors.secondary, selectedColor: Colors.main)
    private var searchBarStack: UIStackView!
    private var overlayButton: UIButton?
    private var previousRestaurantsOnSearch = true
    private var previousSearchedRestaurants: [Restaurant] = []
    private var customPlaceSegment: Segment?
    private var customRestaurantName: String?
    
    private var initialLoadingDone = false {
        didSet {
            if currentSelectedSegment != .search {
                addRestaurantReloadTable()
            }
        }
    }
    private var previousRestaurants: [Establishment] = []
    private var myPlaces: [Establishment] = []
    private var searchResults: [(name: String, address: String)] = [] {
        didSet {
            addRestaurantReloadTable()
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
        setUpHeaderPortionWithCancel()
        setUpSearchOptions()
        setUpSearchTableView()
        setUpRequest()
        setUpCreateOwnRestaurantButton()
        getInitialData()
        previousSearchedRestaurants = Network.shared.previousSearchedRestaurants
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setUpHeaderPortionWithCancel() {
        self.view.addSubview(headerView)
        headerView.constrain(.top, to: self.view, .top, constant: 50.0)
        headerView.constrain(.leading, to: self.view, .leading)
        headerView.constrain(.trailing, to: self.view, .trailing)
        headerView.leftButton.addTarget(self, action: #selector(remove), for: .touchUpInside)
        
    }
    
    private func setUpSearchOptions() {
        
        myPlacesButton.translatesAutoresizingMaskIntoConstraints = false
        searchBarStack = UIStackView(arrangedSubviews: [searchBar, myPlacesButton])
        myPlacesButton.setTitle("Add", for: .normal)
        myPlacesButton.addTarget(self, action: #selector(myPlacesButtonAction), for: .touchUpInside)
        myPlacesButton.titleLabel?.font = .mediumBold
        
        myPlacesButton.isHidden = true
        
        searchBarStack.axis = .horizontal
        searchBarStack.distribution = .fill
        
        searchOptionsStack = UIStackView(arrangedSubviews: [segmentedControl, searchBarStack])
        searchOptionsStack.translatesAutoresizingMaskIntoConstraints = false
        searchOptionsStack.axis = .vertical
        searchOptionsStack.spacing = 5.0
        searchOptionsStack.distribution = .fill
        searchOptionsStack.alignment = .fill
        
        self.view.addSubview(searchOptionsStack)
        searchOptionsStack.constrain(.top, to: headerView, .bottom, constant: 10.0)
        searchOptionsStack.constrain(.leading, to: self.view, .leading, constant: 10.0)
        searchOptionsStack.constrain(.trailing, to: self.view, .trailing, constant: 10.0)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = searchNormalTitle
        searchBar.delegate = self
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        for (i, segment) in Segment.allCases.enumerated() {
            segmentedControl.insertSegment(withTitle: segment.rawValue, at: i, animated: false)
        }
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.mediumBold], for: .normal)
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        
    }
    
    private func setUpSearchTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.constrain(.top, to: searchOptionsStack, .bottom)
        tableView.constrain(.leading, to: self.view, .leading)
        tableView.constrain(.trailing, to: self.view, .trailing)
        tableView.constrain(.bottom, to: self.view, .bottom)
        tableView.register(TwoLevelCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    private func setUpCreateOwnRestaurantButton() {
        overlayButton = headerView.rightButton
        overlayButton!.translatesAutoresizingMaskIntoConstraints = false
        overlayButton!.setTitle("Create", for: .normal)
        overlayButton!.addTarget(self, action: #selector(overlayButtonAction), for: .touchUpInside)
        overlayButton!.alpha = 0.0
    }
    
    private func setUpRequest() {
        requestCompleter.resultTypes = .pointOfInterest
        requestCompleter.pointOfInterestFilter = .init(including: [.restaurant])
        requestCompleter.delegate = self
    }
    
    private func getInitialData() {
        Network.shared.getUserEstablishments { [weak self] (result) in
            DispatchQueue.main.async {
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
    }
    
    @objc private func remove() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func myPlacesButtonAction() {
        if let text = searchBar.text, text.count > 0 {
            customPlaceSegment = .myPlaces
            self.present(SelectLocationVC(owner: self), animated: true, completion: nil)
        } else {
            searchBar.shakeView()
        }
    }
    
    @objc private func segmentedControlChanged() {
        tableView.transitionReload()
        tableView.layoutIfNeeded()
        
        switch currentSelectedSegment {
        case .search:
            searchBar.placeholder = searchNormalTitle
            searchBar.text = ""
            searchBar.searchTextField.leftView = UIImageView(image: .magnifyingGlassImage)
            searchBar.layoutIfNeeded()
            
            self.myPlacesButton.isHidden = true
            
            UIView.animate(withDuration: 0.3) {
                self.searchBarStack.isHidden = false
                self.searchOptionsStack.layoutIfNeeded()
            }
            
        case .previous:
            self.searchBar.endEditing(true)
            UIView.animate(withDuration: 0.3) {
                self.searchBarStack.isHidden = true
                self.searchOptionsStack.layoutIfNeeded()
            }
            
        case .myPlaces:
            searchBar.placeholder = myPlacesTitle
            searchBar.text = ""
            searchBar.searchTextField.leftView = UIImageView(image: .homeImage)
            searchBar.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.3) {
                self.searchBarStack.isHidden = false
                self.myPlacesButton.isHidden = false
                self.searchOptionsStack.layoutIfNeeded()
            }
        }
        
        searchBar.searchTextField.leftViewMode = .always
        searchBar.searchTextField.leftView?.tintColor = .systemGray
        handleShowingOrHidingAddRestaurantOption()
    }
    
    @objc private func addVisitButtonAction() {
        for (i, segment) in Segment.allCases.enumerated() {
            if segment == .search {
                segmentedControl.selectedSegmentIndex = i
                addRestaurantReloadTable()
                break
            }
        }
    }
    
    private func addRestaurantReloadTable() {
        tableView.reloadData()
        handleShowingOrHidingAddRestaurantOption()
    }
    
    private func handleShowingOrHidingAddRestaurantOption() {
        // overlayButton
        print("handleShowingOrHidingAddRestaurantOption being called")
        guard let currText = searchBar.text, currText.count > 0, currentSelectedSegment == .search else {
            overlayButton?.hideWithAlphaAnimated()
            return
        }
        
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        // arbitrary number of 3 for the cutoff point to decide if the user should be able to create their own restaurant
        if numberOfRows <= 3 {
            overlayButton?.showWithAlphaAnimated()
        } else {
            overlayButton?.hideWithAlphaAnimated()
        }
    }
    
    @objc private func overlayButtonAction() {
        self.getTextFromUser(delegate: self, startingText: searchBar.text)
    }
    
    private func handleNewEstablishmentAddition(name: String, type: Segment?, coordinate: CLLocationCoordinate2D, fullAddress: String) {
        guard let type = type else { return }
        switch type {
        case .search:
            #warning("need to complete")
            let newRow = (name, fullAddress)
            tableView.beginUpdates()
            searchResults.insert(newRow, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            tableView.endUpdates()
            self.navigationController?.pushViewController(SubmitRestaurantVC(rawValues: newRow, establishment: nil, restaurant: nil), animated: true)
        case .myPlaces:
            let newEstablishment = Establishment(name: name, isRestaurant: false)
            newEstablishment.updatePropertiesWithFullAddress(address: fullAddress, coordinate: coordinate)
            myPlaces.append(newEstablishment)
            addRestaurantReloadTable()
            self.navigationController?.pushViewController(SubmitRestaurantVC(rawValues: nil, establishment: newEstablishment, restaurant: nil), animated: true)
        case .previous:
            return
        }
        
        searchBar.text = ""
        customPlaceSegment = nil
    }
    
}


// MARK: Table view
extension AddRestaurantVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch currentSelectedSegment {
        case .search:
            tableView.restore()
            if previousRestaurantsOnSearch {
                return previousSearchedRestaurants.count
            } else {
                return searchResults.count
            }
        case .myPlaces:
            let count = myPlaces.count
            if count == 0 {
                if initialLoadingDone {
                    let addPlaceButton = tableView.setEmptyWithAction(message: "No places added yet.", buttonTitle: "Add place", area: .bottom)
                    addPlaceButton.addTarget(self, action: #selector(myPlacesButtonAction), for: .touchUpInside)
                } else {
                    tableView.showLoadingOnTableView()
                }
                return 0
            } else {
                tableView.restore()
                return count
            }
            
        case .previous:
            let count = previousRestaurants.count
            if count == 0 {
                if initialLoadingDone {
                    let addVisitButton = tableView.setEmptyWithAction(message: "No restaurants previously visited yet.", buttonTitle: "Add visit", area: .bottom)
                    addVisitButton.addTarget(self, action: #selector(addVisitButtonAction), for: .touchUpInside)
                } else {
                    tableView.showLoadingOnTableView()
                }
                return 0
            } else {
                tableView.restore()
                return count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TwoLevelCell
        
        switch currentSelectedSegment {
        case .search:
            
            if previousRestaurantsOnSearch {
                let restaurant = previousSearchedRestaurants[indexPath.row]
                cell.setUpWith(restaurant: restaurant)
            } else {
                let cellInfo = searchResults[indexPath.row]
                cell.setUpWith(main: cellInfo.name, secondary: cellInfo.address)
            }
            
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
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        var cellInfo: (String, String)?
        var establishment: Establishment?
        var restaurant: Restaurant?
        
        switch currentSelectedSegment {
        case .search:
            
            if previousRestaurantsOnSearch {
                restaurant = previousSearchedRestaurants[indexPath.row]
            } else {
                cellInfo = searchResults[indexPath.row]
            }
            
            
        case .myPlaces:
            establishment = myPlaces[indexPath.row]
                    
        case .previous:
            establishment = previousRestaurants[indexPath.row]
    
        }
        
        let submitRestaurantVC = SubmitRestaurantVC(rawValues: cellInfo, establishment: establishment, restaurant: restaurant)
        self.navigationController?.pushViewController(submitRestaurantVC, animated: true)
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if searchBar.isFirstResponder {
            searchBar.endEditing(true)
        }
    }
}

// MARK: Search bar
extension AddRestaurantVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if currentSelectedSegment == .search {
            if searchText == "" {
                previousRestaurantsOnSearch = true
                addRestaurantReloadTable()
            } else {
                previousRestaurantsOnSearch = false
                requestCompleter.queryFragment = searchText
            }
        }
    }
}

// MARK: MKLocalSearchCompleterDelegate
extension AddRestaurantVC: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let results = completer.results.map({($0.title, $0.subtitle)})
        searchResults = results
    }
}

// MARK: SelectLocationDelegate
extension AddRestaurantVC: SelectLocationDelegate {
    func locationSelected(coordinate: CLLocationCoordinate2D, fullAddress: String) {
        var text: String? {
            guard let segment = customPlaceSegment else { return nil }
            switch segment {
            case .search:
                return customRestaurantName
            case .myPlaces:
                return searchBar.text
            case .previous:
                return nil
            }
        }
        
        guard text != nil else { return }
        
        handleNewEstablishmentAddition(name: text!, type: customPlaceSegment, coordinate: coordinate, fullAddress: fullAddress)
    }
}

// MARK: EnterValueViewDelegate
extension AddRestaurantVC: EnterValueViewDelegate {
    func textFound(string: String?) {
        guard let string = string else { return }
        customPlaceSegment = .search
        self.customRestaurantName = string
        self.present(SelectLocationVC(owner: self), animated: true, completion: nil)
    }
    
    func ratingFound(float: Float?) { return }
    func phoneFound(string: String?) { return }
}
