//
//  EstablishmentDetailVC.swift
//  restaurants
//
//  Created by Steven Dito on 9/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

protocol EstablishmentDetailDelegate: class {
    func detailDismissed() -> Void
}

class EstablishmentDetailVC: UIViewController {
    
    private weak var delegate: EstablishmentDetailDelegate?
    private let titleLabel = UILabel()
    private var establishment: Establishment?
    private var initialTouchPoint: CGPoint?
    private var initialFrame: CGRect?
    private var headerView: HeaderView!
    private var visits: [Visit] = []
    private var collectionView: UICollectionView!
    private let layout = UICollectionViewFlowLayout.init()
    private let spacer = SpacerView(size: 3.0, orientation: .vertical)
    private let cellIdentifier = "cellIdentifierEstablishmentDetail"
    private let headerIdentifier = "headerIdentifierEstablishmentDetail"
    private let padding: CGFloat = 2.0
    private var initialDataFound = false
    private var scrollingStack: ScrollingStackView!
    private let imageCache = NSCache<NSString, UIImage>()
    private var mode: Mode = .halfScreen
    private var mapLocationView: MapLocationView?
    private var selectedButtonIndex = 0
    private var allowButtonsToChangeSelected = true
    
    enum Mode {
        case fullScreen
        case halfScreen
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
        setUpView()
        setUpHeader(establishment: establishment)
        setUpScrollingSelectDateView()
        setUpCollectionView()
        edgesForExtendedLayout = [.left, .top, .right]
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.layoutIfNeeded()
        
        layout.scrollDirection = .horizontal
        
        var cellSizeSize: CGFloat {
            if mode == .fullScreen {
                return self.collectionView.bounds.height / 3.0
            } else {
                return self.collectionView.bounds.height / 2.0
            }
        }
        
        layout.itemSize = CGSize(width: cellSizeSize - padding, height: cellSizeSize - padding)
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = padding
        
    }
    
    private func getRestaurantInfo(establishment: Establishment) {
        Network.shared.getEstablishmentDetail(from: establishment) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let establishment):
                self.establishment = establishment
                self.visits = establishment.visits ?? []
                self.initialDataFound = true
                self.addViewsToScrollingStack()
                self.collectionView.reloadData()
            case .failure(let error):
                print(error)
                fatalError()
            }
        }
    }
    
    private func setUpView() {
        self.view.clipsToBounds = true
        self.view.layer.cornerRadius = 12.5
        self.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        if mode == .halfScreen {
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureSelector(recognizer:)))
            self.view.addGestureRecognizer(panGestureRecognizer)
        }
        
        if mode == .fullScreen {
            self.navigationItem.title = establishment?.name ?? "Restaurant detail"
        }
    }
    
    private func setUpHeader(establishment: Establishment) {
        
        if mode == .halfScreen {
            headerView = HeaderView(leftButtonTitle: "Done", rightButtonTitle: "", title: establishment.name)
            headerView.headerLabel.font = .secondaryTitle
            self.view.addSubview(headerView)
            headerView.constrain(.leading, to: self.view, .leading, constant: 5.0)
            headerView.constrain(.top, to: self.view, .top, constant: 10.0)
            headerView.constrain(.trailing, to: self.view, .trailing, constant: 5.0)
            headerView.leftButton.addTarget(self, action: #selector(dismissChild), for: .touchUpInside)
            
            self.view.addSubview(spacer)
            spacer.constrain(.leading, to: self.view, .leading)
            spacer.constrain(.trailing, to: self.view, .trailing)
            spacer.constrain(.top, to: headerView, .bottom, constant: 5.0)
        } else {
            if let coordinate = establishment.coordinate {
                mapLocationView = MapLocationView(locationTitle: establishment.name, coordinate: coordinate, address: establishment.displayAddress)
                self.view.addSubview(mapLocationView!)
                mapLocationView?.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.2).isActive = true
                mapLocationView!.constrain(.leading, to: self.view, .leading)
                mapLocationView!.constrain(.top, to: self.view, .top, constant: 10.0)
                mapLocationView!.constrain(.trailing, to: self.view, .trailing)
            }
        }
    }
    
    private func setUpScrollingSelectDateView() {
        scrollingStack = ScrollingStackView(subViews: [])
        self.view.addSubview(scrollingStack)
        
        if mode == .fullScreen {
            if mapLocationView != nil {
                scrollingStack.constrain(.top, to: mapLocationView!, .bottom, constant: 5.0)
            } else {
                scrollingStack.constrain(.top, to: self.view, .top, constant: 5.0)
            }
        } else {
            scrollingStack.constrain(.top, to: spacer, .bottom, constant: 5.0)
        }
        
        scrollingStack.constrain(.leading, to: self.view, .leading, constant: 5.0)
        scrollingStack.constrain(.trailing, to: self.view, .trailing, constant: 5.0)
        scrollingStack.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
    }
    
    private func setUpCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        
        self.view.addSubview(collectionView)
        
        collectionView.constrain(.top, to: scrollingStack, .bottom, constant: 5.0)
        collectionView.constrain(.leading, to: self.view, .leading, constant: padding)
        collectionView.constrain(.trailing, to: self.view, .trailing, constant: padding)
        collectionView.constrain(.bottom, to: self.view, .bottom, constant: padding)
        
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(HeaderEstablishmentReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }
    
    private func addViewsToScrollingStack() {
        for (i, visit) in visits.enumerated() {
            let button = SizeChangeButton.genericScrollingButton()
            button.setTitle(visit.shortUserDate, for: .normal)
            button.tag = i
            button.addTarget(self, action: #selector(dateButtonAction(sender:)), for: .touchUpInside)
            scrollingStack.stackView.addArrangedSubview(button)
            if i == 0 {
                button.isSelected = true
            }
        }
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
        self.parent?.removeChildViewControllersFromBottom(onCompletion: { [weak self] (done) in
            guard let self = self else { return }
            self.delegate?.detailDismissed()
        })
    }
    
    @objc private func dateButtonAction(sender: UIButton) {
        if !sender.isSelected {
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
        header.setUp(visit: visits[indexPath.section])
        header.tag = indexPath.section
        return header
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = visits.count
        if count == 0 {
            if initialDataFound {
                let button = collectionView.setEmptyWithAction(message: "No visits at this location yet", buttonTitle: "")
                button.isHidden = true
            } else {
                collectionView.showLoadingOnCollectionView()
            }
            return 0
        } else {
            collectionView.restore()
            return visits.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let visit = visits[section]
        return visit.listPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotoCell
        let visit = visits[indexPath.section]
        let key = NSString(string: "\(indexPath.section).\(indexPath.row)")
        if let image = imageCache.object(forKey: key) {
            cell.imageView.image = image
        } else {
            let listPhotos = visit.listPhotos
            let url = listPhotos[indexPath.row]
            cell.imageView.appStartSkeleton()
            Network.shared.getImage(url: url) { [weak self] (image) in
                cell.imageView.appEndSkeleton()
                cell.imageView.image = image
                if let image = image {
                    self?.imageCache.setObject(image, forKey: key)
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellSelected = collectionView.cellForItem(at: indexPath) as! PhotoCell
        cellSelected.imageView.hero.id = .photosToSinglePhotoID
        let imageFromCell = cellSelected.imageView.image
        if let image = imageFromCell {
            let newVC = SinglePhotoVC(image: image, imageURL: nil, cell: cellSelected, asset: nil)
            self.navigationController?.present(newVC, animated: true, completion: nil)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)

        return headerView.systemLayoutSizeFitting(CGSize(width: UIView.layoutFittingExpandedSize.width, height: collectionView.frame.height),
                                                  withHorizontalFittingPriority: .fittingSizeLevel,
                                                  verticalFittingPriority: .required)
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
