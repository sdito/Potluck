//
//  GenericTableVC.swift
//  restaurants
//
//  Created by Steven Dito on 9/30/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class GenericTableVC: UITableViewController {
    
    private var friends: [Person.Friend]?
    
    private var mode: Mode = .friends
    private let reuseIdentifier = "genericTableReuseIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
    }
    
    enum Mode: String {
        case friends = "Friends"
        
        var allowsDeletion: Bool {
            switch self {
            case .friends:
                return true
            }
        }
    }
    
    init(mode: Mode) {
        super.init(nibName: nil, bundle: nil)
        self.mode = mode
        setUp()
    }
    
    private func setUp() {
        tableView.tableFooterView = UIView()
        switch mode {
        case .friends:
            setUpForFriends()
        }
    }
    
    private func setUpForFriends() {
        self.navigationItem.title = mode.rawValue
        self.tableView.register(PersonCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        let rightBarButtonItem = UIBarButtonItem(image: .personBadgeImage, style: .plain, target: self, action: #selector(addFriendsSelector))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        Network.shared.getFriends { [weak self] (result) in
            switch result {
            case .success(let friends):
                self?.friends = friends
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(_):
                print("Didn't get friends")
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func handleDeletion(indexPath: IndexPath) {
        print("Need to handle deletion")
        switch mode {
        case .friends:
            self.appAlert(title: "Delete friendship", message: "Are you sure you want to delete this friendship?", buttons: [
                ("Cancel", nil),
                ("Delete", { [weak self] in
                    guard let self = self else { return }
                    guard let deleted = self.friends?.remove(at: indexPath.row) else { return }
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.showMessage("Deleted \(deleted.friend.username ?? "user")")
                    
                    Network.shared.deleteFriend(friend: deleted, complete: { _ in return })
                    
                })
            ])
        }
    }
    
    @objc private func addFriendsSelector() {
        self.navigationController?.pushViewController(AddFriendsVC(), animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .friends:
            return friends?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        switch mode {
        case .friends:
            if let element = friends?[indexPath.row], let typeCell = cell as? PersonCell {
                typeCell.setUpValuesFriend(friend: element)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if mode.allowsDeletion {
            if editingStyle == .delete {
                handleDeletion(indexPath: indexPath)
            }
        }
    }

}
