//
//  UIImage+CircularImage.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/16.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import UIKit

extension UIImage {
    
    public var circularImage : UIImage {
        let newDimension = min(size.width, size.height),
        newRect = CGRect(origin: .zero, size: CGSize(width: newDimension, height: newDimension))
        UIGraphicsBeginImageContextWithOptions(newRect.size, false, 1)
        UIBezierPath(roundedRect: newRect, cornerRadius: newRect.width/2).addClip()
        draw(in: newRect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
