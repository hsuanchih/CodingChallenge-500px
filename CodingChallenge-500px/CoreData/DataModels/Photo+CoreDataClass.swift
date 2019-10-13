//
//  Photo+CoreDataClass.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/11.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Photo)
final public class Photo: NSManagedObject, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id, name, width, height, user_id, user, images
    }
    public required convenience init(from decoder: Decoder) throws {
        self.init(from: decoder, userInfoKey: CodingUserInfoKey.managedObjectContext!)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        width = try container.decode(Int16.self, forKey: .width)
        height = try container.decode(Int16.self, forKey: .height)
        userID = try container.decode(Int64.self, forKey: .user_id)
        imageUrls = try container.decode([Image].self, forKey: .images).map { $0.url }
        _ = try container.decode(User.self, forKey: .user)
    }
}
