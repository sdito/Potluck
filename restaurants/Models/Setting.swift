//
//  Setting.swift
//  restaurants
//
//  Created by Steven Dito on 9/23/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation
import UIKit

enum Setting: String, CaseIterable {
    
    case account = "Account"
    case settings = "Settings"
    case privacy = "Privacy"
    
    private typealias RV = Row.Value
    
    var rows: [Row] {
        switch self {
        case .account:
            return [RV.logout.instance, RV.editAccountInfo.instance]
        case .settings:
            return [RV.appAppearance.instance, RV.reviewApp.instance, RV.hapticFeedback.instance]
        case .privacy:
            return [RV.locationEnabled.instance, RV.photosEnabled.instance]
        }
    }
    
    struct Row {
        
        var title: String
        var description: String
        var mode: SettingCell.Mode
        var subtitle: String?
        var switchAction: (() -> ())?
        var pressAction: (() -> ())?
        var switchValue: Bool?
        
        enum Value {
            case logout
            case editAccountInfo
            case hapticFeedback
            case locationEnabled
            case photosEnabled
            case reviewApp
            case appAppearance
            
            var instance: Row {
                switch self {
                case .logout:
                    return Row(title: "Logout",
                               description: "",
                               mode: .arrowOpen,
                               subtitle: Network.shared.account?.username ?? "username",
                               pressAction: { logoutAction() } )
                case .editAccountInfo:
                    return Row(title: "Edit account info",
                               description: "",
                               mode: .arrowOpen)
                case .hapticFeedback:
                    return Row(title: "Haptic feedback enabled",
                               description: "Haptic feedback is the tap or quick vibration you feel when interacting with different elements of the application, such as selecting a button to change your restaurant search.",
                               mode: .switchButton,
                               switchAction: { UIDevice.changeEnablingHapticFeedback() },
                               switchValue: UIDevice.isHapticFeedbackEnabled())
                case .locationEnabled:
                    return Row(title: "Location services",
                               description: "Location services are used to find restaurants near you. Your location is never shared with anyone.",
                               mode: .arrowOpen,
                               subtitle: UIDevice.locationAuthorizedString(),
                               pressAction: { UIDevice.openAppSettings() })
                case .photosEnabled:
                    return Row(title: "Photo access",
                               description: "Photo access is used to allow you to select photos for your visits. If this is not enabled, you will not be able to add a visit.",
                               mode: .arrowOpen,
                               subtitle: UIDevice.photoAccessAuthorizedString(),
                               pressAction: { UIDevice.openAppSettings() })
                case .reviewApp:
                    return Row(title: "Rate app in App Store",
                               description: "Rating the app would be very much appreciated",
                               mode: .arrowOpen,
                               pressAction: { UIDevice.goToReviewPage() } )
                case .appAppearance:
                    #warning("need to complete with action and stuff")
                    return Row(title: "App theme",
                               description: "The app will use your system setting for dark or light mode by default. This setting allows you to override that for only this app.",
                               mode: .arrowOpen,
                               subtitle: UIDevice.getSystemAppearanceOverrideValue(),
                               pressAction: { changeAppearanceAction() })
                }
            }
        }
    }
    
    private static func logoutAction() {
        guard let vc = UIApplication.topMostViewController else { return }
        vc.appAlert(title: "Logout", message: "Are you sure you want to log out of your account \(Network.shared.account?.username ?? "now")?", buttons: [
            ("Cancel", nil),
            ("Logout", {
                if Network.shared.loggedIn {
                    Network.shared.account?.logOut()
                    vc.showMessage("Logged out of account")
                    vc.navigationController?.popViewController(animated: true)
                }
            })
        ])
    }
    
    private static func changeAppearanceAction() {
        guard let vc = UIApplication.topMostViewController else { return }
        vc.appActionSheet(buttons: [
            AppAction(title: "System (default)", action: { UIDevice.setSystemAppearance(standard: true) } ),
            AppAction(title: "Dark mode", action: { UIDevice.setSystemAppearance(dark: true) } ),
            AppAction(title: "Light mode", action: { UIDevice.setSystemAppearance(light: true) })
        ])
    }
    
}



