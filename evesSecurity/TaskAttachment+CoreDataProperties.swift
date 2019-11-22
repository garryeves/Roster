//
//  TaskAttachment+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation

public struct TaskAttachment {
    public var attachment: NSData?
    public var taskID: Int64
    public var teamID: Int64
    public var title: String?
    public var updateTime: NSDate?
    public var updateType: String?

}
