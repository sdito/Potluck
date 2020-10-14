//
//  EstablishmentListVC.swift
//  restaurants
//
//  Created by Steven Dito on 10/13/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class EstablishmentListVC: UIViewController {
    
    var profile: Person.Profile?
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let reuseIdentifier = "establishmentCellReuseIdentifier"
    
    init(profile: Person.Profile?) {
        super.init(nibName: nil, bundle: nil)
        self.profile = profile
        setUpNavigationBar()
        setUpTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
        let barButtonItem = UIBarButtonItem(image: .filterNoCircleImage, style: .plain, target: self, action: #selector(filterPressed))
        self.navigationItem.rightBarButtonItem = barButtonItem
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
    
}

// MARK: Table view
extension EstablishmentListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        #warning("have screen for when there are no establishments")
        return profile?.establishments?.count ?? 0
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
