//
//  HeaderEstablishmentReusableView.swift
//  restaurants
//
//  Created by Steven Dito on 9/6/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class HeaderEstablishmentReusableView: UICollectionReusableView {
    
    private var dateLabel = UILabel()
    private var commentLabel = UILabel()
    private var container = UIView()
    private var containerStack = UIStackView()
    private var stackConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpElements()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUpElements() {
        container.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(container)
//        container.constrainSides(to: self, distance: 20.0)
        container.constrain(.leading, to: self, .leading, constant: 20.0)
        container.constrain(.top, to: self, .top, constant: 20.0)
        container.constrain(.trailing, to: self, .trailing, constant: 20.0)
        
        
        container.addSubview(containerStack)
        container.layer.cornerRadius = 10.0
        container.clipsToBounds = true
        container.backgroundColor = .secondarySystemBackground
        
        containerStack.axis = .vertical
        containerStack.spacing = 5.0
        containerStack.distribution = .fill
        containerStack.alignment = .center
        containerStack.constrainSides(to: container, distance: 10.0)
        containerStack.addArrangedSubview(dateLabel)
        containerStack.addArrangedSubview(commentLabel)
        containerStack.addArrangedSubview(UIView())
        
        dateLabel.font = .mediumBold
        commentLabel.numberOfLines = 0
        
        commentLabel.font = .smallBold
        commentLabel.textColor = .secondaryLabel
        dateLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        stackConstraint = containerStack.widthAnchor.constraint(equalToConstant: 100)
        stackConstraint?.isActive = true
    }
    
    func setUp(visit: Visit) {
        dateLabel.text = visit.userDate
        if let comment = visit.comment {
            commentLabel.text = comment
            commentLabel.isHidden = false
        } else {
            commentLabel.isHidden = true
        }
        self.layoutIfNeeded()
        stackConstraint?.constant = dateLabel.bounds.width

    }
    
}
