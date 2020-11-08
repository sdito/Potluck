//
//  CameraRollCollectionView.swift
//  restaurants
//
//  Created by Steven Dito on 11/8/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class CameraRollCollectionView: UICollectionView {
    
    let cameraLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private let padding: CGFloat = 2.0
    
    init(width: CGFloat) {
        cameraLayout.scrollDirection = .vertical
        cameraLayout.minimumLineSpacing = 2.0
        let cellSizeSize = width / 3
        cameraLayout.itemSize = CGSize(width: cellSizeSize - padding/2, height: cellSizeSize - padding)
        cameraLayout.minimumInteritemSpacing = 0.0
        
        super.init(frame: .zero, collectionViewLayout: cameraLayout)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .tertiarySystemBackground
        self.showsVerticalScrollIndicator = false
        self.allowsMultipleSelection = true
        self.alwaysBounceVertical = true
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}


// MARK: Collection view
//extension CameraRollCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
//    
//}
