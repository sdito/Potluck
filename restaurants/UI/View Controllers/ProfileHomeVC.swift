//
//  ProfileHomeVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/14/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class ProfileHomeVC: UIViewController {
    
    private var isOwnUsersProfile = false
    private let showOnMapButton = OverlayButton()
    private var visitTableView: VisitTableView?
    private var visits: [Visit] = [] {
        didSet {
            visitTableView?.visits = visits
        }
    }
    private weak var selectedVisit: Visit?
    private var preLoadedData = false
    private var otherUserUsername: String?
    private var allowMapButton = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUpNavigationBar()
        
        if let username = otherUserUsername {
            let navigationTitleView = NavigationTitleView(upperText: username, lowerText: "Visits")
            navigationItem.titleView = navigationTitleView
        } else {
            navigationItem.title = "Visits"
        }
        
        navigationController?.navigationBar.isTranslucent = false
        setUpTableView()
        
        if !preLoadedData {
            getInitialUserVisits()
        } else {
            visitTableView?.reloadData()
            if let elementId = selectedVisit?.djangoOwnID, let idx = visits.map({$0.djangoOwnID}).firstIndex(of: elementId) {
                visitTableView?.visits = visits
                visitTableView?.layoutIfNeeded()
                DispatchQueue.main.async {
                    self.visitTableView?.scrollToRow(at: IndexPath(row: idx, section: 0), at: .top, animated: false)
                }
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedIn), name: .userLoggedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedOut), name: .userLoggedOut, object: nil)
    }
    
    private func setUpNavigationBar() {
        self.setNavigationBarColor()
        self.navigationController?.navigationBar.tintColor = Colors.main
        let rightNavigationButton = UIBarButtonItem(image: .listImage, style: .plain, target: self, action: #selector(establishmentListPressed))
        self.navigationItem.rightBarButtonItem = rightNavigationButton
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init(isOwnUsersProfile: Bool, visits: [Visit]?, selectedVisit: Visit? = nil, prevImageCache: NSCache<NSString, UIImage>? = nil, otherUserUsername: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.isOwnUsersProfile = isOwnUsersProfile
        visitTableView = VisitTableView(mode: .user, prevImageCache: prevImageCache, delegate: self)
        
        if let visits = visits {
            self.visits = visits
            self.selectedVisit = selectedVisit
            self.otherUserUsername = otherUserUsername
            self.preLoadedData = true
            self.allowMapButton = false
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    private func getInitialUserVisits() {
        setMapButton(hidden: true)
        if Network.shared.loggedIn {
            Network.shared.getVisitFeed(feedType: .user) { [weak self] (result) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let visits):
                        self.visitTableView?.allowHintToCreateRestaurant = true
                        self.visitTableView?.refreshControl?.endRefreshing()
                        self.visitTableView?.clearCaches()
                        self.visits = visits
                        self.visitTableView?.reloadData()
                        self.setMapButton(hidden: visits.count < 1)
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        } else {
            noUserTableView()
        }
    }
    
    private func setUpTableView() {

        self.view.addSubview(visitTableView!)
        visitTableView!.constrainSides(to: self.view)
        
        showOnMapButton.setTitle("Show on map", for: .normal)
        showOnMapButton.addTarget(self, action: #selector(showOnMapButtonPressed), for: .touchUpInside)
        
        self.view.addSubview(showOnMapButton)
        showOnMapButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        showOnMapButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -((self.tabBarController?.tabBar.bounds.height ?? 0.0) + 10.0)).isActive = true
        
        if !allowMapButton { showOnMapButton.isHidden = true }
        
    }
    
    private func noUserTableView() {
        visitTableView?.layoutIfNeeded()
        self.visitTableView?.allowHintToCreateRestaurant = false
        let createAccountButton = self.visitTableView?.setEmptyWithAction(message: "You need to create an account in order to make posts.", buttonTitle: "Create account", area: .center)
        createAccountButton?.addTarget(self, action: #selector(rightBarButtonItemSelector), for: .touchUpInside)
    }
    
    @objc private func rightBarButtonItemSelector() {
        
        if Network.shared.loggedIn {
            self.navigationController?.pushViewController(SettingsVC(), animated: true)
        } else {
            self.navigationController?.pushViewController(CreateAccountVC(), animated: true)
        }
    }
    
    @objc private func userLoggedIn() {
        visitTableView?.clearCaches()
        DispatchQueue.main.async {
            self.visitTableView?.restore()
        }
        
        getInitialUserVisits()
    }
    
    @objc private func userLoggedOut() {
        visitTableView?.clearCaches()
        visits = []
        visitTableView?.reloadData()
        noUserTableView()
    }
    
    @objc private func showOnMapButtonPressed() {
        let mapProfile = ProfileMapVC()
        self.navigationController?.pushViewController(mapProfile, animated: true)
    }
    
    @objc private func establishmentListPressed() {
        var person: Person? {
            if isOwnUsersProfile {
                guard let account = Network.shared.account else { return nil }
                return Person(account: account)
            } else {
                guard let visit = selectedVisit ?? visits.first else { return nil }
                return Person(visit: visit)
            }
        }
        if let person = person {
            let vc = EstablishmentListVC(person: person)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.showMessage("Not able to show places")
        }
        
    }
    
    private func setMapButton(hidden: Bool) {
        if allowMapButton {
            DispatchQueue.main.async {
                self.showOnMapButton.isHidden = hidden
            }
        }
    }
}

// MARK: VisitTableViewDelegate
extension ProfileHomeVC: VisitTableViewDelegate {
    func refreshControlSelected() {
        getInitialUserVisits()
    }
}
