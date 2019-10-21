//
//  CoreDataTests.swift
//  CodingChallenge-500pxTests
//
//  Created by Hsuan-Chih Chuang on 2019/10/20.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import XCTest
import CoreData
@testable import CodingChallenge_500px

class CoreDataTests: XCTestCase {
    
    let mainContext = CoreDataStack.shared.mainContext
    let backgroundContext = CoreDataStack.shared.mainBackgroundContext

    override func setUp() {
        super.setUp()
        try! CoreDataStack.shared.clearAll()
        insertStubs()
    }

    override func tearDown() {
        try! CoreDataStack.shared.clearAll()
        super.tearDown()
    }
    
    func testInsertSameContext() {
        let insertID : Int64 = 7
        backgroundContext.performAndWait {
            Photo.mock(id: insertID, in: self.backgroundContext)
            do {
                let inserted = try self.backgroundContext
                .fetch(Photo.fetchRequest().predicate(NSPredicate(format: "\(#keyPath(Photo.id)) = %ld", insertID)))
                XCTAssertFalse(inserted.isEmpty)
            } catch { XCTAssert(false, error.localizedDescription) }
        }
    }
    
    func testInsertDifferentContext() {
        let insertID : Int64 = 11
        
        backgroundContext.performAndWait {
            Photo.mock(id: insertID, in: self.backgroundContext)
        }
        do {
            let inserted = try mainContext
            .fetch(Photo.fetchRequest().predicate(NSPredicate(format: "\(#keyPath(Photo.id)) = %ld", insertID)))
            XCTAssertFalse(inserted.isEmpty)
        } catch {
            XCTAssert(false, error.localizedDescription)
        }
    }
    
    func testUpdateWithSameID_UniqueConstraintValidation() {
        var photoCount = 0
        
        backgroundContext.performAndWait {
            do {
                let photos = try self.backgroundContext.fetch(Photo.fetchRequest())
                photoCount = photos.count
                XCTAssertNotEqual(photoCount, 0)
                let photo = photos.randomElement()! as! Photo, userID = photo.userID
                Photo.mock(id: photo.id, in: self.backgroundContext)
                User.mock(id: userID, in: self.backgroundContext)
            } catch {
                XCTAssert(false, error.localizedDescription)
            }
        }
        
        do {
            let photos = try mainContext.fetch(Photo.fetchRequest()),
            users = try mainContext.fetch(User.fetchRequest())
            XCTAssertEqual(photos.count, photoCount)
            XCTAssertEqual(users.count, photoCount)
        } catch {
            XCTAssert(false, error.localizedDescription)
        }
    }
    
    func testUpdateWithSameID_mergePolicyValidation() {
        var oldPhoto : (id: Int64, name: String)?
        
        backgroundContext.performAndWait {
            do {
                if let photo = (try self.backgroundContext.fetch(Photo.fetchRequest())).randomElement() as? Photo {
                    oldPhoto = (photo.id, photo.name)
                    Photo.mock(id: photo.id, in: self.backgroundContext)
                }
            } catch {
                XCTAssert(false, error.localizedDescription)
            }
        }
        XCTAssertNotNil(oldPhoto)
        do {
            if let fetched = try mainContext.fetch(Photo.fetchRequest().predicate(NSPredicate(format: "\(#keyPath(Photo.id)) = %ld", oldPhoto!.id))).first as? Photo {
                XCTAssertNotEqual(fetched.name, oldPhoto!.name)
            } else { XCTAssertNotNil(nil) }
        } catch {
            XCTAssert(false, error.localizedDescription)
        }
    }
    
    func testBatchDelete() {
        let expect = expectation(description: "\(#function)")
        CoreDataStack.shared.delete(Photo.self) { (error) in
            XCTAssertNil(error, error!.localizedDescription)
            self.backgroundContext.perform {
                do {
                    let photos = try self.backgroundContext.fetch(Photo.fetchRequest())
                    XCTAssert(photos.isEmpty)
                    expect.fulfill()
                } catch {
                    XCTAssert(false, error.localizedDescription)
                }
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}

// MARK: Stub Generator
extension CoreDataTests {
    func insertStubs() {
        backgroundContext.performAndWait {
            (0...5).forEach {
                let photo = Photo.mock(id: Int64($0), in: self.backgroundContext)
                User.mock(id: photo.userID, in: self.backgroundContext)
            }
        }
    }
}

// MARK: Random String Generator
extension String {
    fileprivate static var random : Self {
        return String(Array((0...Int.random(in: 1..<50)).map { _ in
            Character(UnicodeScalar(Int.random(in: 0..<26) + 97)!)
        }))
    }
}

// MARK: Photo Stub Factory
extension Photo {
    @discardableResult fileprivate static func mock(id: Int64? = nil, in context: NSManagedObjectContext) -> Self {
        let photo = (NSEntityDescription.insertNewObject(forEntityName: String(describing: self), into: context) as! Self).mock(id: id)
        if context.hasChanges {
            try! context.save()
        }
        return photo
    }
    @discardableResult fileprivate func mock(id: Int64? = nil) -> Self {
        self.id = id ?? Int64.random(in: 0...Int64.max)
        name = String.random
        width = Int32.random(in: 0...Int32.max)
        height = Int32.random(in: 0...Int32.max)
        userID = Int64.random(in: 0...Int64.max)
        imageUrls = (0...3).map { _ in String.random }
        return self
    }
}

// MARK: User Stub Factory
extension User {
    @discardableResult fileprivate static func mock(id: Int64? = nil, in context: NSManagedObjectContext) -> Self {
        let user = (NSEntityDescription.insertNewObject(forEntityName: String(describing: self), into: context) as! Self).mock(id: id)
        if context.hasChanges {
            try! context.save()
        }
        return user
    }
    @discardableResult fileprivate func mock(id: Int64? = nil) -> Self {
        self.id = id ?? Int64.random(in: 0...Int64.max)
        fullname = String.random
        avatarUrl = String.random
        return self
    }
}
