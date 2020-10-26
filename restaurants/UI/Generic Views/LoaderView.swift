//
//  LoaderView.swift
//  restaurants
//
//  Created by Steven Dito on 10/25/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Lottie

class LoaderView: UIView {
    #warning("use this for all activity indicators AND for refresh controls")
    private let label = UILabel()
    private var animation: Animation?// = Animation.named("fork_and_spoon_loader")
    private var animationView = AnimationView()//(animation: animation)
    private let allAnimationNames = ["cupcake_loader", "mug_loader", "burger_loader", "coffee_cup_loader", "wine_loader", "fries_loader", "ice_cream_loader", "pizza_loader"]
    
    enum Style {
        case small
        case large
    }
    
    init(style: Style) {
        super.init(frame: .zero)
        setUpAnimation(style: style)
        
    }
    
    override func didMoveToWindow() {
        animationView.play()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpAnimation(style: Style) {
        
        self.addSubview(animationView)
        
        if style == .large {
            setUpLabel()
            animation = Animation.named(allAnimationNames.randomElement()!)
        } else {
            animationView.constrain(.bottom, to: self, .bottom)
            animation = Animation.named("fork_and_spoon_loader")
        }
        
        animationView.animation = animation
        
        let size: CGFloat = (style == .large) ? 100 : 30
        
        
        animationView.widthAnchor.constraint(equalToConstant: size).isActive = true
        animationView.heightAnchor.constraint(equalToConstant: size).isActive = true
        
        self.translatesAutoresizingMaskIntoConstraints = false
        animationView.loopMode = .loop
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.constrain(.leading, to: self, .leading)
        animationView.constrain(.top, to: self, .top)
        animationView.constrain(.trailing, to: self, .trailing)
        
    }
    
    private func setUpLabel() {
        self.addSubview(label)
        label.text = "LOADING"
        label.font = .smallBold
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        label.constrain(.top, to: animationView, .bottom, constant: 0.0)
        label.constrain(.leading, to: self, .leading)
        label.constrain(.trailing, to: self, .trailing)
        label.constrain(.bottom, to: self, .bottom)
        label.textAlignment = .center
    }
    
}
