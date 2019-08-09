//
//  Context+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation
import CoreData


extension Context {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Context> {
        return NSFetchRequest<Context>(entityName: "Context")
    }

    @NSManaged public var autoEmail: String?
    @NSManaged public var contextID: Int64
    @NSManaged public var contextType: String?
    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var parentContext: Int64
    @NSManaged public var personID: Int64
    @NSManaged public var predecessor: Int64
    @NSManaged public var status: String?
    @NSManaged public var teamID: Int64
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
