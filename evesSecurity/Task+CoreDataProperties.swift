//
//  Task+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation

struct Task {
    public var completionDate: NSDate?
    public var details: String?
    public var dueDate: NSDate?
    public var energyLevel: String?
    public var estimatedTime: Int64
    public var estimatedTimeType: String?
    public var flagged: NSNumber?
    public var priority: String?
    public var projectID: Int64
    public var repeatBase: String?
    public var repeatInterval: Int64
    public var repeatType: String?
    public var startDate: NSDate?
    public var status: String?
    public var taskID: Int64
    public var teamID: Int64
    public var title: String?
    public var updateTime: NSDate?
    public var updateType: String?
    public var urgency: String?

}
