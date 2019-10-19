//
//  PersistentStore.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/12.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import Foundation

// MARK: The PersistentStore facilitates saving files to and getting files from either the documents or the caches directory
public struct PersistentStore {
    
    public enum `Type` {
        case document
        case cache
        var directory : FileManager.SearchPathDirectory {
            switch self {
            case .document:
                return .documentDirectory
            case .cache:
                return .cachesDirectory
            }
        }
    }
    public enum `Error` : Swift.Error {
        case contentNotFound
    }
    
    // The file cache is used to speed up file access if the file has been faulted into memory
    private static let fileCache = NSCache<NSString, NSData>()
    
    // Concurrent dispatch queue to facilitate concurrent reads & exclusive writes
    private static let dispatchQueue = DispatchQueue(label: String(format: "%@.queue", String(describing: PersistentStore.self)), qos: .userInitiated, attributes: [.concurrent])
    
    public static func save(data: Data, to fileName: String, in storeType: Type, overwrite: Bool = true, onCompletion: ((Swift.Error?)->Void)? = nil) {
        dispatchQueue.async(flags: .barrier) {
            do {
                let url = try self.url(for: storeType).appendingPathComponent(fileName, isDirectory: false)
                if !overwrite && FileManager.default.fileExists(atPath: url.path) { return }
                try remove(file: fileName, from: storeType)
                FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
                onCompletion?(nil)
            } catch {
                onCompletion?(error)
            }
        }
    }
    
    public static func retrieveData(file named: String, from storeType: Type, onCompletion: @escaping (Response<Data>)->Void) {
        dispatchQueue.async {
            switch fileCache.object(forKey: named as NSString) as Data? {
            case .some(let data):
                onCompletion(Response.success(data as Data))
            case .none:
                do {
                    if let data = FileManager.default.contents(atPath: try url(for: storeType).appendingPathComponent(named, isDirectory: false).path) {
                        fileCache.setObject(NSData(data: data), forKey: named as NSString)
                        onCompletion(Response.success(data as Data))
                    } else {
                        onCompletion(Response.failure(Error.contentNotFound))
                    }
                } catch { onCompletion(Response.failure(error)) }
            }
        }
    }
    
    public static func remove(file named: String, from storeType: Type, onCompletion: ((Swift.Error?)->Void)? = nil) {
        dispatchQueue.async(flags: .barrier) {
            do {
                try remove(file: named, from: storeType)
                onCompletion?(nil)
            } catch {
                onCompletion?(error)
            }
        }
    }
    
    public static func clear(_ storeType: Type, onCompletion: ((Swift.Error?)->Void)? = nil) {
        dispatchQueue.async(flags: .barrier) {
            do {
                try FileManager.default.contentsOfDirectory(
                    at: try url(for: storeType),
                    includingPropertiesForKeys: nil,
                    options: []).forEach {
                    try FileManager.default.removeItem(at: $0)
                }
                fileCache.removeAllObjects()
                onCompletion?(nil)
            } catch {
                onCompletion?(error)
            }
        }
    }
    
    
    private init() {}
    
    private static func url(for storeType: Type) throws -> URL {
        return try FileManager.default.url(for: storeType.directory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    private static func remove(file named: String, from storeType: Type) throws {
        let url = try self.url(for: storeType).appendingPathComponent(named, isDirectory: false)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
            fileCache.removeObject(forKey: named as NSString)
        }
    }
}
