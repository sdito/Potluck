//
//  SpacerView.swift
//  restaurants
//
//  Created by Steven Dito on 8/11/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class SpacerView: UIView {
    
    enum Orientation {
        case vertical
        case horizontal
    }
    
    required init(size: CGFloat, orientation: Orientation, color: UIColor = .systemFill) {
        super.init(frame: .zero)
        self.setUp(size: size, orientation: orientation, color: color)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUp(size: CGFloat, orientation: Orientation, color: UIColor) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = color
        
        if orientation == .vertical {
            self.heightAnchor.constraint(equalToConstant: size).isActive = true
        } else {
            self.widthAnchor.constraint(equalToConstant: size).isActive = true
        }
        
    }

}
