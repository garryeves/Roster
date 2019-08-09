//
//  Rates+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation
import CoreData


extension Rates {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rates> {
        return NSFetchRequest<Rates>(entityName: "Rates")
    }

    @NSManaged public var chargeAmount: Double
    @NSManaged public var clientID: Int64
    @NSManaged public var rateAmount: Double
    @NSManaged public var rateID: Int64
    @NSManaged public var rateName: String?
    @NSManaged public var startDate: NSDate?
    @NSManaged public var teamID: Int64
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
