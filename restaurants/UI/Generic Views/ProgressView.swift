//
//  ProgressView.swift
//  restaurants
//
//  Created by Steven Dito on 9/1/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


protocol ProgressViewDelegate: class {
    func endAnimationComplete()
}


class ProgressView: UIView {
    
    private let progressTrackerView = UIProgressView(progressViewStyle: .default)
    private let label = UILabel()
    private var timer: Timer?
    private var stackView: UIStackView!
    private let initialCornerRadius: CGFloat = 5.0
    private weak var delegate: ProgressViewDelegate?
    var progress: Float = 0.0
    
    init(delegate: ProgressViewDelegate) {
        super.init(frame: .zero)
        self.delegate = delegate
        setUpElements()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    private func setUpElements() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = 10.0
        
        label.translatesAutoresizingMaskIntoConstraints = false
        stackView = UIStackView(arrangedSubviews: [progressTrackerView, label])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10.0
        self.addSubview(stackView)
        
        label.text = "Uploading"
        label.font = .mediumBold
        
        progressTrackerView.translatesAutoresizingMaskIntoConstraints = false
        progressTrackerView.progressViewStyle = .bar
        progressTrackerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.7).isActive = true
        progressTrackerView.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        progressTrackerView.setProgress(0.0, animated: false)
        progressTrackerView.progressTintColor = Colors.main
        progressTrackerView.clipsToBounds = true
        progressTrackerView.layer.cornerRadius = initialCornerRadius
        progressTrackerView.backgroundColor = .systemGray
        
        stackView.constrainSides(to: self, distance: 20.0)
        
    }
    
    func updateProgress(to progress: Float) {
        
        if progress > 0.99 {
            self.progressTrackerView.setProgress(progress, animated: false)
            progressTrackerView.tintColor = .systemGreen
        } else {
            self.progressTrackerView.setProgress(progress, animated: true)
        }
    }
    
    func failureAnimation() {
        
        progressTrackerView.progressTintColor = .systemRed
        label.textColor = .systemRed
        label.text = "Upload failed"
        
        if let vc = self.findViewController() as? ShowViewVC {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                vc.removeAnimatedSelector()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.findViewController()?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func successAnimation() {
        
        let duration = 0.3
        let borderWidth: CGFloat = 1.0
        progressTrackerView.alpha = 0.0
        let originFrame = stackView.convert(progressTrackerView.frame, to: self)
        let layerView = UIView(frame: originFrame)
        layerView.translatesAutoresizingMaskIntoConstraints = false
        layerView.backgroundColor = .systemGreen
        layerView.layer.cornerRadius = initialCornerRadius
        layerView.layer.borderColor = UIColor.systemGreen.cgColor
        layerView.layer.borderWidth = borderWidth
        self.addSubview(layerView)
        let newFrameHeight = stackView.frame.height
        
        progressTrackerView.progressTintColor = .systemGreen
        label.textColor = .systemGreen
        label.text = "Upload complete"
        
        let firstInitial = duration * 0.7
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.7, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: firstInitial/duration) {
                layerView.frame.size.height = newFrameHeight
                layerView.frame.size.width = newFrameHeight
                layerView.center.x = self.stackView.center.x
                layerView.layer.cornerRadius = newFrameHeight / 2.0
                self.label.alpha = 0.0
                self.backgroundColor = .clear
            }
            
            UIView.addKeyframe(withRelativeStartTime: firstInitial/duration, relativeDuration: (duration - firstInitial)/duration) {
                layerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
            
        }) { (complete) in
            UIDevice.vibrateSuccess()
            if complete {
                let checkMarkView = UIImageView(frame: layerView.frame)
                checkMarkView.image = .checkImage
                checkMarkView.tintColor = UIColor(red: 50.0/255.0, green: 100.0/255.0, blue: 50.0/255.0, alpha: 1.0)
                checkMarkView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.addSubview(checkMarkView)
                
                let initial = duration * 0.5
                
                UIView.animateKeyframes(withDuration: duration * 2, delay: 0.0, options: [], animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: initial / duration) {
                        checkMarkView.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
                        layerView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                    }
                    UIView.addKeyframe(withRelativeStartTime: initial/duration, relativeDuration: (duration - initial)/duration) {
                        checkMarkView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                        layerView.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
                    }
                    
                }) { (done) in
                    UIView.animate(withDuration: 0.3, delay: 0.5, animations: {
                        layerView.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
                        checkMarkView.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
                        layerView.alpha = 0.0
                        checkMarkView.alpha = 0.0
                    }, completion: { (done) in
                        self.delegate?.endAnimationComplete()
                    })
                }
                
            }
        }
        
    }
    
    
}
