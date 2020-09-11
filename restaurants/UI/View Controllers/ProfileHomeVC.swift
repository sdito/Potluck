//
//  ProfileHomeVC.swift
//  restaurants
//
//  Created by Steven Dito on 8/14/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class ProfileHomeVC: UIViewController {
    
    private let tableView = UITableView()
    private var allowHintToCreateRestaurant = false
    private var visits: [Visit] = []
    private let reuseIdentifier = "visitCellReuseIdentifier"
    private let refreshControl = UIRefreshControl()
    
    private let imageCache = NSCache<NSString, UIImage>()
    private let otherImageCache = NSCache<NSString, ImageRequest>()
    private var photoIndexCache: [Int:Int] = [:]
    
    private class ImageRequest {
        var requested: Bool = true
        var image: UIImage?
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.setNavigationBarColor(color: Colors.navigationBarColor)
        self.navigationController?.navigationBar.tintColor = Colors.main
        self.tableView.separatorInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .settingsImage, style: .plain, target: self, action: #selector(rightBarButtonItemSelector))
        navigationItem.title = "Profile feed"
        setUpTableView()
        getInitialUserVisits()
        
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedIn), name: .userLoggedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedOut), name: .userLoggedOut, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func getInitialUserVisits() {
        
        if Network.shared.loggedIn {
            Network.shared.getUserFeed { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let visits):
                    
                    self.allowHintToCreateRestaurant = true
                    self.visits = visits
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            noUserTableView()
        }
    }
    
    private func setUpTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        tableView.constrainSides(to: self.view)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(VisitCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorStyle = .none
        
        refreshControl.addTarget(self, action: #selector(refreshControlSelector), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        self.tableView.backgroundColor = .systemBackground
        
        let showOnMapButton = OverlayButton()
        showOnMapButton.setTitle("Show on map", for: .normal)
        showOnMapButton.addTarget(self, action: #selector(showOnMapButtonPressed), for: .touchUpInside)
        
        self.view.addSubview(showOnMapButton)
        showOnMapButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        showOnMapButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -((self.tabBarController?.tabBar.bounds.height ?? 0.0) + 10.0)).isActive = true
    }
    
    private func noUserTableView() {
        tableView.layoutIfNeeded()
        self.allowHintToCreateRestaurant = false
        let createAccountButton = self.tableView.setEmptyWithAction(message: "You need to create an account in order to make posts.", buttonTitle: "Create account", area: .center)
        createAccountButton.addTarget(self, action: #selector(rightBarButtonItemSelector), for: .touchUpInside)
    }
    
    @objc private func rightBarButtonItemSelector() {
        if Network.shared.loggedIn {
            self.navigationController?.pushViewController(SettingsVC(), animated: true)
        } else {
            self.navigationController?.pushViewController(CreateAccountVC(), animated: true)
        }
    }
    
    @objc private func addNewPostSelector() {
        self.tabBarController?.presentAddRestaurantVC()
    }
    
    @objc private func userLoggedIn() {
        getInitialUserVisits()
    }
    
    @objc private func userLoggedOut() {
        visits = []
        tableView.reloadData()
        noUserTableView()
    }
    
    @objc private func showOnMapButtonPressed() {
        let mapProfile = ProfileMapVC()
        self.navigationController?.pushViewController(mapProfile, animated: true)
    }
    
    @objc private func refreshControlSelector() {
        print("Refresh control selected")
        #warning("need to complete")
    }
}

// MARK: Table view
extension ProfileHomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allowHintToCreateRestaurant && visits.count == 0 {
            let addPostButton = self.tableView.setEmptyWithAction(message: "You do not have any posts yet. Add a post every time you eat at a restaurant.", buttonTitle: "Add post", area: .center)
            addPostButton.addTarget(self, action: #selector(addNewPostSelector), for: .touchUpInside)
        }
        return visits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! VisitCell
        let visit = visits[indexPath.row]
        cell.setUpWith(visit: visit, selectedPhotoIndex: photoIndexCache[visit.djangoOwnID])
        cell.delegate = self
        let key = NSString(string: "\(visit.djangoOwnID)-main")
        
        // handle the main image
        cell.setImage(url: visit.mainImage, image: imageCache.object(forKey: key), height: visit.mainImageHeight, width: visit.mainImageWidth) { (imageFound) in
            if let imageFound = imageFound {
                self.imageCache.setObject(imageFound, forKey: key)
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let visitSelected = visits[indexPath.row]
        
        var images: [(String, UIImage?)] = visitSelected.listPhotos.map({($0, nil)})
        // get the images from the selected visit and add them to what is being sent
        let id = visitSelected.djangoOwnID
        var counter = 0
        while counter < images.count {
            defer { counter += 1 }
            if counter == 0 {
                let key = NSString(string: "\(id)-main")
                images[counter].1 = imageCache.object(forKey: key)
            } else {
                let key = NSString(string: "\(id)-\(counter-1)")
                images[counter].1 = otherImageCache.object(forKey: key)?.image
            }
        }
        
        
        let photosVC = PhotosVC(images: images)
        self.navigationController?.pushViewController(photosVC, animated: true)
    }
    
    func cellFrom(visit: Visit) -> VisitCell? {
        let cells = tableView.visibleCells
        for cell in cells {
            if let visitCell = cell as? VisitCell {
                if let cellsVisit = visitCell.visit {
                    if cellsVisit.djangoOwnID == visit.djangoOwnID {
                        return visitCell
                    }
                }
            }
        }
        return nil
    }
}


// MARK: VisitCellDelegate
extension ProfileHomeVC: VisitCellDelegate {
    
    func newPhotoIndexSelected(idx: Int, for visit: Visit?) {
        #warning("need to implement and use a cache for it")
        guard let visit = visit else { return }
        photoIndexCache[visit.djangoOwnID] = idx
    }
    
    func moreImageRequest(visit: Visit?, cell: VisitCell) {
        print("More images requested...")
        guard let visit = visit else { return }
        
        for (i, imageUrl) in visit.otherImages.map({$0.image}).enumerated() {
            let imageRequestKey = NSString(string: "\(visit.djangoOwnID)-\(i)")
            if let object = otherImageCache.object(forKey: imageRequestKey) {
                print("Already requested: \(imageRequestKey)")
                // already requested
                // if the image exists, add it to the imageView
                if let image = object.image {
                    print("Image already found: \(imageRequestKey)")
                    cell.otherImageViews[i].image = image
                    print(cell.otherImageViews.count)
                }
            } else {
                let newObject = ImageRequest()
                otherImageCache.setObject(newObject, forKey: imageRequestKey)
                Network.shared.getImage(url: imageUrl) { [weak self] (imageFound) in
                    if let image = imageFound {
                        print("Image gotten from request: \(imageRequestKey)")
                        newObject.image = image

                        if let cell = self?.cellFrom(visit: visit) {
                            print("Image set from request: \(imageRequestKey)")
                            cell.otherImageViews[i].image = image
                        }

                    } else {
                        // remove the value from the cache
                        self?.otherImageCache.removeObject(forKey: imageRequestKey)
                    }
                }
            }
        }
    }
    
    func establishmentSelected(establishment: Establishment) {
        self.navigationController?.pushViewController(EstablishmentDetailVC(establishment: establishment, delegate: nil, mode: .fullScreenBase), animated: true)
    }
    
    func delete(visit: Visit?) {
        guard let visit = visit else { return }
        self.alert(title: "Are you sure you want to delete this visit?", message: "This action can't be undone.") {
            Network.shared.deleteVisit(visit: visit) { (success) in return }
            
            let indexToDelete = self.visits.firstIndex { (v) -> Bool in
                v.djangoOwnID == visit.djangoOwnID
            }
            
            if let idx = indexToDelete {
                guard let cellToDelete = self.tableView.cellForRow(at: IndexPath(row: idx, section: 0)) as? VisitCell else { return }
            
                if cellToDelete.visit?.djangoOwnID == visit.djangoOwnID {
                    self.visits.remove(at: idx)
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [IndexPath(row: idx, section: 0)], with: .automatic)
                    self.tableView.endUpdates()
                }
            }
        }
    }
    
}

