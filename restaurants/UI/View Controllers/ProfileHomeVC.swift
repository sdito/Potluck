//
//  ProfileHomeVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/14/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class ProfileHomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .green
        self.setNavigationBarColor(color: Colors.navigationBarColor)
        self.title = "Profile"
        self.navigationController?.navigationBar.tintColor = Colors.main
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .settingsImage, style: .plain, target: self, action: #selector(rightBarButtonItemSelector))
    }
        
    
    @objc private func rightBarButtonItemSelector() {
        if Network.shared.loggedIn {
            self.navigationController?.pushViewController(SettingsVC(), animated: true)
        } else {
            self.navigationController?.pushViewController(CreateAccountVC(), animated: true)
        }
        
    }
    
    
    

}
