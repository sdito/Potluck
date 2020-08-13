//
//  CheckBoxCell.swift
//  restaurants
//
//  Created by Steven Dito on 8/12/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class CheckBoxCell: UITableViewCell {
    
    var titleLabel = UILabel()
    var checkImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    private var checkBoxShown: Bool = false {
        didSet {
            if self.checkBoxShown {
                checkImageView.image = .unchecked
            } else {
                checkImageView.image = .checked
            }
        }
    }
    
    func setUp(text: String, selected: Bool) {
        titleLabel.text = text
        checkBoxShown = selected
    }
    
    
    private func setUpViews() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(titleLabel)
        self.addSubview(checkImageView)
        
        let spacing: CGFloat = 15.0
        
        
        titleLabel.constrain(.leading, to: self, .leading, constant: spacing)
        titleLabel.constrain(.top, to: self, .top, constant: spacing)
        titleLabel.constrain(.bottom, to: self, .bottom, constant: spacing)
        
        checkImageView.constrain(.leading, to: titleLabel, .trailing, constant: spacing)
        checkImageView.constrain(.top, to: self, .top, constant: spacing)
        checkImageView.constrain(.bottom, to: self, .bottom, constant: spacing)
        checkImageView.constrain(.trailing, to: self, .trailing, constant: spacing)
        checkImageView.tintColor = Colors.main
        //checkImageView.equalSides(size: 30.0)
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkBoxShown = !checkBoxShown
    }
    

}
