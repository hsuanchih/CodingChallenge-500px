//
//  ResourceParameter.swift
//  FiveHundred
//
//  Created by Hsuan-Chih Chuang on 2019/10/10.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import Foundation

// ResourceParameter
// An error-safe way to add parameters to network requests
struct ResourceParameter {}

protocol ResourceParameterDecodable {
    var decode : (key: String, value: String) { get }
}
