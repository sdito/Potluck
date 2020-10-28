//
//  ShowViewVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/30/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

protocol ViewSpecificAnimation: class {
    func start(duration: TimeInterval)
}

class ShowViewVC: UIViewController {
    
    private var newView: UIView
    private var travelDistance: CGFloat = 0.0
    private var mode = Mode.middle
    private let fromTopConstant: CGFloat = 50.0
    private let fromBottomDistance: CGFloat = 22.5
    private var allowScreenPressToDismiss = true
    private var alphaValue: CGFloat = 0.5
    private var viewSpecificAnimation: ViewSpecificAnimation?
    
    init(newView: UIView, mode: Mode, allowScreenPressToDismiss: Bool = true, alphaValue: CGFloat = 0.5, viewSpecificAnimation: ViewSpecificAnimation? = nil) {
        self.newView = newView
        self.mode = mode
        self.allowScreenPressToDismiss = allowScreenPressToDismiss
        self.alphaValue = alphaValue
        self.viewSpecificAnimation = viewSpecificAnimation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.newView = UIView()
        super.init(coder: coder)
    }
    
    enum Mode {
        case top
        case middle
        case bottom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        addCancelButton()
        add(newView: newView)
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch mode {
        case .top:
            topAnimation()
        case .middle:
            middleOrBottomAnimation()
        case .bottom:
            middleOrBottomAnimation()
        }
        
    }
    
    private func topAnimation() {
        let duration = TimeInterval(exactly: 0.2)!
        viewSpecificAnimation?.start(duration: duration)
        UIView.animate(withDuration: duration) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(self.alphaValue)
            self.newView.transform = CGAffineTransform.identity
        }
    }
    
    private func middleOrBottomAnimation() {
        let duration = TimeInterval(exactly: 0.5)!
        viewSpecificAnimation?.start(duration: duration)
        let firstDuration = duration * 0.6
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: duration) {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(self.alphaValue)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: firstDuration/duration) {
                self.newView.transform = CGAffineTransform(translationX: 0, y: -22.5)
            }
            
            UIView.addKeyframe(withRelativeStartTime: firstDuration/duration, relativeDuration: (duration - firstDuration)/duration) {
                self.newView.transform = CGAffineTransform.identity
            }
        })
    }
    
    
    
    private func addCancelButton() {
        let cancelButton = UIButton()
        self.view.insertSubview(cancelButton, at: 1)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.constrainSides(to: self.view)
        if allowScreenPressToDismiss {
            cancelButton.addTarget(self, action: #selector(removeAnimatedSelectorDone), for: .touchUpInside)
        }
        cancelButton.setTitleColor(.black, for: .normal)
    }
    
    private func add(newView: UIView) {
        self.view.insertSubview(newView, at: 2)
        
        newView.layoutIfNeeded()
        
        let newViewHeight = newView.frame.height
        let screenHeight = UIScreen.main.bounds.height
        
        travelDistance = screenHeight / 2.0 + newViewHeight / 2.0
        
        switch mode {
        case .top:
            newView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            newView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: fromTopConstant).isActive = true
            newView.transform = CGAffineTransform(translationX: 0, y: -(fromTopConstant + newViewHeight))
        case .middle:
            newView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            newView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            newView.transform = CGAffineTransform(translationX: 0, y: travelDistance)
        case .bottom:
            newView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            newView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -fromBottomDistance).isActive = true
            newView.transform = CGAffineTransform(translationX: 0, y: fromTopConstant + newViewHeight)
        }
        
    }
    
    
    @objc private func removeAnimatedSelectorDone() {
        animateSelectorWithCompletion(completion: { _ in return })
    }
    
    func animateSelectorWithCompletion(completion: @escaping (Bool) -> Void) {
        switch mode {
        case .top:
            UIView.animate(withDuration: 0.3, animations: {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                self.newView.transform = CGAffineTransform(translationX: 0, y: -(self.fromTopConstant + self.newView.frame.height))
            }) { (done) in
                self.dismiss(animated: false, completion: nil)
                completion(true)
            }
        case .middle:
            UIView.animate(withDuration: 0.3, animations: {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                self.newView.transform = CGAffineTransform(translationX: 0, y: self.travelDistance)
            }) { (done) in
                self.dismiss(animated: false, completion: nil)
                completion(true)
            }
        case .bottom:
            UIView.animate(withDuration: 0.3, animations: {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                self.newView.transform = CGAffineTransform(translationX: 0, y: self.fromBottomDistance + self.newView.frame.height)
            }) { (done) in
                self.dismiss(animated: false, completion: nil)
                completion(true)
            }
        }
    }
    
    func removeFromSuperviewTop(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                self.newView.transform = CGAffineTransform(translationX: 0, y: -(self.fromTopConstant + self.newView.frame.height))
            }) { (done) in
                self.dismiss(animated: false, completion: nil)
                if done {
                    completion(true)
                }
            }
        }
    }
    
    func removeFromSuperviewAlert(completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.newView.transform = CGAffineTransform(translationX: 0, y: self.travelDistance)
        }) { (done) in
            self.dismiss(animated: false, completion: nil)
            if done {
                completion(true)
            }
        }
    }
    
    func removeFromSuperviewActionSheet(completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.newView.transform = CGAffineTransform(translationX: 0, y: self.fromBottomDistance + self.newView.frame.height)
        }) { (done) in
            self.dismiss(animated: false, completion: nil)
            if done {
                completion(true)
            }
        }
    }
    
    func showNextViewFromSide(nextView: UIView) {
        // make sure nothing else gets pressed
        newView.isUserInteractionEnabled = false
        
        // add it to the view to the right
        self.view.addSubview(nextView)
        nextView.layoutIfNeeded()
        
        switch mode {
        case .bottom:
            nextView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            nextView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -fromBottomDistance).isActive = true
            nextView.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
        default:
            fatalError(); #warning("would need to complete")
        }
        
        UIView.animate(withDuration: 0.4) {
            nextView.transform = CGAffineTransform(translationX: -12.5, y: 0)
            self.newView.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0)
        } completion: { (done) in
            if done {
                UIView.animate(withDuration: 0.2) {
                    nextView.transform = .identity
                } completion: { (done) in
                    self.newView = nextView
                }
            }
        }
    }

}
