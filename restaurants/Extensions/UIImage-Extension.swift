//
//  UIImage-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 7/4/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

extension UIImage {
    func resizeImage(to targetSize: CGSize) -> UIImage {

        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height

        var newSize: CGSize {
            if widthRatio > heightRatio {
                return CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                return CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
            }
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
          let rect = CGRect(origin: .zero, size: size)
          UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
          color.setFill()
          UIRectFill(rect)
          let image = UIGraphicsGetImageFromCurrentImageContext()
          UIGraphicsEndImageContext()

          guard let cgImage = image?.cgImage else { return nil }
          self.init(cgImage: cgImage)
    }
    
}
