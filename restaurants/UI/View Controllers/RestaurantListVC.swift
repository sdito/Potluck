//
//  RestaurantListVC.swift
//  restaurants
//
//  Created by Steven Dito on 7/18/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Hero


class RestaurantListVC: UIViewController {
    
    var locationAllowed = true
    private var searchUpdatedFromHere = false
    private var imageCache = NSCache<NSString, UIImage>(); #warning("major issues with the image cache, might need to change to have a global one, idk")
    private var owner: FindRestaurantVC!
    private var searchCompleteDelegate: SearchCompleteDelegate!
    private var topContainerView: UIView!
    private var commonSearchButtons: [SizeChangeButton] = []
    private var restaurantSearchBar = RestaurantSearchBar()
    private var scrollingStackViewForSearchButtons: ScrollingStackView!
    private let topViewPadding: CGFloat = 7.0
    let filterButton = SizeChangeButton(sizeDifference: .medium, restingColor: .secondaryLabel, selectedColor: .secondaryLabel)
    
    var restaurants: [Restaurant]? {
        didSet {
            imageCache.removeAllObjects()
            tableView.reloadData()
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    private let restaurantCellReuseIdentifier = "restaurantCellReuseIdentifier"
    var tableView: UITableView!
    
    init(owner: FindRestaurantVC) {
        self.owner = owner
        self.searchCompleteDelegate = owner
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .secondarySystemBackground
        self.navigationController?.isHeroEnabled = true
        setUpPortionAboveTableView()
        setUpTableView()
        self.tableView.register(RestaurantCell.self, forCellReuseIdentifier: restaurantCellReuseIdentifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if restaurantSearchBar.areViewsHidden {
            restaurantSearchBar.endHeroAnimation()
        }
    }
    
    private func setUpPortionAboveTableView() {
        
        topContainerView = UIView()
        topContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(topContainerView)
        
        NSLayoutConstraint.activate([
            topContainerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: topViewPadding),
            topContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: topViewPadding),
            topContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -topViewPadding),
            topContainerView.heightAnchor.constraint(equalToConstant: 100.0 - topViewPadding * 2)
        ])
        
        
        let topShowSlideView = UIView()
        topShowSlideView.translatesAutoresizingMaskIntoConstraints = false
        topShowSlideView.backgroundColor = .secondarySystemFill
        
        topContainerView.addSubview(topShowSlideView)
        
        NSLayoutConstraint.activate([
            topShowSlideView.heightAnchor.constraint(equalToConstant: 5.0),
            topShowSlideView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 4.0),
            topShowSlideView.topAnchor.constraint(equalTo: topContainerView.topAnchor),
            topShowSlideView.centerXAnchor.constraint(equalTo: topContainerView.centerXAnchor)
        ])
        topShowSlideView.layer.cornerRadius = 2.0
        
        
        filterButton.setImage(.filterButton, for: .normal)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.heightAnchor.constraint(equalTo: filterButton.widthAnchor).isActive = true
        filterButton.backgroundColor = restaurantSearchBar.backgroundColor
        filterButton.layer.cornerRadius = 3.0
        filterButton.tintColor = .secondaryLabel
        
        updateNotificationCount()
        filterButton.addTarget(self, action: #selector(showFilterController), for: .touchUpInside)
        
        let searchBarStack = UIStackView(arrangedSubviews: [restaurantSearchBar, filterButton])
        searchBarStack.translatesAutoresizingMaskIntoConstraints = false
        searchBarStack.axis = .horizontal
        searchBarStack.spacing = 5.0
        searchBarStack.alignment = .fill
        
        topContainerView.addSubview(searchBarStack)
        
        owner.restaurantSearchBar = restaurantSearchBar
        
        NSLayoutConstraint.activate([
            searchBarStack.topAnchor.constraint(equalTo: topShowSlideView.bottomAnchor, constant: 15.0),
            searchBarStack.centerXAnchor.constraint(equalTo: topContainerView.centerXAnchor),
            searchBarStack.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.9),
            searchBarStack.heightAnchor.constraint(equalToConstant: 30.0)
        ])
        
        let topGestureButton = restaurantSearchBar.addGestureToIncreaseAndDecreaseSizeOnPresses()
        topGestureButton.addTarget(self, action: #selector(searchBarPressed(sender:forEvent:)), for: .touchUpInside)
        
        let testViewForScrollingButtons = UIView()
        testViewForScrollingButtons.translatesAutoresizingMaskIntoConstraints = false
        topContainerView.addSubview(testViewForScrollingButtons)
        
        NSLayoutConstraint.activate([
            testViewForScrollingButtons.topAnchor.constraint(equalTo: restaurantSearchBar.bottomAnchor, constant: topViewPadding),
            testViewForScrollingButtons.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor),
            testViewForScrollingButtons.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor),
            testViewForScrollingButtons.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor)
        ])
        
        for (i, search) in Network.commonSearches.enumerated() {
            let button = SizeChangeButton.genericScrollingButton()
            button.setTitle(search.title, for: .normal)
            button.tag = i
            button.addTarget(self, action: #selector(commonSearchesPressed(sender:)), for: .touchUpInside)
            commonSearchButtons.append(button)
        }
        
        scrollingStackViewForSearchButtons = ScrollingStackView(subViews: commonSearchButtons)
        testViewForScrollingButtons.addSubview(scrollingStackViewForSearchButtons)
        scrollingStackViewForSearchButtons.constrainSides(to: testViewForScrollingButtons)
    }
    
    func updateNotificationCount() {
        let values = owner.searchFilters.values
        var counter = 0
        // need this since some will be separated by comma and thus have multiple filters per key
        for value in values {
            if let str = value as? String {
                counter += str.split(separator: ",").count
            } else {
                counter += 1
            }
        }
        
        filterButton.removeNotificationStyleText()
        if counter > 0 {
            filterButton.showNotificationStyleText(str: "\(counter)")
        }
        
    }
    
    @objc private func commonSearchesPressed(sender: UIButton) {
        UIDevice.vibrateSelectionChanged()
        searchUpdatedFromHere = true // used so that the UI does not get updated again for no reason on SearchUpdatedFromMasterDelegate
        let search = Network.commonSearches[sender.tag]
        if sender.isSelected {
            baseSearch()
            sender.isSelected = false
        } else {
            commonSearchButtons.forEach({$0.isSelected = false})
            searchCompleteDelegate.newSearchCompleted(searchType: search, locationText: nil)
            sender.isSelected = true
        }
    }
    
    @objc private func searchBarPressed(sender: UIButton?, forEvent event: UIEvent?) {
        
        var searchOption: RestaurantSearchBar.SearchOption {
            if let touch = event?.allTouches?.first {
                return restaurantSearchBar.findIfSearchTypeOrLocationPressed(point: touch.location(in: sender))
            } else {
                return .location
            }
        }
        
        restaurantSearchBar.beginHeroAnimation()
        let searchInfo = owner.restaurantSearch
        self.navigationController?.pushViewController(SearchRestaurantsVC(searchType: searchInfo.yelpCategory, searchLocation: searchInfo.location ?? "Current location", control: owner, startWithLocation: searchOption == .location), animated: true)
    }
    
    private func baseSearch() {
        searchCompleteDelegate.newSearchCompleted(searchType: ("restaurants", "Restaurants"), locationText: nil)
    }
    
    @objc private func baseSearchSelector(sender: UIButton) {
        baseSearch()
        sender.setTitleColor(.clear, for: .normal)
        sender.placeActivityIndicatorOnTop()
    }
    
    private func setUpTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topContainerView.bottomAnchor, constant: topViewPadding),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        
    }
    
    @objc private func showFilterController() {
        owner.present(FilterRestaurantsVC(previousFilters: owner.searchFilters, master: owner), animated: true, completion: nil)
    }
    
    
    func scrollTableViewToTop() {
        guard tableView != nil && tableView.numberOfRows(inSection: 0) > 0 else { return }
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
    
    func scrollToRestaurant(_ restaurant: Restaurant) {
        #warning("will not scroll to the last few rows, need to fix, also issue with the image cache")
        
        let indexToScrollTo = restaurants?.firstIndex { (rest) -> Bool in rest.id == restaurant.id }
        guard let index = indexToScrollTo else { return }
        
        tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
        
    }

}



// MARK: TableView
extension RestaurantListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let restaurants = restaurants {
            if restaurants.count > 0 {
                tableView.restore()
                return restaurants.count
            } else if !locationAllowed {
                let locationButton = self.tableView.setEmptyWithAction(message: "Location not enabled. Location is used to find restaurants near you. You can add your own location instead.", buttonTitle: "Enter location", area: .top)
                locationButton.addTarget(self, action: #selector(searchBarPressed), for: .touchUpInside)
                return 0
            } else {
                let tryAgainButton = self.tableView.setEmptyWithAction(message: "Something went wrong. Couldn't find restaurants.", buttonTitle: "Try again", area: .top)
                tryAgainButton.addTarget(self, action: #selector(baseSearchSelector(sender:)), for: .touchUpInside)
                return 0
            }
        } else {
            tableView.showLoadingOnTableView(middle: false)
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: restaurantCellReuseIdentifier) as! RestaurantCell
        let restaurant = restaurants![indexPath.row]
        cell.setUp(restaurant: restaurant, place: indexPath.row + 1, vc: owner)
        let key = "\(indexPath.section).\(indexPath.row)" as NSString
        if let cachedImage = imageCache.object(forKey: key) {
            cell.restaurantImageView.image = cachedImage
        } else {
            cell.restaurantImageView.appStartSkeleton()
            Network.shared.getImage(url: restaurant.imageURL) { [weak self] (img) in
                guard let self = self else { return }
                cell.restaurantImageView.appEndSkeleton()
                cell.restaurantImageView.image = img
                if let img = img {
                    self.imageCache.setObject(img, forKey: key)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let restaurant = restaurants![indexPath.row]
        //print(restaurant.name)
        let cell = tableView.cellForRow(at: indexPath) as! RestaurantCell
        cell.setUpForHero()
        self.parent?.navigationController?.isHeroEnabled = true
        
        var imageToSend: UIImage? {
            if cell.restaurantImageView.isSkeletonActive {
                return nil
            } else {
                return cell.restaurantImageView.image
            }
        }
        self.parent?.navigationController?.pushViewController(RestaurantDetailVC(restaurant: restaurant, fromCell: cell, imageAlreadyFound: imageToSend, allowVisit: true), animated: true)
        self.tableView.cellForRow(at: indexPath)?.isSelected = false
    }
}


// MARK: SearchUpdatedFromMasterDelegate

extension RestaurantListVC: SearchUpdatedFromMasterDelegate {
    func newSearch(search: Network.RestaurantSearch) {
        if searchUpdatedFromHere {
            // Updated from one of the selected buttons, and the UI is already handled
            searchUpdatedFromHere = false
        } else {
            // For each of the buttons, using the alias and the network base searches, set the button's UI
            guard let newSearchAlias = search.yelpCategory?.alias else {
                commonSearchButtons.forEach({$0.isSelected = false})
                return
            }
            for (i, search) in Network.commonSearches.enumerated() {
                if search.alias == newSearchAlias {
                    commonSearchButtons[i].isSelected = true
                } else {
                    commonSearchButtons[i].isSelected = false
                }
            }
            
            // So the animation will actually animate and show
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.scrollingStackViewForSearchButtons.updateToScrollToIncludeFirstSelectedButton()
            }
        }
    }
}

