//
//  HeaderDetailView.swift
//  restaurants
//
//  Created by Steven Dito on 7/12/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


protocol HeaderDetailViewDelegate: class {
    func urlPressedToOpen()
    func moreInfoOnHeaderPressed()
    func callRestaurant()
    func visitRestaurant()
}


class HeaderDetailView: UIView {
    
    private weak var delegate: HeaderDetailViewDelegate!
    var timeOpenLabel = UILabel()
    var inside = UIView()
    var container = UIView()
    var newSV = UIStackView()
    var restaurant: Restaurant!
    
    init(restaurant: Restaurant, vc: UIViewController) {
        super.init(frame: .zero)
        self.restaurant = restaurant
        setUp(vc: vc)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUp(vc: UIViewController) {
        self.delegate = vc as? HeaderDetailViewDelegate
        self.translatesAutoresizingMaskIntoConstraints = false
        
        setUpContainers()
        setUpOuterStackView()
        setUpTopScrollingAndButton()
        setUpTimeOpenLabel()
        setUpActionButtons()
        
        container.layer.cornerRadius = 6.0
        inside.layer.cornerRadius = 5.0
        inside.clipsToBounds = true
        inside.backgroundColor = .secondarySystemBackground

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.inside.layer.borderWidth = 1.0
            self.inside.layer.borderColor = Colors.secondary.cgColor
        }
    }
    
    private func setUpContainers() {
        self.backgroundColor = .systemBackground
        container.backgroundColor = .secondarySystemBackground
        container.translatesAutoresizingMaskIntoConstraints = false
        inside.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(container)
        container.addSubview(inside)
        container.constrainSides(to: self, distance: 10.0)
        inside.constrainSides(to: container, distance: 6.0)
    }
    
    private func setUpOuterStackView() {
        newSV.translatesAutoresizingMaskIntoConstraints = false
        newSV.axis = .vertical
        newSV.spacing = 17.5
        newSV.alignment = .leading

        inside.addSubview(newSV)
        newSV.constrainSides(to: inside, distance: 10.0)
    }
    
    private func setUpTopScrollingAndButton() {
        let disclosureButton = UIButton(type: .detailDisclosure)
        disclosureButton.tintColor = Colors.main
        disclosureButton.addTarget(self, action: #selector(moreInfoOnHeaderPressedSelector), for: .touchUpInside)
        let categories = restaurant.categories ?? ["Restaurant"]
        let viewsToAdd = categories.createViewsForDisplay()
        let scrollingView = ScrollingStackView(subViews: viewsToAdd)
        
        let topStackView = UIStackView(arrangedSubviews: [scrollingView, UIView(), disclosureButton])
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        topStackView.spacing = 10.0
        topStackView.axis = .horizontal
        topStackView.distribution = .fill
        newSV.addArrangedSubview(topStackView)
        topStackView.widthAnchor.constraint(equalTo: newSV.widthAnchor).isActive = true
        
    }
    
    private func setUpTimeOpenLabel() {
        timeOpenLabel.font = .mediumBold
        timeOpenLabel.text = " "
        newSV.addArrangedSubview(timeOpenLabel)
    }
    
    private func setUpActionButtons() {
        let buttonsSV = UIStackView()
        buttonsSV.axis = .horizontal
        buttonsSV.spacing = 15.0
        buttonsSV.distribution = .fillEqually
        buttonsSV.alignment = .center

        let webButton = TwoLevelButton(text: "Web", imageText: "desktopcomputer")
        webButton.addTarget(self, action: #selector(openWebForUrl), for: .touchUpInside)
        buttonsSV.addArrangedSubview(webButton)
        
        let callButton = TwoLevelButton(text: "Call", imageText: "phone")
        callButton.addTarget(self, action: #selector(callRestaurantPressed), for: .touchUpInside)
        buttonsSV.addArrangedSubview(callButton)
        
        let visitButton = TwoLevelButton(text: "Visit", imageText: "plus.square.on.square")
        visitButton.addTarget(self, action: #selector(visitButtonSelector), for: .touchUpInside)
        buttonsSV.addArrangedSubview(visitButton)
        
        newSV.addArrangedSubview(buttonsSV)
        buttonsSV.widthAnchor.constraint(equalTo: newSV.widthAnchor).isActive = true
    }
    
    @objc private func openWebForUrl() {
        delegate.urlPressedToOpen()
    }
    
    @objc private func moreInfoOnHeaderPressedSelector() {
        delegate.moreInfoOnHeaderPressed()
    }
    
    @objc private func callRestaurantPressed() {
        delegate.callRestaurant()
    }
    
    @objc private func visitButtonSelector() {
        delegate.visitRestaurant()
    }

}

