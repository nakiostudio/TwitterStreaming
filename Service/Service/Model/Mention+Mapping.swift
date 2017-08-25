//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation
import CoreData

extension Mention {
    
    /**
     Maps the dictionary given to an entity of the current class stored in the
     `NSManagedObjectContext` provided
     - parameter dictionary: Dictionary with the info to be mapped
     - parameter objectContext: Context where the entity will be created on
     - returns The entity if it has been created
     */
    static func entity(withDictionary dictionary: [AnyHashable: Any], objectContext: NSManagedObjectContext) -> Mention? {
        guard let entity = NSManagedObject.service_entity(ofClass: Mention.self, objectContext: objectContext) else {
            return nil
        }
        
        entity.screenName = dictionary["screen_name"] as? String
        entity.identifier = dictionary["id_str"] as? String
        if let startIndex =  (dictionary["indices"] as? [NSNumber])?[safe: 0] {
            entity.startIndex = startIndex
        }
        if let endIndex =  (dictionary["indices"] as? [NSNumber])?[safe: 1] {
            entity.endIndex = endIndex
        }
        
        return entity
    }
    
}
