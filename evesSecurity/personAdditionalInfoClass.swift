//
//  personAdditionalInfoClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 10/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
//import CoreData
import CloudKit
import SwiftUI

public class personAdditionalInfos: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myAdditional:[personAdditionalInfo] = Array()
    
    public init(teamID: Int64)
    {
        if currentUser.currentTeam?.personAdditionalInfo == nil
        {
            currentUser.currentTeam?.personAdditionalInfo = myCloudDB.getPersonAdditionalInfo(teamID: teamID)
        }
        
        for myItem in (currentUser.currentTeam?.personAdditionalInfo)!
        {
            let myObject = personAdditionalInfo(addInfoID: myItem.addInfoID,
                                                addInfoName: myItem.addInfoName!,
                                                addInfoType: myItem.addInfoType!,
                                                teamID: myItem.teamID
            )
            myAdditional.append(myObject)
        }
    }
    
    public var personAdditionalInfos: [personAdditionalInfo]
    {
        get
        {
            return myAdditional
        }
    }
}

public class personAdditionalInfo: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myAddInfoID: Int64 = 0
    fileprivate var myAddInfoName: String = ""
    fileprivate var myAddInfoType: String = ""
    fileprivate var myTeamID: Int64 = 0
    
    public var addInfoID: Int64
    {
        get
        {
            return myAddInfoID
        }
    }
    
    public var addInfoName: String
    {
        get
        {
            return myAddInfoName
        }
        set
        {
            myAddInfoName = newValue
        }
    }
    
    public var addInfoType: String
    {
        get
        {
            return myAddInfoType
        }
        set
        {
            myAddInfoType = newValue
        }
    }
    
    override public init() {}
    
    public init(teamID: Int64)
    {
        super.init()
        
        myAddInfoID = myCloudDB.getNextID("personAdditionalInfo", teamID: teamID)
        myTeamID = teamID
        
        currentUser.currentTeam?.personAdditionalInfo = nil
   //     save()
    }
    
    public init(addInfoID: Int64, teamID: Int64)
    {
        super.init()
        
        if currentUser.currentTeam?.personAdditionalInfo == nil
        {
            currentUser.currentTeam?.personAdditionalInfo = myCloudDB.getPersonAdditionalInfo(teamID: teamID)
        }
        
        var myItem: PersonAdditionalInfo!
        
        for item in (currentUser.currentTeam?.personAdditionalInfo)!
        {
            if item.addInfoID == addInfoID
            {
                myItem = item
                break
            }
        }
        
        if myItem != nil
        {
            myAddInfoID = myItem.addInfoID
            myAddInfoName = myItem.addInfoName!
            myAddInfoType = myItem.addInfoType!
            myTeamID = myItem.teamID
        }
    }
    
    public init(addInfoID: Int64,
                addInfoName: String,
                addInfoType: String,
                teamID: Int64
        )
    {
        super.init()
        
        myAddInfoID = addInfoID
        myAddInfoName = addInfoName
        myAddInfoType = addInfoType
        myTeamID = teamID
    }
    
    public func save()
    {
        if currentUser.checkWritePermission(adminRoleType)
        {
            let temp = PersonAdditionalInfo(addInfoID: myAddInfoID, addInfoName: myAddInfoName, addInfoType: myAddInfoType, teamID: myTeamID)
            
            myCloudDB.savePersonAdditionalInfoRecordToCloudKit(temp)
        }
    }
    
    public func delete()
    {
        if currentUser.checkWritePermission(adminRoleType)
        {
            myCloudDB.deletePersonAdditionalInfo(myAddInfoID, teamID: myTeamID)
            currentUser.currentTeam?.personAdditionalInfo = nil
        }
    }
}

//extension coreDatabase
//{
//    func savePersonAdditionalInfo(_ addInfoID: Int,
//                     addInfoName: String,
//                     addInfoType: String,
//                     teamID: Int,
//                     updateTime: Date =  Date(), updateType: String = "CODE")
//    {
//        var myItem: PersonAdditionalInfo!
//
//        let myReturn = getPersonAdditionalInfoDetails(addInfoID, teamID: teamID)
//
//        if myReturn.count == 0
//        { // Add
//            myItem = PersonAdditionalInfo(context: objectContext)
//            myItem.addInfoID = Int64(addInfoID)
//            myItem.addInfoName = addInfoName
//            myItem.addInfoType = addInfoType
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
//            myItem.addInfoName = addInfoName
//            myItem.addInfoType = addInfoType
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
//    func resetAllPersonAdditionalInfoDetails()
//    {
//        let fetchRequest = NSFetchRequest<PersonAdditionalInfo>(entityName: "PersonAdditionalInfo")
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
//    func clearDeletedPersonAdditionalInfo(predicate: NSPredicate)
//    {
//        let fetchRequest2 = NSFetchRequest<PersonAdditionalInfo>(entityName: "PersonAdditionalInfo")
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
//    func clearSyncedPersonAdditionalInfo(predicate: NSPredicate)
//    {
//        let fetchRequest2 = NSFetchRequest<PersonAdditionalInfo>(entityName: "PersonAdditionalInfo")
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
//    func getPersonAdditionalInfoForSync(_ syncDate: Date) -> [PersonAdditionalInfo]
//    {
//        let fetchRequest = NSFetchRequest<PersonAdditionalInfo>(entityName: "PersonAdditionalInfo")
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
//    func deleteAllPersonAdditionalInfo()
//    {
//        let fetchRequest2 = NSFetchRequest<PersonAdditionalInfo>(entityName: "PersonAdditionalInfo")
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

public struct PersonAdditionalInfo {
    public var addInfoID: Int64
    public var addInfoName: String?
    public var addInfoType: String?
    public var teamID: Int64
}

extension CloudKitInteraction
{
    private func populatePersonAdditionalInfo(_ records: [CKRecord]) -> [PersonAdditionalInfo]
    {
        var tempArray: [PersonAdditionalInfo] = Array()
        
        for record in records
        {
            var addInfoID: Int64 = 0
            if record.object(forKey: "addInfoID") != nil
            {
                addInfoID = record.object(forKey: "addInfoID") as! Int64
            }
            
            var teamID: Int64 = 0
            if record.object(forKey: "teamID") != nil
            {
                teamID = record.object(forKey: "teamID") as! Int64
            }
            
            let tempItem = PersonAdditionalInfo(addInfoID: addInfoID,
                                                addInfoName: record.object(forKey: "addInfoName") as? String,
                                                addInfoType: record.object(forKey: "addInfoType") as? String,
                                                teamID: teamID)
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getPersonAdditionalInfo(teamID: Int64)->[PersonAdditionalInfo]
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "PersonAdditionalInfo", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [PersonAdditionalInfo] = populatePersonAdditionalInfo(returnArray)
        
        return shiftArray
    }
    
    func getPersonAdditionalInfoDetails(_ addInfoID: Int64, teamID: Int64)->[PersonAdditionalInfo]
    {
        let predicate = NSPredicate(format: "(addInfoID == \(addInfoID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "PersonAdditionalInfo", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [PersonAdditionalInfo] = populatePersonAdditionalInfo(returnArray)
        
        return shiftArray
    }
    
    func deletePersonAdditionalInfo(_ addInfoID: Int64, teamID: Int64)
    {
        let predicate = NSPredicate(format: "(addInfoID == \(addInfoID)) AND (teamID == \(teamID))")
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "PersonAdditionalInfo", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            self.performPublicDelete(records!)
            
            sem.signal()
        })
        sem.wait()
    }
    
    func savePersonAdditionalInfoRecordToCloudKit(_ sourceRecord: PersonAdditionalInfo)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(addInfoID == \(sourceRecord.addInfoID)) AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "PersonAdditionalInfo", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: GRE A - \(error!.localizedDescription)")
            }
            else
            {
                // Lets go and get the additional details from the context1_1 table
                
                if records!.count > 0
                {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    
            //        record!.setValue(sourceRecord.addInfoID, forKey: "addInfoID")
                    record!.setValue(sourceRecord.addInfoName, forKey: "addInfoName")
                    record!.setValue(sourceRecord.addInfoType, forKey: "addInfoType")
                    
                    // Save this record again
                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record:  GRE B - \(saveError!.localizedDescription)")
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
                    let record = CKRecord(recordType: "PersonAdditionalInfo")
                    record.setValue(sourceRecord.addInfoID, forKey: "addInfoID")
                    record.setValue(sourceRecord.addInfoName, forKey: "addInfoName")
                    record.setValue(sourceRecord.addInfoType, forKey: "addInfoType")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    
                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record:  GRE C - \(saveError!.localizedDescription)")
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
