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
    
}


class ImageSelectorVC: UIViewController {
    
    weak var delegate: ImageSelectorDelegate!
    
    private let placeholderView = UIView()
    private let scrollingView = ScrollingStackView(subViews: [])
    private let basicSize: CGFloat = 80.0
    private var collectionView: UICollectionView!
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private let imageManager = PHImageManager.default()
    private var allPhotos = PHFetchResult<PHAsset>()
    private let padding: CGFloat = 2.0
    private let reuseIdentifier = "photoCellReuseIdentifier"
    private let requestOptions = PHImageRequestOptions()
    private let imageCache = NSCache<NSString, UIImage>()
    private var selectedIndexPaths: Set<IndexPath> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSelectedImageScrollView()
        setUpCollectionView()
        setUp()
        
    }
    
    private func setUpSelectedImageScrollView() {
        
        self.view.addSubview(scrollingView)
        scrollingView.constrain(.leading, to: self.view, .leading, constant: 10.0)
        scrollingView.constrain(.trailing, to: self.view, .trailing, constant: 10.0)
        scrollingView.constrain(.top, to: self.view, .top, constant: 10.0)
        
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.backgroundColor = .clear
        scrollingView.stackView.addArrangedSubview(placeholderView)
        placeholderView.equalSides(size: basicSize)
        placeholderView.tag = -1
    }
    
    private func setUpCollectionView() {
        
        self.view.backgroundColor = .systemBackground
        
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2.0
        let cellSizeSize = self.view.frame.width / 3
        layout.itemSize = CGSize(width: cellSizeSize - padding/2, height: cellSizeSize - padding)
        layout.minimumInteritemSpacing = 0.0
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.allowsMultipleSelection = true
        
        self.view.addSubview(collectionView)
        
        collectionView.constrain(.top, to: scrollingView, .bottom, constant: 10.0)
        collectionView.constrain(.leading, to: self.view, .leading)
        collectionView.constrain(.trailing, to: self.view, .trailing)
        collectionView.constrain(.bottom, to: self.view, .bottom)
        
    }
    
    
    private func setUp() {
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [.init(key: "creationDate", ascending: false)]
                //fetchOptions.fetchLimit = 500
                self.allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
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
    
    
    
    private func imageSelected(image: UIImage, index: Int, originFrame: CGRect, cell: UICollectionViewCell) {
        #warning("need to get the full size image most likely")
        cell.isUserInteractionEnabled = false
        
        let animatedView = UIImageView(frame: originFrame)
        animatedView.image = image
        animatedView.contentMode = .scaleAspectFill
        animatedView.clipsToBounds = true
        
        self.view.addSubview(animatedView)
        animatedView.backgroundColor = .green
        
        var newFrame = scrollingView.convert(placeholderView.frame, to: self.view)
        newFrame.origin.x -= scrollingView.scrollOrigin.x

        UIView.animate(withDuration: 0.5, animations: {
            animatedView.frame = newFrame
            animatedView.layoutIfNeeded()
            animatedView.tag = index
        }) { (complete) in
            if complete {
                animatedView.removeFromSuperview()
                animatedView.equalSides(size: self.basicSize)
                self.scrollingView.stackView.insertArrangedSubview(animatedView, at: self.scrollingView.stackView.arrangedSubviews.count - 1)
                cell.isUserInteractionEnabled = true
                self.addDeleteButtonToSelectedView(animatedView)
                
            }
        }
    }
    
    private func imageDeselected(index: Int) {
        scrollingView.stackView.subviews.forEach { (v) in
            if v.tag == index {
                v.removeFromSuperview()
            }
        }
    }
    
    private func addDeleteButtonToSelectedView(_ v: UIView) {
        v.isUserInteractionEnabled = true
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(.xImage, for: .normal)
        v.addSubview(b)
        b.constrain(.trailing, to: v, .trailing, constant: 3.0)
        b.constrain(.top, to: v, .top, constant: 3.0)
        b.tintColor = Colors.main
        b.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.8)
        b.clipsToBounds = true
        b.layoutIfNeeded()
        b.layer.cornerRadius = b.frame.height / 4.0
        b.equalSides()
        b.addTarget(self, action: #selector(removeImageView(sender:)), for: .touchUpInside)
        b.alpha = 0.0
        UIView.animate(withDuration: 0.3) {
            b.alpha = 1.0
        }
    }
    
    @objc private func removeImageView(sender: UIButton) {
        
        print("This is being called")
        let indexPath = IndexPath(item: sender.tag, section: 0)
        selectedIndexPaths.remove(indexPath)
        collectionView.reloadItems(at: [indexPath])
        //sender.removeFromSuperview()
        sender.superview?.removeFromSuperview()
    }
    
}

extension ImageSelectorVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        cell.imageView.image = nil
        cell.allowsSelection = true
        cell.updateForShowingSelection(selected: selectedIndexPaths.contains(indexPath))
        let asset = allPhotos.object(at: indexPath.row) as PHAsset
        let key = NSString(string: "\(indexPath.row)")
        if let cachedImage = imageCache.object(forKey: key) {
            cell.imageView.image = cachedImage
        } else {
            imageManager.requestImage(for: asset, targetSize: CGSize(width: layout.itemSize.width * 3.0, height: layout.itemSize.height * 3.0), contentMode: .aspectFit, options: requestOptions) { (image, info) in
                if let image = image {
                    print(image.size)
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
        if let image = cell.imageView.image {
            selectedIndexPaths.insert(indexPath)
            cell.updateForShowingSelection(selected: true)
            let origin = collectionView.convert(cell.frame, to: self.view)
            imageSelected(image: image, index: indexPath.row, originFrame: origin, cell: cell)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        selectedIndexPaths.remove(indexPath)
        cell.updateForShowingSelection(selected: false)
        imageDeselected(index: indexPath.row)
    }
    
    
}
