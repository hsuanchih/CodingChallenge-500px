//
//  UIImageView+SetImage.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/13.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import UIKit

// UIImageView extension to load an image on an UIImageView given the image's url
// while fetch from remote and local image caching happens behind the scenes
extension UIImageView {
    
    public func setImage(with urlString: String?) {
        ImageCache.image(with: urlString) {
            if case let .success(image) = $0 {
                DispatchQueue.main.async { self.image = image }
            }
        }
    }
}
