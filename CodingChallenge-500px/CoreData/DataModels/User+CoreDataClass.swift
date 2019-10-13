//
//  User+CoreDataClass.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/11.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//
//

import Foundation
import CoreData

@objc(User)
final public class User: NSManagedObject, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id, fullname, userpic_url
    }
    public required convenience init(from decoder: Decoder) throws {
        self.init(from: decoder, userInfoKey: CodingUserInfoKey.managedObjectContext!)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        fullname = try container.decode(String.self, forKey: .fullname)
        avatarUrl = try container.decode(String.self, forKey: .userpic_url)
    }
}
