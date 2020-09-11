//
//  RestaurantDetailVC.swift
//  restaurants
//
//  Created by Steven Dito on 7/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import CoreLocation
import SafariServices

class RestaurantDetailVC: UIViewController {
    
    private var scrollView = UIScrollView()
    private var stackView = UIStackView()
    private var imageView = UIImageView()
    private var headerContainerView = UIView()
    private var headerDetailView: HeaderDetailView!
    private var viewAllPhotosButton: UIButton!
    private var titleLabel = PaddingLabel(top: 0.0, bottom: 0.0, left: 5.0, right: 5.0)
    private weak var cellOriginatedFrom: RestaurantCell?
    private var imageAlreadyFound: UIImage?
    private var headerTopConstraint: NSLayoutConstraint!
    private var headerHeightConstraint: NSLayoutConstraint!
    
    private var restaurant: Restaurant!
    private let locationManager = CLLocationManager()
    private var starRatingView: StarRatingView!
    
    // UI values
    private var navigationTitleHidden = true
    private var distanceOfImageView: CGFloat = 10000.0
    private var latestAlpha = 0.0
    private var navBarColor: UIColor?
    private let morePhotosNormalTitle = "More photos"
    private let morePhotosScrolledTitle = "Release for photos"
    private var haveMorePhotosShowOnRelease = false
    private var allowNavigationBarChange = true
    
    init(restaurant: Restaurant, fromCell: RestaurantCell? = nil, imageAlreadyFound: UIImage?) {
        self.restaurant = restaurant
        self.cellOriginatedFrom = fromCell
        self.imageAlreadyFound = imageAlreadyFound
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        edgesForExtendedLayout = [.left, .top, .right]
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        allowNavigationBarChange = false
        scrollView.contentOffset = CGPoint(x: 0, y: 0) // top image can get messed up otherwise
        allowNavigationBarChange = true
        // only when vc is being destroyed this needs to be checked
        if self.isMovingFromParent {
            if let cell = cellOriginatedFrom {
                cell.removeHeroValues()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isMovingFromParent {
            // cleans up the animation for these two views
            titleLabel.toClearBackground()
            starRatingView.toClearBackground()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
        self.setNavigationBarColor(color: Colors.navigationBarColor.withAlphaComponent(0.0))
    }

    private func setUpScrollView() {
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    private func setUpStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 3.0
    }
    
    private func setUpHeaderContainerView() {
        headerContainerView.clipsToBounds = true
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setUpImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
    private func setTitleInfo() {
        let titleStackView = UIStackView()
        titleStackView.alignment = .leading
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.axis = .vertical
        titleStackView.spacing = 3.0
        
        titleLabel.numberOfLines = 2
        titleLabel.text = restaurant.name
        titleLabel.font = .createdTitle
        titleLabel.textColor = .white
        titleLabel.fadedBackground()
        
        viewAllPhotosButton = UIButton()
        viewAllPhotosButton.titleLabel?.font = .smallBold
        viewAllPhotosButton.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 4.0, bottom: 0.0, right: 4.0)
        viewAllPhotosButton.translatesAutoresizingMaskIntoConstraints = false
        viewAllPhotosButton.fadedBackground()
        viewAllPhotosButton.setTitle(morePhotosNormalTitle, for: .normal)
        viewAllPhotosButton.addTarget(self, action: #selector(openPhotosController), for: .touchUpInside)
        
        
        starRatingView = StarRatingView(stars: restaurant.rating ?? 0.0, numReviews: restaurant.reviewCount ?? 0, forceWhite: true)
        if restaurant.rating == nil || restaurant.reviewCount == nil {
            starRatingView.alpha = 0.0
        }
        
        let starsStackView = UIStackView(arrangedSubviews: [starRatingView, UIView(), viewAllPhotosButton])
        starsStackView.alignment = .fill
        starsStackView.spacing = 15.0
        starsStackView.translatesAutoresizingMaskIntoConstraints = false
        starsStackView.axis = .horizontal
        
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(starsStackView)
        
        imageView.addSubview(titleStackView)
        
        starsStackView.widthAnchor.constraint(equalTo: titleStackView.widthAnchor).isActive = true
        
        NSLayoutConstraint.activate([
            titleStackView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 10),
            titleStackView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10),
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

    private func setUpHero() {
        titleLabel.hero.id = .restaurantHomeToDetailTitle
        imageView.hero.id = .restaurantHomeToDetailImageView
        starRatingView.hero.id = .restaurantHomeToDetailStarRatingView
    }
    
    private func setUpBackButton() {
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    private func setUp() {
        
        self.view.backgroundColor = .secondarySystemBackground
        self.navigationItem.title = ""
        
        navBarColor = Colors.navigationBarColor.withAlphaComponent(0.0)
        self.setNavigationBarColor(color: navBarColor!)
        self.navigationController?.navigationBar.tintColor = Colors.main
        
        setUpScrollView()
        setUpStackView()
        setUpImageView()
        setUpHeaderContainerView()
        
        view.addSubview(scrollView)
        headerContainerView.addSubview(imageView)
        scrollView.addSubview(headerContainerView)
        scrollView.addSubview(stackView)
        
        arrangeConstraints()
        
        setTitleInfo()
        imageView.layoutIfNeeded()
        distanceOfImageView = imageView.bounds.height - (self.navigationController?.navigationBar.bounds.height ?? 0.0)
        
        if let imageAlreadyFound = imageAlreadyFound {
            imageView.image = imageAlreadyFound
            imageView.isUserInteractionEnabled = true
        } else {
            imageView.addImageFromUrl(restaurant.imageURL)
        }
    
        headerDetailView = HeaderDetailView(restaurant: restaurant, vc: self)
        stackView.addArrangedSubview(headerDetailView)

        stackView.addArrangedSubview(RestaurantCategoriesView(restaurant: restaurant))
        
        if let userLocation = locationManager.getUserLocation() {
            stackView.addArrangedSubview(MapCutoutView(userLocation: userLocation, userDestination: restaurant.coordinate, restaurant: restaurant, vc: self))
        }
        scrollView.setCorrectContentSize()
        
        setUpHero()
        
        Network.shared.setRestaurantReviewInfo(restaurant: restaurant) { [weak self] (complete) in
            DispatchQueue.main.async {
                if complete {
                    guard let self = self else { return }
                    for review in self.restaurant.reviews {
                        let reviewView = ReviewView(review: review)
                        self.stackView.addArrangedSubview(reviewView)
                    }
                    self.scrollView.setCorrectContentSize()
                }
            }
        }
        
        Network.shared.setFullRestaurantInfo(restaurant: restaurant) { [weak self] (complete) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if complete {
                    if let newDescription = self.restaurant.openNowDescription {
                        self.headerDetailView.timeOpenLabel.attributedText = newDescription
                    }
                    if self.restaurant.imageURL == nil {
                        if let firstPhoto = self.restaurant.additionalInfo?.photos.first {
                            self.imageView.addImageFromUrl(firstPhoto)
                        }
                    }
                }
                if let dateData = self.restaurant.systemTime {
                    for day in dateData {
                        print(day)
                    }
                }
            }
        }
        
        setUpBackButton()
        
    }
}


// MARK: UIScrollViewDelegate

extension RestaurantDetailVC: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if haveMorePhotosShowOnRelease {
            openPhotosController()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        print("This is being called")
        let navHeight = (navigationController?.navigationBar.frame.height ?? 0.0)
        let offset = scrollView.contentOffset.y - navHeight
        
        if offset < 0.0 {
            // Scrolling down: Scale
            headerHeightConstraint?.constant = distanceOfImageView - offset
            
            if offset < -100.0 {
                // Check for more photos release for more button, if panned up enough and released more photos will be shown from scrollViewDidEndDragging
                haveMorePhotosShowOnRelease = true
                viewAllPhotosButton.setTitle(morePhotosScrolledTitle, for: .normal)
            } else {
                haveMorePhotosShowOnRelease = false
                viewAllPhotosButton.setTitle(morePhotosNormalTitle, for: .normal)
            }
        } else {
            // Scrolling up: Parallax
            let parallaxFactor: CGFloat = 0.25
            let offsetY = scrollView.contentOffset.y * parallaxFactor
            let minOffsetY: CGFloat = 8.0
            let availableOffset = min(offsetY, minOffsetY)
            let contentRectOffsetY = availableOffset / distanceOfImageView
            headerTopConstraint?.constant = view.frame.origin.y
            let newConstant = distanceOfImageView - offset
            if newConstant < 0.0 {
                headerHeightConstraint?.constant = 0.0
            } else {
                headerHeightConstraint?.constant = newConstant
            }
            
            imageView.layer.contentsRect = CGRect(x: 0, y: -contentRectOffsetY, width: 1, height: 1)
        }
        
        let secondOffset = scrollView.contentOffset.y
        if secondOffset > distanceOfImageView {
            
            if navigationTitleHidden {
                self.navigationItem.title = restaurant.name
                navigationTitleHidden = false
            }
            if latestAlpha != 1.0 {
                if allowNavigationBarChange {
                    navBarColor = Colors.navigationBarColor.withAlphaComponent(1.0)
                    self.setNavigationBarColor(color: navBarColor!)
                }
                
            }
        } else {
            if !navigationTitleHidden {
                self.navigationItem.title = ""
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
                
                if allowNavigationBarChange {
                    navBarColor = Colors.navigationBarColor.withAlphaComponent(CGFloat(ratio))
                    self.setNavigationBarColor(color: navBarColor!)
                }
                
                latestAlpha = ratio
            }
        }
    }
}


// MARK: MapCutoutViewDelegate

extension RestaurantDetailVC: MapCutoutViewDelegate {
    func locationPressed(name: String, destination: CLLocationCoordinate2D) {
        print("Map selected for \(name), with a location of latitude - \(destination.latitude) and longitude - \(destination.longitude)")
        //self.openMaps(coordinate: destination, name: name)
        self.actionSheet(actions: [
            ("Drive", { [weak self] in self?.openMaps(coordinate: destination, name: name, method: "driving") }),
            ("Walk", { [weak self] in self?.openMaps(coordinate: destination, name: name, method: "walk") }),
            ("Transit", { [weak self] in self?.openMaps(coordinate: destination, name: name, method: "transit") })
        ])
    }
}

// MARK: HeaderDetailViewDelegate
extension RestaurantDetailVC: HeaderDetailViewDelegate {
    
    func visitRestaurant() {
        let addVisitVC = SubmitRestaurantVC(rawValues: nil, establishment: nil, restaurant: restaurant)
        addVisitVC.edgesForExtendedLayout = .bottom
        self.navigationController?.pushViewController(addVisitVC, animated: true)
        
    }
    
    func callRestaurant() {
        guard let additionalInfo = restaurant.additionalInfo, let callUrl = URL(string: "tel://\(additionalInfo.phone)") else { return }
        UIApplication.shared.open(callUrl) // handles action sheet
    }
    
    func urlPressedToOpen() {
        if let urlString = restaurant.url, let url = URL(string: urlString) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let vc = SFSafariViewController(url: url, configuration: config)
            self.present(vc, animated: true, completion: nil)
        } else {
            self.showMessage("Unable to find URL")
        }
    }
    
    func moreInfoOnHeaderPressed() {
        self.navigationController?.pushViewController(RestaurantSpecificInfoVC(restaurant: restaurant), animated: true)
    }
}



// MARK: Selectors
extension RestaurantDetailVC {
    @objc private func openPhotosController() {
        self.navigationController?.pushViewController(PhotosVC(photos: restaurant.additionalInfo?.photos ?? []), animated: true)
    }
}
