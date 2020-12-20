//
//  TagSelectorView.swift
//  restaurants
//
//  Created by Steven Dito on 11/4/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


protocol TagSelectorViewDelegate: class {
    func tagSelected(tag: Tag)
    func clearTag()
    func multipleChange(newAdditions: [Tag], newSubtractions: [Tag])
}


class TagSelectorView: UIView {
    
    private var tags: [Tag] = []
    private let tableView = UITableView()
    private let headerView = HeaderView(leftButtonTitle: "Cancel", rightButtonTitle: "Clear", title: "Select")
    private let spacerView = SpacerView(size: 2.0, orientation: .vertical)
    private let reuseIdentifier = "tagSelectorReuseIdentifier"
    private weak var tagSelectorViewDelegate: TagSelectorViewDelegate?
    private let spacerPadding: CGFloat = 5.0
    weak var showViewVC: ShowViewVC?
    private var selectedTags: [Tag]?
    private var selectMultipleMode = false
    
    init(tags: [Tag]?, selectedTags: [Tag]?, loadUsersTagsInstead: Bool = false, tagSelectorViewDelegate: TagSelectorViewDelegate) {
        super.init(frame: .zero)
        self.tags = tags ?? []
        self.tagSelectorViewDelegate = tagSelectorViewDelegate
        self.selectMultipleMode = loadUsersTagsInstead
        setUpView()
        setUpHeader()
        setUpSpacer()
        setUpTableView()
        setUpSelectedRow()
        NotificationCenter.default.addObserver(self, selector: #selector(tagDeleted(notification:)), name: .standardTagDeleted, object: nil)
        
        if loadUsersTagsInstead {
            tableView.allowsMultipleSelection = true
            headerView.headerLabel.text = "Recents"
            headerView.rightButton.setTitle("Done", for: .normal)
            getUsersTags(previouslySelectedTags: selectedTags)
        } else {
            self.selectedTags = selectedTags
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .systemBackground
        self.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8).isActive = true
        self.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.9).isActive = true
        self.layer.cornerRadius = 20.0
        self.clipsToBounds = true
    }
    
    private func setUpHeader() {
        self.addSubview(headerView)
        headerView.headerLabel.font = .largerBold
        headerView.leftButton.titleLabel?.font = .mediumBold
        headerView.rightButton.titleLabel?.font = .mediumBold
        
        headerView.constrain(.leading, to: self, .leading)
        headerView.constrain(.top, to: self, .top, constant: 10)
        headerView.constrain(.trailing, to: self, .trailing)
        
        headerView.leftButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        headerView.rightButton.addTarget(self, action: #selector(rightButtonPressed), for: .touchUpInside)
    }
    
    private func setUpSpacer() {
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(spacerView)
        spacerView.constrain(.leading, to: self, .leading)
        spacerView.constrain(.trailing, to: self, .trailing)
        spacerView.constrain(.top, to: headerView, .bottom, constant: spacerPadding)
    }
    
    private func setUpTableView() {
        self.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.constrain(.top, to: spacerView, .bottom, constant: 0.0)
        tableView.constrain(.leading, to: self, .leading)
        tableView.constrain(.trailing, to: self, .trailing)
        tableView.constrain(.bottom, to: self, .bottom)
        tableView.register(TagCell.self, forCellReuseIdentifier: reuseIdentifier)
        
    }
    
    private func setUpSelectedRow() {
        guard let selectedTags = selectedTags else { return }
        for tag in selectedTags {
            guard let tagAlias = tag.alias else { continue }
            if let selectedIndex = tags.firstIndex(where: {$0.alias == tagAlias}) {
                print(selectedIndex)
                tableView.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .none)
            }
        }
    }
    
    @objc private func cancelPressed() {
        showViewVC?.animateSelectorWithCompletion(completion: { _ in return })
    }
    
    @objc private func rightButtonPressed() {
        if selectMultipleMode {
            let (additions, subtractions) = getTagChangesForMultipleMode()
            tagSelectorViewDelegate?.multipleChange(newAdditions: additions, newSubtractions: subtractions)
            showViewVC?.animateSelectorWithCompletion(completion: { _ in return })
        } else {
            showViewVC?.animateSelectorWithCompletion(completion: { [weak self] _ in
                self?.tagSelectorViewDelegate?.clearTag()
            })
        }
    }
    
    private func getTagChangesForMultipleMode() -> (additions: [Tag], subtractions: [Tag]) {
        let currentlySelectedIndexes = (tableView.indexPathsForSelectedRows ?? []).map({$0.row})
        
        let currentlySelectedTags = tags.itemsAtIndices(currentlySelectedIndexes)
        let previouslySelectedTags = selectedTags ?? []
        
        let currentlySelectedAliases = currentlySelectedTags.map({$0.alias ?? $0.display.createTagAlias()})
        let previouslySelectedAliases = previouslySelectedTags.map({$0.alias ?? $0.display.createTagAlias()})
        
        var newAdditions: [Tag] = []
        var newSubtractions: [Tag] = []
        
        for tag in currentlySelectedTags {
            guard let tagAlias = tag.alias else { continue }
            if !previouslySelectedAliases.contains(tagAlias) {
                newAdditions.append(tag)
            }
        }
        
        for tag in previouslySelectedTags {
            guard let tagAlias = tag.alias else { continue }
            if !currentlySelectedAliases.contains(tagAlias) {
                newSubtractions.append(tag)
            }
        }
        return (newAdditions, newSubtractions)
    }
    
    private func getUsersTags(previouslySelectedTags: [Tag]?) {
        tableView.showLoadingOnTableView()
        Network.shared.getUsersStandardTags { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let tags):
                self.tags = tags
                
                // previously selected tags should be ones that exist in table view
                var tempPrevTags: [Tag] = []
                let tagsAliases = tags.map({$0.alias ?? $0.display.createTagAlias()})
                for tag in previouslySelectedTags ?? [] {
                    let tagAlias = tag.alias ?? tag.display.createTagAlias()
                    if tagsAliases.contains(tagAlias) {
                        tempPrevTags.append(tag)
                    }
                }
                
                self.selectedTags = tempPrevTags
                
                DispatchQueue.main.async {
                    self.tableView.restore(separatorStyle: .none)
                    self.tableView.reloadData()
                    self.setUpSelectedRow()
                }
            case .failure(_):
                print("Failure")
            }
        }
    }
    
    @objc private func tagDeleted(notification: Notification) {
        print("Tag deleted notification on TagSelectorView")
        if let deletedTag = notification.userInfo?["tag"] as? Tag {
            if let index = tags.firstIndex(of: deletedTag) {
                tags.remove(at: index)
                tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }
    
}


// MARK: Table view
extension TagSelectorView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TagCell
        let tag = tags[indexPath.row]
        cell.setUpWith(tag: tag)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if !selectMultipleMode {
            guard let cell = tableView.cellForRow(at: indexPath), !cell.isSelected else {
                rightButtonPressed()
                tableView.deselectRow(at: indexPath, animated: true)
                return nil
            }
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !selectMultipleMode {
            let tag = tags[indexPath.row]
            
            showViewVC?.animateSelectorWithCompletion(completion: { [weak self] _ in
                self?.tagSelectorViewDelegate?.tagSelected(tag: tag)
            })
        }
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        #warning("need to finish and implement")
        guard let vc = self.findViewController(), let tag = tags.appAtIndex(indexPath.row) else { return }
        vc.appAlert(title: "Delete tag", message: "Are you sure you want to delete the \(tag.display) tag? This will delete the tag from all visits that have it. The visits will not be deleted.", buttons: [
            ("Cancel", nil),
            ("Delete", {
                print("Delete the tag")
                Network.shared.deleteStandardTag(tag: tag) { (done) in
                    print("Deleting tag success: \(done)")
                }
            })
        ])
    }
    
}
