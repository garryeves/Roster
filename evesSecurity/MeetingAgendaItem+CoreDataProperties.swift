//
//  MeetingAgendaItem+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation

struct MeetingAgendaItem {
    public var actualEndTime: NSDate?
    public var actualStartTime: NSDate?
    public var agendaID: Int64
    public var decisionMade: String?
    public var discussionNotes: String?
    public var meetingID: String?
    public var meetingOrder: Int64
    public var owner: String?
    public var status: String?
    public var teamID: Int64
    public var timeAllocation: Int64
    public var title: String?
    public var updateTime: NSDate?
    public var updateType: String?

}
