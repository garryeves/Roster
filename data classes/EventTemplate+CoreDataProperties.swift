//
//  EventTemplate+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation
import CoreData


extension EventTemplate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventTemplate> {
        return NSFetchRequest<EventTemplate>(entityName: "EventTemplate")
    }

    @NSManaged public var dateModifier: Int64
    @NSManaged public var endTime: NSDate?
    @NSManaged public var eventID: Int64
    @NSManaged public var eventName: String?
    @NSManaged public var numRequired: Int64
    @NSManaged public var role: String?
    @NSManaged public var startTime: NSDate?
    @NSManaged public var teamID: Int64
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
