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
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .settingsImage, style: .plain, target: self, action: #selector(rightBarButtonItemSelector))
        
        setUpTableView()
        getInitialUserVisits()
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
            
            #warning("this one is not workking")
            
            tableView.layoutIfNeeded()
            
            self.allowHintToCreateRestaurant = false
            let createAccountButton = self.tableView.setEmptyWithAction(message: "You need to create an account in order to make posts.", buttonTitle: "Create account")
            createAccountButton.addTarget(self, action: #selector(rightBarButtonItemSelector), for: .touchUpInside)
            
            
        }
        
    }
    
    private func setUpTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        tableView.constrainSides(to: self.view)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(VisitCell.self, forCellReuseIdentifier: reuseIdentifier)
        
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
        let key = NSString(string: "\(indexPath.row)")
        
        cell.setImage(url: visit.mainImage, image: imageCache.object(forKey: key), height: visit.mainImageHeight, width: visit.mainImageWidth) { (imageFound) in
            if let imageFound = imageFound {
                self.imageCache.setObject(imageFound, forKey: key)
            }
        }
        
        return cell
    }
    
    
}



