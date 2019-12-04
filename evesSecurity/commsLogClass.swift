//
//  commsLogClass.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 13/4/18.
//  Copyright © 2018 Garry Eves. All rights reserved.
//

import Foundation
import CloudKit
import SwiftUI

public class commLogList: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myEntries:[commsLogEntry] = Array()
    
    public init(teamID: Int64)
    {
        super.init()
        
        if currentUser.currentTeam?.commsLog == nil
        {
            currentUser.currentTeam?.commsLog = myCloudDB.getCommsLog(teamID: teamID)
        }
        
        for myItem in (currentUser.currentTeam?.commsLog)!
        {
            let myObject = commsLogEntry(clientID: myItem.clientID,
                                         convTime: myItem.convTime,
                                         notes: myItem.notes,
                                         personID: myItem.personID,
                                         projectID: myItem.projectID,
                                         summary: myItem.summary,
                                         teamID: myItem.teamID,
                                         type: myItem.type,
                                         leadID: myItem.leadID)
            myEntries.append(myObject)
        }
        sortLog()
    }
    
    public init(teamID: Int64, personID: Int64)
    {
        super.init()
        
        if currentUser.currentTeam?.commsLog == nil
        {
            currentUser.currentTeam?.commsLog = myCloudDB.getCommsLog(teamID: teamID, personID: personID)
        }
        
        for myItem in (currentUser.currentTeam?.commsLog)!
        {
            let myObject = commsLogEntry(clientID: myItem.clientID,
                                         convTime: myItem.convTime,
                                         notes: myItem.notes,
                                         personID: myItem.personID,
                                         projectID: myItem.projectID,
                                         summary: myItem.summary,
                                         teamID: myItem.teamID,
                                         type: myItem.type,
                                         leadID: myItem.leadID)
            myEntries.append(myObject)
        }
        sortLog()
    }
    
    public init(teamID: Int64, leadID: Int64)
    {
        super.init()
        
        if currentUser.currentTeam?.commsLog == nil
        {
            currentUser.currentTeam?.commsLog = myCloudDB.getCommsLog(teamID: teamID, leadID: leadID)
        }
        
        for myItem in (currentUser.currentTeam?.commsLog)!
        {
            let myObject = commsLogEntry(clientID: myItem.clientID,
                                         convTime: myItem.convTime,
                                         notes: myItem.notes,
                                         personID: myItem.personID,
                                         projectID: myItem.projectID,
                                         summary: myItem.summary,
                                         teamID: myItem.teamID,
                                         type: myItem.type,
                                         leadID: myItem.leadID)
            myEntries.append(myObject)
        }
        sortLog()
    }
    
    public init(teamID: Int64, projectID: Int64)
    {
        super.init()
        
        if currentUser.currentTeam?.commsLog == nil
        {
            currentUser.currentTeam?.commsLog = myCloudDB.getCommsLog(teamID: teamID, projectID: projectID)
        }
        
        for myItem in (currentUser.currentTeam?.commsLog)!
        {
            let myObject = commsLogEntry(clientID: myItem.clientID,
                                         convTime: myItem.convTime,
                                         notes: myItem.notes,
                                         personID: myItem.personID,
                                         projectID: myItem.projectID,
                                         summary: myItem.summary,
                                         teamID: myItem.teamID,
                                         type: myItem.type,
                                         leadID: myItem.leadID)
            myEntries.append(myObject)
        }
        sortLog()
    }
    
    public init(teamID: Int64, clientID: Int64)
    {
        super.init()
        
        if currentUser.currentTeam?.commsLog == nil
        {
            currentUser.currentTeam?.commsLog = myCloudDB.getCommsLog(teamID: teamID, clientID: clientID)
        }
        
        for myItem in (currentUser.currentTeam?.commsLog)!
        {
            let myObject = commsLogEntry(clientID: myItem.clientID,
                                         convTime: myItem.convTime,
                                         notes: myItem.notes,
                                         personID: myItem.personID,
                                         projectID: myItem.projectID,
                                         summary: myItem.summary,
                                         teamID: myItem.teamID,
                                         type: myItem.type,
                                         leadID: myItem.leadID)
            myEntries.append(myObject)
        }
        sortLog()
    }
    
    public func sortLog()
    {
        if myEntries.count > 0
        {
            myEntries.sort
                {
                    if $0.convTime == $1.convTime
                    {
                        return $0.type < $1.type
                    }
                    else
                    {
                        return $0.convTime > $1.convTime
                    }
            }
        }
    }
    
    public var logEntries: [commsLogEntry]
    {
        get
        {
            return myEntries
        }
    }
}

public class commsLogEntry: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myClientID: Int64 = 0
    fileprivate var myPersonID: Int64 = 0
    fileprivate var myProjectID: Int64 = 0
    fileprivate var myLeadID: Int64 = 0
    fileprivate var myConvTime: Date = Date()
    fileprivate var myNotes: String = ""
    fileprivate var mySummary: String = ""
    fileprivate var myType: String = ""
    fileprivate var myTeamID: Int64 = 0
    
    public var clientID: Int64
    {
        get
        {
            return myClientID
        }
        set
        {
            myClientID = newValue
        }
    }
    
    public var personID: Int64
    {
        get
        {
            return myPersonID
        }
        set
        {
            myPersonID = newValue
        }
    }
    
    public var projectID: Int64
    {
        get
        {
            return myProjectID
        }
        set
        {
            myProjectID = newValue
        }
    }
    
    public var leadID: Int64
    {
        get
        {
            return myLeadID
        }
        set
        {
            myLeadID = newValue
        }
    }
    
    public var notes: String
    {
        get
        {
            return myNotes
        }
        set
        {
            myNotes = newValue
        }
    }
    
    public var summary: String
    {
        get
        {
            return mySummary
        }
        set
        {
            mySummary = newValue
        }
    }
    
    public var type: String
    {
        get
        {
            return myType
        }
        set
        {
            myType = newValue
        }
    }
    
    public var convTime: Date
    {
        get
        {
            return myConvTime
        }
        set
        {
            myConvTime = newValue
        }
    }
    
    public var displayConvTime: String
    {
        get
        {
            if myConvTime == getDefaultDate() as Date
            {
                return ""
            }
            else
            {
                let myDateFormatter = DateFormatter()
                myDateFormatter.dateStyle = .short
                myDateFormatter.timeStyle = .short
                return myDateFormatter.string(from: myConvTime)
            }
        }
    }
    
    public init(teamID: Int64)
    {
        super.init()
        
        myTeamID = teamID
    }
    
    public init(clientID: Int64,
                convTime: Date,
                notes: String,
                personID: Int64,
                projectID: Int64,
                summary: String,
                teamID: Int64,
                type: String,
                leadID: Int64)
    {
        super.init()
        
        myClientID = clientID
        myConvTime = convTime
        myNotes = notes
        myPersonID = personID
        myProjectID = projectID
        mySummary = summary
        myTeamID = teamID
        myType = type
        myLeadID = leadID
    }
    
    public func save()
    {
        if currentUser.checkWritePermission(financialsRoleType) || currentUser.checkWritePermission(salesRoleType)
        {
            let temp = CommsLog(clientID: myClientID, convTime: myConvTime, notes: myNotes, personID: myPersonID, projectID: myProjectID, summary: mySummary, teamID: myTeamID, type: myType, leadID: myLeadID)
            
            myCloudDB.saveCommsLogRecordToCloudKit(temp)
            
            currentUser.currentTeam?.commsLog = nil
        }
    }
}

public struct CommsLog {
    public var clientID: Int64
    public var convTime: Date
    public var notes: String
    public var personID: Int64
    public var projectID: Int64
    public var summary: String
    public var teamID: Int64
    public var type: String
    public var leadID: Int64
}

extension CloudKitInteraction
{
    private func populateCommsLog(_ records: [CKRecord]) -> [CommsLog]
    {
        var tempArray: [CommsLog] = Array()
        
        for record in records
        {
            var clientID: Int64 = 0
            if record.object(forKey: "clientID") != nil
            {
                clientID = record.object(forKey: "clientID") as! Int64
            }
            
            var convTime: Date = getDefaultDate()
            if record.object(forKey: "convTime") != nil
            {
                convTime = record.object(forKey: "convTime") as! Date
            }
            
            var personID: Int64 = 0
            if record.object(forKey: "personID") != nil
            {
                personID = record.object(forKey: "personID") as! Int64
            }
            
            var projectID: Int64 = 0
            if record.object(forKey: "projectID") != nil
            {
                projectID = record.object(forKey: "projectID") as! Int64
            }
            
            var teamID: Int64 = 0
            if record.object(forKey: "teamID") != nil
            {
                teamID = record.object(forKey: "teamID") as! Int64
            }
            
            var leadID: Int64 = 0
            if record.object(forKey: "leadID") != nil
            {
                leadID = record.object(forKey: "leadID") as! Int64
            }
            
            let tempItem = CommsLog(clientID: clientID,
                                    convTime: convTime,
                                    notes: record.object(forKey: "notes") as! String,
                                    personID: personID,
                                    projectID: projectID,
                                    summary: record.object(forKey: "summary") as! String,
                                    teamID: teamID,
                                    type: record.object(forKey: "type") as! String,
                                    leadID: leadID)
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getCommsLog(teamID: Int64)->[CommsLog]
    {
        let predicate = NSPredicate(format: "teamID == \(teamID)")
        
        let query = CKQuery(recordType: "CommsLog", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [CommsLog] = populateCommsLog(returnArray)
        
        return shiftArray
    }
    
    func getCommsLog(teamID: Int64, personID: Int64)->[CommsLog]
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (personID == \(personID))")
        
        let query = CKQuery(recordType: "CommsLog", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [CommsLog] = populateCommsLog(returnArray)
        
        return shiftArray
    }
    
    func getCommsLog(teamID: Int64, leadID: Int64)->[CommsLog]
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (leadID == \(leadID))")
        
        let query = CKQuery(recordType: "CommsLog", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [CommsLog] = populateCommsLog(returnArray)
        
        return shiftArray
    }
    
    func getCommsLog(teamID: Int64, projectID: Int64)->[CommsLog]
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (projectID == \(projectID))")
        
        let query = CKQuery(recordType: "CommsLog", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [CommsLog] = populateCommsLog(returnArray)
        
        return shiftArray
    }
    
    func getCommsLog(teamID: Int64, clientID: Int64)->[CommsLog]
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (clientID == \(clientID))")
        
        let query = CKQuery(recordType: "CommsLog", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [CommsLog] = populateCommsLog(returnArray)
        
        return shiftArray
    }
    
    func saveCommsLogRecordToCloudKit(_ sourceRecord: CommsLog)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(convTime == %@) AND (teamID == \(sourceRecord.teamID))", sourceRecord.convTime as CVarArg) // better be accurate to get only the record you need
        let query = CKQuery(recordType: "CommsLog", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else
            {
                // Lets go and get the additional details from the context1_1 table
                
                if records!.count > 0
                {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    
                    record!.setValue(sourceRecord.clientID, forKey: "clientID")
                    record!.setValue(sourceRecord.notes, forKey: "notes")
                    record!.setValue(sourceRecord.personID, forKey: "personID")
                    record!.setValue(sourceRecord.projectID, forKey: "projectID")
                    record!.setValue(sourceRecord.summary, forKey: "summary")
                    record!.setValue(sourceRecord.leadID, forKey: "leadID")
                    record!.setValue(sourceRecord.type, forKey: "type")
                    
                    // Save this record again
                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
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
                    let record = CKRecord(recordType: "CommsLog")
                    record.setValue(sourceRecord.clientID, forKey: "clientID")
                    record.setValue(sourceRecord.convTime, forKey: "convTime")
                    record.setValue(sourceRecord.notes, forKey: "notes")
                    record.setValue(sourceRecord.personID, forKey: "personID")
                    record.setValue(sourceRecord.leadID, forKey: "leadID")
                    record.setValue(sourceRecord.projectID, forKey: "projectID")
                    record.setValue(sourceRecord.summary, forKey: "summary")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    record.setValue(sourceRecord.type, forKey: "type")
                    
                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
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

