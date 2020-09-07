//
//  VisitCell.swift
//  restaurants
//
//  Created by Steven Dito on 8/25/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//



import UIKit


protocol VisitCellDelegate: class {
    func delete(visit: Visit?)
}


class VisitCell: UITableViewCell {
    
    var visit: Visit?
    weak var delegate: VisitCellDelegate?
    private let base = UIView()
    private let baseHeight: CGFloat = 250.0
    private let scrollingStackView = ScrollingStackView(subViews: [], showPlaceholder: true)
    let visitImageView = UIImageView()
    private let restaurantNameLabel = UILabel()
    private let commentLabel = UILabel()
    private var visitImageViewHeightConstraint: NSLayoutConstraint?
    private let dateLabel = UILabel()
    private var dateAndButtonStackView: UIStackView!
    private var dateAndButtonContainerView: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUiElements()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpUiElements() {
        self.backgroundColor = .clear
        setUpBase()
        setUpUiElementsForDateAndButtons()
        setUpScrollingStack()
        
        let secondView = UIView()
        secondView.translatesAutoresizingMaskIntoConstraints = false
        scrollingStackView.stackView.addArrangedSubview(secondView)
        secondView.backgroundColor = .blue
        secondView.layoutIfNeeded()
        secondView.heightAnchor.constraint(equalTo: visitImageView.heightAnchor).isActive = true
        
        let lowerStackView = setUpLowerStack()
        
        setUpRestaurantNameLabel()
        lowerStackView.addArrangedSubview(restaurantNameLabel)
        
        setUpCommentLabel()
        lowerStackView.addArrangedSubview(commentLabel)
    }
    
    private func setUpBase() {
        base.translatesAutoresizingMaskIntoConstraints = false
        base.backgroundColor = .systemBackground
        self.addSubview(base)
        base.constrainSides(to: self, distance: 7.5)
        base.layer.cornerRadius = 10.0
        base.clipsToBounds = true
    }
    
    private func setUpUiElementsForDateAndButtons() {
        dateAndButtonStackView = UIStackView()
        
        dateAndButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        dateAndButtonStackView.axis = .horizontal
        dateAndButtonStackView.spacing = 5.0
        dateAndButtonStackView.distribution = .fill
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .mediumBold
        dateLabel.textColor = .tertiaryLabel
        dateAndButtonStackView.addArrangedSubview(dateLabel)
        
        // to take up the space in the middle, as a spacer
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        dateAndButtonStackView.addArrangedSubview(spacer)
        
        let mapButton = UIButton()
        mapButton.translatesAutoresizingMaskIntoConstraints = false
        mapButton.setImage(.mapImage, for: .normal)
        mapButton.tintColor = Colors.main
        mapButton.addTarget(self, action: #selector(mapAction), for: .touchUpInside)
        dateAndButtonStackView.addArrangedSubview(mapButton)
        
        let moreActionsButton = UIButton()
        moreActionsButton.translatesAutoresizingMaskIntoConstraints = false
        moreActionsButton.setImage(.threeDotsImage, for: .normal)
        moreActionsButton.tintColor = Colors.main
        moreActionsButton.addTarget(self, action: #selector(moreActionsSelector), for: .touchUpInside)
        dateAndButtonStackView.addArrangedSubview(moreActionsButton)
        
        
        base.addSubview(dateAndButtonStackView)
        dateAndButtonContainerView = UIView()
        dateAndButtonContainerView.translatesAutoresizingMaskIntoConstraints = false
        dateAndButtonContainerView.addSubview(dateAndButtonStackView)
        
        base.addSubview(dateAndButtonContainerView)
        
        dateAndButtonStackView.constrainSides(to: dateAndButtonContainerView, distance: 10.0)
        
        dateAndButtonContainerView.widthAnchor.constraint(equalTo: base.widthAnchor).isActive = true
        dateAndButtonContainerView.constrain(.top, to: base, .top)
        dateAndButtonContainerView.constrain(.leading, to: base, .leading)
        dateAndButtonContainerView.constrain(.trailing, to: base, .trailing)
        
    }
    
    private func setUpScrollingStack() {
        base.addSubview(scrollingStackView)
        scrollingStackView.constrain(.top, to: dateAndButtonContainerView, .bottom)
        scrollingStackView.constrain(.leading, to: base, .leading)
        scrollingStackView.constrain(.trailing, to: base, .trailing)
        
        scrollingStackView.stackView.distribution = .fillEqually
        scrollingStackView.scrollView.isPagingEnabled = true
        scrollingStackView.stackView.spacing = 3.0
        
        scrollingStackView.stackView.addArrangedSubview(visitImageView)
        visitImageView.translatesAutoresizingMaskIntoConstraints = false
        visitImageView.widthAnchor.constraint(equalTo: scrollingStackView.scrollView.widthAnchor).isActive = true
        
        visitImageViewHeightConstraint = visitImageView.heightAnchor.constraint(equalToConstant: baseHeight)
        visitImageViewHeightConstraint?.priority = .defaultLow
        visitImageViewHeightConstraint?.isActive = true
        visitImageView.contentMode = .scaleAspectFill
    }
    
    private func setUpLowerStack() -> UIStackView {
        let lowerStackView = UIStackView()
        lowerStackView.translatesAutoresizingMaskIntoConstraints = false
        lowerStackView.distribution = .fill
        lowerStackView.alignment = .leading
        lowerStackView.axis = .vertical
        lowerStackView.spacing = 3.0
        
        base.addSubview(lowerStackView)
        
        lowerStackView.constrain(.top, to: scrollingStackView, .bottom, constant: 10.0)
        lowerStackView.constrain(.leading, to: base, .leading, constant: 10.0)
        lowerStackView.constrain(.trailing, to: base, .trailing, constant: 10.0)
        lowerStackView.constrain(.bottom, to: base, .bottom, constant: 10.0)
        
        return lowerStackView
    }
    
    private func setUpRestaurantNameLabel() {
        restaurantNameLabel.numberOfLines = 0
        restaurantNameLabel.font = .secondaryTitle
        restaurantNameLabel.translatesAutoresizingMaskIntoConstraints = false
        restaurantNameLabel.text = "Restaurant name"
    }
    
    private func setUpCommentLabel() {
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.text = "This is the text for the comment"
        commentLabel.textColor = .secondaryLabel
        commentLabel.font = .smallerThanNormal
        commentLabel.numberOfLines = 0
    }
    
    @objc private func mapAction() {
        
        guard let parent = self.findViewController() else { return }
        
        if let coordinate = visit?.coordinate {
            let mapLocationView = MapLocationView(locationTitle: visit?.restaurantName ?? "Location", coordinate: coordinate, address: nil, userInteractionEnabled: true, wantedDistance: 1000)
            mapLocationView.equalSides(size: UIScreen.main.bounds.width * 0.8)
            mapLocationView.layer.cornerRadius = 25.0
            mapLocationView.clipsToBounds = true
            let newVc = ShowViewVC(newView: mapLocationView, fromBottom: true)
            newVc.modalPresentationStyle = .overFullScreen
            parent.present(newVc, animated: false, completion: nil)
        } else {
            #warning("need to test")
            parent.showMessage("No location found", on: parent)
        }
    }
    
    @objc private func moreActionsSelector() {
        print("More actions was pressed")
        guard let delegate = delegate else { return }
        self.findViewController()?.actionSheet(actions: [
            ("Delete visit", { [weak self] in delegate.delete(visit: self?.visit) })
        ])
        
    }
    
    func setUpWith(visit: Visit) {
        self.visit = visit
        imageView?.image = nil
        commentLabel.text = visit.comment ?? "By \(visit.accountUsername)"
        restaurantNameLabel.text = visit.restaurantName
        scrollingStackView.resetElements()
        dateLabel.text = visit.userDate
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
