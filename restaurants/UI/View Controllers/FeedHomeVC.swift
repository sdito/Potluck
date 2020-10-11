//
//  FeedHomeVC.swift
//  restaurants
//
//  Created by Steven Dito on 9/26/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


class FeedHomeVC: UIViewController {
    
    private var visits: [Visit] = []
    private let tableView = UITableView(frame: .zero, style: .plain)
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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        tableView.constrainSides(to: self.view)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(VisitCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    private func getUserFeed() {
        Network.shared.getVisitFeed(feedType: .friends) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let visits):
                self.visits = visits
                DispatchQueue.main.async {
                    self.tableView.reloadData()
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

// MARK: Table view
extension FeedHomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! VisitCell
        cell.setUpWith(visit: visits[indexPath.row], selectedPhotoIndex: nil)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: VisitCellDelegate
extension FeedHomeVC: VisitCellDelegate {
    
    func delete(visit: Visit?) { return }
    func establishmentSelected(establishment: Establishment) { return }
    func moreImageRequest(visit: Visit?, cell: VisitCell) { return }
    func newPhotoIndexSelected(idx: Int, for visit: Visit?) { return }
    func updatedVisit(visit: Visit) { return }
    
    func personSelected(for visit: Visit) {
        let person = Person(visit: visit)
        let userProfileVC = UserProfileVC(person: person)
        self.navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    
}
