//
//  RestaurantListVC.swift
//  restaurants
//
//  Created by Steven Dito on 7/18/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Hero
import SkeletonView

class RestaurantListVC: UIViewController {
    
    private var imageCache = NSCache<NSString, UIImage>()
    private var owner: UIViewController!
    private var searchCompleteDelegate: SearchCompleteDelegate!
    private var topContainerView: UIView!
    private var commonSearchButtons: [SizeChangeButton] = []
    private let topViewPadding: CGFloat = 7.0
    
    var restaurants: [Restaurant] = [] {
        didSet {
            self.view.appEndSkeleton()
            imageCache.removeAllObjects()
            tableView.reloadData()
        }
    }
    
    private let restaurantCellReuseIdentifier = "restaurantCellReuseIdentifier"
    var tableView: UITableView!
    
    init(owner: UIViewController) {
        self.owner = owner
        self.searchCompleteDelegate = owner as? SearchCompleteDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .secondarySystemBackground
        setUpPortionAboveTableView()
        setUpTableView()
        self.tableView.register(RestaurantCell.self, forCellReuseIdentifier: restaurantCellReuseIdentifier)
        self.tableView.appStartSkeleton()
        
    }
    
    private func setUpPortionAboveTableView() {
        print("Yep, am setting up the portion above the table view")
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
        
        
        let buttonSearchView = RestaurantSearchBar()
        
        topContainerView.addSubview(buttonSearchView)
        
        if let parent = owner as? FindRestaurantVC {
            parent.restaurantSearchBar = buttonSearchView
        }
        
        NSLayoutConstraint.activate([
            buttonSearchView.topAnchor.constraint(equalTo: topShowSlideView.bottomAnchor, constant: 15.0),
            buttonSearchView.centerXAnchor.constraint(equalTo: topContainerView.centerXAnchor),
            buttonSearchView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),
            buttonSearchView.heightAnchor.constraint(equalToConstant: 30.0)
        ])
        
        let topGestureButton = buttonSearchView.addGestureToIncreaseAndDecreaseSizeOnPresses()
        topGestureButton.addTarget(self, action: #selector(searchBarPressed), for: .touchUpInside)
        
        
        
        
        
        
        
        
        
        let testViewForScrollingButtons = UIView()
        testViewForScrollingButtons.translatesAutoresizingMaskIntoConstraints = false
        topContainerView.addSubview(testViewForScrollingButtons)
        
        NSLayoutConstraint.activate([
            testViewForScrollingButtons.topAnchor.constraint(equalTo: buttonSearchView.bottomAnchor, constant: topViewPadding),
            testViewForScrollingButtons.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor),
            testViewForScrollingButtons.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor),
            testViewForScrollingButtons.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor)
        ])
        
        // add a clear button to the common search buttons
        #warning("need to complete ^")
        let clearButton = SizeChangeButton(sizeDifference: .medium, restingColor: Colors.secondary, selectedColor: Colors.main)
        clearButton.setImage(.clearImage, for: .normal)
        clearButton.tintColor = .label
        commonSearchButtons.append(clearButton)
        
        for (i, search) in Network.commonSearches.enumerated() {
            let button = SizeChangeButton(sizeDifference: .medium, restingColor: .secondaryLabel, selectedColor: .label)
            button.layer.cornerRadius = 4.0
            button.clipsToBounds = true
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(search.title, for: .normal)
            button.titleLabel?.font = .mediumBold
            button.backgroundColor = .quaternarySystemFill
            button.tag = i
            button.addTarget(self, action: #selector(commonSearchesPressed(sender:)), for: .touchUpInside)
            commonSearchButtons.append(button)
        }
        
        let scrollingStackView = ScrollingStackView(subViews: commonSearchButtons)
        testViewForScrollingButtons.addSubview(scrollingStackView)
        scrollingStackView.constrainSides(to: testViewForScrollingButtons)
    }
    
    @objc private func commonSearchesPressed(sender: UIButton) {
        let search = Network.commonSearches[sender.tag]
        print(search.alias!, search.title)
        searchCompleteDelegate.newSearchCompleted(searchType: search, locationText: nil)
        //sender.backgroundColor = .systemPink
        
        commonSearchButtons.forEach({$0.setTitleColor($0.restingColor, for: .normal)})
        
        sender.setTitleColor(Colors.main, for: .normal)
    }
    
    @objc private func searchBarPressed() {
        if let parent = owner as? FindRestaurantVC {
            let searchInfo = parent.restaurantSearch
            
            self.navigationController?.pushViewController(SearchRestaurantsVC(searchType: searchInfo.yelpCategory, searchLocation: searchInfo.location ?? "Current location", control: owner), animated: true)
        }
        
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
    
    
    
    func scrollTableViewToTop() {
        guard tableView != nil && tableView.numberOfRows(inSection: 0) > 0 else { return }
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
    
    func scrollToRestaurant(_ restaurant: Restaurant) {
        #warning("will not scroll to the last few rows, need to fix")
        
        let indexToScrollTo = restaurants.firstIndex { (rest) -> Bool in rest.id == restaurant.id }
        guard let index = indexToScrollTo else { return }
        #warning("also issue with image cache")
        tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
        
    }

}

// MARK: TableView
extension RestaurantListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: restaurantCellReuseIdentifier) as! RestaurantCell
        let restaurant = restaurants[indexPath.row]
        cell.setUp(restaurant: restaurant, place: indexPath.row + 1, vc: owner)
        let key = "\(indexPath.section).\(indexPath.row)" as NSString
        if let cachedImage = imageCache.object(forKey: key) {
            cell.restaurantImageView.image = cachedImage
        } else {
            cell.restaurantImageView.appStartSkeleton()
            Network.shared.getImage(url: restaurant.imageURL) { (img) in
                cell.restaurantImageView.appEndSkeleton()
                cell.restaurantImageView.image = img
                self.imageCache.setObject(img, forKey: key)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        #warning("alert parent that the row was selected to update the selected pin")
        
        let restaurant = restaurants[indexPath.row]
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
        self.parent?.navigationController?.pushViewController(RestaurantDetailVC(restaurant: restaurant, fromCell: cell, imageAlreadyFound: imageToSend), animated: true)
        self.tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
    
    
}


#warning("doesn't work")
// MARK: Skeleton View
extension RestaurantListVC: SkeletonTableViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
       return restaurantCellReuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
}



