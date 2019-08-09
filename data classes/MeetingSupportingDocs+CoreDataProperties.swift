//
//  MeetingSupportingDocs+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation
import CoreData


extension MeetingSupportingDocs {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MeetingSupportingDocs> {
        return NSFetchRequest<MeetingSupportingDocs>(entityName: "MeetingSupportingDocs")
    }

    @NSManaged public var agendaID: Int64
    @NSManaged public var attachmentPath: String?
    @NSManaged public var meetingID: String?
    @NSManaged public var teamID: Int64
    @NSManaged public var title: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
