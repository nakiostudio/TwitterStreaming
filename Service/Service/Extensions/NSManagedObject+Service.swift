//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation
import CoreData

/**
 Helper methods
 */
extension NSManagedObject {
    
    /**
     Creates an entity for the class given in order to save some boilerplate code
     - parameter class: Type of the entity to return
     - parameter objectContext: `NSManagedObjectContext` where the entity will be added to
     - returns The created `NSManagedObject` if possible
     */
    static func service_entity<T where T: NSManagedObject>(ofClass class: T.Type, objectContext: NSManagedObjectContext) -> T? {
        let name = NSStringFromClass(T).components(separatedBy: ".").last ?? ""
        return NSEntityDescription.insertNewObject(forEntityName: name, into: objectContext) as? T
    }
    
}
