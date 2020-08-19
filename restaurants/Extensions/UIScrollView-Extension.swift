//
//  UIScrollView-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 7/7/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

extension UIScrollView {
    func setCorrectContentSize() {
        self.subviews.forEach({$0.layoutIfNeeded()})
        var height: CGFloat = 0.0
        for view in self.subviews {
            print(view.frame.height)
            height += view.frame.height
        }
        
        self.contentSize.height = height
    }
    
    /// True if content of a scroll view requires scrolling to see all of it
    var contentOverflows: Bool {
        return self.contentSize.width > self.bounds.width
    }
    
    
    var isAtEnd: Bool {
        return contentOffset.x >= verticalOffsetForEnd
    }


    var verticalOffsetForEnd: CGFloat {
        let scrollViewWidth = bounds.width
        let scrollContentSizeHeight = contentSize.width
        let rightInset = contentInset.right
        let scrollViewRightOffset = scrollContentSizeHeight + rightInset - scrollViewWidth
        return scrollViewRightOffset
    }
    
}
