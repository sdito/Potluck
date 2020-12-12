//
//  DynamicHeightLayout.swift
//  restaurants
//
//  Created by Steven Dito on 12/10/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation


import UIKit


#warning("need to use")
protocol DynamicHeightLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForTextAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat
}


class DynamicHeightLayout: UICollectionViewLayout {
    var delegate: DynamicHeightLayoutDelegate!
    var numberOfColumns = 2
    var cellPadding: CGFloat = 2
    var headerHeight: CGFloat = 50 // decide if should use
    
    var cache = [UICollectionViewLayoutAttributes]()
    fileprivate var contentHeight: CGFloat = 0
    fileprivate var width: CGFloat {
        get {
            guard let collectionView = collectionView else {
              return 0
            }
            let insets = collectionView.contentInset
            return collectionView.bounds.width - (insets.left + insets.right)
        }
    }
    
    override var collectionViewContentSize: CGSize {
        // 100 higher to have a buffer from the bottom so everything is not as tight,
        // will easily give space to alert the user if there are more recipes loading or if there are no more recipes to find
        return CGSize(width: width, height: contentHeight + 100.0)
    }
    
    override func prepare() {
        super.prepare()
        cache.removeAll()
        contentHeight = 0
        if cache.isEmpty {
            let columnWidth = width / CGFloat(numberOfColumns)
            var xOffsets = [CGFloat]()
            for column in 0..<numberOfColumns {
                xOffsets.append(CGFloat(column) * columnWidth)
            }
            var yOffsets = [CGFloat](repeating: 0, count: numberOfColumns)
            var column = 0
            
            
            for item in 0..<collectionView!.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                let width = columnWidth - (cellPadding * 2)
                let imageHeight = width
                let height = delegate.collectionView(collectionView!, heightForTextAtIndexPath: indexPath, withWidth: width) + imageHeight + (cellPadding * 2)
                
                let frame = CGRect(x: xOffsets[column], y: yOffsets[column], width: columnWidth, height: height)
                let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                attributes.frame = insetFrame
                cache.append(attributes)
                
                contentHeight = max(contentHeight, frame.maxY)
                yOffsets[column] = yOffsets[column] + height
                column = column >= (numberOfColumns - 1) ? 0 : column + 1
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }

    
}
