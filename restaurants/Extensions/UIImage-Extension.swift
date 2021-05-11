//
//  UIImage-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 7/4/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func circularOverlayMask(bounds: CGRect) -> UIImage {
        let width = bounds.size.width
        let height = bounds.size.height
        
        let diameter = width
        let radius = diameter / 2
        let center = CGPoint(x: width / 2, y: height / 2)

        // Create the image context
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)

        // Create the bezier paths
        let clipPath = UIBezierPath(rect: bounds)
        let maskPath = UIBezierPath(ovalIn: CGRect(x: center.x - radius, y: center.y - radius, width: diameter, height: diameter))

        clipPath.append(maskPath)
        clipPath.usesEvenOddFillRule = true

        clipPath.addClip()
        UIColor(white: 0, alpha: 0.5).setFill()
        clipPath.fill()
        

        let finalImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!

        return finalImage
    }
    
    
    func resizeImageToSizeButKeepAspectRatio(targetSize: CGSize) -> UIImage {
        // i.e. resize to 200 / 200, with original size of 1000 / 400
        // new size would be 500 / 200, i.e. go to the minimum size
        let selfSize = self.size
        if selfSize.width <= targetSize.width || selfSize.height <= targetSize.height {
            // already smaller than the target
            return self
        } else {
            let widthRatio = targetSize.width / selfSize.width
            let heightRatio = targetSize.height / selfSize.height
            
            if heightRatio >= widthRatio {
                let size = CGSize(width: selfSize.width * heightRatio, height: targetSize.height)
                return resizeImage(to: size)
            } else {
                let size = CGSize(width: targetSize.width, height: selfSize.height * widthRatio)
                return resizeImage(to: size)
            }
        }
    }
    
    private func resizeImage(to targetSize: CGSize) -> UIImage {
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

        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func resizeToBeNoLargerThanScreenWidth() -> UIImage {
        let width = self.size.width
        let height = self.size.height
        
        let screenWidth = UIScreen.main.bounds.width
        
        if screenWidth >= width {
            return self
        } else {
            let widthRatio = screenWidth / width
            return resizeImage(to: CGSize(width: screenWidth, height: height * widthRatio))
        }
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
