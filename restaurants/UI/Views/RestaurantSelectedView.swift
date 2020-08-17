//
//  RestaurantSelectedView.swift
//  restaurants
//
//  Created by Steven Dito on 7/27/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Hero


protocol RestaurantSelectedViewDelegate: class {
    func nextButtonSelected(rest: Restaurant)
    func previousButtonSelected(rest: Restaurant)
    func restaurantSelected(rest: Restaurant)
}


class RestaurantSelectedView: UIView {
    
    private var restaurant: Restaurant!
    private weak var delegate: RestaurantSelectedViewDelegate!
    private var wholeStackView = UIStackView()
    private var outerStackView = UIStackView()
    private var innerTopStackView = UIStackView()
    private var topRightStackView = UIStackView()
    var imageView = UIImageView()
    private var titleLabel = UILabel()
    private var starRatingView: StarRatingView!
    private var moneyAndTypeLabel = UILabel()
    private let backButtonTag = 11
    private let forwardButtonTag = 12
    private var backAndForwardButtons: [UIButton] = []
    
    enum UpdateStyle {
        case back
        case forward
        case none
    }
    
    init(restaurant: Restaurant, isFirst: Bool, isLast: Bool, vc: UIViewController) {
        super.init(frame: .zero)
        self.delegate = vc as? RestaurantSelectedViewDelegate
        setUp(restaurant: restaurant, isFirst: isFirst, isLast: isLast)
    }
    
    init(dummy restaurant: Restaurant) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .secondarySystemBackground
        
        setUpWholeStackView()
        setUpBackAndNextButtons(isFirst: true, isLast: true)
        setUpOuterStackView()
        setUpInnerTopStackView()
        setUpImageView(restaurant: restaurant, isDummy: true)
        setUpTopRightStackView()
        setUpTopRightContents(restaurant: restaurant)
        
        self.layoutIfNeeded()
        self.shadowAndRounded(cornerRadius: 10.0)
        
        
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func performUpdateAnimation(restaurant: Restaurant, isFirst: Bool, isLast: Bool, updateStyle: UpdateStyle, animationDone: @escaping (Bool) -> Void) {
        
        guard updateStyle != .none else {
            animationDone(true)
            return
        }
        
        let dummyWidth = self.frame.width
        
        // extra width equal to the extra distance needed, whole view width minus dummyWidth, divided by two (view is centered)
        let extraWidth = (UIScreen.main.bounds.width - dummyWidth) / 2.0
        
        // ** example for coming from the left
        if let parent = self.findViewController() {
            let dummyView = RestaurantSelectedView(dummy: restaurant)
            dummyView.translatesAutoresizingMaskIntoConstraints = false
            
            parent.view.addSubview(dummyView)
            
            NSLayoutConstraint.activate([
                dummyView.widthAnchor.constraint(equalToConstant: dummyWidth),
                dummyView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                
            ])
            
            var transformation: CGAffineTransform {
                switch updateStyle {
                case .back:
                    dummyView.trailingAnchor.constraint(equalTo: parent.view.leadingAnchor).isActive = true
                    return CGAffineTransform(translationX: dummyWidth + extraWidth, y: 0)
                case .forward:
                    dummyView.leadingAnchor.constraint(equalTo: parent.view.trailingAnchor).isActive = true
                    return CGAffineTransform(translationX: -(dummyWidth + extraWidth), y: 0)
                case .none:
                    return CGAffineTransform.identity
                }
            }
            
            
            UIView.animate(withDuration: 0.5, animations: {
                dummyView.transform = transformation
            }) { (complete) in
                dummyView.removeFromSuperview()
                animationDone(true)
            }
        }
    }
    
    func updateWithNewRestaurant(restaurant: Restaurant, isFirst: Bool, isLast: Bool, updateStyle: UpdateStyle) {
        
        performUpdateAnimation(restaurant: restaurant, isFirst: isFirst, isLast: isLast, updateStyle: updateStyle) { (complete) in
            if self.restaurant.id != restaurant.id {
                self.restaurant = restaurant
                self.titleLabel.text = restaurant.name
                self.starRatingView.updateNumberOfStarsAndReviews(stars: restaurant.rating, numReviews: restaurant.reviewCount)
                self.imageView.addImageFromUrl(restaurant.imageURL, skeleton: true)
                self.setMoneyAndTypeLabelText(restaurant)
                
                for potentialView in self.wholeStackView.subviews {
                    if potentialView.tag == self.backButtonTag {
                        if isFirst {
                            potentialView.isUserInteractionEnabled = false
                            potentialView.alpha = 0.0
                        } else {
                            potentialView.isUserInteractionEnabled = true
                            potentialView.alpha = 1.0
                        }
                    } else if potentialView.tag == self.forwardButtonTag {
                        if isLast {
                            potentialView.isUserInteractionEnabled = false
                            potentialView.alpha = 0.0
                        } else {
                            potentialView.isUserInteractionEnabled = true
                            potentialView.alpha = 1.0
                        }
                    }
                }
            }
        }
    }
    
    private func setUp(restaurant: Restaurant, isFirst: Bool, isLast: Bool) {
        self.restaurant = restaurant
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .secondarySystemBackground
        
        setUpWholeStackView()
        setUpBackAndNextButtons(isFirst: isFirst, isLast: isLast)
        setUpOuterStackView()
        setUpInnerTopStackView()
        setUpImageView(restaurant: restaurant)
        setUpTopRightStackView()
        setUpTopRightContents(restaurant: restaurant)
        
        self.layoutIfNeeded()
        self.shadowAndRounded(cornerRadius: 10.0)
        
        layerButtonForTouchEvents()
    }
    
    private func setUpWholeStackView() {
        wholeStackView.translatesAutoresizingMaskIntoConstraints = false
        wholeStackView.spacing = 5.0
        wholeStackView.distribution = .fill
        wholeStackView.alignment = .fill
        wholeStackView.axis = .horizontal
        self.addSubview(wholeStackView)
        wholeStackView.constrainSides(to: self, distance: 10.0)
    }
    
    private func setUpBackAndNextButtons(isFirst: Bool, isLast: Bool) {
        let buttonData = [(backButtonTag, "<"), (forwardButtonTag, ">")]
        for data in buttonData {
            let newButton = SizeChangeButton(sizeDifference: .large, restingColor: Colors.secondary, selectedColor: Colors.main)
            newButton.translatesAutoresizingMaskIntoConstraints = false
            wholeStackView.addArrangedSubview(newButton)
            newButton.setTitle(data.1, for: .normal)
            newButton.tag = data.0
            newButton.setTitleColor(Colors.main, for: .normal)
            newButton.titleLabel?.font = .createdTitle
            newButton.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
            newButton.addTarget(self, action: #selector(backOrForwardPressed), for: .touchUpInside)
            
            backAndForwardButtons.append(newButton)
            
            if (isFirst && data.0 == backButtonTag) || (isLast && data.0 == forwardButtonTag) {
                newButton.isUserInteractionEnabled = false
                newButton.alpha = 0.0
            }
        }
    }
    
    private func setUpOuterStackView() {
        outerStackView.translatesAutoresizingMaskIntoConstraints = false
        outerStackView.axis = .vertical
        outerStackView.spacing = 5.0
        outerStackView.distribution = .fill
        outerStackView.alignment = .fill
        wholeStackView.insertArrangedSubview(outerStackView, at: 1)
    }
    
    private func setUpInnerTopStackView() {
        // Image view on left
        // Title, stars, etc in a stack view vertically on the right
        innerTopStackView.translatesAutoresizingMaskIntoConstraints = false
        innerTopStackView.axis = .horizontal
        innerTopStackView.spacing = 5.0
        innerTopStackView.distribution = .fill
        innerTopStackView.alignment = .fill
        outerStackView.addArrangedSubview(innerTopStackView)
    }
    
    private func setUpImageView(restaurant: Restaurant, isDummy: Bool = false) {
        // left side of innerTopStackView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let imageViewWidth = UIScreen.main.bounds.width / 4.0
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.layer.cornerRadius = 4.0
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        innerTopStackView.addArrangedSubview(imageView)
        
        imageView.heightAnchor.constraint(equalToConstant: imageViewWidth).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: imageViewWidth).isActive = true
        
        if !isDummy {
            imageView.addImageFromUrl(restaurant.imageURL, skeleton: true)
        }
        
    }
    
    private func setUpTopRightStackView() {
        topRightStackView.translatesAutoresizingMaskIntoConstraints = false
        topRightStackView.axis = .vertical
        topRightStackView.spacing = 5.0
        topRightStackView.distribution = .fill
        topRightStackView.alignment = .leading
        innerTopStackView.addArrangedSubview(topRightStackView)
    }
    
    private func setUpTopRightContents(restaurant: Restaurant) {
        // Label with title
        // Star view
        // Dollar sign and food type
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = restaurant.name
        titleLabel.font = .largerBold
        titleLabel.numberOfLines = 2
        topRightStackView.addArrangedSubview(titleLabel)
        
        starRatingView = StarRatingView(stars: restaurant.rating, numReviews: restaurant.reviewCount, forceWhite: false, noBackgroundColor: true)
        topRightStackView.addArrangedSubview(starRatingView)
        
        moneyAndTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        setMoneyAndTypeLabelText(restaurant)
        moneyAndTypeLabel.textColor = .secondaryLabel
        moneyAndTypeLabel.font = .mediumBold
        moneyAndTypeLabel.numberOfLines = 2
        topRightStackView.addArrangedSubview(moneyAndTypeLabel)
        
    }
    
    private func setMoneyAndTypeLabelText(_ rest: Restaurant) {
        moneyAndTypeLabel.text = "\(rest.price ?? "$$") · \(rest.categories.joined(separator: ", "))"
    }
    
    
    private func layerButtonForTouchEvents() {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        outerStackView.addSubview(button)
        
        button.constrainSides(to: outerStackView)
        
        button.addTarget(self, action: #selector(touchDownSel), for: [.touchDown, .touchDragEnter])
        button.addTarget(self, action: #selector(touchUpSel), for: [.touchDragExit, .touchUpInside])
        button.addTarget(self, action: #selector(buttonSelected), for: .touchUpInside)
        
        
    }

    
    func setUpForHero() {
        self.isHeroEnabled = true
        self.titleLabel.hero.id = .restaurantHomeToDetailTitle
        self.imageView.hero.id = .restaurantHomeToDetailImageView
        self.starRatingView.hero.id = .restaurantHomeToDetailStarRatingView
    }
    
    
    @objc private func touchDownSel() {
        // Transform the view to show it is being selected
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        })
    }

    @objc private func touchUpSel() {
        // Transform the view back to normal
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    
    @objc private func buttonSelected() {
        delegate.restaurantSelected(rest: restaurant)
    }
    
    @objc private func backOrForwardPressed(sender: UIButton) {
        if sender.tag == backButtonTag {
            delegate.previousButtonSelected(rest: restaurant)
        } else if sender.tag == forwardButtonTag {
            delegate.nextButtonSelected(rest: restaurant)
        }
    }
    
}



