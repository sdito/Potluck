//
//  ProfileImageSelectorVC.swift
//  restaurants
//
//  Created by Steven Dito on 11/8/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class ProfileImageSelectorVC: UIViewController {
    
    private lazy var collectionView = CameraRollCollectionView(width: self.view.bounds.width)
    private let reuseIdentifier = "photoCellReuseIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUpNavigationBar()
        setUpCollectionView()
    }
    
    private func setUpNavigationBar() {
        let navigationView = NavigationTitleView(upperText: "SELECT", lowerText: "Profile photo")
        self.navigationItem.titleView = navigationView
    }
    
    private func setUpCollectionView() {
        self.view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.constrain(.top, to: self.view, .top, constant: 0.0)
        collectionView.constrain(.leading, to: self.view, .leading)
        collectionView.constrain(.trailing, to: self.view, .trailing)
        collectionView.constrain(.bottom, to: self.view, .bottom)
    }
}

// MARK: Collection view
extension ProfileImageSelectorVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
}
