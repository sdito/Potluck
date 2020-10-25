//
//  LogInField.swift
//  restaurants
//
//  Created by Steven Dito on 8/15/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


protocol LogInFieldDelegate: class {
    func returnPressed(from view: LogInField)
}


class LogInField: UIView {
    #warning("need to use return button")
    let emailPlaceholder = "Email address"
    let usernamePlaceholder = "Username"
    let passwordPlaceholder = "Password"
    
    private weak var logInFieldDelegate: LogInFieldDelegate?
    
    private let minUsernameLength = 3
    var hideButton = false {
        didSet {
            if style != .password {
                if hideButton {
                    viewButton.hideWithAlphaAnimated()
                } else {
                    viewButton.showWithAlphaAnimated()
                }
            }
        }
    }
    
    init(style: Style, returnKeyType: UIReturnKeyType, logInFieldDelegate: LogInFieldDelegate?) {
        self.style = style
        self.logInFieldDelegate = logInFieldDelegate
        super.init(frame: .zero)
        setUp()
        textField.returnKeyType = returnKeyType
    }
    
    required init?(coder: NSCoder) {
        self.style = .none
        super.init(coder: coder)
    }
    
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
            if textFieldText.isValidPassword() {
                valid = true
            } else {
                message = "Your password must be 8 characters long and consist of letters, numbers, and/or special characters."
            }
        case .username:
            valid = isValidText ?? false
            print("Is valid: \(valid)")
            if !valid {
                message = "Your username has to be between 3 and 15 characters long, and only contain letters, numbers, and _ or - or ."
            }
        case .none:
            valid = true
        }
        return (valid, message)
    }
    
    func shakeIfNeeded() {
        if text?.count == 0 {
            self.textField.shakeView()
        }
    }
    
    func setTextFieldText(_ str: String) {
        textField.text = str
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
    
    func activate() {
        _ = textField.becomeFirstResponder()
    }
    
    func deactivate() {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    func setPlaceholder(_ str: String) {
        self.textField.placeholder = str
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
        textField.delegate = self

        self.addSubview(viewButton)
        viewButton.equalSides()
        
        viewButton.constrain(.leading, to: textField, .trailing)
        viewButton.constrain(.top, to: self, .top)
        viewButton.constrain(.bottom, to: self, .bottom)
        viewButton.constrain(.trailing, to: self, .trailing)
        
        setUpSpecificAttributesForStyle()
    }
    
    private func setUpSpecificAttributesForStyle() {
        switch style {
        case .email:
            textField.keyboardType = .emailAddress
            textField.textContentType = .emailAddress
            self.textField.placeholder = emailPlaceholder
            self.textField.addTarget(self, action: #selector(textFieldTextChangedEmail(sender:)), for: .editingChanged)
            viewButton.isUserInteractionEnabled = false
            textFieldTextChangedEmail(sender: textField)
        case .password:
            self.textField.isSecureTextEntry = true
            self.textField.textContentType = .password
            self.textField.placeholder = passwordPlaceholder
            viewButton.setImage(.eyeImage, for: .normal)
            viewButton.setImage(.eyeSlashImage, for: .selected)
            viewButton.addTarget(self, action: #selector(handleEyePassword), for: .touchUpInside)
            viewButton.tintColor = Colors.main
        case .username:
            self.textField.autocapitalizationType = .none
            self.textField.textContentType = .username

            self.textField.placeholder = usernamePlaceholder
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
            let qualifies = text.isValidUsername()
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


extension LogInField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        logInFieldDelegate?.returnPressed(from: self)
        return true
    }
}
