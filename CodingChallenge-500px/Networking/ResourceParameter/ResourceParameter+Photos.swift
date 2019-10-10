//
//  ResourceParameter+Photos.swift
//  FiveHundred
//
//  Created by Hsuan-Chih Chuang on 2019/10/10.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import Foundation

extension ResourceParameter {
    public enum Photos {
        case feature(Feature)
        case only(Category)
        case exclude(Category)
        case page(Int)
        case tags(Bool)
    }
}

extension ResourceParameter.Photos {
    public enum Feature : String {
        case popular, highest_rated, upcoming, editors, fresh_today, fresh_yesterday, fresh_week
    }
    public enum Category : Int {
        case uncategorized, celebrities, film, journalism, nude, blackAndWhite, stillLife, people, landscapes,
        cityAndArchitecture, abstract, animals, macro, travel, fashion, commercial, concert, sport, nature, performingArts,
        family, street, underWater, food, fineArt, wedding, transportation, urbanExplore, ariel = 29, night
    }
}

extension ResourceParameter.Photos : ResourceParameterDecodable {
    public var decode : (key: String, value: String) {
        switch self {
        case .feature(let feature):
            return ("feature", feature.rawValue)
        case .only(let category):
            return ("only", String(category.rawValue))
        case .exclude(let category):
            return ("exclude", String(category.rawValue))
        case .page(let number):
            return ("page", String(number))
        case .tags(let bool):
            return ("tags", String(bool ? 1:0))
        }
    }
}
