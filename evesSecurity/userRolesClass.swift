//
//  userRolesClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 11/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

let readPermission = "Read"
let writePermission = "Write"
let noPermission = "None"

let adminRoleType = "Admin"
let rosteringRoleType = "Rostering"
let invoicingRoleType = "Invoicing"
let financialsRoleType = "Financials"
let hrRoleType = "HR"
let salesRoleType = "Sales"
let pmRoleType = "Project Manager"

class userRoles: NSObject
{
    fileprivate var myUserRoles:[userRoleItem] = Array()
    
    init(userID: Int, teamID: Int)
    {
        for myItem in myDatabaseConnection.getUserRoles(userID: userID, teamID: teamID)
        {
            let myObject = userRoleItem(userID: Int(myItem.userID),
                                    teamID: Int(myItem.teamID),
                                    roleType: myItem.roleType!,
                                    accessLevel: myItem.accessLevel!
                                   )
            myUserRoles.append(myObject)
        }
    }

    var userRole: [userRoleItem]
    {
        get
        {
            return myUserRoles
        }
    }
}

class userRoleItem: NSObject
{
    fileprivate var myUserID: Int = 0
    fileprivate var myTeamID: Int = 0
    fileprivate var myRoleType: String = ""
    fileprivate var myAccessLevel: String = "None"
    
    var teamID: Int
    {
        get
        {
            return myTeamID
        }
    }
    
    var userID: Int
    {
        get
        {
            return myUserID
        }
    }
    
    var roleType: String
    {
        get
        {
            return myRoleType
        }
    }
    
    var accessLevel: String
    {
        get
        {
            return myAccessLevel
        }
        set
        {
            myAccessLevel = newValue
            save()
        }
    }

    init(userID: Int, roleType: String, teamID: Int, saveToCloud: Bool)
    {
        super.init()
        
        myUserID = userID
        myRoleType = roleType
        myTeamID = teamID
        
        save()
    }
    
    init(userID: Int,
         teamID: Int,
         roleType: String,
         accessLevel: String
         )
    {
        super.init()
        
        myUserID = userID
        myRoleType = roleType
        myAccessLevel = accessLevel
        myTeamID = teamID
    }
    
    func save()
    {
        myDatabaseConnection.saveUserRoles(userID: myUserID,
                                           teamID: myTeamID,
                                           roleType: myRoleType,
                                           accessLevel: myAccessLevel
                                         )
    }
    
    func delete()
    {
        myDatabaseConnection.deleteUserRoles(userID: myUserID,
                                             teamID: myTeamID,
                                             roleType: myRoleType)
    }
}

extension coreDatabase
{
    func saveUserRoles(userID: Int,
                       teamID: Int,
                       roleType: String,
                       accessLevel: String,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: UserRoles!
        
        let myReturn = getUserRoles(userID: userID, teamID: teamID, roleType: roleType)
        
        if myReturn.count == 0
        { // Add
            myItem = UserRoles(context: objectContext)
            myItem.userID = Int64(userID)
            myItem.roleType = roleType
            myItem.accessLevel = accessLevel
            myItem.teamID = Int64(teamID)

            if updateType == "CODE"
            {
                myItem.updateTime =  Date()
                
                myItem.updateType = "Add"
            }
            else
            {
                myItem.updateTime = updateTime
                myItem.updateType = updateType
            }
        }
        else
        {
            myItem = myReturn[0]
            myItem.accessLevel = accessLevel
            
            if updateType == "CODE"
            {
                myItem.updateTime =  Date()
                if myItem.updateType != "Add"
                {
                    myItem.updateType = "Update"
                }
            }
            else
            {
                myItem.updateTime = updateTime
                myItem.updateType = updateType
            }
        }
        
        saveContext()

        self.recordsProcessed += 1
    }
    
    func deleteUserRoles(userID: Int,
                         teamID: Int,
                         roleType: String)
    {
        let myReturn = getUserRoles(userID: userID, teamID: teamID, roleType: roleType)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  Date()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getUserRoles(userID: Int, teamID: Int)->[UserRoles]
    {
        let fetchRequest = NSFetchRequest<UserRoles>(entityName: "UserRoles")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(userID == \(userID)) AND (teamID == \(teamID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func getUserRoles(userID: Int, teamID: Int, roleType: String)->[UserRoles]
    {
        let fetchRequest = NSFetchRequest<UserRoles>(entityName: "UserRoles")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(userID == \(userID)) AND (roleType == \"\(roleType)\") AND (teamID == \(teamID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func getUserRolesCount(teamID: Int )-> Int
    {
        let fetchRequest = NSFetchRequest<UserRoles>(entityName: "UserRoles")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(teamID == \(teamID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.count(for: fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return 0
        }
    }
    
    func resetAllUserRoles()
    {
        let fetchRequest = NSFetchRequest<UserRoles>(entityName: "UserRoles")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myItem in fetchResults
            {
                myItem.updateTime =  Date()
                myItem.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearDeletedUserRoles(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<UserRoles>(entityName: "UserRoles")
        
        // Set the predicate on the fetch request
        fetchRequest2.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myItem2 in fetchResults2
            {
                objectContext.delete(myItem2 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        saveContext()
    }
    
    func clearSyncedUserRoles(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<UserRoles>(entityName: "UserRoles")
        
        // Set the predicate on the fetch request
        fetchRequest2.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myItem2 in fetchResults2
            {
                myItem2.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getUserRolesForSync(_ syncDate: Date) -> [UserRoles]
    {
        let fetchRequest = NSFetchRequest<UserRoles>(entityName: "UserRoles")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", syncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func deleteAllUserRoles()
    {
        let fetchRequest2 = NSFetchRequest<UserRoles>(entityName: "UserRoles")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myItem2 in fetchResults2
            {
                self.objectContext.delete(myItem2 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func addPMRoleToAll()
    {
        let fetchRequest = NSFetchRequest<UserRoles>(entityName: "UserRoles")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(roleType == \"\(adminRoleType)\") AND (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            
            for myItem in fetchResults
            {
                saveUserRoles(userID: Int(myItem.userID), teamID: Int(myItem.teamID), roleType: pmRoleType, accessLevel: noPermission)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }
}

extension CloudKitInteraction
{
    func saveUserRolesToCloudKit()
    {
        for myItem in myDatabaseConnection.getUserRolesForSync(getSyncDateForTable(tableName: "UserRoles"))
        {
            saveUserRolesRecordToCloudKit(myItem)
        }
    }
    
    func updateUserRolesInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", getSyncDateForTable(tableName: "UserRoles") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "UserRoles", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            self.updateUserRolesRecord(record)
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "UserRoles", queryOperation: operation, onOperationQueue: operationQueue)
    }
    
//    func deleteUserRoles(roleID: Int)
//    {
//        let sem = DispatchSemaphore(value: 0);
//
//        var myRecordList: [CKRecordID] = Array()
//        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID)) AND (roleID == \(roleID))")
//        let query: CKQuery = CKQuery(recordType: "UserRoles", predicate: predicate)
//        publicDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
//            for record in results!
//            {
//                myRecordList.append(record.recordID)
//            }
//            self.performPublicDelete(myRecordList)
//            sem.signal()
//        })
//
//        sem.wait()
//    }
    
    func saveUserRolesRecordToCloudKit(_ sourceRecord: UserRoles)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(userID == \(sourceRecord.userID)) AND (roleType == \"\(sourceRecord.roleType!)\") AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "UserRoles", predicate: predicate)
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
                    
                    record!.setValue(sourceRecord.accessLevel, forKey: "accessLevel")
                    
                    if sourceRecord.updateTime != nil
                    {
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    // Save this record again
                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                            self.saveOK = false
                        }
                        else
                        {
                            if debugMessages
                            {
                                NSLog("Successfully updated record!")
                            }
                        }
                    })
                }
                else
                {  // Insert
                    let record = CKRecord(recordType: "UserRoles")
                    record.setValue(sourceRecord.userID, forKey: "userID")
                    record.setValue(sourceRecord.roleType, forKey: "roleType")
                    record.setValue(sourceRecord.accessLevel, forKey: "accessLevel")
                    
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                            self.saveOK = false
                        }
                        else
                        {
                            if debugMessages
                            {
                                NSLog("Successfully saved record!")
                            }
                        }
                    })
                }
            }
            sem.signal()
        })
        sem.wait()
    }

    func updateUserRolesRecord(_ sourceRecord: CKRecord)
    {
        var userID: Int = 0
        if sourceRecord.object(forKey: "userID") != nil
        {
            userID = sourceRecord.object(forKey: "userID") as! Int
        }
        
        var teamID: Int = 0
        if sourceRecord.object(forKey: "teamID") != nil
        {
            teamID = sourceRecord.object(forKey: "teamID") as! Int
        }
        
        let roleType = sourceRecord.object(forKey: "roleType") as! String
        
        let accessLevel = sourceRecord.object(forKey: "accessLevel") as! String
        
        var updateTime = Date()
        if sourceRecord.object(forKey: "updateTime") != nil
        {
            updateTime = sourceRecord.object(forKey: "updateTime") as! Date
        }
        
        var updateType: String = ""
        if sourceRecord.object(forKey: "updateType") != nil
        {
            updateType = sourceRecord.object(forKey: "updateType") as! String
        }
        
        myDatabaseConnection.recordsToChange += 1
        
        while self.recordCount > 0
        {
            usleep(self.sleepTime)
        }
        
        self.recordCount += 1
        
        myDatabaseConnection.saveUserRoles(userID: userID,
                                           teamID: teamID,
                                           roleType: roleType,
                                           accessLevel: accessLevel
                                         , updateTime: updateTime, updateType: updateType)
        self.recordCount -= 1
    }
}
