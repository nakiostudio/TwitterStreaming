//
//  Created by Carlos Vidal Pallin on 15/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation
import CoreData

/**
 
 */
public class DataManager {
   
    ///
    public typealias SaveCompletionClosure = NSError? -> Void
    
    ///
    private static let modelURL: NSURL = NSBundle(forClass: DataManager.self).URLForResource("NewsDataModel", withExtension: "momd")!
    
    ///
    private static let sqliteURL: NSURL = {
        let directories = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentsDirectory = directories[directories.count - 1]
        return documentsDirectory.URLByAppendingPathComponent("NewsDataModel.sqlite")
    }()
    
    ///
    private(set) lazy var managedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOfURL: DataManager.modelURL)!
    }()
    
    ///
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        return coordinator
    }()
    
    ///
    private lazy var rootObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    ///
    private lazy var mainObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.parentContext = self.rootObjectContext
        return managedObjectContext
    }()
    
    ///
    lazy var mappingObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.parentContext = self.mainObjectContext
        return managedObjectContext
    }()
    
    ///
    public lazy var objectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.parentContext = self.mainObjectContext
        return managedObjectContext
    }()

    // MARK: - Public methods
    
    /**
     
     */
    public func save(withCompletion completion: SaveCompletionClosure?) {
        var performSaveInRoot = false
        var performSaveInMain = false
        var performSaveInMapping = false
        var performSaveInPublic = false
        
        self.rootObjectContext.performBlockAndWait { 
            performSaveInRoot = self.rootObjectContext.hasChanges
        }
        
        self.mainObjectContext.performBlockAndWait {
            performSaveInMain = self.mainObjectContext.hasChanges
        }
        
        self.mappingObjectContext.performBlockAndWait {
            performSaveInMapping = self.mappingObjectContext.hasChanges
        }
        
        self.objectContext.performBlockAndWait {
            performSaveInPublic = self.objectContext.hasChanges
        }
        
        //
        if !performSaveInRoot && !performSaveInMain && !performSaveInMapping && !performSaveInPublic {
            return
        }
        
        //
        self.saveBottomUp(fromContext: self.mappingObjectContext, completion: completion)
        
        //
        self.saveBottomUp(fromContext: self.objectContext, completion: completion)
    }
    
    /**
     
     */
    func loadStack() {
        guard self.persistentStoreCoordinator.persistentStores.count == 0 else {
            debugPrint("Unable to add persistent store")
            return
        }
        
        let coordinator = self.persistentStoreCoordinator
        let options: [NSObject: AnyObject] = [
            NSSQLitePragmasOption: ["journal_mode": "WAL"],
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: DataManager.sqliteURL, options: options)
        }
        catch {
            debugPrint("Unable to add persistent store")
            abort()
        }
        
    }
    
    // MARK: - Private methods
    
    /**
 
     */
    private func saveBottomUp(fromContext context: NSManagedObjectContext, completion: SaveCompletionClosure?) {
        context.performBlock { 
            do {
                try context.save()
            }
            catch let error as NSError {
                dispatch_async(dispatch_get_main_queue()) {
                    completion?(error)
                }
                return
            }
            
            if let parentContext = context.parentContext {
                self.saveBottomUp(fromContext: parentContext, completion: completion)
            }
        }
    }
    
}
