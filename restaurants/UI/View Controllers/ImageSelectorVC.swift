//
//  ImageSelectorVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/18/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Photos



protocol ImageSelectorDelegate: class {
    func scrollViewContentOffset(scrollView: UIScrollView)
    func photosUpdated(to selectedPhotos: [ImageSelectorVC.ImageInfo])
}


class ImageSelectorVC: UIViewController {
    
    weak var delegate: ImageSelectorDelegate!
    
    private var selectedPhotos: [ImageInfo] = [] {
        didSet {
            delegate.photosUpdated(to: self.selectedPhotos)
        }
    }
    private let infoLabel = UILabel()
    private var allPhotos = PHFetchResult<PHAsset>()
    private var allowChangesOnNewView = false
    private let placeholderView = UIView()
    private let scrollingView = ScrollingStackView(subViews: [])
    private let basicSize: CGFloat = 80.0
    private var collectionView: UICollectionView!
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private let imageManager = PHImageManager.default()
    private let padding: CGFloat = 2.0
    private let reuseIdentifier = "photoCellReuseIdentifier"
    private let requestOptions = PHImageRequestOptions()
    private let imageCache = NSCache<NSString, UIImage>()
    private let scrollingViewConstant: CGFloat = 10.0
    private var beginningPoint: CGPoint!
    private var initialFrame: CGRect!
    private var touchPoint: CGPoint?
    private let buffer: CGFloat = 80.0
    private var senderView: UIView?
    private var newFakeView: ImageXView?
    private var timer: Timer?
    private let timerInterval = 0.05
    private let stackViewAnimationDuration: TimeInterval = 0.4
    
    
    struct ImageInfo {
        var image: UIImage
        var asset: PHAsset
        var date: Date
        var indexPath: IndexPath
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSelectedImageScrollView()
        setUpCollectionView()
        setUp()
    }
    
    
    private func setUpSelectedImageScrollView() {
        
        self.view.addSubview(scrollingView)
        scrollingView.constrain(.leading, to: self.view, .leading, constant: scrollingViewConstant)
        scrollingView.constrain(.trailing, to: self.view, .trailing, constant: scrollingViewConstant)
        scrollingView.constrain(.top, to: self.view, .top, constant: scrollingViewConstant)
        scrollingView.clipsToBounds = false
        
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.backgroundColor = .clear
        scrollingView.stackView.addArrangedSubview(placeholderView)
        placeholderView.equalSides(size: basicSize)
        placeholderView.tag = -1
        placeholderView.isHidden = true
    }
    
    
    private func setUpCollectionView() {
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2.0
        let cellSizeSize = self.view.frame.width / 3
        layout.itemSize = CGSize(width: cellSizeSize - padding/2, height: cellSizeSize - padding)
        layout.minimumInteritemSpacing = 0.0
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .tertiarySystemBackground
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        
        self.view.addSubview(collectionView)
        
        collectionView.constrain(.top, to: scrollingView, .bottom, constant: 10.0)
        collectionView.constrain(.leading, to: self.view, .leading)
        collectionView.constrain(.trailing, to: self.view, .trailing)
        collectionView.constrain(.bottom, to: self.view, .bottom)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ImageSelectorVC.longPress(longPressGestureRecognizer:)))
        collectionView.addGestureRecognizer(longPressRecognizer)
    }
    
    
    
    private func setUp() {
        
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [.init(key: "creationDate", ascending: false)]
                
                self.allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                DispatchQueue.main.async {
                    if !(self.collectionView.numberOfItems(inSection: 0) == self.allPhotos.count) { // means it is already reloaded
                        self.collectionView.reloadData()
                    }
                }
                
                print("Found \(self.allPhotos.count) assets")
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                // Should not see this when requesting
                print("Not determined yet")
            @unknown default:
                fatalError()
            }
        }
    }
    
    private func imageDeselected(index: Int) {
        scrollingView.stackView.arrangedSubviews.forEach { (vEach) in
            if let v = vEach as? ImageXView {
                print(v.representativeIndex)
                if v.representativeIndex == index {
                    v.removeFromStackViewAnimated(duration: stackViewAnimationDuration)
                }
            }
        }
    }
    
    private func imageSelected(image: UIImage, index: Int, originFrame: CGRect, cell: UICollectionViewCell) {
        cell.isUserInteractionEnabled = false
        let animatedView = UIImageView(frame: originFrame)
        animatedView.image = image
        animatedView.contentMode = .scaleAspectFill
        animatedView.clipsToBounds = true
        self.view.addSubview(animatedView)
        var newFrame = scrollingView.convert(placeholderView.frame, to: self.view)
        newFrame.origin.x -= scrollingView.scrollOrigin.x
        if scrollingView.stackView.arrangedSubviews.count > 1 {
            // need to do since the view is always hidden for animation purposes
            // can't shift it over when adding at the 0th index
            newFrame.origin.x += scrollingView.stackView.spacing
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.placeholderView.isHidden = false
            animatedView.frame = newFrame
            animatedView.layoutIfNeeded()
            animatedView.tag = index
        }) { (complete) in
            if complete {
                animatedView.removeFromSuperview()
                let holderView = ImageXView()
                holderView.setUp(image: animatedView.image, size: self.basicSize, tag: index)
                self.scrollingView.stackView.insertArrangedSubview(holderView, at: self.scrollingView.stackView.arrangedSubviews.count - 1)
                cell.isUserInteractionEnabled = true
                self.setUpMoveGestureRecognizer(holderView)
                holderView.cancelButton.addTarget(self, action: #selector(self.removeImageView(sender:)), for: .touchUpInside)
                self.placeholderView.isHidden = true
            }
        }
    }
    
    private func setUpMoveGestureRecognizer(_ v: UIView) {
        let panGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressSelector(sender:)))
        v.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {

        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: touchPoint) {
                let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell
                let asset = allPhotos.object(at: indexPath.row) as PHAsset
                cell?.imageView.hero.id = .photosToSinglePhotoID
                self.navigationController?.present(SinglePhotoVC(image: cell?.imageView.image, imageURL: nil, cell: cell, asset: asset), animated: true, completion: nil)
            }
        }
    }
    
    
    
    @objc private func longPressSelector(sender: UILongPressGestureRecognizer) {
        touchPoint = sender.location(in: self.view)
        senderView = sender.view
        
        let placeholderImage = (senderView as? ImageXView)?.imageView.image
        let tagPlaceholder = (senderView as? ImageXView)?.representativeIndex ?? -1
        
        guard let touchPoint = touchPoint, let senderView = senderView else { return }
        let scaleTransform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        if sender.state == .began {
            
            scrollingView.stackView.bringSubviewToFront(senderView)
            initialFrame = self.scrollingView.scrollView.convert(senderView.frame, to: self.view)
        
            beginningPoint = touchPoint
            newFakeView = ImageXView(frame: initialFrame)
            newFakeView?.setUp(image: placeholderImage, size: self.basicSize, tag: tagPlaceholder)
            newFakeView?.showBorderForMoving()
            newFakeView?.center = senderView.center
            newFakeView?.frame.origin.x -= scrollingView.scrollView.contentOffset.x
            scrollingView.addSubview(newFakeView!)
            view.bringSubviewToFront(newFakeView!)
            
            senderView.alpha = 0.3
            senderView.transform = scaleTransform
            
            UIView.animate(withDuration: 0.2, animations: {
                self.newFakeView?.transform = scaleTransform
            }) { (complete) in
                if complete {
                    self.allowChangesOnNewView = true
                    self.timer = Timer.scheduledTimer(timeInterval: self.timerInterval, target: self, selector: #selector(self.runTimer), userInfo: nil, repeats: true)
                    // set the placeholderView isHidden to false to allow the yellow middle view to go on the placeholder view
                    self.placeholderView.isHidden = false
                    
                }
            }
        } else if sender.state == .changed {
            
            if allowChangesOnNewView {
                let newOriginX = (touchPoint.x - beginningPoint.x) + initialFrame.origin.x + scrollingViewConstant
                let newOriginY = (touchPoint.y - beginningPoint.y) + initialFrame.origin.y + scrollingViewConstant
                let maximumY = scrollingView.frame.maxY - newFakeView!.bounds.height
                newFakeView?.frame.origin.x = newOriginX
                newFakeView?.frame.origin.y = min(maximumY, newOriginY)
            }
            
            scrollingView.indexForViewAtAbsoluteX(touchPoint.x, fromIndex: scrollingView.stackView.arrangedSubviews.firstIndex(of: senderView) ?? 0)
            
        } else if sender.state == .ended {
            timer?.invalidate()
            self.placeholderView.isHidden = true // reset back
            let finalIndex = scrollingView.indexForViewAtAbsoluteX(touchPoint.x, fromIndex: scrollingView.stackView.arrangedSubviews.firstIndex(of: senderView) ?? 0)
            scrollingView.removePlaceholderView()
            
            // have to add at final index index from the previous index
            if let addAtIndex = finalIndex, let previousIndex = scrollingView.stackView.arrangedSubviews.firstIndex(of: senderView) {
                let placeHolderView = ImageXView()
                placeHolderView.setUp(image: newFakeView?.imageView.image, size: self.basicSize, tag: newFakeView?.representativeIndex ?? -1)
                placeHolderView.isHidden = true
                placeHolderView.cancelButton.addTarget(self, action: #selector(self.removeImageView(sender:)), for: .touchUpInside)
                self.setUpMoveGestureRecognizer(placeHolderView)
                self.scrollingView.stackView.arrangedSubviews[previousIndex].removeFromStackViewAnimated(duration: self.stackViewAnimationDuration)
                self.scrollingView.stackView.insertArrangedSubview(placeHolderView, at: addAtIndex)
                newFakeView?.removeFromSuperview()
                
                // need to update the selectedPhotos array
                var tempArray = selectedPhotos
                let changingElement = tempArray.remove(at: previousIndex)
                let placeholder = ImageInfo(image: UIImage(), asset: PHAsset(), date: Date(), indexPath: IndexPath(row: -1, section: -1))
                tempArray.insert(placeholder, at: previousIndex)
                tempArray.insert(changingElement, at: addAtIndex)
                tempArray.removeAll { (imgInfo) -> Bool in
                    imgInfo.indexPath == placeholder.indexPath
                }
                selectedPhotos = tempArray
                
                UIView.animate(withDuration: 0.3) {
                    placeHolderView.isHidden = false
                }
            } else {
                // Just go back to the original spot, nothing happened or cancelled
                UIView.animate(withDuration: 0.2, animations: {
                    self.newFakeView?.alpha = 0.0
                    senderView.alpha = 1.0
                    senderView.transform = .identity
                }) { (complete) in
                    if complete {
                        self.allowChangesOnNewView = false
                        self.newFakeView?.removeFromSuperview()
                    }
                }
            }
        }
    }

    
    @objc private func runTimer() {
        
        let scrollDistance: CGFloat = 15.0
        let viewWidth = self.view.bounds.width
        let scrollContentOffsetX = self.scrollingView.scrollView.contentOffset.x
        if allowChangesOnNewView, let touchPointX = touchPoint?.x, scrollingView.scrollView.contentOverflows {
            if touchPointX < buffer {
                if scrollContentOffsetX > 0.0 {
                    UIView.animate(withDuration: timerInterval) {
                        self.scrollingView.scrollView.contentOffset.x -= scrollDistance
                    }
                }
            } else if touchPointX > (viewWidth - buffer) {
                
                if !self.scrollingView.scrollView.isAtEnd {
                    UIView.animate(withDuration: timerInterval) {
                        self.scrollingView.scrollView.contentOffset.x += scrollDistance
                    }
                }
            }
        }
    }
    
    @objc private func removeImageView(sender: UIButton) {
        guard let superView = sender.superview as? ImageXView else { return }
        let indexPath = IndexPath(item: superView.representativeIndex, section: 0)
        selectedPhotos.removeAll { (info) -> Bool in
            info.indexPath == indexPath
        }
        collectionView.reloadItems(at: [indexPath])
        superView.removeFromStackViewAnimated(duration: stackViewAnimationDuration)
    }
}

// MARK: Collection view
extension ImageSelectorVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        cell.imageView.image = nil
        cell.allowsSelection = true
        cell.updateForShowingSelection(selected: selectedPhotos.contains(where: {$0.indexPath == indexPath}), animated: false)
        let asset = allPhotos.object(at: indexPath.row) as PHAsset
        let creationDate = asset.creationDate
        cell.creationDate = creationDate
        cell.asset = asset
        
        let key = NSString(string: "\(indexPath.row)")
        if let cachedImage = imageCache.object(forKey: key) {
            cell.imageView.image = cachedImage
        } else {
            
            imageManager.requestImage(for: asset, targetSize: CGSize(width: layout.itemSize.width * 3.0, height: layout.itemSize.height * 3.0), contentMode: .aspectFit, options: requestOptions) { (image, info) in
                if let image = image {
                    cell.imageView.image = image
                    self.imageCache.setObject(image, forKey: key)
                } else {
                    cell.imageView.image = nil
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        if let image = cell.imageView.image, let asset = cell.asset, let date = asset.creationDate {
            selectedPhotos.append(ImageInfo(image: image, asset: asset, date: date, indexPath: indexPath))
            cell.updateForShowingSelection(selected: true, animated: true)
            let origin = collectionView.convert(cell.frame, to: self.view)
            imageSelected(image: image, index: indexPath.row, originFrame: origin, cell: cell)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        selectedPhotos = selectedPhotos.filter({$0.indexPath != indexPath})
        cell.updateForShowingSelection(selected: false, animated: true)
        imageDeselected(index: indexPath.row)
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate.scrollViewContentOffset(scrollView: collectionView)
    }
    
    
}
