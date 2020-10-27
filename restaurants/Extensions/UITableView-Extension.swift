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
        let animationView = LoaderView(style: .large)
        
        containerView.addSubview(animationView)
        
        animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        if middle {
            animationView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        } else {
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UIScreen.main.bounds.height * 0.05).isActive = true
        }
        
        
        self.backgroundView = containerView
        self.separatorStyle = .none
        
    }
    
    enum BackgroundViewArea {
        case top
        case center
        case bottom
    }
    
    @discardableResult
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
        
        self.backgroundView = container
        self.separatorStyle = .none
        
        return button

    }

    func restore(separatorStyle: UITableViewCell.SeparatorStyle = .singleLine) {
        DispatchQueue.main.async {
            self.backgroundView = nil
            self.separatorStyle = separatorStyle
        }
    }
    
    func transitionReload() {
        UIView.transition(with: self, duration: 0.4, options: .transitionCrossDissolve, animations: { self.reloadData()} , completion: nil)
    }
    
    func simulateSwipingOnFirstCell(infoBackgroundColor: UIColor) -> UIView? {
        // To move the cell to the right to simulate the user is swiping to show info, have to do it this way since cell can't be swiped programmatically
        let animationSwipeSize: CGFloat = 20.0
        let animationDuration: TimeInterval = 1.0
        let animationStartPortion: TimeInterval = 0.4
        let animationDelay: TimeInterval = 0.3
        let finalPortion = animationDuration - animationStartPortion - animationDelay
        
        guard let firstCell = self.cellForRow(at: IndexPath(row: 0, section: 0)) else { return nil }
        guard let tableSuper = self.superview else { return nil }
        firstCell.isUserInteractionEnabled = false
        
        let firstCellFrame = self.convert(firstCell.frame, to: tableSuper)
        
        let dummyView = UIView(frame: CGRect(x: firstCellFrame.origin.x - animationSwipeSize, y: firstCellFrame.origin.y, width: animationSwipeSize, height: firstCellFrame.height))
        dummyView.translatesAutoresizingMaskIntoConstraints = false
        dummyView.backgroundColor = infoBackgroundColor
        tableSuper.addSubview(dummyView)
        
        let transform = CGAffineTransform(translationX: animationSwipeSize, y: 0)
        
        UIView.animateKeyframes(withDuration: animationDuration, delay: 0.1, options: []) {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: animationStartPortion / animationDuration) {
                dummyView.transform = transform
                firstCell.transform = transform
            }
            
            UIView.addKeyframe(withRelativeStartTime: animationStartPortion + animationDelay / animationDuration, relativeDuration: finalPortion / animationDuration) {
                dummyView.transform = .identity
                firstCell.transform = .identity
            }
            
        } completion: { _ in
            dummyView.removeFromSuperview()
            firstCell.isUserInteractionEnabled = true
        }
        
        return dummyView
        
    }
    
}
