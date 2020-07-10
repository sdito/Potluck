//
//  OverlayButton.swift
//  restaurants
//
//  Created by Steven Dito on 7/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class OverlayButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpButton()
    }
    
    func setUpButton() {
        self.backgroundColor = .secondarySystemBackground
        self.setTitleColor(Colors.secondary, for: .normal)
        self.layer.cornerRadius = 8.0
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        self.addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        self.addTarget(self, action: #selector(touchUp), for: [.touchDragExit, .touchUpInside])
        
    }
    
    
    @objc func touchDown() {
        // Transform the view to show it is being selected
        UIView.animate(withDuration: 0.2, animations: {
            self.setTitleColor(Colors.main, for: .normal)
            self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        })
    }
    
    @objc func touchUp() {
        // Transform the view back to normal
        UIView.animate(withDuration: 0.2, animations: {
            self.setTitleColor(Colors.secondary, for: .normal)
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    
}
