//
//  RestaurantDetailVC.swift
//  restaurants
//
//  Created by Steven Dito on 7/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import CoreLocation

class RestaurantDetailVC: UIViewController {
    
    private var scrollView: UIScrollView!
    private var stackView: UIStackView!
    private var imageView: UIImageView!
    private var headerContainerView: UIView!
    private var headerDetailView: HeaderDetailView!
    
    private var headerTopConstraint: NSLayoutConstraint!
    private var headerHeightConstraint: NSLayoutConstraint!
    

    private var restaurant: Restaurant!
    private let locationManager = CLLocationManager()
    
    // UI values
    private var navigationTitleHidden = true
    private var distanceOfImageView: CGFloat = 10000.0
    private var latestAlpha = 0.0
    private var navBarColor: UIColor?
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navBarColor != nil {
            self.setNavigationBarColor(color: navBarColor!)
        }
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

    
    
    private func setUp() {
        self.view.backgroundColor = .secondarySystemBackground
        self.title = ""
        print(restaurant.transactions)
        navBarColor = Colors.navigationBarColor.withAlphaComponent(0.0)
        self.setNavigationBarColor(color: navBarColor!)
        self.navigationController?.navigationBar.tintColor = Colors.main
        
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
        
        imageView.addImageFromUrl(restaurant.imageURL)
        headerDetailView = HeaderDetailView(restaurant: restaurant, vc: self)
        stackView.addArrangedSubview(headerDetailView)
        
        #warning("test remove later")
        let button = UIButton()
        button.setTitle("Go look at more photos", for: .normal)
        stackView.addArrangedSubview(button)
        button.addTarget(self, action: #selector(openPhotosController), for: .touchUpInside)
        #warning("end test")
        
        stackView.addArrangedSubview(RestaurantCategoriesView(restaurant: restaurant))
        
        if let userLocation = locationManager.getUserLocation() {
            stackView.addArrangedSubview(MapCutoutView(userLocation: userLocation, userDestination: restaurant.coordinate, restaurant: restaurant, vc: self))
        }
        scrollView.setCorrectContentSize()
        
        
        
        Network.shared.setRestaurantReviewInfo(restaurant: restaurant) { (complete) in
            if complete {
                for review in self.restaurant.reviews {
                    let reviewView = ReviewView(review: review)
                    self.stackView.addArrangedSubview(reviewView)
                }
                self.scrollView.setCorrectContentSize()
            }
        }
        
        Network.shared.setFullRestaurantInfo(restaurant: restaurant) { (complete) in
            #warning("need to complete")
            if complete {
                let newDescription = self.restaurant.openNowDescription
                self.headerDetailView.timeOpenLabel.attributedText = newDescription
                
            }
        }
        
    }
}


// MARK: UIScrollViewDelegate

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
                self.title = restaurant.name
                navigationTitleHidden = false
            }
            if latestAlpha != 1.0 {
                navBarColor = Colors.navigationBarColor.withAlphaComponent(1.0)
                self.setNavigationBarColor(color: navBarColor!)
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
                navBarColor = Colors.navigationBarColor.withAlphaComponent(CGFloat(ratio))
                self.setNavigationBarColor(color: navBarColor!)
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
    func urlPressedToOpen() {
        self.navigationController?.pushViewController(WebVC(url: restaurant.url), animated: true)
    }
}



// MARK: Selectors
extension RestaurantDetailVC {
    #warning("test")
    @objc private func openPhotosController() {
        self.navigationController?.pushViewController(PhotosVC(photos: restaurant.additionalInfo?.photos ?? []), animated: true)
    }
    #warning("end test")
}