//
//  NSFetchRequest+Builder.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/11.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import Foundation
import CoreData

extension NSFetchRequest {
    
    @objc public convenience init(entity: NSManagedObject.Type) {
        self.init(entityName: String(describing: entity.self))
    }
    
    @objc public func predicate(_ predicate: NSPredicate?) -> NSFetchRequest {
        self.predicate = predicate
        return self
    }
    
    @objc public func sortDescriptors(_ sortDescriptors: [NSSortDescriptor]?) -> NSFetchRequest {
        self.sortDescriptors = sortDescriptors
        return self
    }
}
