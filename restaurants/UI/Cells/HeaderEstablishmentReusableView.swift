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
    private var ratingLabel = UILabel()
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
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(container)

        container.constrain(.leading, to: self, .leading, constant: 20.0)
        container.constrain(.top, to: self, .top, constant: 20.0)
        container.constrain(.trailing, to: self, .trailing, constant: 20.0)
        container.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -20.0).isActive = true
        
        container.addSubview(containerStack)
        container.layer.cornerRadius = 10.0
        container.clipsToBounds = true
        container.backgroundColor = .secondarySystemBackground
        
        containerStack.axis = .vertical
        containerStack.spacing = 10.0
        containerStack.alignment = .center
        containerStack.constrainSides(to: container, distance: 10.0)
        stackConstraint?.isActive = true
        
        containerStack.addArrangedSubview(dateLabel)
        containerStack.addArrangedSubview(ratingLabel)
        containerStack.addArrangedSubview(commentLabel)
        
        dateLabel.font = .largerBold
        dateLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.minimumScaleFactor = 0.5
//        #error("adjust the dateLabel font to automatically fit")
        
        commentLabel.numberOfLines = 0
        commentLabel.font = .mediumBold
        commentLabel.textColor = .secondaryLabel
        
        
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
        ratingLabel.attributedText = visit.ratingString
    }
    
}
