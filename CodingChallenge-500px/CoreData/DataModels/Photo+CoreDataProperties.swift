//
//  Photo+CoreDataProperties.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/11.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//
//

import Foundation
import CoreData

extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }
    @NSManaged public var id        : Int64
    @NSManaged public var name      : String
    @NSManaged public var width     : Int16
    @NSManaged public var height    : Int16
    @NSManaged public var userID    : Int64
    @NSManaged public var imageUrls : [String]
}


