//
//  CreateAccountVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/14/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class CreateAccountVC: UIViewController {
    
    private let dummyView = UIView()
    private let doneButton = LogInButton()
    private let emailLogInField = LogInField(style: .email)
    private let usernameLogInField = LogInField(style: .username)
    private let passwordLogInField = LogInField(style: .password)
    private let stackView = UIStackView()
    private let logInAndCreateToggleButton = SizeChangeButton(sizeDifference: .medium, restingColor: .secondaryLabel, selectedColor: .label)
    private var mode: Mode! {
        didSet {
            handleModeSwitch()
        }
    }
    private let createAccountString = "Create account instead"
    private let logInString = "Log in instead"
    
    enum Mode {
        case createAccount
        case logIn
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.navigationItem.title = "Account"
        setUpStackView()
        setUpInfoLabel()
        setUpTextFields()
        setUpDoneButton()
        setUpAlterBetweenLogInAndCreate()
        setUpDummyView()
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
    
    private func setUpInfoLabel() {
        let infoLabel = PaddingLabel(top: 5.0, bottom: 5.0, left: 10.0, right: 10.0)
        infoLabel.font = .mediumBold
        infoLabel.numberOfLines = 0
        infoLabel.text = "This should tell the user why it will be the best idea for them to create an account, like this app is the best ever so create an account."
        infoLabel.textAlignment = .center
        infoLabel.layer.cornerRadius = 5.0
        infoLabel.backgroundColor = .secondarySystemBackground
        infoLabel.clipsToBounds = true
        stackView.addArrangedSubview(infoLabel)
    }
    
    private func setUpTextFields() {
        stackView.addArrangedSubview(emailLogInField)
        emailLogInField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        stackView.addArrangedSubview(usernameLogInField)
        usernameLogInField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        stackView.addArrangedSubview(passwordLogInField)
        passwordLogInField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
    }
    
    private func setUpDoneButton() {
        doneButton.setTitle("Create account", for: .normal)
        stackView.addArrangedSubview(doneButton)
        doneButton.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        doneButton.addTarget(self, action: #selector(executeCreateOrLogIn), for: .touchUpInside)
    }
    
    private func setUpAlterBetweenLogInAndCreate() {
        logInAndCreateToggleButton.translatesAutoresizingMaskIntoConstraints = false
        logInAndCreateToggleButton.addTarget(self, action: #selector(logInAndCreateToggleButtonSelector), for: .touchUpInside)
        logInAndCreateToggleButton.titleLabel?.font = .mediumBold
        stackView.addArrangedSubview(logInAndCreateToggleButton)
        mode = .createAccount
    }
    
    private func setUpDummyView() {
        dummyView.translatesAutoresizingMaskIntoConstraints = false
        dummyView.backgroundColor = .clear
    }
    
    @objc private func logInAndCreateToggleButtonSelector() {
        if mode == .createAccount {
            mode = .logIn
        } else {
            mode = .createAccount
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
            
            if emailIsValid.0 && usernameIsValid.0 && passwordIsValid.0, let email = emailLogInField.text, let password = passwordLogInField.text, let username = usernameLogInField.text {
                
                Network.shared.registerUser(email: email, username: username, password: password) { [weak self] (result) in
                    guard let self = self else { return }
                    switch result {
                    case .success(let success):
                        if success {
                            self.showMessage("Created new account as \(Network.shared.account!.username)")
                            self.navigationController?.popViewController(animated: true)
                        }
                    case .failure(let error):
                       self.alert(title: "Error", message: error.message)
                    }
                }
            } else {
                var messages = [emailIsValid.1, usernameIsValid.1, passwordIsValid.1].filter({$0 != nil}).map({$0!})
                if messages.count < 1 {
                    messages = ["Please try again."]
                }
                self.alert(title: "Unable to create account", message: messages.joined(separator: "\n\n"))
                UIDevice.vibrateError()
            }
        case .logIn:
            emailLogInField.shakeIfNeeded()
            passwordLogInField.shakeIfNeeded()
            guard let email = emailLogInField.text, let password = passwordLogInField.text, email.count > 0 && password.count > 0 else {
                self.alert(title: "Unable to log in", message: "Please enter a valid email and password to log in.")
                UIDevice.vibrateError()
                return
            }
            Network.shared.retrieveToken(email: email, password: password) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let success):
                    if success {
                        self.showMessage("Logged into \(Network.shared.account?.username ?? "account")")
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    self.alert(title: "Error", message: error.message)
                    UIDevice.vibrateError()
                    break
                }
            }
        }
        
        
    }
    
    private func handleModeSwitch() {
        switch mode! {
        case .createAccount:
            logInAndCreateToggleButton.setTitle(logInString, for: .normal)
            doneButton.setTitle("Create account", for: .normal)
            if stackView.subviews.contains(dummyView) { dummyView.removeFromSuperview() }
            usernameLogInField.isHidden = false
        case .logIn:
            logInAndCreateToggleButton.setTitle(createAccountString, for: .normal)
            doneButton.setTitle("Log in", for: .normal)
            stackView.insertArrangedSubview(dummyView, at: 1)
            
            dummyView.heightAnchor.constraint(equalToConstant: usernameLogInField.bounds.height).isActive = true
            usernameLogInField.isHidden = true
        }
    }
    

}
