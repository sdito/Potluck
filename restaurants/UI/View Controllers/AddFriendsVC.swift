//
//  AddFriendsVC.swift
//  restaurants
//
//  Created by Steven Dito on 9/27/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class AddFriendsVC: UIViewController {
    
    private let reuseIdentifier = "personCellReuseIdentifier"
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private var pending: [Person.PersonRequest] = []
    private var easyAdd: [Person] = []
    private var askToJoin: [Person] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.navigationItem.title = "Add friends"
        
        setUpTableView()
        setUpContacts()
        
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedOutSelector), name: .userLoggedOut, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    enum Option: String, CaseIterable {
        case requests = "Pending requests"
        case onApp = "Easy add"
        case message = "Ask to join app"
    }
    
    func rowsPerson(option: Option) -> [Person]? {
        switch option {
        case .onApp:
            return self.easyAdd
        case .message:
            return self.askToJoin
        case .requests:
            return nil
        }
    }
    
    func rowsPersonRequest(option: Option) -> [Person.PersonRequest]? {
        switch option {
        case .onApp, .message:
            return nil
        case .requests:
            return self.pending
        }
    }
    
    private func setUpTableView() {
        tableView.register(PersonCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
        tableView.constrainSides(to: self.view)
    }
    
    private func setUpContacts() {
        
        var userContacts = Person.getUserContacts()
        let numbers = userContacts.map({$0.phone})
        var useNumbers: [String] = []
        for num in numbers {
            if let n = num {
                useNumbers.append(n)
            }
        }
    
        Network.shared.getPeopleToAddForUser(phoneNumbers: useNumbers) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let peopleFeedFound):
                let contactsFound = peopleFeedFound.contactsMatched
                let requests = peopleFeedFound.friendRequests
                
                for contact in contactsFound {
                    if let index = userContacts.firstIndex(where: {$0.phone == contact.phone}) {
                        let removed = userContacts.remove(at: index)
                        contact.actualName = removed.actualName
                    }
                }

                self.askToJoin = userContacts
                self.easyAdd = contactsFound
                self.pending = requests
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            
            case .failure(_):
                print("Failure in getting user contact information")
            }
        }
    }
    @objc private func userLoggedOutSelector() {
        self.navigationController?.popViewController(animated: true)
    }
}


extension AddFriendsVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Option.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Option.allCases[section].rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let option = Option.allCases[section]
        return rowsPerson(option: option)?.count ?? rowsPersonRequest(option: option)?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! PersonCell
        let option = Option.allCases[indexPath.section]
        
        if let person = rowsPerson(option: option)?[indexPath.row] {
            cell.setUpValues(contact: person, delegate: self)
        } else if let personRequest = rowsPersonRequest(option: option)?[indexPath.row] {
            cell.setUpValuesPersonRequest(person: personRequest, delegate: self)
        } else {
            cell.resetValues()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: PersonCellDelegate
extension AddFriendsVC: PersonCellDelegate {
    func requestResponse(request: Person.PersonRequest, accept: Bool) {
        if let index = pending.firstIndex(where: {$0.id == request.id}), let section = Option.allCases.firstIndex(where: {$0 == .requests}) {
            pending.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: index, section: section)], with: .automatic)
            self.showMessage("Request \(accept ? "accepted" : "rejected") from \(request.fromPerson.actualName ?? request.fromPerson.username ?? "user")", on: self)
        }
        
        Network.shared.answerFriendRequest(request: request, accept: accept) { (result) in
            print("Result to accepting request is: \(result)")
        }
    }
    
    func cellSelected(contact: Person?) {
        guard let contact = contact else { return }
        
        if let username = contact.username, let id = contact.id {
            
            print("Need to hide the cell first, and remove from the data source")
            if let index = easyAdd.firstIndex(where: {$0.id == id}), let section = Option.allCases.firstIndex(where: {$0 == .onApp}) {
                easyAdd.remove(at: index)
                tableView.deleteRows(at: [IndexPath(row: index, section: section)], with: .automatic)
                self.showMessage("Sent request to \(contact.actualName ?? username)", on: self)
            }
            
            Network.shared.sendFriendRequest(toPerson: contact) { (done) in
                print("Friend request send, done: \(done)")
            }
            
        } else {
            #warning("need to update this with the app information")
            guard let phone = contact.phone else { return }
            let sms: String = "sms:\(phone)&body=Join me on this app"
            let strURL: String = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            UIApplication.shared.open(URL.init(string: strURL)!, options: [:], completionHandler: nil)
        }
        
        
    }
}

