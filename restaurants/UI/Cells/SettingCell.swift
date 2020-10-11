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
