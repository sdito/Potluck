//
//  ProgressView.swift
//  restaurants
//
//  Created by Steven Dito on 9/1/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    
    private let progressTrackerView = UIProgressView(progressViewStyle: .default)
    private let label = UILabel()
    private var timer: Timer?
    private var stackView: UIStackView!
    private let initialCornerRadius: CGFloat = 5.0
    var progress: Float = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        
        setUpTimer()
    }
    
    func updateProgress(to progress: Float) {
        self.progressTrackerView.setProgress(progress, animated: true)
        if progress > 0.99 {
            progressTrackerView.tintColor = .systemGreen
        }
    }
    
    func setUpTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerRunner), userInfo: nil, repeats: true)
    }
    
    func animationComplete() {
        let duration = 0.4
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
            if complete {
                let checkMarkView = UIImageView(frame: layerView.frame)
                checkMarkView.image = .checkImage
                checkMarkView.tintColor = UIColor(red: 50.0/255.0, green: 100.0/255.0, blue: 50.0/255.0, alpha: 1.0)
                checkMarkView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.addSubview(checkMarkView)
                
                let initial = duration * 0.5
                UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: [], animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: initial / duration) {
                        checkMarkView.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
                        layerView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                    }
                    UIView.addKeyframe(withRelativeStartTime: initial/duration, relativeDuration: (duration - initial)/duration) {
                        checkMarkView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                        layerView.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
                    }
                    
                }) { (done) in
                    if done {
                        print("Everything is done")
                    }
                }
                
            }
        }
        
    }
    
    @objc private func timerRunner() {
        progress += 0.1
        updateProgress(to: progress)
        if progress > 1.0 {
            timer?.invalidate()
            animationComplete()
        }
    }
    
}
