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
    static func entity(withDictionary dictionary: [NSObject: AnyObject], objectContext: NSManagedObjectContext) -> Status? {
        guard let entity = NSManagedObject.service_entity(ofClass: Status.self, objectContext: objectContext) else {
            return nil
        }
        
        entity.identifier = dictionary["id_str"] as? String
        entity.text = dictionary["text"] as? String
        if let timestamp = dictionary["timestamp_ms"] as? Double {
            entity.timestamp = NSNumber(double: timestamp)
        }
        if let favorited = dictionary["favorited"] as? Bool {
            entity.favorited = NSNumber(bool: favorited)
        }
        if let retwitted = dictionary["retwitted"] as? Bool {
            entity.retwitted = NSNumber(bool: retwitted)
        }
        if let favoriteCount = dictionary["favorite_count"] as? Int {
            entity.favoriteCount = NSNumber(integer: favoriteCount)
        }
        if let retweetCount = dictionary["retweet_count"] as? Int {
            entity.timestamp = NSNumber(integer: retweetCount)
        }
        if let truncated = dictionary["truncated"] as? Bool {
            entity.truncated = NSNumber(bool: truncated)
        }
        if let dictionary = dictionary["user"] as? [NSObject: AnyObject], user = User.entity(withDictionary: dictionary, objectContext: objectContext) {
            entity.user = user
        }
        if let hashtags = dictionary["entities"]?["hashtags"] as? [[NSObject: AnyObject]] {
            let statusHashtags = entity.mutableOrderedSetValueForKey("hashtags")
            statusHashtags.addObjectsFromArray(
                hashtags.flatMap { Hashtag.entity(withDictionary: $0, objectContext: objectContext) }
            )
        }
        if let urls = dictionary["entities"]?["urls"] as? [[NSObject: AnyObject]] {
            let statusUrls = entity.mutableOrderedSetValueForKey("urls")
            statusUrls.addObjectsFromArray(
                urls.flatMap { Url.entity(withDictionary: $0, objectContext: objectContext) }
            )
        }
        if let mentions = dictionary["entities"]?["mentions"] as? [[NSObject: AnyObject]] {
            let statusMentions = entity.mutableOrderedSetValueForKey("mentions")
            statusMentions.addObjectsFromArray(
                mentions.flatMap { Mention.entity(withDictionary: $0, objectContext: objectContext) }
            )
        }
        
        return entity
    }
    
}
