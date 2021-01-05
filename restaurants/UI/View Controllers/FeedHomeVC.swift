//
//  FeedHomeVC.swift
//  restaurants
//
//  Created by Steven Dito on 9/26/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


class FeedHomeVC: UIViewController {
    
    private var visits: [Visit] = [] {
        didSet {
            visitTableView?.visits = visits
        }
    }
    private var visitTableView: VisitTableView?
    private let reuseIdentifier = "visitCellReuseIdentifier"
    private var previousDateOffset: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUpNavigationBar()
        setUpTableView()
        getUserFeed()
        
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedIn), name: .userLoggedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedOut), name: .userLoggedOut, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(friendshipRequestCountDecreased), name: .friendRequestPendingCountDecreased, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.visitTableView?.backgroundView?.alpha = 0.0
        UIView.animate(withDuration: 0.5) {
            self.visitTableView?.backgroundView?.alpha = 1.0
        }
    }
    
    @objc private func friendshipRequestCountDecreased() {
        print("Notification is being called...")
        let rightView = self.getRightBarButtonView()
        rightView?.changeValueOfNotificationText(valueAlteration: { $0 - 1 })
    }
    
    private func setUpNavigationBar() {
        self.setNavigationBarColor()
        self.navigationItem.title = "Friends"
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
            DispatchQueue.main.async {
                self?.visitTableView?.allowHintForFriendsFeed = true
                self?.visitTableView?.refreshControl?.endRefreshing()
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    self.visits = value.visits
                    let numberOfRequests = value.pending_request_count ?? 0
                    self.handleNotificationTextFor(numberOfRequests: numberOfRequests)
                    self.previousDateOffset = value.visit_date_offset
                    self.visitTableView?.allowNextPage = true
                case .failure(let error):
                    
                    print("Failure getting friends visit feed: \(print(error.localizedDescription))")
                    self.visits = []
                }
                self.handleReloadingVisitTableView()
            }
        }
    }
    
    private func getNextPage() {
        guard let dateOffset = previousDateOffset else { return }
        previousDateOffset = nil
        Network.shared.getVisitFeed(feedType: .friends, previousDateOffset: dateOffset) { [weak self] (result) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    let newVisits = value.visits
                    self.previousDateOffset = value.visit_date_offset
                    var index = self.visits.count
                    var indexPaths: [IndexPath] = []
                    for _ in 0..<value.visits.count {
                        indexPaths.append(IndexPath(row: index, section: 0))
                        index += 1
                    }
                    self.visits.append(contentsOf: newVisits)
                    self.visitTableView?.insertRows(at: indexPaths, with: .automatic)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.visitTableView?.allowNextPage = true
                    }
                    
                case .failure(_):
                    print("Failure in getting next page of visits")
                }
            }
        }
    }
    
    private func handleNotificationTextFor(numberOfRequests: Int) {
        if let subView = self.getRightBarButtonView() {
            if numberOfRequests > 0 {
                subView.removeNotificationStyleText()
                subView.showNotificationStyleText(str: "\(numberOfRequests)", inner: true)
            } else {
                subView.removeNotificationStyleText()
            }
        }
    }
    
    private func handleReloadingVisitTableView() {
        self.visitTableView?.clearCaches()
        self.visitTableView?.reloadData()
        self.visitTableView?.refreshControl?.endRefreshing()
    }
    
    @objc private func addPersonAction() {
        if Network.shared.loggedIn {
            self.navigationController?.pushViewController(AddFriendsVC(), animated: true)
        } else {
            let tabVC = self.tabBarController as? TabVC
            self.userNotLoggedInAlert(tabVC: tabVC)
        }
    }
    
    @objc private func userLoggedIn() {
        getUserFeed()
    }
    
    @objc private func userLoggedOut() {
        visits = []
        self.visitTableView?.clearCaches()
        self.visitTableView?.reloadData()
        self.handleNotificationTextFor(numberOfRequests: 0)
    }
}


// MARK: VisitTableViewDelegate
extension FeedHomeVC: VisitTableViewDelegate {
    
    func nextPageRequested() {
        getNextPage()
    }
    
    func refreshControlSelected() {
        if Network.shared.loggedIn {
            self.getUserFeed()
        } else {
            visits = []
            handleReloadingVisitTableView()
            self.showMessage("Log in to see your friends visits")
        }
    }
}
