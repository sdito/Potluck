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
    private var requests: [Person.PersonRequest]?
    
    private var mode: Mode = .friends
    private let reuseIdentifier = "genericTableReuseIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    enum Mode: String {
        case friends = "Friends"
        case requestsSent = "Requests sent"
        case requestsReceived = "Requests received"
        
        var allowsDeletion: Bool {
            switch self {
            case .friends:
                return true
            case .requestsSent, .requestsReceived:
                return false
            }
        }
        
        var noneMessage: String {
            switch self {
            case .friends:
                return "No friends yet"
            case .requestsSent:
                return "No pending requests sent"
            case .requestsReceived:
                return "No pending requests received"
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
        self.navigationItem.title = mode.rawValue
        self.tableView.register(PersonCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.showLoadingOnTableView(middle: true)
        
        switch mode {
        case .friends:
            setUpForFriends()
        case .requestsSent:
            setUpForRequestsSent()
        case .requestsReceived:
            setUpForRequestsReceived()
        }
    }
    
    private func setUpForFriends() {
        let rightBarButtonItem = UIBarButtonItem(image: .personBadgeImage, style: .plain, target: self, action: #selector(addFriendsSelector))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        NotificationCenter.default.addObserver(self, selector: #selector(friendIdRemoved(notification:)), name: .friendshipIdRemoved, object: nil)
        Network.shared.getFriends { [weak self] (result) in
            switch result {
            case .success(let friends):
                self?.friends = friends
                DispatchQueue.main.async {
                    self?.reloadTableView()
                }
            case .failure(_):
                print("Didn't get friends")
            }
        }
    }
    
    private func setUpForRequestsSent() {
        Network.shared.getFriendRequests(sent: true) { [weak self] (result) in
            self?.handleRequestResult(result: result)
        }
    }
    
    private func setUpForRequestsReceived() {
        Network.shared.getFriendRequests(received: true) { [weak self] (result) in
            self?.handleRequestResult(result: result)
        }
    }
    
    private func handleRequestResult(result: Result<[Person.PersonRequest], Errors.Friends>) {
        switch result {
        case .success(let requests):
            self.requests = requests
            DispatchQueue.main.async {
                self.reloadTableView()
            }
        case .failure(_):
            print("Didn't get sent friend requests")
        }
    }
    
    private func reloadTableView() {
        
        tableView.reloadData()
        
        if tableView(tableView, numberOfRowsInSection: 0) == 0 {
            print("Number of rows in section: \(tableView(tableView, numberOfRowsInSection: 0) == 0)")
            let b = tableView.setEmptyWithAction(message: mode.noneMessage, buttonTitle: "", area: .center)
            b.isHidden = true
        } else {
            tableView.restore()
        }
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func handleDeletion(indexPath: IndexPath) {
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
        case .requestsSent, .requestsReceived:
            return
        }
    }
    
    @objc private func addFriendsSelector() {
        self.navigationController?.pushViewController(AddFriendsVC(), animated: true)
    }
    
    @objc private func friendIdRemoved(notification: Notification) {
        guard let id = notification.userInfo?["friendshipId"] as? Int else { return }
        guard let removedFriendship = friends?.removeAll(where: {$0.friendID == id}) else { return }
    }
    
    // MARK: Table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int {
            switch mode {
            case .friends:
                return friends?.count ?? 0
            case .requestsSent, .requestsReceived:
                return requests?.count ?? 0
            }
        }
        
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! PersonCell
        
        switch mode {
        case .friends:
            if let element = friends?[indexPath.row]  {
                cell.setUpValuesFriend(friend: element)
            }
        case .requestsSent:
            if let element = requests?[indexPath.row] {
                cell.setUpForSentRequest(request: element, delegate: self)
            }
        case .requestsReceived:
            if let element = requests?[indexPath.row] {
                cell.setUpValuesPersonRequest(person: element, delegate: self)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var person: Person?
        #warning("need to do")
        if let element = friends?.appAtIndex(indexPath.row) {
            person = element.friend
        } else if let element = requests?.appAtIndex(indexPath.row) {
            if let notUser = element.notUser {
                person = notUser
            }
        }
        
        guard let p = person, p.id != nil else { return }
        navigationController?.pushViewController(UserProfileVC(person: p), animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        handleDeletion(indexPath: indexPath)
        
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if mode.allowsDeletion {
            return .delete
        } else {
            return .none
        }
    }
}

// MARK: PersonCellDelegate
extension GenericTableVC: PersonCellDelegate {
    func cellSelected(contact: Person?) { return }
    
    func requestResponse(request: Person.PersonRequest, accept: Bool) {
        print("Request response received from delegate, need to accept?: \(accept)")
        
        if let index = requests?.firstIndex(where: {$0.id == request.id}) {
            requests?.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.showMessage("Request \(accept ? "accepted" : "rejected") from \(request.fromPerson.actualName ?? request.fromPerson.username ?? "user")", on: self)
        }
        
        Network.shared.answerFriendRequest(request: request, accept: accept) { (result) in
            print("Result to accepting request is: \(result)")
        }
        
    }
    
    func editFriendRequest(request: Person.PersonRequest) {
        self.appAlert(title: "Delete", message: "Are you sure you want to cancel the friend request you sent to \(request.toPerson.username ?? "this user")?", buttons: [
            ("Back", nil),
            ("Delete", { [weak self] in
                if let index = self?.requests?.firstIndex(where: {$0.id == request.id}) {
                    self?.requests?.remove(at: index)
                    self?.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    Network.shared.rescindFriendRequest(request: request, complete: { _ in return })
                }
            })
        ])
    }
}

