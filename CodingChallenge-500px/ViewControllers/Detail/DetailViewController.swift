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
    
    @IBOutlet weak var dismissButton : UIButton!
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var imageHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var avatarImageView : UIImageView!
    @IBOutlet weak var photonameLabel : UILabel!
    @IBOutlet weak var usernameLabel : UILabel!
    
    
    private let managedObjectContext = CoreDataStack.shared.newBackgroundContext
    public private(set) var indexPath : IndexPath?
    private var managedObjectID : NSManagedObjectID?
    private var onDismissed: ((IndexPath)->Void)?
    
    private func imageHeight(from photo: Photo) -> CGFloat {
        return CGFloat(photo.height)*view.bounds.width/CGFloat(photo.width)
    }
    private var photo : Photo? {
        didSet {
            if let photo = photo, photo != oldValue {
                imageHeightConstraint.constant = imageHeight(from: photo)
                imageView.setImage(with: photo.imageUrls.first)
                photonameLabel.text = photo.name
                if let user = try? managedObjectContext.fetch(User.fetchRequest().predicate(NSPredicate(format: "\(#keyPath(User.id)) = %ld", photo.userID))).first as? User {
                    self.user = user
                }
            }
        }
    }
    
    private var user : User? {
        didSet {
            if let user = user, user != oldValue {
                avatarImageView.setImage(with: user.avatarUrl)
                usernameLabel.text = user.fullname
            }
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
        if let managedObjectID = managedObjectID {
            photo = managedObjectContext.object(with: managedObjectID) as? Photo
        }
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        switch sender {
        case dismissButton:
            if let indexPath = indexPath {
                onDismissed?(indexPath)
            }
            dismiss(animated: true)
        default:
            break
        }
    }
}
