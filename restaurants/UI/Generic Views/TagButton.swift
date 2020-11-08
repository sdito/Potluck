//
//  TagButton.swift
//  restaurants
//
//  Created by Steven Dito on 11/1/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class TagButton: SizeChangeButton {
    
    var buttonTag: Tag?
    private let baseTitleColor = UIColor.systemBackground
    private let selectedTitleColor = Colors.main
    private let baseBackgroundColor = Colors.main
    private let selectedBackgroundColor = UIColor.secondarySystemBackground
    var isTagActive = false
    
    init(title: String?, withImage: Bool, normal: Bool) {
        super.init(sizeDifference: .inverse)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = .mediumBold
        self.clipsToBounds = true
        self.layer.cornerRadius = 5.0
        self.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        self.setContentCompressionResistancePriority(.required, for: .vertical)
        
        if withImage {
            setImage()
        }
        
        if normal {
            self.setTitleColor(baseTitleColor, for: .normal)
            self.backgroundColor = baseBackgroundColor
        } else {
            self.setTitleColor(selectedTitleColor, for: .normal)
            self.backgroundColor = selectedBackgroundColor
        }
        
        self.tintColor = .secondarySystemBackground
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUpForSelected() {
        isTagActive = true
        setImage()
        UIView.animate(withDuration: 0.2) {
            self.setTitleColor(self.selectedTitleColor, for: .normal)
            self.backgroundColor = self.selectedBackgroundColor
            self.tintColor = self.selectedTitleColor
        }
    }
    
    func setUpForNormal() {
        isTagActive = false
        self.setImage(nil, for: .normal)
        
        UIView.animate(withDuration: 0.2) {
            self.setTitleColor(self.baseTitleColor, for: .normal)
            self.backgroundColor = self.baseBackgroundColor
            self.tintColor = self.baseTitleColor
        }
        
    }
    
    private func setImage() {
        self.setImage(UIImage.xImage.withConfiguration(.small), for: .normal)
    }
    

}
