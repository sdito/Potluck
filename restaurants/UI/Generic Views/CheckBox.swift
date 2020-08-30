//
//  CheckBox.swift
//  restaurants
//
//  Created by Steven Dito on 8/11/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class CheckBox: UIButton {
    
    #warning("see if it is ever used")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setImage(.checked, for: .selected)
        self.setImage(.unchecked, for: .normal)
        self.addTarget(self, action: #selector(pressed), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc private func pressed() {
        self.isSelected = !self.isSelected
    }
    
}
