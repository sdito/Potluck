//
//  EnterTextView.swift
//  restaurants
//
//  Created by Steven Dito on 9/14/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

protocol EnterTextViewDelegate: class {
    func textFound(string: String?)
}

class EnterTextView: UIView {
    
    #warning("raise when textField is activated")
    
    private weak var delegate: EnterTextViewDelegate?
    weak var controller: ShowViewVC?
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let textField = PaddingTextField()
    private let buttonStackView = UIStackView()
    private let cancelButton = SizeChangeButton(sizeDifference: .inverse, restingColor: Colors.main, selectedColor: Colors.main)
    private let doneButton = SizeChangeButton(sizeDifference: .inverse, restingColor: Colors.main, selectedColor: Colors.main)
    
    init(text: String, placeholder: String, controller: ShowViewVC?, delegate: EnterTextViewDelegate?) {
        super.init(frame: .zero)
        self.controller = controller
        self.delegate = delegate
        setUp(text: text, placeholder: placeholder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUp(text: String, placeholder: String) {
        
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        blurEffectView.constrainSides(to: self)
        blurEffectView.layer.cornerRadius = 10.0
        blurEffectView.clipsToBounds = true
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.7).isActive = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = .clear
        
        self.addSubview(stackView)
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.constrainSides(to: blurEffectView, distance: 25.0)
        stackView.spacing = 25.0
        
        titleLabel.text = text
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = .largerBold
        titleLabel.textColor = .label
        stackView.addArrangedSubview(titleLabel)
        
        textField.addBlurEffect()
        textField.placeholder = placeholder
        textField.font = .smallerThanNormal
        textField.layer.cornerRadius = 8.0
        stackView.addArrangedSubview(textField)
        
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 10.0
        stackView.addArrangedSubview(buttonStackView)
        
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        
        [cancelButton, doneButton].forEach { (button) in
            
            button.titleLabel?.font = .largerBold
            button.layer.cornerRadius = 4.0
            button.clipsToBounds = true
            buttonStackView.addArrangedSubview(button)
            button.addBlurEffect()
        }
        
        
    }
    
    @objc private func cancelAction() {
        controller?.removeAnimatedSelector()
    }
    
    @objc private func doneAction() {
        #warning("need to use a notification to change the name")
        delegate?.textFound(string: textField.text)
        controller?.removeAnimatedSelector()
    }
    
    
}


extension UIView {
    func addBlurEffect() {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.isUserInteractionEnabled = false
        self.insertSubview(blur, at: 0)
        blur.constrainSides(to: self)
        
        if let button = self as? UIButton {
            if let titleLabel = button.titleLabel {
                button.bringSubviewToFront(titleLabel)
            }
        }
        
    }
}
