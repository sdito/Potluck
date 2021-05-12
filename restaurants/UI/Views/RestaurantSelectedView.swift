//
//  RestaurantSelectedView.swift
//  restaurants
//
//  Created by Steven Dito on 7/27/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Hero


protocol RestaurantSelectedViewDelegate: AnyObject {
    func nextButtonSelected(rest: Restaurant)
    func previousButtonSelected(rest: Restaurant)
    func restaurantSelected(rest: Restaurant)
    func dismissView()
}


class RestaurantSelectedView: UIView {
    
    private var restaurant: Restaurant!
    private weak var delegate: RestaurantSelectedViewDelegate!
    private var innerStackView = UIStackView()
    let imageView = UIImageView()
    private var titleLabel = UILabel()
    private var starRatingView: StarRatingView!
    private var moneyAndTypeLabel = UILabel()
    private let backButtonTag = 11
    private let forwardButtonTag = 12
    private var backAndForwardButtons: [UIButton] = []
    private var backButton: UIButton?
    private var forwardButton: UIButton?
    private let padding: CGFloat = 5.0
    private let cornerRadius: CGFloat = 10.0
    private var dummyView: RestaurantSelectedView?
    private var initialFrameY: CGFloat?
    
    private var imageForNextView: (rest: Restaurant, image: UIImage?)?
    private var animationInProgress = false
    private var initialTouchPointY: CGFloat?
    
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
        setUpBackAndNextButtons(isFirst: false, isLast: false)
        setUpImageView(restaurant: restaurant, isDummy: true)
        setUpInnerStackView()
        setUpTopRightContents(restaurant: restaurant)
        
        self.layoutIfNeeded()
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
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
            dummyView = RestaurantSelectedView(dummy: restaurant)
            dummyView!.translatesAutoresizingMaskIntoConstraints = false
            
            parent.view.addSubview(dummyView!)
            
            NSLayoutConstraint.activate([
                dummyView!.widthAnchor.constraint(equalToConstant: dummyWidth),
                dummyView!.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                
            ])
            
            var transformation: CGAffineTransform {
                switch updateStyle {
                case .back:
                    dummyView!.trailingAnchor.constraint(equalTo: parent.view.leadingAnchor).isActive = true
                    return CGAffineTransform(translationX: dummyWidth + extraWidth, y: 0)
                case .forward:
                    dummyView!.leadingAnchor.constraint(equalTo: parent.view.trailingAnchor).isActive = true
                    return CGAffineTransform(translationX: -(dummyWidth + extraWidth), y: 0)
                case .none:
                    return CGAffineTransform.identity
                }
            }
            
            UIView.animate(withDuration: 0.5, animations: {
                self.dummyView!.transform = transformation
            }) { (complete) in
                self.dummyView!.removeFromSuperview()
                self.dummyView = nil
                animationDone(true)
            }
        }
    }
    
    func updateWithNewRestaurant(restaurant: Restaurant, isFirst: Bool, isLast: Bool, updateStyle: UpdateStyle) {
        imageForNextView = nil
        
        Network.shared.getImage(url: restaurant.imageURL) { (image) in
            guard let image = image else { return }
            DispatchQueue.global(qos: .userInteractive).async {
                let resized = image.resizeToBeNoLargerThanScreenWidth()
                DispatchQueue.main.async {
                    self.imageForNextView = (restaurant, resized)
                    self.dummyView?.imageView.image = resized
                    if !self.animationInProgress {
                        self.imageView.image = resized
                    }
                }
            }
        }
        
        animationInProgress = true
        performUpdateAnimation(restaurant: restaurant, isFirst: isFirst, isLast: isLast, updateStyle: updateStyle) { [weak self] (complete) in
            defer { self?.animationInProgress = false }
            self?.imageView.image = nil
            guard let self = self else { return }
            if self.restaurant.id != restaurant.id {
                self.restaurant = restaurant
                self.titleLabel.text = restaurant.name
                self.starRatingView.updateNumberOfStarsAndReviews(stars: restaurant.rating ?? 0.0, numReviews: restaurant.reviewCount ?? 0)
                self.setMoneyAndTypeLabelText(restaurant)
                
                // make sure it is setting for the right restaurant
                if self.imageForNextView?.rest.id == restaurant.id {
                    self.imageView.image = self.imageForNextView?.image
                }
                
                for potentialView in self.backAndForwardButtons {
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
        
        setUpBackAndNextButtons(isFirst: isFirst, isLast: isLast)
        setUpImageView(restaurant: restaurant)
        setUpInnerStackView()
        setUpTopRightContents(restaurant: restaurant)
        
        self.layoutIfNeeded()
        self.shadowAndRounded(cornerRadius: cornerRadius)
        
        addGestureRecognizers()
    }
    
    private func setUpBackAndNextButtons(isFirst: Bool, isLast: Bool) {
        let buttonData = [(backButtonTag, "<"), (forwardButtonTag, ">")]
        for data in buttonData {
            let newButton = SizeChangeButton(sizeDifference: .large, restingColor: Colors.secondary, selectedColor: Colors.main)
            newButton.translatesAutoresizingMaskIntoConstraints = false
            newButton.setTitle(data.1, for: .normal)
            newButton.tag = data.0
            newButton.setTitleColor(Colors.main, for: .normal)
            newButton.titleLabel?.font = .createdTitle
            newButton.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
            newButton.addTarget(self, action: #selector(backOrForwardPressed), for: .touchUpInside)
            
            self.addSubview(newButton)
            newButton.constrain(.top, to: self, .top, constant: padding)
            newButton.constrain(.bottom, to: self, .bottom, constant: padding)
            
            if data.0 == backButtonTag {
                backButton = newButton
                newButton.constrain(.leading, to: self, .leading, constant: padding)
            } else if data.0 == forwardButtonTag {
                forwardButton = newButton
                newButton.constrain(.trailing, to: self, .trailing, constant: padding)
            }
            
            backAndForwardButtons.append(newButton)
            
            if (isFirst && data.0 == backButtonTag) || (isLast && data.0 == forwardButtonTag) {
                newButton.isUserInteractionEnabled = false
                newButton.alpha = 0.0
            }
        }
    }

    private func setUpImageView(restaurant: Restaurant, isDummy: Bool = false) {
        guard let backButton = backButton else { return }
        // left side of innerTopStackView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let imageViewWidth = UIScreen.main.bounds.width / 4.0
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.layer.cornerRadius = 4.0
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        self.addSubview(imageView)
        imageView.equalSides(size: imageViewWidth)
        
        imageView.constrain(.leading, to: backButton, .trailing, constant: padding)
        imageView.constrain(.top, to: self, .top, constant: padding)
        imageView.constrain(.bottom, to: self, .bottom, constant: padding)
        
        if !isDummy {
            imageView.addImageFromUrl(restaurant.imageURL, autoResize: true, skeleton: true)
        } 
        
    }
    
    private func setUpInnerStackView() {
        // Contains the title, star rating, and categories
        // Issues with continual laying out
        guard let forwardButton = forwardButton else { return }
        innerStackView.translatesAutoresizingMaskIntoConstraints = false
        innerStackView.axis = .vertical
        innerStackView.spacing = 2.0
        innerStackView.distribution = .fill
        innerStackView.alignment = .leading
        
        self.addSubview(innerStackView)
        innerStackView.constrain(.leading, to: imageView, .trailing, constant: padding)
        innerStackView.constrain(.top, to: imageView, .top, constant: padding)
        innerStackView.constrain(.bottom, to: imageView, .bottom, constant: padding)
        innerStackView.constrain(.trailing, to: forwardButton, .leading)
    }
    
    private func setUpTopRightContents(restaurant: Restaurant) {
        // Label with title
        // Dollar sign and food type
        // Star view
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = restaurant.name
        titleLabel.font = .largerBold
        titleLabel.numberOfLines = 2
        innerStackView.addArrangedSubview(titleLabel)
        titleLabel.widthAnchor.constraint(equalTo: innerStackView.widthAnchor).isActive = true
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical) // a
        
        moneyAndTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        setMoneyAndTypeLabelText(restaurant)
        moneyAndTypeLabel.textColor = .secondaryLabel
        moneyAndTypeLabel.font = .smallerThanNormal
        moneyAndTypeLabel.numberOfLines = 2
        innerStackView.addArrangedSubview(moneyAndTypeLabel)
        moneyAndTypeLabel.widthAnchor.constraint(equalTo: innerStackView.widthAnchor).isActive = true
        moneyAndTypeLabel.setContentHuggingPriority(.required, for: .vertical) // b
        
        starRatingView = StarRatingView(stars: restaurant.rating ?? 0.0, numReviews: restaurant.reviewCount ?? 0, forceWhite: false, noBackgroundColor: true)
        innerStackView.addArrangedSubview(starRatingView)
        starRatingView.setContentHuggingPriority(.required, for: .vertical) // c
        
        // (a), (b), and (c) to force the titleLabel to fill up the most possible space
    }
    
    private func setMoneyAndTypeLabelText(_ rest: Restaurant) {
        var text = "\(rest.price ?? "$$")"
        if let categories = rest.categories {
            text.append(" · \(categories.joined(separator: ", "))")
        }
        moneyAndTypeLabel.text = text
    }
    
    private func addGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gestureRecognizerSelector(sender:)))
        self.addGestureRecognizer(tapGestureRecognizer)
        
        let swipeGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeGestureRecognizerSelector(sender:)))
        self.addGestureRecognizer(swipeGestureRecognizer)
    }

    @objc private func gestureRecognizerSelector(sender: UITapGestureRecognizer) {
        delegate.restaurantSelected(rest: restaurant)
    }
    
    @objc private func swipeGestureRecognizerSelector(sender: UIPanGestureRecognizer) {
        let touchPointY = sender.translation(in: self).y
        switch sender.state {
        case .began:
            self.initialTouchPointY = touchPointY
            self.initialFrameY = self.frame.origin.y
            
        case .changed:
            guard let initialTouchPointY = self.initialTouchPointY else { return }
            var difference = touchPointY - initialTouchPointY
            if difference > 0 {
                // means scrolling down, don't want to let the user scroll the view way down, so use square root on the difference
                difference = CGFloat(sqrt(difference))
            }
            let newOriginY = difference + (initialFrameY ?? 0.0)
            self.frame.origin.y = newOriginY
            
            // Square root for bottom
        case .ended:
            guard let initialTouchPointY = self.initialTouchPointY else { return }
            let difference = touchPointY - initialTouchPointY
            self.initialTouchPointY = nil
 
            if difference > 0 {
                // is belowInitial, just scroll back
                UIView.animate(withDuration: 0.3) {
                    self.frame.origin.y = (self.initialFrameY ?? 0.0)
                }
            } else {
                self.delegate.dismissView()
            }
            
        default:
            break
        }
    }
    
    func setUpForHero() {
        self.isHeroEnabled = true
        self.imageView.hero.id = .restaurantHomeToDetailImageView
        self.starRatingView.hero.id = .restaurantHomeToDetailStarRatingView
    }
    
    @objc private func backOrForwardPressed(sender: UIButton) {
        if sender.tag == backButtonTag {
            delegate.previousButtonSelected(rest: restaurant)
        } else if sender.tag == forwardButtonTag {
            delegate.nextButtonSelected(rest: restaurant)
        }
    }
    
}



