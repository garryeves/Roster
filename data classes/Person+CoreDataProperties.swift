//
//  Person+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var canRoster: String?
    @NSManaged public var clientID: Int64
    @NSManaged public var dob: NSDate?
    @NSManaged public var gender: String?
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var personID: Int64
    @NSManaged public var projectID: Int64
    @NSManaged public var teamID: Int64
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
