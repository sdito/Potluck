//
//  Colors.swift
//  restaurants
//
//  Created by Steven Dito on 7/4/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

struct Colors {
    static let main = UIColor(red: 200.0/255.0, green: 100.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    static let secondary = UIColor(red: 160.0/255.0, green: 80.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    static var navigationBarColor = UIColor.systemBackground
    static let locationColor = UIColor.systemTeal
    static let baseSliderColor = UIColor.systemGray
    
    static var random: UIColor {
        let range = CGFloat(0.2)...CGFloat(0.8)
        return UIColor(
            red:   .random(in: range),
            green: .random(in: range),
            blue:  .random(in: range),
            alpha: 1.0
        )
    }
    
}
