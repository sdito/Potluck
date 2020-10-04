//
//  LoadingView.swift
//  restaurants
//
//  Created by Steven Dito on 10/2/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    #warning("actually use when deployed")
    private let activityView = UIActivityIndicatorView(style: .large)
    private let label = UILabel()
    private let button = UIButton()
    private let stackView = UIStackView()
    var controller: ShowViewVC?
    
    init() {
        super.init(frame: .zero)
        setUpBase()
        setUpStackView()
        setUpActivityView()
        setUpLabel()
        setUpButton()
        setUpToAllowCancelling()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpBase() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = 10.0
    }
    
    private func setUpStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 10.0
        stackView.addArrangedSubview(activityView)
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(button)
        self.addSubview(stackView)
        stackView.constrainSides(to: self, distance: 20.0)
    }
    
    private func setUpActivityView() {
        activityView.startAnimating()
    }
    
    private func setUpLabel() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "LOADING"
        label.font = .mediumBold
    }
    
    private func setUpButton() {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.systemRed, for: .normal)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = .smallBold
        button.isHidden = true
    }
    
    private func setUpToAllowCancelling() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            UIView.animate(withDuration: 0.4) { [weak self] in
                self?.button.isHidden = false
            }
        }
    }
    
    func doneLoading() {
        controller?.removeAnimatedSelectorDone()
    }

}
