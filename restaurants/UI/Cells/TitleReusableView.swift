//
//  TitleReusableView.swift
//  restaurants
//
//  Created by Steven Dito on 10/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class TitleReusableView: UICollectionReusableView {
    
    private let label = UILabel()
    let button = UIButton()
    private let constraintDistance: CGFloat = 10.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpElements()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpElements() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.secondarySystemBackground
        
        setUpLabel()
        setUpButton()
    }
    
    private func setUpLabel() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "This is a header"
        label.font = .createdTitle
        
        // to have the label automatically fit the vertical and horizontal space
        label.minimumScaleFactor = 0.1
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byClipping
        label.numberOfLines = 0
        
        self.addSubview(label)
        
        label.constrain(.leading, to: self, .leading, constant: constraintDistance)
        label.constrain(.top, to: self, .top, constant: constraintDistance)
        label.constrain(.bottom, to: self, .bottom, constant: constraintDistance)
    }
    
    private func setUpButton() {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.arrowDownImage, for: .normal)
        button.tintColor = .secondaryLabel
        
        self.addSubview(button)
        
        button.constrain(.leading, to: label, .trailing, constant: constraintDistance)
        button.constrain(.top, to: self, .top, constant: constraintDistance)
        button.constrain(.bottom, to: self, .bottom, constant: constraintDistance)
        button.constrain(.trailing, to: self, .trailing, constant: constraintDistance)
        
        button.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    func setTitle(_ str: String) {
        self.label.text = str
    }
    
}
