//
//  ActionSheetView.swift
//  restaurants
//
//  Created by Steven Dito on 9/21/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

typealias AppAction = ActionSheetView.ButtonAction

class ActionSheetView: UIView {

    private var buttons: [ButtonAction] = []
    private let stackView = UIStackView()
    private let cancel = "Cancel"
    private let cornerRadius: CGFloat = 15.0
    private let spacer = UIView()
    
    weak var showViewVC: ShowViewVC?
    
    init(buttons: [ButtonAction]) {
        super.init(frame: .zero)
        self.buttons = buttons
        setUpView()
        setUpStackView()
        setUpButtons()
        setUpCancelButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    struct ButtonAction {
        var title: String
        var action: (() -> ())?
        var buttons: [ButtonAction]? = nil
    }
    
    private func setUpView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.925).isActive = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
    }
    
    private func setUpStackView() {
        self.addSubview(stackView)
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.constrainSides(to: self)
        stackView.spacing = 2.0
    }
    
    
    private func setUpButtons() {
        
        for (i, buttonData) in buttons.enumerated() {
            let button = SizeChangeButton(sizeDifference: .inverse, restingColor: Colors.main, selectedColor: Colors.main)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(buttonData.title, for: .normal)
            button.clipsToBounds = true
            button.addBlurEffect(style: .systemMaterial)
            button.titleEdgeInsets = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
            button.titleLabel?.font = .actionSheetFont
            
            // top view has top two rounded corners, bottom view has bottom two rounded corners
            var edgesForCorner: CACornerMask = []
            if i == 0 {
                edgesForCorner.insert(.layerMaxXMinYCorner)
                edgesForCorner.insert(.layerMinXMinYCorner)
            }
            if i == buttons.count - 1 {
                edgesForCorner.insert(.layerMinXMaxYCorner)
                edgesForCorner.insert(.layerMaxXMaxYCorner)
            }
            
            if !edgesForCorner.isEmpty {
                button.layer.maskedCorners = edgesForCorner
                button.layer.cornerRadius = cornerRadius
            }
            button.tag = i
            button.addTarget(self, action: #selector(buttonSelector(sender:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
    }
    
    private func setUpCancelButton() {
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.backgroundColor = .clear
        spacer.heightAnchor.constraint(equalToConstant: 5.0).isActive = true
        stackView.addArrangedSubview(spacer)

        let button = SizeChangeButton(sizeDifference: .inverse, restingColor: Colors.main, selectedColor: Colors.main)
        button.titleLabel?.font = .actionSheetCancel
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleEdgeInsets = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
        button.setTitle("Cancel", for: .normal)
        button.addBlurEffect(style: .systemThickMaterial)
        button.layer.cornerRadius = cornerRadius
        button.clipsToBounds = true
        stackView.addArrangedSubview(button)
        button.addTarget(self, action: #selector(cancelSelector), for: .touchUpInside)
    }
    
    @objc private func cancelSelector() {
        self.showViewVC?.removeAnimatedSelectorDone()
    }
    
    @objc private func buttonSelector(sender: UIButton) {
        
        let appAction = buttons[sender.tag]
        guard let showView = self.showViewVC else { return }
        
        UIView.animate(withDuration: 0.4, delay: 0.0) {
            
            for button in self.stackView.arrangedSubviews {
                if button != sender {
                    button.alpha = 0.5
                }
            }
            
        } completion: { (done) in
            if done {
                if let buttons = appAction.buttons {
                    let newActionSheet = ActionSheetView(buttons: buttons)
                    newActionSheet.showViewVC = showView
                    showView.showNextViewFromSide(nextView: newActionSheet)
                } else {
                    showView.removeFromSuperviewActionSheet { (done) in
                        if done {
                            appAction.action?()
                        }
                    }
                }
            }
        }
    }
}

extension ActionSheetView: ViewSpecificAnimation {
    func start(duration: TimeInterval) {

        let distancePerView: CGFloat = 5.0
        var counter: CGFloat = 0.0
        var count = 1
        
        for view in stackView.arrangedSubviews.reversed() {
            guard view != spacer else { continue }
            view.transform = CGAffineTransform(translationX: 0, y: -counter)
            counter += distancePerView * CGFloat(count)
            stackView.bringSubviewToFront(view)
            count += 1
        }
        
        UIView.animate(withDuration: duration) {
            for v in self.stackView.arrangedSubviews {
                v.transform = .identity
            }
        }
    }
}
