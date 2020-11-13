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
            if Network.shared.loggedIn {
                return [RV.logout.instance, RV.phoneNumber.instance, RV.profileImage.instance, RV.accountColor.instance, RV.friends.instance, RV.requestsSent.instance, RV.requestsReceived.instance]
            } else {
                return [RV.logout.instance, RV.profileImage.instance]; #warning("remove profileImage later")
            }
            
        case .settings:
            return [RV.appAppearance.instance, RV.reviewApp.instance, RV.hapticFeedback.instance]
        case .privacy:
            return [RV.locationEnabled.instance, RV.photosEnabled.instance, RV.contactsEnabled.instance]
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
        var color: UIColor?
        var profileImage: Bool = false
        
        enum Value {
            case logout
            case phoneNumber
            case profileImage
            case accountColor
            case friends
            case requestsSent
            case requestsReceived
            case hapticFeedback
            case locationEnabled
            case photosEnabled
            case contactsEnabled
            case reviewApp
            case appAppearance
            
            var instance: Row {
                switch self {
                case .logout:
                    let title = Network.shared.loggedIn ? "Logout" : "Log in or create account"
                    return Row(title: title,
                               description: "If you don't use an account, there will be only limited features for you to use.",
                               mode: .arrowOpen,
                               subtitle: Network.shared.account?.username ?? "Go",
                               pressAction: { logoutAction() } )
                case .phoneNumber:
                    return Row(title: "Phone number",
                               description: "Your phone number is used to help you find your fiends on the app. It is optional to include your phone number.",
                               mode: .arrowOpen,
                               subtitle: Network.shared.account?.phone ?? "None",
                               pressAction: { phoneNumberAction() })
                case .profileImage:
                    return Row(title: "Profile image",
                               description: "If you have a profile image, it will appear when people search your account and by your username.",
                               mode: .arrowOpen,
                               subtitle: Network.shared.account?.actualImage == nil ? "Add" : "Change",
                               pressAction: { profileImageAction() },
                               profileImage: true)
                case .accountColor:
                    return Row(title: "Account color",
                               description: "The account color will be showed when people search your account and by your name. You are randomly assigned one.",
                               mode: .arrowOpen,
                               subtitle: "Edit",
                               pressAction: { showColorPicker() },
                               color: UIColor(hex: Network.shared.account?.color))
                case .friends:
                    return Row(title: "Friend list",
                               description: "Friends allow you to see their posts and vice versa.",
                               mode: .arrowOpen,
                               subtitle: nil,
                               pressAction: { friendsAction(mode: .friends) })
                case .requestsSent:
                    return Row(title: "Friend requests sent",
                               description: "You can edit your pending friend requests in case you accidentally sent one.",
                               mode: .arrowOpen,
                               subtitle: "Edit",
                               pressAction: { friendsAction(mode: .requestsSent) })
                case .requestsReceived:
                    return Row(title: "Friend requests received",
                               description: "You can reject or accept the friend requests, if there are any.",
                               mode: .arrowOpen,
                               subtitle: "Answer",
                               pressAction: { friendsAction(mode: .requestsReceived) })
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
                case .contactsEnabled:
                    return Row(title: "Contacts access",
                               description: "Contacts access is used to help you find your friends on this app. If this is not enabled, then you will need to manually find your friends.",
                               mode: .arrowOpen,
                               subtitle: UIDevice.contactAccessAuthorizedString(),
                               pressAction: { UIDevice.openAppSettings() } )
                case .reviewApp:
                    return Row(title: "Rate app in App Store",
                               description: "Rating the app would be very much appreciated",
                               mode: .arrowOpen,
                               pressAction: { UIDevice.goToReviewPage() } )
                case .appAppearance:
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
        if Network.shared.loggedIn {
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
        } else {
            vc.navigationController?.pushViewController(CreateAccountVC(), animated: true)
        }
        
    }
    
    private static func changeAppearanceAction() {
        guard let vc = UIApplication.topMostViewController else { return }
        vc.appActionSheet(buttons: [
            AppAction(title: "System (default)", action: { UIDevice.setSystemAppearance(standard: true) } ),
            AppAction(title: "Dark mode", action: { UIDevice.setSystemAppearance(dark: true) } ),
            AppAction(title: "Light mode", action: { UIDevice.setSystemAppearance(light: true) })
        ])
    }
    
    private static func profileImageAction() {
        guard let vc = UIApplication.topMostViewController?.navigationController else { return }
        let selector = ProfileImageSelectorVC()
        vc.pushViewController(selector, animated: true)
    }
    
    private static func phoneNumberAction() {
        guard let vc = UIApplication.topMostViewController else { return }
        let hasPhoneNumber = Network.shared.account?.phone != nil

        if hasPhoneNumber {
            vc.appActionSheet(buttons: [
                AppAction(title: "Change phone number", action: { showEnterPhoneNumber(on: vc) }),
                AppAction(title: "Delete phone number", action: {
                    vc.appAlert(title: "Are you sure you want to remove your phone number?", message: "This will not remove your friends.", buttons: [
                        ("Cancel", nil),
                        ("Remove", { Manager.shared.phoneFound(string: nil) } )
                    ])
                }),
            ])
        } else {
            showEnterPhoneNumber(on: vc)
        }
    }
    
    private static func showEnterPhoneNumber(on vc: UIViewController) {
        vc.askForPhoneNumber(delegate: Manager.shared)
    }
    
    private static func friendsAction(mode: GenericTableVC.Mode) {
        guard let vc = UIApplication.topMostViewController?.navigationController else { return }
        let tableVC = GenericTableVC(mode: mode)
        vc.pushViewController(tableVC, animated: true)
    }
    
    private static func showColorPicker() {
        guard let vc = UIApplication.topMostViewController else { return }
        let colorPickerVC = ColorPickerVC(startingColor: UIColor(hex: Network.shared.account?.color), colorPickerDelegate: Manager.shared)
        vc.present(colorPickerVC, animated: true, completion: nil)
    }
}


fileprivate class Manager: EnterValueViewDelegate, ColorPickerDelegate {
    func colorPicker(color: UIColor) {
        let newColorHex = color.toHexString()
        Network.shared.account?.color = newColorHex
        Network.shared.account?.writeToKeychain()
        Network.shared.alterUserPhoneNumberOrColor(changePhone: false, newNumber: nil, newColor: newColorHex, complete: { _ in return })
        
        NotificationCenter.default.post(name: .reloadSettings, object: nil)
        UIApplication.topMostViewController?.showMessage("Account color changed")
    }
    
    func textFound(string: String?) { return }
    func ratingFound(float: Float?) { return }
    
    func phoneFound(string: String?) {
        Network.shared.account?.updatePhone(newPhone: string)
        Network.shared.alterUserPhoneNumberOrColor(changePhone: true, newNumber: string, newColor: nil) { _ in return }
        NotificationCenter.default.post(name: .reloadSettings, object: nil)
    }
    
    private init() {}
    fileprivate static let shared = Manager()
}
