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
    
    init(establishment: Establishment, delegate: EstablishmentDetailDelegate?) {
        super.init(nibName: nil, bundle: nil)
        self.establishment = establishment
        self.delegate = delegate
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
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.layoutIfNeeded()
        
        layout.scrollDirection = .horizontal
        
        let cellSizeSize = self.collectionView.bounds.height / 2.0
        
        layout.itemSize = CGSize(width: cellSizeSize - padding, height: cellSizeSize - padding)
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = padding
        
    }
    
    private func getRestaurantInfo(establishment: Establishment) {
        Network.shared.getEstablishmentDetail(from: establishment) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let establishment):
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
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureSelector(recognizer:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    private func setUpHeader(establishment: Establishment) {
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
    }
    
    private func setUpScrollingSelectDateView() {
        scrollingStack = ScrollingStackView(subViews: [])
        self.view.addSubview(scrollingStack)
        scrollingStack.constrain(.top, to: spacer, .bottom, constant: 5.0)
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
        for visit in visits {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(visit.userDate, for: .normal)
            button.titleLabel?.font = .mediumBold
            button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0)
            button.layer.cornerRadius = 4.0
            button.clipsToBounds = true
            button.backgroundColor = .secondarySystemBackground
            scrollingStack.stackView.addArrangedSubview(button)
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
    
}


// MARK: Collection view
extension EstablishmentDetailVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! HeaderEstablishmentReusableView
        header.setUp(visit: visits[indexPath.section])
        return header
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = visits.count
        if count == 0 {
            if initialDataFound {
                let button = collectionView.setEmptyWithAction(message: "No visits at this location yet", buttonTitle: "")
                button.isHidden = true
            } else {
                for _ in 1...10 {
                    print("Should be loading")
                }
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
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)

        return headerView.systemLayoutSizeFitting(CGSize(width: UIView.layoutFittingExpandedSize.width, height: collectionView.frame.height),
                                                  withHorizontalFittingPriority: .fittingSizeLevel,
                                                  verticalFittingPriority: .required)
    }
    
}
