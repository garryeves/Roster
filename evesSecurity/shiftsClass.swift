//
//  shiftsClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 11/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
//import CoreData
import CloudKit
import SwiftUI
import Combine

public protocol shiftLoadDelegate
{
    func refreshScreen()
}

public let alertShiftNoPersonOrRate = "shifts no person or rate"
public let alertShiftNoPerson = "shifts no person"
public let alertShiftNoRate = "shifts no rate"

public let shiftStatusOpen = "Open"
public let shiftStatusOpenNotDup = "Open not dup"
public let shiftStatusClosed = "Closed"
public let shiftStatusClosedNotDup = "Closed not dup"


class mergedShiftList: Identifiable, ObservableObject
{
    public let id = UUID()
    var contract: String!
    var clientName: String!
    var projectID: Int64!
    var description: String!
    var WEDate: Date!
    var shiftLineID: Int64!
    var monShift: shift!
    var tueShift: shift!
    var wedShift: shift!
    var thuShift: shift!
    var friShift: shift!
    var satShift: shift!
    var sunShift: shift!
    var type: String!
    
    init(incontract: String,
         inclientName: String,
    inprojectID: Int64,
    indescription: String,
    inWEDate: Date,
    inshiftLineID: Int64,
    inmonShift: shift?,
    intueShift: shift?,
    inwedShift: shift?,
    inthuShift: shift?,
    infriShift: shift?,
    insatShift: shift?,
    insunShift: shift?,
    intype: String) {
        contract = incontract
        clientName = inclientName
        projectID = inprojectID
        description = indescription
        WEDate = inWEDate
        shiftLineID = inshiftLineID
        monShift = inmonShift
        tueShift = intueShift
        wedShift = inwedShift
        thuShift = inthuShift
        friShift = infriShift
        satShift = insatShift
        sunShift = insunShift
        type = intype
    }

}

class rosterPerson: NSObject, Identifiable
{
    public let id = UUID()
    var personName: String = ""
    var numHours: Int = 0
    var numMins: Int = 0
    
    public init(passPersonName: String,
                passNumHours: Int,
                passNumMins: Int)
    {
        personName = passPersonName
        numHours = passNumHours
        numMins = passNumMins
    }
}

class shifts: NSObject, Identifiable, ObservableObject
{
    public let id = UUID()
    fileprivate var myShifts:[shift] = Array()
    fileprivate var myWeeklyShifts:[mergedShiftList] = Array()
    var myTeamID: Int64 = 0
    
    init(teamID: Int64, WEDate: Date, type: String)
    {
        super.init()
        myTeamID = teamID
        myWeeklyShifts.removeAll()
        
        if currentUser.currentTeam!.ShiftList == nil
        {
            currentUser.currentTeam?.loadShifts(nil)
        }
        
        let startDate =  WEDate.startOfDay  // calendar.startOfDay(for: WEDate)
        // get the start of the day after the selected date
        let endDate = startDate.add(.day, amount: 1)  // calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        var returnArray: [Shifts] = Array()
        
        for item in (currentUser.currentTeam?.ShiftList)!
        {
            let tempEnd = item.weekEndDate!.add(.hour, amount: 1).startOfDay
            
            //if (item.weekEndDate! >= startDate) && (item.weekEndDate! <= endDate) && (item.type! == type)
            if (tempEnd >= startDate) && (tempEnd <= endDate) && (item.type! == type)
            {
                returnArray.append(item)
            }
        }
        for myItem in returnArray
        {
            let myObject = shift(shiftID: myItem.shiftID,
                                 projectID: myItem.projectID,
                                 personID: myItem.personID,
                                 workDate: myItem.workDate! as Date,
                                 shiftDescription: myItem.shiftDescription!,
                                 startTime: myItem.startTime,
                                 endTime: myItem.endTime,
                                 teamID: myItem.teamID,
                                 weekEndDate: myItem.weekEndDate! as Date,
                                 status: myItem.status!,
                                 shiftLineID: myItem.shiftLineID,
                                 rateID: myItem.rateID,
                                 type: myItem.type!,
                                 clientInvoiceNumber: myItem.clientInvoiceNumber,
                                 personInvoiceNumber: myItem.personInvoiceNumber,
                                 signInTime: myItem.signInTime,
                                 signOutTime: myItem.signOutTime,
                                 recordID: myItem.recordID
            )
            
            myShifts.append(myObject)
        }
        
        if myShifts.count > 0
        {
            createWeeklyArray()
        }
        
        sortArray()
    }
    
    init(teamID: Int64)
    {
        super.init()
        
        myTeamID = teamID
        myWeeklyShifts.removeAll()
        
        if currentUser.currentTeam!.ShiftList == nil
        {
            currentUser.currentTeam?.loadShifts(nil)
        }
        
        for myItem in (currentUser.currentTeam?.ShiftList!)!
        {
            let myObject = shift(shiftID: myItem.shiftID,
                                 projectID: myItem.projectID,
                                 personID: myItem.personID,
                                 workDate: myItem.workDate! as Date,
                                 shiftDescription: myItem.shiftDescription!,
                                 startTime: myItem.startTime,
                                 endTime: myItem.endTime,
                                 teamID: myItem.teamID,
                                 weekEndDate: myItem.weekEndDate! as Date,
                                 status: myItem.status!,
                                 shiftLineID: myItem.shiftLineID,
                                 rateID: myItem.rateID,
                                 type: myItem.type!,
                                 clientInvoiceNumber: myItem.clientInvoiceNumber,
                                 personInvoiceNumber: myItem.personInvoiceNumber,
                                 signInTime: myItem.signInTime,
                                 signOutTime: myItem.signOutTime,
                                 recordID: myItem.recordID
            )
            myShifts.append(myObject)
        }
        
        if myShifts.count > 0
        {
            createWeeklyArray()
        }
        
        currentUser.currentTeam?.reloadShiftData = true
        
        sortArray()
    }
    
    init(teamID: Int64, WEDate: Date, includeEvents: Bool = false)
    {
        super.init()
        myTeamID = teamID
        myWeeklyShifts.removeAll()
        
        if currentUser.currentTeam!.ShiftList == nil
        {
            currentUser.currentTeam?.loadShifts(nil)
        }
        
        let startDate = WEDate.startOfDay  //  calendar.startOfDay(for: WEDate)
        // get the start of the day after the selected date
        let endDate = startDate.add(.day, amount: 1)  //calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var returnArray: [Shifts] = Array()
        
        for item in (currentUser.currentTeam?.ShiftList!)!
        {
            let tempEnd = item.weekEndDate!.add(.hour, amount: 1).startOfDay
            
            if includeEvents
            {
                //                if (item.weekEndDate! >= startDate) && (item.weekEndDate! <= endDate)
                if (tempEnd >= startDate) && (tempEnd <= endDate)
                {
                    returnArray.append(item)
                }
            }
            else
            {
                //                if (item.weekEndDate! >= startDate) && (item.weekEndDate! <= endDate) && (item.type! != eventShiftType)
                if (tempEnd >= startDate) && (tempEnd <= endDate) && (item.type! != eventShiftType)
                {
                    returnArray.append(item)
                }
            }
        }
        
        for myItem in returnArray
        {
            let myObject = shift(shiftID: myItem.shiftID,
                                 projectID: myItem.projectID,
                                 personID: myItem.personID,
                                 workDate: myItem.workDate! as Date,
                                 shiftDescription: myItem.shiftDescription!,
                                 startTime: myItem.startTime,
                                 endTime: myItem.endTime,
                                 teamID: myItem.teamID,
                                 weekEndDate: myItem.weekEndDate! as Date,
                                 status: myItem.status!,
                                 shiftLineID: myItem.shiftLineID,
                                 rateID: myItem.rateID,
                                 type: myItem.type!,
                                 clientInvoiceNumber: myItem.clientInvoiceNumber,
                                 personInvoiceNumber: myItem.personInvoiceNumber,
                                 signInTime: myItem.signInTime,
                                 signOutTime: myItem.signOutTime,
                                 recordID: myItem.recordID
            )
            myShifts.append(myObject)
        }
        
        if myShifts.count > 0
        {
            createWeeklyArray()
        }
        
        sortArray()
    }
    
    init(teamID: Int64, month: Int, year: Int)
    {
        super.init()
        myTeamID = teamID
        myWeeklyShifts.removeAll()
        
        if currentUser.currentTeam!.ShiftList == nil
        {
            currentUser.currentTeam?.loadShifts(nil)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd M yyyy"
        
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        
        let dateString = "01 \(month) \(year)"
        let calculatedDate = dateFormatter.date(from: dateString)
        
        let startDate = calculatedDate!.add(.hour, amount: 1).startOfDay   //    calendar.startOfDay(for: calculatedDate!)
        // get the start of the day after the selected date
        let endDate = startDate.add(.month, amount: 1)  //  calendar.date(byAdding: .month, value: 1, to: startDate)!
        
        
        var returnArray: [Shifts] = Array()
        
        for item in (currentUser.currentTeam?.ShiftList!)!
        {
            if (item.workDate! >= startDate) && (item.workDate! <= endDate)
            {
                returnArray.append(item)
            }
        }
        
        for myItem in returnArray
        {
            let myObject = shift(shiftID: myItem.shiftID,
                                 projectID: myItem.projectID,
                                 personID: myItem.personID,
                                 workDate: myItem.workDate! as Date,
                                 shiftDescription: myItem.shiftDescription!,
                                 startTime: myItem.startTime,
                                 endTime: myItem.endTime,
                                 teamID: myItem.teamID,
                                 weekEndDate: myItem.weekEndDate! as Date,
                                 status: myItem.status!,
                                 shiftLineID: myItem.shiftLineID,
                                 rateID: myItem.rateID,
                                 type: myItem.type!,
                                 clientInvoiceNumber: myItem.clientInvoiceNumber,
                                 personInvoiceNumber: myItem.personInvoiceNumber,
                                 signInTime: myItem.signInTime,
                                 signOutTime: myItem.signOutTime,
                                 recordID: myItem.recordID
            )
            myShifts.append(myObject)
        }
        
        if myShifts.count > 0
        {
            createWeeklyArray()
        }
        
        sortArray()
    }
    
    init(projectID: Int64, startDate: Date, endDate: Date, teamID: Int64)
    {
        super.init()
        myTeamID = teamID
        myWeeklyShifts.removeAll()
        
        if currentUser.currentTeam!.ShiftList == nil
        {
            currentUser.currentTeam?.loadShifts(nil)
        }
        
        var returnArray: [Shifts] = Array()
        
        for item in (currentUser.currentTeam?.ShiftList!)!
        {
            let tempEnd = item.workDate!.add(.hour, amount: 1).startOfDay
            if (item.projectID == projectID) && (tempEnd >= startDate) && (tempEnd <= endDate)
            {
                returnArray.append(item)
            }
        }
        
        for myItem in returnArray
        {
            let myObject = shift(shiftID: myItem.shiftID,
                                 projectID: myItem.projectID,
                                 personID: myItem.personID,
                                 workDate: myItem.workDate! as Date,
                                 shiftDescription: myItem.shiftDescription!,
                                 startTime: myItem.startTime,
                                 endTime: myItem.endTime,
                                 teamID: myItem.teamID,
                                 weekEndDate: myItem.weekEndDate! as Date,
                                 status: myItem.status!,
                                 shiftLineID: myItem.shiftLineID,
                                 rateID: myItem.rateID,
                                 type: myItem.type!,
                                 clientInvoiceNumber: myItem.clientInvoiceNumber,
                                 personInvoiceNumber: myItem.personInvoiceNumber,
                                 signInTime: myItem.signInTime,
                                 signOutTime: myItem.signOutTime,
                                 recordID: myItem.recordID
            )
            myShifts.append(myObject)
        }
        
        if myShifts.count > 0
        {
            createWeeklyArray()
        }
        
        sortArray()
    }
    
    init(projectID: Int64, month: String, year: String, teamID: Int64)
    {
        super.init()
        myTeamID = teamID
        myWeeklyShifts.removeAll()
        
        if currentUser.currentTeam!.ShiftList == nil
        {
            currentUser.currentTeam?.loadShifts(nil)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        
        let dateString = "01 \(month) \(year)"
        let calculatedDate = dateFormatter.date(from: dateString)
        
        let startDate = calculatedDate!.add(.hour, amount: 1).startOfDay // calendar.startOfDay(for: calculatedDate!)
        // get the start of the day after the selected date
        let endDate = startDate.add(.month, amount: 1) // calendar.date(byAdding: .month, value: 1, to: startDate)!
        
        var returnArray: [Shifts] = Array()
        
        for item in (currentUser.currentTeam?.ShiftList!)!
        {
            if (item.projectID == projectID) && (item.workDate! >= startDate) && (item.workDate! <= endDate)
            {
                returnArray.append(item)
            }
        }
        
        for myItem in returnArray
        {
            let myObject = shift(shiftID: myItem.shiftID,
                                 projectID: myItem.projectID,
                                 personID: myItem.personID,
                                 workDate: myItem.workDate! as Date,
                                 shiftDescription: myItem.shiftDescription!,
                                 startTime: myItem.startTime,
                                 endTime: myItem.endTime,
                                 teamID: myItem.teamID,
                                 weekEndDate: myItem.weekEndDate! as Date,
                                 status: myItem.status!,
                                 shiftLineID: myItem.shiftLineID,
                                 rateID: myItem.rateID,
                                 type: myItem.type!,
                                 clientInvoiceNumber: myItem.clientInvoiceNumber,
                                 personInvoiceNumber: myItem.personInvoiceNumber,
                                 signInTime: myItem.signInTime,
                                 signOutTime: myItem.signOutTime,
                                 recordID: myItem.recordID
            )
            myShifts.append(myObject)
        }
        
        if myShifts.count > 0
        {
            createWeeklyArray()
        }
        
        sortArray()
    }
    
    init(clientID: Int64, month: String, year: String, teamID: Int64)
    {
        super.init()
        myTeamID = teamID
        myWeeklyShifts.removeAll()
        
        if currentUser.currentTeam!.ShiftList == nil
        {
            currentUser.currentTeam?.loadShifts(nil)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        
        let dateString = "01 \(month) \(year)"
        let calculatedDate = dateFormatter.date(from: dateString)
        
        let startDate = calculatedDate!.add(.hour, amount: 1).startOfDay // calendar.startOfDay(for: calculatedDate!)
        // get the start of the day after the selected date
        let endDate = startDate.add(.month, amount: 1) // calendar.date(byAdding: .month, value: 1, to: startDate)!
        
        var returnArray: [Shifts] = Array()
        
        for projectItem in projects(clientID: clientID, teamID: teamID, isActive: false).projectList
        {
            for item in (currentUser.currentTeam?.ShiftList!)!
            {
                if (item.projectID == projectItem.projectID) && (item.workDate! >= startDate) && (item.workDate! <= endDate)
                {
                    returnArray.append(item)
                }
            }
        }
        
        for myItem in returnArray
        {
            let myObject = shift(shiftID: myItem.shiftID,
                                 projectID: myItem.projectID,
                                 personID: myItem.personID,
                                 workDate: myItem.workDate! as Date,
                                 shiftDescription: myItem.shiftDescription!,
                                 startTime: myItem.startTime,
                                 endTime: myItem.endTime,
                                 teamID: myItem.teamID,
                                 weekEndDate: myItem.weekEndDate! as Date,
                                 status: myItem.status!,
                                 shiftLineID: myItem.shiftLineID,
                                 rateID: myItem.rateID,
                                 type: myItem.type!,
                                 clientInvoiceNumber: myItem.clientInvoiceNumber,
                                 personInvoiceNumber: myItem.personInvoiceNumber,
                                 signInTime: myItem.signInTime,
                                 signOutTime: myItem.signOutTime,
                                 recordID: myItem.recordID
            )
            myShifts.append(myObject)
        }
        
        if myShifts.count > 0
        {
            createWeeklyArray()
        }
        
        sortArray()
    }
    
    init(personID: Int64, searchFrom: Date, searchTo: Date, teamID: Int64, type: String)
    {
        super.init()
        myTeamID = teamID
        myWeeklyShifts.removeAll()
        
        if currentUser.currentTeam!.ShiftList == nil
        {
            currentUser.currentTeam?.loadShifts(nil)
        }
        
        var returnArray: [Shifts] = Array()
        
        for item in (currentUser.currentTeam?.ShiftList!)!
        {
            let tempEnd = item.workDate!.add(.hour, amount: 1).startOfDay
            
            if type == ""
            {
                //if (item.personID == personID) && (item.workDate! >= searchFrom) && (item.workDate! < searchTo)
                if (item.personID == personID) && (tempEnd >= searchFrom) && (tempEnd < searchTo)
                {
                    returnArray.append(item)
                }
            }
            else
            {
                //if (item.personID == personID) && (item.workDate! >= searchFrom) && (item.workDate! < searchTo) && (item.type == type)
                if (item.personID == personID) && (tempEnd >= searchFrom) && (tempEnd < searchTo) && (item.type == type)
                {
                    returnArray.append(item)
                }
            }
        }
        
        for myItem in returnArray
        {
            let myObject = shift(shiftID: myItem.shiftID,
                                 projectID: myItem.projectID,
                                 personID: myItem.personID,
                                 workDate: myItem.workDate! as Date,
                                 shiftDescription: myItem.shiftDescription!,
                                 startTime: myItem.startTime,
                                 endTime: myItem.endTime,
                                 teamID: myItem.teamID,
                                 weekEndDate: myItem.weekEndDate! as Date,
                                 status: myItem.status!,
                                 shiftLineID: myItem.shiftLineID,
                                 rateID: myItem.rateID,
                                 type: myItem.type!,
                                 clientInvoiceNumber: myItem.clientInvoiceNumber,
                                 personInvoiceNumber: myItem.personInvoiceNumber,
                                 signInTime: myItem.signInTime,
                                 signOutTime: myItem.signOutTime,
                                 recordID: myItem.recordID
                
            )
            myShifts.append(myObject)
        }
        
        if myShifts.count > 0
        {
            createWeeklyArray()
        }
        
        sortArray()
    }
    
    init(projectID: Int64, searchFrom: Date, searchTo: Date, teamID: Int64, type: String)
    {
        super.init()
        myTeamID = teamID
        myWeeklyShifts.removeAll()
        
        if currentUser.currentTeam!.ShiftList == nil
        {
            currentUser.currentTeam?.loadShifts(nil)
        }
        
        var returnArray: [Shifts] = Array()
        
        for item in (currentUser.currentTeam?.ShiftList!)!
        {
            let tempEnd = item.workDate!.add(.hour, amount: 1).startOfDay
            if type == ""
            {
                if (item.projectID == projectID) && (tempEnd >= searchFrom) && (tempEnd <= searchTo)
                {
                    returnArray.append(item)
                }
            }
            else
            {
                if (item.projectID == projectID) && (tempEnd >= searchFrom) && (tempEnd <= searchTo) && (item.type == type)
                {
                    returnArray.append(item)
                }
            }
        }
        
        for myItem in returnArray
        {
            let myObject = shift(shiftID: myItem.shiftID,
                                 projectID: myItem.projectID,
                                 personID: myItem.personID,
                                 workDate: myItem.workDate! as Date,
                                 shiftDescription: myItem.shiftDescription!,
                                 startTime: myItem.startTime,
                                 endTime: myItem.endTime,
                                 teamID: myItem.teamID,
                                 weekEndDate: myItem.weekEndDate! as Date,
                                 status: myItem.status!,
                                 shiftLineID: myItem.shiftLineID,
                                 rateID: myItem.rateID,
                                 type: myItem.type!,
                                 clientInvoiceNumber: myItem.clientInvoiceNumber,
                                 personInvoiceNumber: myItem.personInvoiceNumber,
                                 signInTime: myItem.signInTime,
                                 signOutTime: myItem.signOutTime,
                                 recordID: myItem.recordID
                
            )
            myShifts.append(myObject)
        }
        
        if myShifts.count > 0
        {
            createWeeklyArray()
        }
        
        sortArray()
    }
    
    init(projectID: Int64, teamID: Int64)
    {
        super.init()
        myTeamID = teamID
        myWeeklyShifts.removeAll()
        
        let data = myCloudDB.getShifts(projectID: projectID, teamID: teamID)
        
        for myItem in data
        {
            let myObject = shift(shiftID: myItem.shiftID,
                                 projectID: myItem.projectID,
                                 personID: myItem.personID,
                                 workDate: myItem.workDate! as Date,
                                 shiftDescription: myItem.shiftDescription!,
                                 startTime: myItem.startTime,
                                 endTime: myItem.endTime,
                                 teamID: myItem.teamID,
                                 weekEndDate: myItem.weekEndDate! as Date,
                                 status: myItem.status!,
                                 shiftLineID: myItem.shiftLineID,
                                 rateID: myItem.rateID,
                                 type: myItem.type!,
                                 clientInvoiceNumber: myItem.clientInvoiceNumber,
                                 personInvoiceNumber: myItem.personInvoiceNumber,
                                 signInTime: myItem.signInTime,
                                 signOutTime: myItem.signOutTime,
                                 recordID: myItem.recordID
                
            )
            myShifts.append(myObject)
        }
        
        if myShifts.count > 0
        {
            createWeeklyArray()
        }
        
        sortArray()
    }
    
    init(personID: Int64, teamID: Int64)
    {
        super.init()
        myTeamID = teamID
        myWeeklyShifts.removeAll()
        
        if currentUser.currentTeam!.ShiftList == nil
        {
            currentUser.currentTeam?.loadShifts(nil)
        }
        
        var returnArray: [Shifts] = Array()
        
        for item in (currentUser.currentTeam?.ShiftList!)!
        {
            if (item.personID == personID)
            {
                returnArray.append(item)
            }
        }
        
        for myItem in returnArray
        {
            let myObject = shift(shiftID: myItem.shiftID,
                                 projectID: myItem.projectID,
                                 personID: myItem.personID,
                                 workDate: myItem.workDate! as Date,
                                 shiftDescription: myItem.shiftDescription!,
                                 startTime: myItem.startTime,
                                 endTime: myItem.endTime,
                                 teamID: myItem.teamID,
                                 weekEndDate: myItem.weekEndDate! as Date,
                                 status: myItem.status!,
                                 shiftLineID: myItem.shiftLineID,
                                 rateID: myItem.rateID,
                                 type: myItem.type!,
                                 clientInvoiceNumber: myItem.clientInvoiceNumber,
                                 personInvoiceNumber: myItem.personInvoiceNumber,
                                 signInTime: myItem.signInTime,
                                 signOutTime: myItem.signOutTime,
                                 recordID: myItem.recordID
                
            )
            myShifts.append(myObject)
        }
        
        if myShifts.count > 0
        {
            createWeeklyArray()
        }
        
        sortArray()
    }
    
    init(query: String, teamID: Int64)
    {
        super.init()
        myTeamID = teamID
        myShifts.removeAll()
        
        if currentUser.currentTeam!.ShiftList == nil
        {
            currentUser.currentTeam?.loadShifts(nil)
        }
        
        var returnArray: [Shifts]! = Array()
        switch query
        {
        case alertShiftNoPersonOrRate:
            for item in currentUser.currentTeam!.ShiftList!
            {
                if (item.personID == 0) && (item.rateID == 0)
                {
                    returnArray.append(item)
                }
            }
            
        case alertShiftNoPerson:
            for item in currentUser.currentTeam!.ShiftList!
            {
                if (item.personID == 0) && (item.rateID != 0)
                {
                    returnArray.append(item)
                }
            }
            
        case alertShiftNoRate:
            for item in currentUser.currentTeam!.ShiftList!
            {
                if (item.personID != 0) && (item.rateID != 0)
                {
                    returnArray.append(item)
                }
            }
            
            returnArray = Array()
            
            for item in (currentUser.currentTeam?.ShiftList)!
            {
                if (item.personID != 0) && (item.rateID == 0)
                {
                    returnArray.append(item)
                }
            }
            
        default:
            let _ = 1
        }
        
        if returnArray != nil
        {
            for myItem in returnArray
            {
                let myObject = shift(shiftID: myItem.shiftID,
                                     projectID: myItem.projectID,
                                     personID: myItem.personID,
                                     workDate: myItem.workDate! as Date,
                                     shiftDescription: myItem.shiftDescription!,
                                     startTime: myItem.startTime,
                                     endTime: myItem.endTime,
                                     teamID: myItem.teamID,
                                     weekEndDate: myItem.weekEndDate! as Date,
                                     status: myItem.status!,
                                     shiftLineID: myItem.shiftLineID,
                                     rateID: myItem.rateID,
                                     type: myItem.type!,
                                     clientInvoiceNumber: myItem.clientInvoiceNumber,
                                     personInvoiceNumber: myItem.personInvoiceNumber,
                                     signInTime: myItem.signInTime,
                                     signOutTime: myItem.signOutTime,
                                     recordID: myItem.recordID
                    
                )
                myShifts.append(myObject)
            }
            
            if myShifts.count > 0
            {
                createWeeklyArray()
            }
            
            sortArray()
        }
    }
    
    init(invoiceID: Int64, teamID: Int64)
    {
        super.init()
        myTeamID = teamID
        
        if currentUser.currentTeam!.ShiftList == nil
        {
            currentUser.currentTeam?.loadShifts(nil)
        }
        
        for item in (currentUser.currentTeam?.ShiftList!)!
        {
            if item.clientInvoiceNumber == invoiceID
            {
                let myObject = shift(shiftID: item.shiftID,
                                     projectID: item.projectID,
                                     personID: item.personID,
                                     workDate: item.workDate! as Date,
                                     shiftDescription: item.shiftDescription!,
                                     startTime: item.startTime,
                                     endTime: item.endTime,
                                     teamID: item.teamID,
                                     weekEndDate: item.weekEndDate! as Date,
                                     status: item.status!,
                                     shiftLineID: item.shiftLineID,
                                     rateID: item.rateID,
                                     type: item.type!,
                                     clientInvoiceNumber: item.clientInvoiceNumber,
                                     personInvoiceNumber: item.personInvoiceNumber,
                                     signInTime: item.signInTime,
                                     signOutTime: item.signOutTime,
                                     recordID: item.recordID
                )
                myShifts.append(myObject)
            }
        }
        
        sortArray()
    }
    
    public func sortArray()
    {
        if myShifts.count > 0
        {
            myShifts.sort
                {
                    // Because workdate has time it throws everything out
                    
                    if $0.workDate == $1.workDate
                    {
                        if $0.shiftDescription == $1.shiftDescription
                        {
                            if $0.startTimeString == $1.startTimeString
                            {
                                return $0.personName < $1.personName
                            }
                            else
                            {
                                return $0.startTimeString < $1.startTimeString
                            }
                        }
                        else
                        {
                            return $0.shiftDescription < $1.shiftDescription
                        }
                    }
                    else
                    {
                        return $0.workDate < $1.workDate
                    }
            }
        }
    }
    
    public func sortArrayByName()
    {
        if myShifts.count > 0
        {
            myShifts.sort
                {
                    // Because workdate has time it throws everything out
                    
                    if $0.personName == $1.personName
                    {
                        if $0.workDate == $1.workDate
                        {
                            if $0.startTimeString == $1.startTimeString
                            {
                                return $0.workDate < $1.workDate
                            }
                            else
                            {
                                return $0.startTimeString < $1.startTimeString
                            }
                        }
                        else
                        {
                            return $0.shiftDescription < $1.shiftDescription
                        }
                    }
                    else
                    {
                        return $0.personName < $1.personName
                    }
            }
        }
    }
    
    public func sortArrayByContract()
    {
        if myShifts.count > 0
        {
            myShifts.sort
                {
                    // Because workdate has time it throws everything out
                    
                    if $0.projectName == $1.projectName
                    {
                        if $0.workDate == $1.workDate
                        {
                            if $0.startTimeString == $1.startTimeString
                            {
                                return $0.workDate < $1.workDate
                            }
                            else
                            {
                                return $0.startTimeString < $1.startTimeString
                            }
                        }
                        else
                        {
                            return $0.shiftDescription < $1.shiftDescription
                        }
                    }
                    else
                    {
                        return $0.projectName < $1.projectName
                    }
            }
        }
    }
    
    private func createWeeklyArray()
    {
        // sort the array by week, contract, line ID
        
        if myShifts.count > 0
        {
            myShifts.sort
                {
                    // Because workdate has time it throws everything out
                    
                    if $0.projectID == $1.projectID
                    {
                        if $0.shiftLineID == $1.shiftLineID
                        {
                            return $0.workDate < $1.workDate
                        }
                        else
                        {
                            return $0.shiftLineID < $1.shiftLineID
                        }
                    }
                    else
                    {
                        return $0.projectID < $1.projectID
                    }
            }
        }
        
        // now we iterate through the array and build the weekly array
        var contract: String!
        var clientName: String!
        var projectID: Int64!
        var description: String!
        var WEDate: Date!
        var shiftLineID: Int64!
        var type: String!
        
        var monShift: shift!
        var tueShift: shift!
        var wedShift: shift!
        var thuShift: shift!
        var friShift: shift!
        var satShift: shift!
        var sunShift: shift!
        
        myWeeklyShifts.removeAll()
        
        for myItem in myShifts
        {
            if shiftLineID != nil
            {
                if shiftLineID != myItem.shiftLineID
                {
                    // Thus is a new week
                    let tempShift = mergedShiftList(incontract: contract,
                                                    inclientName: clientName,
                                                    inprojectID: projectID,
                                                    indescription: description,
                                                    inWEDate: WEDate,
                                                    inshiftLineID: shiftLineID,
                                                    inmonShift: monShift,
                                                    intueShift: tueShift,
                                                    inwedShift: wedShift,
                                                    inthuShift: thuShift,
                                                    infriShift: friShift,
                                                    insatShift: satShift,
                                                    insunShift: sunShift,
                                                    intype: type
                    )
                    
                    myWeeklyShifts.append(tempShift)
                    
                    let myContract = project(projectID: myItem.projectID, teamID: myTeamID)
                    contract = myContract.projectName
                    projectID = myItem.projectID
                    let tempClient = client(clientID: myItem.clientID, teamID: myItem.teamID)
                    clientName = tempClient.name
                    description = myItem.shiftDescription
                    WEDate = myItem.weekEndDate
                    shiftLineID = myItem.shiftLineID
                    type = myItem.type
                    
                    monShift = nil
                    tueShift = nil
                    wedShift = nil
                    thuShift = nil
                    friShift = nil
                    satShift = nil
                    sunShift = nil
                }
            }
            else
            {
                let myContract = project(projectID: myItem.projectID, teamID: myTeamID)
                contract = myContract.projectName
                let tempClient = client(clientID: myItem.clientID, teamID: myItem.teamID)
                clientName = tempClient.name
                projectID = myItem.projectID
                description = myItem.shiftDescription
                WEDate = myItem.weekEndDate
                shiftLineID = myItem.shiftLineID
                type = myItem.type
            }
            
            switch myItem.dayOfWeekNumber
            {
            case 1: // Sun
                sunShift = myItem
                
            case 2: // Mon
                monShift = myItem
                
            case 3: // Tue
                tueShift = myItem
                
            case 4: // Wed
                wedShift = myItem
                
            case 5: // Thu
                thuShift = myItem
                
            case 6: // Fri
                friShift = myItem
                
            case 7: // Sat
                satShift = myItem
                
            default: print("Shift createWeeklyArray hit default - value = \(myItem.dayOfWeekNumber)")
                
            }
        }
        
        let tempShift = mergedShiftList(incontract: contract,
                                        inclientName: clientName,
                                        inprojectID: projectID,
                                        indescription: description,
                                        inWEDate: WEDate,
                                        inshiftLineID: shiftLineID,
                                        inmonShift: monShift,
                                        intueShift: tueShift,
                                        inwedShift: wedShift,
                                        inthuShift: thuShift,
                                        infriShift: friShift,
                                        insatShift: satShift,
                                        insunShift: sunShift,
                                        intype: type
        )
        
        myWeeklyShifts.append(tempShift)
    }
    
    public func remove(_ indexNum: Int)
    {
        if myShifts.count <= 1
        {
            myShifts.removeAll()
        }
        else
        {
            myShifts.remove(at: indexNum)
        }
    }
    
    public func removeAll(projectID: Int64, teamID: Int64)
    {
        let data = myCloudDB.getShifts(projectID: projectID, teamID: teamID)
        
        myCloudDB.deleteRecordList.removeAll()
        
        for item in data
        {
            myCloudDB.deleteRecordList.append(item.recordID!)
        }
        
        myCloudDB.performBulkDelete()
        
        myShifts.removeAll()
    }
    
    public func append(_ newEntry: shift)
    {
        myShifts.append(newEntry)
    }
    
    public var shifts: [shift]
    {
        get
        {
            return myShifts
        }
    }
    
    public var weeklyShifts: [mergedShiftList]
    {
        get
        {
            return myWeeklyShifts
        }
    }
    
    func getTimeForPeople() -> [rosterPerson]
    {
        var rosterList: [rosterPerson] = Array()
        
        for item in myShifts
        {
            if rosterList.count == 0
            {
                let tempPerson = rosterPerson(passPersonName: item.personName,
                                              passNumHours: item.numHours,
                                              passNumMins: Int(item.numMins * 60.0))
                rosterList.append(tempPerson)
            }
            else
            {
                // check to see if there is an existing person
                var recordFound: Bool = false
                
                for mySummary in rosterList
                {
                    if item.personName == mySummary.personName
                    {
                        // Have an existying record so add
                        
                        mySummary.numHours = mySummary.numHours + item.numHours
                        mySummary.numMins = mySummary.numMins + Int(item.numMins * 60.0)
                        
                        if mySummary.numMins > 59
                        {
                            mySummary.numHours = mySummary.numHours + 1
                            mySummary.numMins = mySummary.numMins - 60
                        }
                        
                        recordFound = true
                        break
                    }
                }
                
                if !recordFound
                {
                    let tempPerson = rosterPerson(passPersonName: item.personName,
                                                  passNumHours: item.numHours,
                                                  passNumMins: Int(item.numMins * 60.0))
                    rosterList.append(tempPerson)
                }
            }
        }
        
        if rosterList.count > 0
        {
            rosterList.sort
                {
                    // Because workdate has time it throws everything out
                    
                    if $0.personName == $1.personName
                    {
                        return $0.numHours < $1.numHours
                    }
                    else
                    {
                        return $0.personName < $1.personName
                    }
            }
        }
        
        return rosterList
    }
    
    func checkForDuplicates(_ delete: Bool = false)
    {
        var workingShifts: [shift] = []
        
        if myShifts.count > 0
        {
            let shiftList = myShifts
            
            var recordsFound: Int = 0
            
            for item in myShifts
            {
                for searchItem in shiftList
                {
                    if item.projectID == searchItem.projectID &&
                        item.weekEndDate == searchItem.weekEndDate &&
                        item.workDate == searchItem.workDate &&
                        item.shiftLineID == searchItem.shiftLineID &&
                        item.startTime == searchItem.startTime &&
                        item.recordID != searchItem.recordID
                    { // We have a match
                        recordsFound += 1
                        
                        if recordsFound == 1
                        {
                            if !item.checkForExistenceOfRecordInWorkingSet(workingShifts)
                            {
                                workingShifts.append(item)
                            }
                            
                            if !searchItem.checkForExistenceOfRecordInWorkingSet(workingShifts)
                            {
                                workingShifts.append(searchItem)
                            }
                        }
                        else if recordsFound > 1
                        {
                            if !searchItem.checkForExistenceOfRecordInWorkingSet(workingShifts)
                            {
                                workingShifts.append(searchItem)
                            }
                        }
                    }
                }
                
                recordsFound = 0
            }
            
            if delete
            {
                if workingShifts.count > 0
                {
                    var deleteList: [CKRecord.ID] = []
                    
                    for item in workingShifts
                    {
                        if item.personID == 0
                        {
                            deleteList.append(item.recordID!)
                        }
                    }
                    
                    var goodShift: [shift] = []
                    
                    for item in workingShifts
                    {
                        var itemFound: Bool = false
                        
                        for searchItem in goodShift
                        {
                            if item.projectID == searchItem.projectID &&
                                item.personID == searchItem.personID &&
                                item.workDate == searchItem.workDate &&
                                item.startTime == searchItem.startTime &&
                                item.endTime == searchItem.endTime &&
                                item.recordID != searchItem.recordID
                            {
                                itemFound = true
                                deleteList.append(item.recordID!)
                                break
                            }
                        }
                        
                        if !itemFound
                        {
                            goodShift.append(item)
                        }
                    }
                    
                    myCloudDB.deleteRecordList = deleteList
                    
                    myCloudDB.performBulkDelete()
                }
            }
        }
    }
}

public class shift: NSObject, Identifiable, ObservableObject
{
    public let id = UUID()
    fileprivate var myShiftID: Int64 = 0
    fileprivate var myProjectID: Int64 = 0
    fileprivate var myPersonID: Int64 = 0
    fileprivate var myWorkDate: Date!
    fileprivate var myShiftDescription: String = ""
    fileprivate var myStartTime: Date!
    fileprivate var myEndTime: Date!
    fileprivate var myWeekEndDate: Date!
    fileprivate var myTeamID: Int64 = 0
    fileprivate var myStatus: String = ""
    fileprivate var myShiftLineID: Int64 = 0
    fileprivate var myRateID: Int64 = 0
    fileprivate var myType: String = ""
    fileprivate var myClientInvoiceNumber: Int64 = 0
    fileprivate var myPersonInvoiceNumber: Int64 = 0
    fileprivate var newRecordDelay: UInt32 = 0
    fileprivate var mysignInTime: Date?
    fileprivate var mysignOutTime: Date?
    fileprivate var myRecordID: CKRecord.ID?
    fileprivate var myClient: client!
    
    public var recordID: CKRecord.ID?
    {
        get
        {
            return myRecordID
        }
        set
        {
            myRecordID = newValue
        }
    }
    
    
    public var teamID: Int64
    {
        get
        {
            return myTeamID
        }
    }
    
    public var shiftID: Int64
    {
        get
        {
            return myShiftID
        }
    }
    
    public var shiftLineID: Int64
    {
        get
        {
            return myShiftLineID
        }
    }
    
    public var projectID: Int64
    {
        get
        {
            return myProjectID
        }
    }
    
    public var projectName: String
    {
        get
        {
            return project(projectID: myProjectID, teamID: myTeamID).projectName
        }
    }
    
    public var type: String
    {
        get
        {
            return myType
        }
        set
        {
            myType = newValue
            myCloudDB.updateShiftRecord(self)
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
            myCloudDB.updateShiftRecord(self)
        }
    }
    
    public var personName: String
    {
        get
        {
            if myPersonID == 0
            {
                return selectPerson
            }
            else
            {
                return person(personID: myPersonID, teamID: myTeamID).name
            }
        }
    }
    
    public var rateID: Int64
    {
        get
        {
            return myRateID
        }
        set
        {
            myRateID = newValue
            myCloudDB.updateShiftRecord(self)
        }
    }
    
    public var clientID: Int64
    {
        get
        {
            let tempProject = project(projectID: myProjectID, teamID: myTeamID)
            return tempProject.clientID
        }
    }
    
    public var rateDescription: String
    {
        get
        {
            if myRateID == 0
            {
                return "Select Rate"
            }
            else
            {
                return rate(rateID: myRateID, teamID: myTeamID).rateName
            }
        }
    }
    
    public var staffRate: Double
    {
        get
        {
            if myRateID == 0
            {
                return 0.0
            }
            else
            {
                return rate(rateID: myRateID, teamID: myTeamID).rateAmount
            }
        }
    }
    
    public var clientRate: Double
    {
        get
        {
            if myRateID == 0
            {
                return 0.0
            }
            else
            {
                return rate(rateID: myRateID, teamID: myTeamID).chargeAmount
            }
        }
    }
    
    public var status: String
    {
        get
        {
            return myStatus
        }
        set
        {
            myStatus = newValue
            myCloudDB.updateShiftRecord(self)
        }
    }
    
    public var workDate: Date
    {
        get
        {
            return myWorkDate
        }
    }
    
    public var workDateString: String
    {
        get
        {
            return myWorkDate.formatDateToString
        }
    }
    
    public var workDateShortString: String
    {
        get
        {
            return myWorkDate.formatDateToShortString
        }
    }
    
    public var dayOfWeek: String
    {
        get
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E"
            return dateFormatter.string(from: myWorkDate)
        }
    }
    
    public var dayOfWeekNumber: Int
    {
        get
        {
            let myCalendar = Calendar(identifier: .gregorian)
            let weekDay = myCalendar.component(.weekday, from: myWorkDate)
            return weekDay
        }
    }
    
    public var shiftDescription: String
    {
        get
        {
            return myShiftDescription
        }
        set
        {
            myShiftDescription = newValue
            myCloudDB.updateShiftRecord(self)
        }
    }
    
    public var startTime: Date
    {
        get
        {
            if myStartTime == nil {
                return getDefaultDate()
            }
            return myStartTime
        }
        set
        {
            myStartTime = newValue
            myCloudDB.updateShiftRecord(self)
        }
    }
    
    public var startTimeString: String
    {
        get
        {
            if myStartTime != nil
            {
                let dateFormatter = DateFormatter()
                //                dateFormatter.dateFormat = "HH:mm"
                //                dateFormatter.dateFormat = "h:mm am"
                dateFormatter.timeStyle = .short
                return dateFormatter.string(from: myStartTime)
            }
            else
            {
                return ""
            }
        }
    }
    
    public var endTime: Date
    {
        get
        {
            if myEndTime == nil {
                return getDefaultDate()
            }
            return myEndTime
        }
        set
        {
            myEndTime = newValue
            myCloudDB.updateShiftRecord(self)
        }
    }
    
    public var endTimeString: String
    {
        get
        {
            if myEndTime != nil
            {
                let dateFormatter = DateFormatter()
                //                dateFormatter.dateFormat = "HH:mm"
                //   dateFormatter.dateFormat = "h:mm am"
                dateFormatter.timeStyle = .short
                return dateFormatter.string(from: myEndTime)
            }
            else
            {
                return ""
            }
        }
    }
    
    public var weekEndDate: Date
    {
        get
        {
            return myWeekEndDate
        }
    }
    
    public var clientInvoiceNumber: Int64
    {
        get
        {
            return myClientInvoiceNumber
        }
        set
        {
            myClientInvoiceNumber = newValue
            myCloudDB.updateShiftRecord(self)
            save()
        }
    }
    
    public var personInvoiceNumber: Int64
    {
        get
        {
            return myPersonInvoiceNumber
        }
        set
        {
            myPersonInvoiceNumber = newValue
            myCloudDB.updateShiftRecord(self)
            save()
        }
    }
    
    public var numHours: Int
    {
        get
        {
            if myStartTime > myEndTime
            {
                // Start date is after endTime, so add 24 hours to end time (becuase of date handling
                
                let modifiedEndTime = Calendar.current.date(byAdding: .day, value: 1, to: myEndTime)!
                
                return myStartTime.dateDifferenceHours(to: modifiedEndTime)
            }
            else
            {
                return myStartTime.dateDifferenceHours(to: myEndTime)
            }
        }
    }
    
    public var numMins: Double
    {
        get
        {
            var tempNum: Int = 0
            
            if myStartTime > myEndTime
            {
                // Start date is after endTime, so add 24 hours to end time (becuase of date handling
                
                let modifiedEndTime = Calendar.current.date(byAdding: .day, value: 1, to: myEndTime)!
                
                tempNum = myStartTime.dateDifferenceMinutes(to: modifiedEndTime)
            }
            else
            {
                tempNum = myStartTime.dateDifferenceMinutes(to: myEndTime)
            }
            
            if tempNum > 0 && tempNum < 16
            {
                return 0.25
            }
            else if tempNum > 15 && tempNum < 31
            {
                return 0.5
            }
            else if tempNum > 30 && tempNum < 46
            {
                return 0.75
            }
            else if tempNum > 45 && tempNum < 61
            {
                return 1
            }
            
            return 0
        }
    }
    
    public var chargeHours: Double
    {
        get
        {
            if numMins > 0.0
            {
                return Double(numHours) + numMins
            }
            else
            {
                return Double(numHours)
            }
        }
    }
    
    public var income: Double
    {
        get
        {
            if rateID == 0
            {
                return 0
            }
            else
            {
                // Go and get the rate
                
                let rateRecord = rate(rateID: rateID, teamID: myTeamID)
                
                if rateRecord.chargeAmount == 0
                {
                    return 0
                }
                else
                {
                    return calculateAmount(numHours: numHours, numMins: numMins, rate: rateRecord.chargeAmount)
                }
            }
            
        }
    }
    
    public var expense: Double
    {
        get
        {
            if rateID == 0
            {
                return 0
            }
            else
            {
                // Go and get the rate
                
                let rateRecord = rate(rateID: rateID, teamID: myTeamID)
                
                if rateRecord.rateAmount == 0
                {
                    return 0
                }
                else
                {
                    return calculateAmount(numHours: numHours, numMins: numMins, rate: rateRecord.rateAmount)
                }
            }
        }
    }
    
    public var charge: Double
    {
        get
        {
            if rateID == 0
            {
                return 0
            }
            else
            {
                // Go and get the rate
                
                let rateRecord = rate(rateID: rateID, teamID: myTeamID)
                
                if rateRecord.chargeAmount == 0
                {
                    return 0
                }
                else
                {
                    return calculateAmount(numHours: numHours, numMins: numMins, rate: rateRecord.chargeAmount)
                }
            }
        }
    }
    
    public var signInTime: Date?
    {
        get
        {
            return mysignInTime
        }
        set
        {
            mysignInTime = newValue
            mysignOutTime = nil
            myCloudDB.updateShiftRecord(self)
            save()
        }
    }
    
    public var signOutTime: Date?
    {
        get
        {
            return mysignOutTime
        }
        set
        {
            mysignOutTime = newValue
            myCloudDB.updateShiftRecord(self)
            save()
        }
    }
    
    public var clientEntry: client {
        if myClient == nil {
            let tempProject = project(projectID: myProjectID, teamID: myTeamID)
            myClient = client(clientID: tempProject.clientID, teamID: myTeamID)
        }
        
        return myClient
    }
    
    func resetClientEntry() {
        myClient = nil
    }
    
    public init(projectID: Int64, workDate: Date, weekEndDate: Date, teamID: Int64, shiftLineID: Int64, type: String)
    {
        super.init()
        
        //        myShiftID = myCloudDB.getNextID("Shifts", teamID: teamID)
        myProjectID = projectID
        myTeamID = teamID
        myWeekEndDate = weekEndDate
        myStatus = shiftStatusOpen
        myWorkDate = workDate
        myShiftLineID = shiftLineID
        myType = type
        myStartTime = getDefaultDate()
        myEndTime = getDefaultDate()
        
        currentUser.currentTeam?.appendShift(myCloudDB.createShiftRecord(self))
        
        newRecordDelay = saveDelay
    }
    
    public init(projectID: Int64, workDate: Date, weekEndDate: Date, teamID: Int64, shiftLineID: Int64, type: String, shiftDescription: String, startTime: Date, endTime: Date)
    {
        super.init()
        
        //        myShiftID = myCloudDB.getNextID("Shifts", teamID: teamID)
        myProjectID = projectID
        myTeamID = teamID
        myWeekEndDate = weekEndDate
        myStatus = shiftStatusOpen
        myWorkDate = workDate
        myShiftLineID = shiftLineID
        myType = type
        myShiftDescription = shiftDescription
        myStartTime = startTime
        myEndTime = endTime
        
        //        currentUser.currentTeam?.appendShift(myCloudDB.createShiftRecord(self))
        //
        //        newRecordDelay = saveDelay
    }
    
    public init(projectID: Int64, shiftLineID: Int64, weekEndDate: Date, workDate: Date, teamID: Int64)
    {
        super.init()
        
        currentUser.currentTeam?.loadShifts(nil)
        
        var myItem: Shifts!
        
        for item in (currentUser.currentTeam?.ShiftList!)!
        {
            //  if (item.shiftID == shiftID)
            
            if (item.projectID == projectID) &&
                (item.shiftLineID == shiftLineID) &&
                (item.teamID == teamID) &&
                (item.weekEndDate == weekEndDate) &&
                (item.workDate == workDate)
            {
                myItem = item
                break
            }
        }
        
        if myItem != nil
        {
            myShiftID = myItem.shiftID
            myProjectID = myItem.projectID
            myPersonID = myItem.personID
            myWorkDate = myItem.workDate! as Date
            myShiftDescription = myItem.shiftDescription!
            myStartTime = myItem.startTime! as Date
            myEndTime = myItem.endTime! as Date
            myTeamID = myItem.teamID
            myWeekEndDate = myItem.weekEndDate! as Date
            myStatus = myItem.status!
            myShiftLineID = myItem.shiftLineID
            myRateID = myItem.rateID
            myType = myItem.type!
            myClientInvoiceNumber = myItem.clientInvoiceNumber
            myPersonInvoiceNumber = myItem.personInvoiceNumber
        }
    }
    
    public init(shiftID: Int64,
                projectID: Int64,
                personID: Int64,
                workDate: Date,
                shiftDescription: String,
                startTime: Date?,
                endTime: Date?,
                teamID: Int64,
                weekEndDate: Date,
                status: String,
                shiftLineID: Int64,
                rateID: Int64,
                type: String,
                clientInvoiceNumber: Int64,
                personInvoiceNumber: Int64,
                signInTime: Date?,
                signOutTime: Date?,
                recordID: CKRecord.ID?
        )
    {
        super.init()
        
        myShiftID = shiftID
        myProjectID = projectID
        myPersonID = personID
        myWorkDate = workDate
        myShiftDescription = shiftDescription
        myStartTime = startTime
        myEndTime = endTime
        myTeamID = teamID
        myWeekEndDate = weekEndDate
        myStatus = status
        myShiftLineID = shiftLineID
        myRateID = rateID
        myType = type
        myClientInvoiceNumber = clientInvoiceNumber
        myPersonInvoiceNumber = personInvoiceNumber
        mysignInTime = signInTime
        mysignOutTime = signOutTime
        
        if recordID != nil
        {
            myRecordID = recordID!
        }
    }
    
    public func save(bulkSave: Bool = false)
    {
        if currentUser.checkWritePermission(rosteringRoleType) || currentUser.checkWritePermission(invoicingRoleType)
        {
            if !bulkSave
            {
                while myCloudDB.currentlyRunning > 15
                {
                    usleep(500)
                }
                
                myCloudDB.currentlyRunning += 1
                
                let temp = Shifts(newclientInvoiceNumber: self.myClientInvoiceNumber,
                                  newendTime: self.myEndTime,
                                  newpersonID: self.myPersonID,
                                  newpersonInvoiceNumber: self.myPersonInvoiceNumber,
                                  newprojectID: self.myProjectID,
                                  newrateID: self.myRateID,
                                  newshiftDescription: self.myShiftDescription,
                                  newshiftID: self.myShiftID,
                                  newshiftLineID: self.myShiftLineID,
                                  newstartTime: self.myStartTime,
                                  newstatus: self.myStatus,
                                  newteamID: self.myTeamID,
                                  newtype: self.myType,
                                  newweekEndDate: self.myWeekEndDate,
                                  newworkDate: self.myWorkDate,
                                  newsignInTime: self.signInTime,
                                  newsignOutTime: self.signOutTime,
                                  newrecordID: nil)
                
                let newRecordID = myCloudDB.saveShiftsRecordToCloudKit(temp, recordID: self.myRecordID)
                
                var reloadShift: Bool = false
                
                if myRecordID == nil
                {
                    reloadShift = true
                }
                
                if newRecordID?.recordName != ""
                {
                    self.myRecordID = newRecordID
                }
                myCloudDB.currentlyRunning -= 1
                
                currentUser.currentTeam?.reloadShiftData = true
                if reloadShift
                {
                    temp.recordID = newRecordID
                    currentUser.currentTeam?.appendShift(temp)
                }
            }
            else
            {
                // Bulk save
                let temp = Shifts(newclientInvoiceNumber: self.myClientInvoiceNumber,
                                  newendTime: self.myEndTime,
                                  newpersonID: self.myPersonID,
                                  newpersonInvoiceNumber: self.myPersonInvoiceNumber,
                                  newprojectID: self.myProjectID,
                                  newrateID: self.myRateID,
                                  newshiftDescription: self.myShiftDescription,
                                  newshiftID: self.myShiftID,
                                  newshiftLineID: self.myShiftLineID,
                                  newstartTime: self.myStartTime,
                                  newstatus: self.myStatus,
                                  newteamID: self.myTeamID,
                                  newtype: self.myType,
                                  newweekEndDate: self.myWeekEndDate,
                                  newworkDate: self.myWorkDate,
                                  newsignInTime: self.mysignInTime,
                                  newsignOutTime: self.mysignOutTime,
                                  newrecordID: nil)
                myCloudDB.addSaveRecord(temp)
            }
        }
    }
    
    public func delete()
    {
        if currentUser.checkWritePermission(rosteringRoleType)
        {
            myCloudDB.deleteShifts(projectID: myProjectID, shiftLineID: myShiftLineID, weekEndDate: myWeekEndDate, workDate: myWorkDate, teamID: myTeamID)
            
            currentUser.currentTeam?.reloadShiftData = true
            // currentUser.currentTeam?.shifts = nil
        }
    }
    
    public func checkForExistenceOfRecordInWorkingSet(_ mainSet: [shift]) -> Bool
    {
        for tempItem in mainSet
        {
            if myRecordID == tempItem.recordID
            {
                return true
            }
        }
        return false
    }
}

extension alerts
{
    public func shiftAlerts(_ teamID: Int64)
    {
        // check for shifts with no person or rate
        
//        currentUser.currentTeam?.loadShifts(nil)
        
        if (currentUser.currentTeam!.ShiftList?.count)! > 0
        {
            var recordCount: Int = 0
            
            for myItem in shifts(query: alertShiftNoPersonOrRate, teamID: teamID).shifts
            {
                let contractEntry = project(projectID: myItem.projectID, teamID: teamID)
                
                if (contractEntry.projectStatus != archivedProjectStatus) && (contractEntry.projectID != 0)
                {
                    let alertEntry = alertItem()
                    
                    alertEntry.displayText = "Shift has no person or rate for \(myItem.workDateString) - \(myItem.startTimeString) - \(myItem.endTimeString)"
                    alertEntry.name = contractEntry.projectName
                    alertEntry.source = "Shift"
                    alertEntry.type = "Shift has no person or rate"
                    alertEntry.object = myItem
                    
                    alertList.append(alertEntry)
                    recordCount += 1
                }
            }
            
            let tempEntry = alertSummary(displayText: "Shift has no person or rate", displayAmount: recordCount)
            
            alertSummaryList.append(tempEntry)
            
            recordCount = 0
            
 //           notificationCenter.post(name: NotificationAlertUpdate, object: nil)
            
            // check for shifts with no person
            for myItem in shifts(query: alertShiftNoPerson, teamID: teamID).shifts
            {
                let contractEntry = project(projectID: myItem.projectID, teamID: teamID)
                
                if (contractEntry.projectStatus != archivedProjectStatus) && (contractEntry.projectID != 0)
                {
                    let alertEntry = alertItem()
                    
                    alertEntry.displayText = "Shift has no person for \(myItem.workDateString) - \(myItem.startTimeString) - \(myItem.endTimeString)"
                    alertEntry.name = contractEntry.projectName
                    alertEntry.source = "Shift"
                    alertEntry.type = "Shift has no person"
                    alertEntry.object = myItem
                    
                    alertList.append(alertEntry)
                    recordCount += 1
                }
            }
            
            let tempEntry5 = alertSummary(displayText: "Shift has no person", displayAmount: recordCount)
            
            alertSummaryList.append(tempEntry5)
            
            recordCount = 0
            
 //           notificationCenter.post(name: NotificationAlertUpdate, object: nil)
            
            // check for shifts with no rate
            for myItem in shifts(query: alertShiftNoRate, teamID: teamID).shifts
            {
                let contractEntry = project(projectID: myItem.projectID, teamID: teamID)
                
                if (contractEntry.projectStatus != archivedProjectStatus) && (contractEntry.projectID != 0)
                {
                    let alertEntry = alertItem()
                    
                    alertEntry.displayText = "Shift has no rate for \(myItem.workDateString) - \(myItem.startTimeString) - \(myItem.endTimeString)"
                    alertEntry.name = contractEntry.projectName
                    alertEntry.source = "Shift"
                    alertEntry.type = "Shift has no rate"
                    alertEntry.object = myItem
                    
                    alertList.append(alertEntry)
                    recordCount += 1
                }
            }
            
            let tempEntry6 = alertSummary(displayText: "Shift has no rate", displayAmount: recordCount)
            
            alertSummaryList.append(tempEntry6)
            
            recordCount = 0
            
 //           notificationCenter.post(name: NotificationAlertUpdate, object: nil)
            
            // check for events that do not have a shift 2 weeks prior to event
            for myEvent in projects(teamID: teamID, startWeeksAhead: 2).projectList
            {
                if myEvent.staff!.shifts.count == 0
                {
                    let alertEntry = alertItem()
                    
                    alertEntry.displayText = "No Event Plan created for \(myEvent.projectName) - \(myEvent.displayProjectStartDate)"
                    alertEntry.name = myEvent.projectName
                    alertEntry.source = "Project"
                    alertEntry.type = "No Event Plan"
                    alertEntry.object = myEvent
                    
                    alertList.append(alertEntry)
                    recordCount += 1
                }
            }

            let tempEntry7 = alertSummary(displayText: "No Event Plan", displayAmount: recordCount)
            
            alertSummaryList.append(tempEntry7)
            
            recordCount = 0
            
  //          notificationCenter.post(name: NotificationAlertUpdate, object: nil)
            // Check for weeks without a shift 2 weeks in advance
            
            // Calculate the weekending date we want to look at
            let workingDateThisWeek = (Date().add(.day, amount: 1)).getWeekEndingDate
            
            if shifts(teamID: teamID, WEDate: workingDateThisWeek).shifts.count == 0
            {
                let alertEntry = alertItem()
                
                alertEntry.displayText = "No Shifts created for Week Ending \(workingDateThisWeek.formatDateToShortString)"
                alertEntry.name = "Shifts for Week"
                alertEntry.source = ""
                alertEntry.type = "No Shifts created"
                alertEntry.object = nil
                
                alertList.append(alertEntry)
                recordCount += 1
            }
            
 //           notificationCenter.post(name: NotificationAlertUpdate, object: nil)
            let workingDateNextWeek = (Date().add(.day, amount: 8)).getWeekEndingDate
            
            if shifts(teamID: teamID, WEDate: workingDateNextWeek).shifts.count == 0
            {
                let alertEntry = alertItem()
                
                alertEntry.displayText = "No Shifts created for Week Ending \(workingDateNextWeek.formatDateToShortString)"
                alertEntry.name = "Shifts for Week"
                alertEntry.source = ""
                alertEntry.type = "No Shifts created"
                alertEntry.object = nil
                
                alertList.append(alertEntry)
                recordCount += 1
            }
            
  //          notificationCenter.post(name: NotificationAlertUpdate, object: nil)
            let workingDate = (Date().add(.day, amount: 15)).getWeekEndingDate
            
            if shifts(teamID: teamID, WEDate: workingDate).shifts.count == 0
            {
                let alertEntry = alertItem()
                
                alertEntry.displayText = "No Shifts created for Week Ending \(workingDate.formatDateToShortString)"
                alertEntry.name = "Shifts for Week"
                alertEntry.source = ""
                alertEntry.type = "No Shifts created"
                alertEntry.object = nil
                
                alertList.append(alertEntry)
                recordCount += 1
            }
            let tempEntry8 = alertSummary(displayText: "No Shifts created", displayAmount: recordCount)
            
            alertSummaryList.append(tempEntry8)
            
            recordCount = 0
            
//            notificationCenter.post(name: NotificationAlertUpdate, object: nil)
        }
    }
}

extension report
{
    public func reportContractForMonth(_ contractList: projects)
    {
        var lastClientID: Int64 = -1
        
        var clientCost: Double = 0.0
        var clientIncome: Double = 0.0
        var totalCost: Double = 0.0
        var totalIncome: Double = 0.0
        var firstPass: Bool = true
        var clientName: String = ""
        
        let drawLine = reportLine()
        drawLine.drawLine = true
        
        var clientProjects: Int = 0
        
        for myItem in contractList.projectList
        {
            let profit = myItem.financials[0].income - myItem.financials[0].expense
            
            let gp = (profit/myItem.financials[0].income)  * 100
            
            if myItem.financials[0].income != 0 || myItem.financials[0].expense != 0
            {
                let newReportLine = reportLine()
                
                if myItem.clientID != lastClientID
                {
                    if !firstPass
                    {
                        if clientProjects == 1
                        {
                            myLines.last?.format = formatBold
                        }
                        
                        myLines.append(drawLine)
                        
                        if clientProjects > 1
                        {
                            let clientProfit = clientIncome - clientCost
                            var clientGP: Double = 0.0
                            if clientIncome > 0.0
                            {
                                clientGP = (clientProfit/clientIncome)  * 100
                            }
                            
                            let newClientTotalLine = reportLine()
                            newClientTotalLine.column1 = clientName
                            newClientTotalLine.column2 = "Total"
                            newClientTotalLine.column3 = ""
                            newClientTotalLine.column4 = clientCost.formatCurrency
                            newClientTotalLine.column5 = clientIncome.formatCurrency
                            newClientTotalLine.column6 = clientProfit.formatCurrency
                            newClientTotalLine.column7 = clientGP.formatPercent
                            newClientTotalLine.format = formatBold
                            
                            myLines.append(newClientTotalLine)
                            myLines.append(drawLine)
                        }
                        
                        clientProjects = 0
                        clientIncome = 0.0
                        clientCost = 0.0
                    }
                    firstPass = false
                    let tempClient = client(clientID: myItem.clientID, teamID: myTeamID)
                    clientName = tempClient.name
                    lastClientID = myItem.clientID
                    newReportLine.column1 = clientName
                }
                
                clientProjects += 1
                //newReportLine.column1 = clientName
                newReportLine.column2 = myItem.projectName
                newReportLine.column3 = myItem.financials[0].hours.formatHours
                newReportLine.column4 = myItem.financials[0].expense.formatCurrency
                newReportLine.column5 = myItem.financials[0].income.formatCurrency
                newReportLine.column6 = profit.formatCurrency
                newReportLine.column7 = gp.formatPercent
                newReportLine.sourceObject = myItem
                
                myLines.append(newReportLine)
                
                clientCost += myItem.financials[0].expense
                clientIncome += myItem.financials[0].income
                totalCost += myItem.financials[0].expense
                totalIncome += myItem.financials[0].income
            }
        }
        
        if clientProjects == 1
        {
            myLines.last?.format = formatBold
        }
        
        myLines.append(drawLine)
        
        let clientProfit = clientIncome - clientCost
        var clientGP: Double = 0.0
        if clientIncome > 0.0
        {
            clientGP = (clientProfit/clientIncome)  * 100
        }
        
        if clientProjects > 1
        {
            let newClientTotalLine = reportLine()
            newClientTotalLine.column1 = clientName
            newClientTotalLine.column2 = "Total"
            newClientTotalLine.column3 = ""
            newClientTotalLine.column4 = clientCost.formatCurrency
            newClientTotalLine.column5 = clientIncome.formatCurrency
            newClientTotalLine.column6 = clientProfit.formatCurrency
            newClientTotalLine.column7 = clientGP.formatPercent
            newClientTotalLine.format = formatBold
            
            myLines.append(newClientTotalLine)
            myLines.append(drawLine)
        }
        let totalProfit = totalIncome - totalCost
        var totalGP: Double = 0.0
        if clientIncome > 0.0
        {
            totalGP = (totalProfit/totalIncome)  * 100
        }
        let newTotalTotalLine = reportLine()
        newTotalTotalLine.column1 = "Total"
        newTotalTotalLine.column2 = ""
        newTotalTotalLine.column3 = ""
        newTotalTotalLine.column4 = totalCost.formatCurrency
        newTotalTotalLine.column5 = totalIncome.formatCurrency
        newTotalTotalLine.column6 = totalProfit.formatCurrency
        newTotalTotalLine.column7 = totalGP.formatPercent
        newTotalTotalLine.format = formatTotal
        
        myLines.append(newTotalTotalLine)
    }
    
    public func reportWagesForMonth(month: String, year: String, teamID: Int64)
    {
        for myItem in people(teamID: teamID, isActive: true).people
        {
            let monthReport = myItem.getFinancials(month: month, year: year)
            
            if monthReport.hours != 0
            {
                let newReportLine = reportLine()
                
                newReportLine.column1 = myItem.name
                newReportLine.column2 = monthReport.hours.formatHours
                newReportLine.column3 = monthReport.wage.formatCurrency
                
                newReportLine.sourceObject = myItem
                
                myLines.append(newReportLine)
            }
        }
    }
    
    public func reportContractForYear(year: String)
    {
        var janTotalAmount: Double = 0.0
        var febTotalAmount: Double = 0.0
        var marTotalAmount: Double = 0.0
        var aprTotalAmount: Double = 0.0
        var mayTotalAmount: Double = 0.0
        var junTotalAmount: Double = 0.0
        var julTotalAmount: Double = 0.0
        var augTotalAmount: Double = 0.0
        var sepTotalAmount: Double = 0.0
        var octTotalAmount: Double = 0.0
        var novTotalAmount: Double = 0.0
        var decTotalAmount: Double = 0.0
        
        for myClient in clients(teamID: currentUser.currentTeam!.teamID, isActive: true).clients
        {
            var janShowTotal: Bool = false
            var febShowTotal: Bool = false
            var marShowTotal: Bool = false
            var aprShowTotal: Bool = false
            var mayShowTotal: Bool = false
            var junShowTotal: Bool = false
            var julShowTotal: Bool = false
            var augShowTotal: Bool = false
            var sepShowTotal: Bool = false
            var octShowTotal: Bool = false
            var novShowTotal: Bool = false
            var decShowTotal: Bool = false
            
            var janClientAmount: Double = 0.0
            var febClientAmount: Double = 0.0
            var marClientAmount: Double = 0.0
            var aprClientAmount: Double = 0.0
            var mayClientAmount: Double = 0.0
            var junClientAmount: Double = 0.0
            var julClientAmount: Double = 0.0
            var augClientAmount: Double = 0.0
            var sepClientAmount: Double = 0.0
            var octClientAmount: Double = 0.0
            var novClientAmount: Double = 0.0
            var decClientAmount: Double = 0.0
            
            for myProject in myClient.projectList.projectList
            {
                var janShow: Bool = false
                var febShow: Bool = false
                var marShow: Bool = false
                var aprShow: Bool = false
                var mayShow: Bool = false
                var junShow: Bool = false
                var julShow: Bool = false
                var augShow: Bool = false
                var sepShow: Bool = false
                var octShow: Bool = false
                var novShow: Bool = false
                var decShow: Bool = false
                
                myProject.loadFinancials(month: "January", year: year)
                let janAmount = myProject.financials[0].income - myProject.financials[0].expense
                if myProject.financials[0].income != 0 || myProject.financials[0].expense != 0
                {
                    janShow = true
                }
                
                myProject.loadFinancials(month: "February", year: year)
                let febAmount = myProject.financials[0].income - myProject.financials[0].expense
                if myProject.financials[0].income != 0 || myProject.financials[0].expense != 0
                {
                    febShow = true
                }
                
                myProject.loadFinancials(month: "March", year: year)
                let marAmount = myProject.financials[0].income - myProject.financials[0].expense
                if myProject.financials[0].income != 0 || myProject.financials[0].expense != 0
                {
                    marShow = true
                }
                
                myProject.loadFinancials(month: "April", year: year)
                let aprAmount = myProject.financials[0].income - myProject.financials[0].expense
                if myProject.financials[0].income != 0 || myProject.financials[0].expense != 0
                {
                    aprShow = true
                }
                
                myProject.loadFinancials(month: "May", year: year)
                let mayAmount = myProject.financials[0].income - myProject.financials[0].expense
                if myProject.financials[0].income != 0 || myProject.financials[0].expense != 0
                {
                    mayShow = true
                }
                
                myProject.loadFinancials(month: "June", year: year)
                let junAmount = myProject.financials[0].income - myProject.financials[0].expense
                if myProject.financials[0].income != 0 || myProject.financials[0].expense != 0
                {
                    junShow = true
                }
                
                myProject.loadFinancials(month: "July", year: year)
                let julAmount = myProject.financials[0].income - myProject.financials[0].expense
                if myProject.financials[0].income != 0 || myProject.financials[0].expense != 0
                {
                    julShow = true
                }
                
                myProject.loadFinancials(month: "August", year: year)
                let augAmount = myProject.financials[0].income - myProject.financials[0].expense
                if myProject.financials[0].income != 0 || myProject.financials[0].expense != 0
                {
                    augShow = true
                }
                
                myProject.loadFinancials(month: "September", year: year)
                let sepAmount = myProject.financials[0].income - myProject.financials[0].expense
                if myProject.financials[0].income != 0 || myProject.financials[0].expense != 0
                {
                    sepShow = true
                }
                
                myProject.loadFinancials(month: "October", year: year)
                let octAmount = myProject.financials[0].income - myProject.financials[0].expense
                if myProject.financials[0].income != 0 || myProject.financials[0].expense != 0
                {
                    octShow = true
                }
                
                myProject.loadFinancials(month: "November", year: year)
                let novAmount = myProject.financials[0].income - myProject.financials[0].expense
                if myProject.financials[0].income != 0 || myProject.financials[0].expense != 0
                {
                    novShow = true
                }
                
                myProject.loadFinancials(month: "December", year: year)
                let decAmount = myProject.financials[0].income - myProject.financials[0].expense
                if myProject.financials[0].income != 0 || myProject.financials[0].expense != 0
                {
                    decShow = true
                }
                
                let newReportLine = reportLine()
                
                let totAmount = janAmount + febAmount + marAmount + aprAmount + mayAmount + junAmount + julAmount + augAmount + sepAmount + octAmount + novAmount + decAmount
                
                newReportLine.column1 = myProject.projectName
                
                if janShow
                {
                    newReportLine.column2 = janAmount.formatIntString
                    janShowTotal = true
                }
                
                if febShow
                {
                    newReportLine.column3 = febAmount.formatIntString
                    febShowTotal = true
                }
                
                if marShow
                {
                    newReportLine.column4 = marAmount.formatIntString
                    marShowTotal = true
                }
                
                if aprShow
                {
                    newReportLine.column5 = aprAmount.formatIntString
                    aprShowTotal = true
                }
                
                if mayShow
                {
                    newReportLine.column6 = mayAmount.formatIntString
                    mayShowTotal = true
                }
                
                if junShow
                {
                    newReportLine.column7 = junAmount.formatIntString
                    junShowTotal = true
                }
                
                if julShow
                {
                    newReportLine.column8 = julAmount.formatIntString
                    julShowTotal = true
                }
                
                if augShow
                {
                    newReportLine.column9 = augAmount.formatIntString
                    augShowTotal = true
                }
                
                if sepShow
                {
                    newReportLine.column10 = sepAmount.formatIntString
                    sepShowTotal = true
                }
                
                if octShow
                {
                    newReportLine.column11 = octAmount.formatIntString
                    octShowTotal = true
                }
                
                if novShow
                {
                    newReportLine.column12 = novAmount.formatIntString
                    novShowTotal = true
                }
                
                if decShow
                {
                    newReportLine.column13 = decAmount.formatIntString
                    decShowTotal = true
                }
                
                newReportLine.column14 = totAmount.formatIntString
                
                newReportLine.sourceObject = myProject
                
                myLines.append(newReportLine)
                
                janClientAmount += janAmount
                febClientAmount += febAmount
                marClientAmount += marAmount
                aprClientAmount += aprAmount
                mayClientAmount += mayAmount
                junClientAmount += junAmount
                julClientAmount += julAmount
                augClientAmount += augAmount
                sepClientAmount += sepAmount
                octClientAmount += octAmount
                novClientAmount += novAmount
                decClientAmount += decAmount
                
                janTotalAmount += janAmount
                febTotalAmount += febAmount
                marTotalAmount += marAmount
                aprTotalAmount += aprAmount
                mayTotalAmount += mayAmount
                junTotalAmount += junAmount
                julTotalAmount += julAmount
                augTotalAmount += augAmount
                sepTotalAmount += sepAmount
                octTotalAmount += octAmount
                novTotalAmount += novAmount
                decTotalAmount += decAmount
            }
            
            let drawLine = reportLine()
            drawLine.drawLine = true
            myLines.append(drawLine)
            
            let newReportLine = reportLine()
            
            let totClientAmount = janClientAmount + febClientAmount + marClientAmount + aprClientAmount + mayClientAmount + junClientAmount + julClientAmount + augClientAmount + sepClientAmount + octClientAmount + novClientAmount + decClientAmount
            
            newReportLine.column1 = myClient.name
            
            if janShowTotal
            {
                newReportLine.column2 = janClientAmount.formatIntString
            }
            
            if febShowTotal
            {
                newReportLine.column3 = febClientAmount.formatIntString
            }
            
            if marShowTotal
            {
                newReportLine.column4 = marClientAmount.formatIntString
            }
            
            if aprShowTotal
            {
                newReportLine.column5 = aprClientAmount.formatIntString
            }
            
            if mayShowTotal
            {
                newReportLine.column6 = mayClientAmount.formatIntString
            }
            
            if junShowTotal
            {
                newReportLine.column7 = junClientAmount.formatIntString
            }
            
            if julShowTotal
            {
                newReportLine.column8 = julClientAmount.formatIntString
            }
            
            if augShowTotal
            {
                newReportLine.column9 = augClientAmount.formatIntString
            }
            
            if sepShowTotal
            {
                newReportLine.column10 = sepClientAmount.formatIntString
            }
            
            if octShowTotal
            {
                newReportLine.column11 = octClientAmount.formatIntString
            }
            
            if novShowTotal
            {
                newReportLine.column12 = novClientAmount.formatIntString
            }
            
            if decShowTotal
            {
                newReportLine.column13 = decClientAmount.formatIntString
            }
            
            newReportLine.column14 = totClientAmount.formatIntString
            
            newReportLine.sourceObject = myClient
            
            myLines.append(newReportLine)
            
            let drawLine2 = reportLine()
            drawLine2.drawLine = true
            myLines.append(drawLine2)
        }
        
        let newReportLine = reportLine()
        
        let totTotalAmount = janTotalAmount + febTotalAmount + marTotalAmount + aprTotalAmount + mayTotalAmount + junTotalAmount + julTotalAmount + augTotalAmount + sepTotalAmount + octTotalAmount + novTotalAmount + decTotalAmount
        
        newReportLine.column1 = "Total"
        
        newReportLine.column2 = janTotalAmount.formatIntString
        newReportLine.column3 = febTotalAmount.formatIntString
        newReportLine.column4 = marTotalAmount.formatIntString
        newReportLine.column5 = aprTotalAmount.formatIntString
        newReportLine.column6 = mayTotalAmount.formatIntString
        newReportLine.column7 = junTotalAmount.formatIntString
        newReportLine.column8 = julTotalAmount.formatIntString
        newReportLine.column9 = augTotalAmount.formatIntString
        newReportLine.column10 = sepTotalAmount.formatIntString
        newReportLine.column11 = octTotalAmount.formatIntString
        newReportLine.column12 = novTotalAmount.formatIntString
        newReportLine.column13 = decTotalAmount.formatIntString
        newReportLine.column14 = totTotalAmount.formatIntString
        
        myLines.append(newReportLine)
    }
    
    public func reportContractDates(_ contractList: projects)
    {
        var lastClientID: Int64 = -1
        
        for myItem in contractList.projectList
        {
            let profit = myItem.financials[0].income - myItem.financials[0].expense
            
            let gp = (profit/myItem.financials[0].income)  * 100
            
            if myItem.financials[0].income != 0 || myItem.financials[0].expense != 0
            {
                let newReportLine = reportLine()
                
                var clientName: String = ""
                if myItem.clientID != lastClientID
                {
                    let tempClient = client(clientID: myItem.clientID, teamID: myTeamID)
                    clientName = tempClient.name
                    lastClientID = myItem.clientID
                }
                
                newReportLine.column1 = clientName
                newReportLine.column2 = myItem.projectName
                newReportLine.column3 = myItem.financials[0].hours.formatHours
                newReportLine.column4 = myItem.financials[0].expense.formatCurrency
                newReportLine.column5 = myItem.financials[0].income.formatCurrency
                newReportLine.column6 = profit.formatCurrency
                newReportLine.column7 = gp.formatPercent
                newReportLine.sourceObject = myItem
                
                myLines.append(newReportLine)
            }
        }
    }
}

extension team
{
    public var reportingMonths: [String]
    {
        get
        {
            var returnArray: [String] = Array()
            var workingArray: [Int64] = Array()
            
            currentUser.currentTeam?.loadShifts(nil)
            
            for myItem in (currentUser.currentTeam?.ShiftList!)!
            {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM"
                
                let month = dateFormatter.string(from: myItem.workDate! as Date)
                
                let monthInt = Int64(month)
                
                var found: Bool = false
                
                for myMonth in workingArray
                {
                    if myMonth == monthInt
                    {
                        found = true
                        break
                    }
                }
                
                if !found
                {
                    workingArray.append(monthInt!)
                }
            }
            
            // Now we have all the entries sort into numerical ascending order
            
            if workingArray.count > 0
            {
                workingArray.sort { $0 < $1 }
            }
            
            // Now Convert to Month Names
            
            for myItem in workingArray
            {
                switch myItem
                {
                case 1:
                    returnArray.append("January")
                    
                case 2:
                    returnArray.append("February")
                    
                case 3:
                    returnArray.append("March")
                    
                case 4:
                    returnArray.append("April")
                    
                case 5:
                    returnArray.append("May")
                    
                case 6:
                    returnArray.append("June")
                    
                case 7:
                    returnArray.append("July")
                    
                case 8:
                    returnArray.append("August")
                    
                case 9:
                    returnArray.append("September")
                    
                case 10:
                    returnArray.append("October")
                    
                case 11:
                    returnArray.append("November")
                    
                case 12:
                    returnArray.append("December")
                    
                default:
                    print("Teams reportingMonths - got unexpected month - myItem")
                }
                
            }
            
            return returnArray
        }
    }
}

extension projects
{
    public func loadFinancials(month: String, year: String)
    {
        // Need to get the
        
        // get the projects for the team
        
        for workingProject in projectList
        {
            workingProject.loadFinancials(month: month, year: year)
        }
    }
    public func loadFinancials(startDate: Date, endDate: Date)
    {
        // Need to get the
        
        // get the projects for the team
        
        for workingProject in projectList
        {
            workingProject.loadFinancials(startDate: startDate, endDate: endDate)
        }
    }
}

extension project
{
    public func loadFinancials(month: String = "", year: String = "")
    {
        var financeArray: [monthlyFinancialsStruct] = Array()
        
        if month == ""
        {
            // Going to get all financials
            print("GRE - Do project loadFinancials for all")
            
            
            
        }
        else
        {
            let shiftArray = shifts(projectID: projectID, month: month, year: year, teamID: teamID)
            
            financeArray.append(processMonth(shiftArray: shiftArray, month: month, year: year))
        }
        
        financials = financeArray
    }
    
    public func loadFinancials(startDate: Date, endDate: Date)
    {
        var financeArray: [monthlyFinancialsStruct] = Array()
        
        let shiftArray = shifts(projectID: projectID, startDate: startDate, endDate: endDate, teamID: teamID)
        
        financeArray.append(processMonth(shiftArray: shiftArray, month: "", year: ""))
        
        financials = financeArray
    }
    
    private func processMonth(shiftArray: shifts, month: String, year: String) -> monthlyFinancialsStruct
    {
        var income: Double = 0.0
        var expenditure: Double = 0.0
        var hours: Double = 0.0
        
        for myItem in shiftArray.shifts
        {
            income += myItem.income
            expenditure += myItem.expense
            hours += Double(myItem.numHours)
            hours += myItem.numMins
        }
        
        return monthlyFinancialsStruct(
            month: month,
            year: year,
            income: income,
            expense: expenditure,
            hours: hours
        )
    }
}

extension people
{
    convenience public init(teamID: Int64, month: String, year: String)
    {
        self.init(teamID: teamID, isActive: true)
        
        var workingArray: [person] = Array()
        
        // get list of shifts for the month
        
        let shiftList = shifts(teamID: teamID, month: month.monthNum, year: Int(year)!)
        
        for myItem in myPeople
        {
            // See if the person has any shifts in the month
            
            for myShift in shiftList.shifts
            {
                if myShift.personID == myItem.personID
                {
                    workingArray.append(myItem)
                    break
                }
            }
        }
        
        self.myPeople = workingArray
        self.sortArray()
    }
}

extension person
{
    public func getFinancials(month: String, year: String) -> monthlyPersonFinancialsStruct
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        
        let dateString = "01 \(month) \(year)"
        let calculatedDate = dateFormatter.date(from: dateString)
        
        let startDate = calculatedDate!.startOfDay   //  calendar.startOfDay(for: calculatedDate!)
        // get the start of the day after the selected date
        let endDate = startDate.add(.month, amount: 1) //  calendar.date(byAdding: .month, value: 1, to: startDate)!
        
        var wage: Double = 0.0
        var hours: Double = 0.0
        
        for myShift in shifts(personID: personID, searchFrom: startDate, searchTo: endDate, teamID: currentUser.currentTeam!.teamID, type: "").shifts
        {
            wage += myShift.expense
            hours += Double(myShift.numHours)
            hours += myShift.numMins
        }
        
        let retVal = monthlyPersonFinancialsStruct(
            month: month,
            year: year,
            wage: wage,
            hours: hours
        )
        
        return retVal
    }
    
    public func loadShifts(month: String, year: String, teamID: Int64)
    {
        tempArray.removeAll()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        
        let dateString = "01 \(month) \(year)"
        let calculatedDate = dateFormatter.date(from: dateString)
        
        let startDate =  calculatedDate!.startOfDay  //  calendar.startOfDay(for: calculatedDate!)
        // get the start of the day after the selected date
        let endDate = startDate.add(.month, amount: 1)    // calendar.date(byAdding: .month, value: 1, to: startDate)!
        
        let tempShifts = shifts(personID: personID, searchFrom: startDate, searchTo: endDate, teamID: teamID, type: "")
        
        var sortingArray = tempShifts.shifts
        
        if sortingArray.count > 0
        {
            sortingArray.sort
                {
                    // Because workdate has time it throws everything out
                    
                    if $0.workDate == $1.workDate
                    {
                        return $0.startTime < $1.startTime
                    }
                    else
                    {
                        return $0.workDate < $1.workDate
                    }
            }
        }
        
        tempArray = sortingArray
    }
    
    public var shiftArray: [shift]
    {
        get
        {
            return tempArray as! [shift]
        }
    }
    
    public func loadShifts()
    {
        tempArray.removeAll()
        
        let tempShifts = shifts(personID: personID, teamID: teamID)
        
        var sortingArray = tempShifts.shifts
        
        if sortingArray.count > 0
        {
            sortingArray.sort
                {
                    // Because workdate has time it throws everything out
                    
                    if $0.workDate == $1.workDate
                    {
                        return $0.startTime > $1.startTime
                    }
                    else
                    {
                        return $0.workDate > $1.workDate
                    }
            }
        }
        
        tempArray = sortingArray
    }
}

public class Shifts: Identifiable {
    public let id = UUID()
    public var clientInvoiceNumber: Int64
    public var endTime: Date?
    public var personID: Int64
    public var personInvoiceNumber: Int64
    public var projectID: Int64
    public var rateID: Int64
    public var shiftDescription: String?
    public var shiftID: Int64
    public var shiftLineID: Int64
    public var startTime: Date?
    public var status: String?
    public var teamID: Int64
    public var type: String?
    public var weekEndDate: Date?
    public var workDate: Date?
    public var signInTime: Date?
    public var signOutTime: Date?
    public var recordID: CKRecord.ID?
    
    public init(newclientInvoiceNumber: Int64,
                newendTime: Date?,
                newpersonID: Int64,
                newpersonInvoiceNumber: Int64,
                newprojectID: Int64,
                newrateID: Int64,
                newshiftDescription: String?,
                newshiftID: Int64,
                newshiftLineID: Int64,
                newstartTime: Date?,
                newstatus: String?,
                newteamID: Int64,
                newtype: String?,
                newweekEndDate: Date?,
                newworkDate: Date?,
                newsignInTime: Date?,
                newsignOutTime: Date?,
                newrecordID: CKRecord.ID?)
    {
        clientInvoiceNumber = newclientInvoiceNumber
        endTime = newendTime
        personID = newpersonID
        personInvoiceNumber = newpersonInvoiceNumber
        projectID = newprojectID
        rateID = newrateID
        shiftDescription = newshiftDescription
        shiftID = newshiftID
        shiftLineID = newshiftLineID
        startTime = newstartTime
        status = newstatus
        teamID = newteamID
        type = newtype
        weekEndDate = newweekEndDate
        workDate = newworkDate
        signInTime = newsignInTime
        signOutTime = newsignOutTime
        recordID = newrecordID
    }
}

extension CloudKitInteraction
{
    private func populateShifts(_ records: [CKRecord]) -> [Shifts]
    {
        var tempArray: [Shifts] = Array()
        for record in records
        {
            var shiftID: Int64 = 0
            if record.object(forKey: "shiftID") != nil
            {
                shiftID = record.object(forKey: "shiftID") as! Int64
            }
            
            var rateID: Int64 = 0
            if record.object(forKey: "rateID") != nil
            {
                rateID = record.object(forKey: "rateID") as! Int64
            }
            
            var shiftLineID: Int64 = 0
            if record.object(forKey: "shiftLineID") != nil
            {
                shiftLineID = record.object(forKey: "shiftLineID") as! Int64
            }
            
            var projectID: Int64 = 0
            if record.object(forKey: "projectID") != nil
            {
                projectID = record.object(forKey: "projectID") as! Int64
            }
            
            var personID: Int64 = 0
            if record.object(forKey: "personID") != nil
            {
                personID = record.object(forKey: "personID") as! Int64
            }
            
            var workDate = Date()
            if record.object(forKey: "workDate") != nil
            {
                workDate = record.object(forKey: "workDate") as! Date
            }
            
            var startTime = Date()
            if record.object(forKey: "startTime") != nil
            {
                startTime = record.object(forKey: "startTime") as! Date
            }
            
            var endTime = Date()
            if record.object(forKey: "endTime") != nil
            {
                endTime = record.object(forKey: "endTime") as! Date
            }
            
            var weekEndDate = Date()
            if record.object(forKey: "weekEndDate") != nil
            {
                weekEndDate = record.object(forKey: "weekEndDate") as! Date
            }
            
            var teamID: Int64 = 0
            if record.object(forKey: "teamID") != nil
            {
                teamID = record.object(forKey: "teamID") as! Int64
            }
            
            var clientInvoiceNumber: Int64 = 0
            if record.object(forKey: "clientInvoiceNumber") != nil
            {
                clientInvoiceNumber = record.object(forKey: "clientInvoiceNumber") as! Int64
            }
            
            var personInvoiceNumber: Int64 = 0
            if record.object(forKey: "personInvoiceNumber") != nil
            {
                personInvoiceNumber = record.object(forKey: "personInvoiceNumber") as! Int64
            }
            
            var signInTime: Date!
            if record.object(forKey: "signInTime") != nil
            {
                signInTime = record.object(forKey: "signInTime") as? Date
            }
            
            var signOutTime: Date!
            if record.object(forKey: "signOutTime") != nil
            {
                signOutTime = record.object(forKey: "signOutTime") as? Date
            }
            
            let tempItem = Shifts(newclientInvoiceNumber: clientInvoiceNumber,
                                  newendTime: endTime,
                                  newpersonID: personID,
                                  newpersonInvoiceNumber: personInvoiceNumber,
                                  newprojectID: projectID,
                                  newrateID: rateID,
                                  newshiftDescription: record.object(forKey: "shiftDescription") as? String,
                                  newshiftID: shiftID,
                                  newshiftLineID: shiftLineID,
                                  newstartTime: startTime,
                                  newstatus: record.object(forKey: "status") as? String,
                                  newteamID: teamID,
                                  newtype: record.object(forKey: "type") as? String,
                                  newweekEndDate: weekEndDate,
                                  newworkDate: workDate,
                                  newsignInTime: signInTime,
                                  newsignOutTime: signOutTime,
                                  newrecordID: record.recordID)
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func createShiftRecord(_ record: shift) -> Shifts
    {
        return Shifts(newclientInvoiceNumber: record.clientInvoiceNumber,
                      newendTime: record.endTime,
                      newpersonID: record.personID,
                      newpersonInvoiceNumber: record.personInvoiceNumber,
                      newprojectID: record.projectID,
                      newrateID: record.rateID,
                      newshiftDescription: record.shiftDescription,
                      newshiftID: record.shiftID,
                      newshiftLineID: record.shiftLineID,
                      newstartTime: record.startTime,
                      newstatus: record.status,
                      newteamID: record.teamID,
                      newtype: record.type,
                      newweekEndDate: record.weekEndDate,
                      newworkDate: record.workDate,
                      newsignInTime: record.signInTime,
                      newsignOutTime: record.signOutTime,
                      newrecordID: nil)
    }
    
    func updateShiftRecord(_ record: shift)
    {
        for item in (currentUser.currentTeam?.ShiftList)!
        {
            //            if (item.shiftID == record.shiftID)
            if (item.projectID == record.projectID) &&
                (item.shiftLineID == record.shiftLineID) &&
                (item.teamID == record.teamID) &&
                (item.weekEndDate == record.weekEndDate) &&
                (item.workDate == record.workDate)
            {
                item.clientInvoiceNumber = record.clientInvoiceNumber
                item.endTime = record.endTime
                item.personID = record.personID
                item.personInvoiceNumber = record.personInvoiceNumber
                item.projectID = record.projectID
                item.rateID = record.rateID
                item.shiftDescription = record.shiftDescription
                item.startTime = record.startTime
                item.status = record.status
                item.type = record.type
                item.signInTime = record.signInTime
                item.signOutTime = record.signOutTime
            }
        }
    }
    
    func getShiftForRate(rateID: Int64, type: String, teamID: Int64)->[Shifts]
    {
        let predicate = NSPredicate(format: "(rateID == \(rateID)) AND (teamID == \(teamID)) AND (type == \"\(type)\") AND (updateType != \"Delete\")")
        
        let sem = DispatchSemaphore(value: 0)
        var returnArray: [Shifts] = Array()
        
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            returnArray = self.populateShifts(records!)
            
            sem.signal()
        })
        sem.wait()
        
        return returnArray
    }
    
    public func getShifts(teamID: Int64)->[Shifts]
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Shifts] = populateShifts(returnArray)
        return shiftArray
    }
    
    public func cleanTeamShifts(teamID: Int64)
    {
        let predicate = NSPredicate(format: "teamID == \(teamID)")
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Shifts] = populateShifts(returnArray)
        
        deleteRecordList.removeAll()
        
        var totalCount = 0
        
        for item in shiftArray
        {
            if deleteRecordList.count > 200
            {
                performBulkDelete()
                sleep(2)
                deleteRecordList.removeAll()
            }
            
            deleteRecordList.append(item.recordID!)
            
            totalCount += 1
        }
        
        
        performBulkDelete()
    }
    
    public func getShiftsRecent(teamID: Int64)->[Shifts]
    {
        let workingDate = Date().add(.month, amount: -2)
        
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\") AND (workDate >= %@)", workingDate as CVarArg)
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Shifts] = populateShifts(returnArray)
        return shiftArray
    }
    
    public func getShiftsOld(teamID: Int64)->[Shifts]
    {
        let workingDate = Date().add(.month, amount: -2)
        
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\") AND (workDate < %@)", workingDate as CVarArg)
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Shifts] = populateShifts(returnArray)
        return shiftArray
    }
    
    public func getShifts(personID: Int64, teamID: Int64)->[Shifts]
    {
        let predicate = NSPredicate(format: "(personID == \(personID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Shifts] = populateShifts(returnArray)
        
        return shiftArray
    }
    
    public func getShifts(teamID: Int64, WEDate: Date, type: String)->[Shifts]
    {
        let startDate =  WEDate.startOfDay  // calendar.startOfDay(for: WEDate)
        // get the start of the day after the selected date
        let endDate = startDate.add(.day, amount: 1)  // calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(weekEndDate >= %@) AND (weekEndDate <= %@) AND (teamID == \(teamID)) AND (type == \"\(type)\") AND (updateType != \"Delete\")", startDate as CVarArg, endDate as CVarArg)
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Shifts] = populateShifts(returnArray)
        
        return shiftArray
    }
    
    public func getShifts(teamID: Int64, WEDate: Date, includeEvents: Bool)->[Shifts]
    {
        let startDate = WEDate.startOfDay  //  calendar.startOfDay(for: WEDate)
        // get the start of the day after the selected date
        let endDate = startDate.add(.day, amount: 1)  //calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        if includeEvents
        {
            predicate = NSPredicate(format: "(weekEndDate >= %@) AND (weekEndDate <= %@) AND (teamID == \(teamID)) AND (updateType != \"Delete\")", startDate as CVarArg, endDate as CVarArg)
        }
        else
        {
            predicate = NSPredicate(format: "(weekEndDate >= %@) AND (weekEndDate <= %@) AND (teamID == \(teamID)) AND (type != \"\(eventShiftType)\") AND (updateType != \"Delete\")", startDate as CVarArg, endDate as CVarArg)
        }
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Shifts] = populateShifts(returnArray)
        
        return shiftArray
    }
    
    public func getShifts(projectID: Int64, month: String, year: String, teamID: Int64)->[Shifts]
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        
        let dateString = "01 \(month) \(year)"
        let calculatedDate = dateFormatter.date(from: dateString)
        
        let startDate = calculatedDate!.startOfDay // calendar.startOfDay(for: calculatedDate!)
        // get the start of the day after the selected date
        let endDate = startDate.add(.month, amount: 1) // calendar.date(byAdding: .month, value: 1, to: startDate)!
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(workDate >= %@) AND (workDate < %@) AND (projectID == \(projectID)) AND (teamID == \(teamID))  AND (updateType != \"Delete\")", startDate as CVarArg, endDate as CVarArg)
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Shifts] = populateShifts(returnArray)
        
        return shiftArray    }
    
    public func getShifts(teamID: Int64, month: String, year: String)->[Shifts]
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        
        let dateString = "01 \(month) \(year)"
        let calculatedDate = dateFormatter.date(from: dateString)
        
        let startDate = calculatedDate!.startOfDay   //    calendar.startOfDay(for: calculatedDate!)
        // get the start of the day after the selected date
        let endDate = startDate.add(.month, amount: 1)  //  calendar.date(byAdding: .month, value: 1, to: startDate)!
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(workDate >= %@) AND (workDate < %@) AND (teamID == \(teamID)) AND (updateType != \"Delete\")", startDate as CVarArg, endDate as CVarArg)
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Shifts] = populateShifts(returnArray)
        
        return shiftArray
    }
    
    public func getShifts(personID: Int64, searchFrom: Date, searchTo: Date, teamID: Int64, type: String = "")->[Shifts]
    {
        var predicate = NSPredicate()
        
        if type == ""
        {
            predicate = NSPredicate(format: "(personID == \(personID)) AND (workDate >= %@) AND (workDate < %@) AND (teamID == \(teamID)) AND (updateType != \"Delete\")", searchFrom as CVarArg, searchTo as CVarArg)
        }
        else
        {
            predicate = NSPredicate(format: "(personID == \(personID)) AND (workDate >= %@) AND (workDate < %@) AND (teamID == \(teamID)) AND (type == \"\(type)\") AND (updateType != \"Delete\")", searchFrom as CVarArg, searchTo as CVarArg)
        }
        
        let sem = DispatchSemaphore(value: 0)
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Shifts] = populateShifts(returnArray)
        
        return shiftArray
    }
    
    public func getShifts(projectID: Int64, searchFrom: Date, searchTo: Date, teamID: Int64, type: String = "")->[Shifts]
    {
        var predicate = NSPredicate()
        
        if type == ""
        {
            predicate = NSPredicate(format: "(projectID == \(projectID)) AND (teamID == \(teamID)) AND (workDate >= %@) AND (workDate < %@) AND (updateType != \"Delete\")", searchFrom as CVarArg, searchTo as CVarArg)
        }
        else
        {
            predicate = NSPredicate(format: "(projectID == \(projectID)) AND (teamID == \(teamID)) AND (workDate >= %@) AND (workDate < %@) AND (type == \"\(type)\") AND (updateType != \"Delete\")", searchFrom as CVarArg, searchTo as CVarArg)
        }
        
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Shifts] = populateShifts(returnArray)
        
        return shiftArray
    }
    
    public func getShifts(projectID: Int64, teamID: Int64)->[Shifts]
    {
        let predicate = NSPredicate(format: "(projectID == \(projectID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Shifts] = populateShifts(returnArray)
        
        return shiftArray
    }
    
    func getShiftsNoPersonOrRate(teamID: Int64)->[Shifts]
    {
        let predicate = NSPredicate(format: "(personID == 0) AND (rateID == 0) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Shifts] = populateShifts(returnArray)
        
        return shiftArray
        
    }
    
    func getShiftsNoPerson(teamID: Int64)->[Shifts]
    {
        let predicate = NSPredicate(format: "(personID == 0) AND (rateID != 0) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Shifts] = populateShifts(returnArray)
        
        return shiftArray
        
    }
    
    func getShiftsNoRate(teamID: Int64)->[Shifts]
    {
        let predicate = NSPredicate(format: "(personID != 0) AND (rateID == 0) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Shifts] = populateShifts(returnArray)
        
        return shiftArray
        
    }
    
    func getShiftDetails(_ projectID: Int64, shiftLineID: Int64, weekEndDate: Date, workDate: Date, teamID: Int64)->[Shifts]
    {
        // let predicate = NSPredicate(format: "(shiftID == \(shiftID)) AND (teamID == \(teamID))")
        let predicate = NSPredicate(format: "(projectID == \(projectID)) AND (shiftLineID == \(shiftLineID)) AND (weekEndDate == %@) AND (workDate == %@) AND (teamID == \(teamID))", weekEndDate as CVarArg, workDate as CVarArg) // better be
        
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Shifts] = populateShifts(returnArray)
        
        return shiftArray
        
    }
    
    func getShiftCountForTeam(_ teamID: Int64)->Int64
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        return Int64(returnArray.count)
    }
    
    func deleteShifts(projectID: Int64, shiftLineID: Int64, weekEndDate: Date, workDate: Date, teamID: Int64)
    {
        let predicate = NSPredicate(format: "(projectID == \(projectID)) AND (shiftLineID == \(shiftLineID)) AND (weekEndDate == %@) AND (workDate == %@) AND (teamID == \(teamID))", weekEndDate as CVarArg, workDate as CVarArg)
        //let predicate = NSPredicate(format: "(shiftID == \(shiftID)) AND (teamID == \(teamID))")
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            self.performPublicDelete(records!)
            
            sem.signal()
        })
        sem.wait()
    }
    
    func processUpdateRecord(_ sourceRecord: Shifts, record: CKRecord, sem: DispatchSemaphore)
    {
        record.setValue(sourceRecord.personID, forKey: "personID")
        record.setValue(sourceRecord.startTime, forKey: "startTime")
        record.setValue(sourceRecord.endTime, forKey: "endTime")
        record.setValue(sourceRecord.status, forKey: "status")
        record.setValue(sourceRecord.shiftLineID, forKey: "shiftLineID")
        record.setValue(sourceRecord.rateID, forKey: "rateID")
        record.setValue(sourceRecord.type, forKey: "type")
        record.setValue(sourceRecord.clientInvoiceNumber, forKey: "clientInvoiceNumber")
        record.setValue(sourceRecord.personInvoiceNumber, forKey: "personInvoiceNumber")
        
        if sourceRecord.signInTime != nil
        {
            record.setValue(sourceRecord.signInTime, forKey: "signInTime")
        }
        
        if sourceRecord.signOutTime != nil
        {
            record.setValue(sourceRecord.signOutTime, forKey: "signOutTime")
        }
        
        // Save this record again
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
                    NSLog("Successfully updated record!")
                }
                sem.signal()
            }
        })
    }
    
    func getRecordsForRecordID(_ searchID: CKRecord.ID)
    {
        let operation = CKFetchRecordsOperation(recordIDs: [searchID])
        operation.perRecordCompletionBlock = { record, recordID, error in
            if error != nil {
                print("Error found in getRecordsForRecordID")
            }
            else
            {
                //                print("SearchID = \(searchID)")
                //                if recordID != nil
                //                {
                //                    print("RecordID = \(recordID!)")
                //                }
                //                else
                //                {
                //                    print("No record found")
                //                }
            }
        }
        
        //        operation.completionBlock = {
        //            print("All Completed")
        //        }
        
        //   operation.allowsCellularAccess = true
        operation.database = self.publicDB
        operation.start()
    }
    
    func getRecordsForRecordID(_ sourceRecord: Shifts, recordID: CKRecord.ID?, sem: DispatchSemaphore)
    {
        if recordID != nil
        {
            let operation = CKFetchRecordsOperation(recordIDs: [recordID!])
            operation.perRecordCompletionBlock = { record, recordID, error in
                if error != nil {
                    print("Error found in getRecordsForRecordID")
                }
                else
                {
                    self.processUpdateRecord(sourceRecord, record: record!, sem: sem)
                }
            }
            
            //        operation.completionBlock = {
            //            print("All Completed")
            //        }
            
            //   operation.allowsCellularAccess = true
            operation.database = self.publicDB
            operation.start()
        }
    }
    
    func addSaveRecord(_ sourceRecord: Shifts)
    {
        let record = CKRecord(recordType: "Shifts")
        record.setValue(sourceRecord.shiftID, forKey: "shiftID")
        record.setValue(sourceRecord.projectID, forKey: "projectID")
        record.setValue(sourceRecord.personID, forKey: "personID")
        record.setValue(sourceRecord.workDate, forKey: "workDate")
        record.setValue(sourceRecord.shiftDescription, forKey: "shiftDescription")
        record.setValue(sourceRecord.startTime, forKey: "startTime")
        record.setValue(sourceRecord.endTime, forKey: "endTime")
        record.setValue(sourceRecord.weekEndDate, forKey: "weekEndDate")
        record.setValue(sourceRecord.status, forKey: "status")
        record.setValue(sourceRecord.shiftLineID, forKey: "shiftLineID")
        record.setValue(sourceRecord.rateID, forKey: "rateID")
        record.setValue(sourceRecord.type, forKey: "type")
        record.setValue(sourceRecord.clientInvoiceNumber, forKey: "clientInvoiceNumber")
        record.setValue(sourceRecord.personInvoiceNumber, forKey: "personInvoiceNumber")
        record.setValue(sourceRecord.teamID, forKey: "teamID")
        
        if sourceRecord.signInTime != nil
        {
            record.setValue(sourceRecord.signInTime, forKey: "signInTime")
        }
        
        if sourceRecord.signOutTime != nil
        {
            record.setValue(sourceRecord.signOutTime, forKey: "signOutTime")
        }
        
        saveRecordList.append(record)
    }
    
    func saveShiftsRecordToCloudKit(_ sourceRecord: Shifts, recordID: CKRecord.ID?) -> CKRecord.ID?
    {
        var returnValue: CKRecord.ID? = nil
        
        let sem = DispatchSemaphore(value: 0)
        
        if recordID?.recordName != "" && recordID != nil
        {
            // getRecordsForRecordID(sourceRecord, recordID: CKRecord.ID(recordName: recordID), sem: sem)
            getRecordsForRecordID(sourceRecord, recordID: recordID, sem: sem)
            returnValue = recordID
        }
        else
        {
            ////        let predicate = NSPredicate(format: "(shiftID == \(sourceRecord.shiftID)) AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
            //        predicate = NSPredicate(format: "(projectID == \(sourceRecord.projectID)) AND (shiftLineID == \(sourceRecord.shiftLineID)) AND (weekEndDate == %@) AND (workDate == %@) AND (teamID == \(sourceRecord.teamID))", sourceRecord.weekEndDate! as CVarArg, sourceRecord.workDate! as CVarArg) // better be accurate to get only the record you need
            //
            //            let query = CKQuery(recordType: "Shifts", predicate: predicate)
            //            publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            //                if error != nil
            //                {
            //                    NSLog("Error querying records: \(error!.localizedDescription)")
            //                }
            //                else
            //                {
            //                    // Lets go and get the additional details from the context1_1 tableprint(
            //                    if records!.count > 0
            //                    {
            //                        let record = records!.first// as! CKRecord
            //                        // Now you have grabbed your existing record from iCloud
            //                        // Apply whatever changes you want
            //
            //                        self.processUpdateRecord(sourceRecord, record: record!, sem: sem)
            //                    }
            //                    else
            //                    {  // Insert
            let record = CKRecord(recordType: "Shifts")
            record.setValue(sourceRecord.shiftID, forKey: "shiftID")
            record.setValue(sourceRecord.projectID, forKey: "projectID")
            record.setValue(sourceRecord.personID, forKey: "personID")
            record.setValue(sourceRecord.workDate, forKey: "workDate")
            record.setValue(sourceRecord.shiftDescription, forKey: "shiftDescription")
            record.setValue(sourceRecord.startTime, forKey: "startTime")
            record.setValue(sourceRecord.endTime, forKey: "endTime")
            record.setValue(sourceRecord.weekEndDate, forKey: "weekEndDate")
            record.setValue(sourceRecord.status, forKey: "status")
            record.setValue(sourceRecord.shiftLineID, forKey: "shiftLineID")
            record.setValue(sourceRecord.rateID, forKey: "rateID")
            record.setValue(sourceRecord.type, forKey: "type")
            record.setValue(sourceRecord.clientInvoiceNumber, forKey: "clientInvoiceNumber")
            record.setValue(sourceRecord.personInvoiceNumber, forKey: "personInvoiceNumber")
            record.setValue(sourceRecord.teamID, forKey: "teamID")
            
            if sourceRecord.signInTime != nil
            {
                record.setValue(sourceRecord.signInTime, forKey: "signInTime")
            }
            
            if sourceRecord.signOutTime != nil
            {
                record.setValue(sourceRecord.signOutTime, forKey: "signOutTime")
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
                    returnValue = (savedRecord?.recordID)!
                    
                    sem.signal()
                }
            })
            //                    }
            //                }
            //            })
        }
        sem.wait()

        if returnValue != nil
        {
            return returnValue
        }
        else
        {
            return nil
        }
    }
    
    public func getEarliestShift(teamID: Int64)->[Shifts]
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        let sortDescriptor = NSSortDescriptor(key: "workDate", ascending: true)
        
        let sem = DispatchSemaphore(value: 0)
        var returnArray: [Shifts] = Array()
        
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        query.sortDescriptors = [sortDescriptor]
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            returnArray = self.populateShifts(records!)
            
            sem.signal()
        })
        sem.wait()
        
        return returnArray
    }
}

