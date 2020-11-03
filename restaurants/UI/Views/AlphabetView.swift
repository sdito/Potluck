//
//  AlphabetView.swift
//  restaurants
//
//  Created by Steven Dito on 10/30/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


protocol AlphabetViewDelegate: class {
    func letterSelected(_ string: String)
}


class AlphabetView: UIView {
    
    private weak var delegate: AlphabetViewDelegate?
    private var alphabetButtons: [UIButton] = []
    private var previousLetter: String?
    private var alphabetString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
    init(delegate: AlphabetViewDelegate, alphabetString: String) {
        super.init(frame: .zero)
        self.delegate = delegate
        self.alphabetString = alphabetString
        setUpView()
        setUpAlphabetButtons()
        setUpGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 2.0
        self.clipsToBounds = true
        self.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.8)
    }
    
    private func setUpAlphabetButtons() {
        let alphabet = alphabetString.map({String($0)})
        var previousButton: UIButton?
        alphabet.forEach { letter in
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(letter, for: .normal)
            button.setTitleColor(Colors.main, for: .normal)
            button.titleLabel?.font = .smallerThanNormal
            // has to be 0.01 or else it sets it to default
            button.contentEdgeInsets = UIEdgeInsets(top: 0.01, left: 0.01, bottom: 0.01, right: 0.01)
            self.addSubview(button)
            button.constrain(.leading, to: self, .leading)
            button.constrain(.trailing, to: self, .trailing)
            
            if let previousButton = previousButton {
                button.constrain(.top, to: previousButton, .bottom)
            } else {
                button.constrain(.top, to: self, .top)
            }
            
            button.addTarget(self, action: #selector(buttonSelector(sender:)), for: .touchDown)
            //stackView.addArrangedSubview(button)
            alphabetButtons.append(button)
            previousButton = button
        }
        previousButton?.constrain(.bottom, to: self, .bottom)
    }
    
    @objc private func buttonSelector(sender: UIButton) {
        askDelegate(for: sender.titleLabel?.text)
    }

    private func setUpGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(sender:)))
        self.addGestureRecognizer(panGestureRecognizer)
    }

    @objc private func panGestureRecognizer(sender: UIPanGestureRecognizer) {
        let yValue = sender.location(in: self).y
        for button in alphabetButtons {
            let buttonY = button.frame.maxY
            if buttonY > yValue {
                askDelegate(for: button.titleLabel?.text)
                break
            }
        }
    }
    
    private func askDelegate(for letter: String?) {
        guard let letter = letter else { previousLetter = nil; return }
        if previousLetter != letter {
            UIDevice.vibrateSelectionChanged()
            delegate?.letterSelected(letter)
        }
        previousLetter = letter
    }
    
    
}
