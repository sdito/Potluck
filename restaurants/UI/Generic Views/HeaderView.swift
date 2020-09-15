//
//  HeaderView.swift
//  restaurants
//
//  Created by Steven Dito on 8/28/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class HeaderView: UIStackView {
    
    let leftButton = SizeChangeButton(sizeDifference: .medium, restingColor: Colors.secondary, selectedColor: Colors.main)
    let rightButton = SizeChangeButton(sizeDifference: .medium, restingColor: Colors.secondary, selectedColor: Colors.main)
    private let rightStack = UIStackView()
    private let inset: CGFloat = 15.0
    let headerLabel = UILabel()
    
    init(leftButtonTitle: String = "Cancel", rightButtonTitle: String, title: String) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .horizontal
        self.distribution = .fill
        self.spacing = 10.0
        
        leftButton.setTitle(leftButtonTitle, for: .normal)
        leftButton.titleLabel?.font = .largerBold
        self.addArrangedSubview(leftButton)
        leftButton.titleEdgeInsets.left = inset
        leftButton.imageEdgeInsets.left = inset
        leftButton.contentHorizontalAlignment = .left
        
        
        // wrap right button in a stack view to allow multiple buttons on the right side
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        self.addArrangedSubview(rightStack)
        rightStack.widthAnchor.constraint(equalTo: leftButton.widthAnchor).isActive = true
        rightStack.distribution = .fill
        rightStack.axis = .horizontal
        rightStack.spacing = 5.0
        
        // placeholder at beginning
        rightStack.addArrangedSubview(UIView())
        // placeholder at end
        let placeHolder = UIView()
        placeHolder.translatesAutoresizingMaskIntoConstraints = false
        placeHolder.widthAnchor.constraint(equalToConstant: inset).isActive = true
        rightStack.addArrangedSubview(placeHolder)
        
        rightButton.setTitle(rightButtonTitle, for: .normal)
        rightButton.titleLabel?.font = .largerBold
        rightStack.insertArrangedSubview(rightButton, at: 1)
        rightButton.contentHorizontalAlignment = .right
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text = title
        headerLabel.font = .createdTitle
        headerLabel.textAlignment = .center
        headerLabel.minimumScaleFactor = 0.8
        headerLabel.adjustsFontSizeToFitWidth = true
        
        rightStack.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        self.insertArrangedSubview(headerLabel, at: 1)
    }
    
    func insertButtonAtEnd(with image: UIImage) -> UIButton {
        let indexForRight = rightStack.arrangedSubviews.firstIndex(of: rightButton) ?? -1
        let button = SizeChangeButton(sizeDifference: .medium, restingColor: Colors.secondary, selectedColor: Colors.main)
        button.setImage(image, for: .normal)
        button.tintColor = Colors.main
        rightStack.insertArrangedSubview(button, at: indexForRight + 1)
        return button
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
