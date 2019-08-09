//
//  UserRoles+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation
import CoreData


extension UserRoles {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserRoles> {
        return NSFetchRequest<UserRoles>(entityName: "UserRoles")
    }

    @NSManaged public var accessLevel: String?
    @NSManaged public var roleID: Int64
    @NSManaged public var roleType: String?
    @NSManaged public var teamID: Int64
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?
    @NSManaged public var userID: Int64

}
