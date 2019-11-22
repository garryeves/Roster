//
//  TaskPredecessor+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation

struct TaskPredecessor {

    public var predecessorID: Int64
    public var predecessorType: String?
    public var taskID: Int64
    public var teamID: Int64
    public var updateTime: NSDate?
    public var updateType: String?

}
