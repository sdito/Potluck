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
    #warning("pagination on django")
    #warning("remove fatalError stuff")
    
    #warning("need to make sure errors are correct on VisitView in django")
    #warning("maybe have a widget -> one that has a map based on the last area you searched, that has buttons for search shortcuts, one that lets you add a visit maybe")
    #warning("image url can expire before it is seen")
    #warning("unique together the reverse way too")
    #warning("unique together i.e. do not allow the reverse of friends to be true")
    #warning("if a visit is deleted, and then a tag is selected that has that visit, it will show again, prob same for establishments")
    
    #warning("profile image icon")
    
    #warning("in general for image caches, have a cache for processing requests maybe")
    
    #warning("still some issues with restaurantList image cache")
    
    #warning("calendar option, should be a pop-up view")
    
//    private let home =
    private let home = ProfilePageVC()//UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
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
    
    #warning("need to complete and implement")
    func changeActivePageViewController() {
        print("changeActivePageViewController activated")
        if !goToNextPage() {
            goToPreviousPage()
        }
    }
    
    func goToNextPage() -> Bool {
        guard let currentViewController = home.viewControllers?.first else { return false }
        guard let nextViewController = home.dataSource?.pageViewController(home, viewControllerAfter: currentViewController ) else { return false }
        
        self.view.isUserInteractionEnabled = false
        home.setViewControllers([nextViewController], direction: .forward, animated: true) { [weak self] _ in
            self?.view.isUserInteractionEnabled = true
        }
        return true
    }
    
    @discardableResult
    func goToPreviousPage() -> Bool {
        guard let currentViewController = home.viewControllers?.first else { return false }
        guard let previousViewController = home.dataSource?.pageViewController(home, viewControllerBefore: currentViewController ) else { return false }
        
        self.view.isUserInteractionEnabled = false
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
                home.popToCurrentPageRootViewController()
                
            }
        }
        return true
    }
    
    
    
}

