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
    
    public init(clientID: Int64, teamID: Int64, isActive: Bool = false) {
        currentUser.currentTeam!.rates = myCloudDB.getRates(teamID: teamID, isActive: isActive)
        
        for item in (currentUser.currentTeam?.rates)! {
            if item.clientID == clientID {
                var rateNameText = "Issue with rate name.  Please restart"
                
          //      if item.rateName != nil {
                    rateNameText = item.rateName
            //    }
                
                let myObject = rate(rateID: item.rateID,
                                    clientID: item.clientID,
                                    rateName: rateNameText,
                                    rateAmount: item.rateAmount,
                                    chargeAmount: item.chargeAmount,
                                    startDate: item.startDate,
                                    teamID: item.teamID,
                                    active: item.active)
                myRates.append(myObject)
            }
        }
        
        if myRates.count > 0 {
            myRates.sort {
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
    
    public init(teamID: Int64, isActive: Bool = false)
    {
        currentUser.currentTeam?.rates = myCloudDB.getRates(teamID: teamID, isActive: isActive)
        
        for myItem in (currentUser.currentTeam?.rates)!
        {
            var rateText = "Error with loaging rate name, please reload app"
        
      //      if myItem.rateName != nil {
                rateText = myItem.rateName
       //     }
            
            let myObject = rate(rateID: myItem.rateID,
                                clientID: myItem.clientID,
                                rateName: rateText,
                                rateAmount: myItem.rateAmount,
                                chargeAmount: myItem.chargeAmount,
                                startDate: myItem.startDate,
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
            currentUser.currentTeam?.rates = myCloudDB.getRates(teamID: teamID, isActive: false)
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
            myRateName = myItem.rateName
            myRateAmount = myItem.rateAmount
            myChargeAmount = myItem.chargeAmount
            myStartDate = myItem.startDate
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

public struct Rates {
    public var chargeAmount: Double
    public var clientID: Int64
    public var rateAmount: Double
    public var rateID: Int64
    public var rateName: String
    public var startDate: Date
    public var teamID: Int64
    public var active: Bool
}

extension CloudKitInteraction
{
    private func populateRates(_ records: [CKRecord]) -> [Rates]
    {
        var tempArray: [Rates] = Array()
        
        for record in records
        {
            let tempItem = Rates(chargeAmount: decodeDouble(record.object(forKey: "chargeAmount")),
                                 clientID: decodeInt64(record.object(forKey: "clientID")),
                                 rateAmount: decodeDouble(record.object(forKey: "rateAmount")),
                                 rateID: decodeInt64(record.object(forKey: "rateID")),
                                 rateName: decodeString(record.object(forKey: "rateName")),
                                 startDate: decodeDefaultDate(record.object(forKey: "startDate")),
                                 teamID: decodeInt64(record.object(forKey: "teamID")),
                                 active: decodeBool(record.object(forKey: "active"), defaultReturn: true))
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getRates(clientID: Int64, teamID: Int64, isActive: Bool)->[Rates]
    {
        var predicate = NSPredicate()
        if isActive {
            predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\") AND (active == \"true\")")
        } else {
            predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\")")
        }
        
        let query = CKQuery(recordType: "Rates", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        let shiftArray: [Rates] = populateRates(returnArray)
        
        return shiftArray
    }
    
    func getRates(teamID: Int64, isActive: Bool)->[Rates]
    {
        var predicate = NSPredicate()
        if isActive {
            predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\") AND (active == \"true\")")
        } else {
            predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\")")
        }

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

