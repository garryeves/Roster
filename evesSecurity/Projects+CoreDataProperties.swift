//
//  Projects+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation

struct Projects {
    public var areaID: Int64
    public var clientDept: String?
    public var clientID: Int64
    public var daysToPay: Int64
    public var invoicingDay: Int64
    public var invoicingFrequency: String?
    public var lastReviewDate: NSDate?
    public var note: String?
    public var predecessor: Int64
    public var projectEndDate: NSDate?
    public var projectID: Int64
    public var projectName: String?
    public var projectStartDate: NSDate?
    public var projectStatus: String?
    public var repeatBase: String?
    public var repeatInterval: Int64
    public var repeatType: String?
    public var reviewFrequency: Int64
    public var reviewPeriod: String?
    public var teamID: Int64
    public var type: String?
    public var updateTime: NSDate?
    public var updateType: String?

}
