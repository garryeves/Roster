//
//  UserTeams+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation
import CoreData


extension UserTeams {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserTeams> {
        return NSFetchRequest<UserTeams>(entityName: "UserTeams")
    }

    @NSManaged public var teamID: Int64
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?
    @NSManaged public var userID: Int64

}
