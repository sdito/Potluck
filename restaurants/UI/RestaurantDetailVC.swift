//
//  RestaurantDetailVC.swift
//  restaurants
//
//  Created by Steven Dito on 7/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class RestaurantDetailVC: UIViewController {
    
    private var scrollView: UIScrollView!
    private var stackView: UIStackView!
    private var imageView: UIImageView!
    private var headerContainerView: UIView!
    private var headerTopConstraint: NSLayoutConstraint!
    private var headerHeightConstraint: NSLayoutConstraint!
    
    private var restaurant: Restaurant!
    
    // UI values
    private var navigationTitleHidden = true
    private var distanceOfImageView: CGFloat = 10000.0
    private var latestAlpha = 0.0
    
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func setUpScrollView() -> UIScrollView {
        let sv = UIScrollView()
        sv.delegate = self
        sv.alwaysBounceVertical = true
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }
    
    private func setUpStackView() -> UIStackView {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = 3.0
        return sv
    }
    
    private func setUpHeaderContainerView() -> UIView {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }
    
    private func setUpImageView() -> UIImageView {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }
    
    private func setTitleInfo() {
        let starRatingView = StarRatingView(stars: restaurant.rating, numReviews: restaurant.reviewCount)
        
        let titleStackView = UIStackView()
        titleStackView.alignment = .leading
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.axis = .vertical
        titleStackView.spacing = 3.0
        
        let titleLabel = PaddingLabel(top: 2.0, bottom: 2.0, left: 5.0, right: 5.0)
        titleLabel.numberOfLines = 2
        titleLabel.text = restaurant.name
        titleLabel.font = .createdTitle
        titleLabel.textColor = .white
        titleLabel.fadedBackground()
        
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(starRatingView)
        
        imageView.addSubview(titleStackView)
        
        NSLayoutConstraint.activate([
            titleStackView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 10),
            titleStackView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10),
        ])
    }
    
    private func arrangeConstraints() {
        // scroll view
        distanceOfImageView = view.frame.width * 0.7
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        headerTopConstraint = headerContainerView.topAnchor.constraint(equalTo: view.topAnchor)
        headerHeightConstraint = headerContainerView.heightAnchor.constraint(equalToConstant: distanceOfImageView)
        let headerContainerViewConstraints: [NSLayoutConstraint] = [
            headerTopConstraint,
            headerContainerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1.0),
            headerHeightConstraint
        ]
        
        NSLayoutConstraint.activate(headerContainerViewConstraints)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: distanceOfImageView),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    
    
    private func setUp() {
        self.title = ""
        self.setNavigationBarColor(color: Colors.navigationBarColor.withAlphaComponent(0.0))
        self.navigationController?.navigationBar.tintColor = Colors.main
        
        view.backgroundColor = .systemBackground
        
        scrollView = setUpScrollView()
        stackView = setUpStackView()
        imageView = setUpImageView()
        headerContainerView = setUpHeaderContainerView()
        
        view.addSubview(scrollView)
        headerContainerView.addSubview(imageView)
        scrollView.addSubview(headerContainerView)
        scrollView.addSubview(stackView)
        
        arrangeConstraints()
        
        setTitleInfo()
        imageView.layoutIfNeeded()
        distanceOfImageView = imageView.bounds.height - (self.navigationController?.navigationBar.bounds.height ?? 0.0)
        
        Network.shared.getImage(url: restaurant.imageURL) { (img) in
            self.imageView.image = img
        }
        
        Network.shared.setRestaurantReviewInfo(restaurant: restaurant) { (reviews) in
            print("Done adding the reviews, now add them to the UI: \(reviews.map({$0.reviewerName}))")
            if reviews.count > 0 {
                self.restaurant.reviews = reviews
                for review in self.restaurant.reviews {
                    let reviewView = ReviewView(review: review)
                    self.stackView.addArrangedSubview(reviewView)
                }
                self.scrollView.setCorrectContentSize()
            }
        }
        
        for i in 1...10 {
            let label = UILabel()
            label.text = "\(i)"
            stackView.addArrangedSubview(label)
        }
        
        
        scrollView.setCorrectContentSize()
        
    }
    

}



extension RestaurantDetailVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let navHeight = (navigationController?.navigationBar.frame.height ?? 0.0)
        let offset = scrollView.contentOffset.y - navHeight
        
        if offset < 0.0 {
            // Scrolling down: Scale
            headerHeightConstraint?.constant = distanceOfImageView - offset
        } else {
            // Scrolling up: Parallax
            let parallaxFactor: CGFloat = 0.25
            let offsetY = scrollView.contentOffset.y * parallaxFactor
            let minOffsetY: CGFloat = 8.0
            let availableOffset = min(offsetY, minOffsetY)
            let contentRectOffsetY = availableOffset / distanceOfImageView
            headerTopConstraint?.constant = view.frame.origin.y
            headerHeightConstraint?.constant = distanceOfImageView - offset
            imageView.layer.contentsRect = CGRect(x: 0, y: -contentRectOffsetY, width: 1, height: 1)
        }
        
        

        let secondOffset = scrollView.contentOffset.y
        
        if secondOffset > distanceOfImageView {
            
            if navigationTitleHidden {
                self.title = restaurant.name
                navigationTitleHidden = false
            }
            
            if latestAlpha != 1.0 {
                self.setNavigationBarColor(color: Colors.navigationBarColor.withAlphaComponent(1.0))
            }
        } else {
            
            if !navigationTitleHidden {
                self.title = ""
                navigationTitleHidden = true
            }
            
            var ratio: Double {
                if secondOffset < 0.0 {
                    return 0.0
                } else {
                    return Double((secondOffset / distanceOfImageView) * 100).rounded() / 100
                }
            }
            
            if ratio != latestAlpha {
                self.setNavigationBarColor(color: Colors.navigationBarColor.withAlphaComponent(CGFloat(ratio)))
                
                latestAlpha = ratio
            }
            
        }
        
        
    }
}
