//
//  Response.swift
//  FiveHundred
//
//  Created by Hsuan-Chih Chuang on 2019/10/10.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import Foundation

// Response
// Handles response & failures in a single type
public enum Response<Result> {
    case success(Result)
    case failure(Swift.Error)
    
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    public var result: Result? {
        switch self {
        case .success(let result):
            return result
        case .failure:
            return nil
        }
    }

    public var error: Swift.Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}


// MARK: Network Response Errors
extension Response {
    public enum `Error` : Swift.Error {
        case httpStatus(Int)
    }
}
