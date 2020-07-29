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
        self.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -10.0).isActive = true
        
        self.layoutIfNeeded()
        self.alpha = 0.0
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
        
    }
    
    func showAgainAlignAtBottom() {
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform.identity
        }
    }
    
    func shadowAndRounded(cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 0.6
        self.layer.shadowRadius = 6.0
        
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
