//
//  SliderRatingView.swift
//  restaurants
//
//  Created by Steven Dito on 9/16/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class SliderRatingView: UIView {
    
    private let sliderValueButton = UIButton()
    var sliderView = UISlider()
    var sliderValue: Float? {
        didSet {
            if let value = self.sliderValue {
                self.sliderView.tintColor = value.getColorFromZeroToTen()
                self.sliderValueButton.setTitle("\(sliderValue!)", for: .normal)
            } else {
                self.sliderView.tintColor = Colors.baseSliderColor
                self.sliderView.value = (sliderView.maximumValue + sliderView.minimumValue) / 2.0
                self.sliderValueButton.setTitle(emptySliderValue, for: .normal)
            }
            
        }
    }
    private let emptySliderValue = " --- "
    private var stackView = UIStackView()
    
    init() {
        super.init(frame: .zero)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUp() {
        self.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        stackView.constrainSides(to: self)
        
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 7.5
        
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        sliderView.minimumValue = 0.0
        sliderView.maximumValue = 10.0
        sliderView.value = 5.0
        sliderView.tintColor = Colors.baseSliderColor
        
        sliderView.addTarget(self, action: #selector(sliderViewSelector(sender:)), for: .valueChanged)
        
        let ratingButton = UIButton()
        ratingButton.translatesAutoresizingMaskIntoConstraints = false
        ratingButton.titleLabel?.font = .mediumBold
        ratingButton.setTitle("Rating", for: .normal)
        ratingButton.setTitleColor(.label, for: .normal)
        ratingButton.addTarget(self, action: #selector(sliderValueButtonSelector), for: .touchUpInside)
        
        sliderValueButton.translatesAutoresizingMaskIntoConstraints = false
        sliderValueButton.setTitle(emptySliderValue, for: .normal)
        sliderValueButton.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        sliderValueButton.titleLabel?.adjustsFontSizeToFitWidth = true
        sliderValueButton.titleLabel?.minimumScaleFactor = 0.5
        sliderValueButton.titleLabel?.font = .mediumBold
        sliderValueButton.titleLabel?.textAlignment = .center
        sliderValueButton.setTitleColor(.label, for: .normal)
        sliderValueButton.addTarget(self, action: #selector(sliderValueButtonSelector), for: .touchUpInside)

        stackView.addArrangedSubview(ratingButton)
        stackView.addArrangedSubview(sliderView)
        stackView.addArrangedSubview(sliderValueButton)
//        sliderStackView.widthAnchor.constraint(equalTo: headerStackView.widthAnchor).isActive = true
        
    }
    
    
    @objc private func sliderViewSelector(sender: UISlider) {
        sliderValue = Float(round(10 * sender.value)/10)
    }
    
    @objc private func sliderValueButtonSelector() {
        
        self.findViewController()?.appActionSheet(buttons: [
            AppAction(title: "Clear rating value", action: { [weak self] in self?.sliderValue = nil } )
        ])
        
    }
    
}
