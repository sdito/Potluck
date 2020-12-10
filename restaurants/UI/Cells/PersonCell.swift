//
//  PersonCell.swift
//  restaurants
//
//  Created by Steven Dito on 9/27/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


protocol PersonCellDelegate: class {
    func cellSelected(contact: Person?)
    func requestResponse(request: Person.PersonRequest, accept: Bool)
    func editFriendRequest(request: Person.PersonRequest)
}


class PersonCell: UITableViewCell {
    
    private weak var delegate: PersonCellDelegate?
    
    private var contact: Person?
    private var personRequest: Person.PersonRequest?
    private var friend: Person.Friend?
    
    private let outerStackView = UIStackView()
    let personImageView = UIImageView()
    private let primaryLabel = UILabel()
    private let secondaryLabel = UILabel()
    private let addButton = UIButton()
    private let cancelButton = UIButton()
    
    private let acceptTag = 700
    private let declineTag = 7001
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        self.tintColor = Colors.main
        setUpElements()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpElements() {
        setUpStackView()
        setUpPersonIcon()
        setUpLabels()
        setUpButtons()
    }
    
    private func setUpStackView() {
        outerStackView.translatesAutoresizingMaskIntoConstraints = false
        outerStackView.axis = .horizontal
        outerStackView.spacing = 25.0
        outerStackView.alignment = .center
        outerStackView.distribution = .fill
        self.contentView.addSubview(outerStackView)
        
        let priority = UILayoutPriority(999.0)
        outerStackView.constrain(.leading, to: self.contentView, .leading, constant: 20.0, priority: priority)
        outerStackView.constrain(.trailing, to: self.contentView, .trailing, constant: 20.0, priority: priority)
        outerStackView.constrain(.top, to: self.contentView, .top, constant: 15.0, priority: priority)
        outerStackView.constrain(.bottom, to: self.contentView, .bottom, constant: 15.0, priority: priority)
    }
    
    private func setUpPersonIcon() {
        
        personImageView.translatesAutoresizingMaskIntoConstraints = false
        outerStackView.addArrangedSubview(personImageView)
        
        personImageView.backgroundColor = .secondarySystemBackground
        personImageView.contentMode = .scaleAspectFit
        personImageView.clipsToBounds = true
        
        let sideSize: CGFloat = 40.0
        personImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        personImageView.equalSides(size: sideSize)
        personImageView.layer.cornerRadius = sideSize / 2.0
        personImageView.layer.borderWidth = 1.5
    }
    
    private func setUpLabels() {
        primaryLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        primaryLabel.font = .largerBold
        primaryLabel.textColor = .label
        
        secondaryLabel.textColor = .secondaryLabel
        
        let labelStackView = UIStackView(arrangedSubviews: [primaryLabel, secondaryLabel])
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.axis = .vertical
        labelStackView.alignment = .leading
        labelStackView.distribution = .fill
        outerStackView.addArrangedSubview(labelStackView)
    }
    
    private func setUpButtons() {
        
        let buttonStackView = UIStackView(arrangedSubviews: [cancelButton, addButton])
        self.outerStackView.addArrangedSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        buttonStackView.alignment = .center
        buttonStackView.spacing = 10.0
        buttonStackView.axis = .horizontal
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.tag = acceptTag
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.tintColor = .systemRed
        cancelButton.setImage(UIImage.xImage.withConfiguration(.large), for: .normal)
        cancelButton.addTarget(self, action: #selector(requestButtonAction(sender:)), for: .touchUpInside)
        cancelButton.tag = declineTag
    }
    
    @objc private func buttonAction() {
        delegate?.cellSelected(contact: contact)
    }
    
    @objc private func requestButtonAction(sender: UIButton) {
        guard let personRequest = personRequest else { return }
        if sender.tag == acceptTag {
            delegate?.requestResponse(request: personRequest, accept: true)
        } else {
            delegate?.requestResponse(request: personRequest, accept: false)
        }
    }
    
    @objc private func deleteRequestButtonSelected() {
        guard let req = personRequest else { return }
        delegate?.editFriendRequest(request: req)
    }
    
    func setUpValues(contact: Person, delegate: PersonCellDelegate) {
        resetValues()
        self.contact = contact
        self.delegate = delegate
        
        if let actualName = contact.actualName {
            primaryLabel.text = actualName
            if let username = contact.username {
                secondaryLabel.text = username
            } else {
                secondaryLabel.text = contact.phone
            }
        } else {
            primaryLabel.text = contact.username
        }
        
        setUpProfileIcon(color: contact.color)
        addButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        if contact.username != nil {
            addButton.setImage(UIImage.plusImage.withConfiguration(.large), for: .normal)
            addButton.tintColor = UIColor.systemGreen
        } else {
            addButton.setImage(UIImage.messageImage.withConfiguration(.large), for: .normal)
            addButton.tintColor = .systemBlue
        }
        setUpAllowInteraction(person: contact)
        
        if let data = contact.imageData, let image = UIImage(data: data) {
            personImageView.image = image
        } else {
            personImageView.image = UIImage.personImage.withConfiguration(.large)
        }
    }
    
    func setUpValuesPersonRequest(person: Person.PersonRequest, delegate: PersonCellDelegate) {
        resetValues()
        self.personRequest = person
        self.delegate = delegate
        let contact = person.fromPerson
        if let username = contact.username {
            primaryLabel.text = username
        }
        
        secondaryLabel.text = "Received \(person.dateAsked.dateString(style: .short))"
        
        setUpProfileIcon(color: contact.color)
        addButton.tintColor = .systemGreen
        addButton.setImage(UIImage.checkImage.withConfiguration(.large), for: .normal)
        addButton.addTarget(self, action: #selector(requestButtonAction(sender:)), for: .touchUpInside)
        self.cancelButton.isHidden = false
    }
    
    func setUpForSentRequest(request: Person.PersonRequest, delegate: PersonCellDelegate) {
        resetValues()
        self.delegate = delegate
        self.personRequest = request
        let usePerson = request.toPerson
        primaryLabel.text = usePerson.username
        secondaryLabel.text = "Sent \(request.dateAsked.dateString(style: .short))"
        setUpProfileIcon(color: usePerson.color)
        addButton.tintColor = .systemRed
        addButton.setImage(UIImage.trashImage.withConfiguration(.large), for: .normal)
        addButton.addTarget(self, action: #selector(deleteRequestButtonSelected), for: .touchUpInside)
    }
    
    func setUpValuesFriend(friend: Person.Friend) {
        resetValues()
        self.friend = friend
        if let username = friend.friend.username {
            primaryLabel.text = username
        }
        secondaryLabel.text = "Friends since \(friend.date.dateString(style: .medium))"
        setUpProfileIcon(color: friend.friend.color)
    }
    
    func resetValues() {
        self.contact = nil
        self.personRequest = nil
        self.friend = nil
        self.delegate = nil
        self.primaryLabel.text = nil
        self.secondaryLabel.text = nil
        self.cancelButton.isHidden = true
        self.addButton.setImage(UIImage(), for: .normal)
        self.addButton.removeTarget(self, action: #selector(buttonAction), for: .allEvents)
    }
    
    private func setUpProfileIcon(color: UIColor) {
        personImageView.tintColor = color
        personImageView.layer.borderColor = color.cgColor
        personImageView.image = UIImage.personImage.withConfiguration(.large)
    }
    
    private func setUpAllowInteraction(person: Person) {
        if person.alreadyInteracted {
            addButton.alpha = 0.0
            cancelButton.alpha = 0.0
            
            addButton.isUserInteractionEnabled = false
            cancelButton.isUserInteractionEnabled = false
        } else {
            addButton.alpha = 1.0
            cancelButton.alpha = 1.0
            
            addButton.isUserInteractionEnabled = true
            cancelButton.isUserInteractionEnabled = true
        }
    }
    
}
