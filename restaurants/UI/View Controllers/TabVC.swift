//
//  TabVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/17/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


class TabVC: UITabBarController {
    #warning("*****map clustering only on profile maps (userProfileVC, profileMapVC)")
    #warning("image url can expire before it is seen")
    #warning("unique together the reverse way too")
    #warning("unique together i.e. do not allow the reverse of friends to be true")
    #warning("calendar option, should be a pop-up view")
    
    private let home = ProfilePageVC()
    private let feed = UINavigationController(rootViewController: FeedHomeVC())
    private let addRestaurant = AddRestaurantVC()
    private let explore = UINavigationController(rootViewController: FindRestaurantVC())
    private let settings = UINavigationController(rootViewController: SettingsVC())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        let personTabImage = UIImage.personImage.withBaselineOffset(fromBottom: UIFont.systemFontSize / 2)
        let feedImage = UIImage.houseImage.withBaselineOffset(fromBottom: UIFont.systemFontSize / 2)
        let plusTabImage = UIImage.plusImage.withBaselineOffset(fromBottom: UIFont.systemFontSize / 2)
        let magnifyingGlassImage = UIImage.magnifyingGlassImage.withBaselineOffset(fromBottom: UIFont.systemFontSize / 2)
        let settingsImage = UIImage.settingsImage.withBaselineOffset(fromBottom: UIFont.systemFontSize / 2)
        
        home.tabBarItem = UITabBarItem(title: nil, image: personTabImage, selectedImage: personTabImage)
        feed.tabBarItem = UITabBarItem(title: nil, image: feedImage, selectedImage: feedImage)
        addRestaurant.tabBarItem = UITabBarItem(title: nil, image: plusTabImage, selectedImage: plusTabImage)
        explore.tabBarItem = UITabBarItem(title: nil, image: magnifyingGlassImage, selectedImage: magnifyingGlassImage)
        settings.tabBarItem = UITabBarItem(title: nil, image: settingsImage, selectedImage: settingsImage)
        
        self.setViewControllers([explore, feed, addRestaurant, home, settings], animated: false)
        self.tabBar.tintColor = Colors.main
        self.tabBar.barTintColor = Colors.navigationBarColor
        
    }
    
    
    func getProfileTabIndex() -> Int {
        for (i, tab) in self.children.enumerated() {
            if tab == settings {
                return i
            }
        }
        return 0
    }
    
    func getProfileNavigationController() -> UINavigationController {
        return settings
    }
    
    func changeActivePageViewController() {
        if !goToNextPage() {
            goToPreviousPage()
        }
    }
    
    func goToNextPage() -> Bool {
        guard let currentViewController = home.viewControllers?.first else { return false }
        guard let nextViewController = home.dataSource?.pageViewController(home, viewControllerAfter: currentViewController ) else { return false }
        
        self.view.isUserInteractionEnabled = false // dont wan't anything to be clicked while the animation is in progress
        home.setViewControllers([nextViewController], direction: .forward, animated: true) { [weak self] _ in
            self?.view.isUserInteractionEnabled = true
        }
        return true
    }
    
    @discardableResult
    func goToPreviousPage() -> Bool {
        guard let currentViewController = home.viewControllers?.first else { return false }
        guard let previousViewController = home.dataSource?.pageViewController(home, viewControllerBefore: currentViewController ) else { return false }
        
        self.view.isUserInteractionEnabled = false // dont wan't anything to be clicked while the animation is in progress
        home.setViewControllers([previousViewController], direction: .reverse, animated: true) { [weak self] _ in
            self?.view.isUserInteractionEnabled = true
        }
        
        return true
    }
}

// MARK: Tab bar controller
extension TabVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.isKind(of: AddRestaurantVC.self) {
            if Network.shared.loggedIn {
                self.presentAddRestaurantVC()
            } else {
                self.userNotLoggedInAlert(tabVC: self)
            }
            
            return false
        } else if viewController == home {
            // will potentially need to manually pop to the root view controller for the selected navigation controller in the page controller (home)
            if let currentViewController = tabBarController.viewControllers?[tabBarController.selectedIndex], currentViewController == home {
                // only call if the home tab is already selected and being selected again
                home.popToCurrentPageRootViewController()
                
            }
        }
        return true
    }
}

