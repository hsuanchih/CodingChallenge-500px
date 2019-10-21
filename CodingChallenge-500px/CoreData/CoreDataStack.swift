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

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CodingChallenge_500px")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
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
                if context.hasChanges {
                    try context.save()
                }
                onCompletion?(nil)
            } catch {
                onCompletion?(error)
            }
        }
    }
    
    public func clearAll(from context: NSManagedObjectContext = CoreDataStack.shared.mainBackgroundContext) throws {
        persistentContainer.managedObjectModel.entities.forEach {
            delete(entity: $0.name, from: context)
        }
    }

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
