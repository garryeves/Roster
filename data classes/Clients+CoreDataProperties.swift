//
//  Clients+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation
import CoreData


extension Clients {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Clients> {
        return NSFetchRequest<Clients>(entityName: "Clients")
    }

    @NSManaged public var clientContact: Int64
    @NSManaged public var clientID: Int64
    @NSManaged public var clientName: String?
    @NSManaged public var note: String?
    @NSManaged public var teamID: Int64
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
