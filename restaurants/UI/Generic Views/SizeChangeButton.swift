//
//  SizeChangeButton.swift
//  restaurants
//
//  Created by Steven Dito on 7/28/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class SizeChangeButton: UIButton {
    
    private var sizeSelected: SizeDifference = .medium
    var restingColor: UIColor!
    private var selectedColor: UIColor!
    
    enum SizeDifference: CGFloat {
        case large = 1.5
        case medium = 1.1
        case small = 1.05
        case inverse = 0.9
    }
    
    init(sizeDifference: SizeDifference, restingColor: UIColor, selectedColor: UIColor) {
        super.init(frame: .zero)
        self.sizeSelected = sizeDifference
        self.restingColor = restingColor
        self.selectedColor = selectedColor
        self.setTitleColor(restingColor, for: .normal)
        setUpButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpButton() {
        self.addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        self.addTarget(self, action: #selector(touchUp), for: [.touchDragExit, .touchUpInside, .touchCancel])
    }
    
    @objc private func touchDown() {
        // Transform the view to show it is being selected
        UIView.animate(withDuration: 0.2, animations: {
            self.setTitleColor(self.selectedColor, for: .normal)
            self.transform = CGAffineTransform(scaleX: self.sizeSelected.rawValue, y: self.sizeSelected.rawValue)
        })
    }
    
    @objc private func touchUp() {
        // Transform the view back to normal
        UIView.animate(withDuration: 0.2, animations: {
            self.setTitleColor(self.restingColor, for: .normal)
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
}
