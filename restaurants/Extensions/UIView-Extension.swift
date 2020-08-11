//
//  UIView-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 7/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import SkeletonView

extension UIView {
    
    func showNotificationStyleText(str: String) {
        #warning("need to actually use correctly")
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .smallBold
        label.textAlignment = .center
        label.textColor = .label
        label.text = str
        label.backgroundColor = Colors.secondary
        self.addSubview(label)
        label.widthAnchor.constraint(equalTo: label.heightAnchor).isActive = true
        label.layoutIfNeeded()
        NSLayoutConstraint.activate([
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: label.bounds.height / 3.0),
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: -(label.bounds.height / 3.0))
        ])
        label.clipsToBounds = true
        label.layer.cornerRadius = label.bounds.height / 2.0
        for _ in 1...100 {
            print(label.frame, label.bounds)
        }
        
        
    }
    
    @discardableResult
    func addGestureToIncreaseAndDecreaseSizeOnPresses() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        button.constrainSides(to: self)
        button.addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        button.addTarget(self, action: #selector(touchUp), for: [.touchDragExit, .touchUpInside, .touchCancel])
        return button
    }
    
    @objc private func touchDown() {
        // Transform the view to show it is being selected
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        })
    }

    @objc private func touchUp() {
        // Transform the view back to normal
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func appStartSkeleton() {
        if !self.isSkeletonable {
            self.isSkeletonable = true
        }
        
        self.showAnimatedGradientSkeleton(transition: .none)
    }
    
    func appEndSkeleton() {
        self.stopSkeletonAnimation()
        self.hideSkeleton()
    }
    
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
    
    func showFromBottom(on view: UIView, extraDistance: CGFloat = .overlayDistanceFromBottom) {
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        let bottomConstraint = self.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -10.0)
        bottomConstraint.isActive = true
        
        self.layoutIfNeeded()
        self.alpha = 0.0
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
        
    }
    

    
    func hideFromScreenSwipe(removeAtEnd: Bool = true) {
        if let view = self.findViewController()?.view {
            let distanceNeeded = view.frame.size.height - self.frame.origin.y
            let transformation = CGAffineTransform(translationX: 0, y: distanceNeeded)
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = transformation
            }) { (true) in
                if removeAtEnd {
                    self.removeFromSuperview()
                }
            }
        }
    }
    
    func showAgainAlignAtBottom() {
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform.identity
        }
    }
    
    func shadowAndRounded(cornerRadius: CGFloat, shadowRadius: CGFloat = 6.0) {
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 0.6
        self.layer.shadowRadius = shadowRadius
        
    }
    
    func hideFromScreen(removeAtEnd: Bool = true) {
        
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = 0.0
        }) { (complete) in
            if complete {
                self.removeFromSuperview()
            }
        }
    }
    
    func fadedBackground() {
        self.layer.cornerRadius = 5.0
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.clipsToBounds = true
    }
    
    func toClearBackground() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.0)
    }
    
    func constrainSides(to view: UIView, distance: CGFloat = 0.0) {
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: distance),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -distance),
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: distance),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -distance)
        ])
    }
    
    func constrainSidesUnique(to view: UIView, top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) {
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leading),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -trailing),
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: top),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottom)
        ])
    }
    
    func animateRemovingWithCompletion(complete: @escaping (Bool) -> Void) {
        // Moves down and alpha becomes zero
        // At end, it is removed from superview
        // Use when mapView moves when restaurantSelectedView is present
        
        let animationDuration = 0.4
        
        let transformation = CGAffineTransform(translationX: 0, y: 200.0)
        
        // Doesn't work when in completion block, so just time it for after animation completion
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + 0.1) {
            complete(true)
        }
        
        UIView.animate(withDuration: animationDuration) {
            self.alpha = 0.0
            self.transform = transformation
            
        }
    }

    
}
