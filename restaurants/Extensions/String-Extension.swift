//
//  String-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 7/9/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


extension String {
    
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    /// If string contains @ (is email), then lowercase, else return self
    func turnIntoUsernameOrEmailIdentifier() -> String {
        if self.contains("@") {
            return self.lowercased()
        } else {
            return self
        }
    }
    
    static func randomString(_ length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func isValidEmail() -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
    
    func isValidUsername() -> Bool {
        let usernameFormat = "^[a-zA-Z0-9_.-]{3,15}$"
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameFormat)
        return usernamePredicate.evaluate(with: self)
    }
    
    func isValidPassword() -> Bool {
        let passwordFormat =
        """
        ^[a-zA-Z0-9$&+,:;=?@#|'<>.^*()%!-]{8,}$
        """
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordFormat)
        return passwordPredicate.evaluate(with: self)
    }
    
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
