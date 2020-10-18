//
//  UserProfileVC.swift
//  restaurants
//
//  Created by Steven Dito on 10/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import MapKit



class UserProfileVC: UIViewController {
    private var person: Person?
    private var profile: Person.Profile?
    
    private let mapView = MKMapView()
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private var collectionView: UICollectionView?
    private let reuseIdentifier = "userProfileReuseIdentifier"
    private let headerIdentifier = "userProfileHeaderReuseIdentifier"
    private let padding: CGFloat = 1.5
    private let mapRatio: CGFloat = 0.35
    private var collectionViewTop: NSLayoutConstraint?
    private var mapViewHeight: CGFloat?
    private var headerButton: UIButton?
    private let imageCache = NSCache<NSString, UIImage>()
    private let refreshControl = UIRefreshControl()
    private var threeDotsBarButtonItem: UIBarButtonItem?
    private var overlayForNoEstablishments: OverlayButton? { didSet { self.overlayForNoEstablishments?.isUserInteractionEnabled = false } }
    private var initialDataReceived = false
    
    private let establishmentListButton = OverlayButton()
    private let reCenterMapButton = OverlayButton()
    private let overlayConfiguration = UIImage.SymbolConfiguration(scale: .large)
    
    private var previousScrollOffset: CGFloat = 0.0
    private var allowChanges = true
    private let mapOverlayButtonPadding: CGFloat = 5.0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUpNavigationBar()
        getPersonData()
        setUpMap()
        setUpCollectionView()
        setUpEstablishmentListButton()
        setUpReCenterButton()
    }
    
    init(person: Person) {
        super.init(nibName: nil, bundle: nil)
        self.person = person
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpNavigationBar() {
        if let username = person?.username {
            let navigationTitleView = NavigationTitleView(upperText: username, lowerText: "Profile")
            self.navigationItem.titleView = navigationTitleView
        } else {
            self.navigationItem.title = "Profile"
        }
        threeDotsBarButtonItem = UIBarButtonItem(image: .threeDotsImage, style: .plain, target: self, action: #selector(profileInfoPressed))
        self.navigationItem.rightBarButtonItem = threeDotsBarButtonItem
    }
    
    private func setUpMap() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mapView)
        mapView.constrain(.top, to: self.view, .top)
        mapView.constrain(.leading, to: self.view, .leading)
        mapView.constrain(.trailing, to: self.view, .trailing)
        mapView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.35).isActive = true
        mapView.register(RestaurantAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.delegate = self
        mapView.layoutIfNeeded()
    }
    
    private func setUpEstablishmentListButton() {
        establishmentListButton.tintColor = Colors.main
        establishmentListButton.setImage(UIImage.listImage.withConfiguration(overlayConfiguration), for: .normal)
        self.view.addSubview(establishmentListButton)
        establishmentListButton.constrain(.bottom, to: collectionView!, .top, constant: mapOverlayButtonPadding)
        establishmentListButton.constrain(.trailing, to: self.view, .trailing, constant: mapOverlayButtonPadding)
        establishmentListButton.addTarget(self, action: #selector(establishmentListAction), for: .touchUpInside)
        establishmentListButton.isHidden = true
    }
    
    private func setUpReCenterButton() {
        reCenterMapButton.tintColor = Colors.locationColor
        reCenterMapButton.setImage(UIImage.locationImage.withConfiguration(overlayConfiguration), for: .normal)
        self.view.addSubview(reCenterMapButton)
        reCenterMapButton.constrain(.bottom, to: collectionView!, .top, constant: mapOverlayButtonPadding)
        reCenterMapButton.constrain(.trailing, to: establishmentListButton, .leading, constant: mapOverlayButtonPadding)
        reCenterMapButton.addTarget(self, action: #selector(reCenterMapAction), for: .touchUpInside)
        reCenterMapButton.heightAnchor.constraint(equalTo: establishmentListButton.heightAnchor).isActive = true
        reCenterMapButton.widthAnchor.constraint(equalTo: establishmentListButton.widthAnchor).isActive = true
        reCenterMapButton.isHidden = true
    }
    
    
    
    private func setUpCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = padding
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 0.0
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 40.0)
        layout.sectionHeadersPinToVisibleBounds = true
        
        collectionView?.showsVerticalScrollIndicator = false
        collectionView!.translatesAutoresizingMaskIntoConstraints = false
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView?.backgroundColor = .systemBackground
        self.view.addSubview(collectionView!)
        collectionView!.constrain(.leading, to: self.view, .leading)
        collectionView!.constrain(.trailing, to: self.view, .trailing)
        collectionView!.constrain(.bottom, to: self.view, .bottom)
        collectionViewTop = collectionView!.constrain(.top, to: mapView, .bottom)
        collectionView!.alwaysBounceVertical = true
        collectionView!.register(ProfileCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView!.register(TitleReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        refreshControl.addTarget(self, action: #selector(refreshControlSelected), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
    }
    
    private func getPersonData() {
        Network.shared.getPersonProfile(person: person) { [weak self] (response) in
            guard let self = self else { return }
            self.initialDataReceived = true
            DispatchQueue.main.async {
                self.collectionView?.refreshControl?.endRefreshing()
            }
            switch response {
            case .success(let profile):
                self.profile = profile
                self.setUpWithProfile(profile: profile)
            case .failure(_):
                print("Failed getting profile")
            }
        }
    }
    
    private func setUpWithProfile(profile: Person.Profile) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let establishments = profile.establishments {
                for establishment in establishments {
                    let annotation = RestaurantAnnotation(establishment: establishment)
                    self.mapView.addAnnotation(annotation)
                }
                self.mapView.trueFitAllAnnotations(annotations: self.mapView.annotations, animated: false)
            }
            
            if profile.isOwnProfile {
                self.hideBarButtonItem()
            }
            
            self.collectionView?.reloadData()
            self.showOnMapIfThereAreNoEstablishments(establishments: profile.establishments)
        }
    }
    
    @objc private func headerButtonAction() {
        self.collectionView?.layoutIfNeeded()
        self.collectionViewTop?.constant = 0.0
        self.collectionView?.setNeedsLayout()
        self.allowChanges = false
        self.headerButton?.isHidden = true
        
        UIView.animate(withDuration: 0.5) {
            self.mapView.alpha = 1.0
            self.view.layoutIfNeeded()
            self.collectionView?.setContentOffset(.init(x: 0, y: 0), animated: true)
        } completion: { (done) in
            self.allowChanges = true
        }
    }
    
    @objc private func refreshControlSelected() {
        getPersonData()
    }
    
    @objc private func reCenterMapAction() {
        headerButtonAction()
        mapView.trueFitAllAnnotations(annotations: mapView.annotations, animated: true)
    }
    
    @objc private func establishmentListAction() {
        let userName = profile?.account.username ?? "User"
        guard profile != nil else {
            self.showMessage("\(userName) has no places yet")
            return
        }
        
        self.navigationController?.pushViewController(EstablishmentListVC(profile: profile), animated: true)
        
    }
    
    @objc private func profileInfoPressed() {
        guard let profile = profile, !profile.isOwnProfile else { return }
        // Completed
        if profile.areFriends {
            // Option to remove the friend
            self.appActionSheet(buttons: [
                AppAction(title: "Delete friendship", action: { [weak self] in
                    self?.appAlert(title: "Delete friendship", message: "Are you sure you want to delete this friendship?", buttons: [
                        ("Cancel", nil),
                        ("Delete", { [weak self] in
                            // Notification in deleteFriend(friend: id: complete: )
                            Network.shared.deleteFriend(friend: nil, id: profile.friendshipId, complete: { _ in return })
                            self?.hideBarButtonItem()
                            self?.showMessage("Friend removed")
                        })
                    ])
                })
            ])
        } else if profile.hasPendingReceivedRequest {
            // Option to accept the request
            guard let friendRequestId = profile.receivedRequestId else { return }
            self.appActionSheet(buttons: [
                AppAction(title: "Accept friend request", action: { [weak self] in
                    NotificationCenter.default.post(name: .friendshipRequestIdCompleted, object: nil, userInfo: ["friendRequestId": friendRequestId])
                    Network.shared.answerFriendRequest(request: nil, id: friendRequestId, accept: true, complete: { _ in return })
                    self?.showMessage("Friend request accepted")
                    self?.hideBarButtonItem()
                }),
                AppAction(title: "Reject friend request", action: { [weak self] in
                    NotificationCenter.default.post(name: .friendshipRequestIdCompleted, object: nil, userInfo: ["friendRequestId": friendRequestId])
                    Network.shared.answerFriendRequest(request: nil, id: friendRequestId, accept: false, complete: { _ in return })
                    self?.showMessage("Friend request rejected")
                    self?.hideBarButtonItem()
                })
            ])
        } else if profile.hasPendingSentRequest {
            // Option to revoke the sent request
            guard let friendRequestId = profile.sentRequestId else { return }
            self.appActionSheet(buttons: [
                AppAction(title: "Cancel friend request", action: { [weak self] in
                    NotificationCenter.default.post(name: .friendshipRequestIdCompleted, object: nil, userInfo: ["friendRequestId": friendRequestId])
                    Network.shared.rescindFriendRequest(request: nil, id: friendRequestId, complete: { _ in return })
                    self?.showMessage("Cancelled request")
                    self?.hideBarButtonItem()
                })
            ])
        } else {
            // Nothing else, so option to send the person a friend request
            self.appActionSheet(buttons: [
                AppAction(title: "Send friend request", action: { [weak self] in
                    guard let idUsed = profile.account.id else { return }
                    NotificationCenter.default.post(name: .personIdUsed, object: nil, userInfo: ["personId": idUsed])
                    Network.shared.sendFriendRequest(toPerson: nil, id: idUsed, complete: { _ in return })
                    self?.showMessage("Friend request sent")
                    self?.hideBarButtonItem()
                })
            ])
        }
    }
    
    private func hideBarButtonItem() {
        threeDotsBarButtonItem?.image = nil
    }
    
    private func showOnMapIfThereAreNoEstablishments(establishments: [Establishment]?) {
        if establishments == nil || establishments?.count == 0 {
            overlayForNoEstablishments = OverlayButton()
            mapView.addSubview(overlayForNoEstablishments!)
            overlayForNoEstablishments!.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
            overlayForNoEstablishments!.constrain(.bottom, to: mapView, .bottom, constant: 10.0)
            overlayForNoEstablishments!.setTitle("User has no places yet", for: .normal)
            overlayForNoEstablishments!.setTitleColor(.label, for: .normal)
            establishmentListButton.isHidden = true
            reCenterMapButton.isHidden = true
        } else {
            overlayForNoEstablishments?.removeFromSuperview()
            overlayForNoEstablishments = nil
            establishmentListButton.isHidden = false
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //reCenterMapButton.appIsHiddenAnimated(isHidden: true)
        
        let totalCount = mapView.annotations.count
        let visibleCount = mapView.annotations(in: mapView.visibleMapRect).count
        
        if totalCount == visibleCount {
            // make sure reCenterMapButton is hidden, if it is NOT hidden
            if !reCenterMapButton.isHidden {
                reCenterMapButton.appIsHiddenAnimated(isHidden: true)
            }
        } else {
            // make sure reCenterMapButton is visible, if it IS hidden
            if reCenterMapButton.isHidden {
                reCenterMapButton.appIsHiddenAnimated(isHidden: false)
            }
        }
        
    }
    
}

// MARK: Map view
extension UserProfileVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        let identifier = "restaurantAnnotationViewIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            mapView.deselectAnnotation(view.annotation, animated: true)
        }
        guard let restaurantView = view as? RestaurantAnnotationView, let establishment = restaurantView.establishment else { return }
        let establishmentDetail = EstablishmentDetailVC(establishment: establishment, delegate: nil, mode: .fullScreenBase)
        self.navigationController?.pushViewController(establishmentDetail, animated: true)
    }
    
}

// MARK: Collection view
extension UserProfileVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = profile?.visits?.count ?? 0
        
        if count == 0 {
            if initialDataReceived {
                collectionView.setEmptyWithAction(message: "\(person?.username ?? "This user") does not have any visits yet", buttonTitle: "")
            } else {
                collectionView.showLoadingOnCollectionView()
            }
        } else {
            collectionView.restore()
        }
        
        if count == 1 {
            // So, if only one cell is laid out then there will be only one centered column which looks weird
            // Easy way to fix the issue is to lay out another dummy cell (and hide it), so that the first and only actual cell is in the left aligned column
            // see appAtIndex calculation in cellForItem, cell blanked out with cell.setUp(with: nil, width: width)
            return 2
        } else {
            // Otherwise just layout the correct number of cells
            return count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProfileCell
        let width = (self.view.frame.width / 2) - padding/2
        guard let visit = profile?.visits?.appAtIndex(indexPath.row) else {
            // Will be called when there is only one visit, this will just blank out the cell to ensure that the columns lay out correctly, else it will lay out in the center
            // See numberOfItemsInSection for when there are two cells when technically there should be one
            print(indexPath.row)
            cell.setUp(with: nil, width: width)
            return cell
        }
        cell.setUp(with: visit, width: width)
        cell.imageView.image = nil
        
        let key = NSString(string: "\(visit.djangoOwnID)")
        
        if let image = imageCache.object(forKey: key) {
            cell.imageView.image = image
        } else {
            cell.imageView.appStartSkeleton()
            Network.shared.getImage(url: visit.mainImage) { [weak self] (imageFound) in
                cell.imageView.appEndSkeleton()
                if let image = imageFound {
                    let size = cell.imageView.frame.size
                    DispatchQueue.global(qos: .background).async {
                        let resized = image.resizeImageToSizeButKeepAspectRatio(targetSize: size)
                        DispatchQueue.main.async {
                            if cell.visit?.djangoOwnID == visit.djangoOwnID {
                                cell.imageView.image = resized
                            }
                            self?.imageCache.setObject(resized, forKey: key)
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! TitleReusableView
        header.setTitle("User's visits")
        headerButton = header.button
        headerButton!.isHidden = true
        headerButton!.addTarget(self, action: #selector(headerButtonAction), for: .touchUpInside)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let visits = profile?.visits, let visit = visits.appAtIndex(indexPath.item) {
            let profileVC = ProfileHomeVC(visits: visits, selectedVisit: visit, prevImageCache: imageCache, otherUserUsername: person?.username)
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if allowChanges {
            allowChanges = false
            
            if mapViewHeight == nil {
                let topSafeArea = establishmentListButton.bounds.height + (mapOverlayButtonPadding * 2)
                mapViewHeight = mapView.frame.height - topSafeArea
            }
            
            guard let mapViewHeight = mapViewHeight, let collectionViewTop = collectionViewTop else { return }
            if scrollView == collectionView {
                
                let offset = scrollView.contentOffset.y
                let difference = previousScrollOffset - offset
                let potentialNewTop = collectionViewTop.constant + difference
                let topRange = -mapViewHeight...0.0
                
                if topRange ~= potentialNewTop {
                    collectionViewTop.constant = potentialNewTop
                    scrollView.contentOffset.y += difference
                    previousScrollOffset = scrollView.contentOffset.y
                    let alpha = 1 - (-potentialNewTop/mapViewHeight)
                    if alpha > 0.9 {
                        headerButton?.isHidden = true
                    } else {
                        headerButton?.isHidden = false
                    }
                    mapView.alpha = alpha
                } else {
                    if potentialNewTop < -mapViewHeight {
                        headerButton?.isHidden = false
                        mapView.alpha = 0.0
                        collectionViewTop.constant = -mapViewHeight
                    } else {
                        headerButton?.isHidden = true
                        mapView.alpha = 1.0
                        collectionViewTop.constant = 0.0
                    }
                }
            }
            allowChanges = true
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.allowChanges = true
    }
    
}


