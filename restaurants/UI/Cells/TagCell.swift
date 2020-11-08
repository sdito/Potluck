//
//  TagCell.swift
//  restaurants
//
//  Created by Steven Dito on 11/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class TagCell: UITableViewCell {
    
    private let stackView = UIStackView()
    private let tagButton = TagButton(title: "Tag name", withImage: false, normal: true)
    private let countLabel = UILabel()
    private let dateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpStackView()
        setUpButton()
        setUpDateLabel()
        setUpCountLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(stackView)
        stackView.constrain(.leading, to: self.contentView, .leading, constant: 10.0)
        stackView.constrain(.trailing, to: self.contentView, .trailing, constant: 10.0)
        stackView.constrain(.top, to: self.contentView, .top, constant: 5.0)
        stackView.constrain(.bottom, to: self.contentView, .bottom, constant: 5.0)
        stackView.axis = .horizontal
        stackView.spacing = 10.0
        stackView.alignment = .fill
        stackView.distribution = .fill
    }
    
    private func setUpButton() {
        tagButton.translatesAutoresizingMaskIntoConstraints = false
        tagButton.titleLabel?.font = .secondaryTitle
        tagButton.isUserInteractionEnabled = false
        stackView.addArrangedSubview(tagButton)
        tagButton.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    private func setUpDateLabel() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .mediumBold
        dateLabel.textAlignment = .right
        dateLabel.textColor = .secondaryLabel
        stackView.addArrangedSubview(dateLabel)
    }
    
    private func setUpCountLabel() {
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.textColor = .label
        countLabel.font = .mediumBold
        stackView.addArrangedSubview(countLabel)
        countLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    func setUpWith(tag: Tag) {
        tagButton.setTitle(tag.display, for: .normal)
        let str = tag.lastUsed?.dateString(style: .short)
        dateLabel.text = str
        countLabel.text = "\(tag.numberOfVisits ?? 0) visits"
    }
}
