//
//  SearchHelperVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/28/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import MapKit

protocol SearchHelperDelegate: class {
    func textChanged(newString: String)
}

protocol SearchHelperComplete: class {
    func searchFound(search: MKLocalSearchCompletion)
}

class SearchHelperVC: UITableViewController {
    
    private weak var delegate: SearchHelperComplete?
    
    
    private var requestCompleter = MKLocalSearchCompleter()
    private var searchResults: [MKLocalSearchCompletion] = []
    
    init(completionDelegate: UIViewController, mode: Mode) {
        super.init(style: .plain)
        self.delegate = completionDelegate as? SearchHelperComplete
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    enum Mode {
        case allLocations
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        requestCompleter.resultTypes = .address
        requestCompleter.delegate = self
    }

    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = "\(result.title) \(result.subtitle)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = searchResults[indexPath.row]
        self.tableView.isHidden = true
        delegate?.searchFound(search: result)
        self.tableView.layoutIfNeeded()
    }
}


// MARK: Search helper
extension SearchHelperVC: SearchHelperDelegate {
    func textChanged(newString: String) {
        if newString == "" {
            self.tableView.isHidden = true
        } else {
            self.tableView.isHidden = false
            requestCompleter.queryFragment = newString
        }
    }
}

// MARK: MKLocalSearchCompleterDelegate
extension SearchHelperVC: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let results = completer.results
        searchResults = results
        tableView.reloadData()
    }
}

