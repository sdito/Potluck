//
//  PhotosVC.swift
//  restaurants
//
//  Created by Steven Dito on 7/12/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Hero

// Simple-ish squared, two column collection view to display photos, will be used in multiple places
// In the future, might need ability to have headers to split the photos by date (i.e. visit to a restaurant)


class PhotosVC: UIViewController {
    
    private var collectionView: UICollectionView!
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private var photos: [String] = []
    private let imageCache = NSCache<NSString, UIImage>()
    private let padding: CGFloat = 2.0
    private let reuseIdentifier = "photoCellReuseIdentifier"
    
    init(photos: [String]) {
        super.init(nibName: nil, bundle: nil)
        self.photos = photos
        setUpCollectionView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarColor(color: Colors.navigationBarColor)
    }

    private func setUpCollectionView() {
        self.navigationItem.title = "Photos"
        self.view.backgroundColor = .systemBackground
        
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2.0
        let cellSizeSize = self.view.frame.width / 2
        layout.itemSize = CGSize(width: cellSizeSize - padding/2, height: cellSizeSize - padding)
        layout.minimumInteritemSpacing = 0.0
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        self.view.addSubview(collectionView)
        collectionView.constrainSides(to: self.view)
    }
}


// MARK: Collection view
extension PhotosVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageUrl = photos[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        
        // add the image to the imageView
        let key = "\(indexPath.section).\(indexPath.row)" as NSString
        if let cachedImage = imageCache.object(forKey: key) {
            cell.imageView.image = cachedImage
        } else {
            cell.imageView.appStartSkeleton()
            Network.shared.getImage(url: imageUrl) { [weak self] (img) in
                guard let self = self else { return }
                cell.imageView.appEndSkeleton()
                cell.imageView.image = img
                if let img = img {
                    self.imageCache.setObject(img, forKey: key)
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
            self.present(newVC, animated: true)
            
        }
        
    }

}
