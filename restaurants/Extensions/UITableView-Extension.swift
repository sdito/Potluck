//
//  UITableView-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 8/25/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

extension UITableView {

    func setEmptyWithAction(message: String, buttonTitle: String) -> UIButton {
        
        let container = UIView()

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 25.0
        container.addSubview(stack)
        
        let label = UILabel()
        label.font = .largerBold
        label.text = message
        label.textAlignment = .center
        label.numberOfLines = 0
        
        let button = SizeChangeButton(sizeDifference: .large, restingColor: .secondaryLabel, selectedColor: Colors.main)
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .largerBold
        
        
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(button)
        
        self.backgroundView = container
        self.separatorStyle = .none
        
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            stack.widthAnchor.constraint(equalToConstant: self.bounds.width * 0.75)
        ])
        
        return button

    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
