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
    func establishmentSelected(establishment: Establishment)
    func moreImageRequest(visit: Visit?, cell: VisitCell)
    func newPhotoIndexSelected(idx: Int, for visit: Visit?)
}


class VisitCell: UITableViewCell {
    
    var visit: Visit?
    let visitImageView = UIImageView()
    var otherImagesFound = false
    var otherImageViews: [UIImageView] = []
    var requested = false
    
    weak var delegate: VisitCellDelegate?
    private let base = UIView()
    private let baseHeight: CGFloat = 250.0
    private let scrollingStackView = ScrollingStackView(subViews: [], showPlaceholder: true)
    private let restaurantNameButton = SizeChangeButton(sizeDifference: .inverse, restingColor: .label, selectedColor: Colors.main)
    private let commentLabel = UILabel()
    private var visitImageViewHeightConstraint: NSLayoutConstraint?
    private let dateLabel = UILabel()
    private let ratingLabel = UILabel()
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
        
        
        
        let lowerStackView = setUpLowerStack()
        
        setUpRestaurantNameLabel()
        lowerStackView.addArrangedSubview(restaurantNameButton)
        
        setUpCommentLabel()
        lowerStackView.addArrangedSubview(commentLabel)
    }
    
    private func setUpBase() {
        base.translatesAutoresizingMaskIntoConstraints = false
        base.backgroundColor = .secondarySystemBackground
        contentView.addSubview(base)
        base.constrainSides(to: contentView, distance: 7.5)
        base.layer.cornerRadius = 10.0
        base.clipsToBounds = true
    }
    
    private func setUpUiElementsForDateAndButtons() {
        dateAndButtonStackView = UIStackView()
        
        dateAndButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        dateAndButtonStackView.axis = .horizontal
        dateAndButtonStackView.spacing = 5.0
        dateAndButtonStackView.distribution = .fill
        
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        dateAndButtonStackView.addArrangedSubview(ratingLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .mediumBold
        dateLabel.textColor = .secondaryLabel
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
        scrollingStackView.delegate = self
        
        scrollingStackView.scrollView.isUserInteractionEnabled = false
        contentView.addGestureRecognizer(scrollingStackView.scrollView.panGestureRecognizer)
        scrollingStackView.stackView.addArrangedSubview(visitImageView)
        visitImageView.translatesAutoresizingMaskIntoConstraints = false
        scrollingStackView.stackView.spacing = 0.0
        visitImageView.widthAnchor.constraint(equalTo: scrollingStackView.scrollView.widthAnchor).isActive = true
        
        visitImageViewHeightConstraint = visitImageView.heightAnchor.constraint(equalToConstant: baseHeight)
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
        restaurantNameButton.titleLabel?.numberOfLines = 2
        restaurantNameButton.titleLabel?.font = .secondaryTitle
        restaurantNameButton.translatesAutoresizingMaskIntoConstraints = false
        restaurantNameButton.setTitle("Restaurant name", for: .normal)
        restaurantNameButton.addTarget(self, action: #selector(restaurantNameSelected), for: .touchUpInside)
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
    
    @objc private func restaurantNameSelected() {
        if let establishment = visit?.getEstablishment() {
            delegate?.establishmentSelected(establishment: establishment)
        }
    }
    
    func setUpWith(visit: Visit, selectedPhotoIndex: Int?) {
        self.visit = visit
        self.requested = false
        imageView?.image = nil
        commentLabel.text = visit.comment ?? "By \(visit.accountUsername)"
        restaurantNameButton.setTitle(visit.restaurantName, for: .normal)
        
        dateLabel.text = visit.userDate
        ratingLabel.attributedText = visit.ratingString
        
        
        otherImageViews.forEach { (iv) in
            iv.removeFromSuperview()
        }
        otherImageViews = []
        
        for _ in visit.otherImages {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            scrollingStackView.stackView.addArrangedSubview(imageView)
            imageView.layoutIfNeeded()
            imageView.heightAnchor.constraint(equalTo: visitImageView.heightAnchor).isActive = true
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            otherImageViews.append(imageView)
        }
        
        scrollingStackView.layoutIfNeeded()
        
        if let selectedPhotoIndex = selectedPhotoIndex, scrollingStackView.stackView.arrangedSubviews.indices.contains(selectedPhotoIndex)  {
            let scrollingToRect = otherImageViews[selectedPhotoIndex - 1].frame
            
            scrollingStackView.scrollView.scrollRectToVisible(scrollingToRect, animated: false)
            scrollingStackView.resetElements(selectedIndex: selectedPhotoIndex)
        } else {
            scrollingStackView.scrollView.contentOffset = .zero
            scrollingStackView.resetElements()
        }
        
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

// MARK: ScrollingStackViewDelegate
extension VisitCell: ScrollingStackViewDelegate {
    
    func newIndexSelected(idx: Int) {
        delegate?.newPhotoIndexSelected(idx: idx, for: visit)
    }
    
    func scrollViewScrolled() {
        if !requested {
            requested = true
            delegate?.moreImageRequest(visit: visit, cell: self)
        }
        
    }
}
