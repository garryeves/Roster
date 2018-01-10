 //
//  meetingSupportingDocsClass.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 23/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

extension coreDatabase
{
    func clearDeletedMeetingSupportingDocs(predicate: NSPredicate)
    {
        let fetchRequest8 = NSFetchRequest<MeetingSupportingDocs>(entityName: "MeetingSupportingDocs")
        
        // Set the predicate on the fetch request
        fetchRequest8.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults8 = try objectContext.fetch(fetchRequest8)
            for myItem8 in fetchResults8
            {
                objectContext.delete(myItem8 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedMeetingSupportingDocs(predicate: NSPredicate)
    {
        let fetchRequest8 = NSFetchRequest<MeetingSupportingDocs>(entityName: "MeetingSupportingDocs")
        
        // Set the predicate on the fetch request
        fetchRequest8.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults8 = try objectContext.fetch(fetchRequest8)
            for myItem8 in fetchResults8
            {
                myItem8.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getMeetingSupportingDocsForSync(_ syncDate: Date) -> [MeetingSupportingDocs]
    {
        let fetchRequest = NSFetchRequest<MeetingSupportingDocs>(entityName: "MeetingSupportingDocs")
        
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

    func deleteAllMeetingSupportingDocRecords()
    {
        let fetchRequest8 = NSFetchRequest<MeetingSupportingDocs>(entityName: "MeetingSupportingDocs")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults8 = try objectContext.fetch(fetchRequest8)
            for myItem8 in fetchResults8
            {
                self.objectContext.delete(myItem8 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func resetMeetingSupportingDocs()
    {
        let fetchRequest6 = NSFetchRequest<MeetingSupportingDocs>(entityName: "MeetingSupportingDocs")
        
        do
        {
            let fetchResults6 = try objectContext.fetch(fetchRequest6)
            for myMeeting6 in fetchResults6
            {
                myMeeting6.updateTime =  NSDate()
                myMeeting6.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
}

extension CloudKitInteraction
{
    func saveMeetingSupportingDocsToCloudKit()
    {
        for myItem in myDatabaseConnection.getMeetingSupportingDocsForSync(getSyncDateForTable(tableName: "MeetingSupportingDocs"))
        {
            saveMeetingSupportingDocsRecordToCloudKit(myItem)
        }
    }

    func updateMeetingSupportingDocsInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", getSyncDateForTable(tableName: "MeetingSupportingDocs") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "MeetingSupportingDocs", predicate: predicate)
        let operation = CKQueryOperation(query: query)

        operation.recordFetchedBlock = { (record) in
            //              self.updateMeetingSupportingDocsRecord(record)
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "MeetingSupportingDocs", queryOperation: operation, onOperationQueue: operationQueue)
    }

//    func deleteMeetingSupportingDocs(teamID: Int)
//    {
//        let sem = DispatchSemaphore(value: 0);
//        
//        var myRecordList: [CKRecordID] = Array()
//        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID))")
//        let query: CKQuery = CKQuery(recordType: "MeetingSupportingDocs", predicate: predicate)
//        publicDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
//            for record in results!
//            {
//                myRecordList.append(record.recordID)
//            }
//            self.performPublicDelete(myRecordList)
//            sem.signal()
//        })
//        sem.wait()
//    }

    func saveMeetingSupportingDocsRecordToCloudKit(_ sourceRecord: MeetingSupportingDocs)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(meetingID == \"\(sourceRecord.meetingID!)\") && (agendaID == \(sourceRecord.agendaID)) AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the
        let query = CKQuery(recordType: "MeetingSupportingDocs", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else
            {
                if records!.count > 0
                {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    if sourceRecord.updateTime != nil
                    {
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    record!.setValue(sourceRecord.attachmentPath, forKey: "attachmentPath")
                    record!.setValue(sourceRecord.title, forKey: "title")
                    
                    // Save this record again
                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
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
                    let record = CKRecord(recordType: "MeetingSupportingDocs")
                    record.setValue(sourceRecord.meetingID, forKey: "meetingID")
                    record.setValue(sourceRecord.agendaID, forKey: "agendaID")
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.attachmentPath, forKey: "attachmentPath")
                    record.setValue(sourceRecord.title, forKey: "title")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    
                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
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

    func updateMeetingSupportingDocsRecord(_ sourceRecord: CKRecord)
    {
        //  let meetingID = sourceRecord.objectForKey("meetingID") as! String
        //              let agendaID = sourceRecord.objectForKey("agendaID") as! Int
        //        var updateTime = NSDate()
        //        if sourceRecord.objectForKey("updateTime") != nil
        //        {
        //            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        //        }
        
        //       var updateType = ""
        
        //      if sourceRecord.objectForKey("updateType") != nil
        //      {
        //          updateType = sourceRecord.objectForKey("updateType") as! String
        //      }
        //              let attachmentPath = sourceRecord.objectForKey("attachmentPath") as! String
        //              let title = sourceRecord.objectForKey("title") as! String
        
        NSLog("updateMeetingSupportingDocsInCoreData - Need to have the save for this")
        
//        myDatabaseConnection.recordsToChange += 1
//        
//        while self.recordCount > 0
//        {
//            usleep(self.sleepTime)
//        }
//        
//        self.recordCount += 1
        // myDatabaseConnection.updateDecodeValue(decodeName! as! String, codeValue: decodeValue! as! String, codeType: decodeType! as! String)
//        self.recordCount -= 1
    }
}
