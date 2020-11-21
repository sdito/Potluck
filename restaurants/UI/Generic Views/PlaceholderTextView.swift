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
    var isActive = false
    
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
    
    func addToolbar() {
        let toolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.barStyle = .default
        toolbar.tintColor = Colors.main
        toolbar.isTranslucent = true
        
        let doneItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(toolBarButtonPressed))
        toolbar.items = [doneItem]
        
        toolbar.sizeToFit()
        self.inputAccessoryView = toolbar
    }
    
    @objc private func toolBarButtonPressed() {
        self.endEditing(true)
    }
    
}

// MARK: Text view delegate
extension PlaceholderTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        handleTextViewDelegate()
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        isActive = true
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        isActive = false
        return true
    }
}
