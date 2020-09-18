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
}

class EnterValueView: UIView {
    
    #warning("raise when textField is activated")
    
    private weak var delegate: EnterValueViewDelegate?
    weak var controller: ShowViewVC?
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    
    private var textField: PaddingTextField?
    private var textView: PlaceholderTextView?
    private var ratingView: SliderRatingView?
    
    private let buttonStackView = UIStackView()
    private let cancelButton = SizeChangeButton(sizeDifference: .inverse, restingColor: Colors.main, selectedColor: Colors.main)
    private let doneButton = SizeChangeButton(sizeDifference: .inverse, restingColor: Colors.main, selectedColor: Colors.main)
    private var mode: Mode = .textField
    
    
    
    init(text: String?, placeholder: String?, controller: ShowViewVC?, delegate: EnterValueViewDelegate?, mode: Mode) {
        super.init(frame: .zero)
        self.controller = controller
        self.delegate = delegate
        self.mode = mode
        setUp(text: text, placeholder: placeholder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    enum Mode {
        case textField
        case textView
        case rating
        
        var viewSize: CGFloat {
            switch self {
            case .textField, .textView:
                return 0.7
            case .rating:
                return 0.9
            }
        }
    }
    
    private func setUp(text: String?, placeholder: String?) {
        
        let blurEffect = UIBlurEffect(style: .systemMaterial)
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
        case .textField:
            textField = PaddingTextField()
            textField!.translatesAutoresizingMaskIntoConstraints = false
            textField!.addBlurEffect()
            textField!.placeholder = placeholder
            textField!.font = .smallerThanNormal
            textField!.layer.cornerRadius = 8.0
            stackView.addArrangedSubview(textField!)
            textField?.delegate = self
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
            textView?.delegate = self
        case .rating:
            ratingView = SliderRatingView()
            stackView.addArrangedSubview(ratingView!)
            ratingView?.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
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
        controller?.removeAnimatedSelector()
    }
    
    @objc private func doneAction() {
        
        if mode == .textView || mode == .textField {
            var text: (String?, UIView) {
                if mode == .textField {
                    return (textField?.text, textField!)
                } else if mode == .textView {
                    return (textView?.text, textView!)
                } else {
                    fatalError()
                }
            }
            
            guard let string = text.0 else { return }
            
            if string.count > 0 {
                delegate?.textFound(string: string)
                controller?.removeAnimatedSelector()
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
        }
    }
    
    private func executeForRating(rating: Float?) {
        delegate?.ratingFound(float: rating)
        controller?.removeAnimatedSelector()
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
}


// MARK: Text view
extension EnterValueView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        raiseViewForKeyboard()
        return true
    }
}
