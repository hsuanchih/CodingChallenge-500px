//
//  Photos.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/10.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import Foundation

struct Photos {
    let currentPage : Int
    let totalPages : Int
}

extension Photos : Decodable {
    
    enum CodingKeys: String, CodingKey {
        case current_page, total_pages, photos
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentPage = try container.decode(Int.self, forKey: .current_page)
        totalPages = try container.decode(Int.self, forKey: .total_pages)
        _ = try container.decode([Photo].self, forKey: .photos)
    }
}
