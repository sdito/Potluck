//
//  UIDevice-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 9/10/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import CoreLocation
import Photos
import Contacts

extension UIDevice {
    
    static let enabled = "Enabled"
    static let notEnabled = "Not enabled"
    static let notDetermined = "Not determined"
    
    static let hapticFeedbackEnabled = "hapticFeedbackEnabled"
    static let systemDarkModeKey = "systemDarkModeKey"
    static let system = "System"
    static let overrideDark = "Dark"
    static let overrideLight = "Light"
    
    static func getSystemAppearanceOverrideValue() -> String {
        let value = UserDefaults.standard.value(forKey: systemDarkModeKey) as? String
        if let value = value {
            if value == overrideDark {
                return overrideDark
            } else if value == overrideLight {
                return overrideLight
            } else {
                return system
            }
        } else {
            return system
        }
    }
    
    static func setSystemAppearance(standard: Bool = false, dark: Bool = false, light: Bool = false) {
        var value: String {
            if dark {
                return overrideDark
            } else if light {
                return overrideLight
            } else {
                return system
            }
        }
        
        UserDefaults.standard.setValue(value, forKey: systemDarkModeKey)
        NotificationCenter.default.post(name: .reloadSettings, object: nil)
        setSystemAppearanceToWindow(window: nil)
    }
    
    static func setSystemAppearanceToWindow(window: UIWindow?) {
        
        var useWindow: UIWindow? {
            if let window = window {
                return window
            } else {
                return UIApplication.appKeyWindow
            }
        }
        
        let value = UserDefaults.standard.value(forKey: systemDarkModeKey) as? String ?? system
        if value == overrideDark {
            useWindow?.overrideUserInterfaceStyle = .dark
        } else if value == overrideLight {
            useWindow?.overrideUserInterfaceStyle = .light
        } else {
            useWindow?.overrideUserInterfaceStyle = .unspecified
        }
        
    }
    
    static func isHapticFeedbackEnabled() -> Bool {
        // nil or true -> enabled; false -> not enabled
        if let value = UserDefaults.standard.value(forKey: hapticFeedbackEnabled) as? Bool {
            return value
        } else {
            return true
        }
    }
    
    static func changeEnablingHapticFeedback() {
        let value = UserDefaults.standard.value(forKey: hapticFeedbackEnabled) as? Bool ?? true
        UserDefaults.standard.setValue(!value, forKey: hapticFeedbackEnabled)
    }
    
    
    static func vibrateSelectionChanged() {
        if isHapticFeedbackEnabled() {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
    static func vibrateSuccess() {
        if isHapticFeedbackEnabled() {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)
        }
    }
    static func vibrateError() {
        if isHapticFeedbackEnabled() {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.error)
        }
    }
    
    static func readRecentLocationSearchesFromUserDefaults() -> [String] {
        let defaults = UserDefaults.standard
        let previousLocationSearches = defaults.array(forKey: .recentLocationSearchesKey) as? [String] ?? []
        return previousLocationSearches
    }
    
    static func locationServicesEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            return true
        } else {
            return false
        }
    }
    
    static func handleAuthorization() -> (authorized: Bool, needToRequest: Bool) {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            return (false, true)
        case .restricted:
            return (false, false)
        case .denied:
            return (false, false)
        case .authorizedAlways:
            return (true, false)
        case .authorizedWhenInUse:
            return (true, false)
        @unknown default:
            return (false, false)
        }
    }
    
    static func completeLocationEnabled() -> Bool {
        return locationServicesEnabled() && handleAuthorization().authorized
    }
    
    static func locationAuthorizedString() -> String {
        if locationServicesEnabled() && handleAuthorization().authorized {
            return enabled
        } else {
            return notEnabled
        }
    }
    
    static func photoAccessAuthorizedString() -> String {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            return notDetermined
        case .restricted:
            return notEnabled
        case .denied:
            return notEnabled
        case .authorized:
            return enabled
        case .limited:
            return enabled
        default:
            return notEnabled
        }
    }
    
    static func contactAccessAuthorizedString() -> String {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .notDetermined:
            return notDetermined
        case .restricted:
            return notEnabled
        case .denied:
            return notEnabled
        case .authorized:
            return enabled
        default:
            return notEnabled
        }
    }
    
    static func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { _ in return })
        }
    }
    
    static func goToReviewPage() {
        #warning("update with this apps id, 1493046325 is the ID portion")
        guard let reviewUrl = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1493046325&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software") else { return }
        if UIApplication.shared.canOpenURL(reviewUrl) {
            UIApplication.shared.open(reviewUrl, completionHandler: { _ in return })
        }
    }
    
}
