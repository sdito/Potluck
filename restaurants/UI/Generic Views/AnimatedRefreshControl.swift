//
//  AnimatedRefreshControl.swift
//  restaurants
//
//  Created by Steven Dito on 10/26/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Lottie

class AnimatedRefreshControl: UIRefreshControl {
    
    fileprivate let animationView = AnimationView(name: "fork_and_spoon_loader")
    fileprivate var isAnimating = false

    fileprivate let maxPullDistance: CGFloat = 150

    override init() {
        super.init(frame: .zero)
        setupView()
        setupLayout()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupView() {
        // to hide default indicator view
        tintColor = .clear
        animationView.loopMode = .loop
        addSubview(animationView)
        addTarget(self, action: #selector(beginRefreshing), for: .valueChanged)
    }

    func setupLayout() {
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: centerYAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 50),
            animationView.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    func updateProgress(with offsetY: CGFloat) {
        guard !isAnimating, offsetY < 0.0 else { return }
        let slowedProgress = offsetY / 3.0
        let progress = min(abs(slowedProgress / maxPullDistance), 1)
        let alphaProgress = min(abs(offsetY / maxPullDistance), 1)
        animationView.currentProgress = progress
        animationView.alpha = alphaProgress
    }

    override func beginRefreshing() {
        super.beginRefreshing()
        isAnimating = true
        animationView.currentProgress = 0
        animationView.play()
    }

    override func endRefreshing() {
        super.endRefreshing()
        animationView.stop()
        isAnimating = false
    }

}
