//
//  FeedHomeVC.swift
//  restaurants
//
//  Created by Steven Dito on 9/26/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


class FeedHomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.navigationItem.title = "Feed"
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = Colors.main
        self.setNavigationBarColor()
        
        setUpFindPeople()
    }
    
    private func setUpFindPeople() {
        let addPerson = UIBarButtonItem(image: .personBadgeImage, style: .plain, target: self, action: #selector(addPersonAction))
        self.navigationItem.rightBarButtonItem = addPerson
    }

    
    @objc private func addPersonAction() {
        if Network.shared.loggedIn {
            self.navigationController?.pushViewController(AddFriendsVC(), animated: true)
        } else {
            let tabVC = self.tabBarController as? TabVC
            self.userNotLoggedInAlert(tabVC: tabVC)
        }
        
    }
    
}


