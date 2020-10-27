//
//  ForgotPasswordVC.swift
//  restaurants
//
//  Created by Steven Dito on 10/17/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {
    
    private var stage: Stage = .enterUsernameOrPassword
    
    private let stackView = UIStackView()
    private let textField = PaddingTextField()
    private let actionButton = LogInButton()
    private let detailLabel = UILabel()
    private let codeTimeLabel = UILabel()
    
    #warning("need to implement returnKeyType")
    private let passwordField = LogInField(style: .password, returnKeyType: .go, logInFieldDelegate: nil)
    
    private var passwordResetRequest: Account.PasswordResetRequest?
    private var codeResponse: Account.CodeResponse?
    
    enum Stage {
        case enterUsernameOrPassword
        case enterCode
        case enterPassword
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.title = "Forgot password"
        setUpStackView()
        setUpTextField()
        setUpActionButton()
        setUpDetailLabel()
        setUpCodeTimeLabel()
    }
    
    private func setUpStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 20.0
        self.view.addSubview(stackView)
        stackView.constrain(.top, to: self.view, .top, constant: 50.0)
        stackView.constrain(.leading, to: view, .leading, constant: 30.0)
        stackView.constrain(.trailing, to: view, .trailing, constant: 30.0)
    }
    
    private func setUpTextField() {
        // (at least) initially will be for entering
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.placeholder = "Enter email or username"
        stackView.addArrangedSubview(textField)
        textField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
    }
    
    private func setUpDetailLabel() {
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.font = .mediumBold
        detailLabel.textColor = .secondaryLabel
        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 0
        stackView.addArrangedSubview(detailLabel)
        detailLabel.text = "Code sent! Check your email for the code. If you can not find the code, check your junk folder, or you may have entered an invalid email or username."
        detailLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        detailLabel.isHidden = true
    }
    
    private func setUpActionButton() {
        actionButton.setTitle("Get code", for: .normal)
        stackView.addArrangedSubview(actionButton)
        actionButton.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.7).isActive = true
        actionButton.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
    }
    
    private func setUpCodeTimeLabel() {
        codeTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        codeTimeLabel.font = .smallerThanNormal
        codeTimeLabel.textColor = .label
        codeTimeLabel.textAlignment = .center
        codeTimeLabel.numberOfLines = 1
        stackView.addArrangedSubview(codeTimeLabel)
        codeTimeLabel.text = ""
        codeTimeLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        codeTimeLabel.isHidden = true
    }
    
    private func setUpToReceiveCode() {
        // Go from enter email or username to enter code
        // Add label to tell the user to check email and stuff
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let response = self.passwordResetRequest {
                self.stage = .enterCode
                self.textField.placeholder = "Enter code from email"
                self.textField.text = ""
                self.actionButton.setTitle("Verify code", for: .normal)
                self.textField.keyboardType = .numberPad
                self.codeTimeLabel.text = "Code expires at \(response.expiresAt.getTimeOfDay())"
                
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.detailLabel.isHidden = false
                    self?.codeTimeLabel.isHidden = false
                }
            } else {
                UIDevice.vibrateError()
                self.textField.shakeView()
                self.showMessage("No account found")
            }
        }
    }
    
    private func setUpToEnterPassword() {
        // at this point the code is verified, so the user just needs to enter in a new password now, if codeResponse is not nil
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let codeResponse = self.codeResponse, codeResponse.success {
                self.actionButton.setTitle("Submit password", for: .normal)
                
                self.passwordField.setPlaceholder("New password")
                self.stackView.insertArrangedSubview(self.passwordField, at: 0)
                self.passwordField.widthAnchor.constraint(equalTo: self.stackView.widthAnchor).isActive = true
                self.textField.isHidden = true
                
                UIView.animate(withDuration: 0.3) {
                    self.detailLabel.isHidden = true
                    self.codeTimeLabel.isHidden = true
                    
                }
                
                self.stage = .enterPassword
            } else {
                UIDevice.vibrateError()
                self.textField.shakeView()
                let errorMessage = self.codeResponse?.error ?? "Code was incorrect or expired"
                self.showMessage(errorMessage)
            }
        }
    }
    
    private func initiateRequest() {
        guard let text = textField.text, text.count > 0 else { UIDevice.vibrateError(); return }
        disableActivity()
        Network.shared.initiatePasswordReset(usernameOrEmail: text) { [weak self] (passwordRequest) in
            guard let self = self else { return }
            self.enableActivity()
            self.passwordResetRequest = passwordRequest
            self.setUpToReceiveCode()
        }
    }
    
    private func checkCode() {
        guard let text = textField.text?.turnIntoUsernameOrEmailIdentifier(), text.count > 0 else { UIDevice.vibrateError(); return }
        
        disableActivity()
        Network.shared.checkPasswordResetCode(code: text, passwordReset: self.passwordResetRequest) { [weak self] (codeResponse) in
            guard let self = self else { return }
            self.enableActivity()
            self.codeResponse = codeResponse
            self.setUpToEnterPassword()
        }
    }
    
    private func setNewPassword() {
        guard passwordField.text?.count ?? 0 > 0 else { UIDevice.vibrateError(); passwordField.shakeView(); return }
        let (isValid, message) = passwordField.isValid
        if isValid {
            guard let token = codeResponse?.token, let newPassword = passwordField.text else { return }
            disableActivity()
            Network.shared.setNewPassword(token: token, newPassword: newPassword) { [weak self] (success) in
                DispatchQueue.main.async {
                    self?.enableActivity()
                    switch success {
                    case true:
                        self?.navigationController?.popViewController(animated: true)
                    case false:
                        self?.showMessage("Unable to set password")
                    }
                }
            }
        } else {
            passwordField.shakeView()
            UIDevice.vibrateError()
            self.appAlert(title: "Invalid password", message: message ?? "Please enter another password", buttons: [
                ("Ok", nil)
            ])
        }
    }
    
    @objc private func actionButtonPressed() {
        switch stage {
        case .enterUsernameOrPassword:
            initiateRequest()
        case .enterCode:
            checkCode()
        case .enterPassword:
            setNewPassword()
        }
    }
    
    private func disableActivity() {
        DispatchQueue.main.async {
            self.textField.resignFirstResponder()
            self.textField.isUserInteractionEnabled = false
            self.actionButton.isUserInteractionEnabled = false
            self.actionButton.showLoadingOnButton(withLoaderView: true)
        }
    }
    
    private func enableActivity() {
        DispatchQueue.main.async {
            self.textField.isUserInteractionEnabled = true
            self.actionButton.isUserInteractionEnabled = true
            self.actionButton.endLoadingOnButton(titleColor: LogInButton.titleColor)
        }
    }
    
}
