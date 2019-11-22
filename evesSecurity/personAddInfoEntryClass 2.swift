//
//  personAddInfoEntryClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 10/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
//import CoreData
import CloudKit
import SwiftUI

public class personAddInfoEntries: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myPersonAddEntries:[personAddInfoEntry] = Array()
    
    public init(personID: Int64, teamID: Int64)
    {
        if currentUser.currentTeam?.personAddInfoEntry == nil
        {
            currentUser.currentTeam?.personAddInfoEntry = myCloudDB.getPersonAddInfoEntries(teamID: teamID)
        }
        
        var workingArray: [PersonAddInfoEntry] = Array()
        
        for item in (currentUser.currentTeam?.personAddInfoEntry)!
        {
            if item.personID == personID
            {
                workingArray.append(item)
            }
        }
        
        for myItem in workingArray
        {
            let myObject = personAddInfoEntry(addInfoName: myItem.addInfoName!,
                                              dateValue: myItem.dateValue! as Date,
                                              personID: myItem.personID,
                                              stringValue: myItem.stringValue!,
                                              teamID: myItem.teamID
                                   )
            myPersonAddEntries.append(myObject)
        }
    }
    
    public init(addInfoName: String, teamID: Int64)
    {
        if currentUser.currentTeam?.personAddInfoEntry == nil
        {
            currentUser.currentTeam?.personAddInfoEntry = myCloudDB.getPersonAddInfoEntries(teamID: teamID)
        }
        
        var workingArray: [PersonAddInfoEntry] = Array()
        
        for item in (currentUser.currentTeam?.personAddInfoEntry)!
        {
            if item.addInfoName == addInfoName
            {
                workingArray.append(item)
            }
        }
        
        for myItem in myCloudDB.getPersonAddInfoEntryList(addInfoName, teamID: teamID)
        {
            let myObject = personAddInfoEntry(addInfoName: myItem.addInfoName!,
                                              dateValue: myItem.dateValue! as Date,
                                              personID: myItem.personID,
                                              stringValue: myItem.stringValue!,
                                              teamID: myItem.teamID
            )
            myPersonAddEntries.append(myObject)
        }
    }
    
    public init(addInfoName: String, searchString: String, teamID: Int64)
    {
        if currentUser.currentTeam?.personAddInfoEntry == nil
        {
            currentUser.currentTeam?.personAddInfoEntry = myCloudDB.getPersonAddInfoEntries(teamID: teamID)
        }
        
        var workingArray: [PersonAddInfoEntry] = Array()
        
        for item in (currentUser.currentTeam?.personAddInfoEntry)!
        {
            if (item.addInfoName) == addInfoName && (searchString == "")
            {
                workingArray.append(item)
            }
        }
        
        for myItem in workingArray
        {
            let myObject = personAddInfoEntry(addInfoName: myItem.addInfoName!,
                                              dateValue: myItem.dateValue! as Date,
                                              personID: myItem.personID,
                                              stringValue: myItem.stringValue!,
                                              teamID: myItem.teamID
            )
            myPersonAddEntries.append(myObject)
        }
    }
    
    public var personAddEntries: [personAddInfoEntry]
    {
        get
        {
            return myPersonAddEntries
        }
    }
}

public class personAddInfoEntry: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myAddInfoName: String = ""
    fileprivate var myDateValue: Date = getDefaultDate()
    fileprivate var myPersonID: Int64 = 0
    fileprivate var myStringValue: String = ""
    fileprivate var myTeamID: Int64 = 0
    
    public var addInfoName: String
    {
        get
        {
            return myAddInfoName
        }
    }
    
    public var personID: Int64
    {
        get
        {
            return myPersonID
        }
    }
    
    public var dateValue: Date
    {
        get
        {
            return myDateValue
        }
        set
        {
            myDateValue = newValue
        }
    }
    
    public var dateString: String
    {
        get
        {
            if myDateValue == getDefaultDate()
            {
               return "Select"
            }
            else
            {
                let myDateFormatter = DateFormatter()
                myDateFormatter.dateStyle = .short
                return myDateFormatter.string(from: myDateValue)
            }
        }
    }
    
    public var stringValue: String
    {
        get
        {
            return myStringValue
        }
        set
        {
            myStringValue = newValue
        }
    }
    
    public init(addInfoName: String, personID: Int64, teamID: Int64)
    {
        super.init()
        
        if currentUser.currentTeam?.personAddInfoEntry == nil
        {
            currentUser.currentTeam?.personAddInfoEntry = myCloudDB.getPersonAddInfoEntries(teamID: teamID)
        }
        
        var myItem: PersonAddInfoEntry!
        
        for item in (currentUser.currentTeam?.personAddInfoEntry)!
        {
            if (item.addInfoName == addInfoName) && (item.personID == personID)
            {
                myItem = item
                break
            }
        }
        
        myTeamID = teamID
        myPersonID = personID
        myAddInfoName = addInfoName
        
        if myItem != nil
        {
            myAddInfoName = myItem.addInfoName!
            myDateValue = myItem.dateValue! as Date
            myPersonID = myItem.personID
            myStringValue = myItem.stringValue!
            myTeamID = myItem.teamID
        }
    }
    
    public init(addInfoName: String,
         dateValue: Date,
         personID: Int64,
         stringValue: String,
         teamID: Int64
         )
    {
        super.init()
        
        myAddInfoName = addInfoName
        myDateValue = dateValue
        myPersonID = personID
        myStringValue = stringValue
        myTeamID = teamID
    }
    
    public func save()
    {
        if currentUser.checkWritePermission(hrRoleType)
        {
            let temp = PersonAddInfoEntry(addInfoName: myAddInfoName, dateValue: myDateValue, personID: myPersonID, stringValue: myStringValue, teamID: myTeamID)
            
            myCloudDB.savePersonAddInfoEntryRecordToCloudKit(temp)
        }
    }
    
    public func delete()
    {
        if currentUser.checkWritePermission(hrRoleType)
        {
            myCloudDB.deletePersonAddInfoEntry(addInfoName,
                                                      personID: personID, teamID: myTeamID)
        }
    }
}

//extension coreDatabase
//{
//    func savePersonAddInfoEntry(_ addInfoName: String,
//                                dateValue: Date,
//                                personID: Int,
//                                stringValue: String,
//                                teamID: Int,
//                     updateTime: Date =  Date(), updateType: String = "CODE")
//    {
//        var myItem: PersonAddInfoEntry!
//        
//        let myReturn = getPersonAddInfoEntryDetails(addInfoName, personID: personID, teamID: teamID)
//        
//        if myReturn.count == 0
//        { // Add
//            myItem = PersonAddInfoEntry(context: objectContext)
//            myItem.addInfoName = addInfoName
//            myItem.dateValue = dateValue
//            myItem.personID = Int64(personID)
//            myItem.stringValue = stringValue
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
//            myItem.dateValue = dateValue
//            myItem.stringValue = stringValue
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

//    func resetAllPersonAddInfoEntries()
//    {
//        let fetchRequest = NSFetchRequest<PersonAddInfoEntry>(entityName: "PersonAddInfoEntry")
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
//    func clearDeletedPersonAddInfoEntries(predicate: NSPredicate)
//    {
//        let fetchRequest2 = NSFetchRequest<PersonAddInfoEntry>(entityName: "PersonAddInfoEntry")
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
//    func clearSyncedPersonAddInfoEntries(predicate: NSPredicate)
//    {
//        let fetchRequest2 = NSFetchRequest<PersonAddInfoEntry>(entityName: "PersonAddInfoEntry")
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
//    func getPersonAddInfoEntriesForSync(_ syncDate: Date) -> [PersonAddInfoEntry]
//    {
//        let fetchRequest = NSFetchRequest<PersonAddInfoEntry>(entityName: "PersonAddInfoEntry")
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
//    func deleteAllPersonAddInfoEntries()
//    {
//        let fetchRequest2 = NSFetchRequest<PersonAddInfoEntry>(entityName: "PersonAddInfoEntry")
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

public struct PersonAddInfoEntry {
    public var addInfoName: String?
    public var dateValue: Date?
    public var personID: Int64
    public var stringValue: String?
    public var teamID: Int64
}

extension CloudKitInteraction
{
    private func populatePersonAddInfoEntry(_ records: [CKRecord]) -> [PersonAddInfoEntry]
    {
        var tempArray: [PersonAddInfoEntry] = Array()
        
        for record in records
        {
            var personID: Int64 = 0
            if record.object(forKey: "personID") != nil
            {
                personID = record.object(forKey: "personID") as! Int64
            }
            
            var dateValue = Date()
            if record.object(forKey: "dateValue") != nil
            {
                dateValue = record.object(forKey: "dateValue") as! Date
            }
            
            var teamID: Int64 = 0
            if record.object(forKey: "teamID") != nil
            {
                teamID = record.object(forKey: "teamID") as! Int64
            }
            
            let tempItem = PersonAddInfoEntry(addInfoName: record.object(forKey: "addInfoName") as? String,
                                              dateValue: dateValue,
                                              personID: personID,
                                              stringValue: record.object(forKey: "stringValue") as? String,
                                              teamID: teamID)
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getPersonAddInfoEntryForPerson(_ personID: Int64, teamID: Int64)->[PersonAddInfoEntry]
    {
        let predicate = NSPredicate(format: "(personID == \(personID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")

        let query = CKQuery(recordType: "PersonAddInfoEntry", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [PersonAddInfoEntry] = populatePersonAddInfoEntry(returnArray)
        
        return shiftArray
    }
    
    func getPersonAddInfoEntries(teamID: Int64)->[PersonAddInfoEntry]
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\")")
  
        let query = CKQuery(recordType: "PersonAddInfoEntry", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [PersonAddInfoEntry] = populatePersonAddInfoEntry(returnArray)
        
        return shiftArray
    }
    
    func getPersonAddInfoEntryDetails(_ addInfoName: String, personID: Int64, teamID: Int64)->[PersonAddInfoEntry]
    {
        let predicate = NSPredicate(format: "(personID == \(personID)) AND (teamID == \(teamID)) AND (addInfoName == \"\(addInfoName)\") AND (updateType != \"Delete\")")

        let query = CKQuery(recordType: "PersonAddInfoEntry", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [PersonAddInfoEntry] = populatePersonAddInfoEntry(returnArray)
        
        return shiftArray
    }

    func getPersonAddInfoEntryList(_ addInfoName: String, teamID: Int64, searchString: String = "")->[PersonAddInfoEntry]
    {
        var predicate: NSPredicate!

        if searchString == ""
        {
            predicate = NSPredicate(format: "(addInfoName == \"\(addInfoName)\") AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        }
        else
        {
            predicate = NSPredicate(format: "(addInfoName == \"\(addInfoName)\") AND (stringValue == \"\(searchString)\") AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        }

        let query = CKQuery(recordType: "PersonAddInfoEntry", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [PersonAddInfoEntry] = populatePersonAddInfoEntry(returnArray)
        
        return shiftArray
    }

    func deletePersonAddInfoEntry(_ addInfoName: String,
                                  personID: Int64, teamID: Int64)
    {
        let predicate = NSPredicate(format: "(personID == \(personID)) AND (teamID == \(teamID)) AND (addInfoName == \"\(addInfoName)\")")

        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "PersonAddInfoEntry", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            self.performPublicDelete(records!)
            
            sem.signal()
        })
        sem.wait()
    }
    
    func savePersonAddInfoEntryRecordToCloudKit(_ sourceRecord: PersonAddInfoEntry)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(addInfoName == \"\(sourceRecord.addInfoName!)\") AND (personID == \(sourceRecord.personID)) AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "PersonAddInfoEntry", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records:  GRE D - \(error!.localizedDescription)")
            }
            else
            {
                // Lets go and get the additional details from the context1_1 table
                
                if records!.count > 0
                {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want

                    record!.setValue(sourceRecord.addInfoName, forKey: "addInfoName")
                    record!.setValue(sourceRecord.stringValue, forKey: "stringValue")
                    record!.setValue(sourceRecord.personID, forKey: "personID")
                    record!.setValue(sourceRecord.dateValue, forKey: "dateValue")
                    
                    // Save this record again
                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record:  GRE E - \(saveError!.localizedDescription)")
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
                    let record = CKRecord(recordType: "PersonAddInfoEntry")
                    record.setValue(sourceRecord.addInfoName, forKey: "addInfoName")
                    record.setValue(sourceRecord.stringValue, forKey: "stringValue")
                    record.setValue(sourceRecord.personID, forKey: "personID")
                    record.setValue(sourceRecord.dateValue, forKey: "dateValue")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    
                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record:  GRE F - \(saveError!.localizedDescription)")
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

