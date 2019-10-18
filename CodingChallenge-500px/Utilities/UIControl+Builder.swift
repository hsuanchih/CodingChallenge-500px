//
//  UIControl+Builder.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/13.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import UIKit

extension UIControl {
    func with(target: Any?, action: Selector, for controlEvents: UIControl.Event) -> Self {
        addTarget(target, action: action, for: controlEvents)
        return self
    }
}
