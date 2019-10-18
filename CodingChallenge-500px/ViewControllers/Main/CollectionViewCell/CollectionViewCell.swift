//
//  CollectionViewCell.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/17.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import UIKit

final class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var titleLabel : UILabel!
    @IBInspectable var cornerRadius : CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
}

extension CollectionViewCell {
    func feature(_ feature: ResourceParameter.Photos.Feature) -> Self {
        titleLabel.text = feature.titleString
        return self
    }
}
