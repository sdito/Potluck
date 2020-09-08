//
//  TabVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/17/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class TabVC: UITabBarController, UITabBarControllerDelegate {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        let home = UINavigationController(rootViewController: ProfileHomeVC())
        let addRestaurant = AddRestaurantVC()
        let explore = UINavigationController(rootViewController: FindRestaurantVC())
        addRestaurant.view.backgroundColor = .greenSea
        
        home.tabBarItem = UITabBarItem(title: nil, image: .personImage, selectedImage: .personImage)
        addRestaurant.tabBarItem = UITabBarItem(title: nil, image: .add, selectedImage: .add)
        explore.tabBarItem = UITabBarItem(title: nil, image: .magnifyingGlassImage, selectedImage: .magnifyingGlassImage)
        self.setViewControllers([explore,addRestaurant, home], animated: false)
        self.tabBar.tintColor = Colors.main
        self.tabBar.barTintColor = Colors.navigationBarColor
        
        
        for tb in tabBar.items! {
            #warning("not working")
            tb.imageInsets = UIEdgeInsets(top: 5.5, left: 0, bottom: -5.5, right: 0)

        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.isKind(of: AddRestaurantVC.self) {
            self.presentAddRestaurantVC()
            return false
        }
        return true
    }
    
    
    

}

