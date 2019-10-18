//
//  NSBatchDeleteRequest+Builder.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/14.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import Foundation
import CoreData

extension NSBatchDeleteRequest {
    public func resultType(_ resultType: NSBatchDeleteRequestResultType) -> Self {
        self.resultType = resultType
        return self
    }
}
