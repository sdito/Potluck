//
//  TwoLevelButton.swift
//  restaurants
//
//  Created by Steven Dito on 7/7/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class TwoLevelButton: UIButton {
    
    required init(text: String, imageText: String) {
        super.init(frame: CGRect.zero)
        setUp(text: text, imageText: imageText)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUp(text: String, imageText: String) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.tintColor = .label
        self.titleLabel?.font = .smallBold
        let image = UIImage(systemName: imageText, withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        self.setImage(image, for: .normal)
        self.setTitle(text, for: .normal)
        self.setTitleColor(.label, for: .normal)
        self.addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        self.addTarget(self, action: #selector(touchUp), for: [.touchDragExit, .touchUpInside])
        
    }
    
    
    @objc func touchDown() {
        // Transform the view to show it is being selected
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        })
    }
    
    @objc func touchUp() {
        // Transform the view back to normal
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
}
