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
    private var askForPhoneButton: UIButton?
    private var pending: [Person.PersonRequest] = []
    private var easyAdd: [Person] = []
    private var askToJoin: [Person] = []
    private let searchBar = UISearchBar()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewAndNavBar()
        setUpSearchBar()
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
        case message = "Ask to join"
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
    
    private func setUpViewAndNavBar() {
        self.view.backgroundColor = .systemBackground
        self.navigationItem.title = "Add friends"
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        self.view.addSubview(stackView)
        stackView.constrainSides(to: self.view)
        
        #warning("maybe delete this")
        let searchItem = UIBarButtonItem(image: .magnifyingGlassImage, style: .plain, target: self, action: #selector(searchBarButtonAction))
        self.navigationItem.rightBarButtonItem = searchItem
    }
    
    private func setUpSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Find friends by username"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = self.view.backgroundColor
        stackView.addArrangedSubview(searchBar)
        searchBar.isHidden = true
    }
    
    private func setUpTableView() {
        tableView.register(PersonCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        stackView.addArrangedSubview(tableView)
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
                
                let requestPhoneNumbers = requests.map({$0.fromPerson.phone}).filter({$0 != nil}).map({$0!})
                userContacts = userContacts.filter({!requestPhoneNumbers.contains($0.phone ?? "")})
                userContacts.sort { (p1, p2) -> Bool in
                    p1.actualName ?? "" < p2.actualName ?? ""
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
    
    @objc private func addPhoneAction(sender: UIButton) {
        self.askForPhoneButton = sender
        self.askForPhoneNumber(delegate: self)
    }
    
    @objc private func searchBarButtonAction() {
        let isNowHidden = !self.searchBar.isHidden
        
        if isNowHidden {
            searchBar.endEditing(true)
        } else {
            searchBar.becomeFirstResponder()
        }
        
        UIView.animate(withDuration: 0.4) {
            self.searchBar.isHidden = isNowHidden
        }
    }
    
}

// MARK: Table view
extension AddFriendsVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Option.allCases.count
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewHeaderFooterView()
        header.textLabel?.text = Option.allCases[section].rawValue.uppercased()
        
        if Option.allCases[section] == .message && Network.shared.account?.phone == nil {
            let button = SizeChangeButton(sizeDifference: .inverse, restingColor: .secondaryLabel, selectedColor: Colors.main)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Add your number", for: .normal)
            
            header.contentView.addSubview(button)
            button.setTitleColor(.secondaryLabel, for: .normal)
            
            button.constrain(.trailing, to: header.contentView, .trailing)
            button.constrain(.top, to: header.contentView, .top)
            button.constrain(.bottom, to: header.contentView, .bottom)
            button.addTarget(self, action: #selector(addPhoneAction(sender:)), for: .touchUpInside)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        }
        
        return header
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !searchBar.isHidden && searchBar.isFirstResponder {
            print("Is shutting down search bar")
            searchBar.endEditing(true)
        }
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
    func editFriendRequest(request: Person.PersonRequest) { return }
}



extension AddFriendsVC: EnterValueViewDelegate {
    func textFound(string: String?) { return }
    func ratingFound(float: Float?) { return }
    
    func phoneFound(string: String?) {
        askForPhoneButton?.isHidden = true
        self.showMessage("Phone number added")
        Network.shared.account?.updatePhone(newPhone: string)
        Network.shared.alterUserPhoneNumber(newNumber: string, complete: { _ in return })
        NotificationCenter.default.post(name: .reloadSettings, object: nil)
    }
}
