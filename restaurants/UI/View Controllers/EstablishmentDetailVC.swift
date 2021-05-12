//
//  EstablishmentDetailVC.swift
//  restaurants
//
//  Created by Steven Dito on 9/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import CoreLocation

protocol EstablishmentDetailDelegate: AnyObject {
    func detailDismissed() -> Void
    
}

class EstablishmentDetailVC: UIViewController {
    
    private weak var delegate: EstablishmentDetailDelegate?
    private let titleLabel = UILabel()
    private var establishment: Establishment?
    private var initialTouchPoint: CGPoint?
    private var initialFrame: CGRect?
    private var headerView: HeaderView?
    private var visits: [Visit] = []
    private var collectionView: UICollectionView!
    private let layout = UICollectionViewFlowLayout.init()
    private var spacer: SpacerView?
    private let cellIdentifier = "cellIdentifierEstablishmentDetail"
    private let headerIdentifier = "headerIdentifierEstablishmentDetail"
    private let padding: CGFloat = 2.0
    private var initialDataFound = false
    private var scrollingStack: ScrollingStackView!
    private let imageCache = NSCache<NSString, UIImage>()
    private var mode: Mode = .halfScreenBase
    private var mapLocationView: MapLocationView?
    private var selectedButtonIndex = 0
    private var allowButtonsToChangeSelected = true
    private let visitsLabel = UILabel()
    private let collectionSpacer = SpacerView(size: 2.0, orientation: .vertical)
    
    enum Mode {
        case fullScreenBase
        case fullScreenHeaderAndMap
        case halfScreenBase
    }
    
    init(establishment: Establishment, delegate: EstablishmentDetailDelegate?, mode: Mode) {
        super.init(nibName: nil, bundle: nil)
        self.establishment = establishment
        self.delegate = delegate
        self.mode = mode
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        guard let establishment = establishment else { return }
        getRestaurantInfo(establishment: establishment)
        setUpView(establishment: establishment)
        setUpHeader(establishment: establishment)
        setUpScrollingSelectDateView()
        setUpSpacer()
        setUpCollectionView()
        
        edgesForExtendedLayout = []
        
        NotificationCenter.default.addObserver(self, selector: #selector(visitChanged(notification:)), name: .visitUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(visitDeleted(notification:)), name: .visitDeleted, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.setNavigationBarColor()
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.layoutIfNeeded()
        collectionView.backgroundColor = .systemBackground
        layout.scrollDirection = .horizontal
        
        var cellSizeSize: CGFloat {
            if mode == .fullScreenBase || mode == .fullScreenHeaderAndMap {
                return self.collectionView.bounds.height / 3.0
            } else {
                return self.collectionView.bounds.height / 2.0
            }
        }
        
        layout.itemSize = CGSize(width: cellSizeSize - padding, height: cellSizeSize - padding)
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = padding
        
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width / 2.5, height: collectionView.bounds.height)
    }
    
    private func getRestaurantInfo(establishment: Establishment) {
        Network.shared.getEstablishmentDetail(from: establishment) { [weak self] (result) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.initialDataFound = true
                switch result {
                case .success(let establishment):
                    self.establishment?.updateSelfForValuesThatAreNil(newEstablishment: establishment)
                    self.visits = establishment.visits ?? []
                    self.addViewsToScrollingStack()
                    self.collectionView.reloadData()
                case .failure(let error):
                    print(error)
                    self.visits = []
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func setUpView(establishment: Establishment) {

        if mode == .halfScreenBase {
            self.view.clipsToBounds = true
            self.view.layer.cornerRadius = 12.5
            self.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureSelector(recognizer:)))
            self.view.addGestureRecognizer(panGestureRecognizer)
        }
        
        if mode == .fullScreenBase {
            self.navigationItem.title = establishment.name
            
            var barButtonItems: [UIBarButtonItem] = []
            
            // Show on yelp always
            if establishment.yelpID != nil {
                self.navigationController?.navigationBar.tintColor = Colors.main
                let yelpBarButtonItem = UIBarButtonItem(image: .detailImage, style: .plain, target: self, action: #selector(yelpButtonPressed))
                yelpBarButtonItem.imageInsets = UIEdgeInsets(top: 0, left: 20.0, bottom: 0, right: 0)
                barButtonItems.append(yelpBarButtonItem)
            }
            
            // Only show these for own users data
            if establishment.isCurrentUsersEstablishment {
                
                // and ability to add visit
                let addVisitBarButtonItem = UIBarButtonItem(image: .plusImage, style: .plain, target: self, action: #selector(addVisitPressed))
                barButtonItems.append(addVisitBarButtonItem)
                
                // edit visit
                let editEstablishmentBarButtonItem = UIBarButtonItem(image: .threeDotsImage, style: .plain, target: self, action: #selector(editEstablishmentPressed))
                barButtonItems.append(editEstablishmentBarButtonItem)
            }
            navigationItem.rightBarButtonItems = barButtonItems
        }
    }
    
    private func setUpHeader(establishment: Establishment) {
        if mode == .halfScreenBase || mode == .fullScreenHeaderAndMap {
            headerView = HeaderView(leftButtonTitle: "Done", rightButtonTitle: "", title: establishment.name)
            headerView!.headerLabel.font = .secondaryTitle
            
            // Only show these for own users data
            if establishment.isCurrentUsersEstablishment {
                if mode != .fullScreenHeaderAndMap {
                    headerView!.rightButton.setImage(.threeDotsImage, for: .normal)
                    headerView!.rightButton.addTarget(self, action: #selector(editEstablishmentPressed), for: .touchUpInside)
                    headerView!.rightButton.tintColor = Colors.main
                    headerView!.rightButton.setContentCompressionResistancePriority(.required, for: .horizontal)
                }
                
                if mode == .halfScreenBase {
                    let addVisit = headerView?.insertButtonAtEnd(with: .plusImage)
                    addVisit?.setContentCompressionResistancePriority(.required, for: .horizontal)
                    addVisit?.addTarget(self, action: #selector(addVisitPressed), for: .touchUpInside)
                }
            }
            
            // Always have the yelp button available
            if establishment.yelpID != nil && mode != .fullScreenHeaderAndMap {
                let detailPressed = headerView?.insertButtonAtEnd(with: .detailImage)
                detailPressed?.setContentCompressionResistancePriority(.required, for: .horizontal)
                detailPressed?.addTarget(self, action: #selector(yelpButtonPressed), for: .touchUpInside)
            }
            
            self.view.addSubview(headerView!)
            headerView!.constrain(.leading, to: self.view, .leading, constant: 5.0)
            headerView!.constrain(.top, to: self.view, .top, constant: 10.0)
            headerView!.constrain(.trailing, to: self.view, .trailing, constant: 5.0)
            headerView!.leftButton.addTarget(self, action: #selector(dismissChild), for: .touchUpInside)
            spacer = SpacerView(size: 2.0, orientation: .vertical)
            self.view.addSubview(spacer!)
            spacer!.constrain(.leading, to: self.view, .leading)
            spacer!.constrain(.trailing, to: self.view, .trailing)
            spacer!.constrain(.top, to: headerView!, .bottom, constant: 5.0)
        }
        
        // Set up the Map
        if mode == .fullScreenBase || mode == .fullScreenHeaderAndMap {
            if let coordinate = establishment.coordinate {
                
                let mapLocationHeight = UIScreen.main.bounds.height * 0.2
            
                mapLocationView = MapLocationView(estimatedSize: CGSize(width: self.view.bounds.width, height: mapLocationHeight), locationTitle: establishment.name, coordinate: coordinate, address: establishment.displayAddress)
                self.view.addSubview(mapLocationView!)
                mapLocationView?.heightAnchor.constraint(equalToConstant: mapLocationHeight).isActive = true
                mapLocationView!.constrain(.leading, to: self.view, .leading)
                
                if let header = headerView {
                    mapLocationView!.constrain(.top, to: header, .bottom, constant: 10.0)
                } else {
                    mapLocationView!.constrain(.top, to: self.view, .top, constant: 10.0)
                }
                
                mapLocationView!.constrain(.trailing, to: self.view, .trailing)
            }
        }
    }
    
    private func setUpScrollingSelectDateView() {
        visitsLabel.translatesAutoresizingMaskIntoConstraints = false
        visitsLabel.font = .smallBold
        visitsLabel.text = "Visits"
        visitsLabel.clipsToBounds = true
        
        scrollingStack = ScrollingStackView(subViews: [])

        self.view.addSubview(scrollingStack)
        self.view.addSubview(visitsLabel)
        
        if mode == .fullScreenBase || mode == .fullScreenHeaderAndMap {
            if mapLocationView != nil {
                visitsLabel.constrain(.top, to: mapLocationView!, .bottom, constant: 5.0)
                scrollingStack.constrain(.top, to: mapLocationView!, .bottom, constant: 5.0)
            } else {
                visitsLabel.constrain(.top, to: self.view, .top, constant: 5.0)
                scrollingStack.constrain(.top, to: self.view, .top, constant: 5.0)
            }
        } else {
            visitsLabel.constrain(.top, to: spacer!, .bottom, constant: 5.0)
            scrollingStack.constrain(.top, to: spacer!, .bottom, constant: 5.0)
        }
        
        visitsLabel.constrain(.leading, to: self.view, .leading, constant: 10.0)
        visitsLabel.heightAnchor.constraint(equalTo: scrollingStack.heightAnchor).isActive = true
        
        scrollingStack.constrain(.leading, to: visitsLabel, .trailing, constant: 5.0)
        scrollingStack.constrain(.trailing, to: self.view, .trailing, constant: 5.0)
        scrollingStack.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        
    }
    
    private func setUpSpacer() {
        self.view.addSubview(collectionSpacer)
        collectionSpacer.constrain(.leading, to: self.view, .leading)
        collectionSpacer.constrain(.trailing, to: self.view, .trailing)
        collectionSpacer.constrain(.top, to: scrollingStack, .bottom, constant: 5.0)
        
    }
    
    private func setUpCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        
        self.view.addSubview(collectionView)
        
        collectionView.constrain(.top, to: collectionSpacer, .bottom, constant: 5.0)
        collectionView.constrain(.leading, to: self.view, .leading, constant: padding)
        collectionView.constrain(.trailing, to: self.view, .trailing, constant: padding)
        collectionView.constrain(.bottom, to: self.view, .bottom, constant: padding)
        
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(HeaderEstablishmentReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }
    
    private func addViewsToScrollingStack() {
        for (i, visit) in visits.enumerated() {
            let button = SizeChangeButton.genericScrollingButton()
            button.setTitle(visit.shortUserDateVisited, for: .normal)
            button.tag = i
            button.addTarget(self, action: #selector(dateButtonAction(sender:)), for: .touchUpInside)
            scrollingStack.stackView.addArrangedSubview(button)
            if i == 0 {
                button.isSelected = true
            }
        }
    }
    
    private func selectNewLocation() {
        let locationController = SelectLocationVC(owner: self, askPermissionBeforeSending: true)
        self.present(locationController, animated: true, completion: nil)
    }
    
    private func changeTextForEstablishment() {
        let editTextView = EnterValueView(text: "Rename \(establishment?.name ?? "your place")", placeholder: "Enter new name", controller: nil, delegate: self, mode: .textField)
        let vc = ShowViewVC(newView: editTextView, mode: .middle)
        editTextView.controller = vc
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    @objc private func panGestureSelector(recognizer: UIPanGestureRecognizer) {
        let newTouchPoint = recognizer.translation(in: self.view)
        switch recognizer.state {
        case .began:
            initialTouchPoint = newTouchPoint
            self.initialFrame = self.view.frame
        case .changed:
            let newPotentialY = initialTouchPoint!.y + newTouchPoint.y + (initialFrame?.origin.y ?? 0.0)
            self.view.frame.origin.y = max(newPotentialY, initialFrame?.origin.y ?? 0.0)
        case .ended:
            let velocity = recognizer.velocity(in: self.view).y
            
            let totalAmountMoved = self.view.frame.origin.y - (initialFrame?.origin.y ?? 0.0)
            if (totalAmountMoved > self.view.frame.height * 0.2) || velocity > 100 {
                dismissChild()
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.frame = self.initialFrame!
                }
            }
        default:
            break
        }
    }
    
    @objc private func dismissChild() {
        switch mode {
        case .fullScreenBase:
            self.navigationController?.popViewController(animated: true)
        case .fullScreenHeaderAndMap:
            self.dismiss(animated: true, completion: nil)
        case .halfScreenBase:
            self.parent?.removeChildViewControllersFromBottomOf(typeToRemove: EstablishmentDetailVC.self, onCompletion: { [weak self] (done) in
                guard let self = self else { return }
                self.delegate?.detailDismissed()
            })
        }
    }
    
    @objc private func yelpButtonPressed() {
        guard let yelpId = establishment?.yelpID, let longitude = establishment?.longitude, let latitude = establishment?.latitude else { return }
        guard let establishment = establishment else { return }
        let restaurant = Restaurant(establishment: establishment, yelpID: yelpId, latitude: latitude, longitude: longitude)
        let restaurantDetail = RestaurantDetailVC(restaurant: restaurant, imageAlreadyFound: nil, allowVisit: false)
        self.navigationController?.pushViewController(restaurantDetail, animated: true)
    }
    
    @objc private func addVisitPressed() {
        // needs to be able to handle the cases for the half screen and the full screen, both should be with a navigation controller similar to how it is shown from RestaurantDetailVC
        guard let establishment = establishment else { return }
        if Network.shared.loggedIn {
            let addVisitVC = SubmitRestaurantVC(rawValues: nil, establishment: establishment, restaurant: nil)
            addVisitVC.edgesForExtendedLayout = .bottom
            self.navigationController?.pushViewController(addVisitVC, animated: true)
        } else {
            self.userNotLoggedInAlert(tabVC: nil)
        }
        
    }
    
    @objc private func editEstablishmentPressed() {
        guard let establishment = establishment else { return }
        let establishmentName = establishment.isRestaurant ? "Restaurant" : "Place"
        
        self.appActionSheet(buttons: [
            AppAction(title: "Edit \(establishmentName)", action: nil, buttons: [
                AppAction(title: "Edit name", action: { [weak self] in self?.changeTextForEstablishment()} ),
                AppAction(title: "Edit location", action: { [weak self] in self?.selectNewLocation()} )
            ]),
            AppAction(title: "Delete \(establishmentName)", action: {
                self.appAlert(title: "Are you sure you want to delete this \(establishmentName)", message: "This will also delete all of your visits to this \(establishmentName). This action cannot be undone.", buttons: [
                    ("Cancel", nil),
                    ("Delete", { [weak self] in
                        Network.shared.deleteEstablishment(establishment: establishment) { _ in return }
                        self?.dismissChild()
                        NotificationCenter.default.post(name: .establishmentDeleted, object: nil, userInfo: ["establishment": establishment])
                    })
                ])
            })
        ])
        
        
    }
    
    @objc private func visitChanged(notification: Notification) {
        if let dict = notification.userInfo as? [String:Any] {
            if let visit = dict["visit"] as? Visit, let index = visits.firstIndex(where: {$0.djangoOwnID == visit.djangoOwnID}) {
                visits[index].comment = visit.comment
                visits[index].rating = visit.rating
                visits[index].tags = visit.tags
                let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: index)) as? HeaderEstablishmentReusableView
                header?.update(visit: visits[index])
            }
        }
    }
    
    @objc private func visitDeleted(notification: Notification) {
        if let dict = notification.userInfo as? [String:Any] {
            if let visit = dict["visit"] as? Visit, let index = visits.firstIndex(where: {$0.djangoOwnID == visit.djangoOwnID}) {
                visits.remove(at: index)
                collectionView.deleteSections(IndexSet([index]))
                // TODO: Remove stuff from image cache
                // need to update the top buttons
                collectionView.contentOffset = .zero
                scrollingStack.stackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
                addViewsToScrollingStack()
            }
        }
    }
    
    @objc private func dateButtonAction(sender: UIButton) {
        if !sender.isSelected {
            UIDevice.vibrateSelectionChanged()
            let selectedVisitSectionIndex = sender.tag
            sender.isSelected = true
            scrollingStack.stackView.arrangedSubviews.forEach { (view) in
                if let button = view as? SizeChangeButton {
                    button.isSelected = false
                }
            }
            sender.isSelected = true
            
            // Scroll to the header here
            if let attributes = collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: selectedVisitSectionIndex)) {
                let frame = attributes.frame
                allowButtonsToChangeSelected = false
                UIView.animate(withDuration: 0.3, animations: {
                    self.collectionView.contentOffset.x = frame.origin.x
                }) { (complete) in
                    if complete {
                        self.allowButtonsToChangeSelected = true
                    }
                }
            }
        }
    }
}


// MARK: Collection view
extension EstablishmentDetailVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! HeaderEstablishmentReusableView
        header.setUp(visit: visits[indexPath.section], allowPressing: (mode == .halfScreenBase || mode == .fullScreenBase))
        header.tag = indexPath.section
        return header
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = visits.count
        if count == 0 {
            visitsLabel.isHidden = true
            collectionSpacer.isHidden = true
            if initialDataFound {
                let button = collectionView.setEmptyWithAction(message: "No visits at this location yet", buttonTitle: "")
                button.isHidden = true
            } else {
                collectionView.showLoadingOnCollectionView()
            }
            return 0
        } else {
            visitsLabel.isHidden = false
            collectionSpacer.isHidden = false
            collectionView.restore()
            return visits.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let visit = visits[section]
        return visit.listPhotos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotoCell
        let visit = visits[indexPath.section]
        let listPhotos = visit.listPhotos
        let url = listPhotos?[indexPath.row] ?? ""
        let key = NSString(string: url)
        
        if let image = imageCache.object(forKey: key) {
            cell.url = url
            cell.imageView.image = image
        } else {
            cell.imageView.appStartSkeleton()
            Network.shared.getImage(url: url) { [weak self] (image) in
                cell.imageView.appEndSkeleton()
                let bounds = cell.bounds.size
                DispatchQueue.global(qos: .background).async {
                    let resized = image?.resizeImageToSizeButKeepAspectRatio(targetSize: bounds)
                    DispatchQueue.main.async {
                        cell.url = url
                        cell.imageView.image = resized
                        if let resized = resized {
                            self?.imageCache.setObject(resized, forKey: key)
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if mode != .fullScreenHeaderAndMap {
            let cellSelected = collectionView.cellForItem(at: indexPath) as! PhotoCell
            cellSelected.imageView.hero.id = .photosToSinglePhotoID
            let imageFromCell = cellSelected.imageView.image
            if let image = imageFromCell {
                let newVC = SinglePhotoVC(image: image, imageURL: cellSelected.url, cell: cellSelected, asset: nil)
                self.navigationController?.present(newVC, animated: true, completion: nil)
            }
        }
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            guard allowButtonsToChangeSelected else { return }
            let currentlyViewedHeader = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).last
            if let header = currentlyViewedHeader as? HeaderEstablishmentReusableView {
                var newSelectedSection = header.tag
                
                // If the collection view is close to the beginning, then automatically should be the first section
                if collectionView.contentOffset.x < 30.0 {
                    newSelectedSection = 0
                }
                
                if newSelectedSection != selectedButtonIndex {
                    selectedButtonIndex = newSelectedSection
                    for (i, anyView) in scrollingStack.stackView.arrangedSubviews.enumerated() {
                        if let button = anyView as? SizeChangeButton {
                            if i == newSelectedSection {
                                button.isSelected = true
                                scrollingStack.scrollView.scrollRectToVisible(button.frame, animated: true)
                            } else {
                                button.isSelected = false
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: SearchLocationDelegate
extension EstablishmentDetailVC: SelectLocationDelegate {
    func locationSelected(coordinate: CLLocationCoordinate2D, fullAddress: String) {
        guard let establishment = establishment else { return }
        establishment.updatePropertiesWithFullAddress(address: fullAddress, coordinate: coordinate)
        
        Network.shared.updateEstablishment(establishment: establishment, success: { _ in return })
        if let mapLocationView = mapLocationView {
            mapLocationView.updateLocation(coordinate: coordinate)
        }
    }
}

// MARK: EnterValueViewDelegate
extension EstablishmentDetailVC: EnterValueViewDelegate {
    func ratingFound(float: Float?) { return }
    func phoneFound(string: String?) { return }
    
    func textFound(string: String?) {
        guard let string = string, let establishment = establishment else { return }
        self.showMessage("Updated name")
        establishment.name = string
        Network.shared.updateEstablishment(establishment: establishment, success: { _ in return })
        if let header = headerView {
            header.headerLabel.text = string
        } else {
            navigationItem.title = string
        }
    }
}

