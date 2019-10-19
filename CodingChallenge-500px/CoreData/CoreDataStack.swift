//
//  CoreDataStack.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/10.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import Foundation
import CoreData

final class CoreDataStack {
    
    public static let shared = CoreDataStack()
    public var mainContext : NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    public private(set) lazy var mainBackgroundContext : NSManagedObjectContext = {
        return persistentContainer.newBackgroundContext()
            .mergePolicy(NSMergeByPropertyObjectTrumpMergePolicy)
    }()
    public var newBackgroundContext : NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    private init() {}

    private lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "CodingChallenge_500px")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
                
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        })
        return container
    }()
    
    public func delete(_ objects: [NSManagedObject], from context: NSManagedObjectContext = CoreDataStack.shared.mainBackgroundContext, onCompletion: ((Error?)->Void)? = nil) {
        context.perform {
            do {
                if let deleted = (try context.execute(NSBatchDeleteRequest(objectIDs: objects.map { $0.objectID })
                        .resultType(.resultTypeObjectIDs)
                    ) as? NSBatchDeleteResult)?.result as? [NSManagedObjectID], !deleted.isEmpty {
                    NSManagedObjectContext.mergeChanges(
                        fromRemoteContextSave: [NSDeletedObjectsKey: deleted],
                        into: [context]
                    )
                    try context.save()
                }
                onCompletion?(nil)
            } catch {
                onCompletion?(error)
            }
        }
    }
    
    public func delete(_ entity: NSManagedObject.Type, from context: NSManagedObjectContext = CoreDataStack.shared.mainBackgroundContext, onCompletion: ((Error?)->Void)? = nil) {
        delete(entity: entity.description(), from: context, onCompletion: onCompletion)
    }
    
    public func delete(entity named: String?, from context: NSManagedObjectContext = CoreDataStack.shared.mainBackgroundContext, onCompletion: ((Error?)->Void)? = nil) {
        guard let entityName = named else { return }
        context.perform {
            do {
                try context.execute(NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: entityName)))
                try context.save()
                onCompletion?(nil)
            } catch {
                onCompletion?(error)
            }
        }
    }
    
    public func clearAll() throws {
        persistentContainer.managedObjectModel.entities.forEach {
            delete(entity: $0.name)
        }
    }

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
