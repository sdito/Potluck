//
//  UIApplication-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 9/24/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

extension UIApplication {
    /// The top most view controller
    static let appKeyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
    static var topMostViewController: UIViewController? {
        return appKeyWindow?.rootViewController?.visibleViewController
    }
}
