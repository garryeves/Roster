//
//  TaskContext+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 10/5/17.
//
//

import Foundation
import CoreData


extension TaskContext {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskContext> {
        return NSFetchRequest<TaskContext>(entityName: "TaskContext")
    }

    @NSManaged public var contextID: Int32
    @NSManaged public var taskID: Int32
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
