//
//  RestaurantSearchBar.swift
//  restaurants
//
//  Created by Steven Dito on 8/9/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Hero

class RestaurantSearchBar: UIView {
    
    var areViewsHidden = false
    let reloadButton = UIButton()
    private let searchStackView = UIStackView()
    private let searchTypeLabel = UILabel()
    private let locationLabel = UILabel()
    private let searchImage = UIImageView(image: .magnifyingGlassImage)
    private var loaderView: LoaderView?
    private var hasLoadedData = false
    private let stackViewSpacing: CGFloat = 4.0
    
    enum SearchOption {
        case type
        case location
    }
    
    init() {
        super.init(frame: .zero)
        setUpView()
        setUpStackView()
        setupSearchImage()
        addSearchTypeLabel()
        addLocationLabel()
        setUpReloadButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .tertiarySystemBackground
        self.layer.cornerRadius = stackViewSpacing
        self.clipsToBounds = true
        self.hero.id = .searchBarTransitionType
    }
    
    private func setUpStackView() {
        searchStackView.translatesAutoresizingMaskIntoConstraints = false
        searchStackView.axis = .horizontal
        searchStackView.distribution = .fill
        searchStackView.alignment = .center
        searchStackView.spacing = 7.0
        self.addSubview(searchStackView)
        searchStackView.constrainSides(to: self, distance: 4.0)
    }
    
    private func setupSearchImage() {
        searchImage.tintColor = Colors.main
        searchImage.equalSides()
        searchImage.setContentHuggingPriority(.required, for: .horizontal)
        searchStackView.addArrangedSubview(searchImage)
    }
    
    private func addSearchTypeLabel() {
        searchTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        searchTypeLabel.font = .mediumBold
        searchTypeLabel.textColor = .label
        searchTypeLabel.text = "Restaurants"
        searchTypeLabel.textAlignment = .left
        searchTypeLabel.setContentHuggingPriority(.required, for: .horizontal)
        searchStackView.addArrangedSubview(searchTypeLabel)
    }
    
    private func addLocationLabel() {
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = .smallBold
        locationLabel.textColor = .secondaryLabel
        locationLabel.text = "Location"
        locationLabel.textAlignment = .left
        searchStackView.addArrangedSubview(locationLabel)
    }
    
    private func setUpReloadButton() {
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        reloadButton.setImage(.reloadImage, for: .normal)
        reloadButton.tintColor = .tertiaryLabel
        reloadButton.setContentHuggingPriority(.required, for: .horizontal)
        reloadButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        searchStackView.addArrangedSubview(reloadButton)
    }
    
    func update(searchInfo: Network.RestaurantSearch) {
        if let category = searchInfo.yelpCategory {
            searchTypeLabel.text = category.title
        } else {
            searchTypeLabel.text = "Restaurants"
        }
    
        if let location = searchInfo.location {
            locationLabel.text = location
        } else {
            locationLabel.text = "Current location"
        }
        
        if loaderView != nil {
            loaderView?.removeFromSuperview()
        }
        
        if hasLoadedData {
            showActivityIndicator()
        }
        
        hasLoadedData = true
    }
    
    func showActivityIndicator() {
        reloadButton.isUserInteractionEnabled = false
        loaderView = searchImage.placeLoaderViewOnTop()
        loaderView!.backgroundColor = self.backgroundColor
    }
    
    func doneWithRestaurantSearch() {
        reloadButton.isUserInteractionEnabled = true
        self.loaderView?.removeFromSuperview()
    }
    
    func beginHeroAnimation() {
        areViewsHidden = true
        self.subviews.forEach { (v) in
            v.alpha = 0.0
        }
    }
    
    func endHeroAnimation() {
        areViewsHidden = false
        self.subviews.forEach { (v) in
            UIView.animate(withDuration: 0.3) {
                v.alpha = 1.0
            }
        }
    }
    
    func findIfSearchTypeOrLocationPressed(point: CGPoint) -> SearchOption {
        
        let middlePointOfViews = searchTypeLabel.frame.maxX
        
        if point.x < middlePointOfViews {
            return .type
        } else {
            return .location
        }
    }
    
    func addPressDownGestureOverView() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        self.layoutIfNeeded()
        let reloadButtonWidth = reloadButton.bounds.width
        let viewWidth = self.bounds.width
        
        let overlayButtonWidth = viewWidth - reloadButtonWidth - stackViewSpacing
        
        button.constrain(.leading, to: self, .leading)
        button.constrain(.top, to: self, .top)
        button.constrain(.bottom, to: self, .bottom)
        button.widthAnchor.constraint(equalToConstant: overlayButtonWidth).isActive = true
        button.addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        button.addTarget(self, action: #selector(touchUp), for: [.touchDragExit, .touchUpInside, .touchCancel])
        
        return button
    }
    
    @objc private func touchDown() {
        // Transform the view to show it is being selected
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        })
    }

    @objc private func touchUp() {
        // Transform the view back to normal
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    
}
