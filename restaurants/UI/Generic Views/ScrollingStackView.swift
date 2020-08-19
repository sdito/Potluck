//
//  ScrollingStackView.swift
//  restaurants
//
//  Created by Steven Dito on 7/9/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class ScrollingStackView: UIView {
    
    var scrollOrigin: CGPoint {
        return scrollView.contentOffset
    }
    
    private var dropLocationView: UIView?
    
    func removePlaceholderView() {
        dropLocationView?.removeFromSuperview()
    }
    
    @discardableResult
    func indexForViewAtAbsoluteX(_ x: CGFloat, fromIndex: Int) -> Int? {
        self.scrollView.clipsToBounds = false
        self.stackView.clipsToBounds = false
        
        dropLocationView?.removeFromSuperview()
        
        let offset = scrollView.contentOffset.x
        let totalDistance = offset + x
        var widthCounter: CGFloat = 0
        for (i, view) in stackView.arrangedSubviews.enumerated() {
            widthCounter += view.bounds.width
            if widthCounter > totalDistance {
                
                guard i != fromIndex && i != fromIndex + 1 else { return nil }
                
                dropLocationView = setUpDropLocationView(addTo: view)
                
                //self.bringSubviewToFront(dropLocationView!)
                
                return i
                
            }
        }
        
        let idx = stackView.arrangedSubviews.count - 1
        
        return idx
    }
    
    var scrollView: UIScrollView!
    var stackView: UIStackView!
    
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
    
    private func setUpDropLocationView(addTo view: UIView) -> UIView {
        let dropLocationView = UIView()
        dropLocationView.clipsToBounds = false
        dropLocationView.translatesAutoresizingMaskIntoConstraints = false
        dropLocationView.backgroundColor = .yellow
        
        view.addSubview(dropLocationView)
        dropLocationView.widthAnchor.constraint(equalToConstant: 10.0).isActive = true
        dropLocationView.heightAnchor.constraint(equalToConstant: self.bounds.height + 10.0).isActive = true
        dropLocationView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        dropLocationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -7.5).isActive = true
        
        dropLocationView.layer.cornerRadius = 3.0
        dropLocationView.clipsToBounds = true
        
        return dropLocationView
    }
    
}
