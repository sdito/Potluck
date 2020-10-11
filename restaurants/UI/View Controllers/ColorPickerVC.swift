//
//  ColorPickerVC.swift
//  restaurants
//
//  Created by Steven Dito on 10/10/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class ColorPickerVC: UIViewController {
    
    private let headerView = HeaderView(leftButtonTitle: "Cancel", rightButtonTitle: "Choose", title: "Pick color")
    private let spacer = SpacerView(size: 2.0, orientation: .vertical)
    private let stackView = UIStackView()
    private let selectedColorView = UIView()
    private var buttonColors: [UIButton] = []
    
    private let redSlider = UISlider()
    private let greenSlider = UISlider()
    private let blueSlider = UISlider()
    
    private let redButton = UIButton()
    private let greenButton = UIButton()
    private let blueButton = UIButton()
    
    private let minimumValue: Float = 0.0
    private let maximumValue: Float = 255.0
    
    private var redValue: CGFloat = 255.0/2.0
    private var greenValue: CGFloat = 255.0/2.0
    private var blueValue: CGFloat = 255.0/2.0
    
    private var currentColor: UIColor? {
        didSet {
            selectedColorView.backgroundColor = currentColor
        }
    }
    private var selectedColorForValueChangeButton: Color?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUpHeaderAndSpacer()
        setUpStackView()
        setUpSelectedColor()
        setUpSliders()
        updateSliderColors()
        setUpColorOptionsTitle()
        setUpColorOptionsGrid()
    }
    
    init(startingColor: UIColor?) {
        super.init(nibName: nil, bundle: nil)
        self.currentColor = startingColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private enum Color: Int, CaseIterable {
        case red = 1
        case green = 2
        case blue = 3
        
        var string: String {
            switch self {
            case .red:
                return "Red"
            case .green:
                return "Green"
            case .blue:
                return "Blue"
            }
        }
    }
    
    private func getButton(color: Color) -> UIButton {
        switch color {
        case .red:
            return redButton
        case .green:
            return greenButton
        case .blue:
            return blueButton
        }
    }
    
    private func getSlider(color: Color) -> UISlider {
        switch color {
        case .red:
            return redSlider
        case .green:
            return greenSlider
        case .blue:
            return blueSlider
        }
    }
    
    private func updateValue(color: Color, value: CGFloat) {
        switch color {
        case .red:
            redValue = value
        case .green:
            greenValue = value
        case .blue:
            blueValue = value
        }
    }
    
    private func updateButton(color: Color, string: String) {
        let button = getButton(color: color)
        button.setTitle(string, for: .normal)
    }
    
    private func setUpHeaderAndSpacer() {
        self.view.addSubview(headerView)
        headerView.constrain(.leading, to: self.view, .leading)
        headerView.constrain(.top, to: self.view, .top, constant: 10.0)
        headerView.constrain(.trailing, to: self.view, .trailing)
        headerView.leftButton.addTarget(self, action: #selector(dismissChild), for: .touchUpInside)
        headerView.rightButton.addTarget(self, action: #selector(chooseColorSelected), for: .touchUpInside)
        
        self.view.addSubview(spacer)
        spacer.constrain(.leading, to: self.view, .leading)
        spacer.constrain(.trailing, to: self.view, .trailing)
        spacer.constrain(.top, to: headerView, .bottom, constant: 5.0)
    }
    
    private func setUpStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 15.0
        stackView.alignment = .fill
        self.view.addSubview(stackView)
        stackView.constrain(.leading, to: self.view, .leading, constant: 10.0)
        stackView.constrain(.top, to: spacer, .bottom, constant: 20.0)
        stackView.constrain(.trailing, to: self.view, .trailing, constant: 10.0)
        stackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50.0).isActive = true
    }
    
    private func setUpSelectedColor() {
        selectedColorView.translatesAutoresizingMaskIntoConstraints = false
        selectedColorView.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        selectedColorView.layer.cornerRadius = 10.0
        selectedColorView.clipsToBounds = true
        stackView.addArrangedSubview(selectedColorView)
        selectedColorView.backgroundColor = currentColor
    }
    
    private func setUpSliders() {
        for color in Color.allCases {
            let descriptionLabel = setUpDescriptionLabel(text: color.string)
            let slider = getSlider(color: color)
            let button = getButton(color: color)
            setUpSlider(slider, tag: color.rawValue)
            setUpDescriptionButton(button: button, tag: color.rawValue)
            
            let innerStackView = UIStackView(arrangedSubviews: [slider, button])
            innerStackView.axis = .horizontal
            innerStackView.distribution = .fill
            innerStackView.alignment = .fill
            innerStackView.spacing = 10.0
            
            let completeSliderStack = UIStackView(arrangedSubviews: [descriptionLabel, innerStackView])
            completeSliderStack.axis = .vertical
            completeSliderStack.distribution = .fill
            completeSliderStack.alignment = .fill
            stackView.addArrangedSubview(completeSliderStack)
        }
        stackView.layoutIfNeeded()
        if let color = currentColor {
            updateEverythingWithColor(uiColor: color)
        }
    }
    
    private func setUpColorOptionsTitle() {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.backgroundColor = .clear
        spacer.heightAnchor.constraint(equalToConstant: 10.0).isActive = true
        stackView.addArrangedSubview(spacer)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "GRID"
        titleLabel.font = .mediumBold
        titleLabel.textColor = .secondaryLabel
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        let reloadButton = UIButton()
        reloadButton.setImage(UIImage.reloadImage.withConfiguration(UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        reloadButton.tintColor = Colors.main
        reloadButton.setContentHuggingPriority(.required, for: .horizontal)
        reloadButton.addTarget(self, action: #selector(reloadButtonColors), for: .touchUpInside)
        
        let titleStackView = UIStackView(arrangedSubviews: [titleLabel, UIView(), reloadButton])
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(titleStackView)
    }
    
    private func setUpColorOptionsGrid() {
        
        let gridHolderView = UIView()
        gridHolderView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(gridHolderView)
        stackView.layoutIfNeeded()
        
        let gridHeight = gridHolderView.bounds.height
        let gridWidth = gridHolderView.bounds.width
        let gridSpacing: CGFloat = 3.0
        let itemsPerStack = 6
        let desiredItemSideSize = (gridWidth - CGFloat(itemsPerStack - 1)) / CGFloat(itemsPerStack)
        var verticalStackViewCount = Int(gridHeight / (desiredItemSideSize + gridSpacing)) - 1
        // Don't want more than 5 stacks, else it looks to cluttered
        verticalStackViewCount = min(5, verticalStackViewCount)
        
        let gridStackView = UIStackView()
        gridHolderView.addSubview(gridStackView)
        gridStackView.constrainSides(to: gridHolderView)
        gridStackView.translatesAutoresizingMaskIntoConstraints = false
        gridStackView.distribution = .fillEqually
        gridStackView.alignment = .fill
        gridStackView.spacing = gridSpacing
        gridStackView.axis = .vertical
        
        // make sure the range is valid
        guard verticalStackViewCount >= 1 else { return}
        for _ in 1...verticalStackViewCount {
            let colorStackView = UIStackView()
            colorStackView.translatesAutoresizingMaskIntoConstraints = false
            colorStackView.axis = .horizontal
            colorStackView.spacing = gridSpacing
            colorStackView.distribution = .fillEqually
            colorStackView.alignment = .fill
            for _ in 1...itemsPerStack {
                let random = Colors.random
                let button = SizeChangeButton(sizeDifference: .inverse, restingColor: random, selectedColor: random)
                button.translatesAutoresizingMaskIntoConstraints = false
                let height = button.heightAnchor.constraint(equalToConstant: desiredItemSideSize)
                height.isActive = true
                button.addTarget(self, action: #selector(colorButtonPressed(sender:)), for: .touchUpInside)
                button.backgroundColor = random
                button.layer.cornerRadius = 5.0
                buttonColors.append(button)
                colorStackView.addArrangedSubview(button)
            }
            gridStackView.addArrangedSubview(colorStackView)
        }
        stackView.addArrangedSubview(UIView())
        
    }
    
    @objc private func sliderValueChanged(sender: UISlider) {
        let tag = sender.tag
        guard let color = Color(rawValue: tag) else { return }
        let value = CGFloat(sender.value.rounded())
        let valueString = "\(Int(value))"
        
        updateValue(color: color, value: value)
        updateButton(color: color, string: valueString)
        
        currentColor = UIColor(red: redValue/255.0, green: greenValue/255.0, blue: blueValue/255.0, alpha: 1.0)
        updateSliderColors()
    }
    
    @objc private func valueButtonPressed(sender: UIButton) {
        let tag = sender.tag
        guard let color = Color(rawValue: tag) else { return }
        self.getNumberFromUser(delegate: self)
        selectedColorForValueChangeButton = color
    }
    
    @objc private func dismissChild() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func chooseColorSelected() {
        // Need to get the hex color
        guard let color = currentColor else { return }
        let newColorHex = color.toHexString()
        
        Network.shared.account?.color = newColorHex
        Network.shared.account?.writeToKeychain()
        Network.shared.alterUserPhoneNumberOrColor(newNumber: nil, newColor: newColorHex, complete: { _ in return })
        
        NotificationCenter.default.post(name: .reloadSettings, object: nil)
        
        self.showMessage("Account color changed")
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func reloadButtonColors() {
        buttonColors.forEach { (b) in
            b.backgroundColor = Colors.random
        }
    }
    
    @objc private func colorButtonPressed(sender: UIButton) {
        guard let newColor = sender.backgroundColor else { return }
        updateEverythingWithColor(uiColor: newColor)
    }
    
    private func updateEverythingWithColor(uiColor: UIColor) {
        self.currentColor = uiColor
        let (red, green, blue) = uiColor.components
        let combined = [(red, Color.red), (green, Color.green), (blue, Color.blue)]
        for c in combined {
            updateValue(color: c.1, value: c.0)
            updateButton(color: c.1, string: "\(Int(c.0))")
            let slider = getSlider(color: c.1)
            slider.value = Float(c.0)
        }
        updateSliderColors()
    }
    
    private func updateSliderColors() {
        let minimumRed = UIColor(red: CGFloat(minimumValue)/255.0, green: greenValue/255.0, blue: blueValue/255.0, alpha: 1.0)
        let maximumRed = UIColor(red: CGFloat(maximumValue)/255.0, green: greenValue/255.0, blue: blueValue/255.0, alpha: 1.0)
        redSlider.setGradientBackgroundHorizontal(colorLeft: minimumRed, colorRight: maximumRed)
        
        let minimumGreen = UIColor(red: redValue/255.0, green: CGFloat(minimumValue)/255.0, blue: blueValue/255.0, alpha: 1.0)
        let maximumGreen = UIColor(red: redValue/255.0, green: CGFloat(maximumValue)/255.0, blue: blueValue/255.0, alpha: 1.0)
        greenSlider.setGradientBackgroundHorizontal(colorLeft: minimumGreen, colorRight: maximumGreen)
        
        let minimumBlue = UIColor(red: redValue/255.0, green: greenValue/255.0, blue: CGFloat(minimumValue)/255.0, alpha: 1.0)
        let maximumBlue = UIColor(red: redValue/255.0, green: greenValue/255.0, blue: CGFloat(maximumValue)/255.0, alpha: 1.0)
        blueSlider.setGradientBackgroundHorizontal(colorLeft: minimumBlue, colorRight: maximumBlue)
    }
    
    private func setUpSlider(_ slider: UISlider, tag: Int) {
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = .clear
        slider.maximumTrackTintColor = .clear
        slider.minimumValue = minimumValue
        slider.maximumValue = maximumValue
        slider.value = 255.0/2.0
        slider.tag = tag
        slider.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: .valueChanged)
        slider.layer.cornerRadius = slider.bounds.height / 2.0
        slider.clipsToBounds = true
        let image = UIImage.circleImage.withConfiguration(UIImage.SymbolConfiguration(pointSize: 35.0, weight: .heavy))
        slider.setThumbImage(image, for: .normal)
        slider.tintColor = .secondarySystemBackground
    }
    
    private func setUpDescriptionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .mediumBold
        label.textColor = .secondaryLabel
        return label
    }
    
    private func setUpDescriptionButton(button: UIButton, tag: Int) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("122", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.font = .secondaryTitle
        button.widthAnchor.constraint(equalToConstant: self.view.bounds.width * 0.15).isActive = true
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 8.0
        button.tag = tag
        button.addTarget(self, action: #selector(valueButtonPressed(sender:)), for: .touchUpInside)
    }
    
}


extension ColorPickerVC: EnterValueViewDelegate {
    func textFound(string: String?) {
        guard let colorToChange = selectedColorForValueChangeButton, let value = Int(string ?? "") else { return }
        updateValue(color: colorToChange, value: CGFloat(value))
        updateButton(color: colorToChange, string: "\(value)")
        let slider = getSlider(color: colorToChange)
        slider.value = Float(value)
        updateSliderColors()
    }
    
    func ratingFound(float: Float?) { return }
    
    func phoneFound(string: String?) { return }
    
}
