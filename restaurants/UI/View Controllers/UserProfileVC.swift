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
    private var profile: Profile?
    private var filteredVisits: [Visit] = []
    
    private let mapView = MKMapView()
    private let dynamicHeightLayout = DynamicHeightLayout()
    private var collectionView: UICollectionView?
    private let reuseIdentifier = "userProfileReuseIdentifier"
    private let padding: CGFloat = 1.5
    private let mapRatio: CGFloat = 0.35
    private var collectionViewTop: NSLayoutConstraint?
    private var mapViewHeight: CGFloat?
    private var headerButton: UIButton?
    private var filterButton: UIButton?
    private var tagButton: UIButton?
    private let imageCache = NSCache<NSString, UIImage>()
    private let animatedRefreshControl = AnimatedRefreshControl()
    private var threeDotsBarButtonItem: UIBarButtonItem?
    private var establishmentListButton: UIBarButtonItem?
    private var overlayForNoEstablishments: OverlayButton? { didSet { self.overlayForNoEstablishments?.isUserInteractionEnabled = false } }
    private var initialDataReceived = false
    private var refreshControlSetUp = false
    private var allowNextPage = true
    private var allowChanges = true
    private var nextPageDate: String?
    
    private let reCenterMapButton = OverlayButton()
    private let overlayConfiguration = UIImage.SymbolConfiguration(scale: .large)
    
    private var previousScrollOffset: CGFloat = 0.0
    private let mapOverlayButtonPadding: CGFloat = 5.0
    private let headerHeight: CGFloat = 45.0
    
    private let headerView = UserProfileHeaderView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUpNavigationBar()
        getPersonData()
        setUpMap()
        setUpCollectionView()
        setUpHeader()
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
        var barButtonItems: [UIBarButtonItem] = []
        if let username = person?.username {
            let navigationTitleView = NavigationTitleView(upperText: username, lowerText: "Profile", profileImage: .init(url: person?.image, color: person?.color, image: nil))
            self.navigationItem.titleView = navigationTitleView
        } else {
            self.navigationItem.title = "Profile"
        }
        
        threeDotsBarButtonItem = UIBarButtonItem(image: .threeDotsImage, style: .plain, target: self, action: #selector(profileInfoPressed))
        barButtonItems.append(threeDotsBarButtonItem!)
        
        establishmentListButton = UIBarButtonItem(image: .listImage, style: .plain, target: self, action: #selector(establishmentListAction(sender:)))
        establishmentListButton!.tintColor = .clear
        barButtonItems.append(establishmentListButton!)
        
        self.navigationItem.rightBarButtonItems = barButtonItems
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
    
    private func setUpCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: dynamicHeightLayout)
        dynamicHeightLayout.delegate = self
        collectionView?.showsVerticalScrollIndicator = false
        collectionView!.translatesAutoresizingMaskIntoConstraints = false
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView?.backgroundColor = .systemBackground
        self.view.addSubview(collectionView!)
        collectionView!.constrain(.leading, to: self.view, .leading)
        collectionView!.constrain(.trailing, to: self.view, .trailing)
        collectionView!.constrain(.bottom, to: self.view, .bottom)
        collectionViewTop = collectionView!.constrain(.top, to: mapView, .bottom, constant: headerHeight)
        collectionView!.alwaysBounceVertical = true
        collectionView!.register(ProfileCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    private func setUpHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(headerView)
        headerView.constrain(.leading, to: self.view, .leading)
        headerView.constrain(.trailing, to: self.view, .trailing)
        headerView.constrain(.bottom, to: collectionView!, .top)
        headerView.heightAnchor.constraint(equalToConstant: headerHeight).isActive = true
        
        headerButton = headerView.leftButton
        headerButton!.addTarget(self, action: #selector(headerButtonAction), for: .touchUpInside)
        
        filterButton = headerView.rightButton
        filterButton!.addTarget(self, action: #selector(filterButtonPressed), for: .touchUpInside)
        
        tagButton = headerView.tagButton
        tagButton!.addTarget(self, action: #selector(clearTag), for: .touchUpInside)
    }
    
    private func updateHeader() {
        if let count = profile?.tags?.count, count > 0 {
            filterButton?.isHidden = false
        } else {
            filterButton?.isHidden = true
        }
    }
    
    private func setUpReCenterButton() {
        reCenterMapButton.tintColor = Colors.locationColor
        reCenterMapButton.setImage(UIImage.locationImage.withConfiguration(overlayConfiguration), for: .normal)
        self.view.addSubview(reCenterMapButton)
        reCenterMapButton.constrain(.bottom, to: headerView, .top, constant: mapOverlayButtonPadding)
        reCenterMapButton.constrain(.trailing, to: self.view, .trailing, constant: mapOverlayButtonPadding)
        reCenterMapButton.addTarget(self, action: #selector(reCenterMapAction), for: .touchUpInside)
        reCenterMapButton.isHidden = true
    }
    
    private func setUpRefreshControl() {
        if !refreshControlSetUp {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.refreshControlSetUp = true
                self.animatedRefreshControl.addTarget(self, action: #selector(self.refreshControlSelected), for: .valueChanged)
                self.collectionView?.refreshControl = self.animatedRefreshControl
            }
        }
    }
    
    private func getPersonData() {
        Network.shared.getPersonProfile(person: person) { [weak self] (response) in
            guard let self = self else { return }
            self.setUpRefreshControl()
            self.initialDataReceived = true
            DispatchQueue.main.async {
                self.collectionView?.refreshControl?.endRefreshing()
            }
            switch response {
            case .success(let profile):
                self.profile = profile
                self.setUpWithProfile(profile: profile)
                self.nextPageDate = profile.nextVisitPageDate
            case .failure(_):
                print("Failed getting profile")
            }
        }
    }
    
    private func getNextPage() {
        guard let nextPage = self.nextPageDate else { return }
        self.nextPageDate = nil
        Network.shared.getPersonProfile(person: person, nextVisitPageDate: nextPage) { [weak self] (response) in
            switch response {
            case .success(let profile):
                guard let self = self, let newVisits = profile.visits else { return }
                
                var indexPaths: [IndexPath] = []
                var index = self.filteredVisits.count
                for _ in 0..<newVisits.count {
                    indexPaths.append(IndexPath(item: index, section: 0))
                    index += 1
                }
                
                self.profile?.visits?.append(contentsOf: newVisits)
                self.filteredVisits.append(contentsOf: newVisits)
                self.nextPageDate = profile.nextVisitPageDate
                
                DispatchQueue.main.async {
                    self.collectionView?.insertItems(at: indexPaths)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.allowNextPage = true
                }
            case .failure(_):
                print("Failed getting next visit page for UserProfileVC")
            }
        }
    }
    
    private func setUpWithProfile(profile: Profile) {
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
            
            self.filteredVisits = profile.visits ?? []
            self.collectionView?.reloadData()
            self.showOnMapIfThereAreNoEstablishments(establishments: profile.establishments)
            self.updateHeader()
        }
    }
    
    @objc private func headerButtonAction() {
        self.collectionView?.layoutIfNeeded()
        self.collectionViewTop?.constant = headerHeight
        self.collectionView?.setNeedsLayout()
        self.allowChanges = false
        self.headerButton?.hideWithAlphaAnimated()
        
        UIView.animate(withDuration: 0.5) {
            self.mapView.alpha = 1.0
            self.view.layoutIfNeeded()
            self.collectionView?.setContentOffset(.init(x: 0, y: 0), animated: true)
        } completion: { (done) in
            self.allowChanges = true
        }
    }
    
    @objc private func refreshControlSelected() {
        clearTag()
        getPersonData()
    }
    
    @objc private func reCenterMapAction() {
        headerButtonAction()
        mapView.trueFitAllAnnotations(annotations: mapView.annotations, animated: true)
    }
    
    @objc private func establishmentListAction(sender: UIBarButtonItem) {
        // when button is disabled it is clear, since barButtonItems cant be disabled so a button press could still go through
        guard sender.tintColor != .clear else { return}
        
        let userName = profile?.account.username ?? "User"
        guard let profile = profile else {
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
            establishmentListButton?.tintColor = .clear
            
            reCenterMapButton.isHidden = true
        } else {
            overlayForNoEstablishments?.removeFromSuperview()
            overlayForNoEstablishments = nil
            establishmentListButton?.tintColor = Colors.main
        }
    }
    
    @objc private func filterButtonPressed() {
        self.showTagSelectorView(tags: profile?.tags, selectedTags: nil, tagSelectorViewDelegate: self)
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

// MARK: Collection view
extension UserProfileVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = filteredVisits.count
        
        if count == 0 {
            if initialDataReceived {
                if let totalCount = profile?.visits?.count, totalCount == 0 {
                    collectionView.setEmptyWithAction(message: "\(person?.username ?? "This user") does not have any visits yet", buttonTitle: "")
                } else {
                    collectionView.setEmptyWithAction(message: "\(person?.username ?? "This user") does not have any visits with that tag yet", buttonTitle: "")
                }
                
            } else {
                collectionView.showLoadingOnCollectionView()
            }
        } else {
            collectionView.restore()
        }
        
        return count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProfileCell
        let width = (self.view.frame.width / 2) - padding/2
        guard let visit = filteredVisits.appAtIndex(indexPath.row) else {
            // Will be called when there is only one visit, this will just blank out the cell to ensure that the columns lay out correctly, else it will lay out in the center
            // See numberOfItemsInSection for when there are two cells when technically there should be one
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let visit = filteredVisits.appAtIndex(indexPath.item) {
            let profileVC = ProfileHomeVC(isOwnUsersProfile: false,
                                          visits: filteredVisits,
                                          selectedVisit: visit,
                                          prevImageCache: imageCache,
                                          otherPerson: person)
            
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    func reloadCollectionView(tag: Tag?) {
        let prevAlpha = headerButton?.alpha ?? 0.0
        collectionView?.reloadData()
        headerButton?.alpha = prevAlpha
        
        if let tag = tag {
            tagButton?.setTitle(tag.display, for: .normal)
            tagButton?.showWithAlphaAnimated()
            filterButton?.showNotificationStyleText(str: "1")
        } else {
            tagButton?.hideWithAlphaAnimated()
            filterButton?.removeNotificationStyleText()
        }
    }
}

// MARK: Scroll view
extension UserProfileVC {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        animatedRefreshControl.updateProgress(with: scrollView.contentOffset.y)
        if allowChanges {
            allowChanges = false
            
            if mapViewHeight == nil {
                let topSafeArea = reCenterMapButton.bounds.height + (mapOverlayButtonPadding * 2)
                mapViewHeight = mapView.frame.height - topSafeArea
            }
            
            guard let mapViewHeight = mapViewHeight, let collectionViewTop = collectionViewTop else { return }
            if scrollView == collectionView {
                
                let offset = scrollView.contentOffset.y
                let difference = previousScrollOffset - offset
                let potentialNewTop = collectionViewTop.constant + difference
                let topRange = -mapViewHeight...headerHeight
                
                if topRange ~= potentialNewTop {
                    collectionViewTop.constant = potentialNewTop
                    scrollView.contentOffset.y += difference
                    previousScrollOffset = scrollView.contentOffset.y
                    let alpha = 1 - (-potentialNewTop/mapViewHeight)
                    if alpha > 0.9 {
                        headerButton?.hideWithAlphaAnimated()
                    } else {
                        headerButton?.showWithAlphaAnimated()
                    }
                    mapView.alpha = alpha
                } else {
                    if potentialNewTop < -mapViewHeight {
                        headerButton?.showWithAlphaAnimated()
                        mapView.alpha = 0.0
                        collectionViewTop.constant = -mapViewHeight
                    } else {
                        headerButton?.hideWithAlphaAnimated()
                        mapView.alpha = 1.0
                        collectionViewTop.constant = headerHeight
                    }
                }
            }
            allowChanges = true
        }
        guard let cv = collectionView else { return }
        let lastContentOffset = scrollView.contentOffset.y + cv.bounds.height
        let collectionViewHeight = scrollView.contentSize.height - (cv.bounds.height / 2.0)
        if allowNextPage && lastContentOffset > collectionViewHeight {
            getNextPage()
            allowNextPage = false
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.allowChanges = true
    }
}

// MARK: TagSelectorViewDelegate
extension UserProfileVC: TagSelectorViewDelegate {
    @objc func clearTag() {
        guard let allVisits = profile?.visits else { return }
        filteredVisits = allVisits
        reloadCollectionView(tag: nil)
    }
    
    func tagSelected(tag: Tag) {
        guard let selectedAlias = tag.alias else { return }
        guard let allVisits = profile?.visits else { return }
        // *** use alias to filter
        let potentialVisits = allVisits.filter({ (visit) -> Bool in
            visit.tags.contains { (tag) -> Bool in
                tag.alias == selectedAlias
            }
        })
        filteredVisits = potentialVisits
        reloadCollectionView(tag: tag)

    }
    func multipleChange(newAdditions: [Tag], newSubtractions: [Tag]) { return }
}


// MARK: DynamicHeightLayout
extension UserProfileVC: DynamicHeightLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, hasSquareImageAt indexPath: IndexPath) -> Bool {
        let index = indexPath.item
        guard let visit = filteredVisits.appAtIndex(index) else { return false } // watch out for the dummy cell situation
        return visit.mainImage != nil
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForCell indexPath: IndexPath, width: CGFloat) -> CGFloat {
        guard let visit = filteredVisits.appAtIndex(indexPath.item) else { return 0.0 } // watch out for the dummy cell situation
        let height = ProfileCell.calculateHeight(with: visit, width: width)
        return height
    }
}
