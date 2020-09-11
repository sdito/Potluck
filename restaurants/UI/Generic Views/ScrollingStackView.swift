//
//  ScrollingStackView.swift
//  restaurants
//
//  Created by Steven Dito on 7/9/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit



protocol ScrollingStackViewDelegate: class {
    func scrollViewScrolled()
    func newIndexSelected(idx: Int)
}



class ScrollingStackView: UIView {
    
    var scrollOrigin: CGPoint {
        return scrollView.contentOffset
    }
    
    private var dropLocationView: UIView?
    private let spotView = UIView()
    private let paginationStackView = UIStackView()
    private let selectedSideSize: CGFloat = 9.0
    private let selectedColor = UIColor.systemYellow
    private let notSelectedColor = UIColor.white
    weak var delegate: ScrollingStackViewDelegate?
    private var previousIndex = -1
    
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
                guard i != fromIndex && i != fromIndex + 1 else {
                    resetSelectedIndex()
                    return nil
                }
                dropLocationView = setUpDropLocationView(addTo: view)
                checkForHapticFeedback(newIdx: i)
                return i
            }
        }
        
        let idx = stackView.arrangedSubviews.count - 1
        checkForHapticFeedback(newIdx: idx)
        
        return idx
    }
    
    private func checkForHapticFeedback(newIdx: Int) {
        if newIdx != previousIndex {
            UIDevice.vibrateSelectionChanged()
            previousIndex = newIdx
        }
    }
    
    func resetSelectedIndex() {
        previousIndex = -1
    }
    
    var scrollView: UIScrollView!
    var stackView: UIStackView!
    
    init(subViews: [UIView], showPlaceholder: Bool = false) {
        super.init(frame: .zero)
        setUp(subviews: subViews, showPlaceholder: showPlaceholder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUp(subviews: [UIView], showPlaceholder: Bool) {
        self.backgroundColor = .clear
        setUpScrollView()
        setUpStackView(subviews: subviews)
        
        if showPlaceholder {
            setUpPaginationPlacer()
            scrollView.delegate = self
        }
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
        dropLocationView.backgroundColor = .systemYellow
        
        view.addSubview(dropLocationView)
        dropLocationView.widthAnchor.constraint(equalToConstant: 10.0).isActive = true
        dropLocationView.heightAnchor.constraint(equalToConstant: self.bounds.height + 10.0).isActive = true
        dropLocationView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        dropLocationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -7.5).isActive = true
        
        dropLocationView.layer.cornerRadius = 3.0
        dropLocationView.clipsToBounds = true
        
        self.bringSubviewToFront(dropLocationView)
        
        return dropLocationView
    }
    
    private func setUpPaginationPlacer() {
        spotView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(spotView)
        spotView.constrain(.bottom, to: self, .bottom, constant: selectedSideSize / 2.0)
        spotView.backgroundColor = .red
        spotView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        spotView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        spotView.layer.cornerRadius = 3.0
        
        paginationStackView.translatesAutoresizingMaskIntoConstraints = false
        spotView.addSubview(paginationStackView)
        paginationStackView.constrain(.top, to: spotView, .top, constant: selectedSideSize / 4.0)
        paginationStackView.constrain(.bottom, to: spotView, .bottom, constant: selectedSideSize / 4.0)
        paginationStackView.centerXAnchor.constraint(equalTo: spotView.centerXAnchor).isActive = true
        paginationStackView.spacing = selectedSideSize / 2.0
        paginationStackView.widthAnchor.constraint(equalTo: spotView.widthAnchor, constant: -(selectedSideSize / 1.5)).isActive = true
        
    }
    
    func resetElements(selectedIndex: Int = 0) {
        let newAmount = self.stackView.arrangedSubviews.count
        if newAmount < 2 {
            spotView.isHidden = true
        } else {
            spotView.isHidden = false
            paginationStackView.arrangedSubviews.forEach { (v) in
                v.removeFromSuperview()
            }
            
            for _ in 1...newAmount {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = notSelectedColor
                paginationStackView.addArrangedSubview(view)
                view.equalSides(size: selectedSideSize)
                view.layer.cornerRadius = selectedSideSize / 2.0
                view.clipsToBounds = true
            }
            
            highlightViewAt(selectedIndex)
            
        }
    }
    
    func highlightViewAt(_ index: Int) {
        for (i, view) in paginationStackView.arrangedSubviews.enumerated() {
            if i == index {
                view.backgroundColor = selectedColor
            } else {
                view.backgroundColor = notSelectedColor
            }
        }
    }
}


// MARK: Scroll view
extension ScrollingStackView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var idx = 0
        let container = CGRect(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        for (i, view) in stackView.arrangedSubviews.enumerated() {
            let viewFrame = view.frame
            if viewFrame.intersects(container) {
                idx = i
            }
        }
        delegate?.newIndexSelected(idx: idx)
        highlightViewAt(idx)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewScrolled()
    }
    
}
