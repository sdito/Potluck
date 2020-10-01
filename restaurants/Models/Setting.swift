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
    case privacy = "Privacy"; #warning("contacts in this section")
    
    private typealias RV = Row.Value
    
    var rows: [Row] {
        switch self {
        case .account:
            if Network.shared.loggedIn {
                return [RV.logout.instance, RV.phoneNumber.instance, RV.friends.instance]
            } else {
                return [RV.logout.instance]
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
        
        enum Value {
            case logout
            case phoneNumber
            case friends
            case hapticFeedback
            case locationEnabled
            case photosEnabled
            case contactsEnabled
            case reviewApp
            case appAppearance
            
            var instance: Row {
                switch self {
                case .logout:
                    return Row(title: "Logout",
                               description: "",
                               mode: .arrowOpen,
                               subtitle: Network.shared.account?.username ?? "Log in",
                               pressAction: { logoutAction() } )
                case .phoneNumber:
                    return Row(title: "Phone number",
                               description: "Your phone number is used to help you find your fiends on the app. It is optional to include your phone number.",
                               mode: .arrowOpen,
                               subtitle: Network.shared.account?.phone ?? "None",
                               pressAction: { phoneNumberAction() })
                case .friends:
                    return Row(title: "Friends",
                               description: "Friends allow you to see their posts and vice versa.",
                               mode: .arrowOpen,
                               subtitle: nil,
                               pressAction: { friendsAction() })
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
        let editTextView = EnterValueView(text: "Enter phone number", placeholder: nil, controller: nil, delegate: Manager.shared, mode: .phone)
        let showViewVC = ShowViewVC(newView: editTextView, mode: .middle)
        editTextView.controller = showViewVC
        showViewVC.modalPresentationStyle = .overFullScreen
        vc.present(showViewVC, animated: false, completion: nil)
    }
    
    private static func friendsAction() {
        guard let vc = UIApplication.topMostViewController?.navigationController else { fatalError() }
        print("Friends action started")
        let tableVC = GenericTableVC(mode: .friends)
        vc.pushViewController(tableVC, animated: true)
    }
    
}


fileprivate class Manager: EnterValueViewDelegate {
    func textFound(string: String?) { return }
    func ratingFound(float: Float?) { return }
    
    func phoneFound(string: String?) {
        Network.shared.account?.updatePhone(newPhone: string)
        Network.shared.alterUserPhoneNumber(newNumber: string) { (done) in
            print("Alter users phone number succeeded: \(done)")
        }
        NotificationCenter.default.post(name: .reloadSettings, object: nil)
    }
    
    private init() {}
    fileprivate static let shared = Manager()
}
