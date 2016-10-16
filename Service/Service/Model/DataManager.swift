//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation
import CoreData

/**
 CoreData initializer, it holds managed object context and controls its merging
 */
public class DataManager {
   
    /// Alias of the closure called when a save operation finishes
    public typealias SaveCompletionClosure = NSError? -> Void
    
    /// Location of the `momd` file
    private static let modelURL: NSURL = NSBundle(forClass: DataManager.self).URLForResource("NewsDataModel", withExtension: "momd")!
    
    /// Location of the `sqlite` file
    private static let sqliteURL: NSURL = {
        let directories = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentsDirectory = directories[directories.count - 1]
        return documentsDirectory.URLByAppendingPathComponent("NewsDataModel.sqlite")
    }()
    
    /// Object model
    private(set) lazy var managedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOfURL: DataManager.modelURL)!
    }()
    
    /// Store Coordinator
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        return coordinator
    }()
    
    /// Root object context connecting main queue context and persistent store
    private lazy var rootObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    /// Main object context, the designated one to be used from the main queue
    public private(set) lazy var mainObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.parentContext = self.rootObjectContext
        return managedObjectContext
    }()
    
    /// Object context to be used from private queue where the mapping is done
    private(set) lazy var mappingObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.parentContext = self.mainObjectContext
        return managedObjectContext
    }()

    // MARK: - Public methods
    
    /**
     Performs a save operation if there are changes in any of the contexts and
     propagates merging across the object context levels
     - parameter completion: Closure called with the save operation result
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
        
        // Don't do anything if there are no changes no merge
        if !performSaveInRoot && !performSaveInMain && !performSaveInMapping && !performSaveInPublic {
            return
        }
        
        // If there are changes in the leaf context then save
        if performSaveInMapping {
            self.saveBottomUp(fromContext: self.mappingObjectContext, completion: completion)
        }
        else if performSaveInMain { // If there are changes in its parent then save
            self.saveBottomUp(fromContext: self.mainObjectContext, completion: completion)
        }
    }
    
    /**
     Creates the stack
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
     An easy way to propagate the save operation from the current context to top
     */
    private func saveBottomUp(fromContext context: NSManagedObjectContext, completion: SaveCompletionClosure?) {
        do {
            try context.save()
            if let parentContext = context.parentContext {
                self.saveBottomUp(fromContext: parentContext, completion: completion)
                return
            }
            
            // Reached root
            dispatch_async(dispatch_get_main_queue()) {
                completion?(nil)
            }
        }
        catch let error as NSError {
            dispatch_async(dispatch_get_main_queue()) {
                completion?(error)
            }
            return
        }
    }
    
}
