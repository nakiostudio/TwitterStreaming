//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation
import CoreData

extension Status {
    
    /**
     Maps the dictionary given to an entity of the current class stored in the
     `NSManagedObjectContext` provided
     - parameter dictionary: Dictionary with the info to be mapped
     - parameter objectContext: Context where the entity will be created on
     - returns The entity if it has been created
     */
    static func entity(withDictionary dictionary: [AnyHashable: Any], objectContext: NSManagedObjectContext) -> Status? {
        guard let entity = NSManagedObject.service_entity(ofClass: Status.self, objectContext: objectContext) else {
            return nil
        }
        
        entity.insertDate = Date()
        entity.identifier = dictionary["id_str"] as? String
        entity.text = dictionary["text"] as? String
        if let timestamp = dictionary["timestamp_ms"] as? NSNumber {
            entity.timestamp = timestamp
        }
        if let favorited = dictionary["favorited"] as? NSNumber {
            entity.favorited = favorited
        }
        if let retweeted = dictionary["retweeted"] as? NSNumber {
            entity.retweeted = retweeted
        }
        if let favoriteCount = dictionary["favorite_count"] as? NSNumber {
            entity.favoriteCount = favoriteCount
        }
        if let retweetCount = dictionary["retweet_count"] as? NSNumber {
            entity.timestamp = retweetCount
        }
        if let truncated = dictionary["truncated"] as? NSNumber {
            entity.truncated = truncated
        }
        if let dictionary = dictionary["user"] as? [AnyHashable: Any], let user = User.entity(withDictionary: dictionary, objectContext: objectContext) {
            entity.user = user
        }
        if let hashtags = (dictionary["entities"] as? [AnyHashable: Any])?["hashtags"] as? [[AnyHashable: Any]] {
            hashtags.flatMap { Hashtag.entity(withDictionary: $0, objectContext: objectContext) }.forEach {
                $0.status = entity
            }
        }
        if let urls = (dictionary["entities"] as? [AnyHashable: Any])?["urls"] as? [[AnyHashable: Any]] {
            urls.flatMap { Url.entity(withDictionary: $0, objectContext: objectContext) }.forEach {
                $0.status = entity
            }
        }
        if let mentions = (dictionary["entities"] as? [AnyHashable: Any])?["user_mentions"] as? [[AnyHashable: Any]] {
            mentions.flatMap { Mention.entity(withDictionary: $0, objectContext: objectContext) }.forEach {
                $0.status = entity
            }
        }
        
        return entity
    }
    
    /**
     A fetched results controller to retrieve from database all the new items from
     the moment the controller is created
     */
    static func fetchedResultsController(withObjectContext objectContext: NSManagedObjectContext) -> NSFetchedResultsController<NSFetchRequestResult> {
        let name = NSStringFromClass(Status.self).components(separatedBy: ".").last ?? ""
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        // Sort by insert date
        let sortDescriptor = NSSortDescriptor(key: "insertDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        // Filter out those inserted before this moment
        let predicate = NSPredicate(format: "(insertDate >= %@)", argumentArray: [Date()])
        fetchRequest.predicate = predicate
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: objectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        return fetchedResultsController
    }
    
}
