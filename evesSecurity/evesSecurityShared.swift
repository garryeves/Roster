//
//  evesSecurityShared.swift
//  evesSecurity
//
//  Created by Garry Eves on 9/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import SwiftUI
import EventKit

public let coreDatabaseName = "EvesCRM"
public var appName = ""

public var userName: String = ""
public var userEmail: String = ""

public var mainViewController: UIViewController!

public let saveDelay: UInt32 = 2

public let NoStageLabel = "No stage"

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

//struct TextView: UIViewRepresentable {
//    @Binding var text: String
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIView(context: Context) -> UITextView {
//
//        let myTextView = UITextView()
//        myTextView.delegate = context.coordinator
//
//        myTextView.font = UIFont(name: "HelveticaNeue", size: 15)
//        myTextView.isScrollEnabled = true
//        myTextView.isEditable = true
//        myTextView.isUserInteractionEnabled = true
//        myTextView.backgroundColor = UIColor(white: 0.0, alpha: 0.05)
//
//        return myTextView
//    }
//
//    func updateUIView(_ uiView: UITextView, context: Context) {
//        uiView.text = text
//    }
//
//    class Coordinator : NSObject, UITextViewDelegate {
//
//        var parent: TextView
//
//        init(_ uiTextView: TextView) {
//            self.parent = uiTextView
//        }
//
//        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//            return true
//        }
//
//        func textViewDidChange(_ textView: UITextView) {
//            self.parent.text = textView.text
//        }
//    }
//}






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
public var currentUser : userItem!

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

struct emailDecodeEntries: Identifiable {
    let id = UUID()
    
    var decodeType: String
    var decodeValue : String
}

let emailDecodes = [emailDecodeEntries(decodeType: "$$Name", decodeValue: "Full Name"),
                    emailDecodeEntries(decodeType: "$$FirstName", decodeValue: "First Name"),
                    emailDecodeEntries(decodeType: "$$Surname", decodeValue: "Surname")
                    ]

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
