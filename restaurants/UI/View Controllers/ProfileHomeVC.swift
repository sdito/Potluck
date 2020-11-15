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
    private var otherPerson: Person?
    private var visitTableView: VisitTableView?
    private var filteredVisits: [Visit] = [] {
        didSet {
            visitTableView?.visits = filteredVisits
        }
    }
    private var allVisits: [Visit] = []
    private var tags: [Tag] = []
    private var selectedTag: Tag?
    private weak var selectedVisit: Visit?
    private var preLoadedData = false
    private var allowMapButton = true
    private let scrollingStackView = ScrollingStackView(subViews: [UIView.getSpacerView()])
    private var tagButtons: [TagButton] = []
    
    init(isOwnUsersProfile: Bool, visits: [Visit]?, selectedVisit: Visit? = nil, prevImageCache: NSCache<NSString, UIImage>? = nil, otherPerson: Person? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.isOwnUsersProfile = isOwnUsersProfile
        visitTableView = VisitTableView(mode: .user, prevImageCache: prevImageCache, delegate: self)
        #warning("could init with tags from the user here, this is for the non user account, see set up with tags")
        if let visits = visits {
            self.filteredVisits = visits
            self.selectedVisit = selectedVisit
            self.otherPerson = otherPerson
            self.preLoadedData = true
            self.allowMapButton = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUpNavigationBar()
        setUpTagPortion()
        setUpTableView()
        handleInitialDataNeeded()
        
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedIn), name: .userLoggedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedOut), name: .userLoggedOut, object: nil)
    }
    
    private func setUpNavigationBar() {
        self.setNavigationBarColor()
        self.navigationController?.navigationBar.tintColor = Colors.main
        
        // right button
        let rightNavigationButton = UIBarButtonItem(image: .listImage, style: .plain, target: self, action: #selector(establishmentListPressed))
        self.navigationItem.rightBarButtonItem = rightNavigationButton
        
        // left button
        if allowMapButton {
            let leftNavigationButton = UIBarButtonItem(title: "Map", style: .plain, target: self, action: #selector(switchPagePressed))
            self.navigationItem.leftBarButtonItem = leftNavigationButton
        }
        
        // title view
        if let otherPerson = otherPerson {
            let navigationTitleView = NavigationTitleView(upperText: otherPerson.username ?? "User",
                                                          lowerText: "Visits",
                                                          profileImage: .init(url: otherPerson.image, color: otherPerson.color, image: nil))
            navigationItem.titleView = navigationTitleView
        } else {
            navigationItem.title = "Visit feed"
        }
        navigationController?.navigationBar.isTranslucent = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func handleInitialDataNeeded() {
        if !preLoadedData {
            getInitialUserVisits()
        } else {
            visitTableView?.reloadData()
            if let elementId = selectedVisit?.djangoOwnID, let idx = filteredVisits.map({$0.djangoOwnID}).firstIndex(of: elementId) {
                visitTableView?.visits = filteredVisits
                visitTableView?.layoutIfNeeded()
                DispatchQueue.main.async {
                    self.visitTableView?.scrollToRow(at: IndexPath(row: idx, section: 0), at: .top, animated: false)
                }
            }
        }
    }
    
    private func setUpWithTags() {
        
        for view in scrollingStackView.stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        scrollingStackView.stackView.addArrangedSubview(UIView.getSpacerView())
        guard tags.count > 0 else { return }
        let tagButton = UIButton()
        tagButton.translatesAutoresizingMaskIntoConstraints = false
        tagButton.setTitleColor(.secondaryLabel, for: .normal)
        tagButton.tintColor = .secondaryLabel
        tagButton.setImage(UIImage.filterImage.withConfiguration(.large), for: .normal)
        tagButton.titleLabel?.font = .mediumBold
        tagButton.addTarget(self, action: #selector(filterTagButtonPressed), for: .touchUpInside)
        self.scrollingStackView.stackView.addArrangedSubview(tagButton)
        
        for tag in tags {
            let tagButton = TagButton(title: tag.display, withImage: false, normal: true)
            tagButton.addTarget(self, action: #selector(tagButtonSelected(sender:)), for: .touchUpInside)
            tagButton.isHidden = true
            tagButton.buttonTag = tag
            self.scrollingStackView.stackView.addArrangedSubview(tagButton)
            tagButtons.append(tagButton)
            UIView.animate(withDuration: 0.3) {
                tagButton.isHidden = false
            }
        }
    }
    
    private func getInitialUserVisits() {
        if Network.shared.loggedIn {
            Network.shared.getVisitFeed(feedType: .user) { [weak self] (result) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let value):
                        self.allVisits = value.visits
                        self.filteredVisits = value.visits
                        self.tags = value.tags ?? []
                        self.visitTableView?.allowHintToCreateRestaurant = true
                        self.visitTableView?.refreshControl?.endRefreshing()
                        self.visitTableView?.clearCaches()
                        self.visitTableView?.reloadData()
                        self.setUpWithTags()
                    case .failure(_):
                        self.filteredVisits = []
                    }
                }
            }
        } else {
            self.filteredVisits = []
            noUserTableView()
        }
    }
    
    private func setUpTagPortion() {
        scrollingStackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollingStackView)
        scrollingStackView.constrain(.leading, to: self.view, .leading)
        scrollingStackView.constrain(.top, to: self.view, .top)
        scrollingStackView.constrain(.trailing, to: self.view, .trailing)
    }
    
    private func setUpTableView() {
        self.view.addSubview(visitTableView!)
        visitTableView!.constrain(.top, to: scrollingStackView, .bottom, constant: 5.0)
        visitTableView!.constrain(.leading, to: self.view, .leading)
        visitTableView!.constrain(.trailing, to: self.view, .trailing)
        visitTableView!.constrain(.bottom, to: self.view, .bottom)
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
        filteredVisits = []
        allVisits = []
        tags = []
        visitTableView?.reloadData()
        noUserTableView()
        setUpWithTags()
    }
    
    @objc private func showOnMapButtonPressed() {
        let mapProfile = ProfileMapVC()
        self.navigationController?.pushViewController(mapProfile, animated: true)
    }
    
    @objc private func switchPagePressed() {
        guard let tabVC = self.tabBarController as? TabVC else { return }
        tabVC.changeActivePageViewController()
    }
    
    @objc private func establishmentListPressed() {
        var person: Person? {
            if isOwnUsersProfile {
                guard let account = Network.shared.account else { return nil }
                return Person(account: account)
            } else {
                guard let visit = selectedVisit ?? filteredVisits.first else { return nil }
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
    
    @objc private func tagButtonSelected(sender: TagButton) {
        #warning("need to complete -- see comments")
        selectedTag = nil
        guard let tag = sender.buttonTag, let alias = tag.alias else { return }
        var newTitle = "Visit feed"
        if sender.isTagActive {
            sender.setUpForNormal()
            
            // need to clear all the tag filters here
            filteredVisits = allVisits
            visitTableView?.reloadData()
        } else {
            selectedTag = tag
            tagButtons.forEach({$0.setUpForNormal()})
            sender.setUpForSelected()
            newTitle = "(\(tag.display)) Visits"
            
            // need to filter for the tag
            filteredVisits = allVisits.filter({ (v) -> Bool in
                v.tags.contains { (t) -> Bool in
                    t.alias == alias
                }
            })
            visitTableView?.reloadData()
        }
        self.updateNavigationItemTitle(to: newTitle)
    }
    
    @objc private func filterTagButtonPressed() {
        self.showTagSelectorView(tags: self.tags, selectedTag: selectedTag, tagSelectorViewDelegate: self)
    }
}

// MARK: VisitTableViewDelegate
extension ProfileHomeVC: VisitTableViewDelegate {
    func refreshControlSelected() {
        getInitialUserVisits()
    }
}

// MARK: TagSelectorViewDelegate
extension ProfileHomeVC: TagSelectorViewDelegate {
    func tagSelected(tag: Tag) {
        tagButtons.forEach { (button) in
            if button.buttonTag == tag {
                tagButtonSelected(sender: button)
            }
        }
    }
    
    func clearTag() {
        tagButtons.forEach { (button) in
            if button.isTagActive {
                tagButtonSelected(sender: button)
            }
        }
    }
    
}
