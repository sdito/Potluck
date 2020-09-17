//
//  TabVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/17/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class TabVC: UITabBarController, UITabBarControllerDelegate {
    
    #warning("haptic feedback with small click-like vibration")
    #warning("pagination on django")
    #warning("get the date from the images")
    #warning("place for other images, maybe make all images into just images")
    
    #warning("ability to delete establishment")
    #warning("ability to edit establishment")
    #warning("need to make sure errors are correct on VisitView in django")
    #warning("should be able to update/delete Visit from EstablishmentDetailVC, will need to use a notification to update the UI")
    #warning("maybe have a widget")
    /*
     if previousIndex != i {
         let generator = UISelectionFeedbackGenerator()
         generator.prepare()
         generator.selectionChanged()
         previousIndex = i
     }
     */
    
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
            self.presentAddRestaurantVC()
            return false
        }
        return true
    }
    

}




