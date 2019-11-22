//
//  IOSCalendar.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 26/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import EventKit
import SwiftUI

public class iOSCalendarList: Identifiable
{
    public let id = UUID()
    fileprivate var myList: [iOSCalendarListItem] = Array()
    fileprivate var eventStore: EKEventStore!
    
    public var list: [iOSCalendarListItem]
    {
        return myList
    }
    
    public init()
    {
        myList.removeAll()
        
        eventStore = EKEventStore()
        
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status
        {
            case EKAuthorizationStatus.notDetermined:
                // This happens on first-run
                requestEventAccess()
            
            case EKAuthorizationStatus.authorized:
                // Things are in line with being able to show the calendars in the table view
                loadCalendars()
            
            case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
                // We need to help them give us permission
                requestEventAccess()
                print("Calendar permissions not given")
            
            default:
                print("IOSCalendarList init() hit default")
        }
    }
    
    private func requestEventAccess()
    {
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                    self.loadCalendars()
                })
            } else {
                DispatchQueue.main.async(execute: {
                    print("Calendar permissions not given")
                })
            }
        })
    }
    
    private func loadCalendars()
    {
        for item in eventStore.calendars(for: .event)
        {
            if item.allowsContentModifications
            {
                if item.type != .birthday
                {
                    let name = "\(item.source.title) - \(item.title)"
                    var state: Bool = false
                    if readDefaultString(name) == "True"
                    {
                        state = true
                    }
                    
                    let newItem = iOSCalendarListItem(name: name, state: state, calendar: item)
                    myList.append(newItem)
                }
            }
        }
        
        if myList.count > 0
        {
            myList.sort
                {
                    return $0.name < $1.name
            }
        }
    }
    
    public func searchEvents(startDate: Date,
                             endDate: Date)  -> [EKEvent]
    {
        var selectedCalendar: [EKCalendar] = Array()
        
        for myItem in iOSCalendarList().list
        {
            if myItem.state
            {
                selectedCalendar.append(myItem.calendar)
            }
        }
        
        var searchPredicate: NSPredicate!
        
        if selectedCalendar.count > 0
        {
            searchPredicate = eventStore.predicateForEvents(
                withStart: startDate,
                end: endDate,
                calendars: selectedCalendar)
        }
        else
        {
            searchPredicate = eventStore.predicateForEvents(
                withStart: startDate,
                end: endDate,
                calendars: nil)
        }
        
        if eventStore.sources.count > 0
        {
            return eventStore.events(matching: searchPredicate)
        }
        else
        {
            return []
        }
    }
    
    public func createEvent(title: String, startDate: Date, endDate: Date)
    {
        var eventCalendar: EKCalendar!
        
        for item in eventStore.calendars(for: .event)
        {
            let name = "\(item.source.title) - \(item.title)"
            if name == currentUser.defaultCalendar
            {
                eventCalendar = item
                break
            }
        }

        let event = EKEvent(eventStore: eventStore)
        event.title = title

        if eventCalendar == nil
        {
            event.calendar = eventStore.defaultCalendarForNewEvents // this will return deafult calendar from device calendars
        }
        else
        {
            event.calendar = eventCalendar
        }
        event.startDate = startDate
        event.endDate = endDate


        do {
            try eventStore.save(event, span: .thisEvent)
            //event created successfullt to default calendar
        } catch let error as NSError {
            print("failed to save event with error : \(error)")
        }
    }
}

public class iOSCalendarListItem: Identifiable
{
    public let id = UUID()
    fileprivate var myName: String = ""
    fileprivate var myState: Bool = false
    fileprivate var myCalendar: EKCalendar!
    
    public var name: String
    {
        return myName
    }
    
    public var state: Bool
    {
        get
        {
            return myState
        }
        set
        {
            if newValue
            {
                writeDefaultString(myName, value: "True")
            }
            else
            {
                writeDefaultString(myName, value: "False")
            }
            
            myState = newValue
        }
    }
    
    public var calendar: EKCalendar
    {
        return myCalendar
    }
    
    public init(name: String, state: Bool, calendar: EKCalendar)
    {
        myName = name
        myState = state
        myCalendar = calendar
    }
}

public class iOSCalendar: Identifiable
{
    public let id = UUID()
    fileprivate var eventRecords: [mergedCalendarItem] = Array()
    
    fileprivate var calendarSource: iOSCalendarList = iOSCalendarList()
    
    public var events: [mergedCalendarItem]
    {
        get
        {
            return eventRecords
        }
    }
    
    public init(email: String, teamID: Int64, startDate: Date, endDate: Date)
    {
        let events = calendarSource.searchEvents(startDate: startDate, endDate: endDate)
        
        if events.count >  0
        {
            // Go through all the events and print them to the console
            for event in events
            {
                if event.attendees != nil
                {
                    if event.attendees!.count > 0
                    {
                        for attendee in event.attendees!
                        {
                            if !attendee.isCurrentUser
                            {
                                // Is the Attendee is not the current user then we need to parse the email address
                                
                                // Split the URL string on : - to give an array, the second element is the email address
                                
                                let emailSplit = String(describing: attendee.url).components(separatedBy: ":")
                                
                                if emailSplit[1] == email
                                {
                                    storeEvent(event, attendee: attendee, teamID: teamID)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public init(projectName: String, teamID: Int64, startDate: Date, endDate: Date)
    {
        let events = calendarSource.searchEvents(startDate: startDate, endDate: endDate)
        
        if events.count >  0
        {
            // Go through all the events and print them to the console
            for event in events
            {
                let myTitle = event.title
                
                if myTitle?.lowercased().range(of: projectName.lowercased()) != nil
                {
                    storeEvent(event, attendee: nil, teamID: teamID)
                }
            }
        }
    }
    
    public init(teamID: Int64, startDate: Date, endDate: Date)
    {
        let events = calendarSource.searchEvents(startDate: startDate, endDate: endDate)
        
        if events.count >  0
        {
            // Go through all the events and print them to the console
            for event in events
            {
                storeEvent(event, attendee: nil, teamID: teamID)
            }
        }
    }
    
    public init(teamID: Int64, workingDate: Date)
    {
        let endDate = workingDate.add(.day, amount: 1).startOfDay
        let events = calendarSource.searchEvents(startDate: workingDate, endDate: endDate)
        
        if events.count >  0
        {
            // Go through all the events and print them to the console
            for event in events
            {
                storeEvent(event, attendee: nil, teamID: teamID)
            }
        }
    }
    
    public init(clientID: Int64, projectID: Int64, teamID: Int64, startDate: Date, endDate: Date)
    {
        var meetingList: [MeetingAgenda] = Array()
        
        if clientID > 0 && projectID > 0
        {
            meetingList = myCloudDB.getAgenda(clientID: clientID, projectID: projectID, startDate: startDate, endDate: endDate, teamID: teamID)
        }
        else if clientID > 0
        {
            meetingList = myCloudDB.getAgenda(clientID: clientID, startDate: startDate, endDate: endDate, teamID: teamID)
        }
        else if projectID > 0
        {
            meetingList = myCloudDB.getAgenda(projectID: projectID, startDate: startDate, endDate: endDate, teamID: teamID)
        }
        else
        {
            meetingList = myCloudDB.getAgenda(startDate: startDate, endDate: endDate, teamID: teamID)
        }
        
        // Check through the meetings for ones that match the context
        
        let myEventList = calendarSource.searchEvents(startDate: startDate, endDate: endDate)
        
        for myEvent in myEventList
        {
            var foundMeeting: MeetingAgenda!
            
            for myMeeting in meetingList
            {
                let convertedDate = myMeeting.startTime! as Date
                
                if myEvent.title == myMeeting.name! && myEvent.startDate == convertedDate
                {
                    foundMeeting = myMeeting
                    break
                }
            }
            
            if foundMeeting != nil
            {
                let calendarEntry = calendarItem(meetingAgenda: foundMeeting)
                let newItem = mergedCalendarItem(startDate: calendarEntry.startDate, databaseItem: calendarEntry, iCalItem: myEvent)
                eventRecords.append(newItem)
            }
            else
            {
                let newItem = mergedCalendarItem(startDate: myEvent.startDate, databaseItem: nil, iCalItem: myEvent)
                eventRecords.append(newItem)
            }
        }
        
        eventRecords.sort(by: {$0.startDate < $1.startDate})
    }
    
    fileprivate func storeEvent(_ event: EKEvent, attendee: EKParticipant?, teamID: Int64)
    {
        let calendarEntry = calendarItem(event: event, teamID: teamID)
        let newItem = mergedCalendarItem(startDate: event.startDate, databaseItem: calendarEntry, iCalItem: event)
        eventRecords.append(newItem)
    }
    
//    func displayEvent() -> [TableData]
//    {
//        var tableContents: [TableData] = [TableData]()
//        
//        // Build up the details we want to show ing the calendar
//        
//        for event in eventDetails
//        {
//            var myString = "\(event.title)\n"
//            myString += "\(event.displayScheduledDate)\n"
//            
//            if event.recurrence != -1
//            {
//                myString += "Occurs every \(event.recurrenceFrequency) \(event.displayRecurrence)\n"
//            }
//            
//            if event.location != ""
//            {
//                myString += "At \(event.location)\n"
//            }
//            
//            if event.status != -1
//            {
//                myString += "Status = \(event.displayStatus)"
//            }
//            
//            if event.startDate.compare(Date()) == ComparisonResult.orderedAscending
//            {
//                // Event is in the past
//                writeRowToArray(myString, table: &tableContents, targetEvent: event, displayFormat: "Gray")
//            }
//            else
//            {
//                writeRowToArray(myString, table: &tableContents, targetEvent: event)
//            }
//        }
//        return tableContents
//    }
    
//    func getCalendarRecords() -> [TableData]
//    {
//        var outputArray: [TableData] = Array()
//        
//        let endDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())
//        
//        /* Create the predicate that we can later pass to the event store in order to fetch the events */
//        let searchPredicate = globalEventStore.predicateForEvents(
//            withStart: Date(),
//            end: endDate!,
//            calendars: nil)
//        
//        /* Fetch all the events that fall between the starting and the ending dates */
//        
//        if globalEventStore.sources.count > 0
//        {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateStyle = .medium
//            dateFormatter.timeStyle = .short
//            
//            for calItem in globalEventStore.events(matching: searchPredicate)
//            {
//                var tempEntry = TableData(displayText: calItem.title)
//                tempEntry.notes = dateFormatter.string(from: calItem.startDate)
//                tempEntry.event = calItem
//                
//                outputArray.append(tempEntry)
//            }
//            
//            return outputArray
//        }
//        else
//        {
//            return []
//        }
//    }
}

public class iOSReminder: Identifiable
{
    public let id = UUID()
    fileprivate var reminderStore: EKEventStore!
    fileprivate var targetReminderCal: EKCalendar!
    fileprivate var reminderRecords: [EKReminder] = Array()
    
    public init()
    {
        reminderStore = EKEventStore()
        reminderStore.requestAccess(to: EKEntityType.reminder,
                                    completion: {(granted: Bool, error: Error?) in
                                        if !granted {
                                            print("Access to reminder store not granted")
                                        }
        })
    }
    
    public var reminders: [EKReminder]
    {
        get
        {
            return reminderRecords
        }
    }
    
    public func parseReminderDetails (_ search: String)
    {
        let cals = reminderStore.calendars(for: EKEntityType.reminder)
        var myCalFound = false
        
        for cal in cals
        {
            if cal.title == search
            {
                myCalFound = true
                targetReminderCal = cal
            }
        }
        
        if myCalFound
        {
            let predicate = reminderStore.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: [targetReminderCal])
            
            var asyncDone = false
            
            reminderStore.fetchReminders(matching: predicate, completion: {reminders in
                for reminder in reminders!
                {
//                    let workingString: ReminderData = ReminderData(reminderText: reminder.title, reminderCalendar: reminder.calendar)
//                    
//                    if reminder.notes != nil
//                    {
//                        workingString.notes = reminder.notes!
//                    }
//                    workingString.priority = reminder.priority
//                    workingString.calendarItemIdentifier = reminder.calendarItemIdentifier
//                    self.reminderDetails.append(workingString)
                    self.reminderRecords.append(reminder)
                }
                asyncDone = true
            })
            
            // Bit of a nasty workaround but this is to allow async to finish
            
            while !asyncDone
            {
                usleep(500)
            }
        }
    }
    
//    func displayReminder() -> [TableData]
//    {
//        var tableContents: [TableData] = [TableData]()
//        
//        // Build up the details we want to show ing the calendar
//        
//        if reminderDetails.count == 0
//        {
//            writeRowToArray("No reminders list found", table: &tableContents)
//        }
//        else
//        {
//            for myReminder in reminderDetails
//            {
//                let myString = "\(myReminder.reminderText)"
//                
//                switch myReminder.priority
//                {
//                case 1: writeRowToArray(myString, table: &tableContents, displayFormat: "Red")  //  High priority
//                    
//                case 5: writeRowToArray(myString , table: &tableContents, displayFormat: "Orange") // Medium priority
//                    
//                default: writeRowToArray(myString , table: &tableContents)
//                }
//            }
//            
//        }
//        return tableContents
//    }
}

