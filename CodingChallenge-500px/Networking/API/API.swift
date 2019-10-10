//
//  API.swift
//  FiveHundred
//
//  Created by Hsuan-Chih Chuang on 2019/10/10.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import Foundation

struct API {
    public static let baseUrl = "https://api.500px.com"
    public static let consumerKey = ProjectResource.contentsOf(file: "consumer_key", type: "txt")
}
