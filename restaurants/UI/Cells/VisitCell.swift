//
//  VisitCell.swift
//  restaurants
//
//  Created by Steven Dito on 8/25/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//



import UIKit

class VisitCell: UITableViewCell {
    
    var visit: Visit?
    
    private let baseHeight: CGFloat = 250.0
    private let scrollingStackView = ScrollingStackView(subViews: [], showPlaceholder: true)
    let visitImageView = UIImageView()
    private let restaurantNameLabel = UILabel()
    private let commentLabel = UILabel()
    private var visitImageViewHeightConstraint: NSLayoutConstraint?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUiElements()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpUiElements() {
        
        // only top, leading, trailing, have comment or whatever below it along with restaurant info
        self.addSubview(scrollingStackView)
        scrollingStackView.constrain(.top, to: self, .top)
        scrollingStackView.constrain(.leading, to: self, .leading)
        scrollingStackView.constrain(.trailing, to: self, .trailing)
        
        scrollingStackView.stackView.distribution = .fillEqually
        scrollingStackView.scrollView.isPagingEnabled = true
        scrollingStackView.stackView.spacing = 3.0
        
        scrollingStackView.stackView.addArrangedSubview(visitImageView)
        visitImageView.translatesAutoresizingMaskIntoConstraints = false
        visitImageView.widthAnchor.constraint(equalTo: scrollingStackView.scrollView.widthAnchor).isActive = true
        visitImageViewHeightConstraint = visitImageView.heightAnchor.constraint(equalToConstant: baseHeight)
        visitImageViewHeightConstraint?.isActive = true
        visitImageView.contentMode = .scaleAspectFill
        
        #warning("get the spot thing for the scrolling stack view")
        
        let secondView = UIView()
        secondView.translatesAutoresizingMaskIntoConstraints = false
        scrollingStackView.stackView.addArrangedSubview(secondView)
        secondView.backgroundColor = .blue
        secondView.layoutIfNeeded()
        secondView.heightAnchor.constraint(equalTo: visitImageView.heightAnchor).isActive = true
        
        let lowerStackView = UIStackView()
        lowerStackView.translatesAutoresizingMaskIntoConstraints = false
        lowerStackView.distribution = .fill
        lowerStackView.alignment = .leading
        lowerStackView.axis = .vertical
        lowerStackView.spacing = 3.0
        
        self.addSubview(lowerStackView)
        
        lowerStackView.constrain(.top, to: scrollingStackView, .bottom, constant: 10.0)
        lowerStackView.constrain(.leading, to: self, .leading, constant: 10.0)
        lowerStackView.constrain(.trailing, to: self, .trailing, constant: 10.0)
        lowerStackView.constrain(.bottom, to: self, .bottom, constant: 10.0)
        
        restaurantNameLabel.translatesAutoresizingMaskIntoConstraints = false
        restaurantNameLabel.text = "Restaurant name"
        lowerStackView.addArrangedSubview(restaurantNameLabel)
        
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.text = "This is the text for the comment"
        commentLabel.textColor = .secondaryLabel
        commentLabel.font = .smallerThanNormal
        commentLabel.numberOfLines = 0
        lowerStackView.addArrangedSubview(commentLabel)
        
        
    }
    
    
    func setUpWith(visit: Visit) {
        self.visit = visit
        imageView?.image = nil
        commentLabel.text = visit.comment
        restaurantNameLabel.text = visit.restaurantName
        
        scrollingStackView.resetElements()
    }
    
    func setImage(url: String?, image: UIImage?, height: Int?, width: Int?, imageFound: @escaping (UIImage?) -> Void) {
        
        visitImageView.layoutIfNeeded()
        
        if let height = height, let width = width {
            
            let ratio = CGFloat(width) / CGFloat(height)
            visitImageViewHeightConstraint?.constant = visitImageView.bounds.width / ratio
            
        } else {
            visitImageViewHeightConstraint?.constant = baseHeight
        }
        
        
        if let image = image {
            visitImageView.image = image
            imageFound(nil)
        } else if let url = url {
            self.visitImageView.appStartSkeleton()
            Network.shared.getImage(url: url) { [weak self] (img) in
                guard let self = self else { return }
                self.visitImageView.appEndSkeleton()
                self.visitImageView.image = img
                imageFound(img)
            }
        } else {
            imageFound(nil)
        }
    }
    
}
