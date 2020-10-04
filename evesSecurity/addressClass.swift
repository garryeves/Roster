//
//  addressClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 10/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
//import CoreData
import CloudKit
import SwiftUI

public class personAddresses: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myAddresses:[address] = Array()
    
    public init(personID: Int64, teamID: Int64)
    {
        if currentUser.currentTeam?.addresses == nil
        {
            currentUser.currentTeam?.addresses = myCloudDB.getAddresses(teamID: teamID)
        }
        
        var workingArray: [Addresses] = Array()
        
        for item in (currentUser.currentTeam?.addresses)!
        {
            if (item.personID == personID)
            {
                workingArray.append(item)
            }
        }
        
        for myItem in workingArray
        {
            let myContext = address(addressID: myItem.addressID,
                                    addressLine1: myItem.addressLine1,
                                    addressLine2: myItem.addressLine2,
                                    city: myItem.city,
                                    clientID: myItem.clientID,
                                    country: myItem.country,
                                    personID: myItem.personID,
                                    postcode: myItem.postcode,
                                    projectID: myItem.projectID,
                                    state: myItem.state,
                                    addressType: myItem.addressType,
                                    teamID: myItem.teamID)
            myAddresses.append(myContext)
        }
    }
    
    public init(clientID: Int64, teamID: Int64)
    {
        if currentUser.currentTeam?.addresses == nil
        {
            currentUser.currentTeam?.addresses = myCloudDB.getAddresses(teamID: teamID)
        }
        
        var workingArray: [Addresses] = Array()
        
        for item in (currentUser.currentTeam?.addresses)!
        {
            if (item.clientID == clientID)
            {
                workingArray.append(item)
            }
        }
        
        for myItem in workingArray
        {
            let myContext = address(addressID: myItem.addressID,
                                    addressLine1: myItem.addressLine1,
                                    addressLine2: myItem.addressLine2,
                                    city: myItem.city,
                                    clientID: myItem.clientID,
                                    country: myItem.country,
                                    personID: myItem.personID,
                                    postcode: myItem.postcode,
                                    projectID: myItem.projectID,
                                    state: myItem.state,
                                    addressType: myItem.addressType,
                                    teamID: myItem.teamID)
            
            myAddresses.append(myContext)
        }
    }
    
    public init(projectID: Int64, teamID: Int64)
    {
        if currentUser.currentTeam?.addresses == nil
        {
            currentUser.currentTeam?.addresses = myCloudDB.getAddresses(teamID: teamID)
        }
        
        var workingArray: [Addresses] = Array()
        
        for item in (currentUser.currentTeam?.addresses)!
        {
            if (item.projectID == projectID)
            {
                workingArray.append(item)
            }
        }
        
        for myItem in workingArray
        {
            let myContext = address(addressID: myItem.addressID,
                                    addressLine1: myItem.addressLine1,
                                    addressLine2: myItem.addressLine2,
                                    city: myItem.city,
                                    clientID: myItem.clientID,
                                    country: myItem.country,
                                    personID: myItem.personID,
                                    postcode: myItem.postcode,
                                    projectID: myItem.projectID,
                                    state: myItem.state,
                                    addressType: myItem.addressType,
                                    teamID: myItem.teamID)
            myAddresses.append(myContext)
        }
    }
    
    public var addresses: [address]
    {
        get
        {
            return myAddresses
        }
    }
}

public class address: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myAddressID: Int64 = 0
    fileprivate var myAddressLine1: String = ""
    fileprivate var myAddressLine2: String = ""
    fileprivate var myCity: String = ""
    fileprivate var myClientID: Int64 = 0
    fileprivate var myCountry: String = ""
    fileprivate var myPersonID: Int64 = 0
    fileprivate var myPostcode: String = ""
    fileprivate var myProjectID: Int64 = 0
    fileprivate var myState: String = ""
    fileprivate var myAddressType: String = ""
    fileprivate var myTeamID: Int64 = 0
    
    public var addressID: Int64
    {
        get
        {
            return myAddressID
        }
    }
    
    public var addressLine1: String
    {
        get
        {
            return myAddressLine1
        }
        set
        {
            myAddressLine1 = newValue
        }
    }
    
    public var addressLine2: String
    {
        get
        {
            return myAddressLine2
        }
        set
        {
            myAddressLine2 = newValue
        }
    }
    
    public var city: String
    {
        get
        {
            return myCity
        }
        set
        {
            myCity = newValue
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
    
    public var country: String
    {
        get
        {
            return myCountry
        }
        set
        {
            myCountry = newValue
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
    
    public var postcode: String
    {
        get
        {
            return myPostcode
        }
        set
        {
            myPostcode = newValue
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
    
    public var state: String
    {
        get
        {
            return myState
        }
        set
        {
            myState = newValue
        }
    }
    
    public var addressType: String
    {
        get
        {
            return myAddressType
        }
        set
        {
            myAddressType = newValue
        }
    }
    
    override public init()
    {
        super.init()
    }
    
    public init(teamID: Int64, addressType: String, personID: Int64)
    {
        super.init()
        
//        myAddressID = myCloudDB.getNextID("Address", teamID: teamID)
        myAddressID = myCloudDB.dateAsInt()
        myTeamID = teamID
        myAddressType = addressType
        myPersonID = personID
        
        save()
        
        currentUser.currentTeam?.addresses = nil
    }
    
    public init(addressID: Int64, teamID: Int64)
    {
        super.init()
        
        if currentUser.currentTeam?.addresses == nil
        {
            currentUser.currentTeam?.addresses = myCloudDB.getAddresses(teamID: teamID)
        }
        
        var myItem: Addresses!
        
        for item in (currentUser.currentTeam?.addresses)!
        {
            if (item.addressID == addressID)
            {
                myItem = item
                break
            }
        }
        
        if myItem != nil
        {
            myAddressID = myItem.addressID
            myAddressLine1 = myItem.addressLine1
            myAddressLine2 = myItem.addressLine2
            myCity = myItem.city
            myClientID = myItem.clientID
            myCountry = myItem.country
            myPersonID = myItem.personID
            myPostcode = myItem.postcode
            myProjectID = myItem.projectID
            myState = myItem.state
            myAddressType = myItem.addressType
            myTeamID = myItem.teamID
        }
    }
    
    public init(addressID: Int64,
                addressLine1: String,
                addressLine2: String,
                city: String,
                clientID: Int64,
                country: String,
                personID: Int64,
                postcode: String,
                projectID: Int64,
                state: String,
                addressType: String,
                teamID: Int64)
    {
        super.init()
        
        myAddressID = addressID
        myAddressLine1 = addressLine1
        myAddressLine2 = addressLine2
        myCity = city
        myClientID = clientID
        myCountry = country
        myPersonID = personID
        myPostcode = postcode
        myProjectID = projectID
        myState = state
        myAddressType = addressType
        myTeamID = teamID
    }
    
    public func save()
    {
        if currentUser.checkWritePermission(hrRoleType)
        {
            let temp = Addresses(addressID: myAddressID, addressLine1: myAddressLine1, addressLine2: myAddressLine2, addressType: myAddressType, city: myCity, clientID: myClientID, country: myCountry, personID: myPersonID, postcode: myPostcode, projectID: myProjectID, state: myState, teamID: myTeamID)
            
            myCloudDB.saveAddressRecordToCloudKit(temp)
            
            currentUser.currentTeam?.addresses = nil
            
            //      currentUser.currentTeam?.addresses = myCloudDB.getAddresses(teamID: (currentUser.currentTeam?.teamID)!)
        }
    }
    
    public func delete()
    {
        if currentUser.checkWritePermission(hrRoleType)
        {
            myCloudDB.deleteAddress(myAddressID, teamID: myTeamID)
            currentUser.currentTeam?.addresses = nil
        }
    }
}

//extension coreDatabase
//{
//    func saveAddress(_ addressID: Int,
//                     addressLine1: String,
//                     addressLine2: String,
//                     city: String,
//                     clientID: Int,
//                     country: String,
//                     personID: Int,
//                     postcode: String,
//                     projectID: Int,
//                     state: String,
//                     addressType: String,
//                     teamID: Int,
//                     updateTime: Date =  Date(), updateType: String = "CODE")
//    {
//        var myItem: Addresses!
//
//        let myReturn = getAddressDetails(addressID, teamID: teamID)
//
//        if myReturn.count == 0
//        { // Add
//            myItem = Addresses(context: objectContext)
//            myItem.addressID = Int64(addressID)
//            myItem.addressLine1 = addressLine1
//            myItem.addressLine2 = addressLine2
//            myItem.city = city
//            myItem.clientID = Int64(clientID)
//            myItem.country = country
//            myItem.personID = Int64(personID)
//            myItem.postcode = postcode
//            myItem.projectID = Int64(projectID)
//            myItem.state = state
//            myItem.addressType = addressType
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
//            myItem.addressLine1 = addressLine1
//            myItem.addressLine2 = addressLine2
//            myItem.city = city
//            myItem.clientID = Int64(clientID)
//            myItem.country = country
//            myItem.personID = Int64(personID)
//            myItem.postcode = postcode
//            myItem.projectID = Int64(projectID)
//            myItem.state = state
//            myItem.addressType = addressType
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


//    func resetAllAddresses()
//    {
//        let fetchRequest = NSFetchRequest<Addresses>(entityName: "Addresses")
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
//    func clearDeletedAddresses(predicate: NSPredicate)
//    {
//        let fetchRequest2 = NSFetchRequest<Addresses>(entityName: "Addresses")
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
//    func clearSyncedAddresses(predicate: NSPredicate)
//    {
//        let fetchRequest2 = NSFetchRequest<Addresses>(entityName: "Addresses")
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
//    func getAddressesForSync(_ syncDate: Date) -> [Addresses]
//    {
//        let fetchRequest = NSFetchRequest<Addresses>(entityName: "Addresses")
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
//            return returnArray
//        }
//    }
//
//    func deleteAllAddresses()
//    {
//        let fetchRequest2 = NSFetchRequest<Addresses>(entityName: "Addresses")
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

public struct Addresses {
    public var addressID: Int64
    public var addressLine1: String
    public var addressLine2: String
    public var addressType: String
    public var city: String
    public var clientID: Int64
    public var country: String
    public var personID: Int64
    public var postcode: String
    public var projectID: Int64
    public var state: String
    public var teamID: Int64
}

extension CloudKitInteraction
{
    private func populateAddresses(_ records: [CKRecord]) -> [Addresses]
    {
        var tempArray: [Addresses] = Array()
        
        for record in records
        {
            let tempItem = Addresses(addressID: decodeInt64(record.object(forKey: "addressID")),
                                     addressLine1: decodeString(record.object(forKey: "addressLine1")),
                                     addressLine2: decodeString(record.object(forKey: "addressLine2")),
                                     addressType: decodeString(record.object(forKey: "addressType")),
                                     city: decodeString(record.object(forKey: "city")),
                                     clientID: decodeInt64(record.object(forKey: "clientID")),
                                     country: decodeString(record.object(forKey: "country")),
                                     personID: decodeInt64(record.object(forKey: "personID")),
                                     postcode: decodeString(record.object(forKey: "postcode")),
                                     projectID: decodeInt64(record.object(forKey: "projectID")),
                                     state: decodeString(record.object(forKey: "state")),
                                     teamID: decodeInt64(record.object(forKey: "teamID")))
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getAddressForPerson(personID: Int64, teamID: Int64)->[Addresses]
    {
        let predicate = NSPredicate(format: "(personID == \(personID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Addresses", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Addresses] = populateAddresses(returnArray)
        
        return shiftArray
    }
    
    func getAddresses(teamID: Int64)->[Addresses]
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Addresses", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Addresses] = populateAddresses(returnArray)
        
        return shiftArray
    }
    
    func getAddressForClient(clientID: Int64, teamID: Int64)->[Addresses]
    {
        let predicate = NSPredicate(format: "(clientID == \(clientID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Addresses", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Addresses] = populateAddresses(returnArray)
        
        return shiftArray
    }
    
    func getAddressForProject(projectID: Int64, teamID: Int64)->[Addresses]
    {
        let predicate = NSPredicate(format: "(projectID == \(projectID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Addresses", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Addresses] = populateAddresses(returnArray)
        
        return shiftArray
    }
    
    func getAddressDetails(_ addressID: Int64, teamID: Int64)->[Addresses]
    {
        let predicate = NSPredicate(format: "(addressID == \(addressID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Addresses", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Addresses] = populateAddresses(returnArray)
        
        return shiftArray
    }
    
    func deleteAddress(_ addressID: Int64, teamID: Int64)
    {
        let predicate = NSPredicate(format: "(addressID == \(addressID)) AND (teamID == \(teamID))")
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "Addresses", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            self.performPublicDelete(records!)
            
            sem.signal()
        })
        sem.wait()
    }
    
    func saveAddressRecordToCloudKit(_ sourceRecord: Addresses)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(addressID == \(sourceRecord.addressID)) AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Addresses", predicate: predicate)
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
                    
                    record!.setValue(sourceRecord.addressID, forKey: "addressID")
                    record!.setValue(sourceRecord.addressLine1, forKey: "addressLine1")
                    record!.setValue(sourceRecord.addressLine2, forKey: "addressLine2")
                    record!.setValue(sourceRecord.city, forKey: "city")
                    record!.setValue(sourceRecord.clientID, forKey: "clientID")
                    record!.setValue(sourceRecord.country, forKey: "country")
                    record!.setValue(sourceRecord.personID, forKey: "personID")
                    record!.setValue(sourceRecord.postcode, forKey: "postcode")
                    record!.setValue(sourceRecord.projectID, forKey: "projectID")
                    record!.setValue(sourceRecord.state, forKey: "state")
                    record!.setValue(sourceRecord.addressType, forKey: "addressType")
                    
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
                    let record = CKRecord(recordType: "Addresses")
                    record.setValue(sourceRecord.addressID, forKey: "addressID")
                    record.setValue(sourceRecord.addressLine1, forKey: "addressLine1")
                    record.setValue(sourceRecord.addressLine2, forKey: "addressLine2")
                    record.setValue(sourceRecord.city, forKey: "city")
                    record.setValue(sourceRecord.clientID, forKey: "clientID")
                    record.setValue(sourceRecord.country, forKey: "country")
                    record.setValue(sourceRecord.personID, forKey: "personID")
                    record.setValue(sourceRecord.postcode, forKey: "postcode")
                    record.setValue(sourceRecord.projectID, forKey: "projectID")
                    record.setValue(sourceRecord.state, forKey: "state")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    record.setValue(sourceRecord.addressType, forKey: "addressType")
                    
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
