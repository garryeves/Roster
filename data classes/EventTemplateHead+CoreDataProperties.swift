//
//  EventTemplateHead+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation
import CoreData


extension EventTemplateHead {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventTemplateHead> {
        return NSFetchRequest<EventTemplateHead>(entityName: "EventTemplateHead")
    }

    @NSManaged public var eventID: Int64
    @NSManaged public var eventName: String?
    @NSManaged public var teamID: Int64
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
