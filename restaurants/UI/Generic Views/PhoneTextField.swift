//
//  PhoneTextField.swift
//  restaurants
//
//  Created by Steven Dito on 9/28/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import PhoneNumberKit

class PhoneTextField: PhoneNumberTextField {
    
    var phoneNumberValue: String? {
        if let phoneNumber = phoneNumber {
            let formatted = phoneNumberKit.format(phoneNumber, toType: .e164)
            return formatted
        } else {
            return nil
        }
    }
    
    init() {
        super.init(frame: .zero)
        self.tintColor = Colors.main
        self.withExamplePlaceholder = true
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let padding = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    
    
}
