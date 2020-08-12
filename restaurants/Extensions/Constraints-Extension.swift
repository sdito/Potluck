//
//  Constraints-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 8/11/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

extension UIView {
    
    enum Side {
        case top
        case leading
        case trailing
        case bottom
        
        var isYAxis: Bool {
            return self == .top || self == .bottom
        }
        
        var isXAxis: Bool {
            return !isYAxis
        }
    }
    
    @discardableResult
    func constrain(_ selfSide: Side, to view: UIView, _ side: Side, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        guard selfSide.isYAxis == side.isYAxis else {
            fatalError("Sides are not on the same axis from constrain(selfSide")
        }
        
        #warning("need to actually use")
        let absConstant = abs(constant)
        var constraint: NSLayoutConstraint!
        
        switch selfSide {
        case .top:
            switch side {
            case .top:
                constraint = self.topAnchor.constraint(equalTo: view.topAnchor, constant: absConstant)
            case .bottom:
                constraint = self.topAnchor.constraint(equalTo: view.bottomAnchor, constant: absConstant)
            default:
                break
            }
        case .bottom:
            switch side {
            case .top:
                constraint = self.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -absConstant)
            case .bottom:
                constraint = self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -absConstant)
            default:
                break
            }
        case .leading:
            switch side {
            case .leading:
                constraint = self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: absConstant)
            case .trailing:
                constraint = self.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: absConstant)
            default:
                break
            }
        case .trailing:
            switch side {
            case .leading:
                constraint = self.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: -absConstant)
            case .trailing:
                constraint = self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -absConstant)
            default:
                break
            }
        }
        
        constraint.isActive = true
        return constraint
        
    }
    
    func equalSides(size: CGFloat? = nil) {
        self.heightAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        if let size = size {
            self.widthAnchor.constraint(equalToConstant: size).isActive = true
            
        }
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
