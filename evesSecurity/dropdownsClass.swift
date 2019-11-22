//
//  dropdownsClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 11/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
//import CoreData
import CloudKit
import SwiftUI

public class dropdowns: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myDropdowns:[dropdownItem] = Array()
    fileprivate var myDropdownTypes: [String] = Array()
    
    public init(teamID: Int64)
    {
        super.init()
        
        if currentUser.currentTeam?.dropdowns == nil
        {
            currentUser.currentTeam?.dropdowns = myCloudDB.getDropdowns(teamID: teamID)
        }
        
        for myItem in (currentUser.currentTeam?.dropdowns)!
        {
            let myObject = dropdownItem(dropdownType: myItem.dropDownType!,
                                        dropdownValue: myItem.dropDownValue!,
                                        teamID: myItem.teamID,
                                        order: myItem.order,
                                        saveRecord: false
            )
            myDropdowns.append(myObject)
            
            var typeFound: Bool = false
            
            for myType in myDropdownTypes
            {
                if myItem.dropDownType! == myType
                {
                    typeFound = true
                    break
                }
            }
            
            if !typeFound
            {
                myDropdownTypes.append(myItem.dropDownType!)
            }
        }
        
        sort()
    }
    
    public init(dropdownType: String, teamID: Int64)
    {
        super.init()
        
        if currentUser.currentTeam?.dropdowns == nil
        {
            currentUser.currentTeam?.dropdowns = myCloudDB.getDropdowns(teamID: teamID)
        }
        
        var workingArray: [Dropdowns] = Array()
        
        for item in (currentUser.currentTeam?.dropdowns)!
        {
            if (item.dropDownType == dropdownType)
            {
                workingArray.append(item)
            }
        }
        
        for myItem in workingArray
        {
            let myObject = dropdownItem(dropdownType: myItem.dropDownType!,
                                        dropdownValue: myItem.dropDownValue!,
                                        teamID: myItem.teamID,
                                        order: myItem.order,
                                        saveRecord: false
            )
            myDropdowns.append(myObject)
            var typeFound: Bool = false
            
            for myType in myDropdownTypes
            {
                if myItem.dropDownType! == myType
                {
                    typeFound = true
                    break
                }
            }
            
            if !typeFound
            {
                myDropdownTypes.append(myItem.dropDownType!)
            }
        }
        
        sort()
    }
    
    public func sort()
    {
        if myDropdowns.count > 0
        {
            myDropdowns.sort
                {
                    // Because workdate has time it throws everything out
                    
                    if $0.order == $1.order
                    {
                        return $0.dropdownValue < $1.dropdownValue
                    }
                    else
                    {
                        return $0.order < $1.order
                    }
            }
        }
    }
    
    public func append(_ newItem: dropdownItem)
    {
        myDropdowns.append(newItem)
    }
    
    
    public func remove(_ item: Int)
    {
        myDropdowns.remove(at: item)
    }
    
    public var dropdowns: [dropdownItem]
    {
        get
        {
            return myDropdowns
        }
    }
    
    public var dropDownTypes: [String]
    {
        return myDropdownTypes
    }
    
    func move(source: IndexSet, destination: Int) {
        myDropdowns.move(fromOffsets: source, toOffset: destination)

        var processIndex: Int64 = 1
        
        DispatchQueue.global(qos: .background).async {
            for item in self.myDropdowns {
                if item.order != processIndex {
                    item.order = processIndex
                    item.saveMove()
                }
                processIndex += 1
            }

            myCloudDB.performBulkPublicSave()
        }
    }
}

public class dropdownItem: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myDropdownValue: String = ""
    fileprivate var myDropdownType: String = ""
    fileprivate var myTeamID: Int64 = 0
    fileprivate var myOrder: Int64 = 0
    fileprivate var myOriginalOrder: Int64 = 0
    
    public var dropdownType: String
    {
        get
        {
            return myDropdownType
        }
    }
    
    public var dropdownValue: String
    {
        get
        {
            return myDropdownValue
        }
        set
        {
            myDropdownValue = newValue
            save()
        }
    }
    
    public var order: Int64
    {
        get
        {
            return myOrder
        }
        set
        {
            if newValue != myOriginalOrder
            {
                myOrder = newValue
                myOriginalOrder = newValue
                
                save()
            }
        }
    }
    
    public override init() {
        super.init()
    }
    
    public init(dropdownType: String, dropdownValue: String, teamID: Int64, order: Int64, saveRecord: Bool)
    {
        super.init()
        
        myDropdownType = dropdownType
        myDropdownValue = dropdownValue
        myOrder = order
        myOriginalOrder = order
        myTeamID = teamID
        
        if saveRecord
        {
            save()
        }
    }
    
    private func save()
    {
        if currentUser.checkWritePermission(adminRoleType)
        {
            let temp = Dropdowns(dropDownType: myDropdownType, dropDownValue: myDropdownValue, teamID: myTeamID, order: myOrder)
            
            DispatchQueue.main.async
                {
                    myCloudDB.saveDropdownsRecordToCloudKit(temp)
            }
        }
    }
    
    func saveMove() {
        if currentUser.checkWritePermission(adminRoleType)
        {
            let temp = Dropdowns(dropDownType: myDropdownType, dropDownValue: myDropdownValue, teamID: myTeamID, order: myOrder)
            
            myCloudDB.moveQuestionRecordToCloudKit(temp)
        }
    }
    
    public func delete()
    {
        if currentUser.checkWritePermission(adminRoleType)
        {
            myCloudDB.deleteDropdowns(myDropdownType, dropdownValue: myDropdownValue, teamID: myTeamID)
            currentUser.currentTeam?.dropdowns = nil
        }
    }
}

public struct Dropdowns {
    public var dropDownType: String?
    public var dropDownValue: String?
    public var teamID: Int64
    public var order: Int64
}

extension CloudKitInteraction
{
    private func populateDropdowns(_ records: [CKRecord]) -> [Dropdowns]
    {
        var tempArray: [Dropdowns] = Array()
        
        for record in records
        {
            var teamID: Int64 = 0
            if record.object(forKey: "teamID") != nil
            {
                teamID = record.object(forKey: "teamID") as! Int64
            }
            
            var order: Int64 = 0
            if record.object(forKey: "order") != nil
            {
                order = record.object(forKey: "order") as! Int64
            }
            
            let tempItem = Dropdowns(dropDownType: record.object(forKey: "dropDownType") as? String,
                                     dropDownValue: record.object(forKey: "dropDownValue") as? String,
                                     teamID: teamID,
                                     order: order)
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getDropdownsTypes(teamID: Int64)->[String]
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (dropDownType != 'Privacy') AND (dropDownType != 'ProjectType') AND (dropDownType != 'Reports') AND (dropDownType != 'RoleAccess') AND (dropDownType != 'RoleType') AND (dropDownType !=  'ShiftType') AND (dropDownType != 'TeamState')")
        
        let query = CKQuery(recordType: "Dropdowns", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Dropdowns] = populateDropdowns(returnArray)
        
        var workingArray: [String] = Array()
        
        for myItem in shiftArray
        {
            workingArray.append(myItem.dropDownType!)
        }
        
        return workingArray
    }
    
    func getDropdowns(teamID: Int64)->[Dropdowns]
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Dropdowns", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Dropdowns] = populateDropdowns(returnArray)
        
        return shiftArray
    }
    
    func getDropdowns(dropdownType: String, teamID: Int64)->[Dropdowns]
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (dropDownType == \"\(dropdownType)\")")
        
        let query = CKQuery(recordType: "Dropdowns", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Dropdowns] = populateDropdowns(returnArray)
        
        return shiftArray
    }
    
    func getDropdowns(dropdownType: String, dropdownValue: String, teamID: Int64)->[Dropdowns]
    {
        let predicate = NSPredicate(format: "(dropDownType == \"\(dropdownType)\") AND (dropDownValue == \"\(dropdownValue)\") AND (teamID == \(teamID))")
        
        let query = CKQuery(recordType: "Dropdowns", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Dropdowns] = populateDropdowns(returnArray)
        
        return shiftArray
    }
    
    func deleteDropdowns(_ dropdownType: String, dropdownValue: String, teamID: Int64)
    {
        let predicate = NSPredicate(format: "(dropDownType == \"\(dropdownType)\") AND (dropDownValue == \"\(dropdownValue)\") AND (teamID == \(teamID))")
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "Dropdowns", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            self.performPublicDelete(records!)
            
            sem.signal()
        })
        sem.wait()
    }
    
    func saveDropdownsRecordToCloudKit(_ sourceRecord: Dropdowns)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(dropDownType == \"\(sourceRecord.dropDownType!)\") AND (dropDownValue == \"\(sourceRecord.dropDownValue!)\") AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Dropdowns", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: A \(error!.localizedDescription)")
            }
            else
            {
                // Lets go and get the additional details from the context1_1 table
                
                if records!.count > 0
                {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    
                    record!.setValue(sourceRecord.dropDownValue, forKey: "dropDownValue")
                    record!.setValue(sourceRecord.order, forKey: "order")
                    
                    // Save this record again
                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: B \(saveError!.localizedDescription)")
                            self.saveOK = false
                            print("next level = \(saveError!)")
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
                    let record = CKRecord(recordType: "Dropdowns")
                    record.setValue(sourceRecord.dropDownType, forKey: "dropDownType")
                    record.setValue(sourceRecord.dropDownValue, forKey: "dropDownValue")
                    record.setValue(sourceRecord.order, forKey: "order")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    
                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: C \(saveError!.localizedDescription)")
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
    
    func moveQuestionRecordToCloudKit(_ sourceRecord: Dropdowns) {
        let predicate = NSPredicate(format: "(dropDownType == \"\(sourceRecord.dropDownType!)\") AND (dropDownValue == \"\(sourceRecord.dropDownValue!)\") AND (teamID == \(sourceRecord.teamID))")
        let query = CKQuery(recordType: "Dropdowns", predicate: predicate)
        
        let sem = DispatchSemaphore(value: 0)
        
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil {
                NSLog("Error querying records: \(error!.localizedDescription)")
            } else {
                // Lets go and get the additional details from the context1_1 table
                
                if records!.count > 0 {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                     
                    record!.setValue(sourceRecord.order, forKey: "order")

                    self.checkSaveRecordList(record!)
                    self.saveRecordList.append(record!)
                    sem.signal()
                }
            }
        })
        sem.wait()
    }
}

