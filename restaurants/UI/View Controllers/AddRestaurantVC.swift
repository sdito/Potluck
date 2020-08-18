//
//  AddRestaurantVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/17/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class AddRestaurantVC: UIViewController {
    
    private let searchBar = UISearchBar()
    private let cancelButton = SizeChangeButton(sizeDifference: .medium, restingColor: Colors.secondary, selectedColor: Colors.main)
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUpCancelButton()
        setUpSearchBar()
        setUpSearchTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    private func setUpCancelButton() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(cancelButton)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .largerBold
        cancelButton.constrain(.top, to: self.view, .top, constant: 10)
        cancelButton.constrain(.trailing, to: self.view, .trailing, constant: 10)
        cancelButton.addTarget(self, action: #selector(remove), for: .touchUpInside)
    }
    
    private func setUpSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(searchBar)
        searchBar.constrain(.leading, to: self.view, .leading)
        searchBar.constrain(.top, to: cancelButton, .bottom)
        searchBar.constrain(.trailing, to: self.view, .trailing)
        searchBar.placeholder = "Restaurant name"
    }
    
    private func setUpSearchTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.constrain(.top, to: searchBar, .bottom)
        tableView.constrain(.leading, to: self.view, .leading)
        tableView.constrain(.trailing, to: self.view, .trailing)
        tableView.constrain(.bottom, to: self.view, .bottom)
    }
    
    @objc private func remove() {
        self.dismiss(animated: true, completion: nil)
    }
}



extension AddRestaurantVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "Cell number \(indexPath.row)"
        return cell
    }
    
    
}
