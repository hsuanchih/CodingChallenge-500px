//
//  NSManagedObjectContext+Builder.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/12.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    public func mergePolicy(_ mergePolicy: AnyObject) -> Self {
        self.mergePolicy = mergePolicy
        return self
    }
}
