//
//  evesSecurityShared.swift
//  evesSecurity
//
//  Created by Garry Eves on 9/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CloudKit
import SwiftUI
import EventKit

public let coreDatabaseName = "EvesCRM"
public var appName = ""

public var userName: String = ""
public var userEmail: String = ""

public var mainViewController: UIViewController!

public let saveDelay: UInt32 = 2

public let NoStageLabel = "No stage"

@objc public protocol myCommunicationDelegate
{
    @objc optional func orgEdit(_ organisation: team?)
    @objc optional func userCreated(_ userRecord: userItem, teamID: Int64)
    @objc optional func loadMainScreen()
    @objc optional func passwordCorrect()
    @objc optional func refreshScreen()
    @objc optional func callLoadMainScreen()
}

let eventSignInNotPresentType = "Staff Not Present"
let eventSignInOnSiteType = "Staff On-Site"

struct eventSignInSummaryRecord: Identifiable
{
    let id = UUID()
    var role: String
    var toCome: Int
    var onSite: Int
}

struct eventSignInDisplayRecord: Identifiable
{
    let id = UUID()
    var details: String
    var source: shift!
}

public let defaultsName = "group.com.garryeves.EvesCRM"
public let userDefaultName = "userID"
public let userDefaultPassword = "password"
public let userDefaultPasswordHint = "passwordHint"

public func writeDefaultString(_ keyName: String, value: String)
{
    let defaults = UserDefaults(suiteName: defaultsName)!
    
    defaults.set(value, forKey: keyName)
    
    defaults.synchronize()
}

public func writeDefaultInt(_ keyName: String, value: Int)
{
    let defaults = UserDefaults(suiteName: defaultsName)!
    
    defaults.set(value, forKey: keyName)
    
    defaults.synchronize()
}

public func writeDefaultDate(_ keyName: String, value: Date)
{
    let defaults = UserDefaults(suiteName: defaultsName)!
    
    defaults.set(value, forKey: keyName)
    
    defaults.synchronize()
}

public func readDefaultString(_ keyName: String) -> String
{
    let defaults = UserDefaults(suiteName: defaultsName)!
    
    if defaults.string(forKey: keyName) != nil
    {
        return (defaults.string(forKey: keyName))!
    }
    else
    {
        return ""
    }
}

public func readDefaultInt(_ keyName: String) -> Int
{
    let defaults = UserDefaults(suiteName: defaultsName)!
    
    if defaults.string(forKey: keyName) != nil
    {
        return defaults.integer(forKey: keyName)
    }
    else
    {
        return -1
    }
}

public func readDefaultDate(_ keyName: String) -> Date
{
    let defaults = UserDefaults(suiteName: defaultsName)!
    
    if defaults.object(forKey: keyName) != nil
    {
        let tempDate = defaults.object(forKey: keyName) as? Date
        return tempDate!
    }
    else
    {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        return dateStringFormatter.date(from: "2016-01-01")!
    }
}

public func removeDefaultString(_ keyName: String)
{
    let defaults = UserDefaults(suiteName: defaultsName)!
    
    defaults.removeObject(forKey: keyName)
    
    defaults.synchronize()
}

public func setSyncDateforTable(tableName: String, syncDate: Date)
{
    writeDefaultDate(tableName, value: syncDate)
}

public func getSyncDateForTable(tableName: String) -> Date
{
    return readDefaultDate(tableName)
}

public func updateSubscriptions(expiryDate: Date, numUsers: Int64)
{
    for teamList in myCloudDB.getTeamsIOwn(currentUser.userID)
    {
        let workingTeam = team(teamID: teamList.teamID)
        workingTeam.subscriptionDate = expiryDate.startOfDay
        workingTeam.subscriptionLevel = numUsers
        workingTeam.save()
    }
}

public struct TableData
{
    var displayText: String
    
    fileprivate var myDisplayFormat: String
    fileprivate var myObjectType: String
    fileprivate var myReminderPriority: Int
    fileprivate var myNotes: String
    fileprivate var myCalendarItemIdentifier: String
    fileprivate var myTask: task?
//    fileprivate var myEvent: Int
    fileprivate var myObject: AnyObject?
    fileprivate var myCalendarEvent: EKEvent?
    
    var displaySpecialFormat: String
        {
        get {
            return myDisplayFormat
        }
        set {
            myDisplayFormat = newValue
        }
    }
    
    var objectType: String
        {
        get {
            return myObjectType
        }
        set {
            myObjectType = newValue
        }
    }
    
    var reminderPriority: Int
        {
        get {
            return myReminderPriority
        }
        set {
            myReminderPriority = newValue
        }
    }
    
    var calendarItemIdentifier: String
        {
        get {
            return myCalendarItemIdentifier
        }
        set {
            myCalendarItemIdentifier = newValue
        }
    }
    
    var notes: String
        {
        get {
            return myNotes
        }
        set {
            myNotes = newValue
        }
    }
    
    var task: task?
    {
        get
        {
            return myTask
        }
        set
        {
            myTask = newValue
        }
    }
    
//    var calendarItem: calendarItem?
//    {
//        get
//        {
//            return myEvent
//        }
//        set
//        {
//            myEvent = newValue
//        }
//    }
    
    var event: EKEvent?
    {
        get
        {
            return myCalendarEvent
        }
        set
        {
            myCalendarEvent = newValue
        }
    }
    
    var object: AnyObject?
    {
        get
        {
            return myObject
        }
        set
        {
            myObject = newValue
        }
    }
    
    public init(displayText: String)
    {
        self.displayText = displayText
        self.myDisplayFormat = ""
        self.myObjectType = ""
        self.myReminderPriority = 0
        self.myCalendarItemIdentifier = ""
        self.myNotes = ""
    }
}

// Here I am definging my own struct to use in the Display array.  This is to allow passing of multiple different types of information

// Overloading writeRowToArray a number of times to allow for collection of structs where I am going to allow user to interact and change data inside the app,rather than them having to go to source app.  The number of these will be kept to a minimum.

func writeRowToArray(_ displayText: String, table: inout [TableData], displayFormat: String="")
{
    // Create the struct for this record
    
    var myDisplay: TableData = TableData(displayText: displayText)

    if displayFormat != ""
    {
        myDisplay.displaySpecialFormat = displayFormat
    }
        
    table.append(myDisplay)
}

func writeRowToArray(_ displayText: String, table: inout [TableData], targetTask: task, displayFormat: String="")
{
    // Create the struct for this record
    
    var myDisplay: TableData = TableData(displayText: displayText)
    
    if displayFormat != ""
    {
        myDisplay.displaySpecialFormat = displayFormat
    }
    
    myDisplay.task = targetTask
    
    table.append(myDisplay)
}

//func writeRowToArray(_ displayText: String, table: inout [TableData], targetEvent: calendarItem, displayFormat: String="")
//{
//    // Create the struct for this record
//
//    var myDisplay: TableData = TableData(displayText: displayText)
//
//    if displayFormat != ""
//    {
//        myDisplay.displaySpecialFormat = displayFormat
//    }
//
//    myDisplay.calendarItem = targetEvent
//
//    table.append(myDisplay)
//}

func writeRowToArray(_ displayText: String, table: inout [TableData], targetObject: AnyObject, displayFormat: String="")
{
    // Create the struct for this record
    
    var myDisplay: TableData = TableData(displayText: displayText)
    
    if displayFormat != ""
    {
        myDisplay.displaySpecialFormat = displayFormat
    }
    
    myDisplay.object = targetObject
    
    table.append(myDisplay)
}

public let frameworkBundle = Bundle(identifier: "com.garryeves.evesShared")


public let loginStoryboard = UIStoryboard(name: "LoginRoles", bundle: frameworkBundle)
public let pickerStoryboard = UIStoryboard(name: "dropDownMenus", bundle: frameworkBundle)
public let personStoryboard = UIStoryboard(name: "person", bundle: frameworkBundle)
public let clientsStoryboard = UIStoryboard(name: "Clients", bundle: frameworkBundle)
public let projectsStoryboard = UIStoryboard(name: "Projects", bundle: frameworkBundle)
public let reportsStoryboard = UIStoryboard(name: "reports", bundle: frameworkBundle)
public let shiftsStoryboard = UIStoryboard(name: "Shifts", bundle: frameworkBundle)
public let tasksStoryboard = UIStoryboard(name: "tasks", bundle: frameworkBundle)
public let meetingStoryboard = UIStoryboard(name: "meetings", bundle: frameworkBundle)
public let settingsStoryboard = UIStoryboard(name: "Settings", bundle: frameworkBundle)
public let invoiceStoryboard = UIStoryboard(name: "Invoicing", bundle: frameworkBundle)
public let coursesStoryboard = UIStoryboard(name: "courses", bundle: frameworkBundle)
public let salesStoryboard = UIStoryboard(name: "Leads", bundle: frameworkBundle)

public var currentAddressBook: addressBookClass!
public var currentUser: userItem!



//public func openProject(_ target: project, sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
//{
//
//    let contractEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
//    contractEditViewControl.communicationDelegate = commsDelegate
//    contractEditViewControl.workingContract = target
//    sourceView.present(contractEditViewControl, animated: true, completion: nil)
//}
//
//public func openClient(_ target: client?, sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
//{
//    let clientMaintenanceViewControl = clientsStoryboard.instantiateViewController(withIdentifier: "clientMaintenance") as! clientMaintenanceViewController
//    clientMaintenanceViewControl.communicationDelegate = commsDelegate
//    if target != nil
//    {
//        clientMaintenanceViewControl.selectedClient = target
//    }
//    sourceView.present(clientMaintenanceViewControl, animated: true, completion: nil)
//}
//
//public func openEvent(_ target: project?, sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
//{
//    let eventsViewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "eventPlanningForm") as! eventPlanningViewController
//    eventsViewControl.communicationDelegate = commsDelegate
//    if target != nil
//    {
//        eventsViewControl.currentEvent = target
//    }
//    sourceView.present(eventsViewControl, animated: true, completion: nil)
//}
//
//public func openRoster(_ target: shift?, sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
//{
//    let rosterMaintenanceViewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "rosterForm") as! shiftMaintenanceViewController
//    rosterMaintenanceViewControl.communicationDelegate = commsDelegate
//    if target != nil
//    {
//        rosterMaintenanceViewControl.currentWeekEndingDate = target?.weekEndDate
//    }
//    sourceView.present(rosterMaintenanceViewControl, animated: true, completion: nil)
//}
//
//public func openSettings(_ sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
//{
//    let userEditViewControl = settingsStoryboard.instantiateViewController(withIdentifier: "settings") as! settingsViewController
//    userEditViewControl.communicationDelegate = commsDelegate
//    sourceView.present(userEditViewControl, animated: true, completion: nil)
//}
//
//public func openPeople(_ sourceView: UIViewController)
//{
//    let peopleEditViewControl = personStoryboard.instantiateViewController(withIdentifier: "personForm") as! personViewController
//    sourceView.present(peopleEditViewControl, animated: true, completion: nil)
//}
//
//public func openMonthlyRoster(_ sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
//{
//    let rosterViewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "monthlyRoster") as! monthlyRosterViewController
//    rosterViewControl.communicationDelegate = commsDelegate
//    sourceView.present(rosterViewControl, animated: true, completion: nil)
//}
//
//public func openReports(_ sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
//{
//    let reportsViewControl = reportsStoryboard.instantiateViewController(withIdentifier: "reportScreen") as! reportView
//    reportsViewControl.communicationDelegate = commsDelegate
//    sourceView.present(reportsViewControl, animated: true, completion: nil)
//}
//
//public func openComms(_ target: commsLogEntry, sourceView: UIViewController, commsDelegate: myCommunicationDelegate, button: UIButton, delegate: UIPopoverPresentationControllerDelegate)
//{
//    let commsView = settingsStoryboard.instantiateViewController(withIdentifier: "commsLogView") as! commsLogView
//    commsView.modalPresentationStyle = .popover
//
//    let popover = commsView.popoverPresentationController!
//    popover.delegate = delegate
//    popover.sourceView = button
//    popover.sourceRect = button.bounds
//    popover.permittedArrowDirections = .any
//
//    commsView.preferredContentSize = CGSize(width: 500,height: 800)
//    commsView.workingEntry = target
//    sourceView.present(commsView, animated: true, completion: nil)
//}
//
//public func openUser(_ sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
//{
//    let loginViewControl = loginStoryboard.instantiateViewController(withIdentifier: "newInstance") as! newInstanceViewController
//    loginViewControl.communicationDelegate = commsDelegate
//    sourceView.present(loginViewControl, animated: true, completion: nil)
//}
//
//public func openOrg(_ target: team, sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
//{
//    let orgEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "orgEdit") as! orgEditViewController
//    orgEditViewControl.communicationDelegate = commsDelegate
//    orgEditViewControl.workingOrganisation = target
//    sourceView.present(orgEditViewControl, animated: true, completion: nil)
//}
//
//public func openUserForm(_ target: userItem, sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
//{
//    let userEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "userForm") as! userFormViewController
//    userEditViewControl.workingUser = target
//    userEditViewControl.communicationDelegate = commsDelegate
//    userEditViewControl.initialUser = true
//    sourceView.present(userEditViewControl, animated: true, completion: nil)
//}
//
//public func openPassword(_ sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
//{
//    let passwordViewControl = loginStoryboard.instantiateViewController(withIdentifier: "enterPassword") as! validatePasswordViewController
//    passwordViewControl.communicationDelegate = commsDelegate
//    sourceView.present(passwordViewControl, animated: true, completion: nil)
//}
//
//public func openMeeting(_ target: calendarItem!, sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
//{
//    let meetingView = meetingStoryboard.instantiateViewController(withIdentifier: "Meetings") as! meetingsViewController
//
//    if target != nil
//    {
//        meetingView.passedMeeting = target
//    }
//
//    meetingView.delegate = commsDelegate
//    sourceView.present(meetingView, animated: true, completion: nil)
//}
//
//public func openTask(_ target: task, sourceView: UIViewController, commsDelegate: myCommunicationDelegate, button: UIButton, delegate: UIPopoverPresentationControllerDelegate)
//{
//    let popoverContent = tasksStoryboard.instantiateViewController(withIdentifier: "tasks") as! taskViewController
//    popoverContent.modalPresentationStyle = .popover
//    let popover = popoverContent.popoverPresentationController
//    popover!.delegate = delegate
//    popover!.sourceView = button
//    popover!.sourceRect = CGRect(x: 700,y: 700,width: 0,height: 0)
//
//    popoverContent.passedTaskType = "minutes"
//    popoverContent.passedTask = target
//
//    popoverContent.preferredContentSize = CGSize(width: 700,height: 700)
//
//    sourceView.present(popoverContent, animated: true, completion: nil)
//}
//
//#else

//public func openProject(_ target: project, sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
//{
//    #if os(iOS)
//    let contractEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
//    #else
//    let contractEditViewControl = projectsStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "contractMaintenance")) as! contractMaintenanceViewController
//    #endif
//    contractEditViewControl.communicationDelegate = commsDelegate
//    contractEditViewControl.workingContract = target
//    //    sourceView.presentViewController(contractEditViewControl)
//    sourceView.present(contractEditViewControl, animated: true)
//}

public func openStaffInvoicing(_ sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
{
    let split = invoiceStoryboard.instantiateViewController(withIdentifier: "personInvoiceSplit") as! UISplitViewController
    
    mainViewController = sourceView
    sourceView.view.window?.rootViewController = split
}

//public func openClient(_ target: client?, sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
//{
//    #if os(iOS)
//    let clientMaintenanceViewControl = clientsStoryboard.instantiateViewController(withIdentifier: "clientMaintenance") as! clientMaintenanceViewController
//    #else
//    let clientMaintenanceViewControl = clientsStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "clientMaintenance")) as! clientMaintenanceViewController
//    #endif
//    clientMaintenanceViewControl.communicationDelegate = commsDelegate
//    if target != nil
//    {
//        clientMaintenanceViewControl.selectedClient = target
//    }
//    sourceView.present(clientMaintenanceViewControl, animated: true)
//}

//public func openEvent(_ target: project?, sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
//{
//    #if os(iOS)
//    let eventsViewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "eventPlanningForm") as! eventPlanningViewController
//    #else
//    let eventsViewControl = shiftsStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "eventPlanningForm")) as! eventPlanningViewController
//    #endif
//    //eventsViewControl.communicationDelegate = commsDelegate
//    if target != nil
//    {
//        eventsViewControl.currentEvent = target
//    }
//    sourceView.present(eventsViewControl, animated: true)
//}

//public func openRoster(_ target: shift?, sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
//{
//    #if os(iOS)
//    let rosterMaintenanceViewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "rosterForm") as! shiftMaintenanceViewController
//    #else
//    let rosterMaintenanceViewControl = shiftsStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "rosterForm")) as! shiftMaintenanceViewController
//    #endif
//  //  rosterMaintenanceViewControl.communicationDelegate = commsDelegate
//    if target != nil
//    {
//        rosterMaintenanceViewControl.currentWeekEndingDate = target?.weekEndDate
//    }
//    sourceView.present(rosterMaintenanceViewControl, animated: true)
//}

public func openSettings(_ sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
{
    let userEditViewControl = settingsStoryboard.instantiateViewController(withIdentifier: "settings") as! settingsViewController
    userEditViewControl.communicationDelegate = commsDelegate
    sourceView.present(userEditViewControl, animated: true)
}

public func openPeople(_ sourceView: UIViewController)
{
    let peopleEditViewControl = personStoryboard.instantiateViewController(withIdentifier: "personForm") as! personViewController
    sourceView.present(peopleEditViewControl, animated: true)
}

//public func openMonthlyRoster(_ sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
//{
//    #if os(iOS)
//    let rosterViewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "monthlyRoster") as! monthlyRosterViewController
//    #else
//    let rosterViewControl = shiftsStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "monthlyRoster")) as! monthlyRosterViewController
//    #endif
//    rosterViewControl.communicationDelegate = commsDelegate
//    sourceView.present(rosterViewControl, animated: true)
//}

public func openReports(_ sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
{
    let reportsViewControl = reportsStoryboard.instantiateViewController(withIdentifier: "reportScreen") as! reportView
    reportsViewControl.communicationDelegate = commsDelegate
    sourceView.present(reportsViewControl, animated: true)
}

public func openComms(_ target: commsLogEntry, sourceView: UIViewController, commsDelegate: myCommunicationDelegate, button: UIButton, delegate: UIPopoverPresentationControllerDelegate)
{
//    let commsView = settingsStoryboard.instantiateViewController(withIdentifier: "commsLogView") as! commsLogView
//    commsView.modalPresentationStyle = .popover
//    
//    let popover = commsView.popoverPresentationController!
//    popover.delegate = delegate
//    popover.sourceView = button
//    popover.sourceRect = button.bounds
//    popover.permittedArrowDirections = .any
//    
//    commsView.preferredContentSize = CGSize(width: 500,height: 800)
//    commsView.workingEntry = target
//    sourceView.present(commsView, animated: true, completion: nil)
}

public func openUser(_ sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
{
//    #if os(iOS)
//    let loginViewControl = loginStoryboard.instantiateViewController(withIdentifier: "newInstance") as! newInstanceViewController
//    #else
//    let loginViewControl = loginStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "newInstance")) as! newInstanceViewController
//    #endif
//    loginViewControl.communicationDelegate = commsDelegate
//    sourceView.present(loginViewControl, animated: true)
}

public func openOrg(target: team?, sourceView:UIViewController, commsDelegate: myCommunicationDelegate)
{
    let orgEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "orgEdit") as! orgEditViewController
    orgEditViewControl.communicationDelegate = commsDelegate
    orgEditViewControl.workingOrganisation = target
    sourceView.present(orgEditViewControl, animated: true)
}

public func openUserForm(_ target: userItem, sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
{
    let userEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "userForm") as! userFormViewController
    userEditViewControl.workingUser = target
    userEditViewControl.communicationDelegate = commsDelegate
    userEditViewControl.initialUser = true
    sourceView.present(userEditViewControl, animated: true)
}

public func openPassword(_ sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
{
    let passwordViewControl = loginStoryboard.instantiateViewController(withIdentifier: "enterPassword") as! validatePasswordViewController
    passwordViewControl.communicationDelegate = commsDelegate
    sourceView.present(passwordViewControl, animated: true)
}

public func openMeeting(_ target: calendarItem!, sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
{
    let meetingView = meetingStoryboard.instantiateViewController(withIdentifier: "Meetings") as! meetingsViewController
    if target != nil
    {
        meetingView.passedMeeting = target
    }
    
    meetingView.delegate = commsDelegate
    sourceView.present(meetingView, animated: true)
}

public func openTask(_ target: task, sourceView: UIViewController, commsDelegate: myCommunicationDelegate, button: UIButton, delegate: UIPopoverPresentationControllerDelegate)
{
    let popoverContent = tasksStoryboard.instantiateViewController(withIdentifier: "tasks") as! taskViewController
    popoverContent.modalPresentationStyle = .popover
    let popover = popoverContent.popoverPresentationController
    popover!.delegate = delegate
    popover!.sourceView = button
    popover!.sourceRect = CGRect(x: 700,y: 700,width: 0,height: 0)
    
    popoverContent.passedTaskType = "minutes"
    popoverContent.passedTask = target
    
    popoverContent.preferredContentSize = CGSize(width: 700,height: 700)
    
    sourceView.present(popoverContent, animated: true, completion: nil)
}




public protocol mainScreenProtocol
{
    func reloadMenu()
    func loadShifts()
}

//extension coreDatabase
//{
//    func clearDeletedItems()
//    {
////        let predicate = NSPredicate(format: "(updateType == \"Delete\")")
////        
////        clearDeletedTeam(predicate: predicate)
//    }
//    
//    func clearSyncedItems()
//    {
////        let predicate = NSPredicate(format: "(updateType != \"\")")
////        
////        clearSyncedTeam(predicate: predicate)
//    }
//    
//    func deleteAllCoreData()
//    {
//        deleteAllTeamRecords()
//    }
//}
//
//extension CloudKitInteraction
//{
//    func setupSubscriptions()
//    {
//        // Setup notification
//
//        let sem = DispatchSemaphore(value: 0);
//
//        privateDB.fetchAllSubscriptions() { [unowned self] (subscriptions, error) -> Void in
//            if error == nil
//            {
//                if let subscriptions = subscriptions
//                {
//                    for subscription in subscriptions
//                    {
//                        self.privateDB.delete(withSubscriptionID: subscription.subscriptionID, completionHandler: { (str, error) -> Void in
//                            if error != nil
//                            {
//                                // do your error handling here!
//                                print(error!.localizedDescription)
//                            }
//                        })
//
//                    }
//                }
//            }
//            else
//            {
//                // do your error handling here!
//                print(error!.localizedDescription)
//            }
//            sem.signal()
//        }
//
//        sem.wait()
//
//        createSubscription("Team", sourceQuery: "teamID > -1")
//    }
//}
//
//extension DBSync
//{
//    func performSync()
//    {
//        syncTotal = 17
//        syncProgress = 0
//        
//        let syncDate = Date()
//
//        myCloudDB.saveOK = true
//        
//        myCloudDB.saveTeamToCloudKit()
//        myCloudDB.updateTeamInCoreData()
//        
//        if myCloudDB.saveOK
//        {
//            setSyncDateforTable(tableName: "Team", syncDate: syncDate)
//        }
//        
//        myCloudDB.saveOK = true
//        
//        syncProgress += 1
//        
//        sleep(syncTime)
//        
//        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
//        {
//            sleep(1)
//        }
//        
//        myCloudDB.saveDecodesToCloudKit()
//        myCloudDB.updatePublicDecodesInCoreData()
//        if myCloudDB.saveOK
//        {
//            setSyncDateforTable(tableName: "Decode", syncDate: syncDate)
//        }
//        
//        myCloudDB.saveOK = true
//        
//        syncProgress += 1
//        
//        sleep(syncTime)
//        
//        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
//        {
//            sleep(1)
//        }
//        
//        myCloudDB.saveAddressToCloudKit()
//        myCloudDB.updateAddressInCoreData()
//        if myCloudDB.saveOK
//        {
//            setSyncDateforTable(tableName: "Addresses", syncDate: syncDate)
//        }
//        
//        myCloudDB.saveOK = true
//        
//        syncProgress += 1
//        sleep(syncTime)
//        
//        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
//        {
//            sleep(1)
//        }
//        
//        myCloudDB.saveClientToCloudKit()
//        myCloudDB.updateClientInCoreData()
//        if myCloudDB.saveOK
//        {
//            setSyncDateforTable(tableName: "Clients", syncDate: syncDate)
//        }
//        
//        myCloudDB.saveOK = true
//        
//        syncProgress += 1
//        sleep(syncTime)
//        
//        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
//        {
//            sleep(1)
//        }
//        
//        myCloudDB.saveContactToCloudKit()
//        myCloudDB.updateContactInCoreData()
//        if myCloudDB.saveOK
//        {
//            setSyncDateforTable(tableName: "Contacts", syncDate: syncDate)
//        }
//        
//        myCloudDB.saveOK = true
//        
//        syncProgress += 1
//        sleep(syncTime)
//        
//        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
//        {
//            sleep(1)
//        }
//        
//        myCloudDB.saveDropdownsToCloudKit()
//        myCloudDB.updateDropdownsInCoreData()
//        if myCloudDB.saveOK
//        {
//            setSyncDateforTable(tableName: "Dropdowns", syncDate: syncDate)
//        }
//        
//        myCloudDB.saveOK = true
//        
//        syncProgress += 1
//        sleep(syncTime)
//        
//        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
//        {
//            sleep(1)
//        }
//        
//        myCloudDB.savePersonToCloudKit()
//        myCloudDB.updatePersonInCoreData()
//        if myCloudDB.saveOK
//        {
//            setSyncDateforTable(tableName: "Person", syncDate: syncDate)
//        }
//        
//        myCloudDB.saveOK = true
//        
//        syncProgress += 1
//        sleep(syncTime)
//        
//        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
//        {
//            sleep(1)
//        }
//        
//        myCloudDB.savePersonAdditionalInfoToCloudKit()
//        myCloudDB.updatePersonAdditionalInfoInCoreData()
//        if myCloudDB.saveOK
//        {
//            setSyncDateforTable(tableName: "PersonAdditionalInfo", syncDate: syncDate)
//        }
//        
//        myCloudDB.saveOK = true
//        
//        syncProgress += 1
//        sleep(syncTime)
//        
//        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
//        {
//            sleep(1)
//        }
//        
//        myCloudDB.savePersonAddInfoEntryToCloudKit()
//        myCloudDB.updatePersonAddInfoEntryInCoreData()
//        if myCloudDB.saveOK
//        {
//            setSyncDateforTable(tableName: "PersonAddInfoEntry", syncDate: syncDate)
//        }
//        
//        myCloudDB.saveOK = true
//        
//        syncProgress += 1
//        sleep(syncTime)
//        
//        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
//        {
//            sleep(1)
//        }
//        
//        myCloudDB.saveProjectsToCloudKit()
//        myCloudDB.updateProjectsInCoreData()
//        if myCloudDB.saveOK
//        {
//            setSyncDateforTable(tableName: "Projects", syncDate: syncDate)
//        }
//        
//        myCloudDB.saveOK = true
//        
//        syncProgress += 1
//        sleep(syncTime)
//        
//        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
//        {
//            sleep(1)
//        }
//        
//        myCloudDB.saveRatesToCloudKit()
//        myCloudDB.updateRatesInCoreData()
//        if myCloudDB.saveOK
//        {
//            setSyncDateforTable(tableName: "Rates", syncDate: syncDate)
//        }
//        
//        myCloudDB.saveOK = true
//        
//        syncProgress += 1
//        sleep(syncTime)
//        
//        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
//        {
//            sleep(1)
//        }
//        
//        myCloudDB.saveShiftsToCloudKit()
//        myCloudDB.updateShiftsInCoreData()
//        if myCloudDB.saveOK
//        {
//            setSyncDateforTable(tableName: "Shifts", syncDate: syncDate)
//        }
//        
//        myCloudDB.saveOK = true
//        
//        syncProgress += 1
//        sleep(syncTime)
//        
//        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
//        {
//            sleep(1)
//        }
//        
//        myCloudDB.saveUserRolesToCloudKit()
//        myCloudDB.updateUserRolesInCoreData()
//        if myCloudDB.saveOK
//        {
//            setSyncDateforTable(tableName: "UserRoles", syncDate: syncDate)
//        }
//        
//        myCloudDB.saveOK = true
//        
//        syncProgress += 1
//        sleep(syncTime)
//        
//        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
//        {
//            sleep(1)
//        }
//        
//        myCloudDB.saveEventTemplateToCloudKit()
//        myCloudDB.updateEventTemplateInCoreData()
//        if myCloudDB.saveOK
//        {
//            setSyncDateforTable(tableName: "EventTemplate", syncDate: syncDate)
//        }
//        
//        myCloudDB.saveOK = true
//        
//        syncProgress += 1
//        sleep(syncTime)
//        
//        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
//        {
//            sleep(1)
//        }
//        
//        myCloudDB.saveEventTemplateHeadToCloudKit()
//        myCloudDB.updateEventTemplateHeadInCoreData()
//        if myCloudDB.saveOK
//        {
//            setSyncDateforTable(tableName: "EventTemplateHead", syncDate: syncDate)
//        }
//        
//        myCloudDB.saveOK = true
//        
//        syncProgress += 1
//        sleep(syncTime)
//        
//        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
//        {
//            sleep(1)
//        }
//        
//        myCloudDB.saveUserTeamsToCloudKit()
//        myCloudDB.updateUserTeamsInCoreData()
//        if myCloudDB.saveOK
//        {
//            setSyncDateforTable(tableName: "UserTeams", syncDate: syncDate)
//        }
//        
//        myCloudDB.saveOK = true
//
//        syncProgress += 1
//        sleep(syncTime)
//        
//        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
//        {
//            sleep(1)
//        }
//
//        myCloudDB.saveReportsToCloudKit()
//        myCloudDB.updateReportsInCoreData()
//        if myCloudDB.saveOK
//        {
//            setSyncDateforTable(tableName: "Reports", syncDate: syncDate)
//        }
//        
//        myCloudDB.saveOK = true
//        
//        syncProgress += 1
//        sleep(syncTime)
//        
//        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
//        {
//            sleep(1)
//        }
//
//        syncProgress += 1
//        notificationCenter.post(name: NotificationCloudSyncFinished, object: nil)
//    }
//        
//    func deleteAllFromCloudKit()
//    {
///*        progressMessage("deleteAllFromCloudKit Team")
//        myCloudDB.deleteTeam()
//        
//        progressMessage("syncToCloudKit Decode")
//        myCloudDB.deletePrivateDecodes()
//        
//         progressMessage("syncToCloudKit Addresses")
//        myCloudDB.deleteAddresses()
//        
//         progressMessage("syncToCloudKit Clients")
//        myCloudDB.deleteClients()
//         
//        progressMessage("syncToCloudKit Contacts")
//        myCloudDB.deleteContacts)
//        
//         progressMessage("syncToCloudKit Dropdowns")
//        myCloudDB.deleteDropdowns()
//        
//         progressMessage("syncToCloudKit Person")
//        myCloudDB.deletePerson()
//        
//         progressMessage("syncToCloudKit PersonAdditionalInfo")
//        myCloudDB.deletePersonAdditionalInfo()
//        
//         progressMessage("syncToCloudKit PersonAdditionalItem")
//        myCloudDB.deletePersonAddInfoEntry()
//        
//         progressMessage("syncToCloudKit Projects")
//        myCloudDB.deleteProjects()
//        
//         progressMessage("syncToCloudKit Rates")
//        myCloudDB.deleteRates()
//        
//         progressMessage("syncToCloudKit ReportingMonth")
//        myCloudDB.deleteReportingMonth()
//        
//         progressMessage("syncToCloudKit Shifts")
//        myCloudDB.deleteShifts()
//        progressMessage("syncToCloudKit UserRoles")
//        myCloudDB.deleteUserRoles()
//        
//         progressMessage("syncToCloudKit ContractShifts")
//         myCloudDB.deleteContractShifts()   eventtemplate
//        
//         progressMessage("syncToCloudKit ContractShifts")
//         myCloudDB.deleteContractShifts() event template head
//         
//         progressMessage("syncToCloudKit ContractShifts")
//         myCloudDB.deleteContractShifts() user teams
//         
//   */
//        
//    }
//    
//}

public class displayMonthItem: NSObject, Identifiable
{
    public let id = UUID()
    var myprojectID: Int64 = 0
    var myprojectName: String = ""
    var mynumRoles: Int = 0
    var myWorkDate: Date!
    var myFullyDefined: Bool = true
    
    public var projectID: Int64
    {
        get
        {
            return myprojectID
        }
    }
    
    public var projectName: String
    {
        get
        {
            return myprojectName
        }
    }
    
    public var workDate: Date
    {
        get
        {
            return myWorkDate
        }
    }
    
    public var numRoles: Int
    {
        get
        {
            return mynumRoles
        }
    }
    
    public var fullyDefined: Bool
    {
        get
        {
            return myFullyDefined
        }
        set
        {
            myFullyDefined = newValue
        }
    }
    
    public func addRole()
    {
        mynumRoles += 1
    }
    
    public init(projectID: Int64, projectName: String, workDate: Date)
    {
        super.init()
        
        myprojectID = projectID
        myprojectName = projectName
        myWorkDate = workDate
        mynumRoles = 1
    }
}

public class cellDetails: NSObject
{
    fileprivate var myTag: Int = 0
    fileprivate var myTargetObject: AnyObject!
        fileprivate var myView: UIView!

    fileprivate var myHeadBody: String = ""
    fileprivate var myType: String = ""
    fileprivate var myFrame: CGRect!
    
    public var tag: Int
        {
        get
        {
            return myTag
        }
        set
        {
            myTag = newValue
        }
    }
    
    public var targetObject: AnyObject
        {
        get
        {
            return myTargetObject
        }
        set
        {
            myTargetObject = newValue
            
            if newValue is team
            {
                myType = "team"
            }
//            else if newValue is workingGTDItem
//            {
//                myType = "workingGTDItem"
//            }
            else if newValue is project
            {
                myType = "project"
            }
            else if newValue is task
            {
                myType = "task"
            }
//            else if newValue is context
//            {
//                myType = "context"
//            }
        }
    }

        public var displayView: UIView
        {
            get
            {
                return myView
            }
            set
            {
                myView = newValue
            }
        }
    
    public var headBody: String
        {
        get
        {
            return myHeadBody
        }
        set
        {
            myHeadBody = newValue
        }
    }
    
    public var type: String
        {
        get
        {
            return myType
        }
    }
    
    public var displayX: CGFloat
        {
        get
        {
            return myFrame.origin.x
        }
    }
    
    public var displayY: CGFloat
        {
        get
        {
            return myFrame.origin.y
        }
    }
    
    public var frame: CGRect
        {
        get
        {
            return myFrame
        }
        set
        {
            myFrame = newValue
        }
    }
}

public let emailDecodes = [["$$Name", "Full Name"],
                           ["$$FirstName", "First Name"],
                           ["$$Surname", "Surname"]]

public let menuWeeklyRoster = "Weekly Roster"
public let menuStaffInvoicing = "Staff Invoicing"
public let menuMonthlyRoster = "Monthly Roster"
public let menuClients = "Clients"
public let menuPeople = "People"
public let menuEventPlanning = "Event Planning"
public let menuEventTemplates = "Event Templates"
public let menuMonthlyBookings = "Monthly Bookings"
public let menuPerson = "person"
public let menuClient = "client"
public let menuProject = "project"
public let menuDashboard = "Dashboard"
public let menuRoster = "Roster"
public let menuCourse = "Course"
public let menuSales = "sales"
public let menuStaffToPay = "Staff To Pay"
public let menuClientInvoices = "Client Invoices"
public let menuCoachingInvoices = "Coaching Invoices"
public let menuInvoiceSettings = "Invoice Settings"
public let menuReports = "Reports"
public let menuNewComms = "New Communication"
public let menuSettings = "Settings"


public let selectPerson = "Select Person"
