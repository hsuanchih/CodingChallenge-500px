//
//  UITapGestureRecognizer+Builder.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/18.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import UIKit

extension UITapGestureRecognizer {
    
    public func numberOfTapsRequired(_ numberOfTapsRequired: Int) -> Self {
        self.numberOfTapsRequired = numberOfTapsRequired
        return self
    }
    
    public func requireOtherGestureRecognizer(toFail otherGestureRecognizer: UIGestureRecognizer?) -> Self {
        if let otherGestureRecognizer = otherGestureRecognizer {
            require(toFail: otherGestureRecognizer)
        }
        return self
    }
}
