//
//  MeetingAgendaItem+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 10/5/17.
//
//

import Foundation
import CoreData


extension MeetingAgendaItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MeetingAgendaItem> {
        return NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
    }

    @NSManaged public var actualEndTime: NSDate?
    @NSManaged public var actualStartTime: NSDate?
    @NSManaged public var agendaID: Int32
    @NSManaged public var decisionMade: String?
    @NSManaged public var discussionNotes: String?
    @NSManaged public var meetingID: String?
    @NSManaged public var meetingOrder: Int32
    @NSManaged public var owner: String?
    @NSManaged public var status: String?
    @NSManaged public var timeAllocation: Int16
    @NSManaged public var title: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
