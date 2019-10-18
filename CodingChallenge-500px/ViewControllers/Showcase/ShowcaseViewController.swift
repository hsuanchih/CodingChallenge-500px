//
//  ShowcaseViewController.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/13.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import UIKit
import CoreData

final class ShowcaseViewController: UIViewController {

    @IBOutlet private weak var collectionView : UICollectionView! {
        didSet {
            collectionView.register(with: collectionViewCellType)
            collectionView.addSubview(
                UIRefreshControl().with(target: self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
            )
        }
    }
    private let collectionViewCellType = ShowcaseCollectionViewCell.self
    private let numItemsPerRow : CGFloat = 3
    
    // UIPageViewController
    // Supports navigation between DetailViewControllers
    private lazy var pageViewController : UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController.modalPresentationStyle = .overCurrentContext
        pageViewController.modalTransitionStyle = .crossDissolve
        pageViewController.dataSource = self
        return pageViewController
    }()
    
    // NSFetchedResultsController
    // Coordinates between core data fetched results and collection view data source
    private var blockOperations : [BlockOperation] = []
    private lazy var fetchedResultsController : NSFetchedResultsController<Photo> = {
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: Photo.fetchRequest()
                .sortDescriptors([NSSortDescriptor(key: #keyPath(Photo.creationDate), ascending: true)]),
            managedObjectContext: CoreDataStack.shared.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    // DataProvider
    // Fetches data from remote and saves results to Core Data
    private var dataProvider : DataProvider?
    private var feature: ResourceParameter.Photos.Feature = .popular
    public convenience init(_ feature: ResourceParameter.Photos.Feature) {
        self.init(nibName: String(describing: type(of: self)), bundle: .main)
        self.feature = feature
        dataProvider = DataProvider(feature: feature, itemsPerPage: 40)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = feature.titleString
        try? self.fetchedResultsController.performFetch()
        dataProvider?.loadData()
    }
    
    @objc func pullToRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.isUserInteractionEnabled = false
        dataProvider?.delete(fetchedResultsController.fetchedObjects)
        dataProvider?.loadData(onCompletion: { _ in
            DispatchQueue.main.async {
                refreshControl.endRefreshing()
                refreshControl.isUserInteractionEnabled = true
            }
        })
    }
    
    deinit {
        dataProvider?.delete(fetchedResultsController.fetchedObjects)
        blockOperations.forEach { $0.cancel() }
        blockOperations.removeAll()
    }
}

// MARK: UICollectionViewDataSource
extension ShowcaseViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (fetchedResultsController.sections?[section])?.numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(with: collectionViewCellType, for: indexPath).imageUrls(fetchedResultsController.object(at: indexPath).imageUrls)
    }
}

// MARK: UICollectionViewDelegate
extension ShowcaseViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pageViewController.setViewControllers(
            [DetailViewController(indexPath: indexPath, managedObjectID: fetchedResultsController.object(at: indexPath).objectID)],
            direction: .forward,
            animated: false
        )
        present(pageViewController, animated: true)
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ShowcaseViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let width = (collectionView.bounds.width - (flowLayout.sectionInset.left +
            flowLayout.sectionInset.right +
            flowLayout.minimumInteritemSpacing*(numItemsPerRow-1)))/numItemsPerRow
        return CGSize(width: width, height: width)
    }
}

// MARK: UICollectionViewDataSourcePrefetching
extension ShowcaseViewController : UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        dataProvider?.loadData(at: indexPaths)
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension ShowcaseViewController : NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type, indexPath, newIndexPath) {
        case (.insert, _, .some(let newIndexPath)):
            blockOperations.append(BlockOperation { [weak self] in
                 self?.collectionView?.insertItems(at: [newIndexPath])
            })
        case (.delete, .some(let indexPath), _):
            blockOperations.append(BlockOperation { [weak self] in
                self?.collectionView?.deleteItems(at: [indexPath])
            })
        case (.update, .some(let indexPath), _):
            blockOperations.append(BlockOperation { [weak self] in
                self?.collectionView?.reloadItems(at: [indexPath])
            })
        case let (.move, .some(indexPath), .some(newIndexPath)):
            blockOperations.append(BlockOperation { [weak self] in
                self?.collectionView?.moveItem(at: indexPath, to: newIndexPath)
            })
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            self.blockOperations.forEach { $0.start() }
        }) {
            if $0 { self.blockOperations.removeAll() }
        }
    }
}

// MARK: UIPageViewControllerDataSource
extension ShowcaseViewController : UIPageViewControllerDataSource {
    
    private enum PageDirection {
        case before, after
    }
    private func viewController(_ direction: PageDirection, _ indexPath: IndexPath?) -> UIViewController? {
        var nextItem : Int?
        switch (direction, indexPath?.item) {
        case (.before, .some(let item)) where item > 0:
            nextItem = item-1
        case (.after, .some(let item)) where item < (fetchedResultsController.fetchedObjects?.count ?? 0)-1:
            nextItem = item+1
        default:
            break
        }
        if let nextItem = nextItem {
            let nextIndexPath = IndexPath(item: nextItem, section: 0)
            return DetailViewController(indexPath: nextIndexPath, managedObjectID: fetchedResultsController.object(at: nextIndexPath).objectID, onDismissed: { [weak self] in
                self?.collectionView.scrollToItem(at: $0, at: .centeredVertically, animated: false)
            })
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return self.viewController(.before, (viewController as? DetailViewController)?.indexPath)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return self.viewController(.after, (viewController as? DetailViewController)?.indexPath)
    }
}
