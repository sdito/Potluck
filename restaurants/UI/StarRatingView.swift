//
//  StarRatingView.swift
//  restaurants
//
//  Created by Steven Dito on 7/6/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class StarRatingView: UIView {
    
    init(stars: Double) {
        super.init(frame: .zero)
        setUp(stars: stars)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    func setUp(stars: Double) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.5)
        self.layer.cornerRadius = 5.0
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 2.0
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 3.0),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3.0),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 3.0),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -3.0)
        ])
        
        print("Set UI with number of stars")
        var numberStarsLeft = stars
        
        for _ in 1...5 {
            let imageView = UIImageView()
            if numberStarsLeft > 0.99 {
                // add a full star at the end
                imageView.image = UIImage(systemName: "star.fill")
                numberStarsLeft -= 1.0
            } else if numberStarsLeft > 0.01 {
                // add a half star at the end
                imageView.image = UIImage(systemName: "star.lefthalf.fill")
                numberStarsLeft = 0.0
            } else {
                // add an empty star at the end
                imageView.image = UIImage(systemName: "star")
            }
            imageView.tintColor = Colors.main
            stackView.addArrangedSubview(imageView)
            
        }
        
        self.layer.cornerRadius = 5.0
        
        
        
    }
    
    
    
}
