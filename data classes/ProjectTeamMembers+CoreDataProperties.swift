//
//  ProjectTeamMembers+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation
import CoreData


extension ProjectTeamMembers {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProjectTeamMembers> {
        return NSFetchRequest<ProjectTeamMembers>(entityName: "ProjectTeamMembers")
    }

    @NSManaged public var personID: Int64
    @NSManaged public var projectID: Int64
    @NSManaged public var projectMemberNotes: String?
    @NSManaged public var roleID: Int64
    @NSManaged public var teamID: Int64
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
