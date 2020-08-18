//
//  SettingsVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/16/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    enum Setting: String, CaseIterable {
        case account = "Account"
        case data = "Data"
        
        var rows: [String] {
            switch self {
            case .account:
                return ["Logout", "Edit account info"]
            case .data:
                return ["Reset all data"]
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUpTableView()
    }
    
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        tableView.constrainSides(to: self.view)
    }
    
    
}


extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Setting.allCases[section].rawValue
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Setting.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Setting.allCases[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let text = Setting.allCases[indexPath.section].rows[indexPath.row]
        cell.textLabel?.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Network.shared.loggedIn {
            Network.shared.account?.logOut()
            self.showMessage("Logged out of account")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
}
