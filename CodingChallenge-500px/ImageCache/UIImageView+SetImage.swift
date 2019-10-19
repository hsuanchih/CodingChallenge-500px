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
    
    public func setImage(with urlString: String?, onCompletion: ((Error?)->Void)? = nil) {
        ImageCache.image(with: urlString) {
            switch $0 {
            case .success(let image):
                DispatchQueue.main.async { self.image = image }
                onCompletion?(nil)
            case .failure(let error):
                onCompletion?(error)
            }
        }
    }
}
