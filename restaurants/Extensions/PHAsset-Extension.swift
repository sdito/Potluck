//
//  PHAsset-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 8/21/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Photos

extension PHAsset {
    func getOriginalImage(imageFound: @escaping (UIImage?) -> Void) {
        
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        
        manager.requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions) { (image, _) in
            imageFound(image)
        }
    }
}
