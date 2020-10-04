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
    private let personImageView = UIImageView()
    private let primaryLabel = UILabel()
    private let secondaryLabel = UILabel()
    private let addButton = UIButton()
    private let cancelButton = UIButton()
    private let configuration = UIImage.SymbolConfiguration(scale: .large)
    
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
        
        outerStackView.constrain(.leading, to: self.contentView, .leading, constant: 20.0)
        outerStackView.constrain(.trailing, to: self.contentView, .trailing, constant: 20.0)
        outerStackView.constrain(.top, to: self.contentView, .top, constant: 15.0)
        outerStackView.constrain(.bottom, to: self.contentView, .bottom, constant: 15.0)
    }
    
    private func setUpPersonIcon() {
        let sideSize: CGFloat = 35.0
        personImageView.translatesAutoresizingMaskIntoConstraints = false
        outerStackView.addArrangedSubview(personImageView)
        personImageView.equalSides(size: sideSize)
        personImageView.layer.cornerRadius = sideSize / 2.0
        personImageView.backgroundColor = .secondarySystemBackground
        personImageView.contentMode = .scaleAspectFit
        personImageView.clipsToBounds = true
        personImageView.image = UIImage.personCircleImage.withConfiguration(configuration)
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
        cancelButton.setImage(UIImage.xImage.withConfiguration(configuration), for: .normal)
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
            addButton.setImage(UIImage.plusImage.withConfiguration(configuration), for: .normal)
            addButton.tintColor = UIColor.systemGreen
        } else {
            addButton.setImage(UIImage.messageImage.withConfiguration(configuration), for: .normal)
            addButton.tintColor = .systemBlue
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
        if let message = person.message {
            secondaryLabel.text = message
        }
        setUpProfileIcon(color: contact.color)
        addButton.tintColor = .systemGreen
        addButton.setImage(UIImage.checkImage.withConfiguration(configuration), for: .normal)
        addButton.addTarget(self, action: #selector(requestButtonAction(sender:)), for: .touchUpInside)
        self.cancelButton.isHidden = false
    }
    
    func setUpForSentRequest(request: Person.PersonRequest, delegate: PersonCellDelegate) {
        resetValues()
        self.delegate = delegate
        self.personRequest = request
        let usePerson = request.toPerson
        primaryLabel.text = usePerson.username
        secondaryLabel.text = request.message ?? request.dateAsked.dateString(style: .medium)
        setUpProfileIcon(color: usePerson.color)
        addButton.tintColor = .systemRed
        addButton.setImage(UIImage.trashImage.withConfiguration(configuration), for: .normal)
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
        personImageView.backgroundColor = color
        personImageView.tintColor = color.lighter
    }
    
}
