//
//  SubmitRestaurantVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/18/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


class SubmitRestaurantVC: UIViewController {
    
    
    
    private let containerView = UIView()
    private var name: String!
    private var address: String!
    
    init(name: String, address: String) {
        self.name = name
        self.address = address
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUp()
        setUpChildView()
        setUpImageSelector()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setUp() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "\(name!) \(address!)"
        self.view.addSubview(label)
        label.constrain(.leading, to: view, .leading)
        label.constrain(.trailing, to: view, .trailing)
        label.constrain(.top, to: view, .top, constant: self.navigationController?.navigationBar.bounds.height ?? 0.0)
    }
    
    private func setUpChildView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerView)
        containerView.backgroundColor = .flatOrange
        containerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.7).isActive = true
        containerView.constrain(.bottom, to: self.view, .bottom)
        containerView.constrain(.leading, to: self.view, .leading)
        containerView.constrain(.trailing, to: self.view, .trailing)
    }
    
    private func setUpImageSelector() {
        let vc = ImageSelectorVC()
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(vc)
        containerView.addSubview(vc.view)
        vc.view.constrainSides(to: containerView)
        vc.didMove(toParent: self)
        vc.delegate = self
    }
    
    
    
}


extension SubmitRestaurantVC: ImageSelectorDelegate {
    
    
}
