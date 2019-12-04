//
//  Contacts.swift
//  evesSecurity
//
//  Created by Garry Eves on 10/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
//import CoreData
import CloudKit
import UIKit
import SwiftUI

public class personContacts: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myContacts:[contactItem] = Array()
    
    public init(personID: Int64, teamID: Int64)
    {
        if currentUser.currentTeam?.contacts == nil
        {
            currentUser.currentTeam?.contacts = myCloudDB.getContacts(teamID: teamID)
        }
        
        var workingArray: [Contacts] = Array()
        
        for item in (currentUser.currentTeam?.contacts)!
        {
            if (item.personID == personID)
            {
                workingArray.append(item)
            }
        }
        
        for myItem in workingArray
        {
            let myObject = contactItem(personID: myItem.personID,
                                       contactType: myItem.contactType,
                                       contactValue: myItem.contactValue,
                                       teamID: myItem.teamID,
                                       clientID: myItem.clientID,
                                       projectID: myItem.projectID)
            myContacts.append(myObject)
        }
    }
    
    public init(clientID: Int64, teamID: Int64)
    {
        var workingArray: [Contacts] = Array()
        
        for item in (currentUser.currentTeam?.contacts)!
        {
            if (item.clientID == clientID)
            {
                workingArray.append(item)
            }
        }
        
        for myItem in workingArray
        {
            let myObject = contactItem(personID: myItem.personID,
                                       contactType: myItem.contactType,
                                       contactValue: myItem.contactValue,
                                       teamID: myItem.teamID,
                                       clientID: myItem.clientID,
                                       projectID: myItem.projectID)
            myContacts.append(myObject)
        }
    }
    
    public init(projectID: Int64, teamID: Int64)
    {
        var workingArray: [Contacts] = Array()
        
        for item in (currentUser.currentTeam?.contacts)!
        {
            if (item.projectID == projectID)
            {
                workingArray.append(item)
            }
        }
        
        for myItem in workingArray
        {
            let myObject = contactItem(personID: myItem.personID,
                                       contactType: myItem.contactType,
                                       contactValue: myItem.contactValue,
                                       teamID: myItem.teamID,
                                       clientID: myItem.clientID,
                                       projectID: myItem.projectID)
            myContacts.append(myObject)
        }
    }
    
    public var contacts: [contactItem]
    {
        get
        {
            return myContacts
        }
    }
}

public class contactItem: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myPersonID: Int64 = 0
    fileprivate var myContactType: String = ""
    fileprivate var myContactValue: String = ""
    fileprivate var myTeamID: Int64 = 0
    fileprivate var myClientID: Int64 = 0
    fileprivate var myProjectID: Int64 = 0
    
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
    
    public var contactType: String
    {
        get
        {
            return myContactType
        }
        set
        {
            myContactType = newValue
        }
    }
    
    public var contactValue: String
    {
        get
        {
            return myContactValue
        }
        set
        {
            myContactValue = newValue
        }
    }
    
    override public init() {}
    
    public init(teamID: Int64, contactType: String, personID: Int64, clientID: Int64, projectID: Int64)
    {
        super.init()
        
        myTeamID = teamID
        myContactType = contactType
        myPersonID = personID
        myClientID = clientID
        myProjectID = projectID
        save()
        
        currentUser.currentTeam?.contacts = nil
    }
    
    public init(teamID: Int64, contactType: String, contactValue: String, personID: Int64, clientID: Int64, projectID: Int64)
    {
        super.init()
        
        myTeamID = teamID
        myContactType = contactType
        myPersonID = personID
        myClientID = clientID
        myProjectID = projectID
        myContactValue = contactValue
        save()
        
        currentUser.currentTeam?.contacts = nil
    }
    
    public init(personID: Int64, teamID: Int64)
    {
        super.init()
        var myItem: Contacts!
        
        for item in (currentUser.currentTeam?.contacts)!
        {
            if (item.personID == personID)
            {
                myItem = item
                break
            }
        }
        
        myPersonID = personID
        
        if myItem != nil
        {
            myContactType = myItem.contactType
            myContactValue = myItem.contactValue
            myClientID = myItem.clientID
            myProjectID = myItem.projectID
            myTeamID = myItem.teamID
        }
    }
    
    public init(clientID: Int64, teamID: Int64)
    {
        super.init()
        var myItem: Contacts!
        
        for item in (currentUser.currentTeam?.contacts)!
        {
            if (item.clientID == clientID)
            {
                myItem = item
                break
            }
        }
        
        myClientID = clientID
        
        if myItem != nil
        {
            myPersonID = myItem.personID
            myContactType = myItem.contactType
            myContactValue = myItem.contactValue
            myTeamID = myItem.teamID
            myProjectID = myItem.projectID
        }
    }
    
    public init(projectID: Int64, teamID: Int64)
    {
        super.init()
        
        var myItem: Contacts!
        
        for item in (currentUser.currentTeam?.contacts)!
        {
            if (item.projectID == projectID)
            {
                myItem = item
                break
            }
        }
        
        myProjectID = projectID
        
        if myItem != nil
        {
            myPersonID = myItem.personID
            myContactType = myItem.contactType
            myContactValue = myItem.contactValue
            myTeamID = myItem.teamID
            myClientID = myItem.clientID
        }
    }
    
    public init(personID: Int64,
                contactType: String,
                contactValue: String,
                teamID: Int64,
                clientID: Int64,
                projectID: Int64)
    {
        super.init()
        myPersonID = personID
        myContactType = contactType
        myContactValue = contactValue
        myTeamID = teamID
        myClientID = clientID
        myProjectID = projectID
    }
    
    public func save()
    {
        if currentUser.checkWritePermission(hrRoleType)
        {
            let temp = Contacts(clientID: myClientID, contactType: myContactType, contactValue: myContactValue, personID: myPersonID, projectID: myProjectID, teamID: myTeamID)
            
            myCloudDB.saveContactRecordToCloudKit(temp)
            
            currentUser.currentTeam?.contacts = nil
            //       currentUser.currentTeam?.contacts = nil
        }
    }
    
    public func delete()
    {
        if currentUser.checkWritePermission(hrRoleType)
        {
            if myPersonID != 0
            {
                myCloudDB.deleteContactForPerson(myPersonID, contactType: myContactType, teamID: myTeamID)
            }
            
            if myClientID != 0
            {
                myCloudDB.deleteContactForClient(myClientID, contactType: myContactType, teamID: myTeamID)
            }
            
            if myProjectID != 0
            {
                myCloudDB.deleteContactForProject(myProjectID, contactType: myContactType, teamID: myTeamID)
            }
        }
    }
}

//extension coreDatabase
//{
//    func saveContact(_ personID: Int,
//                     contactType: String,
//                     contactValue: String,
//                     teamID: Int,
//                     clientID: Int,
//                     projectID: Int,
//                     updateTime: Date =  Date(), updateType: String = "CODE")
//    {
//        var myItem: Contacts!
//        var myReturn: [Contacts]!
//
//        if personID != 0
//        {
//            myReturn = getContactDetailsForPerson(personID, contactType: contactType, teamID: teamID)
//        }
//        else if clientID != 0
//        {
//            myReturn = getContactDetailsForClient(clientID, contactType: contactType, teamID: teamID)
//        }
//        else if projectID != 0
//        {
//            myReturn = getContactDetailsForProject(projectID, contactType: contactType, teamID: teamID)
//        }
//
//        if myReturn.count == 0
//        { // Add
//            myItem = Contacts(context: objectContext)
//            myItem.personID = Int64(personID)
//            myItem.contactType = contactType
//            myItem.contactValue = contactValue
//            myItem.teamID = Int64(teamID)
//            myItem.clientID = Int64(clientID)
//            myItem.projectID = Int64(projectID)
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
//            myItem.contactValue = contactValue
//            myItem.clientID = Int64(clientID)
//            myItem.projectID = Int64(projectID)
//            myItem.personID = Int64(personID)
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

//
//    func resetAllContacts()
//    {
//        let fetchRequest = NSFetchRequest<Contacts>(entityName: "Contacts")
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
//            print("Error occurred during execution: \(error)")
//        }
//
//        saveContext()
//    }
//
//    func clearDeletedContacts(predicate: NSPredicate)
//    {
//        let fetchRequest2 = NSFetchRequest<Contacts>(entityName: "Contacts")
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
//            print("Error occurred during execution: \(error)")
//        }
//        saveContext()
//    }
//
//    func clearSyncedContacts(predicate: NSPredicate)
//    {
//        let fetchRequest2 = NSFetchRequest<Contacts>(entityName: "Contacts")
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
//            print("Error occurred during execution: \(error)")
//        }
//
//        saveContext()
//    }
//
//    func getContactsForSync(_ syncDate: Date) -> [Contacts]
//    {
//        let fetchRequest = NSFetchRequest<Contacts>(entityName: "Contacts")
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
//            print("Error occurred during execution: \(error)")
//            return []
//        }
//    }
//
//    func deleteAllContacts()
//    {
//        let fetchRequest2 = NSFetchRequest<Contacts>(entityName: "Contacts")
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
//            print("Error occurred during execution: \(error)")
//        }
//
//        saveContext()
//    }
//}
//

public struct Contacts {
    public var clientID: Int64
    public var contactType: String
    public var contactValue: String
    public var personID: Int64
    public var projectID: Int64
    public var teamID: Int64
}

extension CloudKitInteraction
{
    private func populateContacts(_ records: [CKRecord]) -> [Contacts]
    {
        var tempArray: [Contacts] = Array()
        
        for record in records
        {
            var personID: Int64 = 0
            if record.object(forKey: "personID") != nil
            {
                personID = record.object(forKey: "personID") as! Int64
            }
            
            var teamID: Int64 = 0
            if record.object(forKey: "teamID") != nil
            {
                teamID = record.object(forKey: "teamID") as! Int64
            }
            
            var clientID: Int64 = 0
            if record.object(forKey: "clientID") != nil
            {
                clientID = record.object(forKey: "clientID") as! Int64
            }
            
            var projectID: Int64 = 0
            if record.object(forKey: "projectID") != nil
            {
                projectID = record.object(forKey: "projectID") as! Int64
            }
            let tempItem = Contacts(clientID: clientID,
                                    contactType: record.object(forKey: "contactType") as! String,
                                    contactValue: record.object(forKey: "contactValue") as! String,
                                    personID: personID,
                                    projectID: projectID,
                                    teamID: teamID)
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getContactDetailsForPerson(_ personID: Int64, contactType: String, teamID: Int64)->[Contacts]
    {
        let predicate = NSPredicate(format: "(personID == \(personID)) AND (teamID == \(teamID)) AND (contactType == \"\(contactType)\") AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Contacts", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Contacts] = populateContacts(returnArray)
        
        return shiftArray
    }
    
    func getContactDetailsForPerson(_ personID: Int64, teamID: Int64)->[Contacts]
    {
        let predicate = NSPredicate(format: "(personID == \(personID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Contacts", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Contacts] = populateContacts(returnArray)
        
        return shiftArray
    }
    
    func getContacts(teamID: Int64)->[Contacts]
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Contacts", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Contacts] = populateContacts(returnArray)
        
        return shiftArray
    }
    
    func getContactDetailsForClient(_ clientID: Int64, contactType: String, teamID: Int64)->[Contacts]
    {
        let predicate = NSPredicate(format: "(clientID == \(clientID)) AND (teamID == \(teamID)) AND (contactType == \"\(contactType)\") AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Contacts", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Contacts] = populateContacts(returnArray)
        
        return shiftArray
    }
    
    func getContactDetailsForClient(_ clientID: Int64, teamID: Int64)->[Contacts]
    {
        let predicate = NSPredicate(format: "(clientID == \(clientID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Contacts", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Contacts] = populateContacts(returnArray)
        
        return shiftArray
    }
    
    func getContactDetailsForProject(_ projectID: Int64, contactType: String, teamID: Int64)->[Contacts]
    {
        let predicate = NSPredicate(format: "(projectID == \(projectID)) AND (teamID == \(teamID)) AND (contactType == \"\(contactType)\") AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Contacts", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Contacts] = populateContacts(returnArray)
        
        return shiftArray
    }
    
    func getContactDetailsForProject(_ projectID: Int64, teamID: Int64)->[Contacts]
    {
        let predicate = NSPredicate(format: "(projectID == \(projectID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Contacts", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Contacts] = populateContacts(returnArray)
        
        return shiftArray
    }
    
    func deleteContactForPerson(_ personID: Int64, contactType: String, teamID: Int64)
    {
        let predicate = NSPredicate(format: "(personID == \(personID)) AND (teamID == \(teamID)) AND (contactType == \"\(contactType)\") AND (updateType != \"Delete\")")
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "Contacts", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            self.performPublicDelete(records!)
            
            sem.signal()
        })
        sem.wait()
    }
    
    func deleteContactForClient(_ clientID: Int64, contactType: String, teamID: Int64)
    {
        let predicate = NSPredicate(format: "(clientID == \(clientID)) AND (teamID == \(teamID)) AND (contactType == \"\(contactType)\") AND (updateType != \"Delete\")")
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "Contacts", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            self.performPublicDelete(records!)
            
            sem.signal()
        })
        sem.wait()
    }
    
    func deleteContactForProject(_ projectID: Int64, contactType: String, teamID: Int64)
    {
        let predicate = NSPredicate(format: "(projectID == \(projectID)) AND (teamID == \(teamID)) AND (contactType == \"\(contactType)\")")
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "Contacts", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            self.performPublicDelete(records!)
            
            sem.signal()
        })
        sem.wait()
    }
    
    func saveContactRecordToCloudKit(_ sourceRecord: Contacts)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(personID == \(sourceRecord.personID)) AND (clientID == \(sourceRecord.clientID)) AND (projectID == \(sourceRecord.projectID)) AND (contactType == \"\(sourceRecord.contactType)\") AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Contacts", predicate: predicate)
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
                    
                    record!.setValue(sourceRecord.personID, forKey: "personID")
                    record!.setValue(sourceRecord.contactType, forKey: "contactType")
                    record!.setValue(sourceRecord.contactValue, forKey: "contactValue")
                    record!.setValue(sourceRecord.clientID, forKey: "clientID")
                    record!.setValue(sourceRecord.projectID, forKey: "projectID")
                    
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
                    let record = CKRecord(recordType: "Contacts")
                    record.setValue(sourceRecord.personID, forKey: "personID")
                    record.setValue(sourceRecord.contactType, forKey: "contactType")
                    record.setValue(sourceRecord.contactValue, forKey: "contactValue")
                    record.setValue(sourceRecord.clientID, forKey: "clientID")
                    record.setValue(sourceRecord.projectID, forKey: "projectID")
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
}
