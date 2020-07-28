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
    
    private var imageCache = NSCache<NSString, UIImage>()
    
    var restaurants: [Restaurant] = [] {
        didSet {
            imageCache.removeAllObjects()
            tableView.reloadData()
        }
    }
    
    private let restaurantCellReuseIdentifier = "restaurantCellReuseIdentifier"
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .secondarySystemBackground
        setUpTableView()
        self.tableView.register(RestaurantCell.self, forCellReuseIdentifier: restaurantCellReuseIdentifier)
        
    }
    
    private func setUpTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
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
extension RestaurantListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: restaurantCellReuseIdentifier) as! RestaurantCell
        let restaurant = restaurants[indexPath.row]
        cell.setUp(restaurant: restaurant, place: indexPath.row + 1)
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

