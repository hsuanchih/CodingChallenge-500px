//
//  DetailViewController.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/13.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import UIKit
import CoreData

final class DetailViewController: UIViewController {
    
    @IBOutlet private weak var headerView : UIView!
    @IBOutlet private weak var headerViewHeightConstraint : NSLayoutConstraint!
    @IBOutlet private weak var dismissButton : UIButton!
    @IBOutlet private weak var scrollView: UIScrollView! {
        didSet {
            for numTapsRequired in (1...2).reversed() {
                scrollView.addGestureRecognizer(
                    UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped(_:))).numberOfTapsRequired(numTapsRequired).requireOtherGestureRecognizer(toFail: scrollView.gestureRecognizers?.last)
                )
            }
        }
    }
    @IBOutlet private weak var imageView : UIImageView!
    @IBOutlet private weak var userProfileView : UIView!
    @IBOutlet private weak var userProfileViewHeightConstraint : NSLayoutConstraint!
    @IBOutlet private weak var avatarImageView : UIImageView!
    @IBOutlet private weak var photonameLabel : UILabel!
    @IBOutlet private weak var usernameLabel : UILabel!
    
    public private(set) var indexPath : IndexPath?
    private var onDismissed: ((IndexPath)->Void)?
    private var managedObjectID : NSManagedObjectID?
    private let managedObjectContext = CoreDataStack.shared.newBackgroundContext
    
    private var photo : Photo? {
        didSet {
            guard let photo = photo, photo != oldValue else { return }
            photonameLabel.text = photo.name
            imageView.setImage(with: photo.imageUrls.first) { _ in
                self.imageView.setImage(with: photo.imageUrls.last)
            }
        }
    }
    
    private func getUserByID(_ userID: Int64, onCompletion: @escaping (User?)->Void) {
        managedObjectContext.perform {
            do {
                onCompletion(
                    try self.managedObjectContext.fetch(
                        User.fetchRequest().predicate(NSPredicate(format: "\(#keyPath(User.id)) = %ld", userID))
                    ).first as? User
                )
            } catch { onCompletion(nil) }
        }
    }
    private var user : User? {
        didSet {
            guard let user = user, user != oldValue else { return }
            avatarImageView.setImage(with: user.avatarUrl)
            usernameLabel.text = user.fullname
        }
    }
    
    public convenience init(indexPath: IndexPath, managedObjectID: NSManagedObjectID, onDismissed: ((IndexPath)->Void)? = nil) {
        self.init(nibName: String(describing: type(of: self)), bundle: .main)
        self.indexPath = indexPath
        self.managedObjectID = managedObjectID
        self.onDismissed = onDismissed
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard UIDevice.current.orientation.isValidInterfaceOrientation else { return }
        setAccessoryViewVisibility(!UIDevice.current.orientation.isLandscape)
        scrollView.setZoomScale(1, animated: true)
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    private func loadData() {
        guard let managedObjectID = managedObjectID, let photo = managedObjectContext.object(with: managedObjectID) as? Photo else {
            return
        }
        self.photo = photo
        getUserByID(photo.userID) { (user) in
            DispatchQueue.main.async { self.user = user }
        }
    }
    
    // MARK: Button Handler
    @IBAction func buttonTapped(_ sender: UIButton) {
        switch sender {
        case dismissButton:
            if let indexPath = indexPath { onDismissed?(indexPath) }
            dismiss(animated: true)
        default:
            break
        }
    }
    
    // MARK: Scroll View Tap Gesture Handler
    @objc func scrollViewTapped(_ sender: UITapGestureRecognizer) {
        switch (sender.numberOfTapsRequired, UIDevice.current.orientation.isLandscape) {
        case (1, false) : setAccessoryViewVisibility(headerView.isHidden)
        case (2, _)     : scrollView.setZoomScale(1, animated: true)
        default: break
        }
    }
    
    // MARK: Accessory View Visibility
    private func setAccessoryViewVisibility(_ visible: Bool) {
        setVisibility(visible, views: headerView, userProfileView)
        headerViewHeightConstraint.constant = visible ? 44 : 0
        userProfileViewHeightConstraint.constant = visible ? 70 : 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    private func setVisibility(_ visible: Bool, views: UIView...) {
        views.forEach { $0.isHidden = !visible }
    }
}


// MARK: UIScrollViewDelegate
extension DetailViewController : UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
