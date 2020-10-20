//
//  FilterRestaurantsVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/11/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class FilterRestaurantsVC: UIViewController {
    
    private weak var master: FindRestaurantVC!
    private var previousFilters: [String:Any]!
    private var indexPathsToSelect: Set<IndexPath> = []
    private let checkBoxCellReuse = "checkBoxCellReuse"
    private let executeButton = SizeChangeButton(sizeDifference: .inverse, restingColor: .systemBackground, selectedColor: .systemBackground)
    private let headerLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let spacer = SpacerView(size: 1, orientation: .vertical)
    
    private let cancelTag = 2
    private let resetTag = 3
    
    init(previousFilters: [String:Any], master: FindRestaurantVC) {
        self.previousFilters = previousFilters
        self.master = master
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    enum Section: String, CaseIterable {
        case price = "Price"
        case attributes = "Attributes"
        case hours = "Hours"
        case sort = "Sort by"
        
        var parameterKey: String? {
            switch self {
            case .price:
                return "price"
            case .attributes:
                return "attributes"
            case .hours:
                return nil
            case .sort:
                return "sort_by"
            }
        }
        
        var cellTitleAlias: [(title: String, alias: String?)] {
            switch self {
            case .price:
                return [("$", "1"), ("$$", "2"), ("$$$", "3"), ("$$$$", "4")]
            case .attributes:
                return [("Hot and new", "hot_and_new"),
                        ("Reservation", "reservation"),
                        ("Waitlist reservation", "waitlist_reservation"),
                        ("Gender neutral restrooms", "gender_neutral_restrooms"),
                        ("Cashback", "cashback"),
                        ("Open to all", "open_to_all"),
                        ("Wheelchair accessible", "wheelchair_accessible")]
            case .hours:
                return [("Open now", "open_now")]
            case .sort:
                return [("Rating", "rating"),
                        ("Review count", "review_count"),
                        ("Distance", "distance")]
            }
        }
    }
    
    private func requiresSpecialCollection(section: Section) -> (() -> [String:Any])? {
        switch section {
        case .price:
            return nil
        case .attributes:
            return nil
        case .hours:
            return hoursCollection
        case .sort:
            return nil
        }
    }
    
    private func hoursCollection() -> [String:Any] {
        var tempParams: [String:Any] = [:]
        guard let selectedCells = tableView.indexPathsForSelectedRows else { return tempParams }
        for indexPath in selectedCells {
            if indexPath.section == Section.allCases.firstIndex(of: .hours) {
                let value = Section.hours.cellTitleAlias[indexPath.row]
                if let alias = value.alias, alias == "open_now" {
                    tempParams[alias] = "true"
                } else {
                    fatalError("Need to update hoursCollection in FilterRestaurantsVC")
                }
            }
        }
        return tempParams
    }
    
    private func collectFilters() -> [String:Any] {
        var newParams: [String:Any] = [:]
        //guard let selectedCells = tableView.indexPathsForSelectedRows else { return newParams }
        for (i, section) in Section.allCases.enumerated() {
            if let special = requiresSpecialCollection(section: section) {
                let params = special()
                params.forEach { newParams[$0] = $1 }
            } else {
                let paths = indexPathsToSelect.filter({$0.section == i})
                if paths.count > 0 {
                    var text: [String] = []
                    for path in paths {
                        let index = path.row
                        guard let alias = section.cellTitleAlias[index].alias else { continue }
                        text.append(alias)
                    }
                    if let paramKey = section.parameterKey {
                        print("Section: \(section), text: \(text.joined(separator: ","))")
                        newParams[paramKey] = text.joined(separator: ",")
                    } else {
                        fatalError("collectFilters on FilterRestaurantsVC went wrong")
                    }
                }
            }
        }
        return newParams
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUpHeadPortion()
        setUpTableView()
        setUpExecuteButton()
        setUpPreSetFilters()
    }
    
    
    private func setUpHeadPortion() {
        let headerStack = HeaderView(leftButtonTitle: "Cancel", rightButtonTitle: "Reset", title: "Filter")
        
        headerStack.leftButton.tag = cancelTag
        headerStack.leftButton.addTarget(self, action: #selector(cancelOrResetPressed(sender:)), for: .touchUpInside)
        headerStack.rightButton.tag = resetTag
        headerStack.rightButton.addTarget(self, action: #selector(cancelOrResetPressed(sender:)), for: .touchUpInside)
        
        self.view.addSubview(headerStack)

        headerStack.constrain(.top, to: self.view, .top, constant: 10.0)
        headerStack.constrain(.leading, to: self.view, .leading)
        headerStack.constrain(.trailing, to: self.view, .trailing)

        self.view.addSubview(spacer)

        spacer.constrain(.top, to: headerStack, .bottom, constant: 5.0)
        spacer.constrain(.leading, to: self.view, .leading)
        spacer.constrain(.trailing, to: self.view,  .trailing)
    }
    
    private func setUpTableView() {
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.constrain(.top, to: spacer, .bottom)
        tableView.constrain(.leading, to: view, .leading)
        tableView.constrain(.trailing, to: view, .trailing)
        tableView.allowsMultipleSelection = true
        tableView.register(CheckBoxCell.self, forCellReuseIdentifier: checkBoxCellReuse)
    }
    
    private func setUpPreSetFilters() {
        var valuesNeedSelecting: [String:[String]] = [:]
        
        for key in self.previousFilters.keys {
            guard let value = previousFilters[key] as? String else { continue }
            let filterValues = value.split(separator: ",").map({String($0)})
            valuesNeedSelecting[key] = filterValues
        }
        
        
        for (sectionIndex, section) in Section.allCases.enumerated() {
            for (rowIndex, row) in section.cellTitleAlias.enumerated() {
                if let paramKey = section.parameterKey, let rowVal = row.alias {
                    if let values = valuesNeedSelecting[paramKey], values.contains(rowVal) {
                        indexPathsToSelect.insert(IndexPath(row: rowIndex, section: sectionIndex))
                    }
                } else {
                    if let rowAlias = row.alias {
                        if let values = valuesNeedSelecting[rowAlias], values.contains("true") {
                            indexPathsToSelect.insert(IndexPath(row: rowIndex, section: sectionIndex))
                        }
                    }
                }
            }
        }
        
        for ip in indexPathsToSelect {
            self.tableView.selectRow(at: ip, animated: false, scrollPosition: .none)
            self.handleShowingNotificationLabel()
            
        }
    }
    
    private func setUpExecuteButton() {
        executeButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(executeButton)
        executeButton.constrain(.top, to: tableView, .bottom, constant: 20.0)
        executeButton.constrain(.leading, to: view, .leading, constant: 20.0)
        executeButton.constrain(.trailing, to: view, .trailing, constant: 20.0)
        executeButton.constrain(.bottom, to: view, .bottom, constant: 20.0)
        executeButton.setTitle("Go", for: .normal)
        executeButton.layer.cornerRadius = 8.0
        executeButton.titleLabel?.font = .createdTitle
        executeButton.backgroundColor = Colors.main
        executeButton.addTarget(self, action: #selector(executeFilterPressed), for: .touchUpInside)
    }
    
    @objc private func executeFilterPressed() {
        let params = collectFilters()
        master.searchFilters = params
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc private func cancelOrResetPressed(sender: UIButton) {
        let tag = sender.tag
        if tag == cancelTag {
            self.dismiss(animated: true, completion: nil)
        } else {
            UIDevice.vibrateSelectionChanged()
            executeButton.removeNotificationStyleText()
            
            indexPathsToSelect.forEach { (ip) in
                tableView.deselectRow(at: ip, animated: true)
            }
            indexPathsToSelect.removeAll()
        }
    }
}


extension FilterRestaurantsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section.allCases[section].rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Section.allCases[section].cellTitleAlias.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: checkBoxCellReuse) as! CheckBoxCell
        let text = Section.allCases[indexPath.section].cellTitleAlias[indexPath.row].title
        cell.setUp(text: text, selected: indexPathsToSelect.contains(indexPath))
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for selectedIndexPath in selectedIndexPaths {
                if selectedIndexPath.section == indexPath.section && Section.allCases[indexPath.section] != .attributes {
                    tableView.deselectRow(at: selectedIndexPath, animated: true)
                    indexPathsToSelect.remove(selectedIndexPath)
                }
            }
        }
        return indexPath
    }
    
    private func handleShowingNotificationLabel() {
        executeButton.removeNotificationStyleText()
        if let count = tableView.indexPathsForSelectedRows?.count {
            executeButton.showNotificationStyleText(str: "\(count)")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIDevice.vibrateSelectionChanged()
        indexPathsToSelect.insert(indexPath)
        handleShowingNotificationLabel()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        UIDevice.vibrateSelectionChanged()
        indexPathsToSelect.remove(indexPath)
        handleShowingNotificationLabel()
    }
    
}
