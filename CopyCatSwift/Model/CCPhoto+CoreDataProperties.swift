//
//  CCPhoto+CoreDataProperties.swift
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

extension CCPhoto {

    @NSManaged var id: NSNumber?
    @NSManaged var photoURI: String?
    @NSManaged var refPhotoURI: String?

}
