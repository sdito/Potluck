//
//  TabVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/17/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class TabVC: UITabBarController, UITabBarControllerDelegate {
    
    #warning("pagination on django")
    #warning("place for other images, maybe make all images into just images")
    
    #warning("need to make sure errors are correct on VisitView in django")
    #warning("maybe have a widget -> one that has a map based on the last area you searched, that has buttons for search shortcuts, one that lets you add a visit maybe")
    #warning("add tags to visits")
    #warning("image url can expire before it is seen")
    #warning("setting to override dark mode in app")
    #warning("skStore thing to pop up to review the app")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        let home = UINavigationController(rootViewController: ProfileHomeVC())
        let addRestaurant = AddRestaurantVC()
        let explore = UINavigationController(rootViewController: FindRestaurantVC())
        addRestaurant.view.backgroundColor = .greenSea
        
        let personTabImage = UIImage.personImage.withBaselineOffset(fromBottom: UIFont.systemFontSize / 2)
        let plusTabImage = UIImage.plusImage.withBaselineOffset(fromBottom: UIFont.systemFontSize / 2)
        let magnifyingGlassImage = UIImage.magnifyingGlassImage.withBaselineOffset(fromBottom: UIFont.systemFontSize / 2)
        
        home.tabBarItem = UITabBarItem(title: nil, image: personTabImage, selectedImage: personTabImage)
        addRestaurant.tabBarItem = UITabBarItem(title: nil, image: plusTabImage, selectedImage: plusTabImage)
        explore.tabBarItem = UITabBarItem(title: nil, image: magnifyingGlassImage, selectedImage: magnifyingGlassImage)
        self.setViewControllers([explore,addRestaurant, home], animated: false)
        self.tabBar.tintColor = Colors.main
        self.tabBar.barTintColor = Colors.navigationBarColor
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.isKind(of: AddRestaurantVC.self) {
            
            #warning("only do this if the user is logged in, have an alert or something if they are not")
            self.presentAddRestaurantVC()
            return false
        }
        return true
    }
    

}




