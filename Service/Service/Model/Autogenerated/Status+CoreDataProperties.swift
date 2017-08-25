//
//  Status+CoreDataProperties.swift
//  Service
//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

public extension Status {

    @NSManaged var timestamp: NSNumber?
    @NSManaged var insertDate: Date?
    @NSManaged var identifier: String?
    @NSManaged var text: String?
    @NSManaged var favorited: NSNumber?
    @NSManaged var retweeted: NSNumber?
    @NSManaged var favoriteCount: NSNumber?
    @NSManaged var retweetCount: NSNumber?
    @NSManaged var truncated: NSNumber?
    @NSManaged var user: User?
    @NSManaged var hashtags: NSOrderedSet?
    @NSManaged var urls: NSOrderedSet?
    @NSManaged var mentions: NSOrderedSet?

}
