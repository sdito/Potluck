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
    private var standalone = false
    private var previousPhotos: [String]?
    private var editingVisit: Visit?
    weak var delegate: ImageSelectorDelegate?
    private var selectedPhotos: [ImageInfo] = [] {
        didSet {
            delegate?.photosUpdated(to: self.selectedPhotos)
            updateSelectUpToLabel()
            DispatchQueue.main.asyncAfter(deadline: .now() + self.stackViewAnimationDuration + 0.1) {
                for (i, arrangedView) in self.scrollingView.stackView.arrangedSubviews.enumerated() {
                    if let xView = arrangedView as? ImageXView {
                        xView.updateForStarPosition(firstLocation: i == 0)
                    }
                }
            }
        }
    }
    
    private let selectUpToLabel = UILabel()
    private var allPhotos = PHFetchResult<PHAsset>()
    private var allowChangesOnNewView = false
    private let placeholderView = UIView()
    private let scrollingView = ScrollingStackView(subViews: [])
    private let basicSize: CGFloat = 80.0
    private lazy var collectionView = CameraRollCollectionView(width: self.view.bounds.width)
    private let imageManager = PHImageManager.default()
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
    private let maxPhotos = 5
    private static var idCounter = 0
    private let upperStackView = UIStackView()
    private lazy var headerView = HeaderView(leftButtonTitle: "Cancel", rightButtonTitle: "Done", title: "Edit photos")
    private lazy var spacerView = SpacerView(size: 2.0, orientation: .vertical)
    private lazy var imageInfoStartedWith: [ImageInfo] = []
    
    init(standalone: Bool = false, previousPhotos: [String]? = nil, visit: Visit? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.standalone = standalone
        self.previousPhotos = previousPhotos
        self.editingVisit = visit
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUpHeaderForStandalone()
        setUpUpperElements()
        setUpScrollingStackView()
        setUpCollectionView()
        getUserPhotos()
        addPreviousPhotos()
    }
    
    private func setUpHeaderForStandalone() {
        if standalone {
            self.view.addSubview(headerView)
            headerView.constrain(.leading, to: self.view, .leading, constant: scrollingViewConstant)
            headerView.constrain(.trailing, to: self.view, .trailing, constant: scrollingViewConstant)
            headerView.constrain(.top, to: self.view, .top, constant: scrollingViewConstant)
            headerView.leftButton.addTarget(self, action: #selector(dismissVc), for: .touchUpInside)
            headerView.rightButton.addTarget(self, action: #selector(doneWithEditingPressed), for: .touchUpInside)
            
            self.view.addSubview(spacerView)
            spacerView.constrain(.leading, to: self.view, .leading)
            spacerView.constrain(.trailing, to: self.view, .trailing)
            spacerView.constrain(.top, to: headerView, .bottom, constant: scrollingViewConstant)
        }
    }
    
    private func setUpUpperElements() {
        upperStackView.translatesAutoresizingMaskIntoConstraints = false
        upperStackView.axis = .horizontal
        upperStackView.spacing = scrollingViewConstant
        upperStackView.distribution = .fill
        self.view.addSubview(upperStackView)
        
        if standalone {
            // has the header view then
            upperStackView.constrain(.top, to: spacerView, .bottom, constant: scrollingViewConstant)
        } else {
            upperStackView.constrain(.top, to: self.view, .top, constant: scrollingViewConstant)
            
        }
        
        upperStackView.constrain(.leading, to: self.view, .leading, constant: scrollingViewConstant)
        upperStackView.constrain(.trailing, to: self.view, .trailing, constant: scrollingViewConstant)
        
        selectUpToLabel.translatesAutoresizingMaskIntoConstraints = false
        updateSelectUpToLabel()
        selectUpToLabel.font = .mediumBold
        selectUpToLabel.textColor = .tertiaryLabel
        selectUpToLabel.textAlignment = .left
        selectUpToLabel.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        upperStackView.addArrangedSubview(selectUpToLabel)
        
        let infoButton = UIButton(type: .infoDark)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.tintColor = Colors.main
        infoButton.addTarget(self, action: #selector(infoButtonPressed), for: .touchUpInside)
        infoButton.setContentHuggingPriority(.required, for: .horizontal)
        upperStackView.addArrangedSubview(infoButton)
        
        let cameraButton = UIButton()
        cameraButton.setImage(.cameraImage, for: .normal)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.tintColor = Colors.main
        cameraButton.addTarget(self, action: #selector(cameraButtonPressed), for: .touchUpInside)
        cameraButton.setContentHuggingPriority(.required, for: .horizontal)
        upperStackView.addArrangedSubview(cameraButton)
    }
    
    private func setUpScrollingStackView() {
        
        self.view.addSubview(scrollingView)
        scrollingView.constrain(.leading, to: self.view, .leading, constant: scrollingViewConstant)
        scrollingView.constrain(.trailing, to: self.view, .trailing, constant: scrollingViewConstant)
        scrollingView.constrain(.top, to: upperStackView, .bottom, constant: scrollingViewConstant)
        scrollingView.clipsToBounds = false
        
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.backgroundColor = .clear
        scrollingView.stackView.addArrangedSubview(placeholderView)
        placeholderView.equalSides(size: basicSize)
        placeholderView.tag = -1
        placeholderView.isHidden = true
    }
    
    private func setUpCollectionView() {
        self.view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.constrain(.top, to: scrollingView, .bottom, constant: 10.0)
        collectionView.constrain(.leading, to: self.view, .leading)
        collectionView.constrain(.trailing, to: self.view, .trailing)
        collectionView.constrain(.bottom, to: self.view, .bottom)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ImageSelectorVC.longPress(longPressGestureRecognizer:)))
        collectionView.addGestureRecognizer(longPressRecognizer)
    }
    
    private func addPreviousPhotos() {
        guard let previousPhotos = previousPhotos else { return }
        for previousPhoto in previousPhotos {
            let holderView = addNewImage(image: nil, tag: nil)
            holderView.appStartSkeleton()
            Network.shared.getImage(url: previousPhoto) { (imageFound) in
                holderView.appEndSkeleton()
                holderView.imageView.image = imageFound
            }
        }
        imageInfoStartedWith = selectedPhotos
    }
    
    @discardableResult
    private func addNewImage(image: UIImage?, tag: Int?) -> ImageXView {
        let imageInfo = ImageInfo(image: image ?? UIImage(), asset: nil, date: Date(), indexPath: nil, isDummy: false)
        selectedPhotos.append(imageInfo)
        let holderView = ImageXView()
        let selectedIndex = self.scrollingView.stackView.arrangedSubviews.count - 1
        holderView.setUp(image: image ?? UIImage(), size: self.basicSize, tag: tag ?? -1, uniqueId: imageInfo.uniqueId)
        self.scrollingView.stackView.insertArrangedSubview(holderView, at: selectedIndex)
        self.setUpMoveGestureRecognizer(holderView)
        holderView.cancelButton.addTarget(self, action: #selector(self.removeImageView(sender:)), for: .touchUpInside)
        self.placeholderView.isHidden = true
        return holderView
    }
    
    
    private func getUserPhotos() {
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
    
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .authorized, .limited:
                self.collectionView.restore()
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
                DispatchQueue.main.async {
                    let button = self.collectionView.setEmptyWithAction(message: "Photo authorization not enabled. Enable to upload photos from your visits.", buttonTitle: "Enable access in privacy settings")
                    button.addTarget(self, action: #selector(self.photosNotAuthorized), for: .touchUpInside)
                }
            case .notDetermined:
                // Should not see this when requesting
                return
            @unknown default:
                return
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
    
    private func imageSelected(image: UIImage, index: Int, originFrame: CGRect, cell: UICollectionViewCell, uniqueId: Int) {
        
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
                let selectedIndex = self.scrollingView.stackView.arrangedSubviews.count - 1
                holderView.setUp(image: animatedView.image, size: self.basicSize, tag: index, uniqueId: uniqueId)
                self.scrollingView.stackView.insertArrangedSubview(holderView, at: selectedIndex)
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
        
        let xView = senderView as? ImageXView
        let placeholderImage = xView?.imageView.image
        let tagPlaceholder = xView?.representativeIndex ?? -1
        
        guard let touchPoint = touchPoint, let senderView = senderView else { return }
        let scaleTransform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        if sender.state == .began {

            scrollingView.stackView.bringSubviewToFront(senderView)
            initialFrame = self.scrollingView.scrollView.convert(senderView.frame, to: self.view)
        
            beginningPoint = touchPoint
            newFakeView = ImageXView(frame: initialFrame)
            newFakeView?.setUp(image: placeholderImage, size: self.basicSize, tag: tagPlaceholder, uniqueId: xView?.uniqueId ?? -1)
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
            // was changed --- initial point was off
            if allowChangesOnNewView {
                let newOriginX = (touchPoint.x - beginningPoint.x) + initialFrame.origin.x
                let newOriginY = (touchPoint.y - beginningPoint.y) + scrollingViewConstant
                let maximumY = scrollingView.frame.maxY - newFakeView!.bounds.height
                newFakeView?.frame.origin.x = newOriginX
                newFakeView?.frame.origin.y = min(maximumY, newOriginY)
            }
            
            scrollingView.indexForViewAtAbsoluteX(touchPoint.x, fromIndex: scrollingView.stackView.arrangedSubviews.firstIndex(of: senderView) ?? 0)
            
        } else if sender.state == .ended {
            scrollingView.resetSelectedIndex()
            timer?.invalidate()
            self.placeholderView.isHidden = true // reset back
            let finalIndex = scrollingView.indexForViewAtAbsoluteX(touchPoint.x, fromIndex: scrollingView.stackView.arrangedSubviews.firstIndex(of: senderView) ?? 0)
            scrollingView.removePlaceholderView()
            
            // have to add at final index index from the previous index
            if let addAtIndex = finalIndex, let previousIndex = scrollingView.stackView.arrangedSubviews.firstIndex(of: senderView) {
                let placeHolderView = ImageXView()
                placeHolderView.setUp(image: newFakeView?.imageView.image, size: self.basicSize, tag: newFakeView?.representativeIndex ?? -1, uniqueId: xView?.uniqueId ?? -1)
                placeHolderView.isHidden = true
                placeHolderView.cancelButton.addTarget(self, action: #selector(self.removeImageView(sender:)), for: .touchUpInside)
                self.setUpMoveGestureRecognizer(placeHolderView)
                self.scrollingView.stackView.arrangedSubviews[previousIndex].removeFromStackViewAnimated(duration: self.stackViewAnimationDuration)
                self.scrollingView.stackView.insertArrangedSubview(placeHolderView, at: addAtIndex)
                newFakeView?.removeFromSuperview()
                
                // need to update the selectedPhotos array
                var tempArray = selectedPhotos
                let changingElement = tempArray.remove(at: previousIndex)
                let placeholder = ImageInfo(image: UIImage(), asset: PHAsset(), date: Date(), indexPath: IndexPath(row: -1, section: -1), isDummy: true)
                tempArray.insert(placeholder, at: previousIndex)
                tempArray.insert(changingElement, at: addAtIndex)
                tempArray.removeAll { (imgInfo) -> Bool in
                    imgInfo.uniqueId == placeholder.uniqueId
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
        
        selectedPhotos.removeAll { (info) -> Bool in
            info.uniqueId == superView.uniqueId
        }
        
        if superView.representativeIndex >= 0 {
            let indexPath = IndexPath(item: superView.representativeIndex, section: 0)
            collectionView.reloadItems(at: [indexPath])
        }
        
        superView.removeFromStackViewAnimated(duration: stackViewAnimationDuration)
    }
    
    @objc private func infoButtonPressed() {
        self.appAlert(title: "Photos", message: "Press and hold then drag a photo to change the order. The first photo is the main photo and will be displayed first.", buttons: [("Ok", nil)])
    }
    
    @objc private func cameraButtonPressed() {
        guard selectedPhotos.count < maxPhotos else {
            selectUpToLabel.shakeView()
            UIDevice.vibrateError()
            return
        }
        
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        (self.parent ?? self).present(vc, animated: true)
    }
    
    @objc private func photosNotAuthorized() {
        UIDevice.openAppSettings()
    }
    
    private func updateSelectUpToLabel() {
        let count = selectedPhotos.count
        let value = maxPhotos - count
        
        if count == 0 {
            selectUpToLabel.text = "Select/take up to \(maxPhotos) photos"
        } else if value == 0 {
            selectUpToLabel.text = "Maximum photos selected"
        } else {
            let s = (value == 1) ? "" : "s"
            selectUpToLabel.text = "Select/take up to \(value) more photo\(s)"
        }
    }
    
    @objc private func dismissVc() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneWithEditingPressed() {
        #warning("need to complete and stuff, can delete imageInfoStartedWith stuff at end probably")
        print()
        print("Photos started with: \(imageInfoStartedWith.map({$0.uniqueId}))")
        print("Photos ended with: \(selectedPhotos.map({$0.uniqueId}))")
        print()
        
        let previousIds = imageInfoStartedWith.map({$0.uniqueId})
        /*
         For each photo in selected photos, need to determine how it got there
         Main is 0, first in other 1, second 2, and so on
         
         -- Deletions (not in end, in beginning, will be handled on backend)
         -- Go through the ending selected photos and create image trasnfers
         */
        var imageTransfers: [ImageTransfer] = []
        for (i, v) in selectedPhotos.enumerated() {
            let previousMain = previousIds.first == v.uniqueId
            let newMain = i == 0
            var previousOrder: Int?
            var newOrder: Int?
            if !newMain {
                newOrder = i
            }
            
            if !previousMain {
                // a nil previous order means it is new
                // get indexOf previous id in previousIds for the previous order, if not previousMain
                previousOrder = previousIds.firstIndex(of: v.uniqueId)
            }
            
            let imageTransfer = ImageTransfer(previousMain: previousMain,
                                              newMain: newMain,
                                              newPhoto: !previousMain && previousOrder == nil,
                                              image: v.maxImage ?? v.image,
                                              previousOrder: previousOrder,
                                              newOrder: newOrder)
            
            imageTransfers.append(imageTransfer)
        }
        
        
        // need to determine how many new images there are here, and get that many presigned posts and upload the stuff
        Network.shared.editPhotosOnVisit(imageTransfer: imageTransfers, visit: editingVisit)
        
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
            imageManager.requestImage(for: asset, targetSize: CGSize(width: self.collectionView.cameraLayout.itemSize.width, height: self.collectionView.cameraLayout.itemSize.height), contentMode: .aspectFill, options: requestOptions) { (image, info) in
                if let image = image {
                    print(self.collectionView.cameraLayout.itemSize.width, image.size.width)
                    cell.imageView.image = image
                    self.imageCache.setObject(image, forKey: key)
                } else {
                    cell.imageView.image = nil
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if selectedPhotos.count >= maxPhotos {
            selectUpToLabel.shakeView()
            UIDevice.vibrateError()
            collectionView.cellForItem(at: indexPath)?.shakeView()
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        if let image = cell.imageView.image, let asset = cell.asset, let date = asset.creationDate {
            let imageInfo = ImageInfo(image: image, asset: asset, date: date, indexPath: indexPath, isDummy: false)
            selectedPhotos.append(imageInfo)
            cell.updateForShowingSelection(selected: true, animated: true)
            let origin = collectionView.convert(cell.frame, to: self.view)
            imageSelected(image: image, index: indexPath.row, originFrame: origin, cell: cell, uniqueId: imageInfo.uniqueId)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        selectedPhotos = selectedPhotos.filter({$0.indexPath != indexPath})
        cell.updateForShowingSelection(selected: false, animated: true)
        imageDeselected(index: indexPath.row)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewContentOffset(scrollView: collectionView)
    }
}

// MARK: Camera
extension ImageSelectorVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        
        let imageInfo = ImageInfo(image: image, asset: nil, date: Date(), indexPath: nil, isDummy: false)
        selectedPhotos.append(imageInfo)
        let holderView = ImageXView()
        let selectedIndex = self.scrollingView.stackView.arrangedSubviews.count - 1
        holderView.setUp(image: image, size: self.basicSize, tag: -1, uniqueId: imageInfo.uniqueId)
        self.scrollingView.stackView.insertArrangedSubview(holderView, at: selectedIndex)
        self.setUpMoveGestureRecognizer(holderView)
        holderView.cancelButton.addTarget(self, action: #selector(self.removeImageView(sender:)), for: .touchUpInside)
        self.placeholderView.isHidden = true
    }
}

// MARK: Image info
extension ImageSelectorVC {
    class ImageInfo {
        var image: UIImage
        var asset: PHAsset?
        var date: Date
        var indexPath: IndexPath?
        var maxImage: UIImage?
        var uniqueId: Int
        
        init(image: UIImage, asset: PHAsset?, date: Date, indexPath: IndexPath?, isDummy: Bool) {
            self.image = image
            self.asset = asset
            self.date = date
            self.indexPath = indexPath
            self.uniqueId = ImageSelectorVC.idCounter
            ImageSelectorVC.idCounter += 1
            
            if !isDummy {
                getMaxImage()
            }
        }
        
        private func getMaxImage() {
            asset?.getOriginalImage { [weak self] (imageFound) in
                guard let self = self else { return }
                self.maxImage = imageFound
            }
        }
    }
}

