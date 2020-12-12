//
//  UserProfileHeaderView.swift
//  restaurants
//
//  Created by Steven Dito on 12/12/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class UserProfileHeaderView: UIView {
    
    private let stackView = UIStackView()
    private let label = UILabel()
    let rightButton = UIButton()
    let leftButton = UIButton()
    private let constraintDistance: CGFloat = 10.0
    let tagButton = TagButton(title: "", withImage: true, normal: true)
    
    
    init() {
        super.init(frame: .zero)
        setUpElements()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpElements() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.systemBackground
        setUpStackView()
        setUpLabel()
        setUpTagButton()
        setUpLeftButton()
        setUpRightButton()
    }
    
    private func setUpStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        stackView.constrainSides(to: self, distance: constraintDistance)
        stackView.spacing = constraintDistance
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
    }
    
    private func setUpLabel() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Visits"
        label.font = .largerBold
        stackView.addArrangedSubview(label)
        label.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    private func setUpTagButton() {
        stackView.addArrangedSubview(tagButton)
        tagButton.setContentHuggingPriority(.required, for: .horizontal)
        tagButton.setContentCompressionResistancePriority(.required, for: .vertical)
        tagButton.alpha = 0.0
    }
    
    private func setUpLeftButton() {
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.setImage(.arrowDownImage, for: .normal)
        leftButton.tintColor = Colors.main
        stackView.addArrangedSubview(leftButton)
        leftButton.contentHorizontalAlignment = .trailing
        leftButton.alpha = 0.0
    }
    
    private func setUpRightButton() {
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.setImage(.filterImage, for: .normal)
        rightButton.setTitle(" TAGS", for: .normal)
        rightButton.setTitleColor(Colors.main, for: .normal)
        rightButton.titleLabel?.font = .smallBold
        rightButton.tintColor = Colors.main
        
        stackView.addArrangedSubview(rightButton)
        rightButton.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    func setTitle(_ str: String) {
        self.label.text = str
    }
    
}
