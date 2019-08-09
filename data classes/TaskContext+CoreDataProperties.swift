//
//  TaskContext+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation
import CoreData


extension TaskContext {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskContext> {
        return NSFetchRequest<TaskContext>(entityName: "TaskContext")
    }

    @NSManaged public var contextID: Int64
    @NSManaged public var contextType: String?
    @NSManaged public var taskID: Int64
    @NSManaged public var teamID: Int64
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
