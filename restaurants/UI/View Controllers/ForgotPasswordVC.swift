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
    
    private var passwordResetRequest: Account.PasswordResetRequest?
    
    enum Stage {
        case enterUsernameOrPassword
        case enterCode
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
        actionButton.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.5).isActive = true
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
            self.textField.placeholder = "Enter code from email"
            self.textField.text = ""
            self.actionButton.setTitle("Verify code", for: .normal)
            self.textField.keyboardType = .numberPad
            
            if let txt = self.passwordResetRequest?.expiresAt.getTimeOfDay() {
                self.codeTimeLabel.text = "Code expires at \(txt)"
            }
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.detailLabel.isHidden = false
                self?.codeTimeLabel.isHidden = false
            }
        }
        
    }
    
    private func initiateRequest() {
        textField.resignFirstResponder()
        disableActivity()
        guard let text = textField.text, text.count > 0 else { UIDevice.vibrateError(); return }
        
        #warning("remove dispatch queue stuff")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            Network.shared.initiatePasswordReset(usernameOrEmail: text) { [weak self] (passwordRequest) in
                guard let self = self else { return }
                self.enableActivity()
                self.passwordResetRequest = passwordRequest
                self.stage = .enterCode
                self.setUpToReceiveCode()
            }
        }
        
    }
    
    @objc private func actionButtonPressed() {
        switch stage {
        case .enterUsernameOrPassword:
            initiateRequest()
        case .enterCode:
            #warning("actually do network stuff here and etc..")
            print("Need to verify the code")
        }
    }
    
    private func disableActivity() {
        DispatchQueue.main.async {
            self.textField.isUserInteractionEnabled = false
            self.actionButton.isUserInteractionEnabled = false
            self.actionButton.showLoadingOnButton()
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
