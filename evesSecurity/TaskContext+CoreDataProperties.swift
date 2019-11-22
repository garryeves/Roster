//
//  TaskContext+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation

struct TaskContext {
    public var contextID: Int64
    public var contextType: String?
    public var taskID: Int64
    public var teamID: Int64
    public var updateTime: NSDate?
    public var updateType: String?

}
