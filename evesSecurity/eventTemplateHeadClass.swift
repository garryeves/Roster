//
//  EventTemplateHeadClass.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 23/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
//import CoreData
import CloudKit
import SwiftUI

let newTemplateName = "Template Name"

public class eventTemplateHeads: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myEventTemplateHead:[eventTemplateHead] = Array()
    
    public init(teamID: Int64)
    {
        if currentUser.currentTeam?.eventTemplateHeadsList == nil
        {
            currentUser.currentTeam?.eventTemplateHeadsList = myCloudDB.getEventTemplateHeadItems(teamID: teamID)
        }
        
        for myItem in (currentUser.currentTeam?.eventTemplateHeadsList)!
        {
            let myObject = eventTemplateHead(eventID: myItem.eventID,
                                             eventName: myItem.eventName,
                                             teamID: myItem.teamID)
            
            myEventTemplateHead.append(myObject)
        }
    }
    
    public var templates: [eventTemplateHead]
    {
        get
        {
            return myEventTemplateHead
        }
    }
}

public class eventTemplateHead: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myTemplateID: Int64 = 0
    fileprivate var myTemplateName: String = newTemplateName
    fileprivate var myTeamID: Int64 = 0
    fileprivate var myRoles: eventTemplates!
    
    public var templateID: Int64
    {
        get
        {
            return myTemplateID
        }
    }
    
    public var templateName: String
    {
        get
        {
            return myTemplateName
        }
        set
        {
            myTemplateName = newValue
         //   save()
        }
    }
    
    public var roles: eventTemplates?
    {
        get
        {
            return myRoles
        }
    }
    
    override init() {
        super.init()
    }
    
    public init(teamID: Int64)
    {
        super.init()
        
        createTemplate(teamID: teamID)
    }
    
//    public init(eventID: Int64, teamID: Int64)
//    {
//        super.init()
//
//        loadTemplate(eventID: eventID, teamID: teamID)
//    }
    
    public init(eventID: Int64,
                eventName: String,
                teamID: Int64)
    {
        super.init()
        
        myTemplateID = eventID
        myTemplateName = eventName
        myTeamID = teamID
    }
    
    public func createTemplate(teamID: Int64) {
        myTemplateID = myCloudDB.getNextID("EventTemplateHead", teamID: teamID)
        myTeamID = teamID
        myTemplateName = newTemplateName
        save()
        
        myRoles = nil
    
        currentUser.currentTeam?.eventTemplateHeadsList = nil
    }
    
    public func loadTemplate(templateID: Int64, teamID: Int64) {
        if currentUser.currentTeam?.eventTemplateHeadsList == nil
        {
            currentUser.currentTeam?.eventTemplateHeadsList = myCloudDB.getEventTemplateHeadItems(teamID: teamID)
        }
        
        var myItem: EventTemplateHead!
        
        for item in (currentUser.currentTeam?.eventTemplateHeadsList)!
        {
            if item.eventID == templateID
            {
                myItem = item
                break
            }
        }
        
        if myItem != nil
        {
            myTemplateID = myItem.eventID
            myTemplateName = myItem.eventName
            myTeamID = myItem.teamID
        }
    }
    
    public func save()
    {
        if currentUser.checkWritePermission(rosteringRoleType)
        {
            let temp = EventTemplateHead(eventID: myTemplateID, eventName: myTemplateName, teamID: myTeamID)
            
            myCloudDB.saveEventTemplateHeadRecordToCloudKit(temp)
        }
    }
    
    public func delete()
    {
        if currentUser.checkWritePermission(rosteringRoleType)
        {
            myCloudDB.deleteEventTemplateHead(myTemplateID, teamID: myTeamID)
            currentUser.currentTeam?.eventTemplateHeadsList = nil
        }
    }
    
    public func loadRoles()
    {
        myRoles = eventTemplates(eventID: myTemplateID, teamID: myTeamID)
    }
    
    public func addRole(role: String,
                        numRequired: Int64,
                        dateModifier: Int64,
                        startTime: Date,
                        endTime: Date)
    {
        let newRole = eventTemplate(eventID: myTemplateID, role: role, dateModifier: dateModifier, startTime: startTime, endTime: endTime, teamID: myTeamID)
        newRole.numRequired = numRequired
    }
}

//extension coreDatabase
//{
//    func saveEventTemplateHead(_ templateID: Int,
//                           templateName: String,
//                           teamID: Int,
//                           updateTime: Date =  Date(), updateType: String = "CODE")
//    {
//        var myItem: EventTemplateHead!
//
//        let myReturn = getEventTemplateHead(templateID: templateID, teamID: teamID)
//
//        if myReturn.count == 0
//        { // Add
//            myItem = EventTemplateHead(context: objectContext)
//            myItem.eventID = Int64(templateID)
//            myItem.eventName = templateName
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
//            myItem.eventName = templateName
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
//    func resetAllEventTemplateHead()
//    {
//        let fetchRequest = NSFetchRequest<EventTemplateHead>(entityName: "EventTemplateHead")
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
//    func clearDeletedEventTemplateHead(predicate: NSPredicate)
//    {
//        let fetchRequest2 = NSFetchRequest<EventTemplateHead>(entityName: "EventTemplateHead")
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
//    func clearSyncedEventTemplateHead(predicate: NSPredicate)
//    {
//        let fetchRequest2 = NSFetchRequest<EventTemplateHead>(entityName: "EventTemplateHead")
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
//    func getEventTemplateHeadForSync(_ syncDate: Date) -> [EventTemplateHead]
//    {
//        let fetchRequest = NSFetchRequest<EventTemplateHead>(entityName: "EventTemplateHead")
//
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
//    func deleteAllEventTemplateHead()
//    {
//        let fetchRequest2 = NSFetchRequest<EventTemplateHead>(entityName: "EventTemplateHead")
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
//}
//

public struct EventTemplateHead {
    public var eventID: Int64
    public var eventName: String
    public var teamID: Int64
}

extension CloudKitInteraction
{
    private func populateEventTemplateHead(_ records: [CKRecord]) -> [EventTemplateHead]
    {
        var tempArray: [EventTemplateHead] = Array()
        
        for record in records
        {
            let tempItem = EventTemplateHead(eventID: decodeInt64(record.object(forKey: "eventID")),
                                             eventName: decodeString(record.object(forKey: "eventName")),
                                             teamID: decodeInt64(record.object(forKey: "teamID")))
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getEventTemplateHeadItems(teamID: Int64)->[EventTemplateHead]
    {
        let predicate = NSPredicate(format: "teamID == \(teamID) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "EventTemplateHead", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [EventTemplateHead] = populateEventTemplateHead(returnArray)
        
        return shiftArray
    }
    
    func getEventTemplateHead(templateID: Int64, teamID: Int64)->[EventTemplateHead]
    {
        let predicate = NSPredicate(format: "eventID == \(templateID) AND (teamID == \(teamID))")
        
        let query = CKQuery(recordType: "EventTemplateHead", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [EventTemplateHead] = populateEventTemplateHead(returnArray)
        
        return shiftArray
    }
    
    func deleteEventTemplateHead(_ templateID: Int64, teamID: Int64)
    {
        let predicate = NSPredicate(format: "eventID == \(templateID) AND (teamID == \(teamID))")
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "EventTemplateHead", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            self.performPublicDelete(records!)
            
            sem.signal()
        })
        sem.wait()
    }
    
    func saveEventTemplateHeadRecordToCloudKit(_ sourceRecord: EventTemplateHead)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(teamID == \(sourceRecord.teamID)) AND (eventID == \(sourceRecord.eventID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "EventTemplateHead", predicate: predicate)
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
                    
                    record!.setValue(sourceRecord.eventName, forKey: "eventName")
                    
                    // Save this record again
                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: B \(saveError!.localizedDescription)")
                            self.saveOK = false
                            print("next level = \(saveError!)")
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
                    let record = CKRecord(recordType: "EventTemplateHead")
                    record.setValue(sourceRecord.eventID, forKey: "eventID")
                    record.setValue(sourceRecord.eventName, forKey: "eventName")
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
                            sem.signal()
                        }
                    })
                }
            }
        })
        sem.wait()
    }
}



