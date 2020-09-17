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
    
    func addBlurEffect() {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.isUserInteractionEnabled = false
        self.insertSubview(blur, at: 0)
        blur.constrainSides(to: self)
        
        if let button = self as? UIButton {
            if let titleLabel = button.titleLabel {
                button.bringSubviewToFront(titleLabel)
            }
        }
    }
    
    @discardableResult
    func placeActivityIndicatorOnTop() -> UIActivityIndicatorView {
        let activityView = UIActivityIndicatorView()
        activityView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityView)
        
        activityView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        activityView.startAnimating()
        
        return activityView
    }
    
    func appIsHiddenAnimated(isHidden: Bool, animated: Bool = true) {
        
        if animated {
            let smallTransform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            if isHidden {
                print("Need to animate shrinking")
                UIView.animate(withDuration: 0.3, animations: {
                    self.transform = smallTransform
                }) { (complete) in
                    if complete {
                        self.isHidden = isHidden
                        self.transform = .identity
                    }
                }
            } else {
                self.isHidden = isHidden
                // Showing from hidden, start small, bounce it to be bigger, then go to standard size
                self.isHidden = false
                self.transform = smallTransform
                UIView.animate(withDuration: 0.3, animations: {
                    self.transform = CGAffineTransform(scaleX: 1.75, y: 1.75)
                }) { (complete) in
                    if complete {
                        UIView.animate(withDuration: 0.2) {
                            self.transform = CGAffineTransform.identity
                        }
                    }
                }
            }
        } else {
            self.isHidden = isHidden
        }
    }
    
    func removeFromStackViewAnimated(duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
            self.isHidden = true
        }) { (complete) in
            if complete { self.removeFromSuperview() }
        }
    }
    
    func shakeView() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
    
    static let notificationLabelTag = 7
    
    func showNotificationStyleText(str: String) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .smallBold
        label.textAlignment = .center
        label.textColor = .white
        label.text = str
        label.backgroundColor = Colors.secondary
        self.addSubview(label)
        label.equalSides()
        label.layoutIfNeeded()
        NSLayoutConstraint.activate([
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: label.bounds.height / 3.0),
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: -(label.bounds.height / 3.0))
        ])
        label.clipsToBounds = true
        label.layer.cornerRadius = label.bounds.height / 2.0
        label.tag = UIView.notificationLabelTag
    }
    
    func removeNotificationStyleText() {
        self.subviews.forEach { (subview) in
            if subview.tag == UIView.notificationLabelTag {
                subview.removeFromSuperview()
            }
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
    
    func setGradientBackgroundVertical(colorBottom: UIColor, colorTop: UIColor){
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [NSNumber(floatLiteral: 0.0), NSNumber(floatLiteral: 1.0)]
        gradientLayer.frame = self.bounds
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
    
    func animateRemovingWithCompletion(complete: @escaping (Bool) -> Void) {
        // Moves up
        // At end, it is removed from superview
        // Use when mapView moves when restaurantSelectedView is present
        
        let animationDuration = 0.3
        
        let transformation = CGAffineTransform(translationX: 0, y: -(50 + self.bounds.height))
        
        // Doesn't work when in completion block, so just time it for after animation completion
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + 0.1) {
            complete(true)
        }
        
        UIView.animate(withDuration: animationDuration) {
            self.transform = transformation
        }
    }

    
}
