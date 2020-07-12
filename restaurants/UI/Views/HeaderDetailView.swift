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
}


class HeaderDetailView: UIView {
    
    private weak var delegate: HeaderDetailViewDelegate!
    var timeOpenLabel: UILabel!
    
    init(restaurant: Restaurant, vc: UIViewController) {
        super.init(frame: .zero)
        setUp(restaurant: restaurant, vc: vc)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUp(restaurant: Restaurant, vc: UIViewController) {
        print("Being set up")
        self.delegate = vc as? HeaderDetailViewDelegate
        self.translatesAutoresizingMaskIntoConstraints = false
        let container = UIView()
        let inside = UIView()
        self.backgroundColor = .systemBackground
        container.backgroundColor = .secondarySystemBackground
        container.translatesAutoresizingMaskIntoConstraints = false
        inside.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(container)
        container.addSubview(inside)
        container.constrainSides(to: self, distance: 10.0)
        inside.constrainSides(to: container, distance: 6.0)

        let newSV = UIStackView()
        newSV.translatesAutoresizingMaskIntoConstraints = false
        newSV.axis = .vertical
        newSV.spacing = 17.5
        newSV.alignment = .leading

        inside.addSubview(newSV)
        newSV.constrainSides(to: inside, distance: 10.0)

        let viewsToAdd = restaurant.categories.createViewsForDisplay()
        let scrollingView = ScrollingStackView(subViews: viewsToAdd)
        newSV.addArrangedSubview(scrollingView)
        scrollingView.widthAnchor.constraint(equalTo: newSV.widthAnchor).isActive = true

        timeOpenLabel = UILabel()
        timeOpenLabel.font = .mediumBold
        timeOpenLabel.text = " "
        newSV.addArrangedSubview(timeOpenLabel)

        let buttonsSV = UIStackView()
        buttonsSV.axis = .horizontal
        buttonsSV.spacing = 15.0
        buttonsSV.distribution = .fillEqually
        buttonsSV.alignment = .center

        let webButton = TwoLevelButton(text: "Web", imageText: "desktopcomputer")
        webButton.addTarget(self, action: #selector(openWebForUrl), for: .touchUpInside)

        buttonsSV.addArrangedSubview(webButton)
        buttonsSV.addArrangedSubview(TwoLevelButton(text: "Call", imageText: "phone"))
        buttonsSV.addArrangedSubview(TwoLevelButton(text: "Menu", imageText: "book"))

        newSV.addArrangedSubview(buttonsSV)
        buttonsSV.widthAnchor.constraint(equalTo: newSV.widthAnchor).isActive = true

        container.layer.cornerRadius = 6.0
        inside.layer.cornerRadius = 5.0
        inside.clipsToBounds = true
        inside.backgroundColor = .secondarySystemBackground

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            inside.layer.borderWidth = 1.0
            inside.layer.borderColor = Colors.secondary.cgColor
        }

    }
    
    @objc private func openWebForUrl() {
        delegate.urlPressedToOpen()
    }

}

