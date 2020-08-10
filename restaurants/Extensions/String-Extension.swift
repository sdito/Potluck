//
//  String-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 7/9/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


extension String {
    
    
    func convertFromStringToDisplayTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HHmm"
        let date = dateFormatter.date(from: self)
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date!)
    }

    func getAffirmativeOrNegativeAttributedString(_ affirmative: Bool, font: UIFont? = nil) -> NSAttributedString {
        var image: UIImage {
            if affirmative {
                let img = UIImage(systemName: "checkmark")!.withTintColor(.systemGreen)
                return img
            } else {
                let img = UIImage(systemName: "slash.circle")!.withTintColor(.systemRed)
                return img
            }
        }
        return self.addImageAtBeginning(image: image, font: font)
        
    }
    
    func addImageAtBeginning(image: UIImage, font: UIFont? = nil, color: UIColor? = nil) -> NSAttributedString {
        
        let string = NSMutableAttributedString()
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        let imageString = NSAttributedString(attachment: imageAttachment)
        string.append(imageString)
        string.append(NSAttributedString(string: " \(self)"))
        
        if let font = font {
            let length = string.length
            let range = NSRange(location: 0, length: length)
            string.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        }
        
        if let color = color {
            let length = string.length
            let range = NSRange(location: 0, length: length)
            string.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
        
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
