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

extension UIViewController {
    
    func showAddingChildFromBottom(child: UIViewController, childHeight: CGFloat) {
        child.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(child)
        self.view.addSubview(child.view)
        child.view.constrain(.leading, to: self.view, .leading)
        child.view.constrain(.trailing, to: self.view, .trailing)
        child.view.constrain(.bottom, to: self.view, .bottom)
        //child.view.heightAnchor.constraint(equalToConstant: childHeight).isActive = true
        child.view.frame.size.height = childHeight
        child.didMove(toParent: self)
        
        child.view.transform = CGAffineTransform(translationX: 0, y: childHeight)
        
        UIView.animate(withDuration: 0.3) {
            child.view.transform = .identity
        }
    }
    
    func removeChildViewControllersFromBottom(onCompletion: @escaping (Bool) -> Void) {
        for vc in self.children {
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
        }
    }
    
    func presentAddRestaurantVC() {
        let baseVC = AddRestaurantVC()
        let vc = UINavigationController(rootViewController: baseVC)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
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
    
    
    // MARK: Alerts
    func alert(title: String, message: String, button: String = "Ok") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: button, style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func alert(title: String, message: String?, negativeButton: String = "Cancel", positiveButton: String = "Ok", positiveAction: @escaping () -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: negativeButton, style: .cancel, handler: nil))
        let action = UIAlertAction(title: positiveButton, style: .default) { (alertAction) in
            positiveAction()
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func actionSheet(title: String? = nil, message: String? = nil, actions: [(title: String, pressed: () -> ())]) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        for action in actions {
            //let act = UIAlertAction(title: action.title, style: .default, handler: action.pressed)
            let act = UIAlertAction(title: action.title, style: .default) { (alertAction) in
                action.pressed()
            }
            actionSheet.addAction(act)
        }
        actionSheet.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true)
        
    }
    
    
    func setNavigationBarColor(color: UIColor) {
        let image = UIImage(color: color)
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        self.navigationController?.navigationBar.shadowImage = image
    }
    
    
    
}


