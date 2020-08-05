//
//  SearchRestaurantsVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/1/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class SearchRestaurantsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.title = "Search"
        self.navigationController?.navigationBar.tintColor = Colors.main
        setUpTopSearchBars()
    }
    
    private func setUpTopSearchBars() {
        let searchTypeSearchBar = UIView()
        searchTypeSearchBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(searchTypeSearchBar)
        
        NSLayoutConstraint.activate([
            searchTypeSearchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            searchTypeSearchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            searchTypeSearchBar.topAnchor.constraint(equalTo: self.view.topAnchor),
            searchTypeSearchBar.heightAnchor.constraint(equalToConstant: 50.0)
        ])
        
        searchTypeSearchBar.backgroundColor = .systemPink
    }

    
}
