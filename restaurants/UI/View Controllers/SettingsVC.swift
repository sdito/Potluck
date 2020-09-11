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
        case settings = "Settings"
        
        var rows: [Row] {
            switch self {
            case .account:
                return [.logout, .editAccountInfo]
            case .settings:
                return [.resetAllData, .hapticFeedback]
            }
        }
    }
    
    enum Row: String {
        case logout = "Logout"
        case editAccountInfo = "Edit account info"
        case resetAllData = "Reset all data"
        case hapticFeedback = "Enable haptic feedback"
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
        cell.textLabel?.text = text.rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = Setting.allCases[indexPath.section].rows[indexPath.row]
        
        switch row {
        case .logout:
            
            self.alert(title: "Logout", message: "Are you sure you want to log out of your account \(Network.shared.account?.username ?? "now")?") {
                if Network.shared.loggedIn {
                    Network.shared.account?.logOut()
                    self.showMessage("Logged out of account")
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
            
        case .editAccountInfo:
            print("Need to edit account info")
        case .resetAllData:
            print("Need to reset all data")
        case .hapticFeedback:
            print("Need to do haptic feedback")
        }
        
        
    }
    
    
}
