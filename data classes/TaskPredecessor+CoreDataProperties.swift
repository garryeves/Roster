//
//  TaskPredecessor+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation
import CoreData


extension TaskPredecessor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskPredecessor> {
        return NSFetchRequest<TaskPredecessor>(entityName: "TaskPredecessor")
    }

    @NSManaged public var predecessorID: Int64
    @NSManaged public var predecessorType: String?
    @NSManaged public var taskID: Int64
    @NSManaged public var teamID: Int64
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
