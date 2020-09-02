//
//  ShowViewVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/30/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class ShowViewVC: UIViewController {
    
    private var newView: UIView
    private var travelDistance: CGFloat = 0.0
    private var fromBottom = true
    private let fromTopConstant: CGFloat = 50.0
    
    init(newView: UIView, fromBottom: Bool) {
        self.newView = newView
        self.fromBottom = fromBottom
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.newView = UIView()
        super.init(coder: coder)
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
        
        if fromBottom {
            fromBottomAnimation()
        } else {
            fromTopAnimation()
        }
        
        
    }
    
    private func fromTopAnimation() {
        let duration = TimeInterval(exactly: 0.2)!
        
        UIView.animate(withDuration: duration) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.newView.transform = CGAffineTransform.identity
        }
    }
    
    private func fromBottomAnimation() {
        
        let duration = TimeInterval(exactly: 0.5)!
        let firstDuration = 0.3
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: duration) {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
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
        cancelButton.addTarget(self, action: #selector(removeAnimatedSelector), for: .touchUpInside)
        cancelButton.setTitleColor(.black, for: .normal)
    }
    
    private func add(newView: UIView) {
        self.view.insertSubview(newView, at: 2)
        
        
        newView.layoutIfNeeded()
        
        let newViewHeight = newView.frame.height
        let screenHeight = UIScreen.main.bounds.height
        
        travelDistance = screenHeight / 2.0 + newViewHeight / 2.0
        
        if fromBottom {
            newView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            newView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            newView.transform = CGAffineTransform(translationX: 0, y: travelDistance)
        } else {
            
            newView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            newView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: fromTopConstant).isActive = true
            newView.transform = CGAffineTransform(translationX: 0, y: -(fromTopConstant + newViewHeight))
        }
        
        
    }
    
    
    @objc func removeAnimatedSelector() {
        
        if fromBottom {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                self.newView.transform = CGAffineTransform(translationX: 0, y: self.travelDistance)
            }) { (true) in
                self.dismiss(animated: false, completion: nil)
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                self.newView.transform = CGAffineTransform(translationX: 0, y: -(self.fromTopConstant + self.newView.frame.height))
            }) { (true) in
                self.dismiss(animated: false, completion: nil)
            }
        }
        
        
    }

}
