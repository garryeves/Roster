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
    #if os(iOS)
    //let viewControl = invoiceStoryboard.instantiateViewController(withIdentifier: "staffInvoicingView") as! staffInvoicingViewController
    
    
    let split = invoiceStoryboard.instantiateViewController(withIdentifier: "personInvoiceSplit") as! UISplitViewController
    
    mainViewController = sourceView
    sourceView.view.window?.rootViewController = split

    #else
    let viewControl = invoiceStoryboard.instantiateViewController(withIdentifier: "staffInvoicingView") as! staffInvoicingViewController
        viewControl.communicationDelegate = commsDelegate
        sourceView.present(viewControl, animated: true)
    #endif
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
    #if os(iOS)
    let userEditViewControl = settingsStoryboard.instantiateViewController(withIdentifier: "settings") as! settingsViewController
    #else
    let userEditViewControl = settingsStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "settings")) as! settingsViewController
    #endif
    userEditViewControl.communicationDelegate = commsDelegate
    sourceView.present(userEditViewControl, animated: true)
}

public func openPeople(_ sourceView: UIViewController)
{
    #if os(iOS)
    let peopleEditViewControl = personStoryboard.instantiateViewController(withIdentifier: "personForm") as! personViewController
    #else
    let peopleEditViewControl = personStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "personForm")) as! personViewController
    #endif
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
    #if os(iOS)
    let reportsViewControl = reportsStoryboard.instantiateViewController(withIdentifier: "reportScreen") as! reportView
    #else
    let reportsViewControl = reportsStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "reportScreen")) as! reportView
    #endif
    reportsViewControl.communicationDelegate = commsDelegate
    sourceView.present(reportsViewControl, animated: true)
}

#if os(iOS)
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
#else
public func openComms(_ target: commsLogEntry, sourceView: NSViewController, commsDelegate: myCommunicationDelegate, button: NSButton)
{
    let commsView = settingsStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "commsLogView")) as! commsLogView
    commsView.workingEntry = target
    sourceView.presentViewControllerAsSheet(commsView)
}
#endif

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
    #if os(iOS)
    let orgEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "orgEdit") as! orgEditViewController
    #else
    let orgEditViewControl = loginStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "orgEdit")) as! orgEditViewController
    #endif
    orgEditViewControl.communicationDelegate = commsDelegate
    orgEditViewControl.workingOrganisation = target
    sourceView.present(orgEditViewControl, animated: true)
}

public func openUserForm(_ target: userItem, sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
{
    #if os(iOS)
    let userEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "userForm") as! userFormViewController
    #else
    let userEditViewControl = loginStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "userForm")) as! userFormViewController
    #endif
    userEditViewControl.workingUser = target
    userEditViewControl.communicationDelegate = commsDelegate
    userEditViewControl.initialUser = true
    sourceView.present(userEditViewControl, animated: true)
}

public func openPassword(_ sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
{
    #if os(iOS)
    let passwordViewControl = loginStoryboard.instantiateViewController(withIdentifier: "enterPassword") as! validatePasswordViewController
    #else
    let passwordViewControl = loginStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "enterPassword")) as! validatePasswordViewController
    #endif
    passwordViewControl.communicationDelegate = commsDelegate
    sourceView.present(passwordViewControl, animated: true)
}

public func openMeeting(_ target: calendarItem!, sourceView: UIViewController, commsDelegate: myCommunicationDelegate)
{
    #if os(iOS)
    let meetingView = meetingStoryboard.instantiateViewController(withIdentifier: "Meetings") as! meetingsViewController
    #else
    let meetingView = meetingStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Meetings")) as! meetingsViewController
    #endif
    if target != nil
    {
        meetingView.passedMeeting = target
    }
    
    meetingView.delegate = commsDelegate
    sourceView.present(meetingView, animated: true)
}

#if os(iOS)
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
#else
public func openTask(_ target: task, sourceView: NSViewController, commsDelegate: myCommunicationDelegate, button: NSButton)
{
    let popoverContent = tasksStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "tasks")) as! taskViewController
    popoverContent.passedTaskType = "minutes"
    popoverContent.passedTask = target
    sourceView.presentViewControllerAsSheet(popoverContent)
}
#endif



public protocol mainScreenProtocol
{
    func reloadMenu()
    func loadShifts()
}

public struct teamOwnerItem
{
    var userID: Int64
    var name: String
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
