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

#warning("show previously used tags from the user at the beginning section of the table view")
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
    private let clearButton = UIButton()
    private var scrollingStackView: ScrollingStackView?
    private let reuseIdentifier = "visitTagsVcReuseIdentifier"
    private let padding: CGFloat = 5.0
    private var tagsDictionary: [String:Network.YelpCategories] = [:]
    private var dictionaryAlphabetKeys: [String] = []
    private var selectedTags = Set<String>() {
        didSet {
            clearButton.appIsHiddenAnimated(isHidden: selectedTags.count == 0)
        }
    }
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
        setUpClearButton()
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
        setUpAddButtonImage()
    }
    
    private func setUpAddButtonOnTopOfSearchBar() {
        addButton.translatesAutoresizingMaskIntoConstraints = false
        searchBar.addSubview(addButton)
        addButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor).isActive = true
        addButton.constrain(.trailing, to: searchBar, .trailing, constant: 15.0)
        addButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
    }
    
    private func setUpAddButtonImage() {
        if searchBar.isEmpty {
            addButton.tintColor = .label
            addButton.setImage(UIImage.recentsImage, for: .normal)
        } else {
            addButton.tintColor = Colors.main
            addButton.setImage(UIImage.plusImage, for: .normal)
        }
    }
    
    private func setUpScrollingStackView() {
        let placeHolderView = UIView()
        placeHolderView.equalSides(size: 1.0)
        scrollingStackView = ScrollingStackView(subViews: [placeHolderView])
        self.view.addSubview(scrollingStackView!)
        scrollingStackView!.constrain(.leading, to: self.view, .leading)
        scrollingStackView!.constrain(.top, to: searchBar, .bottom)
    }
    
    private func setUpClearButton() {
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setImage(.clearImage, for: .normal)
        clearButton.tintColor = Colors.main
        clearButton.setTitleColor(.label, for: .normal)
        self.view.addSubview(clearButton)
        clearButton.constrain(.leading, to: scrollingStackView!, .trailing, constant: 5.0)
        clearButton.constrain(.trailing, to: self.view, .trailing, constant: 10.0)
        clearButton.centerYAnchor.constraint(equalTo: scrollingStackView!.centerYAnchor).isActive = true
        clearButton.addTarget(self, action: #selector(clearButtonPressed), for: .touchUpInside)
        clearButton.isHidden = true
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
        let oneLetterStrings = dictionaryAlphabetKeys.filter({$0.count == 1})
        let alphabetView = AlphabetView(delegate: self, alphabetString: oneLetterStrings.joined())
        self.view.addSubview(alphabetView)
        alphabetView.constrain(.trailing, to: self.view, .trailing)
        alphabetView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true
    }
    private func selectThePreviouslySetTags() {
        guard let tags = previousTags else { return }
        for tag in tags {
            handleAddingTagFromText(tag: tag)
        }
    }
    
    private func handleAddingTagFromText(tag: String) {
        if let firstLetter = tag.first?.uppercased(),
           let section = dictionaryAlphabetKeys.firstIndex(of: firstLetter),
           let row = tagsDictionary[firstLetter]?.firstIndex(where: {$0.title == tag}) {
                let indexPath = IndexPath(row: row, section: section)
                if !(tableView.cellForRow(at: indexPath)?.isSelected ?? false) {
                    tableView(tableView, didSelectRowAt: indexPath)
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
                
        } else {
            // just create tag without adding the row, since the row doesn't exist
            addButton(element: tag)
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
        self.tagsDictionary = tagsDictTemp
    }
    
    @objc private func buttonPressed(sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }
        handleProcessForRemovingTag(tagText: buttonTitle, sender: sender)
    }
    
    private func handleProcessForRemovingTag(tagText: String, sender: UIButton?) {
        if let firstLetter = tagText.first?.uppercased(),
           let section = dictionaryAlphabetKeys.firstIndex(of: firstLetter),
           let row = tagsDictionary[firstLetter]?.firstIndex(where: {$0.title == tagText}) {
            let indexPath = IndexPath(row: row, section: section)
            tableView(tableView, didDeselectRowAt: indexPath)
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            // does not belong on the table view, just remove the button
            selectedTags.remove(tagText)
            if let sender = sender {
                handleProcessForDeletingButton(button: sender)
            } else {
                for button in tagButtons {
                    if let title = button.titleLabel?.text {
                        if title == tagText {
                            handleProcessForDeletingButton(button: button)
                        }
                    }
                }
            }
        }
    }
    
    @objc private func addButtonPressed() {
        if searchBar.isEmpty {
            // have the recents pop up
            let selected = self.selectedTags.map({Tag(display: $0, alias: $0.createTagAlias())})
            self.showTagSelectorView(tags: nil, selectedTags: selected, loadUsersTagsInstead: true, tagSelectorViewDelegate: self)
            
        } else {
            // add the tag
            guard let text = searchBar.text else { return }
            handleAddingTagFromText(tag: text)
            searchBar.text = ""
            searchBar(searchBar, textDidChange: "")
        }
    }
    
    @objc private func clearButtonPressed() {
        for selectedRow in tableView.indexPathsForSelectedRows ?? [] {
            //tableView(tableView, didDeselectRowAt: selectedRow)
            tableView.deselectRow(at: selectedRow, animated: true)
        }
        
        selectedTags.removeAll()
        for button in tagButtons {
            handleProcessForDeletingButton(button: button)
        }
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
                }
            }
        } else {
            addButton(element: element)
        }
    }
    
    private func addButton(element: String) {
        guard let scrollingStackView = scrollingStackView else { return }
        selectedTags.insert(element)
        let button = TagButton(title: element, withImage: true, normal: true)
        button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        tagButtons.insert(button)
        button.isHidden = true
        scrollingStackView.stackView.addArrangedSubview(button)
        
        
        UIView.animate(withDuration: 0.2) {
            button.isHidden = false
        } completion: { _ in
            scrollingStackView.scrollView.scrollRectToVisible(button.frame, animated: true)
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
        searchBar.text = ""
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
        
    }
}

// MARK: Search bar
extension VisitTagsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        setUpAddButtonImage()
        
        // scroll to the correct tag
        guard let firstLetter = searchText.first?.uppercased(), let section = dictionaryAlphabetKeys.firstIndex(of: firstLetter) else { return }
        
        if searchText.count == 1 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: false)
        } else {
            print("Need to scroll more")
            guard let elements = tagsDictionary[firstLetter] else { return }
            let elementNames = elements.map({$0.title.lowercased()})
            let searchTermLower =  searchText.lowercased()
            
            // get the index of the first element that starts with
            if let firstIndex = elementNames.firstIndex(where: {$0.starts(with: searchTermLower)}) {
                tableView.scrollToRow(at: IndexPath(row: firstIndex, section: section), at: .top, animated: false)
            }
        }
    }
}



// MARK: TagSelectorViewDelegate
extension VisitTagsVC: TagSelectorViewDelegate {
    func tagSelected(tag: Tag) { return }
    func clearTag() { return }
    
    func multipleChange(newAdditions: [Tag], newSubtractions: [Tag]) {
        for addition in newAdditions {
            handleAddingTagFromText(tag: addition.display)
        }
        
        for subtraction in newSubtractions {
            handleProcessForRemovingTag(tagText: subtraction.display, sender: nil)
        }
    }
}
