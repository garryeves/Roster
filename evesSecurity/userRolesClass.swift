//
//  userRolesClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 11/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
//import CoreData
import CloudKit
import SwiftUI

public let readPermission = "Read"
public let writePermission = "Write"
public let noPermission = "None"

public let adminRoleType = "Admin"
public let rosteringRoleType = "Rostering"
public let invoicingRoleType = "Invoicing"
public let financialsRoleType = "Financials"
public let hrRoleType = "HR"
public let salesRoleType = "Sales"
public let pmRoleType = "Project Manager"
public let coachingRoleType = "Coaching"
public let clientRoleType = "Client"

public class userRoles: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myUserRoles:[userRoleItem] = Array()
    
    public init(userID: Int64, teamID: Int64)
    {
        myUserRoles.removeAll()
        if currentUser != nil
        {
            currentUser.currentTeam?.userRoles = myCloudDB.getUserRoles(userID: userID, teamID: teamID)
            
            for myItem in (currentUser.currentTeam?.userRoles)!
            {
                let myObject = userRoleItem(userID: myItem.userID, teamID: myItem.teamID, roleType: myItem.roleType!, accessLevel: myItem.accessLevel!, roleID: myItem.roleID)
                
                myUserRoles.append(myObject)
            }
        }
        
        if myUserRoles.count > 0
        {
            myUserRoles.sort
                {
                    // Because workdate has time it throws everything out
                    
                    if $0.myRoleType == $1.myRoleType
                    {
                        return $0.myUserID < $1.myUserID
                    }
                    else
                    {
                        return $0.myRoleType < $1.myRoleType
                    }
            }
        }
    }
    
    public var userRole: [userRoleItem]
    {
        get
        {
            return myUserRoles
        }
    }
}

public class userRoleItem: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myUserID: Int64 = 0
    fileprivate var myTeamID: Int64 = 0
    fileprivate var myRoleID: Int64 = 0
    fileprivate var myRoleType: String = ""
    fileprivate var myAccessLevel: String = "None"
    
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
    
    public var roleID: Int64
    {
        get
        {
            return myRoleID
        }
    }
    
    public var roleType: String
    {
        get
        {
            return myRoleType
        }
    }
    
    public var accessLevel: String
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
    
    public init(userID: Int64, roleType: String, teamID: Int64, roleID: Int64)
    {
        super.init()
        
        myUserID = userID
        myRoleType = roleType
        myTeamID = teamID
        myRoleID = roleID
        
        currentUser.currentTeam?.userRoles = nil
    }
    
    public  init(userID: Int64,
                 teamID: Int64,
                 roleType: String,
                 accessLevel: String
        , roleID: Int64
        )
    {
        super.init()
        
        myUserID = userID
        myRoleType = roleType
        myAccessLevel = accessLevel
        myTeamID = teamID
        myRoleID = roleID
    }
    
    public func save()
    {
        let temp = UserRoles(accessLevel: myAccessLevel, roleID: myRoleID, roleType: myRoleType, teamID: myTeamID, userID: myUserID)
        
        myCloudDB.saveUserRolesRecordToCloudKit(temp)
    }
    
    public func delete()
    {
        myCloudDB.deleteUserRoles(userID: myUserID,
                                  teamID: myTeamID,
                                  roleType: myRoleType)
        currentUser.currentTeam?.userRoles = nil
    }
}

public struct UserRoles {
    public var accessLevel: String?
    public var roleID: Int64
    public var roleType: String?
    public var teamID: Int64
    public var userID: Int64
}

extension CloudKitInteraction
{
    private func populateUserRoles(_ records: [CKRecord]) -> [UserRoles]
    {
        var tempArray: [UserRoles] = Array()
        
        for record in records
        {
            var userID: Int64 = 0
            if record.object(forKey: "userID") != nil
            {
                userID = record.object(forKey: "userID") as! Int64
            }
            
            var teamID: Int64 = 0
            if record.object(forKey: "teamID") != nil
            {
                teamID = record.object(forKey: "teamID") as! Int64
            }
            
            var roleID: Int64 = 0
            if record.object(forKey: "roleID") != nil
            {
                roleID = record.object(forKey: "roleID") as! Int64
            }
            
            let tempItem = UserRoles(accessLevel: record.object(forKey: "accessLevel") as? String,
                                     roleID: roleID,
                                     roleType: record.object(forKey: "roleType") as? String,
                                     teamID: teamID,
                                     userID: userID)
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getUserRoles(userID: Int64, teamID: Int64)->[UserRoles]
    {
        let predicate = NSPredicate(format: "(userID == \(userID)) AND (teamID == \(teamID)) && (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "UserRoles", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [UserRoles] = populateUserRoles(returnArray)
        
        return shiftArray
    }
    
    func getUserRoles(userID: Int64, teamID: Int64, roleType: String)->[UserRoles]
    {
        let predicate = NSPredicate(format: "(userID == \(userID)) AND (roleType == \"\(roleType)\") AND (teamID == \(teamID)) && (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "UserRoles", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [UserRoles] = populateUserRoles(returnArray)
        
        return shiftArray
    }
    
    func getUserRolesCount(teamID: Int64) -> Int
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) && (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "UserRoles", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [UserRoles] = populateUserRoles(returnArray)
        
        return shiftArray.count
    }
    
    func deleteUserRoles(userID: Int64,
                         teamID: Int64,
                         roleType: String)
    {
        let predicate = NSPredicate(format: "(userID == \(userID)) AND (roleType == \"\(roleType)\") AND (teamID == \(teamID))")
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "UserRoles", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            self.performPublicDelete(records!)
            
            sem.signal()
        })
        sem.wait()
    }
    
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
                    let record = CKRecord(recordType: "UserRoles")
                    record.setValue(sourceRecord.userID, forKey: "userID")
                    record.setValue(sourceRecord.roleType, forKey: "roleType")
                    record.setValue(sourceRecord.accessLevel, forKey: "accessLevel")
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
