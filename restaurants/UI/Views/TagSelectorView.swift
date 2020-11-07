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
    
    init(tags: [Tag]?, tagSelectorViewDelegate: TagSelectorViewDelegate) {
        super.init(frame: .zero)
        self.tags = tags?.sorted(by: { (one, two) -> Bool in one.display > two.display }) ?? []
        self.tagSelectorViewDelegate = tagSelectorViewDelegate
        setUpView()
        setUpHeader()
        setUpSpacer()
        setUpTableView()
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
        headerView.rightButton.addTarget(self, action: #selector(clearPressed), for: .touchUpInside)
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
    
    @objc private func cancelPressed() {
        showViewVC?.animateSelectorWithCompletion(completion: { _ in return })
    }
    
    @objc private func clearPressed() {
        showViewVC?.animateSelectorWithCompletion(completion: { [weak self] _ in
            self?.tagSelectorViewDelegate?.clearTag()
        })
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tag = tags[indexPath.row]
        showViewVC?.animateSelectorWithCompletion(completion: { [weak self] _ in
            self?.tagSelectorViewDelegate?.tagSelected(tag: tag)
        })
    }
    
}
