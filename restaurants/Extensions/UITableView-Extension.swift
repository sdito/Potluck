//
//  UITableView-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 8/25/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

extension UITableView {
    
    func showLoadingOnTableView(middle: Bool = true) {
        let containerView = UIView()
        let loadingView = UIActivityIndicatorView(style: .large)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(loadingView)
        
        loadingView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        if middle {
            loadingView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        } else {
            loadingView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UIScreen.main.bounds.height * 0.05).isActive = true
        }
        
        loadingView.startAnimating()
        self.backgroundView = containerView
        self.separatorStyle = .none
        
    }
    
    enum BackgroundViewArea {
        case top
        case center
        case bottom
    }

    func setEmptyWithAction(message: String, buttonTitle: String, area: BackgroundViewArea) -> UIButton {
        
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
            stack.widthAnchor.constraint(equalToConstant: self.bounds.width * 0.75)
        ])
        
        switch area {
        case .top:
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: UIScreen.main.bounds.height * 0.05).isActive = true
        case .center:
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        case .bottom:
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -(stack.bounds.height + UIScreen.main.bounds.height * 0.3)).isActive = true
        }
        
        
        return button

    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
