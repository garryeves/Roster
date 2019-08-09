//
//  Shifts+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation
import CoreData


extension Shifts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Shifts> {
        return NSFetchRequest<Shifts>(entityName: "Shifts")
    }

    @NSManaged public var clientInvoiceNumber: Int64
    @NSManaged public var endTime: NSDate?
    @NSManaged public var personID: Int64
    @NSManaged public var personInvoiceNumber: Int64
    @NSManaged public var projectID: Int64
    @NSManaged public var rateID: Int64
    @NSManaged public var shiftDescription: String?
    @NSManaged public var shiftID: Int64
    @NSManaged public var shiftLineID: Int64
    @NSManaged public var startTime: NSDate?
    @NSManaged public var status: String?
    @NSManaged public var teamID: Int64
    @NSManaged public var type: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?
    @NSManaged public var weekEndDate: NSDate?
    @NSManaged public var workDate: NSDate?

}
