//
//  ProfilePageVC.swift
//  restaurants
//
//  Created by Steven Dito on 11/14/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class ProfilePageVC: UIPageViewController {
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    lazy private var pages: [UIViewController] = {
        let one = UINavigationController(rootViewController: ProfileHomeVC(isOwnUsersProfile: true, visits: nil, prevImageCache: nil))
        let two = UINavigationController(rootViewController: ProfileMapVC())
        return [one, two]
    }()
    
    private var currentController: UIViewController? {
        return self.viewControllers?.first
    }
    
    func popToCurrentPageRootViewController() {
        if let currentController = currentController as? UINavigationController {
            currentController.popToRootViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        self.view.backgroundColor = .secondarySystemBackground
        
        if let firstViewController = pages.first {
            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
}

// MARK: Page view controller
extension ProfilePageVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return nil }
        guard pages.count > previousIndex else { return nil }
        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else { return nil }
        guard pages.count > nextIndex else { return nil }
        return pages[nextIndex]
    }
}
