//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation
import CoreData

extension Url {
    
    /**
     Maps the dictionary given to an entity of the current class stored in the
     `NSManagedObjectContext` provided
     - parameter dictionary: Dictionary with the info to be mapped
     - parameter objectContext: Context where the entity will be created on
     - returns The entity if it has been created
     */
    static func entity(withDictionary dictionary: [AnyHashable: Any], objectContext: NSManagedObjectContext) -> Url? {
        guard let entity = NSManagedObject.service_entity(ofClass: Url.self, objectContext: objectContext) else {
            return nil
        }
        
        entity.url = dictionary["url"] as? String
        entity.expandedURL = dictionary["expanded_url"] as? String
        if let startIndex =  (dictionary["indices"] as? [NSNumber])?[safe: 0] {
            entity.startIndex = startIndex
        }
        if let endIndex =  (dictionary["indices"] as? [NSNumber])?[safe: 1] {
            entity.endIndex = endIndex
        }
        
        return entity
    }
    
}
