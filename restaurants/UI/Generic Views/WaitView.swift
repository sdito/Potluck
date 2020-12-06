//
//  WaitView.swift
//  restaurants
//
//  Created by Steven Dito on 10/2/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class WaitView: UIView {
    
    private let loaderView = LoaderView(style: .large)
    private let stackView = UIStackView()
    var controller: ShowViewVC?
    
    init() {
        super.init(frame: .zero)
        setUpBase()
        setUpStackView()
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
        self.addSubview(stackView)
        stackView.constrainSides(to: self, distance: 20.0)
    }
    
    
    func doneLoading(complete: @escaping (Bool) -> Void) {
        //controller?.animateSelectorWithCompletion()
        controller?.animateSelectorWithCompletion(completion: { (done) in
            complete(done)
        })
    }

}
