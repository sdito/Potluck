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
import StoreKit

extension UIDevice {
    
    static let enabled = "Enabled"
    static let notEnabled = "Not enabled"
    static let notDetermined = "Not determined"
    
    static let numberOfTimesRan = "numberOfTimesRan"
    static let hapticFeedbackEnabled = "hapticFeedbackEnabled"
    static let systemDarkModeKey = "systemDarkModeKey"
    static let system = "System"
    static let overrideDark = "Dark"
    static let overrideLight = "Light"
    static let runCountToAskForRequest = 5
    
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
        guard let reviewUrl = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1543547966&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software") else { return }
        if UIApplication.shared.canOpenURL(reviewUrl) {
            UIApplication.shared.open(reviewUrl, completionHandler: { _ in return })
        }
    }
    
    static func incrementNumberOfTimesApplicationRan() {
        let numberOfTimesRan = UserDefaults.standard.value(forKey: UIDevice.numberOfTimesRan) as? Int ?? 0
        let incremented = numberOfTimesRan + 1
        UserDefaults.standard.setValue(incremented, forKey: UIDevice.numberOfTimesRan)
    }
    
    static func checkAndAskForAppStoreReviewIfApplicable() {
        guard let numberOfTimesRan = UserDefaults.standard.value(forKey: UIDevice.numberOfTimesRan) as? Int else { return }
        if numberOfTimesRan == UIDevice.runCountToAskForRequest {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                SKStoreReviewController.requestReview()
            }
        }
    }
    
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String {
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod touch (5th generation)"
            case "iPod7,1":                                 return "iPod touch (6th generation)"
            case "iPod9,1":                                 return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPhone12,8":                              return "iPhone SE (2nd generation)"
            case "iPhone13,1":                              return "iPhone 12 mini"
            case "iPhone13,2":                              return "iPhone 12"
            case "iPhone13,3":                              return "iPhone 12 Pro"
            case "iPhone13,4":                              return "iPhone 12 Pro Max"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                    return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                      return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                    return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                    return "iPad (8th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                    return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                    return "iPad Air (4th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad mini (5th generation)"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                     return "iPad Pro (11-inch) (2nd generation)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                    return "iPad Pro (12.9-inch) (4th generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "AudioAccessory5,1":                       return "HomePod mini"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()
    
}




