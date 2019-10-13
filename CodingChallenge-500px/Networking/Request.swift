//
//  Request.swift
//  FiveHundred
//
//  Created by Hsuan-Chih Chuang on 2019/10/10.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import Foundation
import CoreData

// Request - The Networking Client
// A minimal networking client that to get the basics done
final class Request<Result: Decodable> {
    
    private var urlRequest : URLRequest
    
    public init(version: API.Version = .v1, endPoint: API.Endpoint, httpMethod: HTTPMethod = .get) {
        urlRequest = URLRequest(
            url: URL(string: API.baseUrl)!
                .appendingPathComponent(version.rawValue)
                .appendingPathComponent(endPoint.rawValue),
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10
        )
        urlRequest.addValue(API.consumerKey, forHTTPHeaderField: "consumer_key")
    }
    
    public func fire(_ onCompletion: ((Response<Result>)->Void)?) {
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            switch (error, (response as? HTTPURLResponse)?.statusCode, data) {
            case (.some(let error), _, _):
                onCompletion?(.failure(error))
            case (.none, .some(let statusCode), _) where !(200...299).contains(statusCode):
                onCompletion?(.failure(Response<Result>.Error.httpStatus(statusCode)))
            case (.none, _, .some(let data)):
                do { onCompletion?(.success(try self.decode(data: data)))
                } catch { onCompletion?(.failure(error)) }
            default:
                break
            }
        }.resume()
    }
    
    private func decode(data: Data) throws -> Result {
        let managedObjectContext = CoreDataStack.shared.newBackgroundContext
            .mergePolicy(NSMergeByPropertyObjectTrumpMergePolicy)
        let result = try JSONDecoder()
            .userinfo(key: CodingUserInfoKey.managedObjectContext!, value: managedObjectContext)
            .decode(Result.self, from: data)
        if managedObjectContext.hasChanges {
            try managedObjectContext.save()
        }
        return result
    }
}


// MARK: Request HTTP Methods
extension Request {
    public enum HTTPMethod : String {
        case get, post, update, delete
    }
}

// MARK: Request Builder
extension Request {
    public func resourceParameter(_ param: ResourceParameterDecodable) -> Self {
        let (key, value) = param.decode
        return httpHeader(key: key, value: value)
    }
    public func httpHeader(key: String, value: String) -> Self {
        urlRequest.addValue(value, forHTTPHeaderField: key)
        return self
    }
    public func body<Body: Encodable>(_ body: Body) throws -> Self {
        urlRequest.httpBody = try JSONEncoder().encode(body)
        return self
    }
    public func timeoutInterval(_ timeoutInterval: TimeInterval) -> Self {
        urlRequest.timeoutInterval = timeoutInterval
        return self
    }
}
