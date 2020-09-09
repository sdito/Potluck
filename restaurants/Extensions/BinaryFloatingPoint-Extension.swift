//
//  BinaryFloatingPoint-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 9/7/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

extension BinaryFloatingPoint {
    func getColorFromZeroToTen() -> UIColor {
        
        var redRatio: CGFloat = 1.0
        var greenRatio: CGFloat = 1.0
        let ratePerOne: CGFloat = 0.2
        
        if self > 10.0 {
            redRatio = 0.0
        } else if self < 0.0 {
            greenRatio = 0.0
        } else {
            if self > 5.0 {
                // Less red
                let redToRemoveRatio = (10.0 - CGFloat(self)) * ratePerOne
                redRatio = redToRemoveRatio
            } else if self < 5.0 {
                // Less green
                let greenToRemoveRatio = (5.0 - CGFloat(self)) * ratePerOne
                greenRatio -= greenToRemoveRatio
            }
        }
        
        // To darken up the colors and make them work for both light and dark mode
        redRatio = redRatio * 0.8
        greenRatio = greenRatio * 0.8
        
        return UIColor(red: redRatio, green: greenRatio, blue: 0.0, alpha: 1.0)
    }
}
