//
//  PlaceholderTextView.swift
//  restaurants
//
//  Created by Steven Dito on 8/30/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class PlaceholderTextView: UITextView {
    
    private var placeholder: String = ""
    private let label = UILabel()
    
    init(placeholder: String, font: UIFont) {
        super.init(frame: .zero, textContainer: nil)
        self.placeholder = placeholder
        self.font = font
        self.delegate = self
        setUpPlaceholderLabel(font: font)
    }
    
    
    private func setUpPlaceholderLabel(font: UIFont) {
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .placeholderText
        label.numberOfLines = 0
        self.addSubview(label)
        label.font = font
        let constraint = self.textContainerInset.top
        
        label.constrainSides(to: self, distance: constraint)
        label.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, constant: -constraint*2).isActive = true
        label.heightAnchor.constraint(lessThanOrEqualTo: self.heightAnchor, constant: -constraint*2).isActive = true
        label.text = placeholder
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func handleTextViewDelegate() {
        guard let text = self.text else { return }
        if text == "" {
            label.isHidden = false
        } else {
            label.isHidden = true
        }
    }
    
}


extension PlaceholderTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        handleTextViewDelegate()
    }
}
