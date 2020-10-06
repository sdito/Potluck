//
//  TitleReusableView.swift
//  restaurants
//
//  Created by Steven Dito on 10/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class TitleReusableView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpElements()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpElements() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "This is a header"
        
    }
    
}
