//
//  NavigationTitleView.swift
//  restaurants
//
//  Created by Steven Dito on 10/7/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class NavigationTitleView: UIStackView {
    
    private let innerStackView = UIStackView()
    private var imageView: UIImageView?
    
    private let upperLabel = UILabel()
    private let lowerLabel = UILabel()
    
    private var stackAlignment = UIStackView.Alignment.center
    
    // Upper is typically a username, lower is typically the normal navigation name
    init(upperText: String, lowerText: String, profileImage: ProfileImage? = nil) {
        super.init(frame: .zero)
        setUpSelfStackView()
        setUpInnerStackView()
        setUpLabels(upperText: upperText, lowerText: lowerText)
        setUpImageView(profileImage: profileImage)
        innerStackView.alignment = stackAlignment
    }
    
    struct ProfileImage {
        var url: String?
        var color: UIColor?
        var image: UIImage?
    }
    
    private func setUpSelfStackView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .horizontal
        self.alignment = .fill
        self.spacing = 3.0
    }
    
    private func setUpImageView(profileImage: ProfileImage?) {
        if let profileImage = profileImage {
            let color = profileImage.color ?? Colors.random
            imageView = UIImageView()
            imageView!.translatesAutoresizingMaskIntoConstraints = false
            imageView!.equalSides()
            imageView!.tintColor = color
            imageView!.image = profileImage.image ?? UIImage.personImage
            imageView!.tintColor = color
            imageView!.clipsToBounds = true
            imageView!.contentMode = .scaleAspectFit
            self.insertArrangedSubview(imageView!, at: 0)
            imageView!.heightAnchor.constraint(equalTo: innerStackView.heightAnchor).isActive = true
            imageView!.layoutIfNeeded()
            imageView!.layer.cornerRadius = imageView!.bounds.height / 2.0
            imageView!.layer.borderWidth = 1.5
            imageView!.layer.borderColor = color.cgColor
            stackAlignment = .leading
            
            
            if let url = profileImage.url {
                imageView!.appStartSkeleton()
                Network.shared.getImage(url: url) { [weak self] (imageFound) in
                    self?.imageView!.appEndSkeleton()
                    if let imageFound = imageFound {
                        self?.imageView?.image = imageFound
                    }
                }
            }
        }
    }
    
    private func setUpInnerStackView() {
        innerStackView.translatesAutoresizingMaskIntoConstraints = false
        innerStackView.axis = .vertical
        self.addArrangedSubview(innerStackView)
    }
    
    private func setUpLabels(upperText: String, lowerText: String) {
        upperLabel.translatesAutoresizingMaskIntoConstraints = false
        upperLabel.text = upperText.uppercased()
        upperLabel.textColor = .secondaryLabel
        upperLabel.font = .mediumBold
        upperLabel.setContentHuggingPriority(.required, for: .vertical)
        innerStackView.addArrangedSubview(upperLabel)
        
        lowerLabel.translatesAutoresizingMaskIntoConstraints = false
        lowerLabel.text = lowerText
        lowerLabel.textColor = .label
        lowerLabel.font = .boldSystemFont(ofSize: 17.5)
        lowerLabel.setContentHuggingPriority(.required, for: .vertical)
        innerStackView.addArrangedSubview(lowerLabel)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
