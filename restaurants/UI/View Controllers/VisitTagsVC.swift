//
//  VisitTagsVC.swift
//  restaurants
//
//  Created by Steven Dito on 10/29/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


protocol VisitTagsDelegate: class {
    func tagsSelected(tags: [String])
}


class VisitTagsVC: UIViewController {
    
    private weak var delegate: VisitTagsDelegate?
    private var submitTagsOnWillDisappear = true
    private var previousTags: [String]?
    private let searchBar = UISearchBar()
    private let actionButton = SizeChangeButton(sizeDifference: .inverse, restingColor: Colors.main, selectedColor: Colors.main)
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let headerView = HeaderView(leftButtonTitle: "Cancel", rightButtonTitle: "Done", title: "Visit tags")
    private let spacerView = SpacerView(size: 2.0, orientation: .vertical)
    private let addButton = UIButton()
    private var scrollingStackView: ScrollingStackView?
    private let reuseIdentifier = "visitTagsVcReuseIdentifier"
    private let padding: CGFloat = 5.0
    private var tagsDictionary: [String:Network.YelpCategories] = [:]
    private var dictionaryAlphabetKeys: [String] = []
    private var selectedTags = Set<String>()
    private var tagButtons = Set<UIButton>()
    
    init(delegate: VisitTagsDelegate, tags: [String]?) {
        super.init(nibName: nil, bundle: nil)
        self.previousTags = tags
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUpHeader()
        setUpSpacer()
        setUpSearchBar()
        setUpAddButtonOnTopOfSearchBar()
        setUpScrollingStackView()
        setUpTableView()
        setDictionaryForPotentialCategories()
        setUpAlphabetView()
        selectThePreviouslySetTags()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if submitTagsOnWillDisappear {
            delegate?.tagsSelected(tags: selectedTags.sorted())
        }
    }
    
    private func setUpHeader() {
        self.view.addSubview(headerView)
        headerView.constrain(.leading, to: self.view, .leading)
        headerView.constrain(.trailing, to: self.view, .trailing)
        headerView.constrain(.top, to: self.view, .top, constant: 10.0)
        headerView.leftButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        headerView.rightButton.addTarget(self, action: #selector(submitNewTags), for: .touchUpInside)
    }
    
    private func setUpSpacer() {
        self.view.addSubview(spacerView)
        spacerView.constrain(.leading, to: self.view, .leading)
        spacerView.constrain(.trailing, to: self.view, .trailing)
        spacerView.constrain(.top, to: headerView, .bottom, constant: padding)
    }
    
    private func setUpSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(searchBar)
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Filter or add tags"
        searchBar.constrain(.leading, to: self.view, .leading, constant: padding)
        searchBar.constrain(.trailing, to: self.view, .trailing, constant: padding)
        searchBar.constrain(.top, to: spacerView, .bottom)
        searchBar.setImage(UIImage(), for: .clear, state: .normal)
        searchBar.tintColor = Colors.main
        searchBar.delegate = self
    }
    
    private func setUpAddButtonOnTopOfSearchBar() {
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setImage(UIImage.plusImage, for: .normal)
        addButton.tintColor = Colors.main
        searchBar.addSubview(addButton)
        addButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor).isActive = true
        addButton.constrain(.trailing, to: searchBar, .trailing, constant: 15.0)
        addButton.appIsHiddenAnimated(isHidden: true, animated: false)
        addButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
    }
    
    private func setUpScrollingStackView() {
        let placeHolderView = UIView()
        placeHolderView.equalSides(size: 1.0)
        scrollingStackView = ScrollingStackView(subViews: [placeHolderView])
        self.view.addSubview(scrollingStackView!)
        scrollingStackView!.constrain(.leading, to: self.view, .leading)
        scrollingStackView!.constrain(.trailing, to: self.view, .trailing)
        scrollingStackView!.constrain(.top, to: searchBar, .bottom)
    }
    
    private func setUpTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.constrain(.leading, to: self.view, .leading)
        tableView.constrain(.trailing, to: self.view, .trailing)
        tableView.constrain(.bottom, to: self.view, .bottom)
        tableView.constrain(.top, to: scrollingStackView!, .bottom, constant: padding*2)
        tableView.register(CheckBoxCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.allowsMultipleSelection = true
        tableView.showsVerticalScrollIndicator = false
    }
    
    private func setUpAlphabetView() {
        let alphabetView = AlphabetView(delegate: self, alphabetString: dictionaryAlphabetKeys.joined())
        self.view.addSubview(alphabetView)
        alphabetView.constrain(.trailing, to: self.view, .trailing)
        alphabetView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true
    }
    private func selectThePreviouslySetTags() {
        guard let tags = previousTags else { return }
        for tag in tags {
            if let firstLetter = tag.first?.uppercased(),
               let section = dictionaryAlphabetKeys.firstIndex(of: firstLetter),
               let row = tagsDictionary[firstLetter]?.firstIndex(where: {$0.title == tag}) {
                let indexPath = IndexPath(row: row, section: section)
                tableView(tableView, didSelectRowAt: indexPath)
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            } else {
                // just create tag without adding the row, since the row doesn't exist
                addButton(element: tag)
            }
        }
    }
    
    @objc private func dismissView() {
        submitTagsOnWillDisappear = false
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func submitNewTags() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setDictionaryForPotentialCategories() {
        var tagsDictTemp: [String:Network.YelpCategories] = [:]
        for tag in Network.shared.visitTags {
            guard let firstLetter = tag.title.first?.uppercased() else { continue }
            
            if var previousArray = tagsDictTemp[firstLetter] {
                previousArray.append(tag)
                tagsDictTemp[firstLetter] = previousArray
            } else {
                tagsDictTemp[firstLetter] = [tag]
            }
        }
        
        dictionaryAlphabetKeys = tagsDictTemp.keys.sorted()
        // don't need to sort the individual arrays in tagsDictTemp since the input (Network.shared.visitTags) is sorted
        self.tagsDictionary = tagsDictTemp
    }
    
    @objc private func buttonPressed(sender: UIButton) {
        if let buttonTitle = sender.titleLabel?.text, let firstLetter = buttonTitle.first?.uppercased(),
           let section = dictionaryAlphabetKeys.firstIndex(of: firstLetter),
           let row = tagsDictionary[firstLetter]?.firstIndex(where: {$0.title == buttonTitle}) {
            let indexPath = IndexPath(row: row, section: section)
            tableView(tableView, didDeselectRowAt: indexPath)
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            // does not belong on the table view, just remove the button
            handleProcessForDeletingButton(button: sender)
        }
        
    }
    
    @objc private func addButtonPressed() {
        guard let text = searchBar.text else { return }
        addButton(element: text)
        searchBar.text = ""
        searchBar(searchBar, textDidChange: "")
    }
    
    private func handleProcessForDeletingButton(button: UIButton) {
        tagButtons.remove(button)
        UIView.animate(withDuration: 0.3) {
            button.isHidden = true
        } completion: { _ in
            button.removeFromSuperview()
        }
    }
    
    func handleDeletionAndInsertion(indexPath: IndexPath) {
        
        let section = dictionaryAlphabetKeys[indexPath.section]
        let element = tagsDictionary[section]![indexPath.row].title
        if selectedTags.contains(element) {
            selectedTags.remove(element)
            for button in tagButtons {
                guard let title = button.title(for: .normal) else { continue }
                if title == element {
                    handleProcessForDeletingButton(button: button)
                    break
                }
            }
        } else {
            addButton(element: element)
        }
    }
    
    private func addButton(element: String) {
        #warning("scroll to the view tag")
        selectedTags.insert(element)
        let button = TagButton(title: element, withImage: true)
        button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        tagButtons.insert(button)
        button.isHidden = true
        scrollingStackView?.stackView.addArrangedSubview(button)
        UIView.animate(withDuration: 0.3) {
            button.isHidden = false
        }
    }
    
    
    
}


// MARK: Table view
extension VisitTagsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dictionaryAlphabetKeys.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dictionaryAlphabetKeys[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // should do filtered categories
        let section = dictionaryAlphabetKeys[section]
        let sectionArrayCount = tagsDictionary[section]?.count
        return sectionArrayCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! CheckBoxCell
        let section = dictionaryAlphabetKeys[indexPath.section]
        let element = tagsDictionary[section]![indexPath.row].title
        let selected = selectedTags.contains(element)
        cell.setUp(text: element, selected: selected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleDeletionAndInsertion(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        handleDeletionAndInsertion(indexPath: indexPath)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            if searchBar.isFirstResponder {
                searchBar.endEditing(true)
            }
        }
    }
    
}

// MARK: AlphabetViewDelegate
extension VisitTagsVC: AlphabetViewDelegate {
    func letterSelected(_ string: String) {
        // scroll to (without animating) the section of the letter
        guard let section = dictionaryAlphabetKeys.firstIndex(of: string) else { return }
        tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: false)
        print("Letter form AVD: \(string)")
    }
}

// MARK: Search bar
extension VisitTagsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        addButton.appIsHiddenAnimated(isHidden: searchText.count == 0)
        
        // scroll to the correct tag
        #warning("need to complete")
        #warning("need to create an alias i.e. all lowercase, remove all punctuation, replace spaces with underscores")
    }
}
