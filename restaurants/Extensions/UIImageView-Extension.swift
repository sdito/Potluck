//
//  UIImageView-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 7/7/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

extension UIImageView {
    func addImageFromUrl(_ url: String?, skeleton: Bool = true, backupImage: String? = nil) {
        if let url = url {
            if skeleton { self.appStartSkeleton() }
            Network.shared.getImage(url: url) { [weak self] (img) in
                guard let self = self else { return }
                if skeleton { self.appEndSkeleton() }
                self.image = img
            }
        } else if let backup = backupImage {
            if backup == "person.crop.circle" {
                let image = UIImage(systemName: backup, withConfiguration: UIImage.SymbolConfiguration(scale: .large))
                self.image = image
            } else {
                let image = UIImage(systemName: backup)
                self.image = image
            }
        }
    }
    
}
