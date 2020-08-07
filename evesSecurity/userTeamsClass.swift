//
//  userTeamsClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 12/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
//import CoreData
import CloudKit
import SwiftUI

public class userTeams: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myUserTeams:[userTeamItem] = Array()
    
    public init(userID: Int64)
    {
        for myItem in myCloudDB.getTeamsForUser(userID: userID)
        {
            let myObject = userTeamItem(userID: myItem.userID, teamID: myItem.teamID)
            myUserTeams.append(myObject)
        }
    }
    
    public init(teamID: Int64)
    {
        for myItem in myCloudDB.getUsersForTeam(teamID: teamID)
        {
            let myObject = userTeamItem(userID: myItem.userID, teamID: myItem.teamID)
            myUserTeams.append(myObject)
        }
    }
    
    public var UserTeams: [userTeamItem]
    {
        get
        {
            return myUserTeams
        }
    }
}

public class userTeamItem: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myTeamID: Int64 = 0
    fileprivate var myUserID: Int64 = 0
    
    public var teamID: Int64
    {
        get
        {
            return myTeamID
        }
    }
    
    public var userID: Int64
    {
        get
        {
            return myUserID
        }
    }
    
    public init(userID: Int64,
                teamID: Int64
        )
    {
        super.init()
        
        myTeamID = teamID
        myUserID = userID
    }
    
    public func save()
    {
        let temp = UserTeams(teamID: myTeamID, userID: myUserID)
        myCloudDB.saveUserTeamsRecordToCloudKit(temp)
        currentUser.currentTeam?.userTeams = nil
    }
    
    public func delete()
    {
        myCloudDB.deleteUserTeam(myUserID, teamID: myTeamID)
        currentUser.currentTeam?.userTeams = nil
    }
}

//extension coreDatabase
//{
//    func saveUserTeam(_ userID: Int,
//                       teamID: Int,
//                     updateTime: Date =  Date(), updateType: String = "CODE")
//    {
//        var myItem: UserTeams!
//
//        let myReturn = getUserTeamsDetails(userID, teamID: teamID)
//
//        if myReturn.count == 0
//        { // Add
//            myItem = UserTeams(context: objectContext)
//            myItem.teamID = Int64(teamID)
//            myItem.userID = Int64(userID)
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
//
//        saveContext()
//    }
//
//    func replaceUserTeam(_ userID: Int,
//                          teamID: Int,
//                        updateTime: Date =  Date(), updateType: String = "CODE")
//    {
//        let myItem = UserTeams(context: objectContext)
//        myItem.teamID = Int64(teamID)
//        myItem.userID = Int64(userID)
//
//        if updateType == "CODE"
//        {
//            myItem.updateTime =  Date()
//            myItem.updateType = "Add"
//        }
//        else
//        {
//            myItem.updateTime = updateTime
//            myItem.updateType = updateType
//        }
//
//        saveContext()
//
//        self.recordsProcessed += 1
//    }
//

//

//

//
//    func getUserTeamsDetails(_ userID: Int, teamID: Int)->[UserTeams]
//    {
//        let fetchRequest = NSFetchRequest<UserTeams>(entityName: "UserTeams")
//
//        // Create a new predicate that filters out any object that
//        // doesn't have a title of "Best Language" exactly.
//        let predicate = NSPredicate(format: "(userID == \(userID)) AND (teamID == \(teamID)) && (updateType != \"Delete\")")
//
//        // Set the predicate on the fetch request
//        fetchRequest.predicate = predicate
//
//        // Execute the fetch request, and cast the results to an array of LogItem objects
//        do
//        {
//            let fetchResults = try objectContext.fetch(fetchRequest)
//            return fetchResults
//        }
//        catch
//        {
//            print("Error occurred during execution: \(error)")
//            return []
//        }
//    }
//
//    func resetAllUserTeams()
//    {
//        let fetchRequest = NSFetchRequest<UserTeams>(entityName: "UserTeams")
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
//    func clearDeletedUserTeams(predicate: NSPredicate)
//    {
//        let fetchRequest2 = NSFetchRequest<UserTeams>(entityName: "UserTeams")
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
//    func clearSyncedUserTeams(predicate: NSPredicate)
//    {
//        let fetchRequest2 = NSFetchRequest<UserTeams>(entityName: "UserTeams")
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
//    func getUserTeamsForSync(_ syncDate: Date) -> [UserTeams]
//    {
//        let fetchRequest = NSFetchRequest<UserTeams>(entityName: "UserTeams")
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
//    func deleteAllUserTeams()
//    {
//        let fetchRequest2 = NSFetchRequest<UserTeams>(entityName: "UserTeams")
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

public struct UserTeams {
    public var teamID: Int64
    public var userID: Int64
}

extension CloudKitInteraction
{
    func populateUserTeams(_ records: [CKRecord]) -> [UserTeams]
    {
        var tempArray: [UserTeams] = Array()
        
        for record in records
        {
            let tempItem = UserTeams(teamID: decodeInt64(record.object(forKey: "teamID")),
                                     userID: decodeInt64(record.object(forKey: "userID")))
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func deleteUserTeam(_ userID: Int64,
                        teamID: Int64)
    {
        let predicate = NSPredicate(format: "(userID == \(userID)) AND (teamID == \(teamID))")
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "UserTeams", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            self.performPublicDelete(records!)
            
            sem.signal()
        })
        sem.wait()
    }
    
    func getTeamsForUser(userID: Int64)->[UserTeams]
    {
        let predicate = NSPredicate(format: "(userID == \(userID)) && (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "UserTeams", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [UserTeams] = populateUserTeams(returnArray)
        
        return shiftArray
    }
    
    func getUsersForTeam(teamID: Int64)->[UserTeams]
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) && (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "UserTeams", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [UserTeams] = populateUserTeams(returnArray)
        
        return shiftArray
    }
    
    func getAllUsersTeamS()->[UserTeams]
    {
        let predicate = NSPredicate(format: "(updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "UserTeams", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [UserTeams] = populateUserTeams(returnArray)
        
        return shiftArray
    }
    
    
    
    func deleteUserTeams(userID: Int64)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID)) AND (userID == \(userID))")
        let query: CKQuery = CKQuery(recordType: "UserTeams", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            self.performPublicDelete(results!)
            sem.signal()
        })
        
        sem.wait()
    }
    
    func saveUserTeamsRecordToCloudKit(_ sourceRecord: UserTeams)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(userID == \(sourceRecord.userID)) AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "UserTeams", predicate: predicate)
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
                    // Do nothing
                }
                else
                {  // Insert
                    let record = CKRecord(recordType: "UserTeams")
                    record.setValue(sourceRecord.userID, forKey: "userID")
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

