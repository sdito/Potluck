//
//  NSAttributedString-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 12/12/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation
import CoreGraphics
import AVFoundation

extension NSAttributedString {
    func heightOfString(width: CGFloat?) -> CGFloat {
        return self.boundingRect(with: CGSize(width: width ?? CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, context: nil).height
    }
}
