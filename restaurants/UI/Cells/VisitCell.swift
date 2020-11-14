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
    func updatedVisit(visit: Visit)
    func personSelected(for visit: Visit)
}


class VisitCell: UITableViewCell {
    
    var visit: Visit?
    let visitImageView = UIImageView()
    var otherImagesFound = false
    var otherImageViews: [UIImageView] = []
    var requested = false
    private var allowScrollViewDelegate = true
    
    var standardImageWidth: CGFloat {
        // probably not the best, used to calculate visitImageView height since it is based on width
        return UIScreen.main.bounds.width - (baseConstraintConstant * 2)
    }

    weak var delegate: VisitCellDelegate?
    private let base = UIView()
    private let baseHeight: CGFloat = 250.0
    private let baseConstraintConstant: CGFloat = 7.5
    private let scrollingStackView = ScrollingStackView(subViews: [], showPlaceholder: true)
    private let restaurantNameButton = SizeChangeButton(sizeDifference: .inverse, restingColor: .label, selectedColor: Colors.main)
    private let commentLabel = UILabel()
    var visitImageViewHeightConstraint: NSLayoutConstraint?
    private let dateLabel = UILabel()
    private let ratingLabel = UILabel()
    private var dateAndButtonStackView = UIStackView()
    private let moreActionsButton = UIButton()
    private let mapButton = UIButton()
    let usernameButton = PersonTitleView()
    private let headerStackView = UIStackView()
    
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
        setUpHeaderStackView()
        setUpUserNameButton()
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
        base.constrainSides(to: contentView, distance: baseConstraintConstant)
        base.layer.cornerRadius = 10.0
        base.clipsToBounds = true
    }
    
    private func setUpHeaderStackView() {
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        headerStackView.axis = .vertical
        headerStackView.spacing = 5.0
        headerStackView.alignment = .fill
        headerStackView.distribution = .fill
        base.addSubview(headerStackView)
        headerStackView.constrain(.leading, to: base, .leading, constant: 15.0)
        headerStackView.constrain(.trailing, to: base, .trailing, constant: 15.0)
        headerStackView.constrain(.top, to: base, .top, constant: 10.0)
    }
    
    private func setUpUserNameButton() {
        base.addSubview(usernameButton)
        headerStackView.addArrangedSubview(usernameButton)
        usernameButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(usernameSelected)))
    }
    
    private func setUpUiElementsForDateAndButtons() {
        dateAndButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        dateAndButtonStackView.axis = .horizontal
        dateAndButtonStackView.spacing = 15.0
        dateAndButtonStackView.distribution = .fill
        
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        dateAndButtonStackView.addArrangedSubview(ratingLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .mediumBold
        dateLabel.textColor = .secondaryLabel
        dateAndButtonStackView.addArrangedSubview(dateLabel)
        
        // to take up the space in the middle, as a spacer
        dateAndButtonStackView.addArrangedSubview(UIView.getSpacerView())
        
        moreActionsButton.translatesAutoresizingMaskIntoConstraints = false
        moreActionsButton.setImage(.threeDotsImage, for: .normal)
        moreActionsButton.tintColor = Colors.main
        moreActionsButton.addTarget(self, action: #selector(moreActionsSelector), for: .touchUpInside)
        dateAndButtonStackView.addArrangedSubview(moreActionsButton)
        
        mapButton.translatesAutoresizingMaskIntoConstraints = false
        mapButton.setImage(.mapImage, for: .normal)
        mapButton.tintColor = Colors.main
        mapButton.addTarget(self, action: #selector(mapAction), for: .touchUpInside)
        dateAndButtonStackView.addArrangedSubview(mapButton)

        headerStackView.addArrangedSubview(dateAndButtonStackView)
    }
    
    private func setUpScrollingStack() {
        base.addSubview(scrollingStackView)
        scrollingStackView.constrain(.top, to: headerStackView, .bottom, constant: 5.0)
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
        
        let priority = UILayoutPriority(rawValue: 999.0)
        lowerStackView.constrain(.top, to: scrollingStackView, .bottom, constant: 5.0, priority: priority)
        lowerStackView.constrain(.leading, to: base, .leading, constant: 10.0, priority: priority)
        lowerStackView.constrain(.trailing, to: base, .trailing, constant: 10.0, priority: priority)
        lowerStackView.constrain(.bottom, to: base, .bottom, constant: 5.0, priority: priority)
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
        commentLabel.numberOfLines = 4
    }
    
    @objc private func mapAction() {
        
        guard let parent = self.findViewController() else { return }
        
        if let coordinate = visit?.coordinate {
            parent.showMapDetail(locationTitle: visit?.restaurantName ?? "Location", coordinate: coordinate, address: nil)
        } else {
            parent.showMessage("No location found", on: parent)
        }
    }
    
    @objc private func moreActionsSelector() {
        
        guard let delegate = delegate, let vc = findViewController(), let visit = visit else { return }
        vc.appActionSheet(buttons: [
            AppAction(title: "Edit visit", action: nil, buttons: [
                AppAction(title: "Edit comment", action: { [weak self] in visit.changeValueProcess(presentingVC: vc, mode: .textView, enterTextViewDelegate: self) }),
                AppAction(title: "Edit rating", action: { [weak self] in visit.changeValueProcess(presentingVC: vc, mode: .rating, enterTextViewDelegate: self) }),
                AppAction(title: "Edit tags", action: { [weak self] in visit.changeTagsProcess(presentingVC: vc, visitTagsDelegate: self) })
            ]),
            AppAction(title: "Delete visit", action: { [weak self] in
                vc.appAlert(title: "Are you sure you want to delete this visit?", message: "This action cannot be undone.", buttons: [
                    ("Cancel", nil),
                    ("Delete", { [weak self] in delegate.delete(visit: self?.visit) } )
                ])
            })
        ])
    }
    
    @objc private func restaurantNameSelected() {
        if let establishment = visit?.getEstablishment() {
            delegate?.establishmentSelected(establishment: establishment)
        }
    }
    
    @objc private func usernameSelected() {
        guard let visit = visit else { return }
        delegate?.personSelected(for: visit)
    }
    
    func setUpWith(visit: Visit, selectedPhotoIndex: Int?) {
        // usernameButton in cell is set on cellForRow
        self.visit = visit
        self.requested = false
        
        allowScrollViewDelegate = false
        defer { allowScrollViewDelegate = true }
        
        imageView?.image = nil
        setUpCommentText()
        
        restaurantNameButton.setTitle(visit.restaurantName, for: .normal)
        
        dateLabel.text = visit.userDateVisited
        setUpRatingLabelText()
        
        moreActionsButton.isHidden = !visit.isCurrentUsersVisit
        
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
            let checkIdx = selectedPhotoIndex - 1
            if checkIdx >= 0 {
                let scrollingToRect = otherImageViews[selectedPhotoIndex - 1].frame
                scrollingStackView.scrollView.scrollRectToVisible(scrollingToRect, animated: false)
                scrollingStackView.resetElements(selectedIndex: selectedPhotoIndex)
            } else {
                scrollingStackView.scrollView.contentOffset = .zero
                scrollingStackView.resetElements()
            }
            
        } else {
            scrollingStackView.scrollView.contentOffset = .zero
            scrollingStackView.resetElements()
        }
        
    }
    
    func update() {
        setUpCommentText()
        setUpRatingLabelText()
    }
    
    private func setUpCommentText() {
        guard let visit = visit else { return }
        let (string, hasData) = visit.getTagAndCommentAttributedString(smallerThanNormal: false)
        
        commentLabel.attributedText = string
        
        if hasData {
            commentLabel.isHidden = false
        } else {
            commentLabel.isHidden = true
        }
        
    }
    
    private func setUpRatingLabelText() {
        if let text = visit?.ratingString {
            ratingLabel.attributedText = text
            ratingLabel.isHidden = false
        } else {
            ratingLabel.attributedText = nil
            ratingLabel.isHidden = true
        }
        
    }

}

// MARK: ScrollingStackViewDelegate
extension VisitCell: ScrollingStackViewDelegate {
    
    func newIndexSelected(idx: Int) {
        delegate?.newPhotoIndexSelected(idx: idx, for: visit)
    }
    
    func scrollViewScrolled() {
        if !requested && allowScrollViewDelegate {
            print("More image request activated from scroll")
            requested = true
            delegate?.moreImageRequest(visit: visit, cell: self)
        }
    }
}


// MARK: EnterValueViewDelegate
extension VisitCell: EnterValueViewDelegate {
    func phoneFound(string: String?) { return }
    func ratingFound(float: Float?) {
        guard let visit = visit, let rating = float else { return }
        visit.rating = Double(String(format: "%.1f", Double(rating)))
        self.findViewController()?.showMessage("Rating changed")
        delegate?.updatedVisit(visit: visit)
        Network.shared.updateVisit(visit: visit, rating: rating, newComment: nil, newTags: nil, success: { _ in return })
        NotificationCenter.default.post(name: .visitUpdated, object: nil, userInfo: ["visit": visit])
    }
    
    func textFound(string: String?) {
        guard let visit = visit else { return }
        visit.comment = string
        self.findViewController()?.showMessage("Comment changed")
        delegate?.updatedVisit(visit: visit)
        Network.shared.updateVisit(visit: visit, rating: nil, newComment: string, newTags: nil, success: { _ in return })
        NotificationCenter.default.post(name: .visitUpdated, object: nil, userInfo: ["visit": visit])
    }
}

// MARK: VisitTagsDelegate
extension VisitCell: VisitTagsDelegate {
    func tagsSelected(tags: [String]) {
        guard let visit = visit else { return }
        visit.tags = tags.map({Tag(display: $0)})
        Network.shared.updateVisit(visit: visit, rating: nil, newComment: nil, newTags: tags, success: { _ in return })
        NotificationCenter.default.post(name: .visitUpdated, object: nil, userInfo: ["visit": visit])
    }
}
