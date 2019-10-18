//
//  ViewController.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/10.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    @IBOutlet private weak var collectionView : UICollectionView! {
        didSet { collectionView.register(with: collectionViewCellType) }
    }
    private let collectionViewCellType = CollectionViewCell.self
    private let features = ResourceParameter.Photos.Feature.allCases
    private let numItemsPerRow : CGFloat = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Discover"
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let width = (collectionView.bounds.width - (flowLayout.sectionInset.left + flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing*(numItemsPerRow-1)))/numItemsPerRow
        return CGSize(width: width, height: width)
    }
}

// MARK: UICollectionViewDelegate
extension ViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.pushViewController(
            ShowcaseViewController(features[indexPath.item]),
            animated: true
        )
    }
}

// MARK: UICollectionViewDataSource
extension ViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return features.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(with: collectionViewCellType, for: indexPath).feature(features[indexPath.item])
    }
}
