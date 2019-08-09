//
//  MeetingTasks+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation
import CoreData


extension MeetingTasks {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MeetingTasks> {
        return NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
    }

    @NSManaged public var agendaID: Int64
    @NSManaged public var meetingID: String?
    @NSManaged public var taskID: Int64
    @NSManaged public var teamID: Int64
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
