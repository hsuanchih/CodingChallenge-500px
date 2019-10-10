//
//  ProjectResource.swift
//  FiveHundred
//
//  Created by Hsuan-Chih Chuang on 2019/10/10.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import Foundation

// ProjectResource
// A helper for accessing project resources
struct ProjectResource {
    
    private init() {}
    
    public static func contentsOf(file: String, type: String) -> String {
        guard let path = Bundle.main.path(forResource: file, ofType: type)
            else { fatalError("File missing - \"\(file).\(type)\"") }
        do {
            return try String(contentsOf: URL(fileURLWithPath: path))
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
