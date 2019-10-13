//
//  CoreData+Decoder.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/11.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import Foundation
import CoreData


// MARK: Custom-defined CodingUserInfoKey to attach a ManagedObjectContext to  JSONDecoder
extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}

// MARK: Helper to build JSONDecoder's userInfo dictionary
extension JSONDecoder {
    public func userinfo(key: CodingUserInfoKey, value: Any) -> Self {
        userInfo[key] = value
        return self
    }
}

// MARK: NSManagedObject's convenience initializer to match the Decoder protocol
extension NSManagedObject {
    convenience init(from decoder: Decoder, userInfoKey: CodingUserInfoKey) {
        let entityName = String(describing: type(of: self))
        guard let managedObjectContext = decoder.userInfo[userInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext) else {
            fatalError("Error decoding \(entityName)")
        }
        self.init(entity: entity, insertInto: managedObjectContext)
    }
}
