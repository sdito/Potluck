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
    private let loaderView = LoaderView(style: .large)
    private let button = UIButton()
    private let stackView = UIStackView()
    var controller: ShowViewVC?
    
    init() {
        super.init(frame: .zero)
        setUpBase()
        setUpStackView()
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
        stackView.addArrangedSubview(loaderView)
        stackView.addArrangedSubview(button)
        self.addSubview(stackView)
        stackView.constrainSides(to: self, distance: 20.0)
    }
    
    
    private func setUpButton() {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.systemRed, for: .normal)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = .smallBold
        button.layoutIfNeeded()
        button.isHidden = true
    }
    
    private func setUpToAllowCancelling() {
        button.isHidden = true
        stackView.addArrangedSubview(button)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            UIView.animate(withDuration: 0.4) { [weak self] in
                self?.button.isHidden = false
                self?.stackView.layoutIfNeeded()
            }
        }
    }
    
    func doneLoading() {
        controller?.removeAnimatedSelectorDone()
    }

}
