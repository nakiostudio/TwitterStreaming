//
//  Hashtag+CoreDataProperties.swift
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

public extension Hashtag {

    @NSManaged var text: String?
    @NSManaged var startIndex: NSNumber?
    @NSManaged var endIndex: NSNumber?
    @NSManaged var status: Status?

}
