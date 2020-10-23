//
//  EstablishmentListVC.swift
//  restaurants
//
//  Created by Steven Dito on 10/13/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class EstablishmentListVC: UIViewController {
    
    var person: Person?
    var profile: Person.Profile?
    var initialDataFound = false
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let listBarButtonItem = UIBarButtonItem(image: .filterNoCircleImage, style: .plain, target: self, action: #selector(filterPressed))
    private let reuseIdentifier = "establishmentCellReuseIdentifier"
    
    init(profile: Person.Profile) {
        super.init(nibName: nil, bundle: nil)
        self.initialDataFound = true
        self.profile = profile
        setUpElements()
    }
    
    init(person: Person) {
        super.init(nibName: nil, bundle: nil)
        self.person = person
        setUpElements()
        handleGettingDataForPerson()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setUpElements() {
        setUpNavigationBar()
        setUpTableView()
    }
    
    private func setUpNavigationBar() {
        // Title
        let places = "Places"
        if let username = profile?.account.username {
            let navigationView = NavigationTitleView(upperText: username, lowerText: places)
            self.navigationItem.titleView = navigationView
        } else {
            self.navigationItem.title = places
        }
        
        // Right bar button item
        handleShowingOrHidingBarButtonItem()
    }
    
    private func setUpTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.constrainSides(to: self.view)
        tableView.tableFooterView = UIView()
        tableView.register(EstablishmentCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    @objc private func filterPressed() {
        self.appActionSheet(buttons: [
            AppAction(title: "Sort by date", action: { [weak self] in self?.completeFilteringByDate() }),
            AppAction(title: "Sort by name", action: { [weak self] in self?.completeFilteringByName() })
        ])
    }
    
    private func completeFilteringByName() {
        profile?.establishments?.sortByName()
        tableView.transitionReload()
    }
    
    private func completeFilteringByDate() {
        profile?.establishments?.sortByFirstVisited()
        tableView.transitionReload()
    }
    
    private func handleGettingDataForPerson() {
        Network.shared.getPersonProfile(person: person) { [weak self] (result) in
            self?.initialDataFound = true
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let profile):
                    self.profile = profile
                    self.tableView.reloadData()
                    self.handleShowingOrHidingBarButtonItem()
                case .failure(_):
                    self.tableView.reloadData()
                    self.handleShowingOrHidingBarButtonItem()
                    print("Unable to get profile for person")
                }
            }
        }
    }
    
    private func handleShowingOrHidingBarButtonItem() {
        let countGreaterThanZero = (profile?.establishments?.count ?? 0) > 0
        if countGreaterThanZero {
            self.navigationItem.rightBarButtonItem = listBarButtonItem
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
}

// MARK: Table view
extension EstablishmentListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = profile?.establishments?.count ?? 0
        
        if count > 0 {
            tableView.restore()
        } else if initialDataFound {
            // received data from server, just is empty
            let button = tableView.setEmptyWithAction(message: "This user does not have any places yet", buttonTitle: "", area: .center)
            button.isHidden = true
        } else {
            tableView.showLoadingOnTableView()
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! EstablishmentCell
        let establishment = profile?.establishments?[indexPath.row]
        cell.setUpWith(establishment: establishment)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let establishment = profile?.establishments?[indexPath.row] else { return }
        let establishmentDetail = EstablishmentDetailVC(establishment: establishment, delegate: nil, mode: .fullScreenBase)
        self.navigationController?.pushViewController(establishmentDetail, animated: true)
    }
    
}
