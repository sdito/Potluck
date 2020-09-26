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
    private let reuseIdentifier = "settingCellReuseIdentifier"
    private let infoBackgroundColor = UIColor.systemYellow
    private var dummyView: UIView?
    private var contentOffset: CGFloat?
    private var originalDummyContentOffsetY: CGFloat = 0.0
    var seenBefore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUpTableView()
        navigationItem.title = "Settings"
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSettingsNotification), name: .reloadSettings, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        tableView.constrainSides(to: self.view)
        tableView.register(SettingCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !seenBefore {
            seenBefore = true
            dummyView = tableView.simulateSwipingOnFirstCell(infoBackgroundColor: infoBackgroundColor)
            originalDummyContentOffsetY = dummyView?.frame.origin.y ?? 0.0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        dummyView?.alpha = 0.0
    }
    
    @objc private func reloadSettingsNotification() {
        tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingCell
        let cellRow = Setting.allCases[indexPath.section].rows[indexPath.row]
        cell.setUp(value: cellRow)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = Setting.allCases[indexPath.section].rows[indexPath.row]
        if let selectAction = row.pressAction {
            selectAction()
        }
    }
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .normal, title: "Info", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            let cellRow = Setting.allCases[indexPath.section].rows[indexPath.row]
            self.appAlert(title: cellRow.title, message: cellRow.description, buttons: [
                ("Ok", nil)
            ])
            success(true)
        })
        
        action.backgroundColor = infoBackgroundColor
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            let value = scrollView.contentOffset.y
            if let contentOffset = contentOffset {
                let difference = value - contentOffset
                dummyView?.frame.origin.y = originalDummyContentOffsetY - difference
            } else {
                contentOffset = value
            }
        }
    }
    
}
