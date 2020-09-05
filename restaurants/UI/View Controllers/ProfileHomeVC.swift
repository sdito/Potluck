//
//  ProfileHomeVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/14/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class ProfileHomeVC: UIViewController {
    
    private let tableView = UITableView()
    private var allowHintToCreateRestaurant = false
    private var visits: [Visit] = []
    private let reuseIdentifier = "visitCellReuseIdentifier"
    private let imageCache = NSCache<NSString, UIImage>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.setNavigationBarColor(color: Colors.navigationBarColor)
        self.navigationController?.navigationBar.tintColor = Colors.main
        self.tableView.separatorInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .settingsImage, style: .plain, target: self, action: #selector(rightBarButtonItemSelector))
        
        setUpTableView()
        getInitialUserVisits()
        
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedIn), name: .userLoggedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedOut), name: .userLoggedOut, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func getInitialUserVisits() {
        
        if Network.shared.loggedIn {
            Network.shared.getUserFeed { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let visits):
                    
                    self.allowHintToCreateRestaurant = true
                    self.visits = visits
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            noUserTableView()
        }
    }
    
    private func setUpTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        tableView.constrainSides(to: self.view)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(VisitCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorStyle = .none
        self.tableView.backgroundColor = .secondarySystemBackground
        
        let showOnMapButton = SizeChangeButton(sizeDifference: .medium, restingColor: Colors.main, selectedColor: Colors.main)
        showOnMapButton.translatesAutoresizingMaskIntoConstraints = false
        showOnMapButton.setTitle("Show on map", for: .normal)
        showOnMapButton.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.9)
        showOnMapButton.titleEdgeInsets = UIEdgeInsets(top: 2.0, left: 5.0, bottom: 2.0, right: 5.0)
        showOnMapButton.layer.cornerRadius = 5.0
        showOnMapButton.setTitleColor(Colors.main, for: .normal)
        showOnMapButton.titleLabel?.font = .mediumBold
        
        self.view.addSubview(showOnMapButton)
        showOnMapButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//        showOnMapButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        showOnMapButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -((self.tabBarController?.tabBar.bounds.height ?? 0.0) + 10.0)).isActive = true
    }
    
    private func noUserTableView() {
        tableView.layoutIfNeeded()
        self.allowHintToCreateRestaurant = false
        let createAccountButton = self.tableView.setEmptyWithAction(message: "You need to create an account in order to make posts.", buttonTitle: "Create account")
        createAccountButton.addTarget(self, action: #selector(rightBarButtonItemSelector), for: .touchUpInside)
    }
    
    @objc private func rightBarButtonItemSelector() {
        if Network.shared.loggedIn {
            self.navigationController?.pushViewController(SettingsVC(), animated: true)
        } else {
            self.navigationController?.pushViewController(CreateAccountVC(), animated: true)
        }
    }
    
    @objc private func addNewPostSelector() {
        self.tabBarController?.presentAddRestaurantVC()
    }
    
    @objc private func userLoggedIn() {
        getInitialUserVisits()
    }
    
    @objc private func userLoggedOut() {
        visits = []
        tableView.reloadData()
        noUserTableView()
    }
}


extension ProfileHomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allowHintToCreateRestaurant && visits.count == 0 {
            let addPostButton = self.tableView.setEmptyWithAction(message: "You do not have any posts yet. Add a post every time you eat at a restaurant.", buttonTitle: "Add post")
            addPostButton.addTarget(self, action: #selector(addNewPostSelector), for: .touchUpInside)
        }
        return visits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! VisitCell
        let visit = visits[indexPath.row]
        cell.setUpWith(visit: visit)
        cell.delegate = self
        let key = NSString(string: "\(visit.djangoOwnID)")
        
        cell.setImage(url: visit.mainImage, image: imageCache.object(forKey: key), height: visit.mainImageHeight, width: visit.mainImageWidth) { (imageFound) in
            if let imageFound = imageFound {
                self.imageCache.setObject(imageFound, forKey: key)
            }
        }
        return cell
    }
}


// MARK: VisitCellDelegate
extension ProfileHomeVC: VisitCellDelegate {
    func delete(visit: Visit?) {
        guard let visit = visit else { return }
        self.alert(title: "Are you sure you want to delete this visit?", message: "This action can't be undone.") {
            Network.shared.deleteVisit(visit: visit) { (success) in return }
            
            let indexToDelete = self.visits.firstIndex { (v) -> Bool in
                v.djangoOwnID == visit.djangoOwnID
            }
            
            if let idx = indexToDelete {
                guard let cellToDelete = self.tableView.cellForRow(at: IndexPath(row: idx, section: 0)) as? VisitCell else { return }
            
                if cellToDelete.visit?.djangoOwnID == visit.djangoOwnID {
                    self.visits.remove(at: idx)
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [IndexPath(row: idx, section: 0)], with: .automatic)
                    self.tableView.endUpdates()
                }
            }
        }
    }
    
}

