//
//  SinglePhotoVC.swift
//  restaurants
//
//  Created by Steven Dito on 7/12/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


class SinglePhotoVC: UIViewController {
    
    private weak var cellToResetIdAfter: PhotoCell?
    private var imageView: UIImageView!
    private var scrollView: UIScrollView!
    private var doneButton: UIButton!
    private var initialTouchPoint: CGPoint?
    private var minimumAlpha: CGFloat = 0.5
    
    
    init(image: UIImage?, imageURL: String?, cell: PhotoCell?) {
        super.init(nibName: nil, bundle: nil)
        setUp(image: image, imageURL: imageURL, cell: cell)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
    }

    private func setUp(image: UIImage?, imageURL: String?, cell: PhotoCell?) {
        self.cellToResetIdAfter = cell
        self.hero.isEnabled = true
        self.view.backgroundColor = .systemBackground
        
        setUpDoneButton()
        setUpScrollView()
        setUpImageView(image: image, imageURL: imageURL)
        setUpGestureRecognizerForDismissing()
    }
    
    private func setUpDoneButton() {
        doneButton = UIButton()
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(Colors.main, for: .normal)
        
        self.view.addSubview(doneButton)
        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 15.0),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5.0),
            doneButton.heightAnchor.constraint(equalToConstant: 40.0)
        ])
        
        doneButton.addTarget(self, action: #selector(dismissSinglePhoto), for: .touchUpInside)
        
    }
    
    private func setUpScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 10
        scrollView.bounces = false
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        self.view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: doneButton.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setUpImageView(image: UIImage?, imageURL: String?) {
        imageView = UIImageView()
        imageView.hero.id = .photosToSinglePhotoID
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        
        scrollView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        if let image = image {
            let ratio = image.size.height / image.size.width
            imageView.image = image
            imageView.heightAnchor.constraint(equalToConstant: self.view.frame.width * ratio).isActive = true
        } else if let imageURL = imageURL {
            imageView.addImageFromUrl(imageURL)
        }
    }
    
    @objc private func dismissSinglePhoto() {
        self.hero.dismissViewController {
            if let cell = self.cellToResetIdAfter {
                // used to reset and fix the hero animation
                cell.imageView.hero.id = ""
            }
        }
    }
    
    private func setUpGestureRecognizerForDismissing() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureSelector(sender:)))
        self.view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func panGestureSelector(sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        switch sender.state {
        case .began:
            initialTouchPoint = touchPoint
        case .changed:
            if let initialTouchPoint = initialTouchPoint {
                let difference = touchPoint.y - initialTouchPoint.y
                if (difference > 0) {
                    let viewHeight = self.view.frame.size.height
                    self.view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.view.frame.size.width, height: viewHeight)
                    let ratio = (viewHeight - difference) / viewHeight
                    // use ratio to set alpha on view when being dragged
                    if ratio < 0.95 {
                        let newAlphaValue = 1.0 - (minimumAlpha - (minimumAlpha*ratio))
                        self.view.alpha = newAlphaValue
                    } else {
                        self.view.alpha = 1.0 // close enough to the top, just set to 1.0
                    }
                }
            }
            
        case .ended, .cancelled:
            if let initialTouchPoint = initialTouchPoint {
                if touchPoint.y - initialTouchPoint.y > 100 {
                    doneButton.isHidden = true // shows up weird on dismiss if it doesn't get set to hidden
                    dismissSinglePhoto()
                } else {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.alpha = 1.0
                        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                    })
                }
            }
            
        default:
            break
        }
        
    }
    
    
}


extension SinglePhotoVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
