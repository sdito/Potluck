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
    private var allowPressing = false
    
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
        guard allowPressing else { return }
        guard let vc = self.findViewController(), let visit = visit else { return }
        vc.actionSheet(actions: [
            ("Edit visit", {[weak self] in vc.actionSheet(actions: [
                ("Edit comment", { [weak self] in visit.changeValueProcess(presentingVC: vc, mode: .textView, enterTextViewDelegate: self) }),
                ("Edit rating", { [weak self] in visit.changeValueProcess(presentingVC: vc, mode: .rating, enterTextViewDelegate: self) })
            ])}),
            ("Delete visit", { [weak self] in vc.appAlert(title: "Are you sure you want to delete this visit?", message: "This action cannot be undone.", buttons: [
                ("Cancel", nil),
                ("Delete", { [weak self] in self?.handleDeleting() } )
            ]) })
            
        ])
    }
    
    private func handleDeleting() {
        guard let visit = visit else { return }
        NotificationCenter.default.post(name: .visitDeleted, object: nil, userInfo: ["visit": visit])
        Network.shared.deleteVisit(visit: visit, success: { _ in return })
    }
    
    @objc private func touchDown() {
        guard allowPressing else { return }
        // Transform the view to show it is being selected
        UIView.animate(withDuration: 0.2, animations: {
            self.container.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
    }

    @objc private func touchUp() {
        guard allowPressing else { return }
        // Transform the view back to normal
        UIView.animate(withDuration: 0.2, animations: {
            self.container.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func setUp(visit: Visit, allowPressing: Bool) {
        self.visit = visit
        self.allowPressing = allowPressing
        dateLabel.text = visit.userDateVisited
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
    
    func update(visit: Visit) {
        self.visit = visit
        if let comment = visit.comment {
            commentLabel.text = comment
            commentLabel.isHidden = false
        } else {
            commentLabel.isHidden = true
        }
        
        ratingLabel.attributedText = visit.ratingString
    }
}


// MARK: EnterValueViewDelegate
extension HeaderEstablishmentReusableView: EnterValueViewDelegate {
    func textFound(string: String?) {
        guard let visit = visit else { return }
        visit.comment = string
        self.findViewController()?.showMessage("Comment changed")
        Network.shared.updateVisit(visit: visit, rating: nil, newComment: string, success: { _ in return })
        
        NotificationCenter.default.post(name: .visitUpdated, object: nil, userInfo: ["visit": visit])
    }
    
    func ratingFound(float: Float?) {
        guard let visit = visit, let rating = float else { return }
        visit.rating = Double(String(format: "%.1f", Double(rating)))
        self.findViewController()?.showMessage("Rating changed")
        Network.shared.updateVisit(visit: visit, rating: rating, newComment: nil, success: { _ in return })
        
        NotificationCenter.default.post(name: .visitUpdated, object: nil, userInfo: ["visit": visit])
    }
}
