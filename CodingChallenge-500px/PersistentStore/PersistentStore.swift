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
    
    // The file cache is used to speed up file access if the file has been faulted into memory
    private static let fileCache = NSCache<NSString, NSData>()
    
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
    
    private init() {}
    private static func url(for storeType: Type) throws -> URL {
        return try FileManager.default.url(for: storeType.directory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    public static func save(data: Data, to fileName: String, in storeType: Type, overwrite: Bool = true) throws {
        let url = try self.url(for: storeType).appendingPathComponent(fileName, isDirectory: false)
        if !overwrite && FileManager.default.fileExists(atPath: url.path) { return }
        try remove(file: fileName, from: storeType)
        FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
    }
    
    public static func retrieveData(file named: String, from storeType: Type) throws -> Data? {
        if let data = fileCache.object(forKey: named as NSString) {
            return data as Data
        }
        if let data = FileManager.default.contents(atPath: try url(for: storeType).appendingPathComponent(named, isDirectory: false).path) {
            fileCache.setObject(NSData(data: data), forKey: named as NSString)
            return data
        }
        return nil
    }
    
    public static func remove(file named: String, from storeType: Type) throws {
        let url = try self.url(for: storeType).appendingPathComponent(named, isDirectory: false)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
            fileCache.removeObject(forKey: named as NSString)
        }
    }
    
    public static func clear(_ storeType: Type) throws {
        try FileManager.default.contentsOfDirectory(
            at: try url(for: storeType),
            includingPropertiesForKeys: nil,
            options: []).forEach {
            try FileManager.default.removeItem(at: $0)
        }
        fileCache.removeAllObjects()
    }
}
