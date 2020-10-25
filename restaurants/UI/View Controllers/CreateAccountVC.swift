//
//  CreateAccountVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/14/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class CreateAccountVC: UIViewController {
    
    private let doneButton = LogInButton()
    
    private lazy var emailLogInField = LogInField(style: .email, returnKeyType: .next, logInFieldDelegate: self)
    private lazy var usernameLogInField = LogInField(style: .username, returnKeyType: .next, logInFieldDelegate: self)
    private lazy var passwordLogInField = LogInField(style: .password, returnKeyType: .go, logInFieldDelegate: self)
    
    private let stackView = UIStackView()
    private let logInAndCreateToggleButton = SizeChangeButton(sizeDifference: .inverse, restingColor: .secondaryLabel, selectedColor: .label)
    private let resetPasswordButton = SizeChangeButton(sizeDifference: .inverse, restingColor: .secondaryLabel, selectedColor: .label)
    private var mode: Mode! {
        didSet {
            handleModeSwitch()
        }
    }
    private let createAccountString = "Create account instead"
    private let logInString = "Log in instead"
    
    var emailText: String? {
        return emailLogInField.text?.lowercased()
    }
    
    enum Mode {
        case createAccount
        case logIn
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUpStackView()
        setUpTextFields()
        setUpDoneButton()
        setUpAlterBetweenLogInAndCreate()
        setUpResetPasswordButton()
        mode = .createAccount
        self.edgesForExtendedLayout = [.left, .right, .bottom]
    }
    
    
    private func setUpStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10.0
        stackView.distribution = .fill
        self.view.addSubview(stackView)
        stackView.constrain(.top, to: view, .top, constant: 15.0)
        stackView.constrain(.leading, to: view, .leading, constant: 15.0)
        stackView.constrain(.trailing, to: view, .trailing, constant: 15.0)
        stackView.axis = .vertical
        stackView.alignment = .center
    }
    
    private func setUpTextFields() {
        stackView.addArrangedSubview(emailLogInField)
        emailLogInField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        stackView.addArrangedSubview(usernameLogInField)
        usernameLogInField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        stackView.addArrangedSubview(passwordLogInField)
        passwordLogInField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        emailLogInField.heightAnchor.constraint(equalTo: usernameLogInField.heightAnchor).isActive = true
        usernameLogInField.heightAnchor.constraint(equalTo: passwordLogInField.heightAnchor).isActive = true
    }
    
    private func setUpDoneButton() {
        doneButton.setTitle("Create account", for: .normal)
        stackView.addArrangedSubview(doneButton)
        doneButton.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        doneButton.addTarget(self, action: #selector(executeCreateOrLogIn), for: .touchUpInside)
    }
    
    private func setUpResetPasswordButton() {
        resetPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        resetPasswordButton.titleLabel?.font = .mediumBold
        stackView.addArrangedSubview(resetPasswordButton)
        resetPasswordButton.setTitle("Forgot password?", for: .normal)
        resetPasswordButton.addTarget(self, action: #selector(forgotPasswordPressed), for: .touchUpInside)
        resetPasswordButton.alpha = 0.0
    }
    
    private func setUpAlterBetweenLogInAndCreate() {
        logInAndCreateToggleButton.translatesAutoresizingMaskIntoConstraints = false
        logInAndCreateToggleButton.addTarget(self, action: #selector(logInAndCreateToggleButtonSelector), for: .touchUpInside)
        logInAndCreateToggleButton.titleLabel?.font = .mediumBold
        stackView.addArrangedSubview(logInAndCreateToggleButton)
    }
    
    @objc private func logInAndCreateToggleButtonSelector() {
        if mode == .createAccount {
            mode = .logIn
        } else {
            mode = .createAccount
        }
    }
    
    @objc private func forgotPasswordPressed() {
        self.navigationController?.pushViewController(ForgotPasswordVC(), animated: true)
    }
    
    private func handleRegisterUserRequest(email: String, username: String, password: String) {
        Network.shared.registerUser(email: email, username: username, password: password) { [weak self] (result) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let success):
                    if success {
                        self.showMessage("Created new account as \(Network.shared.account!.username)")
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    self.appAlert(title: "Error", message: error.message, buttons: [("Ok", nil)])
                }
            }
        }
    }
    
    private func handleLogInUserRequest(identifier: String, password: String) {
        Network.shared.retrieveToken(identifier: identifier, password: password) { [weak self] (result) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let success):
                    if success {
                        self.showMessage("Logged into \(Network.shared.account?.username ?? "account")")
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    self.appAlert(title: "Error", message: error.message, buttons: [("Ok", nil)])
                    UIDevice.vibrateError()
                    break
                }
            }
        }
    }
    
    @objc func executeCreateOrLogIn() {
        switch mode! {
        case .createAccount:
            emailLogInField.shakeIfNeeded()
            passwordLogInField.shakeIfNeeded()
            usernameLogInField.shakeIfNeeded()
            
            let emailIsValid = emailLogInField.isValid
            let passwordIsValid = passwordLogInField.isValid
            let usernameIsValid = usernameLogInField.isValid
            
            if emailIsValid.0 && usernameIsValid.0 && passwordIsValid.0, let email = emailText, let password = passwordLogInField.text, let username = usernameLogInField.text {
                handleRegisterUserRequest(email: email, username: username, password: password)
            } else {
                var messages = [emailIsValid.1, usernameIsValid.1, passwordIsValid.1].filter({$0 != nil}).map({$0!})
                if messages.count < 1 {
                    messages = ["Please try again."]
                }
                self.appAlert(title: "Unable to create account", message: messages.joined(separator: "\n\n"), buttons: [("Ok", nil)])
                UIDevice.vibrateError()
            }
        case .logIn:
            usernameLogInField.shakeIfNeeded()
            passwordLogInField.shakeIfNeeded()
            
            guard let identifier = usernameLogInField.text?.turnIntoUsernameOrEmailIdentifier(), let password = passwordLogInField.text, identifier.count > 0 && password.count > 0 else {
                UIDevice.vibrateError()
                return
            }
            handleLogInUserRequest(identifier: identifier, password: password)
        }
    }
    
    private func handleModeSwitch() {
        let combo = [emailLogInField, usernameLogInField]
        switch mode! {
        case .createAccount:
            logInAndCreateToggleButton.setTitle(logInString, for: .normal)
            doneButton.setTitle("Create account", for: .normal)
            emailLogInField.showWithAlphaAnimated()
            combo.forEach({$0.hideButton = false})
            self.navigationItem.title = "Create account"
            usernameLogInField.setPlaceholder(emailLogInField.usernamePlaceholder)
            resetPasswordButton.hideWithAlphaAnimated()
            removeTextFromProperTextFields()
        case .logIn:
            logInAndCreateToggleButton.setTitle(createAccountString, for: .normal)
            doneButton.setTitle("Log in", for: .normal)
            emailLogInField.hideWithAlphaAnimated()
            combo.forEach({$0.hideButton = true})
            self.navigationItem.title = "Log in"
            usernameLogInField.setPlaceholder("Username or email address")
            resetPasswordButton.showWithAlphaAnimated()
            removeTextFromProperTextFields()
        }
    }
    
    private func removeTextFromProperTextFields() {
        usernameLogInField.setTextFieldText("")
        emailLogInField.setTextFieldText("")
    }

}

extension CreateAccountVC: LogInFieldDelegate {
    func returnPressed(from view: LogInField) {
        
        if view == emailLogInField {
            emailLogInField.deactivate()
            usernameLogInField.activate()
        } else if view == usernameLogInField {
            usernameLogInField.deactivate()
            passwordLogInField.activate()
        } else if view == passwordLogInField {
            executeCreateOrLogIn()
        }
    }
    
}
