//
//  personClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 11/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CloudKit
import SwiftUI

public struct monthlyPersonFinancialsStruct
{
    var month: Int64
    var year: Int64
    var wage: Double
    var hours: Double
}

public let genderList = [ "Undeclared", "Male", "Female"]

public class people: NSObject, Identifiable
{
    public let id = UUID()
    public var myPeople:[person] = Array()
    fileprivate var myRawData: [Person] = Array()
    
    public init(teamID: Int64, isActive: Bool)
    {
        super.init()
        
        if currentUser.currentTeam?.peopleList == nil
        {
            currentUser.currentTeam?.peopleList = myCloudDB.getPeople(teamID: teamID, isActive: isActive)
        }
        
        for myItem in (currentUser.currentTeam?.peopleList)!
        {
            let dob: Date = myItem.dob
            
            var tempFirstName: String = ""
            var tempTitle: String = ""
            tempFirstName = myItem.firstName
            tempTitle = myItem.title
            
            let myObject = person(personID: myItem.personID,
                                  name: myItem.name,
                                  dob: dob,
                                  teamID: myItem.teamID,
                                  gender: myItem.gender,
                                  note: myItem.note,
                                  clientID: myItem.clientID,
                                  projectID: myItem.projectID,
                                  canRoster: myItem.canRoster,
                                  firstName: tempFirstName,
                                  title: tempTitle,
                                  emailOptIn: myItem.emailOptIn,
                                  isActive: myItem.isActive,
                                  useAllowanceHours: myItem.useAllowanceHours
            )
            myPeople.append(myObject)
        }
        sortArray()
    }
    
    public init(teamID: Int64, canRoster: Bool)
    {
        super.init()
        
        if currentUser.currentTeam?.peopleList == nil
        {
            currentUser.currentTeam?.peopleList = myCloudDB.getPeople(teamID: teamID, isActive: true)
        }
        
        var workingArray: [Person] = Array()
        
        for item in (currentUser.currentTeam?.peopleList)!
        {
            if canRoster
            {
                if (item.canRoster)
                {
                    workingArray.append(item)
                }
            }
            else
            {
                workingArray.append(item)
            }
        }
        
        for myItem in workingArray
        {
            let dob: Date = myItem.dob
            
            var tempFirstName: String = ""
            var tempTitle: String = ""
            tempFirstName = myItem.firstName
            tempTitle = myItem.title

            let myObject = person(personID: myItem.personID,
                                  name: myItem.name,
                                  dob: dob,
                                  teamID: myItem.teamID,
                                  gender: myItem.gender,
                                  note: myItem.note,
                                  clientID: myItem.clientID,
                                  projectID: myItem.projectID,
                                  canRoster: myItem.canRoster,
                                  firstName: tempFirstName,
                                  title: tempTitle,
                                  emailOptIn: myItem.emailOptIn,
                                  isActive: true,
                                  useAllowanceHours: myItem.useAllowanceHours
            )
            myPeople.append(myObject)
        }
        sortArray()
    }
    
    public init(clientID: Int64, teamID: Int64, onlyActive: Bool)
    {
        super.init()
        
        if currentUser.currentTeam?.peopleList == nil
        {
            currentUser.currentTeam?.peopleList = myCloudDB.getPeople(teamID: teamID, isActive: onlyActive)
        }
        
        var workingArray: [Person] = Array()
        
        for item in (currentUser.currentTeam?.peopleList)!
        {
            if item.clientID == clientID
            {
                workingArray.append(item)
            }
        }
        
        for myItem in workingArray
        {
            let dob: Date = myItem.dob
            
            var tempFirstName: String = ""
            var tempTitle: String = ""
            tempFirstName = myItem.firstName
            tempTitle = myItem.title
            
            let myObject = person(personID: myItem.personID,
                                  name: myItem.name,
                                  dob: dob,
                                  teamID: myItem.teamID,
                                  gender: myItem.gender,
                                  note: myItem.note,
                                  clientID: myItem.clientID,
                                  projectID: myItem.projectID,
                                  canRoster: myItem.canRoster,
                                  firstName: tempFirstName,
                                  title: tempTitle,
                                  emailOptIn: myItem.emailOptIn,
                                  isActive: myItem.isActive,
                                  useAllowanceHours: myItem.useAllowanceHours
            )
            myPeople.append(myObject)
        }
        sortArray()
    }
    
    public init(projectID: Int64, teamID: Int64, onlyActive: Bool)
    {
        super.init()
        
        if currentUser.currentTeam?.peopleList == nil
        {
            currentUser.currentTeam?.peopleList = myCloudDB.getPeople(teamID: teamID, isActive: onlyActive)
        }
        
        var workingArray: [Person] = Array()
        
        for item in (currentUser.currentTeam?.peopleList)!
        {
            if item.projectID == projectID
            {
                workingArray.append(item)
            }
        }
        
        for myItem in workingArray
        {
            let dob: Date = myItem.dob
            
            var tempFirstName: String = ""
            var tempTitle: String = ""
            tempFirstName = myItem.firstName
            tempTitle = myItem.title
            
            let myObject = person(personID: myItem.personID,
                                  name: myItem.name,
                                  dob: dob,
                                  teamID: myItem.teamID,
                                  gender: myItem.gender,
                                  note: myItem.note,
                                  clientID: myItem.clientID,
                                  projectID: myItem.projectID,
                                  canRoster: myItem.canRoster,
                                  firstName: tempFirstName,
                                  title: tempTitle,
                                  emailOptIn: myItem.emailOptIn,
                                  isActive: myItem.isActive,
                                  useAllowanceHours: myItem.useAllowanceHours
            )
            myPeople.append(myObject)
        }
        sortArray()
    }
    
    public init(peopleList: [Int64], teamID: Int64) {
        myRawData = myCloudDB.getPeople(peopleList: peopleList, teamID: teamID)
        
        if myRawData.count > 0 {
            myRawData.sort {
                    if $0.fullName == $1.fullName {
                        return $0.name < $1.name
                    }
                    else {
                        return $0.fullName < $1.fullName
                    }
            }
        }
    }
    
    var rawData: [Person] {
        get {
            return myRawData
        }
    }
    
    public func sortArray()
    {
        if myPeople.count > 0
        {
            myPeople.sort
                {
                    // Because workdate has time it throws everything out
                    
                    if $0.name == $1.name
                    {
                        return $0.dob < $1.dob
                    }
                    else
                    {
                        return $0.name < $1.name
                    }
            }
        }
    }
    
    public func append( _ newItem: person)
    {
        myPeople.append(newItem)
        sortArray()
    }
    
    public func remove(_ personID: Int64)
    {
        var recordCount = 0
        
        for item in myPeople
        {
            if item.personID == personID
            {
                break
            }
            recordCount += 1
        }
        myPeople.remove(at: recordCount)
    }
    
    public var people: [person]
    {
        get
        {
            return myPeople
        }
    }
    
    func checkShifts(shiftList: shifts) -> [person] {
        var workingArray: [person] = Array()

        // get list of shifts for the month

        for myItem in myPeople {
            // See if the person has any shifts in the month

            for myShift in shiftList.shifts {
                if myShift.personID == myItem.personID {
                    workingArray.append(myItem)
                    break
                }
            }
        }

        if workingArray.count > 0 {
            workingArray.sort {
                    // Because workdate has time it throws everything out
                    
                    if $0.name == $1.name {
                        return $0.dob < $1.dob
                    } else {
                        return $0.name < $1.name
                    }
            }
        }
        
        return workingArray
    }
    
    public var peopleNames: [String]
    {
        get
        {
            var temp: [String] = Array()
            
            for item in myPeople {
                temp.append(item.name)
            }
            
            return temp
        }
    }
    
    public func personRecord(_ searchText: String) -> person? {
        for item in myPeople {
            if item.name == searchText {
                return item
            }
        }
        return nil
    }
}

let newPersonDefault = "No name entered"
public class person: NSObject, Identifiable, ObservableObject
{
    public let id = UUID()
    fileprivate var myPersonID: Int64 = 0
    fileprivate var myClientID: Int64 = 0
    fileprivate var myProjectID: Int64 = 0
    fileprivate var myName: String = ""
    fileprivate var myGender: String = ""
    fileprivate var myNote: String = ""
    fileprivate var myDob: Date = getDefaultDate()
    fileprivate var myAddresses: personAddresses!
    fileprivate var myContacts: personContacts!
    public var addInfo: personAddInfoEntries!
    fileprivate var myTeamID: Int64 = 0
    fileprivate var myCanRoster: Bool = true
    public var tempArray: [Any] = Array()
    fileprivate var myFirstName: String = ""
    fileprivate var myTitle: String = ""
    fileprivate var myEmailOptIn: Bool = false
    fileprivate var myIsActive: Bool = true
    fileprivate var mySessions: sessionNotes!
    fileprivate var myuseAllowanceHours: Bool = false
    fileprivate var myMonthlyAllow: [allowanceUnitsitem] = Array()
    fileprivate var myMonthYear: String = ""
    fileprivate var myInvoices: clientInvoices!
    
    @Published var reloadScreen = false
    
    var personLoaded = false
    
    public var personID: Int64
    {
        get
        {
            return myPersonID
        }
    }
    
    public var teamID: Int64
    {
        get
        {
            return myTeamID
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
            reloadScreen.toggle()
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
            reloadScreen.toggle()
        }
    }
    
    public var lastName: String
    {
        get
        {
            return myName
        }
        set
        {
            myName = newValue
            currentUser.currentTeam?.peopleList = nil
            reloadScreen.toggle()
        }
    }
    
    public var firstName: String
    {
        get
        {
            return myFirstName
        }
        set
        {
            myFirstName = newValue
            currentUser.currentTeam?.peopleList = nil
            reloadScreen.toggle()
        }
    }
    
    public var name: String
    {
        get
        {
            if (myFirstName == "") && (myName == "")
            {
                return(newPersonDefault)
            }
            
            if (myFirstName == "")
            {
                return(myName)
            }
            
            if (myName == "")
            {
                return(myFirstName)
            }
            
            return "\(myFirstName) \(myName)"
        }
    }
    
    
    public var title: String
    {
        get
        {
            return myTitle
        }
        set
        {
            myTitle = newValue
            reloadScreen.toggle()
        }
    }
    
    public var gender: String
    {
        get
        {
            if myGender == ""
            {
                return "Select"
            }
            else
            {
                return myGender
            }
        }
        set
        {
            myGender = newValue
            reloadScreen.toggle()
        }
    }
    
    public var note: String
    {
        get
        {
            return myNote
        }
        set
        {
            myNote = newValue
            reloadScreen.toggle()
        }
    }
    
    public var dob: Date
    {
        get
        {
            if myDob == getDefaultDate()
            {
                return Date()
            }
            return myDob
        }
        set
        {
            myDob = newValue
            currentUser.currentTeam?.peopleList = nil
            reloadScreen.toggle()
        }
    }
    
    public var addresses: [address]
    {
        get
        {
            if myAddresses == nil
            {
                return []
            }
            else
            {
                return myAddresses.addresses
            }
        }
    }
    
    public var contacts: [contactItem]
    {
        get
        {
            if myContacts == nil
            {
                return []
            }
            else
            {
                return myContacts.contacts
            }
        }
    }
    
//    public var addInfo: [personAddInfoEntry]
//    {
//        get
//        {
//            if myAddInfo == nil
//            {
//                return []
//            }
//            else
//            {
//                return myAddInfo.personAddEntries
//            }
//        }
//    }
    
    public var dobText: String
    {
        get
        {
            if myDob == getDefaultDate()
            {
                return "Select"
            }
            else
            {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                
                return dateFormatter.string(from: myDob)
            }
        }
    }
    
    public var canRoster: Bool
    {
        get
        {
            return myCanRoster
        }
        set
        {
            myCanRoster = newValue
            reloadScreen.toggle()
        }
    }
    
    public var emailOptIn: Bool
    {
        get
        {
            return myEmailOptIn
        }
        set
        {
            myEmailOptIn = newValue
            reloadScreen.toggle()
        }
    }
    
    public var isActive: Bool
    {
        get
        {
            return myIsActive
        }
        set
        {
            myIsActive = newValue
            currentUser.currentTeam?.peopleList = nil
            reloadScreen.toggle()
        }
    }
    
    public var useAllowanceHours: Bool
    {
        get
        {
            return myuseAllowanceHours
        }
        set
        {
            myuseAllowanceHours = newValue
            reloadScreen.toggle()
        }
    }
    
    public var sessions: [sessionNote]
    {
        get
        {
            return mySessions!.noteList
        }
    }
    
    public var invoices: clientInvoices?
    {
        get
        {
            return myInvoices
        }
    }
    
    public init(teamID: Int64)
    {
        super.init()
        
        createPerson(teamID: teamID)
    }
    
    public init(teamID: Int64, taskOwner: String)
    {
        super.init()
        
        createPerson(teamID: teamID, personName: taskOwner)
    }
    
    public init(teamID: Int64, newName: String)
    {
        super.init()
        
        createPerson(teamID: teamID, personName: newName)
    }
    
    public init(personID: Int64, teamID: Int64)
    {
        super.init()
        
        loadPerson(personID: personID, teamID: teamID)

    }
    
    public func createPerson(teamID: Int64, personName: String = "")
    {
        myPersonID = myCloudDB.dateAsInt()
        myTeamID = teamID
        myName = personName
            
        currentUser.currentTeam?.peopleList = nil
        
        
        myDob = getDefaultDate()
        myGender = ""
        myNote = ""
        myClientID = 0
        myProjectID = 0
        myCanRoster = true
        myFirstName = ""
        myTitle = ""
        myEmailOptIn = false
        myIsActive = true
        myuseAllowanceHours = false
        
        myAddresses = nil
        myContacts = nil
        addInfo = nil
        
        tempArray.removeAll()
        mySessions = nil
        myMonthlyAllow.removeAll()
        myMonthYear = ""
        myInvoices = nil
        
        personLoaded = true
        
        save()
    }
    
    public func loadPerson(personID: Int64, teamID: Int64)
    {
        if currentUser.currentTeam?.peopleList == nil
        {
            currentUser.currentTeam?.peopleList = myCloudDB.getPeople(teamID: teamID, isActive: true)
        }
        
        var myItem: Person!
        
        for item in (currentUser.currentTeam?.peopleList)!
        {
            if item.personID == personID
            {
                myItem = item
                break
            }
        }
        // Gaza update thes to wrap all text with nil check
        if myItem != nil
        {
            myPersonID = myItem.personID
            myName = myItem.name
            
            myDob = myItem.dob
            myTeamID = myItem.teamID
            myGender = myItem.gender

            myNote = myItem.note
            
            myClientID = myItem.clientID
            myProjectID = myItem.projectID

            myCanRoster = myItem.canRoster

            myFirstName = myItem.firstName

            myTitle = myItem.title

            myEmailOptIn = myItem.emailOptIn
            myIsActive = myItem.isActive
            myuseAllowanceHours = myItem.useAllowanceHours
            
            myAddresses = nil
            myContacts = nil
            addInfo = nil
            
            tempArray.removeAll()
            mySessions = nil
            myMonthlyAllow.removeAll()
            myMonthYear = ""
            myInvoices = nil
            
            personLoaded = true

        }
    }
    
    override init()
    {
        
    }
    
    public init(name: String, teamID: Int64)
    {
        super.init()
        
        var myItem: Person!
        
        if currentUser.currentTeam?.peopleList == nil
        {
            currentUser.currentTeam?.peopleList = myCloudDB.getPeople(teamID: teamID, isActive: true)
        }
        
        for item in (currentUser.currentTeam?.peopleList)!
        {
            if item.name == name
            {
                myItem = item
                break
            }
        }
        
        if myItem != nil
        {
            myPersonID = myItem.personID
            myName = myItem.name
            myDob = myItem.dob
            myTeamID = myItem.teamID
            myGender = myItem.gender
            myNote = myItem.note
            myClientID = myItem.clientID
            myProjectID = myItem.projectID
            myCanRoster = myItem.canRoster
            myIsActive = myItem.isActive
            myuseAllowanceHours = myItem.useAllowanceHours
            
            myFirstName = myItem.firstName
            myTitle = myItem.title

            myEmailOptIn = myItem.emailOptIn
        }
    }
    
    public init(personID: Int64,
                name: String,
                dob: Date,
                teamID: Int64,
                gender: String,
                note: String,
                clientID: Int64,
                projectID: Int64,
                canRoster: Bool,
                firstName: String,
                title: String,
                emailOptIn: Bool,
                isActive: Bool,
                useAllowanceHours: Bool
        )
    {
        super.init()
        
        myPersonID = personID
        myName = name
        myDob = dob
        myTeamID = teamID
        myGender = gender
        myNote = note
        myClientID = clientID
        myProjectID = projectID
        myCanRoster = canRoster
        myFirstName = firstName
        myTitle = title
        myEmailOptIn = emailOptIn
        myIsActive = isActive
        myuseAllowanceHours = useAllowanceHours
    }
    
    public func save()
    {
        let temp = Person(canRoster: myCanRoster, clientID: myClientID, dob: dob, gender: myGender, name: myName, note: myNote, personID: myPersonID, projectID: myProjectID, teamID: myTeamID,
                          firstName: myFirstName,
                          title: myTitle,
                          emailOptIn: myEmailOptIn, isActive: myIsActive, useAllowanceHours: myuseAllowanceHours, fullName: "\(myFirstName) \(myName)")
        
        myCloudDB.savePersonRecordToCloudKit(temp)
    }
    
    public func delete()
    {
        if currentUser.checkWritePermission(hrRoleType)
        {
            myCloudDB.deletePerson(myPersonID, teamID: myTeamID)
            currentUser.currentTeam?.peopleList = nil
        }
    }
    
    public func deleteAddress(addressType: String)
    {
        for myItem in myAddresses.addresses
        {
            if myItem.addressType == addressType
            {
                myItem.delete()
                break
            }
        }
        
        loadAddresses()
    }
    
    public func loadAddresses()
    {
        myAddresses = personAddresses(personID: myPersonID, teamID: myTeamID)
    }
    
    public func removeContact(contactType: String)
    {
        for myItem in myContacts.contacts
        {
            if myItem.contactType == contactType
            {
                myItem.delete()
                break
            }
        }
        
        loadContacts()
    }
    
    public func loadContacts()
    {
        myContacts = personContacts(personID: myPersonID, teamID: myTeamID)
    }
    
    public func removeAddInfo(addInfoType: String)
    {
        for myItem in addInfo.personAddEntries
        {
            if myItem.addInfoName == addInfoType
            {
                myItem.delete()
                break
            }
        }
        
        loadAddInfo()
    }
    
    public func loadAddInfo()
    {
        addInfo = personAddInfoEntries(personID: myPersonID, teamID: myTeamID)
    }
    
    public func loadSessions()
    {
        mySessions = sessionNotes(personID: myPersonID, teamID: myTeamID)
    }
    
    public func allowanceHours(_ monthYear: String) -> [allowanceUnitsitem]
    {
        if monthYear == myMonthYear
        {
            return myMonthlyAllow
        }
        else
        {
            let temp = allowanceUnits(teamID: currentUser.currentTeam!.teamID, monthYear: monthYear, personID: myPersonID)
            
            myMonthlyAllow = temp.getRecords(myPersonID)
            
            myMonthYear = monthYear
            
            return myMonthlyAllow
        }
    }
    
    func loadInvoices(_ isActive: Bool)
    {
        myInvoices = clientInvoices(teamID: currentUser.currentTeam!.teamID, personID: myPersonID, isActive: isActive)
    }
    
    func shareMonthlyRoster () -> String {
        var returnString = "\(currentUser.currentTeam!.name) - Roster for \(name)\n\n"
        
        for item in shiftArray {
            returnString += "\(item.workDateString) \(item.startTimeString) - \(item.endTimeString) \(item.projectName)\n\n"
        }
        
        return returnString
    }
}

extension alerts
{
    func personTaskLinkAlerts()
    {
        if currentUser.personTaskLink <= 0
        {
            let alertEntry = alertItem()
            
            alertEntry.displayText = "You need to create a link to a person entry so Actions can be assigned to you."
            alertEntry.name = "Housekeeping"
            alertEntry.source = "PersonTask"
            alertEntry.object = currentUser.personTaskLink
            
            alertList.append(alertEntry)
        }
    }
}

public struct Person {
    public var canRoster: Bool
    public var clientID: Int64
    public var dob: Date
    public var gender: String
    public var name: String
    public var note: String
    public var personID: Int64
    public var projectID: Int64
    public var teamID: Int64
    public var firstName: String
    public var title: String
    public var emailOptIn: Bool
    public var isActive: Bool
    public var useAllowanceHours: Bool
    public var fullName: String
}

extension CloudKitInteraction
{
    private func populatePerson(_ records: [CKRecord]) -> [Person]
    {
        var tempArray: [Person] = Array()
        
        for record in records
        {
            var displayFullName = record.object(forKey: "name") as! String
            var firstName = ""
          
            if record.object(forKey: "firstName") != nil {
                firstName = record.object(forKey: "firstName") as! String
                
                if firstName == "" || firstName == " " {
                    let _ = 1
                } else {
                    displayFullName = "\(firstName) \(record.object(forKey: "name") as! String)"
                }
            }
            
            let tempItem = Person(canRoster: decodeBool(record.object(forKey: "canRoster"), defaultReturn: true),
                                  clientID: decodeInt64(record.object(forKey: "clientID")),
                                  dob: decodeDate(record.object(forKey: "dob")),
                                  gender: decodeString(record.object(forKey: "gender")),
                                  name: decodeString(record.object(forKey: "name")),
                                  note: decodeString(record.object(forKey: "note")),
                                  personID: decodeInt64(record.object(forKey: "personID")),
                                  projectID: decodeInt64(record.object(forKey: "projectID")),
                                  teamID: decodeInt64(record.object(forKey: "teamID")),
                                  firstName: firstName,
                                  title: decodeString(record.object(forKey: "title")),
                                  emailOptIn: decodeBool(record.object(forKey: "emailOptIn"), defaultReturn: false),
                                  isActive: decodeBool(record.object(forKey: "isActive"), defaultReturn: true),
                                  useAllowanceHours: decodeBool(record.object(forKey: "useAllowanceHours"), defaultReturn: false),
                                  fullName: displayFullName
            )
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getPeople(teamID: Int64, isActive: Bool)->[Person]
    {
        var predicate: NSPredicate!
        
        if isActive
        {
            predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\") AND (isActive != \"false\")")
        }
        else
        {
            predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\")")
        }
        
        let query = CKQuery(recordType: "Person", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Person] = populatePerson(returnArray)
        
        return shiftArray
    }
    
    func getPeople(teamID: Int64, canRoster: Bool)->[Person]
    {
        var predicate: NSPredicate!
        
        if canRoster
        {
            predicate = NSPredicate(format: "(updateType != \"Delete\") AND (teamID == \(teamID)) AND (canRoster == \"True\") AND (isActive != \"false\")")
        }
        else
        {
            predicate = NSPredicate(format: "(updateType != \"Delete\") AND (teamID == \(teamID)) AND (isActive != \"false\")")
        }
        
        let query = CKQuery(recordType: "Person", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Person] = populatePerson(returnArray)
        
        return shiftArray
    }
    
    func getPeople(teamID: Int64, useAllowanceHours: Bool)->[Person]
    {
        let predicate = NSPredicate(format: "(updateType != \"Delete\") AND (teamID == \(teamID)) AND (useAllowanceHours == \"true\")")
        
        let query = CKQuery(recordType: "Person", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Person] = populatePerson(returnArray)
        
        return shiftArray
    }
    
    func getPeople(peopleList: [Int64], teamID: Int64)->[Person] {
        if peopleList.count > 0 {
            var queryList = ""
            
            for item in peopleList {
                if queryList == "" {
                    queryList = "\(item)"
                } else {
                    queryList += ", \(item)"
                }
            }
            
            let predicate = NSPredicate(format: "(personID IN {\(queryList)}) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
            
            let query = CKQuery(recordType: "Person", predicate: predicate)
            let sem = DispatchSemaphore(value: 0)
            fetchServices(query: query, sem: sem, completion: nil)
            
            sem.wait()
            
            let shiftArray: [Person] = populatePerson(returnArray)
            
            return shiftArray
        } else {
            return []
        }
    }
    
    func getPeopleForClient(clientID: Int64, teamID: Int64, onlyActive: Bool)->[Person]
    {
        var predicate: NSPredicate!
        
        if onlyActive
        {
            predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\") AND (clientID == \(clientID)) AND (isActive != \"false\")")
        }
        else
        {
            predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\") AND (clientID == \(clientID))")
        }
        
        let query = CKQuery(recordType: "Person", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Person] = populatePerson(returnArray)
        
        return shiftArray
    }
    
    func getPeopleForProject(projectID: Int64, teamID: Int64, onlyActive: Bool)->[Person]
    {
        var predicate: NSPredicate!
        
        if onlyActive
        {
            predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\") AND (projectID == \(projectID)) AND (isActive != \"false\")")
        }
        else
        {
            predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\") AND (projectID == \(projectID))")
        }
        
        let query = CKQuery(recordType: "Person", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Person] = populatePerson(returnArray)
        
        return shiftArray
    }
    
    func getPersonDetails(personID: Int64, teamID: Int64)->[Person]
    {
        let predicate = NSPredicate(format: "(personID == \(personID)) AND (teamID == \(teamID))")
        
        let query = CKQuery(recordType: "Person", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Person] = populatePerson(returnArray)
        
        return shiftArray
    }
    
    func getPersonDetails(name: String, teamID: Int64)->[Person]
    {
        let predicate = NSPredicate(format: "(name == \"\(name)\") AND (teamID == \(teamID))")
        
        let query = CKQuery(recordType: "Person", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Person] = populatePerson(returnArray)
        
        return shiftArray
    }
    
    func deletePerson(_ personID: Int64, teamID: Int64)
    {
        let predicate = NSPredicate(format: "(personID == \(personID)) AND (teamID == \(teamID))")
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "Person", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            self.performPublicDelete(records!)
            
            sem.signal()
        })
        sem.wait()
    }
    
    func savePersonRecordToCloudKit(_ sourceRecord: Person)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(personID == \(sourceRecord.personID)) AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Person", predicate: predicate)
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
                    
                    record!.setValue(sourceRecord.name, forKey: "name")
                    record!.setValue(sourceRecord.dob, forKey: "dob")
                    record!.setValue(sourceRecord.gender, forKey: "gender")
                    record!.setValue(sourceRecord.note, forKey: "note")
                    record!.setValue(sourceRecord.clientID, forKey: "clientID")
                    record!.setValue(sourceRecord.projectID, forKey: "projectID")
                    record!.setValue(sourceRecord.firstName, forKey: "firstName")
                    record!.setValue(sourceRecord.title , forKey: "title")
                    
                    if sourceRecord.emailOptIn
                    {
                        record!.setValue("True", forKey: "emailOptIn")
                    }
                    else
                    {
                        record!.setValue("False", forKey: "emailOptIn")
                    }
                    
                    if sourceRecord.isActive
                    {
                        record!.setValue("true", forKey: "isActive")
                    }
                    else
                    {
                        record!.setValue("false", forKey: "isActive")
                    }
                    
                    if sourceRecord.canRoster
                    {
                        record!.setValue("true", forKey: "canRoster")
                    }
                    else
                    {
                        record!.setValue("false", forKey: "canRoster")
                    }
                    
                    if sourceRecord.useAllowanceHours
                    {
                        record!.setValue("true", forKey: "useAllowanceHours")
                    }
                    else
                    {
                        record!.setValue("false", forKey: "useAllowanceHours")
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
                    let record = CKRecord(recordType: "Person")
                    record.setValue(sourceRecord.personID, forKey: "personID")
                    record.setValue(sourceRecord.name, forKey: "name")
                    record.setValue(sourceRecord.dob, forKey: "dob")
                    record.setValue(sourceRecord.gender, forKey: "gender")
                    record.setValue(sourceRecord.note, forKey: "note")
                    record.setValue(sourceRecord.clientID, forKey: "clientID")
                    record.setValue(sourceRecord.projectID, forKey: "projectID")
                    record.setValue(sourceRecord.firstName, forKey: "firstName")
                    record.setValue(sourceRecord.title , forKey: "title")
                    
                    if sourceRecord.canRoster
                    {
                        record.setValue("true", forKey: "canRoster")
                    }
                    else
                    {
                        record.setValue("false", forKey: "canRoster")
                    }
                    
                    if sourceRecord.emailOptIn
                    {
                        record.setValue("True", forKey: "emailOptIn")
                    }
                    else
                    {
                        record.setValue("False", forKey: "emailOptIn")
                    }
                    
                    if sourceRecord.isActive
                    {
                        record.setValue("true", forKey: "isActive")
                    }
                    else
                    {
                        record.setValue("false", forKey: "isActive")
                    }
                    
                    if sourceRecord.useAllowanceHours
                    {
                        record.setValue("true", forKey: "useAllowanceHours")
                    }
                    else
                    {
                        record.setValue("false", forKey: "useAllowanceHours")
                    }
                    
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
    
    func getDeletedPeople(_ teamID: Int64)->[Person]
    {
        let predicate = NSPredicate(format: "(updateType == \"Delete\") AND (teamID == \(teamID))")
        
        let query = CKQuery(recordType: "Clients", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Person] = populatePerson(returnArray)
        
        return shiftArray
    }
}
