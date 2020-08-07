//
//  clientsClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 10/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CloudKit
import SwiftUI

public let alertClientNoProject = "client no project"
public let alertClientNoRates = "client no rate"
public let alertClientInvoiceUnapproved = "Invoices that have not been Approved"
public let alertClientInvoiceUnpaid = "Invoices that have not been Paid"

public class clients: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myClients:[client] = Array()
    
    public init(teamID: Int64, isActive: Bool)
    {
        super.init()
        
        if currentUser.currentTeam?.clients == nil
        {
            currentUser.currentTeam?.clients = myCloudDB.getClients(teamID: teamID, isActive: isActive)
        }
        
        for myItem in (currentUser.currentTeam?.clients)!
        {
            let myObject = client(clientID: myItem.clientID,
                                  clientName: myItem.clientName,
                                  clientContact: myItem.clientContact,
                                  teamID: myItem.teamID,
                                  note: myItem.note,
                                  isActive: myItem.isActive
            )
            myClients.append(myObject)
        }
        self.sortArrayByClient()
    }
    
    public init(alertQuery: String, teamID: Int64, isActive: Bool) {
        super.init()

        if currentUser.currentTeam?.clients == nil {
            currentUser.currentTeam?.clients = myCloudDB.getClients(teamID: teamID, isActive: isActive)
        }
        
        var returnArray: [Clients] = Array()
        
        myClients.removeAll()

        switch alertQuery {
            case alertClientNoProject:
                for myItem in (currentUser.currentTeam?.clients)!
                {
                    let myReturn = projects(clientID: myItem.clientID, teamID: teamID, isActive: true)
                    
                    if myReturn.projectList.count == 0 {
                        returnArray.append(myItem)
                    }
                }
                
            case alertClientNoRates:
                
                let rateList = rates(teamID: teamID)
                
                for myItem in (currentUser.currentTeam?.clients)! {
                    
                    let myReturn = rateList.rates.filter { $0.clientID == myItem.clientID}

                    if myReturn.count == 0 {
                        returnArray.append(myItem)
                    }
                }
                
            default:
                let _ = 1
        }
        
        for myItem in returnArray {
            let myObject = client(clientID: myItem.clientID,
                                  clientName: myItem.clientName,
                                  clientContact: myItem.clientContact,
                                  teamID: myItem.teamID,
                                  note: myItem.note,
                                  isActive: myItem.isActive
            )
            myClients.append(myObject)
        }
                
        self.sortArrayByClient()
    }
    
    private func sortArrayByClient()
    {
        myClients.sort
            {
                if $0.name == $1.name
                {
                    return $0.clientID < $1.clientID
                }
                else
                {
                    return $0.name < $1.name
                }
        }
    }
    
    public var clients: [client]
    {
        get
        {
            return myClients
        }
    }
}

@dynamicMemberLookup
public class client: NSObject, Identifiable, ObservableObject
{
    public let ID = UUID()
    fileprivate var myClientID: Int64 = 0
    fileprivate var myClientName: String = "New Client"
    fileprivate var myClientContact: Int64 = 0
    fileprivate var myClientNote: String = ""
    fileprivate var myTeamID: Int64 = 0
    fileprivate var myIsActive: Bool = true
    fileprivate var myComms: commLogList!
    fileprivate var myInvoices: clientInvoices!
    fileprivate var myShifts: shifts!
    fileprivate var myProjects: projects!
    fileprivate var myProjectList = project()
    fileprivate var myRateList: rates!
    
    @Published var reloadScreen = false
    
    public var clientID: Int64
    {
        get
        {
            return myClientID
        }
    }
    
    public var name: String
    {
        get
        {
            return myClientName
        }
        set
        {
            myClientName = newValue
            currentUser.currentTeam?.clients = nil
            reloadScreen.toggle()
        }
    }
    
    public var note: String
    {
        get
        {
            return myClientNote
        }
        set
        {
            myClientNote = newValue
            reloadScreen.toggle()
        }
    }
    
    public var contact: Int64
    {
        get
        {
            return myClientContact
        }
        set
        {
            myClientContact = newValue
            reloadScreen.toggle()
        }
    }
    
    public var isActive: Bool
    {
        get
        {
            return myIsActive
        }
        set
        {
            myIsActive = newValue
            currentUser.currentTeam?.clients = nil
            reloadScreen.toggle()
        }
    }
    
    public var comms: [commsLogEntry]
    {
        get
        {
            if myComms == nil
            {
                return []
            }
            return myComms.logEntries
        }
    }
    
    public var invoices: clientInvoices?
    {
        get
        {
            return myInvoices
        }
    }
    
    public var shiftArray: [shift]
    {
        get
        {
            return myShifts.shifts
        }
    }
    
    subscript<T>(dynamicMember keyPath: KeyPath<project, T>) -> T {
        return myProjectList[keyPath: keyPath]
    }
    
    public var projectList: projects
    {
        get
        {
            return projects(clientID: myClientID, teamID: myTeamID, isActive: true)
        }
    }
    
    public var allProjectList: projects
    {
        get
        {
            return projects(clientID: myClientID, teamID: myTeamID, isActive: false)
        }
    }
    
    public var rateList: rates {
        get {
            if myRateList == nil {
                myRateList = rates(clientID: myClientID, teamID: myTeamID)
            }
            return myRateList
        }
    }
    
    func resetRatesList() {
        myRateList = nil
    }
    
//    public func projectList(_ isActive: Bool) -> [project]
//    {
//        return projects(clientID: myClientID, teamID: myTeamID, isActive: isActive, type: "").projectList
//    }
    
    override init() {}
    
    public init(teamID: Int64)
    {
        super.init()
        
        createClient(teamID: teamID)
    }
    
    public init(clientID: Int64, teamID: Int64)
    {
        super.init()
        
        loadClient(clientID: clientID, teamID: teamID)
    }
    
    public init(clientID: Int64,
                clientName: String,
                clientContact: Int64,
                teamID: Int64,
                note: String,
                isActive: Bool)
    {
        super.init()
        
        myClientID = clientID
        myClientName = clientName
        myClientContact = clientContact
        myTeamID = teamID
        myClientNote = note
        myIsActive = isActive
    }
    
    func createClient(teamID: Int64)
    {
        myClientID = myCloudDB.getNextID("Client", teamID: teamID)
        
        myTeamID = teamID
        
        currentUser.currentTeam?.clients = nil
        
        myShifts = nil
        
        myInvoices = nil
        
        save()
    }
    
    func loadClient(clientID: Int64, teamID: Int64)
    {
        if currentUser.currentTeam?.clients == nil
        {
            currentUser.currentTeam?.clients = myCloudDB.getClients(teamID: teamID, isActive: false)
        }
        
        var myItem: Clients!
        
        for item in (currentUser.currentTeam?.clients)!
        {
            if item.clientID == clientID
            {
                myItem = item
                break
            }
        }
        
        if myItem != nil
        {
            myClientID = myItem.clientID
            myClientName = myItem.clientName
            myClientContact = myItem.clientContact
            myTeamID = myItem.teamID
            myClientNote = myItem.note
            myIsActive = myItem.isActive
        }
        
        myShifts = nil
        
        myInvoices = nil
    }
    
    public func loadComms()
    {
        myComms = commLogList(teamID: currentUser.currentTeam!.teamID, clientID: myClientID)
    }
    
    func loadInvoices(_ isActive: Bool)
    {
        myInvoices = clientInvoices(teamID: currentUser.currentTeam!.teamID, clientID: myClientID, isActive: isActive)
    }
    
    func loadShifts(month: Int64, year: Int64)
    {
        myShifts = shifts(clientID: myClientID, month: month, year: year, teamID: myTeamID)
    }
    
//    func calculateInvoice(month: Int64, year: Int64) {
//
//    }
    
    public func save()
    {
        if currentUser.checkWritePermission(pmRoleType) || currentUser.checkWritePermission(salesRoleType)
        {
            let temp = Clients(clientContact: myClientContact, clientID: myClientID, clientName: myClientName, note: myClientNote, teamID: myTeamID, isActive: myIsActive)
            
            myCloudDB.saveClientRecordToCloudKit(temp)
        }
    }
    
    public func delete()
    {
        if currentUser.checkWritePermission(pmRoleType) || currentUser.checkWritePermission(salesRoleType)
        {
            // There are a number of actions to take when deleting a client, mainly to make sure we maintain data integrity
            
            // Close any existing projects
            
            for myProject in projects(clientID: myClientID, teamID: myTeamID, isActive: true).projectList
            {
                myProject.projectStatus = archivedProjectStatus
            }
            
            // Now delete the client
            
            myCloudDB.deleteClient(myClientID, teamID: myTeamID)
            currentUser.currentTeam?.clients = nil
        }
    }
}

extension alerts
{
    public func clientAlerts(_ teamID: Int64) {
        // check for clients with no projects
        var recordCount: Int = 0

        for myItem in clients(alertQuery: alertClientNoProject, teamID: teamID, isActive: true).clients {
            let alertEntry = alertItem()
            
            alertEntry.displayText = "Client has no Contracts"
            alertEntry.name = myItem.name
            alertEntry.source = "Client"
            alertEntry.type = "Client has no Contracts"
            alertEntry.object = myItem
            
            alertList.append(alertEntry)
            
            recordCount += 1
        }
        
        let tempEntry = alertSummary(displayText: "Client has no Contracts", displayAmount: recordCount)
        
        alertSummaryList.append(tempEntry)
        
        recordCount = 0
        
 //       notificationCenter.post(name: NotificationAlertUpdate, object: nil)
        // check for clients with no projects
 
        for myItem in clients(alertQuery: alertClientNoRates, teamID: teamID, isActive: true).clients {
            let alertEntry = alertItem()
            
            alertEntry.displayText = "Client has no Rates"
            alertEntry.name = myItem.name
            alertEntry.source = "Client"
            alertEntry.type = "Client has no Rates"
            alertEntry.object = myItem
            
            alertList.append(alertEntry)
            
            recordCount += 1
        }

        let tempEntry1 = alertSummary(displayText: "Client has no Rates", displayAmount: recordCount)
        
        alertSummaryList.append(tempEntry1)
        
        recordCount = 0
    }
}

public struct Clients {
    public var clientContact: Int64
    public var clientID: Int64
    public var clientName: String = ""
    public var note: String = ""
    public var teamID: Int64
    public var isActive: Bool = true
}

extension CloudKitInteraction
{
    private func populateClients(_ records: [CKRecord]) -> [Clients]
    {
        var tempArray: [Clients] = Array()
        
        for record in records
        {
            let tempItem = Clients(clientContact: decodeInt64(record.object(forKey: "clientContact")),
                                   clientID: decodeInt64(record.object(forKey: "clientID")),
                                   clientName: decodeString(record.object(forKey: "clientName")),
                                   note: decodeString(record.object(forKey: "note")),
                                   teamID: decodeInt64(record.object(forKey: "teamID")),
                                   isActive: decodeBool(record.object(forKey: "isActive"), defaultReturn: true))
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getClientDetails(clientID: Int64, teamID: Int64)->[Clients]
    {
        let predicate = NSPredicate(format: "(clientID == \(clientID)) AND (teamID = \(teamID))")
        
        let query = CKQuery(recordType: "Clients", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Clients] = populateClients(returnArray)
        
        return shiftArray
    }
    
    func deleteClient(_ clientID: Int64, teamID: Int64)
    {
        let predicate = NSPredicate(format: "(clientID == \(clientID)) AND (teamID = \(teamID))")
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "Clients", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            self.performPublicDelete(records!)
            
            sem.signal()
        })
        sem.wait()
    }
    
    func getClients(teamID: Int64, isActive: Bool) -> [Clients]
    {
        var predicate: NSPredicate!
        
        if isActive
        {
            predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\") AND (isActive != \"false\")")
        }
        else
        {
            predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\")")
        }
        
        let query = CKQuery(recordType: "Clients", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Clients] = populateClients(returnArray)
        
        return shiftArray
    }
    
    func saveClientRecordToCloudKit(_ sourceRecord: Clients)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(clientID == \(sourceRecord.clientID)) AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Clients", predicate: predicate)
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
                    record!.setValue(sourceRecord.clientName, forKey: "clientName")
                    record!.setValue(sourceRecord.clientContact, forKey: "clientContact")
                    record!.setValue(sourceRecord.note, forKey: "note")
                    
                    if sourceRecord.isActive
                    {
                        record!.setValue("true", forKey: "isActive")
                    }
                    else
                    {
                        record!.setValue("false", forKey: "isActive")
                    }
                    
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
                    let record = CKRecord(recordType: "Clients")
                    
                    record.setValue(sourceRecord.clientID, forKey: "clientID")
                    record.setValue(sourceRecord.clientName, forKey: "clientName")
                    record.setValue(sourceRecord.clientContact, forKey: "clientContact")
                    record.setValue(sourceRecord.note, forKey: "note")
                    
                    if sourceRecord.isActive
                    {
                        record.setValue("true", forKey: "isActive")
                    }
                    else
                    {
                        record.setValue("false", forKey: "isActive")
                    }
                    
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    
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
    
    func getDeletedClients(_ teamID: Int64) -> [Clients]
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType == \"Delete\")")
        
        let query = CKQuery(recordType: "Clients", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Clients] = populateClients(returnArray)
        
        return shiftArray
    }
}

