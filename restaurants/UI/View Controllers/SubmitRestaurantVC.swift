//
//  SubmitRestaurantVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/18/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import MapKit

class SubmitRestaurantVC: UIViewController {
    
    private var allowChanges = true
    private var previousScrollOffset: CGFloat = .zero
    private var containerViewHeightAnchor: NSLayoutConstraint!
    
    private var containerViewBaseHeight: CGFloat!
    private var containerViewMaxHeight: CGFloat!
    private var mapHeightInitial: CGFloat?
    private var mapHeightMinimum: CGFloat?
    
    private var selectedPhotos: [ImageSelectorVC.ImageInfo] = []
    
    private var imageSelector: ImageSelectorVC!
    private let nameLabel = UILabel()
    private let addressLabel = UILabel()
    private let containerView = UIView()
    private let headerStackView = UIStackView()
    private let showMapPopUpButton = UIButton()
    private var sliderRatingView: SliderRatingView?
    
    private let textView = PlaceholderTextView(placeholder: "Add comment. Type of meal, how the experience was, who you went with, etc. (Optional)", font: UIFont.systemFont(ofSize: UIFont.systemFontSize))
    
    private var nameRawValue: String?
    private var addressRawValue: String?
    private var coordinateRawValue: CLLocationCoordinate2D?

    
    private var establishment: Establishment?
    private var restaurant: Restaurant?
    private var mode: Mode?
    private var map: MapLocationView?
    
    
    
    init(rawValues: (name: String, address: String)?, establishment: Establishment?, restaurant: Restaurant?) {
        self.nameRawValue = rawValues?.name
        self.addressRawValue = rawValues?.address
        self.establishment = establishment
        self.restaurant = restaurant
        if rawValues != nil {
            mode = .rawValue
        } else if establishment != nil {
            mode = .establishment
        } else if restaurant != nil {
            mode = .restaurant
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    enum Mode {
        case rawValue
        case establishment
        case restaurant
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUpHeaderStackView()
        setUpLabels()
        setUpMap()
        setUpSliderView()
        setUpCommentTextView()
        setUpChildView()
        setUpImageSelector()
        findAssociatedRestaurant()
        setUpNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.setNavigationBarColor(color: Colors.navigationBarColor)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let ratio: CGFloat = 0.85
        mapHeightInitial = self.map?.bounds.height ?? 0
        mapHeightMinimum = mapHeightInitial! * (1-ratio)
        self.containerViewMaxHeight = self.containerViewBaseHeight + (mapHeightInitial! * ratio)
    }
    
    private func setUpNavigationBar() {
        let submit = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitPressed))
        navigationItem.rightBarButtonItem = submit
        navigationItem.title = "New visit"
    }
    
    private func setUpHeaderStackView() {
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        headerStackView.axis = .vertical
        headerStackView.distribution = .fill
        headerStackView.alignment = .leading
        headerStackView.spacing = 5.0
        self.view.addSubview(headerStackView)
        headerStackView.constrain(.top, to: self.view, .top)
        headerStackView.constrain(.leading, to: self.view, .leading, constant: 10.0)
        headerStackView.constrain(.trailing, to: self.view, .trailing, constant: 10.0)
    }
    
    private func setUpLabels() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.numberOfLines = 0
        headerStackView.addArrangedSubview(nameLabel)
        
        let restaurantTitle = nameRawValue ?? restaurant?.name ?? establishment?.name ?? "Restaurant name"
        let secondaryTitle = addressRawValue ?? establishment?.displayAddress ?? restaurant?.address.displayAddress?.joined(separator: ", ") ?? "No address"
        let mutableTitle = NSMutableAttributedString()
        let restaurantAttributed = NSAttributedString(string: restaurantTitle, attributes: [NSAttributedString.Key.font: UIFont.secondaryTitle, NSAttributedString.Key.foregroundColor: UIColor.label])
        let middleAttributed = NSAttributedString(string: " · ", attributes: [NSAttributedString.Key.font: UIFont.createdTitle, NSAttributedString.Key.foregroundColor: UIColor.tertiaryLabel])
        let secondaryAttributed = NSAttributedString(string: secondaryTitle, attributes: [NSAttributedString.Key.font: UIFont.mediumBold, NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
        
        mutableTitle.append(restaurantAttributed)
        mutableTitle.append(middleAttributed)
        mutableTitle.append(secondaryAttributed)
        nameLabel.attributedText = mutableTitle
    }
    
    private func setUpMap() {
        
        guard let mode = mode else { return }
        
        var name: String = "Restaurant"
        var coordinate: CLLocationCoordinate2D?
        var address: String?
        
        switch mode {
        case .rawValue:
            name = nameRawValue ?? "Restaurant"
            address = addressRawValue
        case .establishment:
            guard let establishment = establishment else { return }
            name = establishment.name
            address = establishment.displayAddress
            coordinate = establishment.coordinate
            
        case .restaurant:
            guard let restaurant = restaurant else { return }
            name = restaurant.name
            address = restaurant.address.displayAddress?.joined(separator: ", ")
            coordinate = restaurant.coordinate
        }
        
        map = MapLocationView(locationTitle: name, coordinate: coordinate, address: address)
        headerStackView.addArrangedSubview(map!)
        map?.widthAnchor.constraint(equalTo: headerStackView.widthAnchor).isActive = true
        //map!.heightAnchor.constraint(equalToConstant: 150.0).isActive = true
        map?.layer.cornerRadius = 10.0
        map?.clipsToBounds = true
        
        
        showMapPopUpButton.translatesAutoresizingMaskIntoConstraints = false
        showMapPopUpButton.setImage(.mapImage, for: .normal)
        map!.addSubview(showMapPopUpButton)
        showMapPopUpButton.centerXAnchor.constraint(equalTo: map!.centerXAnchor).isActive = true
        showMapPopUpButton.constrain(.top, to: map!, .top)
        showMapPopUpButton.tintColor = Colors.locationColor
        showMapPopUpButton.alpha = 0.0
        showMapPopUpButton.addTarget(self, action: #selector(showMapOnPopUp), for: .touchUpInside)
    }
    
    private func setUpSliderView() {
        sliderRatingView = SliderRatingView()
        headerStackView.addArrangedSubview(sliderRatingView!)
        sliderRatingView!.widthAnchor.constraint(equalTo: headerStackView.widthAnchor).isActive = true
    }
    
    
    private func setUpCommentTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        headerStackView.addArrangedSubview(textView)
        textView.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
        textView.widthAnchor.constraint(equalTo: headerStackView.widthAnchor).isActive = true
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 10.0
        textView.clipsToBounds = true
        
    }
    
    private func setUpChildView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerView)
        
        containerViewBaseHeight = self.view.bounds.height * 0.40
        
        containerViewHeightAnchor = containerView.heightAnchor.constraint(equalToConstant: containerViewBaseHeight!)
        containerViewHeightAnchor?.isActive = true
        
        containerView.constrain(.bottom, to: self.view, .bottom)
        containerView.constrain(.leading, to: self.view, .leading)
        containerView.constrain(.trailing, to: self.view, .trailing)
        containerView.constrain(.top, to: headerStackView, .bottom, constant: 5.0)
        containerView.backgroundColor = .tertiarySystemBackground
        containerViewMaxHeight = containerViewBaseHeight + 50.0
    }
    
    private func setUpImageSelector() {
        imageSelector = ImageSelectorVC()
        imageSelector.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(imageSelector)
        containerView.addSubview(imageSelector.view)
        imageSelector.view.constrainSides(to: containerView)
        imageSelector.didMove(toParent: self)
        imageSelector.delegate = self
    }
    
    @objc private func submitPressed() {
        
        guard let mode = mode else {
            fatalError()
        }
        
        if selectedPhotos.count > 0 {
            
            var selectedPhotosCopy = selectedPhotos
            let firstPhotoWhole = selectedPhotosCopy.removeFirst()
            let otherPhotos = selectedPhotosCopy.map { (imageInfo) -> UIImage in
                imageInfo.maxImage ?? imageInfo.image
            }
            
            var firstPhoto: UIImage {
                return firstPhotoWhole.maxImage ?? firstPhotoWhole.image
            }
            
            let firstPhotoDate = firstPhotoWhole.date.convertToUTC()
            
            let progressView = ProgressView(delegate: self)
            let vc = ShowViewVC(newView: progressView, fromBottom: false)
            vc.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(vc, animated: false, completion: nil)
            
            var newComment: String? {
                if textView.text == "" {
                    return nil
                } else {
                    return textView.text
                }
            }
            
            switch mode {
            case .rawValue:
                // Will only get called if no yelp restaurant is found from the parts
                let rawValueEstablishment = Establishment(name: nameRawValue!, fullAddressString: addressRawValue, coordinate: coordinateRawValue)
                executeForNonVisitedEstablishment(rawValueEstablishment, mainImage: firstPhoto, otherImages: otherPhotos, progressView: progressView, comment: newComment, firstPhotoDate: firstPhotoDate)
            case .establishment:
                if let id = establishment!.djangoID {
                    Network.shared.userPostAlreadyVisited(djangoID: id,
                                                          mainImage: firstPhoto,
                                                          mainImageDate: firstPhotoDate,
                                                          otherImages: otherPhotos,
                                                          comment: textView.text,
                                                          rating: sliderRatingView?.sliderValue,
                                                          progressView: progressView)
                    { (result) in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(_):
                                progressView.successAnimation()
                            case .failure(let error):
                                print(error)
                                progressView.failureAnimation()
                            }
                        }
                    }
                } else {
                    executeForNonVisitedEstablishment(establishment!, mainImage: firstPhoto, otherImages: otherPhotos, progressView: progressView, comment: newComment, firstPhotoDate: firstPhotoDate)
                }
                
            case .restaurant:
                // turn restaurant into establishment
                let convertedEstablishment = restaurant!.turnIntoEstablishment()
                executeForNonVisitedEstablishment(convertedEstablishment, mainImage: firstPhoto, otherImages: otherPhotos, progressView: progressView, comment: newComment, firstPhotoDate: firstPhotoDate)
            }
        } else {
            imageSelector.noPhotosSelectedAlert()
        }
    }
    
    private func executeForNonVisitedEstablishment(_ establishment: Establishment, mainImage: UIImage, otherImages: [UIImage]?, progressView: ProgressView, comment: String?, firstPhotoDate: Date) {
        Network.shared.userPostNotVisited(establishment: establishment,
                                          mainImage: mainImage,
                                          mainImageDate: firstPhotoDate,
                                          otherImages: otherImages,
                                          comment: comment,
                                          rating: sliderRatingView?.sliderValue,
                                          progressView: progressView)
        { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    progressView.successAnimation()
                case .failure(_):
                    progressView.failureAnimation()
                }
            }
        }
    }
    
    @objc private func showMapOnPopUp() {
        let mapLocationView = MapLocationView(locationTitle: nameRawValue ?? restaurant?.name ?? establishment?.name ?? "Restaurant",
                                              coordinate: restaurant?.coordinate ?? establishment?.coordinate ?? nil,
                                              address: addressRawValue ?? restaurant?.address.displayAddress?.joined(separator: ", ") ?? establishment?.displayAddress)
        mapLocationView.equalSides(size: UIScreen.main.bounds.width * 0.8)
        mapLocationView.layer.cornerRadius = 25.0
        mapLocationView.clipsToBounds = true
        
        let newVc = ShowViewVC(newView: mapLocationView, fromBottom: true)
        newVc.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(newVc, animated: false, completion: nil)
    }
    
    private func findAssociatedRestaurant() {
        
        if let mode = mode, mode == .rawValue {
            Network.shared.getRestaurantFromPartialData(name: nameRawValue!, fullAddress: addressRawValue!) { [weak self] (result) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let restaurant):
                        self.restaurant = restaurant
                        self.mode = .restaurant
                    case .failure(_):
                        self.mode = .rawValue
                        self.getCoordinate(from: self.addressRawValue!)
                    }
                }
            }
        }
    }
    
    private func getCoordinate(from address: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { [weak self] (placeMarks, error) in
            guard let self = self else { return }
            guard let firstPlaceMark = placeMarks?.first, let location = firstPlaceMark.location?.coordinate else { return }
            self.coordinateRawValue = location
        }
    }
}


// MARK: ImageSelectorDelegate
extension SubmitRestaurantVC: ImageSelectorDelegate {

    func scrollViewContentOffset(scrollView: UIScrollView) {
        if allowChanges {
            let scrollingMultiplier: CGFloat = 1.5
            let scrollDiff = (scrollView.contentOffset.y - self.previousScrollOffset) * scrollingMultiplier
            let absoluteTop: CGFloat = 0
            let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
            let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
            let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
            var newHeight = self.containerViewHeightAnchor.constant
            if isScrollingDown {
                newHeight = min(self.containerViewMaxHeight, self.containerViewHeightAnchor.constant + abs(scrollDiff))
            } else if isScrollingUp {
                newHeight = max(self.containerViewBaseHeight, self.containerViewHeightAnchor.constant - abs(scrollDiff))
            }
            if newHeight != self.containerViewHeightAnchor.constant {
                
                
                
                allowChanges = false
                #warning("this block ruins everything")
                if isScrollingDown {
                    let difference = newHeight - self.containerViewHeightAnchor.constant
                    scrollView.contentOffset.y -= difference
                    self.containerViewHeightAnchor?.constant = newHeight
                } else if isScrollingUp {
                    if scrollView.contentOffset.y < 10.0 {
                        self.containerViewHeightAnchor?.constant = newHeight
                    }
                }
                allowChanges = true
                
                
                
            }
            previousScrollOffset = scrollView.contentOffset.y
            
            if let mapHeight = map?.bounds.height, let minimum = mapHeightMinimum, let initial = mapHeightInitial {
                let percentAbove = (mapHeight - minimum) / (initial - minimum)
                if percentAbove < 0.1 {
                    map?.setAlpha(0.0)
                } else if percentAbove > 0.95 {
                    map?.setAlpha(1.0)
                } else {
                    map?.setAlpha(percentAbove)
                }
                
                let startingDistance = initial / 2.0
                let mapPercentAbove = (mapHeight - minimum) / (startingDistance - minimum)
                let mapPercentAlpha = 1 - mapPercentAbove
                
                if mapPercentAlpha < 0.05 {
                    showMapPopUpButton.alpha = 0.0
                } else if mapPercentAlpha > 0.95 {
                    showMapPopUpButton.alpha = 1.0
                } else {
                    showMapPopUpButton.alpha = mapPercentAlpha
                }
            }
        }
    }
    
    func photosUpdated(to selectedPhotos: [ImageSelectorVC.ImageInfo]) {
        self.selectedPhotos = selectedPhotos
        
    }
}


// MARK: ProgressViewDelegate
extension SubmitRestaurantVC: ProgressViewDelegate {
    func endAnimationComplete() {
        #warning("need to complete for showing from restaurant detail")
        // TODO: pretty bad temporary fix
        // Could go wrong with any additional changes
        self.view.isUserInteractionEnabled = false
        if let vc = self.presentingViewController {
            vc.dismiss(animated: true, completion: nil)
        } else {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
        
        
    }
}

