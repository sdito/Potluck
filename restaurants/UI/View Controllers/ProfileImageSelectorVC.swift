//
//  ProfileImageSelectorVC.swift
//  restaurants
//
//  Created by Steven Dito on 11/8/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Photos

class ProfileImageSelectorVC: UIViewController {
    
    private var allPhotos = PHFetchResult<PHAsset>()
    private let requestOptions = PHImageRequestOptions()
    private let imageCache = NSCache<NSString, UIImage>()
    private let imageManager = PHImageManager.default()
    private var somethingChanged = false
    private let profilePortionView = UIView()
    private lazy var collectionView = CameraRollCollectionView(width: self.view.bounds.width)
    private let reuseIdentifier = "photoCellReuseIdentifier"
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let nameButton = UIButton()
    private let deleteImageButton = UIButton()
    private let colorPickerButton = UIButton()
    private lazy var profilePortionHeightConstant = self.view.bounds.height * 0.2
    private let accountColor: UIColor = UIColor(hex: Network.shared.account?.color) ?? Colors.random
    private var hasProfileImage: Bool = false {
        didSet {
            deleteImageButton.isHidden = !hasProfileImage
        }
    }
    
    private var newAccountColor: UIColor?
    private var newProfileImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setUpNavigationBar()
        setUpProfilePortion()
        setUpInnerProfileStackView()
        setUpProfileImageView()
        setUpDeleteButton()
        setUpProfileName()
        setUpCollectionView()
        getPhotos()
    }
    
    private func setUpNavigationBar() {
        let navigationView = NavigationTitleView(upperText: "Edit", lowerText: "Profile")
        self.navigationItem.titleView = navigationView
        
        let rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(savePressed))
        rightBarButtonItem.tintColor = Colors.main
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        // cancel button
        self.navigationItem.leftItemsSupplementBackButton = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
    }
    
    private func setUpProfilePortion() {
        profilePortionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(profilePortionView)
        profilePortionView.constrain(.leading, to: self.view, .leading)
        profilePortionView.constrain(.top, to: self.view, .top)
        profilePortionView.constrain(.trailing, to: self.view, .trailing)
        profilePortionView.heightAnchor.constraint(equalToConstant: profilePortionHeightConstant).isActive = true
    }
    
    private func setUpInnerProfileStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        profilePortionView.addSubview(stackView)
        
        stackView.constrain(.leading, to: profilePortionView, .leading)
        stackView.constrain(.trailing, to: profilePortionView, .trailing)
        stackView.centerYAnchor.constraint(equalTo: profilePortionView.centerYAnchor).isActive = true
        
        stackView.axis = .vertical
        stackView.spacing = 5.0
        stackView.alignment = .center
        stackView.distribution = .equalCentering
    }
    
    private func setUpProfileImageView() {
        let size = profilePortionHeightConstant / 2.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.equalSides(size: size)
        stackView.addArrangedSubview(imageView)
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = size / 2.0
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 3.0
        imageView.layer.borderColor = accountColor.cgColor
        
        if let image = Network.shared.account?.actualImage {
            hasProfileImage = true
            imageView.image = image
        } else {
            hasProfileImage = false
            imageView.image = UIImage.personImage
        }
        
        imageView.tintColor = accountColor
    }
    
    private func setUpDeleteButton() {
        deleteImageButton.translatesAutoresizingMaskIntoConstraints = false
        deleteImageButton.setImage(.xImage, for: .normal)
        deleteImageButton.tintColor = Colors.main
        deleteImageButton.backgroundColor = .secondarySystemBackground
        deleteImageButton.addTarget(self, action: #selector(removePhotoPressed), for: .touchUpInside)
        self.view.addSubview(deleteImageButton)
        deleteImageButton.constrain(.trailing, to: imageView, .trailing)
        deleteImageButton.constrain(.top, to: imageView, .top)
        deleteImageButton.imageEdgeInsets = UIEdgeInsets(top: 3.0, left: 3.0, bottom: 3.0, right: 3.0)
        deleteImageButton.equalSides()
        deleteImageButton.layoutIfNeeded()
        deleteImageButton.layer.cornerRadius = deleteImageButton.bounds.height / 2.0
    }
    
    private func setUpProfileName() {
        let nameStackView = UIStackView()
        nameStackView.translatesAutoresizingMaskIntoConstraints = false
        nameStackView.axis = .horizontal
        nameStackView.spacing = 5.0
        stackView.addArrangedSubview(nameStackView)
        
        nameButton.translatesAutoresizingMaskIntoConstraints = false
        nameButton.setTitleColor(accountColor, for: .normal)
        nameButton.titleLabel?.font = .largerBold
        nameButton.setTitle(Network.shared.account?.username ?? "StevenDito", for: .normal)
        nameStackView.addArrangedSubview(nameButton)
        
        colorPickerButton.translatesAutoresizingMaskIntoConstraints = false
        colorPickerButton.tintColor = accountColor
        colorPickerButton.setImage(.colorPickerIcon, for: .normal)
        colorPickerButton.addTarget(self, action: #selector(chooseNewAccountColor), for: .touchUpInside)
        nameStackView.addArrangedSubview(colorPickerButton)
    }
    
    private func setUpCollectionView() {
        self.view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.constrain(.top, to: profilePortionView, .bottom)
        collectionView.constrain(.leading, to: self.view, .leading)
        collectionView.constrain(.trailing, to: self.view, .trailing)
        collectionView.constrain(.bottom, to: self.view, .bottom)
    }
    
    @objc private func photosNotAuthorized() {
        UIDevice.openAppSettings()
    }
    
    @objc private func chooseNewAccountColor() {
        let colorPicker = ColorPickerVC(startingColor: newAccountColor ?? accountColor, colorPickerDelegate: self)
        self.present(colorPicker, animated: true, completion: nil)
    }
    
    @objc private func removePhotoPressed() {
        print("remove photo pressed")
        
        self.appAlert(title: nil, message: "Are you sure you want to remove your profile photo?", buttons: [
            ("Cancel", nil),
            ("Remove", { [weak self] in
                self?.hasProfileImage = false
                self?.imageView.image = UIImage.personImage
                self?.newProfileImage = nil
            })
        ])
        
    }
    
    @objc private func cancelPressed() {
        if !somethingChanged {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.appAlert(title: "Unsaved changes", message: "Are you sure you want to exit and lose your unsaved changes?", buttons: [
                ("Exit", {
                    self.navigationController?.popViewController(animated: true)
                }),
                ("Stay", nil)
            ])
        }
    }
    
    @objc private func savePressed() {
        var somethingChanged = false
        if let newColorHex = newAccountColor?.toHexString() {
            Network.shared.account?.color = newColorHex
            Network.shared.account?.writeToKeychain()
            Network.shared.alterUserPhoneNumberOrColor(changePhone: false, newNumber: nil, newColor: newColorHex, complete: { _ in return })
            somethingChanged = true
        }
        
        // If newProfileImage is set then there has to be a new image, if newProfileImage is nil and the user did have an image, then it was removed
        // updateUserProfilePhoto(newImage adds an image if not nil, or removes the image if it is nil
        if newProfileImage != nil || (Network.shared.account?.actualImage != nil && !hasProfileImage) {
            Network.shared.account?.actualImage = newProfileImage
            Network.shared.updateUserProfilePhoto(newImage: newProfileImage) { _ in return }
            somethingChanged = true
        }
        
        if somethingChanged {
            NotificationCenter.default.post(name: .reloadSettings, object: nil)
        } 
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    private func getPhotos() {
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
    
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .authorized, .limited:
                self.collectionView.restore()
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [.init(key: "creationDate", ascending: false)]

                self.allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                
                DispatchQueue.main.async {
                    if !(self.collectionView.numberOfItems(inSection: 0) == self.allPhotos.count) { // means it is already reloaded
                        self.collectionView.reloadData()
                    }
                }
                
            case .denied, .restricted:
                print("Not allowed")
                DispatchQueue.main.async {
                    let button = self.collectionView.setEmptyWithAction(message: "Photo authorization not enabled. Enable to upload photos from your visits.", buttonTitle: "Enable access in privacy settings")
                    button.addTarget(self, action: #selector(self.photosNotAuthorized), for: .touchUpInside)
                }
            case .notDetermined:
                // Already automatically requests
                return
            @unknown default:
                return
            }
        }
    }
}

// MARK: Collection view
extension ProfileImageSelectorVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        cell.imageView.image = nil
        cell.allowsSelection = true
        cell.updateForShowingSelection(selected: false, animated: false)
        let asset = allPhotos.object(at: indexPath.row) as PHAsset
        let creationDate = asset.creationDate
        cell.creationDate = creationDate
        cell.asset = asset
        
        let key = NSString(string: "\(indexPath.row)")
        if let cachedImage = imageCache.object(forKey: key) {
            cell.imageView.image = cachedImage
        } else {
            imageManager.requestImage(for: asset, targetSize: CGSize(width: self.collectionView.cameraLayout.itemSize.width, height: self.collectionView.cameraLayout.itemSize.height), contentMode: .aspectFill, options: requestOptions) { (image, info) in
                if let image = image {
                    print(self.collectionView.cameraLayout.itemSize.width, image.size.width)
                    cell.imageView.image = image
                    self.imageCache.setObject(image, forKey: key)
                } else {
                    cell.imageView.image = nil
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        if let image = cell.imageView.image {
            print(indexPath.row)
            cell.imageView.hero.id = .photosToSinglePhotoID
            let vc = CropImageVC(image: image, asset: cell.asset, cell: cell, cropImageDelegate: self)
            vc.isHeroEnabled = true
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
}


// MARK: CropImageDelegate
extension ProfileImageSelectorVC: CropImageDelegate {
    
    func animationStarted() {
        self.imageView.hero.id = .photosToSinglePhotoID
    }
    
    func imageFound(image: UIImage) {
        self.somethingChanged = true
        self.hasProfileImage = true
        self.imageView.image = image
        self.imageView.hero.id = ""
        self.newProfileImage = image
    }
}

// MARK: ColorPickerDelegate
extension ProfileImageSelectorVC: ColorPickerDelegate {
    func colorPicker(color: UIColor) {
        self.somethingChanged = true
        self.nameButton.setTitleColor(color, for: .normal)
        self.colorPickerButton.tintColor = color
        self.imageView.layer.borderColor = color.cgColor
        self.imageView.tintColor = color
        self.newAccountColor = color
    }
}
