//
//  SubmitRestaurantVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/18/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


class SubmitRestaurantVC: UIViewController {

    private var allowChanges = true
    private var previousScrollOffset: CGFloat = .zero
    private var containerViewHeightAnchor: NSLayoutConstraint!
    private var containerViewBaseHeight: CGFloat!
    private var maxHeight: CGFloat!
    
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
        setUpLabels()
        setUpChildView()
        setUpImageSelector()
        findAssociatedRestaurant()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setUpLabels() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "\(name!) \(address!)"
        self.view.addSubview(label)
        label.constrain(.leading, to: view, .leading)
        label.constrain(.trailing, to: view, .trailing)
        label.constrain(.top, to: view, .top)
        
        let map = MapLocationView(locationTitle: name, coordinate: .simulatorDefault, address: nil)
        self.view.addSubview(map)
        map.constrain(.top, to: label, .bottom)
        map.constrain(.leading, to: self.view, .leading)
        map.constrain(.trailing, to: self.view, .trailing)
        map.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
    }
    
    private func setUpChildView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerView)
        containerViewBaseHeight = self.view.bounds.height * 0.45
        maxHeight = self.view.bounds.height * 0.75
        containerViewHeightAnchor = containerView.heightAnchor.constraint(equalToConstant: containerViewBaseHeight!)
        containerViewHeightAnchor?.isActive = true
        containerView.constrain(.bottom, to: self.view, .bottom)
        containerView.constrain(.leading, to: self.view, .leading)
        containerView.constrain(.trailing, to: self.view, .trailing)
        containerView.backgroundColor = .tertiarySystemBackground
        
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
    
    private func findAssociatedRestaurant() {
        Network.shared.getRestaurantFromPartialData(name: name, fullAddress: address) { (result) in
            print(result)
        }
    }
}


extension SubmitRestaurantVC: ImageSelectorDelegate {
    
    func scrollViewContentOffset(scrollView: UIScrollView) {
        if allowChanges {
            let scrollingMultiplier: CGFloat = 1.5
            let scrollDiff = (scrollView.contentOffset.y - self.previousScrollOffset) * scrollingMultiplier
            let absoluteTop: CGFloat = 0
            let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
            let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
            let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
            var newHeight = self.containerViewHeightAnchor.constant
            if isScrollingDown {
                newHeight = min(self.maxHeight, self.containerViewHeightAnchor.constant + abs(scrollDiff))
            } else if isScrollingUp {
                newHeight = max(self.containerViewBaseHeight, self.containerViewHeightAnchor.constant - abs(scrollDiff))
            }
            if newHeight != self.containerViewHeightAnchor.constant {
                allowChanges = false
                
                if isScrollingDown {
                    let difference = newHeight - self.containerViewHeightAnchor.constant
                    scrollView.contentOffset.y -= difference
                    self.containerViewHeightAnchor.constant = newHeight
                } else if isScrollingUp {
                    if scrollView.contentOffset.y < 10.0 {
                        self.containerViewHeightAnchor.constant = newHeight
                    }
                }
                allowChanges = true
            }
            previousScrollOffset = scrollView.contentOffset.y
        }
    }
    
    func photosUpdated(to selectedPhotos: [ImageSelectorVC.ImageInfo]) {
        print(selectedPhotos.map({$0.indexPath.row}))
        #warning("need to use")
    }
}
