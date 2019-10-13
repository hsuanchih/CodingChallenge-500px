//
//  Image.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/12.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import Foundation

struct Image : Decodable {
    public let format  : Format
    public let size    : Int
    public let url     : String
}

extension Image {
    public enum Format : String, Decodable {
        case jpeg
        case png
    }
}
