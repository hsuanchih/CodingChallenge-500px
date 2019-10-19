//
//  UINavigationController+DeviceOrientation.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/19.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    open override var shouldAutorotate : Bool {
        return true
    }
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return visibleViewController is UIPageViewController ? .all : .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return .portrait
    }
}
