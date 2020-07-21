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
        let constraint = self.topAnchor.constraint(equalTo: view.topAnchor)
        self.layoutIfNeeded()
        let value = -10 - self.frame.height
        constraint.isActive = true
        let transformation = CGAffineTransform.init(translationX: 0, y: value)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = transformation
        }) { (complete) in
            self.transform = CGAffineTransform.identity
            constraint.constant = value
        }
        
    }
    
    func showAgainAlignAtBottom() {
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform.identity
        }
    }
    
    func hideFromScreen(removeAtEnd: Bool = true) {
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
    
    func fadedBackground() {
        self.layer.cornerRadius = 5.0
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.clipsToBounds = true
    }
    
    func toClearBackground() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.0)
//        UIView.animate(withDuration: 0.1) {
//            
//        }
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

    
}
