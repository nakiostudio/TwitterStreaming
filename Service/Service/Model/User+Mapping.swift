//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation
import CoreData

extension User {
    
    /**
     Maps the dictionary given to an entity of the current class stored in the
     `NSManagedObjectContext` provided
     - parameter dictionary: Dictionary with the info to be mapped
     - parameter objectContext: Context where the entity will be created on
     - returns The entity if it has been created
     */
    static func entity(withDictionary dictionary: [NSObject: AnyObject], objectContext: NSManagedObjectContext) -> User? {
        guard let entity = NSManagedObject.service_entity(ofClass: User.self, objectContext: objectContext) else {
            return nil
        }
        
        entity.identifier = dictionary["id_str"] as? String
        entity.name = dictionary["name"] as? String
        entity.screenName = dictionary["screen_name"] as? String
        entity.profileImageURL = dictionary["profile_image_url_https"] as? String
        
        return entity
    }
    
}
