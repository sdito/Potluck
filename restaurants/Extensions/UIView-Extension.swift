//
//  UIView-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 7/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


extension UIView {
    
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
    
    func showFromBottom(on view: UIView) {
        print("Should show the button")
        
        let originalConstraint = self.topAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            originalConstraint,
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Animate the view going into place
        // Distance from the bottom is .overlayDistanceFromBottom
        self.layoutIfNeeded()
        let distanceNeeded: CGFloat = .overlayDistanceFromBottom - self.frame.size.height
        let transformation = CGAffineTransform(translationX: 0, y: distanceNeeded)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = transformation
        }) { (done) in
            originalConstraint.isActive = false
            self.transform = CGAffineTransform.identity // remove the transformation
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: .overlayDistanceFromBottom).isActive = true
        }
        
    }
    
    func hideFromScreen() {
        if let view = self.findViewController()?.view {
            let distanceNeeded = view.frame.size.height - self.frame.origin.y
            let transformation = CGAffineTransform(translationX: 0, y: distanceNeeded)
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = transformation
            }) { (true) in
                self.removeFromSuperview()
            }
            
        }
    }
    
    func fadedBackground() {
        self.layer.cornerRadius = 5.0
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.clipsToBounds = true
    }
    
    func constrainSides(to view: UIView, distance: CGFloat = 0.0) {
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: distance),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -distance),
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: distance),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -distance)
        ])
    }
    
}
