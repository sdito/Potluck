//
//  SettingCell.swift
//  restaurants
//
//  Created by Steven Dito on 9/23/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {
    
    private var switchAction: (() -> ())?
    private let switchControl = UISwitch()
    
    enum Mode {
        case arrowOpen
        case switchButton
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        self.tintColor = Colors.main
        setUpSwitch()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpSwitch() {
        switchControl.onTintColor = Colors.main
        switchControl.addTarget(self, action: #selector(switchControlSelector), for: .valueChanged)
    }
    
    func setUp(value: Setting.Row) {
        reset()

        textLabel?.text = value.title
        switch value.mode {
        case .arrowOpen:
            self.accessoryType = .disclosureIndicator
            self.detailTextLabel?.text = value.subtitle
            self.detailTextLabel?.textColor = value.color ?? .secondaryLabel
        case .switchButton:
            self.accessoryView = switchControl
            switchAction = value.switchAction
            switchControl.setOn(value.switchValue ?? false, animated: false)
        }
        
        if value.profileImage {
            setUpImageView()
        } else {
            self.imageView?.image = nil
        }
    }
    
    override func layoutSubviews() {
        guard let iv = self.imageView else { return }
        super.layoutSubviews()
        iv.layer.cornerRadius = iv.frame.width / 2
        iv.clipsToBounds = true
    }
    
    private func setUpImageView() {
        guard let imageView = self.imageView else { return }
        imageView.image = Network.shared.account?.actualImage ?? UIImage.personImage.withConfiguration(.large)
        let color = UIColor(hex: Network.shared.account?.color)
        imageView.tintColor = color
        imageView.layer.borderColor = color?.cgColor
        imageView.layer.borderWidth = 1.5
    }
    
    @objc private func switchControlSelector() {
        switchAction?()
    }
    
    private func reset() {
        self.accessoryView = nil
        self.detailTextLabel?.text = nil
        self.textLabel?.text = nil
        self.switchAction = nil
        self.detailTextLabel?.textColor = .secondaryLabel
    }
    

}
