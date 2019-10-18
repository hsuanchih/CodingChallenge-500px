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
    private var urlComponents = URLComponents()
    
    public init(version: API.Version = .v1, endPoint: API.Endpoint, httpMethod: HTTPMethod = .get) {
        urlRequest = URLRequest(
            url: URL(string: API.baseUrl)!
                .appendingPathComponent(version.rawValue)
                .appendingPathComponent(endPoint.rawValue),
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10
        )
        urlComponents = URLComponents(string: endPoint.rawValue)!
        urlRequest.addValue(API.consumerKey, forHTTPHeaderField: "consumer_key")
    }
    
    public var constructUrlRequest : URLRequest {
        if let query = urlComponents.query, let urlString = urlRequest.url?.absoluteString {
            urlRequest.url = URL(string: String(format: "%@?%@", urlString, query))
        }
        return urlRequest
    }
    
    public func fire(_ onCompletion: ((Response<Result>)->Void)?) {
        URLSession.shared.dataTask(with: constructUrlRequest) { (data, response, error) in
            switch (error, (response as? HTTPURLResponse)?.statusCode, data) {
            case (.some(let error), _, _):
                onCompletion?(.failure(error))
            case (.none, .some(let statusCode), _) where !(200...299).contains(statusCode):
                onCompletion?(.failure(Response<Result>.Error.httpStatus(statusCode)))
            case (.none, _, .some(let data)):
                self.decode(
                    data: data,
                    with: CoreDataStack.shared.newBackgroundContext
                        .mergePolicy(NSMergeByPropertyObjectTrumpMergePolicy),
                    onCompletion: onCompletion
                )
            default:
                break
            }
        }.resume()
    }
    
    private func decode(data: Data, with context: NSManagedObjectContext? = nil, onCompletion: ((Response<Result>)->Void)? = nil) {
        if let context = context {
            context.perform {
                do {
                    let result = try JSONDecoder()
                        .userinfo(key: CodingUserInfoKey.managedObjectContext!, value: context)
                        .decode(Result.self, from: data)
                    if context.hasChanges {
                        try context.save()
                    }
                    onCompletion?(Response.success(result))
                } catch {
                    onCompletion?(Response.failure(error))
                }
            }
        } else {
            do {
                onCompletion?(Response.success(try JSONDecoder().decode(Result.self, from: data)))
            } catch {
                onCompletion?(Response.failure(error))
            }
        }
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
        let (key, value) = param.decode, queryItem = URLQueryItem(name: key, value: value)
        if let _ = urlComponents.queryItems {
            urlComponents.queryItems?.append(queryItem)
        } else {
            urlComponents.queryItems = [queryItem]
        }
        return self
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
