//
//  EnterTextView.swift
//  restaurants
//
//  Created by Steven Dito on 9/14/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

protocol EnterValueViewDelegate: class {
    func textFound(string: String?)
    func ratingFound(float: Float?)
    func phoneFound(string: String?)
}

class EnterValueView: UIView {
    
    private weak var delegate: EnterValueViewDelegate?
    weak var controller: ShowViewVC?
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    
    private var textField: PaddingTextField?
    private var textView: PlaceholderTextView?
    private var ratingView: SliderRatingView?
    private var phoneNumberTextField: PhoneTextField?
    
    private let buttonStackView = UIStackView()
    private let cancelButton = SizeChangeButton(sizeDifference: .inverse, restingColor: Colors.main, selectedColor: Colors.main)
    private let doneButton = SizeChangeButton(sizeDifference: .inverse, restingColor: Colors.main, selectedColor: Colors.main)
    private var mode: Mode = .textField
    
    private var maximumNumber = 0
    private var allowMessage = true
    private var startingText: String?
    
    init(text: String?, placeholder: String?, controller: ShowViewVC?, delegate: EnterValueViewDelegate?, mode: Mode, maximumNumber: Int = 255, startingText: String? = nil) {
        super.init(frame: .zero)
        self.controller = controller
        self.delegate = delegate
        self.mode = mode
        self.maximumNumber = maximumNumber
        self.startingText = startingText
        setUp(text: text, placeholder: placeholder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    enum Mode {
        case textField
        case textView
        case rating
        case phone
        case number
        
        var viewSize: CGFloat {
            switch self {
            case .textField, .textView, .phone, .number:
                return 0.7
            case .rating:
                return 0.9
            }
        }
    }
    
    private func setUp(text: String?, placeholder: String?) {
        
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        blurEffectView.constrainSides(to: self)
        blurEffectView.layer.cornerRadius = 10.0
        blurEffectView.clipsToBounds = true
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * mode.viewSize).isActive = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
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
        
        if let text = text {
            titleLabel.text = text
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 0
            titleLabel.font = .largerBold
            titleLabel.textColor = .label
            stackView.addArrangedSubview(titleLabel)
        }
        
        switch mode {
        case .textField, .number:
            textField = PaddingTextField()
            textField!.translatesAutoresizingMaskIntoConstraints = false
            textField!.addBlurEffect()
            textField!.placeholder = placeholder
            textField!.font = .smallerThanNormal
            textField!.layer.cornerRadius = 8.0
            stackView.addArrangedSubview(textField!)
            textField!.delegate = self
            textField!.text = startingText
            if mode == .number {
                textField?.keyboardType = .numberPad
            }
        case .textView:
            textView = PlaceholderTextView(placeholder: placeholder ?? "", font: .smallerThanNormal)
            textView!.translatesAutoresizingMaskIntoConstraints = false
            textView!.font = .smallerThanNormal
            textView!.layer.cornerRadius = 8.0
            stackView.addArrangedSubview(textView!)
            textView!.heightAnchor.constraint(equalToConstant: 100).isActive = true
            textView!.backgroundColor = .clear
            textView!.layer.borderWidth = 1.0
            textView!.layer.borderColor = UIColor.systemBackground.cgColor
            textView!.delegate = self
        case .rating:
            ratingView = SliderRatingView()
            stackView.addArrangedSubview(ratingView!)
            ratingView?.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        case .phone:
            phoneNumberTextField = PhoneTextField()
            phoneNumberTextField!.translatesAutoresizingMaskIntoConstraints = false
            phoneNumberTextField!.addBlurEffect()
            phoneNumberTextField!.placeholder = placeholder
            phoneNumberTextField!.font = .largerBold
            phoneNumberTextField!.layer.cornerRadius = 8.0
            phoneNumberTextField!.clipsToBounds = true
            stackView.addArrangedSubview(phoneNumberTextField!)
            phoneNumberTextField?.delegate = self
        }
        
        
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
        controller?.animateSelectorWithCompletion(completion: { _ in return })
    }
    
    @objc private func doneAction() {
        if mode == .textView || mode == .textField || mode == .number {
            var text: (String?, UIView) {
                if mode == .textField || mode == .number {
                    return (textField?.text, textField!)
                } else if mode == .textView {
                    return (textView?.text, textView!)
                }  else {
                    // won't go here, would potentially need to change if there is another option
                    return (nil, textField!)
                }
            }
            
            guard let string = text.0 else { return }
            
            if string.count > 0 {
                
                controller?.animateSelectorWithCompletion(completion: { done in
                    if done { self.delegate?.textFound(string: string) }
                })
                
            } else {
                UIDevice.vibrateError()
                text.1.shakeView()
            }
        } else if mode == .rating {
            
            let rating = ratingView?.sliderValue
            
            if let rating = rating {
                executeForRating(rating: rating)
            } else {
                UIDevice.vibrateError()
                ratingView?.shakeView()
            }
        } else if mode == .phone {
            if let number = phoneNumberTextField?.phoneNumberValue {
                delegate?.phoneFound(string: number)
                controller?.animateSelectorWithCompletion(completion: { _ in return })
            } else {
                UIDevice.vibrateError()
                phoneNumberTextField?.shakeView()
            }
        }
    }
    
    private func executeForRating(rating: Float?) {
        delegate?.ratingFound(float: rating)
        controller?.animateSelectorWithCompletion(completion: { _ in return })
    }
    
    private func raiseViewForKeyboard() {
        
        let selfArea = self.frame
        let heightToTop = selfArea.minY
        let buffer: CGFloat = 50
        
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(translationX: 0, y: -(heightToTop - buffer))
        } completion: { (done) in
            
        }
    }
}

// MARK: Text field
extension EnterValueView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        raiseViewForKeyboard()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard mode == .number else { return true }
        guard let textFieldString = textField.text else { return false }
        
        if textFieldString.count == 1 && textFieldString == "0" {
            textField.text = string
            return false
        } else {
            guard let integerValue = Int("\(textFieldString)\(string)") else { return false }
            
            if integerValue <= maximumNumber {
                return true
            } else {
                if allowMessage {
                    allowMessage = false
                    let messageDuration = 1.5
                    controller?.showMessage("Needs to be less than \(maximumNumber)", lastsFor: messageDuration, on: controller)
                    DispatchQueue.main.asyncAfter(deadline: .now() + messageDuration + 0.2) { [weak self] in
                        self?.allowMessage = true
                    }
                }
            }
            
            return false
        }
    }
}

// MARK: Text view
extension EnterValueView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        raiseViewForKeyboard()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let placeholderTV = textView as? PlaceholderTextView {
            placeholderTV.handleTextViewDelegate()
        }
    }
    
}
