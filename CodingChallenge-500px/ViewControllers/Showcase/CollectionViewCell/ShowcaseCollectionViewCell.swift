//
//  ShowcaseCollectionViewCell.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/13.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import UIKit

class ShowcaseCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var imageView : UIImageView!
    
    public var imageUrls : [String]? {
        didSet { imageView.setImage(with: imageUrls?.first) }
    }
}

extension ShowcaseCollectionViewCell {
    func imageUrls(_ imageUrls: [String]) -> Self {
        self.imageUrls = imageUrls
        return self
    }
}
