//
//  Team+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 10/5/17.
//
//

import Foundation
import CoreData


extension Team {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Team> {
        return NSFetchRequest<Team>(entityName: "Team")
    }

    @NSManaged public var externalID: Int32
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var predecessor: Int32
    @NSManaged public var status: String?
    @NSManaged public var teamID: Int32
    @NSManaged public var type: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
