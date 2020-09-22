//
//  AlertView.swift
//  restaurants
//
//  Created by Steven Dito on 9/21/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class AlertView: UIView {
    
    typealias ButtonAction = (buttonTitle: String, action: (() -> ())?)
    private var title: String?
    private var message: String?
    private var buttons: [ButtonAction]?
    
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    private let stackView = UIStackView()
    private let buttonStackView = UIStackView()
    
    weak var showViewVC: ShowViewVC?

    init(title: String?, message: String?, buttons: [ButtonAction]?) {
        super.init(frame: .zero)
        self.title = title
        self.message = message
        self.buttons = buttons
        setUpView()
        setUpStackView()
        setUpTitleAndMessage()
        setUpButtons()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    private func setUpView() {
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        blurEffectView.constrainSides(to: self)
        blurEffectView.layer.cornerRadius = 10.0
        blurEffectView.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.7).isActive = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
    }
    
    private func setUpStackView() {
        self.addSubview(stackView)
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        
        stackView.constrain(.leading, to: blurEffectView, .leading, constant: 25.0)
        stackView.constrain(.trailing, to: blurEffectView, .trailing, constant: 25.0)
        stackView.constrain(.top, to: blurEffectView, .top, constant: 40.0)
        stackView.constrain(.bottom, to: blurEffectView, .bottom, constant: 40.0)
        
        stackView.spacing = 25.0
    }
    
    private func setUpTitleAndMessage() {
        for part in [(text: title, font: UIFont.secondaryTitle), (text: message, font: UIFont.systemFont(ofSize: 15))] {
            if let text = part.text {
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.numberOfLines = 0
                label.font = part.font
                label.text = text
                label.textAlignment = .center
                stackView.addArrangedSubview(label)
            }
        }
    }
    
    
    private func setUpButtons() {
        if let buttons = buttons, buttons.count > 0 {
            buttonStackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(buttonStackView)
            buttonStackView.spacing = 5.0
            buttonStackView.distribution = .fillEqually
            buttonStackView.alignment = .fill
            
            if buttons.count >= 3 {
                buttonStackView.axis = .vertical
                buttonStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.7).isActive = true
            } else {
                buttonStackView.axis = .horizontal
                buttonStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.9).isActive = true
            }
            
            for (index, button) in buttons.enumerated() {
                let b = SizeChangeButton(sizeDifference: .inverse, restingColor: Colors.main, selectedColor: Colors.main)
                b.translatesAutoresizingMaskIntoConstraints = false
                b.setTitle(button.buttonTitle, for: .normal)
                buttonStackView.addArrangedSubview(b)
                b.titleLabel?.font = .largerBold
                b.layer.cornerRadius = 4.0
                b.clipsToBounds = true
                b.addBlurEffect()
                b.tag = index
                b.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
            }
        }
    }
    
    @objc private func buttonAction(sender: UIButton) {
        #warning("need to fix")
        
        showViewVC?.removeFromSuperviewAlert(completion: { (done) in
            if done {
                guard let buttons = self.buttons else { return }
                
                if let actionFound = buttons[sender.tag].action {
                    actionFound()
                }
            }
            
        })
        
        
    }
    
}
