//
//  PriceLabel.swift
//  restaurants
//
//  Created by Steven Dito on 7/8/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class PriceLabel: UILabel {
    
    required init(price: String) {
        super.init(frame: CGRect.zero)
        setUp(price: price)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUp(price: String) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textColor = .secondaryLabel
        self.font = .secondaryTitle
        self.text = price
        
        
    }
    
}
