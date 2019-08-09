//
//  Team+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation
import CoreData


extension Team {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Team> {
        return NSFetchRequest<Team>(entityName: "Team")
    }

    @NSManaged public var companyName: String?
    @NSManaged public var companyRegNumber: String?
    @NSManaged public var externalID: String?
    @NSManaged public var logo: NSData?
    @NSManaged public var name: String?
    @NSManaged public var nextInvoiceNumber: Int64
    @NSManaged public var note: String?
    @NSManaged public var predecessor: Int64
    @NSManaged public var status: String?
    @NSManaged public var subscriptionDate: NSDate?
    @NSManaged public var subscriptionLevel: Int64
    @NSManaged public var taxNumber: String?
    @NSManaged public var teamID: Int64
    @NSManaged public var teamOwner: Int64
    @NSManaged public var type: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
