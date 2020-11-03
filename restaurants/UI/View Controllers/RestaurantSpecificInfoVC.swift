//
//  RestaurantSpecificInfoVC.swift
//  restaurants
//
//  Created by Steven Dito on 7/14/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


class RestaurantSpecificInfoVC: UIViewController {
    
    private var restaurant: Restaurant!
    private var tableView = UITableView(frame: .zero, style: .grouped)
    private let currentWeekday = Date.convertWeekdayFromAppleToStandard(appleDate: Date.getDayOfWeek())
    
    enum ReturnType {
        case hours([Restaurant.SystemTime.Weekday])
        case transactions([Restaurant.YelpTransaction])
    }
    
    enum Sections: CaseIterable {
        case hours
        case transactions
        
        var cellInformation: ReturnType {
            switch self {
            case .hours:
                return ReturnType.hours(Restaurant.SystemTime.Weekday.allCases)
            case .transactions:
                return ReturnType.transactions(Restaurant.YelpTransaction.allCases)
            }
        }
        
        var description: String {
            switch self {
            case .hours:
                return "Hours"
            case .transactions:
                return "Transactions"
            }
        }
    }
    
    
    init(restaurant: Restaurant) {
        super.init(nibName: nil, bundle: nil)
        self.restaurant = restaurant
        setUp(restaurant: restaurant)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarColor()
    }
    
    func setUp(restaurant: Restaurant) {
        self.view.backgroundColor = .systemBackground
        setUpNavigation()
        setUpTableView()
    }
    
    private func setUpNavigation() {
        let navigationHeaderView = NavigationTitleView(upperText: restaurant.name, lowerText: "More info")
        self.navigationItem.titleView = navigationHeaderView
    }
    
    private func setUpTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.constrainSides(to: self.view)
        tableView.allowsSelection = false
    }

}


extension RestaurantSpecificInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = Sections.allCases[section]
        let sectionData = section.cellInformation
        switch sectionData {
        case .hours(let value):
            return value.count
        case .transactions(let value):
            return value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Sections.allCases[indexPath.section]
        let cellInformation = section.cellInformation
        switch cellInformation {
        case .hours(let hours):
            let subtitleCell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            subtitleCell.textLabel?.numberOfLines = 0
            let weekday = hours[indexPath.row]
            if let times = restaurant.systemTime {
                let matchingTimes = times.filter({$0.weekday == weekday})
                let sorted = matchingTimes.sorted { (one, two) -> Bool in
                    one.rawStartValue < two.rawStartValue
                }
                let stringRepresentation = sorted.map({"\($0.start) to \($0.end)"})
                if stringRepresentation.count > 0 {
                    let joinedRepresentation = stringRepresentation.joined(separator: "\n")
                    subtitleCell.textLabel?.text = joinedRepresentation
                } else {
                    subtitleCell.textLabel?.text = "Closed"
                }
                
            } else {
                subtitleCell.textLabel?.text = "No hours found"
            }
            
            subtitleCell.detailTextLabel?.text = "\(weekday.description)"
            subtitleCell.detailTextLabel?.textColor = .secondaryLabel
            
            if weekday == currentWeekday {
                let accessoryImage = UIImage(systemName: "arrowtriangle.left.fill")
                let accessoryImageView = UIImageView(image: accessoryImage)
                accessoryImageView.tintColor = Colors.main
                subtitleCell.accessoryView = accessoryImageView
            }
            
            return subtitleCell
            
        case .transactions(let transactions):
            let defaultCell = UITableViewCell(style: .default, reuseIdentifier: nil)
            let transaction = transactions[indexPath.row]
            let affirmative = restaurant.transactions?.contains(transaction) ?? false
            let cellText = transaction.description.getAffirmativeOrNegativeAttributedString(affirmative)
            defaultCell.textLabel?.attributedText = cellText
            return defaultCell
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = Sections.allCases[section]
        return section.description
    }
    
}
