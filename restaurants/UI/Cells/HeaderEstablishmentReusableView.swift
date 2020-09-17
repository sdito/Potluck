//
//  HeaderEstablishmentReusableView.swift
//  restaurants
//
//  Created by Steven Dito on 9/6/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class HeaderEstablishmentReusableView: UICollectionReusableView {
    
    private let dateLabel = UILabel()
    private let commentLabel = UILabel()
    private let ratingLabel = UILabel()
    private let container = UIView()
    private let containerStack = UIStackView()
    private var stackConstraint: NSLayoutConstraint?
    private var visit: Visit?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpElements()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpElements() {
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
        
        commentLabel.numberOfLines = 0
        commentLabel.font = .mediumBold
        commentLabel.textColor = .secondaryLabel
        
        setUpClicking()
    }
    
    private func setUpClicking() {
        let layerButton = UIButton()
        layerButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(layerButton)
        self.bringSubviewToFront(layerButton)
        layerButton.constrainSides(to: self)
        layerButton.backgroundColor = .clear
        
        layerButton.addTarget(self, action: #selector(layerButtonAction), for: .touchUpInside)
        layerButton.addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        layerButton.addTarget(self, action: #selector(touchUp), for: [.touchDragExit, .touchUpInside, .touchCancel])
    }
    
    @objc private func layerButtonAction() {
        guard let vc = self.findViewController(), let visit = visit else { return }
        
        vc.actionSheet(actions: [
            ("Edit visit", {[weak self] in vc.actionSheet(actions: [
                ("Edit comment", { [weak self] in visit.changeValueProcess(presentingVC: vc, mode: .textView, enterTextViewDelegate: self) }),
                ("Edit rating", { [weak self] in visit.changeValueProcess(presentingVC: vc, mode: .textView, enterTextViewDelegate: self) })
            ])}),
            ("Delete visit", { [weak self] in vc.alert(title: "Are you sure you want to delete this visit?", message: "This action cannot be undone.") { [weak self] in
                //delegate.delete(visit: self?.visit)
                print("Delete the visit here")
            } })
        ])
    }
    
    @objc private func touchDown() {
        // Transform the view to show it is being selected
        UIView.animate(withDuration: 0.2, animations: {
            self.container.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
    }

    @objc private func touchUp() {
        // Transform the view back to normal
        UIView.animate(withDuration: 0.2, animations: {
            self.container.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func setUp(visit: Visit) {
        self.visit = visit
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


extension HeaderEstablishmentReusableView: EnterValueViewDelegate {
    func textFound(string: String?) {
        print("Text found: \(string)")
    }
    
    func ratingFound(float: Float?) {
        print("Rating found: \(float)")
    }
}
