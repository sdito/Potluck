//
//  FeedHomeVC.swift
//  restaurants
//
//  Created by Steven Dito on 9/26/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


class FeedHomeVC: UIViewController {
    #warning("handle case for user logged out")
    private var visits: [Visit] = [] {
        didSet {
            visitTableView?.visits = visits
        }
    }
    private var visitTableView: VisitTableView?
    private let reuseIdentifier = "visitCellReuseIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUpNavigationBar()
        setUpTableView()
        getUserFeed()
    }
    
    private func setUpNavigationBar() {
        self.setNavigationBarColor()
        self.navigationItem.title = "Feed"
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = Colors.main
        let addPerson = UIBarButtonItem(image: .personBadgeImage, style: .plain, target: self, action: #selector(addPersonAction))
        self.navigationItem.rightBarButtonItem = addPerson
    }
    
    private func setUpTableView() {
        visitTableView = VisitTableView(mode: .friends, prevImageCache: nil, delegate: self)
        self.view.addSubview(visitTableView!)
        visitTableView!.constrainSides(to: self.view)
    }
    
    private func getUserFeed() {
        Network.shared.getVisitFeed(feedType: .friends) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let visits):
                self.visits = visits
                DispatchQueue.main.async {
                    self.visitTableView?.clearCaches()
                    self.visitTableView?.reloadData()
                    self.visitTableView?.refreshControl?.endRefreshing()
                }
            case .failure(_):
                print("Failure getting friends visit feed")
            }
        }
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


// MARK: VisitTableViewDelegate
extension FeedHomeVC: VisitTableViewDelegate {
    func refreshControlSelected() {
        self.getUserFeed()
    }
}
