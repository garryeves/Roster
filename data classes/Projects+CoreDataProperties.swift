//
//  Projects+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation
import CoreData


extension Projects {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Projects> {
        return NSFetchRequest<Projects>(entityName: "Projects")
    }

    @NSManaged public var areaID: Int64
    @NSManaged public var clientDept: String?
    @NSManaged public var clientID: Int64
    @NSManaged public var daysToPay: Int64
    @NSManaged public var invoicingDay: Int64
    @NSManaged public var invoicingFrequency: String?
    @NSManaged public var lastReviewDate: NSDate?
    @NSManaged public var note: String?
    @NSManaged public var predecessor: Int64
    @NSManaged public var projectEndDate: NSDate?
    @NSManaged public var projectID: Int64
    @NSManaged public var projectName: String?
    @NSManaged public var projectStartDate: NSDate?
    @NSManaged public var projectStatus: String?
    @NSManaged public var repeatBase: String?
    @NSManaged public var repeatInterval: Int64
    @NSManaged public var repeatType: String?
    @NSManaged public var reviewFrequency: Int64
    @NSManaged public var reviewPeriod: String?
    @NSManaged public var teamID: Int64
    @NSManaged public var type: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
