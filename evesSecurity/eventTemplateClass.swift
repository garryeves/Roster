//
//  eventTemplateClass.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 23/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//


import Foundation
//import CoreData
import CloudKit
import SwiftUI

struct eventDayItems {
    var description: String
    var dateModifier: Int
}

public class eventTemplates: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myEventTemplate:[eventTemplate] = Array()
    
    public init(eventID: Int64, teamID: Int64)
    {
        if currentUser.currentTeam?.eventTemplatesList == nil
        {
            currentUser.currentTeam?.eventTemplatesList = myCloudDB.getEventTemplates(teamID: teamID)
        }
        
        var workingArray: [EventTemplate] = Array()
        
        for item in (currentUser.currentTeam?.eventTemplatesList)!
        {
            if (item.eventID == eventID)
            {
                workingArray.append(item)
            }
        }
        
        for myItem in workingArray
        {
            let myObject = eventTemplate(eventID: myItem.eventID,
                                         role: myItem.role!,
                                         numRequired: myItem.numRequired,
                                         dateModifier: myItem.dateModifier,
                                         startTime: myItem.startTime! as Date,
                                         endTime: myItem.endTime! as Date,
                                         teamID: myItem.teamID)
            
            myEventTemplate.append(myObject)
        }
        
    }
    
    public var roles: [eventTemplate]?
    {
        get
        {
            return myEventTemplate
        }
    }
}

public class eventTemplate: NSObject, Identifiable, ObservableObject
{
    public let id = UUID()
    fileprivate var myEventID: Int64 = 0
    fileprivate var myRole: String = ""
    fileprivate var myNumRequired: Int64 = 0
    fileprivate var myDateModifier: Int64 = 0
    fileprivate var myStartTime: Date = getDefaultDate()
    fileprivate var myEndTime: Date = getDefaultDate()
    fileprivate var myTeamID: Int64 = 0
//    fileprivate var myEventName: String = ""
    fileprivate var eventDayArray: [eventDayItems] = Array()
    fileprivate var dayNameArray: [String] = Array()
    
    public var eventID: Int64
    {
        get
        {
            return myEventID
        }
    }
    
    public var role: String
    {
        get
        {
            return myRole
        }
        set {
            myRole = newValue
        }
    }
    
    public var numRequired: Int64
    {
        get
        {
            return myNumRequired
        }
        set
        {
            myNumRequired = newValue
     //       save()
        }
    }
    
    public var dateModifier: Int64
    {
        get
        {
            return myDateModifier
        }
        set {
            myDateModifier = newValue
        }
    }
    
    var displayEventDay: String {
        if eventDayArray.count == 0 {
            createEventDayList()
        }
        
        var returnString = "Unknown"
        for item in eventDayArray
        {
            if item.dateModifier == myDateModifier {
                returnString = item.description
                break
            }
        }
        return returnString
    }
    
    var fullListArray: [eventDayItems] {
        if eventDayArray.count == 0 {
            createEventDayList()
        }

        return eventDayArray
    }
    
    var listArray: [String] {
        if eventDayArray.count == 0 {
            createEventDayList()
        }

        return dayNameArray
    }
    
    public var startTime: Date
    {
        get
        {
            return myStartTime
        }
        set
        {
            myStartTime = newValue
     //       save()
        }
    }
    
    public var endTime: Date
    {
        get
        {
            return myEndTime
        }
        set
        {
            myEndTime = newValue
      //      save()
        }
    }
    
//    public var eventName: String
//    {
//        get
//        {
//            return myEventName
//        }
//        set
//        {
//            myEventName = newValue
//     //       save)
//        }
//    }
    
    public init(eventID: Int64,
                role: String,
                dateModifier: Int64,
                startTime: Date,
                endTime: Date,
                teamID: Int64)
    {
        super.init()
        
        myEventID = eventID
        myDateModifier = dateModifier
        myStartTime = startTime
        myEndTime = endTime
        myRole = role
        myTeamID = teamID
    }
    
    public init(eventID: Int64,
                role: String,
                numRequired: Int64,
                dateModifier: Int64,
                startTime: Date,
                endTime: Date,
                teamID: Int64)
    {
        super.init()
        
        myEventID = eventID
        myRole = role
        myNumRequired = numRequired
        myDateModifier = dateModifier
        myStartTime = startTime
        myEndTime = endTime
        myTeamID = teamID
    }
    
    public init(eventID: Int64,
                teamID: Int64)
    {
        super.init()
        
        myEventID = eventID
        myTeamID = teamID
    }
    
    public func save()
    {
        if currentUser.checkWritePermission(rosteringRoleType)
        {
            let temp = EventTemplate(dateModifier: myDateModifier, endTime: myEndTime, eventID: myEventID, numRequired: myNumRequired, role: myRole, startTime: myStartTime, teamID: myTeamID)
            
            myCloudDB.saveEventTemplateRecordToCloudKit(temp)
            
            currentUser.currentTeam?.eventTemplatesList = nil
        }
    }
    
    private func createEventDayList() {
        eventDayArray.removeAll()
        dayNameArray.removeAll()
        eventDayArray.append(eventDayItems(description: "Event Day - 3", dateModifier: -3))
        dayNameArray.append("Event Day - 3")
        eventDayArray.append(eventDayItems(description: "Event Day - 2", dateModifier: -2))
        dayNameArray.append("Event Day - 2")
        eventDayArray.append(eventDayItems(description: "Event Day - 1", dateModifier: -1))
        dayNameArray.append("Event Day - 1")
        eventDayArray.append(eventDayItems(description: "Event Day", dateModifier: 0))
        dayNameArray.append("Event Day")
        eventDayArray.append(eventDayItems(description: "Event Day + 1", dateModifier: 1))
        dayNameArray.append("Event Day + 1")
        eventDayArray.append(eventDayItems(description: "Event Day + 2", dateModifier: 2))
        dayNameArray.append("Event Day + 2")
        eventDayArray.append(eventDayItems(description: "Event Day + 3", dateModifier: 3))
        dayNameArray.append("Event Day + 3")
    }
    
    public func delete()
    {
        if currentUser.checkWritePermission(rosteringRoleType)
        {
            myCloudDB.deleteEventTemplate(myEventID,
                                          role: myRole,
                                          dateModifier: myDateModifier,
                                          startTime: myStartTime,
                                          endTime: myEndTime,
                                          teamID: myTeamID)
        }
    }
}

//extension coreDatabase
//{
//    func saveEventTemplate(_ eventID: Int,
//                       role: String,
//                       numRequired: Int,
//                       dateModifier: Int,
//                       startTime: Date,
//                       endTime: Date,
//                       teamID: Int,
//                       updateTime: Date =  Date(), updateType: String = "CODE")
//    {
//        var myItem: EventTemplate!
//
//        let myReturn = getEventTemplate(eventID: eventID,
//                                        role: role,
//                                        dateModifier: dateModifier,
//                                        startTime: startTime,
//                                        endTime: endTime,
//                                        teamID: teamID)
//
//        if myReturn.count == 0
//        { // Add
//            myItem = EventTemplate(context: objectContext)
//            myItem.eventID = Int64(eventID)
//            myItem.role = role
//            myItem.numRequired = Int64(numRequired)
//            myItem.dateModifier = Int64(dateModifier)
//            myItem.startTime = startTime
//            myItem.endTime = endTime
//            myItem.teamID = Int64(teamID)
//
//            if updateType == "CODE"
//            {
//                myItem.updateTime =  Date()
//
//                myItem.updateType = "Add"
//            }
//            else
//            {
//                myItem.updateTime = updateTime
//                myItem.updateType = updateType
//            }
//        }
//        else
//        {
//            myItem = myReturn[0]
//            myItem.numRequired = Int64(numRequired)
//
//            if updateType == "CODE"
//            {
//                myItem.updateTime =  Date()
//                if myItem.updateType != "Add"
//                {
//                    myItem.updateType = "Update"
//                }
//            }
//            else
//            {
//                myItem.updateTime = updateTime
//                myItem.updateType = updateType
//            }
//        }
//
//        saveContext()
//
//        self.recordsProcessed += 1
//    }
//
//    func resetAllEventTemplate()
//    {
//        let fetchRequest = NSFetchRequest<EventTemplate>(entityName: "EventTemplate")
//
//        // Execute the fetch request, and cast the results to an array of LogItem objects
//        do
//        {
//            let fetchResults = try objectContext.fetch(fetchRequest)
//            for myItem in fetchResults
//            {
//                myItem.updateTime =  Date()
//                myItem.updateType = "Delete"
//            }
//        }
//        catch
//        {
//            print("Error occurred during execution: F \(error.localizedDescription)")
//        }
//
//        saveContext()
//    }
//
//    func clearDeletedEventTemplate(predicate: NSPredicate)
//    {
//        let fetchRequest2 = NSFetchRequest<EventTemplate>(entityName: "EventTemplate")
//
//        // Set the predicate on the fetch request
//        fetchRequest2.predicate = predicate
//
//        // Execute the fetch request, and cast the results to an array of LogItem objects
//        do
//        {
//            let fetchResults2 = try objectContext.fetch(fetchRequest2)
//            for myItem2 in fetchResults2
//            {
//                objectContext.delete(myItem2 as NSManagedObject)
//            }
//        }
//        catch
//        {
//            print("Error occurred during execution: G \(error.localizedDescription)")
//        }
//        saveContext()
//    }
//
//    func clearSyncedEventTemplate(predicate: NSPredicate)
//    {
//        let fetchRequest2 = NSFetchRequest<EventTemplate>(entityName: "EventTemplate")
//
//        // Set the predicate on the fetch request
//        fetchRequest2.predicate = predicate
//
//        // Execute the fetch request, and cast the results to an array of LogItem objects
//        do
//        {
//            let fetchResults2 = try objectContext.fetch(fetchRequest2)
//            for myItem2 in fetchResults2
//            {
//                myItem2.updateType = ""
//            }
//        }
//        catch
//        {
//            print("Error occurred during execution: H \(error.localizedDescription)")
//        }
//
//        saveContext()
//    }
//
//    func getEventTemplateForSync(_ syncDate: Date) -> [EventTemplate]
//    {
//        let fetchRequest = NSFetchRequest<EventTemplate>(entityName: "EventTemplate")
//
//
//
////let workingdate = Date().add(.hour, amount: -2)
////
////        let predicate = NSPredicate(format: "(updateTime >= %@)", workingdate as CVarArg)
//        let predicate = NSPredicate(format: "(updateTime >= %@)", syncDate as CVarArg)
//
//        // Set the predicate on the fetch request
//
//        fetchRequest.predicate = predicate
//        // Execute the fetch request, and cast the results to an array of  objects
//        do
//        {
//            let fetchResults = try objectContext.fetch(fetchRequest)
//
//            return fetchResults
//        }
//        catch
//        {
//            print("Error occurred during execution: I \(error.localizedDescription)")
//            return []
//        }
//    }
//
//    func deleteAllEventTemplate()
//    {
//        let fetchRequest2 = NSFetchRequest<EventTemplate>(entityName: "EventTemplate")
//
//        // Execute the fetch request, and cast the results to an array of LogItem objects
//        do
//        {
//            let fetchResults2 = try objectContext.fetch(fetchRequest2)
//            for myItem2 in fetchResults2
//            {
//                self.objectContext.delete(myItem2 as NSManagedObject)
//            }
//        }
//        catch
//        {
//            print("Error occurred during execution: J \(error.localizedDescription)")
//        }
//
//        saveContext()
//    }
//
//    func quickFixEventTemplate()
//    {
//        let fetchRequest2 = NSFetchRequest<EventTemplate>(entityName: "EventTemplate")
//
//        // Execute the fetch request, and cast the results to an array of LogItem objects
//        do
//        {
//            let fetchResults2 = try objectContext.fetch(fetchRequest2)
//            for myItem2 in fetchResults2
//            {
//                myItem2.role = "Steward"
//                myItem2.updateTime = Date()
//                saveContext()
//            }
//        }
//        catch
//        {
//            print("Error occurred during execution: J \(error.localizedDescription)")
//        }
//    }
//}
//

public struct EventTemplate {
    public var dateModifier: Int64
    public var endTime: Date?
    public var eventID: Int64
    public var numRequired: Int64
    public var role: String?
    public var startTime: Date?
    public var teamID: Int64
}

extension CloudKitInteraction
{
    private func populateEventTemplate(_ records: [CKRecord]) -> [EventTemplate]
    {
        var tempArray: [EventTemplate] = Array()
        
        for record in records
        {
            var eventID: Int64 = 0
            if record.object(forKey: "eventID") != nil
            {
                eventID = record.object(forKey: "eventID") as! Int64
            }
            
            var numRequired: Int64 = 0
            if record.object(forKey: "numRequired") != nil
            {
                numRequired = record.object(forKey: "numRequired") as! Int64
            }
            
            var dateModifier: Int64 = 0
            if record.object(forKey: "dateModifier") != nil
            {
                dateModifier = record.object(forKey: "dateModifier") as! Int64
            }
            
            var startTime = Date()
            if record.object(forKey: "startTime") != nil
            {
                startTime = record.object(forKey: "startTime") as! Date
            }
            
            var endTime = Date()
            if record.object(forKey: "endTime") != nil
            {
                endTime = record.object(forKey: "endTime") as! Date
            }
            
            var teamID: Int64 = 0
            if record.object(forKey: "teamID") != nil
            {
                teamID = record.object(forKey: "teamID") as! Int64
            }
            
            let tempItem = EventTemplate(dateModifier: dateModifier,
                                         endTime: endTime,
                                         eventID: eventID,
                                         numRequired: numRequired,
                                         role: record.object(forKey: "role") as? String,
                                         startTime: startTime,
                                         teamID: teamID)
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getEventTemplateItems(eventID: Int64, teamID: Int64)->[EventTemplate]
    {
        let predicate = NSPredicate(format: "eventID == \(eventID) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "EventTemplate", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [EventTemplate] = populateEventTemplate(returnArray)
        
        return shiftArray
    }
    
    func getEventTemplates(teamID: Int64)->[EventTemplate]
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "eventTemplate", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [EventTemplate] = populateEventTemplate(returnArray)
        
        //        for item in shiftArray
        //        {
        //            print("We have \(item.eventID)")
        //        }
        
        return shiftArray
    }
    
    func getEventTemplate(eventID: Int64,
                          role: String,
                          dateModifier: Int64,
                          startTime: Date,
                          endTime: Date,
                          teamID: Int64)->[EventTemplate]
    {
        let predicate = NSPredicate(format: "(role == \"\(role)\") AND (eventID == \(eventID)) AND (dateModifier == \(dateModifier)) AND (teamID == \(teamID)) AND (startTime == %@) AND (endTime == %@) AND (updateType != \"Delete\")", startTime as CVarArg, endTime as CVarArg)
        
        let query = CKQuery(recordType: "EventTemplate", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [EventTemplate] = populateEventTemplate(returnArray)
        
        return shiftArray
    }
    
    func deleteEventTemplate(_ eventID: Int64,
                             role: String,
                             dateModifier: Int64,
                             startTime: Date,
                             endTime: Date,
                             teamID: Int64)
    {
        let predicate = NSPredicate(format: "(role == \"\(role)\") AND (eventID == \(eventID)) AND (dateModifier == \(dateModifier)) AND (teamID == \(teamID)) AND (startTime == %@) AND (endTime == %@)", startTime as CVarArg, endTime as CVarArg)
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "EventTemplate", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            self.performPublicDelete(records!)
            
            sem.signal()
        })
        sem.wait()
    }
    
    func saveEventTemplateRecordToCloudKit(_ sourceRecord: EventTemplate)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(teamID == \(sourceRecord.teamID)) AND (role == \"\(sourceRecord.role!)\") AND (eventID == \(sourceRecord.eventID)) AND (dateModifier == \(sourceRecord.dateModifier)) AND (startTime == %@) AND (endTime == %@)", sourceRecord.startTime! as CVarArg, sourceRecord.endTime! as CVarArg) // better be accurate to get only the record you need
        let query = CKQuery(recordType: "eventTemplate", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: A \(error!.localizedDescription)")
            }
            else
            {
                // Lets go and get the additional details from the context1_1 table
                
                if records!.count > 0
                {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    
                    record!.setValue(sourceRecord.numRequired, forKey: "numRequired")
                    
                    // Save this record again
                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: B \(saveError!.localizedDescription)")
                            print("next level = \(saveError!)")
                            self.saveOK = false
                            sem.signal()
                        }
                        else
                        {
                            if debugMessages
                            {
                                NSLog("Successfully updated record!")
                            }
                            sem.signal()
                        }
                    })
                }
                else
                {  // Insert
                    let record = CKRecord(recordType: "EventTemplate")
                    record.setValue(sourceRecord.eventID, forKey: "eventID")
                    record.setValue(sourceRecord.role, forKey: "role")
                    record.setValue(sourceRecord.numRequired, forKey: "numRequired")
                    record.setValue(sourceRecord.dateModifier, forKey: "dateModifier")
                    record.setValue(sourceRecord.startTime, forKey: "startTime")
                    record.setValue(sourceRecord.endTime, forKey: "endTime")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    
                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: C \(saveError!.localizedDescription)")
                            self.saveOK = false
                            sem.signal()
                        }
                        else
                        {
                            if debugMessages
                            {
                                NSLog("Successfully saved record!")
                            }
                            currentUser.currentTeam?.eventTemplatesList = nil
                            sem.signal()
                        }
                    })
                }
            }
        })
        sem.wait()
    }
}


