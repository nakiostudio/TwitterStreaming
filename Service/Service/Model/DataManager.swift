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
    public typealias SaveCompletionClosure = (NSError?) -> Void
    
    /// Location of the `momd` file
    fileprivate static let modelURL: URL = Bundle(for: DataManager.self).url(forResource: "NewsDataModel", withExtension: "momd")!
    
    /// Location of the `sqlite` file
    fileprivate static let sqliteURL: URL = {
        let directories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = directories[directories.count - 1]
        return documentsDirectory.appendingPathComponent("NewsDataModel.sqlite")
    }()
    
    /// Object model
    fileprivate(set) lazy var managedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOf: DataManager.modelURL)!
    }()
    
    /// Store Coordinator
    fileprivate lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        return coordinator
    }()
    
    /// Root object context connecting main queue context and persistent store
    fileprivate lazy var rootObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    /// Main object context, the designated one to be used from the main queue
    public fileprivate(set) lazy var mainObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = self.rootObjectContext
        return managedObjectContext
    }()
    
    /// Object context to be used from private queue where the mapping is done
    fileprivate(set) lazy var mappingObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.parent = self.mainObjectContext
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
        
        self.rootObjectContext.performAndWait { 
            performSaveInRoot = self.rootObjectContext.hasChanges
        }
        
        self.mainObjectContext.performAndWait {
            performSaveInMain = self.mainObjectContext.hasChanges
        }
        
        self.mappingObjectContext.performAndWait {
            performSaveInMapping = self.mappingObjectContext.hasChanges
        }
        
        // Don't do anything if there are no changes no merge
        if !performSaveInRoot && !performSaveInMain && !performSaveInMapping {
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
        let options: [AnyHashable: Any] = [
            NSSQLitePragmasOption: ["journal_mode": "WAL"],
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: DataManager.sqliteURL, options: options)
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
    fileprivate func saveBottomUp(fromContext context: NSManagedObjectContext, completion: SaveCompletionClosure?) {
        do {
            try context.save()
            if let parentContext = context.parent {
                self.saveBottomUp(fromContext: parentContext, completion: completion)
                return
            }
            
            // Reached root
            DispatchQueue.main.async {
                completion?(nil)
            }
        }
        catch let error as NSError {
            DispatchQueue.main.async {
                completion?(error)
            }
            return
        }
    }
    
}
