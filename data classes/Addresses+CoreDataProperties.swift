//
//  Addresses+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation
import CoreData


extension Addresses {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Addresses> {
        return NSFetchRequest<Addresses>(entityName: "Addresses")
    }

    @NSManaged public var addressID: Int64
    @NSManaged public var addressLine1: String?
    @NSManaged public var addressLine2: String?
    @NSManaged public var addressType: String?
    @NSManaged public var city: String?
    @NSManaged public var clientID: Int64
    @NSManaged public var country: String?
    @NSManaged public var personID: Int64
    @NSManaged public var postcode: String?
    @NSManaged public var projectID: Int64
    @NSManaged public var state: String?
    @NSManaged public var teamID: Int64
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
