//
//  PersonAddInfoEntry+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation
import CoreData


extension PersonAddInfoEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersonAddInfoEntry> {
        return NSFetchRequest<PersonAddInfoEntry>(entityName: "PersonAddInfoEntry")
    }

    @NSManaged public var addInfoName: String?
    @NSManaged public var dateValue: NSDate?
    @NSManaged public var personID: Int64
    @NSManaged public var stringValue: String?
    @NSManaged public var teamID: Int64
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
