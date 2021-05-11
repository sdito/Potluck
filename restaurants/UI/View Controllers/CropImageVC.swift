//
//  CropImageVC.swift
//  restaurants
//
//  Created by Steven Dito on 11/8/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Photos


protocol CropImageDelegate: class {
    func animationStarted()
    func imageFound(image: UIImage)
}


class CropImageVC: UIViewController {
    
    var imageToCrop: UIImage? {
        didSet {
            imageView.image = imageToCrop
        }
    }
    private lazy var overlayView = UIImageView(image: UIImage.circularOverlayMask(bounds: scrollView.bounds))
    private let scrollView = UIScrollView()
    private let headerView = HeaderView(leftButtonTitle: "Cancel", rightButtonTitle: "Done", title: "Crop")
    private let imageView = UIImageView()
    private var asset: PHAsset?
    private weak var cellToResetIdAfter: PhotoCell?
    private weak var cropImageDelegate: CropImageDelegate?
    private var cameraLinesView: UIView?
    
    init(image: UIImage?, asset: PHAsset?, cell: PhotoCell?, cropImageDelegate: CropImageDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.cellToResetIdAfter = cell
        self.cropImageDelegate = cropImageDelegate
        self.asset = asset
        if let image = image {
            imageToCrop = image
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.edgesForExtendedLayout = []
        setUpHeader()
        setUpScrollView()
        setUpImageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getImageFromAsset()
        addCurrentSelector()
        
    }
    
    private func setUpHeader() {
        self.view.addSubview(headerView)
        headerView.constrain(.leading, to: self.view, .leading)
        headerView.constrain(.top, to: self.view, .top, constant: 50.0)
        headerView.constrain(.trailing, to: self.view, .trailing)
        headerView.leftButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        headerView.rightButton.addTarget(self, action: #selector(donePressed), for: .touchUpInside)
    }
    
    private func setUpScrollView() {
        let scrollViewPadding: CGFloat = 5.0
        self.view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        scrollView.zoomScale = 1.0
        
        scrollView.bounces = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.hero.id = .photosToSinglePhotoID
        scrollView.constrain(.top, to: headerView, .bottom, constant: scrollViewPadding * 3.0)
        scrollView.constrain(.leading, to: self.view, .leading, constant: scrollViewPadding)
        scrollView.constrain(.trailing, to: self.view, .trailing, constant: scrollViewPadding)
        scrollView.equalSides()
    }
    
    private func setUpImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(imageView)
        
        /*
         if image width is greater than or equal to height, then image height is equal to scrollView height and width is larger using ratio
         if image height is greater than width, then image width is equal to scrollView width and height is larger using ratio
         */
        
        if let image = imageToCrop {
            imageView.image = image
            let height = image.size.height
            let width = image.size.width
            
            scrollView.layoutIfNeeded()
            var imageViewHeight: CGFloat = 0.0
            var imageViewWidth: CGFloat = 0.0
            var yContentOffset: CGFloat = 0.0
            var xContentOffset: CGFloat = 0.0
            
            let scrollViewHeight = scrollView.bounds.height
            let scrollViewWidth = scrollView.bounds.width
            
            if width >= height {
                imageViewHeight = scrollViewHeight
                imageViewWidth = scrollViewWidth * (width / height)
                xContentOffset = (imageViewWidth - scrollViewHeight) / 2.0
            } else { // height greater
                imageViewHeight = scrollViewHeight * (height / width)
                imageViewWidth = scrollViewWidth
                yContentOffset = (imageViewHeight - scrollViewHeight) / 2.0
            }
            
            imageView.widthAnchor.constraint(equalToConstant: imageViewWidth).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageViewHeight).isActive = true
            scrollView.contentSize = CGSize(width: imageViewWidth, height: imageViewHeight)
            
            cameraLinesView = overlayView.addCameraLines()
            // to center the imageView in the scrollView content offset
            scrollView.contentOffset = CGPoint(x: xContentOffset, y: yContentOffset)
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor)
        ])
        
    }
    
    private func addCurrentSelector() {
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(overlayView)
        overlayView.constrainSides(to: scrollView)
        overlayView.alpha = 0.0
        overlayView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.3) {
            self.overlayView.alpha = 1.0
        }
    }
    
    private func getImageFromAsset() {
        asset?.getOriginalImage(imageFound: { (image) in
            self.imageToCrop = image ?? self.imageToCrop
        })
    }
    
    @objc private func cancelPressed() {
        animateBackgroundAlphaGoingToZero()
        
        self.hero.dismissViewController {
            if let cell = self.cellToResetIdAfter {
                // used to reset and fix the hero animation
                cell.imageView.hero.id = ""
            }
        }
    }
    
    private func animateBackgroundAlphaGoingToZero() {
        UIView.animate(withDuration: 0.1) {
            self.view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.0)
            self.overlayView.alpha = 0.0
        }
    }
    
    @objc private func donePressed() {
        guard let cropImage = imageView.image else { return }
        // To get the coordinates of the image from the current position in the scrollView
        // Basically just use a bunch of ratios
        let zoomScale = scrollView.zoomScale
        let rawSideSize = (scrollView.bounds.size.height + scrollView.bounds.size.width) / 2.0
        let trueSideSize = rawSideSize / zoomScale
        
        let contentOffset = scrollView.contentOffset
        let contentSize = scrollView.contentSize
        
        let imageOriginY = cropImage.size.height * (contentOffset.y / contentSize.height)
        let imageOriginX = cropImage.size.width * (contentOffset.x / contentSize.width)
        
        let imageSideSize = min(cropImage.size.height, cropImage.size.width) * (trueSideSize / rawSideSize)
        
        
        // imageOriginY and imageOriginX are the correct origin, imageSideSize is the correct size BOTH in relation to the cropImage
        // now need to actually create the new image from the crop image
        
        print("X: \(imageOriginX), Y: \(imageOriginY), sideSize: \(imageSideSize), image width: \(cropImage.size.width), image height: \(cropImage.size.height)")
        // to actually create the image
        let fromRect = CGRect(x: imageOriginX, y: imageOriginY, width: imageSideSize ,height: imageSideSize)
        guard let drawImage = cropImage.cgImage?.cropping(to: fromRect) else { return }
        // cropped image is the final correct image
        let croppedImage = UIImage(cgImage: drawImage)
        
        // want to animate to the profileImageView on ProfileImageSelectorVC instead
        cellToResetIdAfter?.imageView.hero.id = ""
        
        cropImageDelegate?.animationStarted()
        animateBackgroundAlphaGoingToZero()
        
        self.dismiss(animated: true) {
            self.cropImageDelegate?.imageFound(image: croppedImage)
        }
        
    }
    
}


// MARK: Scroll view
extension CropImageVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        setAlphaTo(1.0)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        setAlphaTo(0.0)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        setAlphaTo(1.0)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        setAlphaTo(0.0)
    }
    
    private func setAlphaTo(_ value: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.cameraLinesView?.alpha = value
        }
    }
    
}
