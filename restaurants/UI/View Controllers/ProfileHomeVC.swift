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
    private let tagFilterButton = UIButton()
    private var tagButtons: [TagButton] = []
    private var nextPageCutoff: String?
    
    init(isOwnUsersProfile: Bool, visits: [Visit]?, selectedVisit: Visit? = nil, prevImageCache: NSCache<NSString, UIImage>? = nil, otherPerson: Person? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.isOwnUsersProfile = isOwnUsersProfile
        visitTableView = VisitTableView(mode: .user, prevImageCache: prevImageCache, delegate: self)
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
        setUpFilterTagButton()
        setUpTagPortion()
        setUpTableView()
        handleInitialDataNeeded()
        
        if isOwnUsersProfile {
            setUpScrollAssistantView()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedIn), name: .userLoggedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedOut), name: .userLoggedOut, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tagDeleted(notification:)), name: .standardTagDeleted, object: nil)
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
            setBaseNavigationTitle()
        }
        navigationController?.navigationBar.isTranslucent = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setBaseNavigationTitle() {
        self.navigationItem.title = "Visit feed"
    }
    
    private func handleInitialDataNeeded() {
        if !preLoadedData {
            getUserVisits()
        } else {
            visitTableView?.reloadData()
            if let elementId = selectedVisit?.djangoOwnID, let idx = filteredVisits.map({$0.djangoOwnID}).firstIndex(of: elementId) {
                visitTableView?.visits = filteredVisits
                visitTableView?.layoutIfNeeded()
                let indexPath = IndexPath(row: idx, section: 0)
                DispatchQueue.main.async {
                    self.visitTableView?.scrollToRow(at: indexPath, at: .top, animated: false)
                }
            }
        }
    }
    
    private func setUpWithTags() {
        for view in scrollingStackView.stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        scrollingStackView.stackView.addArrangedSubview(UIView.getSpacerView())
        guard tags.count > 0 else {
            tagFilterButton.isHidden = true
            return
        }
        tagFilterButton.isHidden = false
        
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
    
    private func getUserVisits() {
        if Network.shared.loggedIn {
            Network.shared.getVisitFeed(feedType: .user) { [weak self] (result) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let value):
                        self.allVisits = value.visits
                        self.filteredVisits = value.visits
                        self.tags = value.tags ?? []
                        self.nextPageCutoff = value.date_offset
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
    
    private func getNextVisitPage() {
        guard let dateOffset = nextPageCutoff else { return }
        nextPageCutoff = nil
        
        Network.shared.getVisitFeed(feedType: .user, previousDateOffset: dateOffset) { [weak self] (result) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    self.allVisits.append(contentsOf: value.visits)
                    self.nextPageCutoff = value.date_offset
                    
                    var indexPaths: [IndexPath] = []
                    var index = self.filteredVisits.count
                    for _ in 0..<value.visits.count {
                        indexPaths.append(IndexPath(row: index, section: 0))
                        index += 1
                    }
                    self.filteredVisits.append(contentsOf: value.visits)
                    
                    self.visitTableView?.insertRows(at: indexPaths, with: .automatic)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.visitTableView?.allowNextPage = true
                    }
                    
                case .failure(_):
                    print("Failed getting next page of visits")
                }
            }
        }
    }
    
    private func setUpFilterTagButton() {
        tagFilterButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tagFilterButton)
        tagFilterButton.constrain(.leading, to: self.view, .leading, constant: 5.0)
        tagFilterButton.setTitleColor(.secondaryLabel, for: .normal)
        tagFilterButton.tintColor = .secondaryLabel
        tagFilterButton.setImage(UIImage.filterImage.withConfiguration(.large), for: .normal)
        tagFilterButton.titleLabel?.font = .mediumBold
        tagFilterButton.addTarget(self, action: #selector(filterTagButtonPressed), for: .touchUpInside)
        tagFilterButton.isHidden = true
    }
    
    private func setUpTagPortion() {
        scrollingStackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollingStackView)
        scrollingStackView.constrain(.leading, to: tagFilterButton, .trailing)
        scrollingStackView.constrain(.top, to: self.view, .top)
        scrollingStackView.constrain(.trailing, to: self.view, .trailing)
        
        tagFilterButton.centerYAnchor.constraint(equalTo: scrollingStackView.centerYAnchor).isActive = true
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
    
    private func setUpScrollAssistantView() {
        guard let visitTableView = visitTableView else { return }
        let scrollHelperView = UIView()
        scrollHelperView.translatesAutoresizingMaskIntoConstraints = false
        scrollHelperView.backgroundColor = .clear
        self.view.addSubview(scrollHelperView)
        scrollHelperView.constrain(.top, to: visitTableView, .top)
        scrollHelperView.constrain(.trailing, to: visitTableView, .trailing)
        scrollHelperView.constrain(.bottom, to: visitTableView, .bottom)
        scrollHelperView.widthAnchor.constraint(equalToConstant: 17.5).isActive = true
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
        
        getUserVisits()
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
                guard let visit = selectedVisit ?? filteredVisits.first, let person = visit.person else { return nil }
                return person
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
        let selectedTags = selectedTag == nil ? nil : [selectedTag!]
        self.showTagSelectorView(tags: self.tags, selectedTags: selectedTags, tagSelectorViewDelegate: self)
    }
    
    @objc private func tagDeleted(notification: Notification) {
        if let deletedTag = notification.userInfo?["tag"] as? Tag {
            if let index = tags.firstIndex(of: deletedTag) {
                tags.remove(at: index)
                for button in tagButtons {
                    if button.titleLabel?.text == deletedTag.display {
                        button.removeFromStackViewAnimated(duration: 0.3)
                    }
                }
            }
        }
    }
}

// MARK: VisitTableViewDelegate
extension ProfileHomeVC: VisitTableViewDelegate {
    
    func nextPageRequested() {
        getNextVisitPage()
    }
    
    func refreshControlSelected() {
        setBaseNavigationTitle()
        getUserVisits()
        self.visitTableView?.allowNextPage = true
    }
}

// MARK: TagSelectorViewDelegate
extension ProfileHomeVC: TagSelectorViewDelegate {
    func tagSelected(tag: Tag) {
        tagButtons.forEach { (button) in
            if button.buttonTag == tag {
                tagButtonSelected(sender: button)
                let transferredFrame = scrollingStackView.stackView.convert(button.frame, to: scrollingStackView.scrollView)
                scrollingStackView.scrollView.scrollRectToVisible(transferredFrame, animated: true)
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
    
    func multipleChange(newAdditions: [Tag], newSubtractions: [Tag]) { return }
    
}
