//
//  ratesClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 11/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
//import CoreData
import CloudKit
import SwiftUI

public class rates: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myRates:[rate] = Array()
    
    public init(clientID: Int64, teamID: Int64)
    {
        if currentUser.currentTeam!.rates == nil
        {
            currentUser.currentTeam!.rates = myCloudDB.getRates(teamID: teamID)
        }
        
        //        var returnArray: [Rates] = Array()
        
        //        for item in (currentUser.currentTeam?.rates)!
        //        for item in myCloudDB.getRates(clientID: clientID, teamID: teamID)
        //        {
        //            if item.clientID == clientID
        //            {
        //                returnArray.append(item)
        //            }
        //        }
        //
        //        for myItem in returnArray
        //        {
        //            let myObject = rate(rateID: myItem.rateID,
        //                                clientID: myItem.clientID,
        //                                rateName: myItem.rateName!,
        //                                rateAmount: myItem.rateAmount,
        //                                chargeAmount: myItem.chargeAmount,
        //                                startDate: myItem.startDate! as Date,
        //                                teamID: myItem.teamID,
        //                                active: myItem.active)
        //            myRates.append(myObject)
        //        }
        
        
        for item in (currentUser.currentTeam?.rates)!
        {
            if item.clientID == clientID
            {
                let myObject = rate(rateID: item.rateID,
                                    clientID: item.clientID,
                                    rateName: item.rateName!,
                                    rateAmount: item.rateAmount,
                                    chargeAmount: item.chargeAmount,
                                    startDate: item.startDate! as Date,
                                    teamID: item.teamID,
                                    active: item.active)
                myRates.append(myObject)
            }
        }
        
        if myRates.count > 0
        {
            myRates.sort
                {
                    if $0.isActive == $1.isActive
                    {
                        if $0.startDate == $1.startDate
                        {
                            return $0.rateName < $1.rateName
                        }
                        else
                        {
                            return $0.startDate < $1.startDate
                        }
                    }
                    else
                    {
                        return $0.isActive && !$1.isActive
                    }
            }
        }
    }
    
    public init(teamID: Int64)
    {
        if currentUser.currentTeam?.rates == nil
        {
            currentUser.currentTeam?.rates = myCloudDB.getRates(teamID: teamID)
        }
        
        for myItem in (currentUser.currentTeam?.rates)!
        {
            let myObject = rate(rateID: myItem.rateID,
                                clientID: myItem.clientID,
                                rateName: myItem.rateName!,
                                rateAmount: myItem.rateAmount,
                                chargeAmount: myItem.chargeAmount,
                                startDate: myItem.startDate! as Date,
                                teamID: myItem.teamID,
                                active: myItem.active)
            myRates.append(myObject)
        }
    }
    
    public func append(_ newrecord: rate)
    {
        myRates.append(newrecord)
    }
    
    public var rates: [rate]
    {
        get
        {
            return myRates
        }
    }
    
    public func checkRate(_ rateID: Int64) -> Bool
    {
        let filteredItems = myRates.filter { $0.rateID == rateID}
        
        if filteredItems.count > 0
        {
            return true
        }
        else
        {
            return false
        }
    }
}

public class rate: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myRateID: Int64 = 0
    fileprivate var myClientID: Int64 = 0
    fileprivate var myRateName: String = ""
    fileprivate var myRateAmount: Double = 0.0
    fileprivate var myChargeAmount: Double = 0.0
    fileprivate var myStartDate: Date = getDefaultDate()
    fileprivate var myTeamID: Int64 = 0
    fileprivate var myActive: Bool = true
    
    public var rateID: Int64
    {
        get
        {
            return myRateID
        }
    }
    
    public var clientID: Int64
    {
        get
        {
            return myClientID
        }
    }
    
    public var rateName: String
    {
        get
        {
            return myRateName
        }
        set
        {
            myRateName = newValue
        }
    }
    
    public var rateAmount: Double
    {
        get
        {
            return myRateAmount
        }
        set
        {
            myRateAmount = newValue
        }
    }
    
    public var chargeAmount: Double
    {
        get
        {
            return myChargeAmount
        }
        set
        {
            myChargeAmount = newValue
        }
    }
    
    public var GP: String
    {
        get
        {
            return String(format: "%.1f", ((myChargeAmount - myRateAmount) / myChargeAmount) * 100.0)
        }
    }
    
    public var startDate: Date
    {
        get
        {
            return myStartDate
        }
        set
        {
            myStartDate = newValue
        }
    }
    
    public var displayStartDate: String
    {
        get
        {
            if myStartDate == getDefaultDate() as Date
            {
                return ""
            }
            else
            {
                let myDateFormatter = DateFormatter()
                myDateFormatter.dateStyle = DateFormatter.Style.short
                return myDateFormatter.string(from: myStartDate)
            }
        }
    }
    
    public var hasShiftEntry: Bool
    {
        get
        {
            if myCloudDB.getShiftForRate(rateID: myRateID, type: shiftShiftType, teamID: myTeamID).count > 0
            {
                return true
            }
            else
            {
                return false
            }
        }
    }
    
    public var isActive: Bool
    {
        get
        {
            return myActive
        }
        set
        {
            myActive = newValue
            save()
            currentUser.currentTeam?.rates = nil
        }
    }
    
    public init(clientID: Int64, teamID: Int64)
    {
        super.init()
        
        myRateID = myCloudDB.getNextID("Rates", teamID: teamID)
        myClientID = clientID
        myTeamID = teamID
        
        save()
        currentUser.currentTeam?.rates = nil
    }
    
    public init(clientID: Int64,
                rateName: String,
                rateAmount: Double,
                chargeAmount: Double,
                startDate: Date,
                teamID: Int64)
    {
        super.init()
        
        myRateID = myCloudDB.getNextID("Rates", teamID: teamID)
        myClientID = clientID
        myRateName = rateName
        myRateAmount = rateAmount
        myChargeAmount = chargeAmount
        myStartDate = startDate
        myTeamID = teamID
        
        save()
        
        currentUser.currentTeam?.rates = nil
    }
    
    public init(rateID: Int64, teamID: Int64)
    {
        super.init()
        if currentUser.currentTeam?.rates == nil
        {
            currentUser.currentTeam?.rates = myCloudDB.getRates(teamID: teamID)
        }
        
        var myItem: Rates!
        
        for item in (currentUser.currentTeam?.rates)!
        {
            if item.rateID == rateID
            {
                myItem = item
                break
            }
        }
        
        if myItem != nil
        {
            myRateID = myItem.rateID
            myClientID = myItem.clientID
            myRateName = myItem.rateName!
            myRateAmount = myItem.rateAmount
            myChargeAmount = myItem.chargeAmount
            myStartDate = myItem.startDate! as Date
            myTeamID = myItem.teamID
            myActive = myItem.active
        }
    }
    
    public init(rateID: Int64,
                clientID: Int64,
                rateName: String,
                rateAmount: Double,
                chargeAmount: Double,
                startDate: Date,
                teamID: Int64,
                active: Bool
        )
    {
        super.init()
        
        myRateID = rateID
        myClientID = clientID
        myRateName = rateName
        myRateAmount = rateAmount
        myChargeAmount = chargeAmount
        myStartDate = startDate
        myTeamID = teamID
        myActive = active
    }
    
    public func save()
    {
        if currentUser.checkWritePermission(financialsRoleType) || currentUser.checkWritePermission(salesRoleType)
        {
            let temp = Rates(chargeAmount: myChargeAmount, clientID: myClientID, rateAmount: myRateAmount, rateID: myRateID, rateName: myRateName, startDate: myStartDate, teamID: myTeamID, active: myActive)
            
            myCloudDB.saveRatesRecordToCloudKit(temp)
        }
    }
    
    public func delete()
    {
        if currentUser.checkWritePermission(financialsRoleType) || currentUser.checkWritePermission(salesRoleType)
        {
            myCloudDB.deleteRates(myRateID, teamID: myTeamID)
            currentUser.currentTeam?.rates = nil
        }
    }
}

//extension coreDatabase
//{
//    func saveRates(_ rateID: Int,
//                   clientID: Int,
//                   rateName: String,
//                   rateAmount: Double,
//                   chargeAmount: Double,
//                   startDate: Date,
//                   teamID: Int,
//                     updateTime: Date =  Date(), updateType: String = "CODE")
//    {
//        var myItem: Rates!
//
//        let myReturn = getRatesDetails(rateID, teamID: teamID)
//
//        if myReturn.count == 0
//        { // Add
//            myItem = Rates(context: objectContext)
//            myItem.rateID = Int64(rateID)
//            myItem.clientID = Int64(clientID)
//            myItem.rateName = rateName
//            myItem.rateAmount = rateAmount
//            myItem.chargeAmount = chargeAmount
//            myItem.startDate = startDate
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
//            myItem.clientID = Int64(clientID)
//            myItem.rateName = rateName
//            myItem.rateAmount = rateAmount
//            myItem.chargeAmount = chargeAmount
//            myItem.startDate = startDate
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
//    func restoreRate(_ rateID: Int, teamID: Int)
//    {
//        for myItem in getRatesDetails(rateID, teamID: teamID)
//        {
//            myItem.updateType = "Update"
//            myItem.updateTime = Date()
//        }
//        saveContext()
//    }
//
//    func resetAllRates()
//    {
//        let fetchRequest = NSFetchRequest<Rates>(entityName: "Rates")
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
//    func clearDeletedRates(predicate: NSPredicate)
//    {
//        let fetchRequest2 = NSFetchRequest<Rates>(entityName: "Rates")
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
//    func clearSyncedRates(predicate: NSPredicate)
//    {
//        let fetchRequest2 = NSFetchRequest<Rates>(entityName: "Rates")
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
//    func getRatesForSync(_ syncDate: Date) -> [Rates]
//    {
//        let fetchRequest = NSFetchRequest<Rates>(entityName: "Rates")
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
//    func deleteAllRates()
//    {
//        let fetchRequest2 = NSFetchRequest<Rates>(entityName: "Rates")
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

public struct Rates {
    public var chargeAmount: Double
    public var clientID: Int64
    public var rateAmount: Double
    public var rateID: Int64
    public var rateName: String?
    public var startDate: Date?
    public var teamID: Int64
    public var active: Bool!
}

extension CloudKitInteraction
{
    private func populateRates(_ records: [CKRecord]) -> [Rates]
    {
        var tempArray: [Rates] = Array()
        
        for record in records
        {
            var rateID: Int64 = 0
            if record.object(forKey: "rateID") != nil
            {
                rateID = record.object(forKey: "rateID") as! Int64
            }
            
            var clientID: Int64 = 0
            if record.object(forKey: "clientID") != nil
            {
                clientID = record.object(forKey: "clientID") as! Int64
            }
            
            var rateAmount: Double = 0.0
            if record.object(forKey: "rateAmount") != nil
            {
                rateAmount = record.object(forKey: "rateAmount") as! Double
            }
            
            var chargeAmount: Double = 0.0
            if record.object(forKey: "chargeAmount") != nil
            {
                chargeAmount = record.object(forKey: "chargeAmount") as! Double
            }
            
            var startDate: Date = getDefaultDate()
            if record.object(forKey: "startDate") != nil
            {
                startDate = record.object(forKey: "startDate") as! Date
            }
            
            var active: Bool = true
            if record.object(forKey: "active") != nil
            {
                if record.object(forKey: "active") as? String == "false"
                {
                    active = false
                }
            }
            
            var teamID: Int64 = 0
            if record.object(forKey: "teamID") != nil
            {
                teamID = record.object(forKey: "teamID") as! Int64
            }
            
            let tempItem = Rates(chargeAmount: chargeAmount,
                                 clientID: clientID,
                                 rateAmount: rateAmount,
                                 rateID: rateID,
                                 rateName: record.object(forKey: "rateName") as? String,
                                 startDate: startDate,
                                 teamID: teamID,
                                 active: active)
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getRates(clientID: Int64, teamID: Int64)->[Rates]
    {
        let predicate = NSPredicate(format: "(clientID == \(clientID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Rates", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        let shiftArray: [Rates] = populateRates(returnArray)
        
        return shiftArray
    }
    
    func getRates(teamID: Int64)->[Rates]
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Rates", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Rates] = populateRates(returnArray)
        
        return shiftArray
    }
    
    func getRatesDetails(_ rateID: Int64, teamID: Int64)->[Rates]
    {
        let predicate = NSPredicate(format: "(rateID == \(rateID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Rates", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Rates] = populateRates(returnArray)
        
        return shiftArray
    }
    
    func deleteRates(_ rateID: Int64, teamID: Int64)
    {
        let predicate = NSPredicate(format: "(rateID == \(rateID)) AND (teamID == \(teamID))")
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "Rates", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            self.performPublicDelete(records!)
            
            sem.signal()
        })
        sem.wait()
    }
    
    func saveRatesRecordToCloudKit(_ sourceRecord: Rates)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(rateID == \(sourceRecord.rateID)) AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Rates", predicate: predicate)
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
                    record!.setValue(sourceRecord.rateName, forKey: "rateName")
                    record!.setValue(sourceRecord.rateAmount, forKey: "rateAmount")
                    record!.setValue(sourceRecord.chargeAmount, forKey: "chargeAmount")
                    record!.setValue(sourceRecord.startDate, forKey: "startDate")
                    if sourceRecord.active
                    {
                        record!.setValue("true", forKey: "active")
                    }
                    else
                    {
                        record!.setValue("false", forKey: "active")
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
                    let record = CKRecord(recordType: "Rates")
                    record.setValue(sourceRecord.rateID, forKey: "rateID")
                    record.setValue(sourceRecord.clientID, forKey: "clientID")
                    record.setValue(sourceRecord.rateName, forKey: "rateName")
                    record.setValue(sourceRecord.rateAmount, forKey: "rateAmount")
                    record.setValue(sourceRecord.chargeAmount, forKey: "chargeAmount")
                    record.setValue(sourceRecord.startDate, forKey: "startDate")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    
                    if sourceRecord.active
                    {
                        record.setValue("true", forKey: "active")
                    }
                    else
                    {
                        record.setValue("false", forKey: "active")
                    }
                    
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
        
        sleep(2)
    }
    
    func getDeletedRates(_ teamID: Int64)->[Rates]
    {
        let predicate = NSPredicate(format: "(updateType == \"Delete\") AND (teamID == \(teamID))")
        
        let query = CKQuery(recordType: "Clients", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Rates] = populateRates(returnArray)
        
        return shiftArray
    }
}

