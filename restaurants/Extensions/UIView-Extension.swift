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
    
    func addCameraLines() -> UIView {
        /*
         two vertical lines, and two horizontal lines
         split the view into thirds both directions
         */
        
        let dummyView = UIView()
        dummyView.translatesAutoresizingMaskIntoConstraints = false
        dummyView.backgroundColor = .clear
        dummyView.isUserInteractionEnabled = false
        dummyView.clipsToBounds = true
        self.addSubview(dummyView)
        dummyView.constrainSides(to: self)
        dummyView.layer.cornerRadius = self.bounds.width / 2.0
        
        let lineWidth: CGFloat = 2.0
        
        // for vertical lines
        let widthThird = self.bounds.width / 3.0
        
        let startingPoints: [CGFloat] = [widthThird, widthThird*2]
        
        for point in startingPoints {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.white.withAlphaComponent(0.55)
            dummyView.addSubview(view)
            view.widthAnchor.constraint(equalToConstant: lineWidth).isActive = true
            view.constrain(.top, to: dummyView, .top)
            view.constrain(.bottom, to: dummyView, .bottom)
            view.constrain(.leading, to: dummyView, .leading, constant: point)
        }
        
        for point in startingPoints {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.white.withAlphaComponent(0.55)
            dummyView.addSubview(view)
            view.heightAnchor.constraint(equalToConstant: lineWidth).isActive = true
            view.constrain(.leading, to: dummyView, .leading)
            view.constrain(.trailing, to: dummyView, .trailing)
            view.constrain(.top, to: dummyView, .top, constant: point)
        }
        dummyView.alpha = 0.0
        return dummyView
        
    }
    
    static func getSpacerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        view.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
        return view
    }
    
    var appTraitCollection: UITraitCollection {
        return self.findViewController()?.traitCollection ?? self.traitCollection
    }
    
    func addBlurEffect(style: UIBlurEffect.Style = .systemThinMaterial) {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: style))
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
    func placeLoaderViewOnTop() -> LoaderView {
        let loaderView = LoaderView(style: .small)
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(loaderView)
        
        loaderView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        loaderView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        return loaderView
    }
    
    func appIsHiddenAnimated(isHidden: Bool, animated: Bool = true) {
        
        // don't need to animate if it is already at the goal end state
        guard isHidden != self.isHidden else { return }
        
        if animated {
            let smallTransform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            if isHidden {
                UIView.animate(withDuration: 0.3, animations: {
                    self.transform = smallTransform
                }) { (complete) in
                    if complete {
                        self.isHidden = isHidden
                        self.transform = .identity
                    }
                }
            } else {
                // Showing from hidden, start small, bounce it to be bigger, then go to standard size
                self.isHidden = false
                self.transform = smallTransform
                UIView.animate(withDuration: 0.3, animations: {
                    self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
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
    
    static let notificationLabelTag = 7001
    
    func showNotificationStyleText(str: String, inner: Bool = false) {
        self.appTraitCollection.performAsCurrent {
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
            
            var constant = label.bounds.height / 3.0
            if inner {
                constant = -constant
            }
            
            NSLayoutConstraint.activate([
                label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: constant),
                label.topAnchor.constraint(equalTo: self.topAnchor, constant: -constant)
            ])
            label.clipsToBounds = true
            label.layer.cornerRadius = label.bounds.height / 2.0
            label.tag = UIView.notificationLabelTag
        }
    }
    
    func removeNotificationStyleText() {
        self.subviews.forEach { (subview) in
            if subview.tag == UIView.notificationLabelTag {
                subview.removeFromSuperview()
            }
        }
    }
    
    func changeValueOfNotificationText(valueAlteration: (Int) -> Int) {
        // first need to find the notification label
        let subviews = self.subviews
        for subview in subviews {
            if subview.tag == UIView.notificationLabelTag {
                guard let label = subview as? UILabel, let strValue = label.text, var intValue = Int(strValue) else { break }
                intValue = valueAlteration(intValue)
                if intValue <= 0 {
                    label.removeFromSuperview()
                } else {
                    label.text = "\(intValue)"
                }
                break
            }
        }
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
    
    func setGradientBackgroundVertical(colorBottom: UIColor, colorTop: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [NSNumber(floatLiteral: 0.0), NSNumber(floatLiteral: 1.0)]
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setGradientBackgroundHorizontal(colorLeft: UIColor, colorRight: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorLeft.cgColor, colorRight.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.locations = [NSNumber(floatLiteral: 0.0), NSNumber(floatLiteral: 1.0)]
        gradientLayer.frame = self.bounds
        gradientLayer.name = "gradientLayer"
        
        for layer in self.layer.sublayers ?? [] {
            if layer.name == "gradientLayer" {
                layer.removeFromSuperlayer()
            }
        }
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func appStartSkeleton() {
        if !self.isSkeletonable {
            self.isSkeletonable = true
        }
        
        self.appTraitCollection.performAsCurrent {
            self.showAnimatedGradientSkeleton(transition: .none)
        }
        
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

    static func onePixelView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        view.backgroundColor = .clear
        return view
    }
    
    func hideWithAlphaAnimated() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0.0
        }
    }
    
    func showWithAlphaAnimated() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
    }
    
    
    
}
