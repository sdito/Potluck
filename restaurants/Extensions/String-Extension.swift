//
//  String-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 7/9/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


extension String {

    
    func getAffirmativeOrNegativeAttributedString(_ affirmative: Bool) -> NSAttributedString {
        var image: UIImage {
            if affirmative {
                let img = UIImage(systemName: "checkmark")!.withTintColor(.systemGreen)
                return img
            } else {
                let img = UIImage(systemName: "slash.circle")!.withTintColor(.systemRed)
                return img
            }
        }
        return self.addImageAtBeginning(image: image)
        
    }
    
    func addImageAtBeginning(image: UIImage) -> NSAttributedString {
        let string = NSMutableAttributedString()
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        let imageString = NSAttributedString(attachment: imageAttachment)
        string.append(imageString)
        string.append(NSAttributedString(string: " \(self)"))
        return string
    }
}


extension Array where Element == String {
    func createViewsForDisplay() -> [UIView] {
        var scrollingViewsToAdd: [UIView] = []
        for string in self {
            let label = PaddingLabel(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0)
            label.text = string
            label.font = .smallBold
            label.backgroundColor = Colors.main
            label.layer.cornerRadius = 3.0
            label.clipsToBounds = true
            scrollingViewsToAdd.append(label)
        }
        return scrollingViewsToAdd
    }
    
}