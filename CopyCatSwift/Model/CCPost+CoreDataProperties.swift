//
//  CCPost+CoreDataProperties.swift
//  
//
//  Created by Baiqi Zhang on 5/22/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CCPost {

    @NSManaged var id: String?
    @NSManaged var likeCount: NSNumber?
    @NSManaged var liked: NSNumber?
    @NSManaged var photoHeight: NSNumber?
    @NSManaged var photoURI: String?
    @NSManaged var photoWidth: NSNumber?
    @NSManaged var pinCount: NSNumber?
    @NSManaged var timestamp: NSDate?
    @NSManaged var userName: String?
    @NSManaged var userProfileImage: String?
    @NSManaged var userID: String?

}
