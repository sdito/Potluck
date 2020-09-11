//
//  UIDevice-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 9/10/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

extension UIDevice {
    static func vibrateSelectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    static func vibrateSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    static func vibrateError() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}
