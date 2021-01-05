//
//  VisitTableView.swift
//  restaurants
//
//  Created by Steven Dito on 10/11/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit



protocol VisitTableViewDelegate: class {
    func refreshControlSelected()
    func nextPageRequested()
}



class VisitTableView: UITableView {
    
    private var imageCache: NSCache<NSString, UIImage>?
    private let otherImageCache = NSCache<NSString, ImageRequest>()
    private var profileImageCache: NSCache<NSString, UIImage>?
    private let alreadyRequestedCache = NSCache<NSString, NSNumber>()
    private let photoIndexCache = NSCache<NSNumber, NSNumber>()
    
    var visits: [Visit] = [] {
        didSet {
            self.initialDataFound = true
        }
    }
    private var lastContentOffset: CGFloat = 0.0
    private let animatedRefreshControl = AnimatedRefreshControl()
    private let reuseIdentifier = "visitCellReuseIdentifier"
    private weak var visitTableViewDelegate: VisitTableViewDelegate?
    private var mode: Mode = .user
    private var initialDataFound = false
    var allowNextPage = true
    var allowHintToCreateRestaurant = false
    var allowHintForFriendsFeed = false
    
    enum Mode {
        case friends
        case user
    }
    
    init(mode: Mode, prevImageCache: NSCache<NSString, UIImage>?, delegate: VisitTableViewDelegate) {
        super.init(frame: .zero, style: .plain)
        self.mode = mode
        self.visitTableViewDelegate = delegate
        if let cache = prevImageCache {
            imageCache = cache
        } else {
            imageCache = NSCache<NSString, UIImage>()
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        self.delegate = self
        self.dataSource = self
        self.register(VisitCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.separatorStyle = .none
        self.rowHeight = UITableView.automaticDimension
        self.separatorInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        animatedRefreshControl.addTarget(self, action: #selector(refreshControlSelector), for: .valueChanged)
        self.refreshControl = animatedRefreshControl
        
        self.backgroundColor = .systemBackground
        
        if mode == .user {
            NotificationCenter.default.addObserver(self, selector: #selector(establishmentDeleted(notification:)), name: .establishmentDeleted, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(establishmentUpdated(notification:)), name: .establishmentUpdated, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(visitUpdated(notification:)), name: .visitUpdated, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(visitDeleted(notification:)), name: .visitDeleted, object: nil)
        } else if mode == .friends {
            profileImageCache = NSCache<NSString, UIImage>()
        }
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private class ImageRequest {
        var requested: Bool = true
        var image: UIImage?
    }
    
    func cellFrom(visit: Visit) -> VisitCell? {
        let cells = self.visibleCells
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
    
    @objc private func refreshControlSelector() {
        visitTableViewDelegate?.refreshControlSelected()
    }
    
    @objc private func addNewPostSelector() {
        self.findViewController()?.tabBarController?.presentAddRestaurantVC()
    }
    
    @objc private func establishmentDeleted(notification: Notification) {
        if let establishment = notification.userInfo?["establishment"] as? Establishment {
            changeEstablishment(establishment: establishment, delete: true)
        }
    }
    
    @objc private func establishmentUpdated(notification: Notification) {
        if let establishment = notification.userInfo?["establishment"] as? Establishment {
            changeEstablishment(establishment: establishment, delete: false)
        }
    }
    
    @objc private func visitUpdated(notification: Notification) {
        if let dict = notification.userInfo as? [String:Any], let visit = dict["visit"] as? Visit {
            if let index = visits.firstIndex(where: { $0.djangoOwnID == visit.djangoOwnID }) {
                let previousVisit = visits[index]
                previousVisit.comment = visit.comment
                previousVisit.rating = visit.rating
                previousVisit.tags = visit.tags
                let cell = self.cellForRow(at: IndexPath(row: index, section: 0)) as? VisitCell
                cell?.visit = previousVisit
                cell?.update()
            }
        }
    }
    
    @objc private func visitDeleted(notification: Notification) {
        if let dict = notification.userInfo as? [String:Any], let visit = dict["visit"] as? Visit {
            if let index = visits.firstIndex(where: { $0.djangoOwnID == visit.djangoOwnID }) {
                visits.remove(at: index)
                self.reloadData()
            }
        }
    }
    
    private func changeEstablishment(establishment: Establishment, delete: Bool) {
        guard let establishmentID = establishment.djangoID else { return }
        var indexesToChange: [Int] = []
        var visitsToChange: [Visit] = []
        for (idx, visit) in visits.enumerated() {
            if visit.djangoRestaurantID == establishmentID {
                indexesToChange.append(idx)
                visitsToChange.append(visit)
                
                if !delete {
                    visit.updateFromEstablishment(establishment: establishment)
                }
            }
        }
        let indexPaths = indexesToChange.map({IndexPath(row: $0, section: 0)})
        if delete {
            // remove from visits
            for idx in indexesToChange.sorted().reversed() {
                visits.remove(at: idx)
            }
            for vis in visitsToChange {
                self.removeImagesFromCacheFor(visit: vis)
            }
            // remove from the table view
            self.deleteRows(at: indexPaths, with: .automatic)
        } else {
            // just update...not in hierarchy so fine
            self.reloadData()
        }
    }
    
    @objc private func goToCreateAccount() {
        self.findViewController()?.navigationController?.pushViewController(CreateAccountVC(), animated: true)
    }
    
    func clearCaches() {
        photoIndexCache.removeAllObjects()
        imageCache?.removeAllObjects()
        otherImageCache.removeAllObjects()
        alreadyRequestedCache.removeAllObjects()
    }
    
    private func setProfileImage(visit: Visit, cell: VisitCell) {
        if let imageUrl = visit.person?.image, let cache = profileImageCache, let personId = visit.person?.id {
            let key = NSString(string: "\(personId)")
            if let image = cache.object(forKey: key) {
                cell.usernameButton.update(name: visit.person?.username ?? "User", color: visit.accountColor, image: image)
            } else {
                cell.usernameButton.startImageSkeleton()
                
                Network.shared.getImage(url: imageUrl) { (imageFound) in
                    cell.usernameButton.endImageSkeleton()
                    if let imageFound = imageFound {
                        cache.setObject(imageFound, forKey: key)
                        // make cell still needs to be updated for the correct person (i.e. could take a while to load and set on the wrong dequed cell)
                        if let id = cell.visit?.person?.id, id == personId {
                            cell.usernameButton.update(name: visit.person?.username ?? "User", color: visit.accountColor, image: imageFound)
                        }
                    } else {
                        cell.usernameButton.update(name: visit.person?.username ?? "User", color: visit.accountColor, image: UIImage.personImage)
                    }
                }
            }
        } else {
            // doesn't have an image
            cell.usernameButton.update(name: visit.person?.username ?? "User", color: visit.accountColor, image: UIImage.personImage)
        }
    }
    
    func removeImagesFromCacheFor(visit: Visit) {
        print("Remove images from cache: \(visit.djangoOwnID)")
        let mainKey = NSString(string: "\(visit.djangoOwnID)")
        imageCache?.removeObject(forKey: mainKey)
        alreadyRequestedCache.removeObject(forKey: mainKey)
        for visIdx in 0..<visit.otherImages.count {
            let otherKey = NSString(string: "\(visit.djangoOwnID)-\(visIdx)")
            otherImageCache.removeObject(forKey: otherKey)
        }
    }
    
}

// MARK: Table view
extension VisitTableView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard initialDataFound else {
            tableView.showLoadingOnTableView(middle: true)
            return 0
        }
        
        let count = visits.count
        if allowHintToCreateRestaurant && count == 0 {
            let addPostButton = self.setEmptyWithAction(message: "You do not have any posts yet. Add a post every time you eat at a restaurant.", buttonTitle: "Add post", area: .screenMiddle)
            addPostButton.addTarget(self, action: #selector(addNewPostSelector), for: .touchUpInside)
        }
        if allowHintForFriendsFeed && count == 0 {
            if Network.shared.loggedIn {
                // Say there are no visits... and no button
                self.setEmptyWithAction(message: "Your friends have not posted anything yet", buttonTitle: "", area: .screenMiddle)
            } else {
                // Tell the user to log in
                let createAccountButton = self.setEmptyWithAction(message: "You need to create an account in order to see your friends posts", buttonTitle: "Create account", area: .screenMiddle)
                createAccountButton.addTarget(self, action: #selector(goToCreateAccount), for: .touchUpInside)
            }
        }
        
        if count != 0 {
            tableView.restore(separatorStyle: .none)
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! VisitCell
        let visit = visits[indexPath.row]
        //let selectedIndex = photoIndexCache[visit.djangoOwnID]
        let selectedIndex = photoIndexCache.object(forKey: NSNumber(value: visit.djangoOwnID)) as? Int
        cell.setUpWith(visit: visit, selectedPhotoIndex: selectedIndex)
        cell.delegate = self
        
        
        if selectedIndex != nil {
            cell.delegate?.moreImageRequest(visit: visit, cell: cell)
        }
        
        let key = NSString(string: "\(visit.djangoOwnID)")
        
        // handle the main image
        let cellImageView = cell.visitImageView
        
        if let ratio = visit.mainImageRatio {
            cell.visitImageViewHeightConstraint?.constant = cell.standardImageWidth * ratio
        } else {
            cell.visitImageViewHeightConstraint?.constant = 0
        }
        
        cellImageView.image = nil
        if let image = imageCache?.object(forKey: key) {
            print("Already has image: \(key)")
            cellImageView.image = image
        } else if alreadyRequestedCache.object(forKey: key) == 1 {
            // Don't need to make a request again, image will find cell otherwise
            print("Already made a request: \(key)")
        } else {
            print("Doesn't have image: \(key)")
            cellImageView.appStartSkeleton()
            alreadyRequestedCache.setObject(1, forKey: key)
            Network.shared.getImage(url: visit.mainImage) { [weak self] (imageFound) in
                cellImageView.appEndSkeleton()
                guard let imageFound = imageFound, let self = self else { return }
                DispatchQueue.global(qos: .background).async {
                    let resized = imageFound.resizeToBeNoLargerThanScreenWidth()
                    DispatchQueue.main.async { [weak self] in
                        self?.imageCache?.setObject(resized, forKey: key)
                        if let cell = self?.cellFrom(visit: visit) {
                            // cell from visit will even find the cell if it is dequeued and added again
                            print("Got image, cell exist: \(key)")
                            cell.visitImageView.image = resized
                        }
                    }
                }
            }
        }
        
        // handle the profile image
        if mode == .friends {
            // always update to at least update name and color, at the beginning
            setProfileImage(visit: visit, cell: cell)
        } else {
            // should just hide the usernameButton
            cell.usernameButton.removeFromSuperview()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let visitSelected = visits[indexPath.row]
        
        guard let listPhotos = visitSelected.listPhotos, listPhotos.count > 0 else {
            self.findViewController()?.showMessage("No photos")
            return
        }
        
        var images: [(String, UIImage?)] = listPhotos.map({($0, nil)})
        // get the images from the selected visit and add them to what is being sent
        let id = visitSelected.djangoOwnID
        var counter = 0
        while counter < images.count {
            defer { counter += 1 }
            if counter == 0 {
                let key = NSString(string: "\(id)-main")
                images[counter].1 = imageCache?.object(forKey: key)
            } else {
                let key = NSString(string: "\(id)-\(counter-1)")
                images[counter].1 = otherImageCache.object(forKey: key)?.image
            }
        }
        
        let photosVC = PhotosVC(upperNavigationTitle: "Visit", images: images)
        self.findViewController()?.navigationController?.pushViewController(photosVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        animatedRefreshControl.updateProgress(with: scrollView.contentOffset.y)
        
        // find out when user is at bottom
        lastContentOffset = scrollView.contentOffset.y + self.bounds.height
            
        let tableViewHeight = scrollView.contentSize.height - (self.bounds.height / 2.0)
        
        if allowNextPage && lastContentOffset > tableViewHeight && Network.shared.loggedIn {
            visitTableViewDelegate?.nextPageRequested()
            allowNextPage = false
        }
    }
    
    
}

// MARK: VisitCellDelegate
extension VisitTableView: VisitCellDelegate {
    func personSelected(for visit: Visit) {
        guard let navigationController = self.findViewController()?.navigationController,
              let person = visit.person else { return }
        let vc = UserProfileVC(person: person)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func updatedVisit(visit: Visit) {
        
        let indexToUpdate = self.visits.firstIndex { $0.djangoOwnID == visit.djangoOwnID }
        if let idx = indexToUpdate {
            let indexPath = IndexPath(row: idx, section: 0)
            let visitToUpdate = visits[idx]
            visitToUpdate.rating = visit.rating
            visitToUpdate.comment = visit.comment
            visitToUpdate.tags = visit.tags
            guard let cellToUpdate = self.cellForRow(at: indexPath) as? VisitCell else { return }
            cellToUpdate.visit = visit
            
            cellToUpdate.update()
        }
    }
    
    func newPhotoIndexSelected(idx: Int, for visit: Visit?) {
        guard let visit = visit else { return }
        photoIndexCache.setObject(NSNumber(value: idx), forKey: NSNumber(value: visit.djangoOwnID))
    }
    
    func moreImageRequest(visit: Visit?, cell: VisitCell) {
        cell.otherImageViews.forEach({ $0.appEndSkeleton() })
        guard let visit = visit else { return }
        
        for (i, imageUrl) in visit.otherImages.map({$0.image}).enumerated() {
            let imageRequestKey = NSString(string: "\(visit.djangoOwnID)-\(i)")
            if let object = otherImageCache.object(forKey: imageRequestKey) {
                // already requested
                // if the image exists, add it to the imageView
                if let image = object.image {
                    print("Image already exists")
                    cell.otherImageViews[i].image = image
                }
            } else {
                
                let newObject = ImageRequest()
                otherImageCache.setObject(newObject, forKey: imageRequestKey)
                cell.otherImageViews.first?.appStartSkeleton()
                Network.shared.getImage(url: imageUrl) { [weak self] (imageFound) in
                    cell.otherImageViews.first?.appEndSkeleton()
                    if let image = imageFound {
                        DispatchQueue.global(qos: .background).async {
                            let resized = image.resizeToBeNoLargerThanScreenWidth()
                            DispatchQueue.main.async {
                                newObject.image = resized
                                if let cell = self?.cellFrom(visit: visit) {
                                    cell.otherImageViews[i].image = resized
                                }
                            }
                        }
                    } else {
                        // remove the value from the cache
                        print("Image not found for url: \(imageRequestKey), \(imageUrl)")
                        self?.otherImageCache.removeObject(forKey: imageRequestKey)
                    }
                }
            }
        }
    }
    
    func establishmentSelected(establishment: Establishment) {
        self.findViewController()?.navigationController?.pushViewController(EstablishmentDetailVC(establishment: establishment, delegate: nil, mode: .fullScreenBase), animated: true)
    }
    
    func delete(visit: Visit?) {
        guard let visit = visit else { return }
        Network.shared.deleteVisit(visit: visit) { (success) in return }
        
        let indexToDelete = self.visits.firstIndex { (v) -> Bool in
            v.djangoOwnID == visit.djangoOwnID
        }
        
        if let idx = indexToDelete {
            guard let cellToDelete = self.cellForRow(at: IndexPath(row: idx, section: 0)) as? VisitCell else { return }
        
            if cellToDelete.visit?.djangoOwnID == visit.djangoOwnID {
                self.visits.remove(at: idx)
                self.deleteRows(at: [IndexPath(row: idx, section: 0)], with: .automatic)
            }
        }
    }
}
