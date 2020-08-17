//
//  LogInField.swift
//  restaurants
//
//  Created by Steven Dito on 8/15/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class LogInField: UIView {
    
    private let minUsernameLength = 3
    
    var text: String? {
        return textField.text
    }
    
    var isValid: (Bool, errorMessage: String?) {
        var valid = false
        var message: String?
        guard let textFieldText = textField.text else {
            message = "Unable to log in. Please try again."
            return (valid, message)
        }
        switch style {
        case .email:
            valid = isValidText ?? false
            if !valid {
                message = "Your email does not look right. Please fix it and try again."
            }
        case .password:
            if textFieldText.count > 7 {
                valid = true
            } else {
                message = "You need a password at least 8 characters long."
            }
        case .username:
            #warning("need to watch out for emojies and stuff")
            valid = isValidText ?? false
            if !valid {
                message = "Your username needs to be at least \(minUsernameLength) characters long. Please fit it and try again."
            }
        case .none:
            valid = true
        }
        return (valid, message)
    }
    
    private let viewButton = UIButton()
    private let textField = PaddingTextField()
    private var isValidText: Bool?
    
    private var showPasswordText = false {
        didSet {
            switch self.showPasswordText {
            case true:
                textField.isSecureTextEntry = false
                viewButton.isSelected = true
            case false:
                textField.isSecureTextEntry = true
                viewButton.isSelected = false
            }
        }
    }
    
    private var style: Style
    
    enum Style {
        case email
        case password
        case username
        case none
    }
    
    
    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        self.style = .none
        super.init(coder: coder)
    }
    
    func activate() {
        textField.becomeFirstResponder()
    }
    
    private func setUp() {
        self.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        viewButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(textField)
        
        textField.borderStyle = .roundedRect
        textField.constrain(.leading, to: self, .leading)
        textField.constrain(.top, to: self, .top)
        textField.constrain(.bottom, to: self, .bottom)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        
        self.addSubview(viewButton)
        viewButton.equalSides()
        
        viewButton.constrain(.leading, to: textField, .trailing)
        viewButton.constrain(.top, to: self, .top)
        viewButton.constrain(.bottom, to: self, .bottom)
        viewButton.constrain(.trailing, to: self, .trailing)
        
        switch style {
        case .email:
            textField.keyboardType = .emailAddress
            textField.textContentType = .emailAddress
            self.textField.placeholder = "Email address"
            self.textField.addTarget(self, action: #selector(textFieldTextChangedEmail(sender:)), for: .editingChanged)
            viewButton.isUserInteractionEnabled = false
            textFieldTextChangedEmail(sender: textField)
        case .password:
            self.textField.isSecureTextEntry = true
            self.textField.textContentType = .newPassword
            self.textField.placeholder = "Password"
            viewButton.setImage(.eyeImage, for: .normal)
            viewButton.setImage(.eyeSlashImage, for: .selected)
            viewButton.addTarget(self, action: #selector(handleEyePassword), for: .touchUpInside)
            viewButton.tintColor = Colors.main
        case .username:
            self.textField.autocapitalizationType = .none
            self.textField.textContentType = .username

            self.textField.placeholder = "Username"
            self.textField.addTarget(self, action: #selector(textFieldTextChangedUsername(sender:)), for: .editingChanged)
            viewButton.isUserInteractionEnabled = false
            textFieldTextChangedUsername(sender: textField)
        case .none:
            break
        }
        
    }
    
    @objc private func handleEyePassword() {
        showPasswordText = !showPasswordText
    }
    
    @objc private func textFieldTextChangedEmail(sender: UITextField) {
        if let text = sender.text {
            let validEmail = text.isValidEmail()
            if validEmail != isValidText {
                isValidText = validEmail
                changeButton(boolean: validEmail)
            }
        }
    }
    
    
    @objc private func textFieldTextChangedUsername(sender: UITextField) {
        if let text = sender.text {
            let qualifies = text.count >= minUsernameLength
            if qualifies != isValidText {
                isValidText = qualifies
                changeButton(boolean: qualifies)
            }
        }
    }
    
    private func changeButton(boolean: Bool) {
        if boolean {
            viewButton.setImage(.checkImage, for: .normal)
            viewButton.tintColor = .green
        } else {
            viewButton.tintColor = .red
            viewButton.setImage(.xImage, for: .normal)
        }
    }
    
    

}

