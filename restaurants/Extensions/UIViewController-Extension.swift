//
//  UIViewController-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 6/27/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import SafariServices

extension UIViewController {
    
    func updateNavigationItemTitle(to string: String) {
        let fadeTextAnimation = CATransition()
        fadeTextAnimation.duration = 0.2
        fadeTextAnimation.type = .fade
        self.navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "fadeText")
        self.navigationItem.title = string
    }
    
    func showMapDetail(locationTitle: String, coordinate: CLLocationCoordinate2D?, address: String?) {
        let sideSize = UIScreen.main.bounds.width * 0.8
        let size = CGSize(width: sideSize, height: sideSize)
        let mapLocationView = MapLocationView(estimatedSize: size, locationTitle: locationTitle, coordinate: coordinate, address: address)
        mapLocationView.equalSides(size: sideSize)
        mapLocationView.layer.cornerRadius = 25.0
        mapLocationView.clipsToBounds = true
        
        let newVc = ShowViewVC(newView: mapLocationView, mode: .middle)
        newVc.modalPresentationStyle = .overFullScreen
        self.present(newVc, animated: false, completion: nil)
    }
    
    func openLink(url: String) {
        guard let link = URL(string: url) else { return }
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let vc = SFSafariViewController(url: link, configuration: config)
        vc.preferredControlTintColor = Colors.main
        self.present(vc, animated: true, completion: nil)
    }
    
    var visibleViewController: UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.visibleViewController
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.visibleViewController
        } else if let presentedViewController = presentedViewController {
            return presentedViewController.visibleViewController
        } else {
            return self
        }
    }
    
    func showTagSelectorView(tags: [Tag]?, selectedTags: [Tag]?, loadUsersTagsInstead: Bool = false, tagSelectorViewDelegate: TagSelectorViewDelegate) {
        let tagSelectorView = TagSelectorView(tags: tags, selectedTags: selectedTags, loadUsersTagsInstead: loadUsersTagsInstead, tagSelectorViewDelegate: tagSelectorViewDelegate)
        let vc = ShowViewVC(newView: tagSelectorView, mode: .middle, allowScreenPressToDismiss: true)
        vc.modalPresentationStyle = .overFullScreen
        tagSelectorView.showViewVC = vc
        self.present(vc, animated: false, completion: nil)
    }
    
    func appAlert(title: String?, message: String?, buttons: [AlertView.ButtonAction]?) {
        let alertView = AlertView(title: title, message: message, buttons: buttons)
        let vc = ShowViewVC(newView: alertView, mode: .middle, allowScreenPressToDismiss: false)
        alertView.showViewVC = vc
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    func appActionSheet(buttons: [ActionSheetView.ButtonAction]) {
        let actionSheetView = ActionSheetView(buttons: buttons)
        let vc = ShowViewVC(newView: actionSheetView, mode: .bottom, allowScreenPressToDismiss: true, alphaValue: 0.7, viewSpecificAnimation: actionSheetView)
        actionSheetView.showViewVC = vc
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    func askForPhoneNumber(delegate: EnterValueViewDelegate) {
        let editTextView = EnterValueView(text: "Enter phone number", placeholder: nil, controller: nil, delegate: delegate, mode: .phone)
        let showViewVC = ShowViewVC(newView: editTextView, mode: .middle)
        editTextView.controller = showViewVC
        showViewVC.modalPresentationStyle = .overFullScreen
        self.present(showViewVC, animated: false, completion: nil)
    }
    
    func getNumberFromUser(delegate: EnterValueViewDelegate) {
        let enterValueView = EnterValueView(text: "Enter number", placeholder: nil, controller: nil, delegate: delegate, mode: .number)
        let showViewVC = ShowViewVC(newView: enterValueView, mode: .middle)
        enterValueView.controller = showViewVC
        showViewVC.modalPresentationStyle = .overFullScreen
        self.present(showViewVC, animated: false, completion: nil)
    }
    
    func showLoadingView() -> WaitView {
        let loadingView = WaitView()
        let showViewVC = ShowViewVC(newView: loadingView, mode: .top, allowScreenPressToDismiss: false)
        loadingView.controller = showViewVC
        showViewVC.modalPresentationStyle = .overFullScreen
        self.present(showViewVC, animated: false, completion: nil)
        return loadingView
    }
    
    func showAddingChildFromBottom(child: UIViewController, childHeight: CGFloat) {
        child.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(child)
        self.view.addSubview(child.view)
        child.view.constrain(.leading, to: self.view, .leading)
        child.view.constrain(.trailing, to: self.view, .trailing)
        child.view.constrain(.bottom, to: self.view, .bottom)
        
        child.view.frame.size.height = childHeight
        child.didMove(toParent: self)
        
        child.view.transform = CGAffineTransform(translationX: 0, y: childHeight)
        
        UIView.animate(withDuration: 0.3) {
            child.view.transform = .identity
        }
    }
    
    func removeChildViewControllersFromBottomOf<T>(typeToRemove: T, onCompletion: @escaping (Bool) -> Void) {
        for vc in self.children {
            if type(of: vc).isEqual(typeToRemove) {
                print("Removing child...")
                let height = vc.view.bounds.height
                UIView.animate(withDuration: 0.3, animations: {
                    vc.view.transform = CGAffineTransform(translationX: 0, y: height)
                }) { (complete) in
                    if complete {
                        vc.willMove(toParent: nil)
                        vc.view.removeFromSuperview()
                        vc.removeFromParent()
                        onCompletion(true)
                    }
                }
            } else {
                print("Isn't remove child...")
            }
        }
    }
    
    func presentAddRestaurantVC() {
        if Network.shared.loggedIn {
            let baseVC = AddRestaurantVC()
            let vc = UINavigationController(rootViewController: baseVC)
            vc.modalPresentationStyle = .fullScreen
            
            vc.navigationBar.tintColor = Colors.main
            vc.setNavigationBarColor()
            vc.navigationBar.isTranslucent = false
            
            self.present(vc, animated: true, completion: nil)
        } else {
            userNotLoggedInAlert(tabVC: nil)
        }
        
    }
    
    func showMessage(_ string: String, lastsFor: Double = 3.0, on presentingVC: UIViewController? = nil) {
        let upAndDownDuration = 0.125
        let duration = (upAndDownDuration * 2) + lastsFor
        let beginningScale: CGFloat = 0.3

        let vc = presentingVC ?? UIApplication.shared.windows.first!.rootViewController!
        let label = PaddingLabel(top: 10.0, bottom: 10.0, left: 15.0, right: 15.0)
        label.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = string
        label.font = .largerBold
        label.layer.cornerRadius = 5.0
        label.numberOfLines = 0
        label.clipsToBounds = true
        label.textAlignment = .center
        label.alpha = 0.0
        
        vc.view.addSubview(label)
        label.superview?.bringSubviewToFront(label)
        
        label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: vc.view.topAnchor, constant: 0.0).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualTo: vc.view.widthAnchor, multiplier: 0.9).isActive = true
        
        label.transform = CGAffineTransform.identity.scaledBy(x: beginningScale, y: beginningScale)
        label.layoutIfNeeded()
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: upAndDownDuration/duration, animations: {
                label.transform = CGAffineTransform(translationX: 0, y: label.bounds.height + 75.0).scaledBy(x: 1.0, y: 1.0)
                label.alpha = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: (duration - upAndDownDuration) / duration, relativeDuration: upAndDownDuration/duration, animations: {
                label.transform = CGAffineTransform.identity.scaledBy(x: beginningScale, y: beginningScale)
                label.alpha = 0.0
            })
            
        }) { (complete) in
            if complete {
                label.removeFromSuperview()
            }
        }
        
    }
    
    func openMaps(coordinate: CLLocationCoordinate2D, name: String, method: String = "driving") {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = name
        var value: String {
            if method == "driving" {
                return MKLaunchOptionsDirectionsModeDriving
            } else if method == "walk" {
                return MKLaunchOptionsDirectionsModeWalking
            } else if method == "transit" {
                return MKLaunchOptionsDirectionsModeTransit
            } else {
                return MKLaunchOptionsDirectionsModeDefault
            }
        }
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : value])
    }
    
    func setNavigationBarColor(alpha: CGFloat = 1.0) {
        self.traitCollection.performAsCurrent {
            self.navigationController?.navigationBar.shadowImage = UIImage(color: .clear)
            let navView = self.navigationController?.navigationBar.subviews.first
            navView?.alpha = alpha
        }
    }
    
    func userNotLoggedInAlert(tabVC: TabVC?) {
        var buttons: [(String, (() -> ())?)] {
            if let tabVC = tabVC {
                return
                    [("Cancel", nil),
                    ("Log in", {
                    tabVC.selectedIndex = tabVC.getProfileTabIndex()
                    let vc = tabVC.getProfileNavigationController()
                    vc.pushViewController(CreateAccountVC(), animated: true)
                })]
            } else {
                return [("Ok", nil)]
            }
        }
        self.appAlert(title: "Not logged in", message: "In order to add a visit, you either need to log in to an existing account or create a new account.", buttons: buttons)
    }
    
    func getRightBarButtonView() -> UIView? {
        return self.navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView
    }
    
}


