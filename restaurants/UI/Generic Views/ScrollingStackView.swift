//
//  ScrollingStackView.swift
//  restaurants
//
//  Created by Steven Dito on 7/9/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class ScrollingStackView: UIView {
    
    private var scrollView: UIScrollView!
    private var stackView: UIStackView!
    
    init(subViews: [UIView]) {
        super.init(frame: .zero)
        setUp(subviews: subViews)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUp(subviews: [UIView]) {
        self.backgroundColor = .clear
        setUpScrollView()
        setUpStackView(subviews: subviews)
    }
    
    private func setUpScrollView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(scrollView)
        scrollView.constrainSides(to: self)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    private func setUpStackView(subviews: [UIView]) {
        
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 5.0
        
        for view in subviews {
            view.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(view)
        }
        
        scrollView.addSubview(stackView)
        stackView.constrainSides(to: scrollView)
        stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
    }
    
    func updateToScrollToIncludeFirstSelectedButton() {
        for subview in stackView.subviews {
            guard let button = subview as? UIButton else { return }
            if button.isSelected {
                scrollView.scrollRectToVisible(subview.frame, animated: true)
                break
            }
        }
    }
    
}
