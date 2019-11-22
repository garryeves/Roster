//
//  UsersClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 11/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
//import CoreData
import CloudKit
import SwiftUI

public let NotificationUserLoaded = Notification.Name("NotificationUserLoaded")
public let NotificationUserListLoaded = Notification.Name("NotificationUserListLoaded")

class menuArray: Identifiable
{
    public let id = UUID()
    var menuText: String = ""
    var menuAction: String = ""
    var index: Int64 = 0
    var itemID: Int = 0
    var parentID: Int = 0
    var display: Bool = false
    
    public init(menuTextx: String, menuActionx: String, indexx: Int64, IDx: Int, parentIDx: Int, displayx: Bool)
    {
        menuText = menuTextx
        menuAction = menuActionx
        index = indexx
        itemID = IDx
        parentID = parentIDx
        display = displayx
    }
}

public class userItems: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myUsers: [Users]!
    
    public init(userList: String)
    {
        super.init()
        
        // Call to cloudkey top get the list of users details
                
        myUsers = myCloudDB.getUsersList(userList: userList)
    }
    
    public init(executeMe: Bool)
    {
        if executeMe
        {
            let temp = myCloudDB.getAllUsersTeamS()
            for item in temp
            {
                if myCloudDB.getUserRoles(userID: item.userID, teamID: item.teamID, roleType: clientRoleType).count == 0
                {
                print("User id = \(item.userID) teamID = \(item.teamID)")
                    
                    
                    let myItem = userRoleItem(userID: item.userID, roleType: clientRoleType, teamID: item.teamID, roleID: -1)
                   myItem.accessLevel = writePermission
                }
                
                if myCloudDB.getUserRoles(userID: item.userID, teamID: item.teamID, roleType: hrRoleType).count == 0
                {
                    print("User id = \(item.userID) teamID = \(item.teamID)")
                    
                    
                    let myItem = userRoleItem(userID: item.userID, roleType: hrRoleType, teamID: item.teamID, roleID: -1)
                    myItem.accessLevel = writePermission
                }
            }
        }
    }
    
    public var users: [Users]
    {
        return myUsers
    }
}

public class userItem: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myUserID: Int64 = 0
    fileprivate var myRoles: userRoles!
    fileprivate var myTeams: [team] = Array()
    fileprivate var myAuthorised: Bool = false
    fileprivate var myName: String = ""
    fileprivate var myPhraseDate: Date = getDefaultDate()
    fileprivate var myEmail: String = ""
    fileprivate var myPassPhrase: String = ""
    fileprivate var myCurrentTeam: team!
    fileprivate var myPersonID: Int64 = 0
    fileprivate var mydefaultCalendar: String = ""
    fileprivate var myTeamList: userTeams!
    fileprivate var myMenuOptions: [menuArray] = Array()

    fileprivate let defaultsName = "group.com.garryeves.EvesCRM"
    
    public var userID: Int64
    {
        get
        {
            return myUserID
        }
    }
    
    public var roles: userRoles
    {
        get
        {
            return myRoles
        }
    }
    
    public var isAuthorised: Bool
    {
        get
        {
            return myAuthorised
        }
    }
    
    public var name: String
    {
        get
        {
            return myName
        }
        set
        {
            myName = newValue
        }
    }
    
    public var email: String
    {
        get
        {
            return myEmail
        }
        set
        {
            myEmail = newValue
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
    
    public var phraseDate: Date
    {
        get
        {
            return myPhraseDate
        }
        set
        {
            myPhraseDate = newValue
        }
    }
    
    public var phraseDateText: String
    {
        get
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            
            return dateFormatter.string(from: myPhraseDate)
        }
    }
    
    public var passPhrase: String
    {
        get
        {
            return myPassPhrase
        }
        set
        {
            myPassPhrase = newValue
        }
    }
    
    public var currentTeam: team?
    {
        get
        {
            return myCurrentTeam
        }
        set
        {
            var foundBool = false
            
            for myItem in myTeams
            {
                if myItem.teamID == newValue!.teamID
                {
                    foundBool = true
                    break
                }
            }
            
            if foundBool
            {
                myCurrentTeam = newValue
                loadRoles()
            }
        }
    }
    
    public var personTaskLink: Int64
    {
        get
        {
            if currentTeam!.teamID == 0
            {
                // No team set
                return 0
            }
            
            let entryName = "Team \(currentTeam!.teamID) person link"

            return Int64(readDefaultInt(entryName))
        }
        set
        {
            if currentTeam!.teamID != 0
            {
                let entryName = "Team \(currentTeam!.teamID) person link"
                
                writeDefaultInt(entryName, value: Int(newValue))
            }
        }
    }
    
    public var defaultCalendar: String
    {
        get
        {
            return mydefaultCalendar
        }
        set
        {
            mydefaultCalendar = newValue
        }
    }
    
    public var teamList: userTeams
    {
        get {
            return myTeamList
        }
    }
    
    var menuOptions: [menuArray]
    {
        get {
            return myMenuOptions.filter { $0.display == true }
        }
    }
    
    public init(currentTeam: team, userName: String, userEmail: String)
    {
        super.init()

        // Create a new user
        
        myCurrentTeam = currentTeam
        myName = userName
        myEmail = userEmail
        
        let returnArray = myCloudDB.checkExistingUser(email: myEmail)
        if returnArray.count > 0
        {
            if returnArray[0].userID > 0
            {
                myUserID = returnArray[0].userID
            }
        }
        else
        {
            // Create a user record
            myUserID = myCloudDB.getAllUserCount() + 1
            
            // Now lets call to create the team in cloudkit
            
            if myCloudDB.createNewUser(myUserID, name: myName, email: myEmail)
            {
                myAuthorised = true
                
                // Check to see if already a member of the team
                
                var teamFound: Bool = false
                
                for myItem in userTeams(userID: myUserID).UserTeams
                {
                    if myItem.teamID == myCurrentTeam.teamID
                    {
                        teamFound = true
                        break
                    }
                }
                
                if !teamFound
                {
                    addTeamToUser(myCurrentTeam)
                }
            }
        }
    }
    
    override public init()
    {
        super.init()
    }
    
    public init(userID: Int64)
    {
        super.init()

        myUserID = userID
        
        loadTeams()
        
        if currentTeam != nil
        {
            loadRoles()
        }
    }
    
    public func checkReadPermission(_ roleType: String) -> Bool
    {
        if myRoles == nil
        {
            myRoles = userRoles(userID: myUserID, teamID: myCurrentTeam!.teamID)
        }
        
        for item in myRoles.userRole
        {
            if item.roleType == roleType
            {
                if item.accessLevel == writePermission || item.accessLevel == readPermission
                {
                    return true
                }
            }
        }
        
        return false
    }
    
    public func checkWritePermission(_ roleType: String) -> Bool
    {
        if myRoles == nil
        {
            myRoles = userRoles(userID: myUserID, teamID: myCurrentTeam!.teamID)
        }
        
        for item in myRoles.userRole
        {
            if item.roleType == roleType
            {
                if item.accessLevel == writePermission
                {
                    return true
                }
            }
        }
        
        return false
    }
    
    public func getUserDetails()
    {
        // check to see if user exists
        let myReachability = Reachability()
        if myReachability.isConnectedToNetwork()
        {
            let record = myCloudDB.getUser(userID)
            
            if record != nil
            {
                myUserID = record!.userID
                myName = record!.name
                myPhraseDate = record!.phraseDate
                myPassPhrase = record!.passPhrase
                myEmail = record!.email
                myPersonID = record!.personID
                mydefaultCalendar = record!.defaultCalendar
            }
            else
            {
                myName = ""
                myPassPhrase = ""
                myEmail = ""
            }
            
            loadTeams()
            
            loadRoles()
            
            notificationCenter.post(name: NotificationUserLoaded, object: nil)
        }
        else
        {
            // Not connected to Internet
            
            myUserID = userID
        }
    }

    public func addTeamToUser(_ teamObject: team)
    {
        myTeams.append(teamObject)
        
        let temp = UserTeams(teamID: teamObject.teamID, userID: myUserID)
        myCloudDB.saveUserTeamsRecordToCloudKit(temp)
        
        if myTeams.count == 1
        {
            myCurrentTeam = teamObject
        }
    }
    
    public func addRoleToUser(roleType: String, accessLevel: String)
    {
        if myCloudDB.getUserRoles(userID: myUserID, teamID: currentUser.currentTeam!.teamID, roleType: roleType).count == 0
        {
            let myItem = userRoleItem(userID: myUserID, roleType: roleType, teamID: currentTeam!.teamID, roleID: -1)
            myItem.accessLevel = accessLevel
        }
    }
    
    public func loadRoles()
    {
        myRoles = userRoles(userID: myUserID, teamID: currentTeam!.teamID)
    }
    
    public func removeTeamForUser(_ teamObject: team)
    {
        myCloudDB.deleteUserTeam(myUserID, teamID: teamObject.teamID)
        
        loadTeams()
    }
    
    public func loadUserTeams()
    {
        myTeamList = userTeams(userID: myUserID)
    }
    
    public func loadTeams()
    {
        myTeams.removeAll()
        
        for myItem in myCloudDB.getTeamsForUser(userID: myUserID)
        {
            let teamObject = team(teamID: myItem.teamID)
            myTeams.append(teamObject)
        }
        
        if myTeams.count > 0
        {
            myCurrentTeam = myTeams[0]
        }
    }
    
    public func loadMenu(showActive: Bool)
    {
        if currentTeam != nil
        {
            let clientList = clients(teamID: currentTeam!.teamID, isActive: showActive)
            let projectList = projects(teamID: currentTeam!.teamID, includeEvents: true, isActive: showActive)

            let peopleList = people(teamID: (currentTeam?.teamID)!, isActive: showActive)
            let leadList = leads(teamID: (currentTeam?.teamID)!, isActive: showActive)

            
            myMenuOptions.removeAll()
            var menuID: Int = 1
            var parentID: Int = 0
            
            let tempA = menuArray(menuTextx: "Dashboard", menuActionx: "Dashboard", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
            myMenuOptions.append(tempA)
            menuID += 1
            
            //        let temp0 = menuArray(menuTextx: "Alerts", menuActionx: "Alerts", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
            //        menuOptions.append(temp0)
            //        menuID += 1
            
            if checkReadPermission(rosteringRoleType)
            {
                let temp5 = menuArray(menuTextx: "Rostering", menuActionx: "", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
                myMenuOptions.append(temp5)
                parentID = menuID
                menuID += 1
                
                let temp6 = menuArray(menuTextx: "     Roster", menuActionx: "Roster", indexx: 0, IDx: menuID, parentIDx: parentID, displayx: false)
                myMenuOptions.append(temp6)
                menuID += 1
                
                let temp7 = menuArray(menuTextx: "     Event Planning", menuActionx: menuEventPlanning, indexx: 0, IDx: menuID, parentIDx: parentID, displayx: false)
                myMenuOptions.append(temp7)
                menuID += 1
                
                let temp8 = menuArray(menuTextx: "     Event Templates", menuActionx: menuEventTemplates, indexx: 0, IDx: menuID, parentIDx: parentID, displayx: false)
                myMenuOptions.append(temp8)
                menuID += 1
                
                let temp8a = menuArray(menuTextx: "     Monthly Roster", menuActionx: menuMonthlyRoster, indexx: 0, IDx: menuID, parentIDx: parentID, displayx: false)
                myMenuOptions.append(temp8a)
                menuID += 1
                
                let temp8b = menuArray(menuTextx: "     Weekly Roster", menuActionx: menuWeeklyRoster, indexx: 0, IDx: menuID, parentIDx: parentID, displayx: false)
                myMenuOptions.append(temp8b)
                menuID += 1
                
                let temp8c = menuArray(menuTextx: "     Monthly Bookings", menuActionx: menuMonthlyBookings, indexx: 0, IDx: menuID, parentIDx: parentID, displayx: false)
                myMenuOptions.append(temp8c)
                menuID += 1
            }
            
            if checkReadPermission(coachingRoleType)
            {
                let temp8c = menuArray(menuTextx: "Coaching", menuActionx: "Course", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
                myMenuOptions.append(temp8c)
                menuID += 1
            }
            
            if checkReadPermission(salesRoleType)
            {
                let temp8b = menuArray(menuTextx: "Sales", menuActionx: "", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
                myMenuOptions.append(temp8b)
                parentID = menuID
                menuID += 1
                
                for item in leadList.leads
                {
                    let tempLead = menuArray(menuTextx: "     \(item.name)", menuActionx: "sales", indexx: item.leadID, IDx: menuID, parentIDx: parentID, displayx: false)
                    myMenuOptions.append(tempLead)
                    menuID += 1
                }
                
                let tempLead = menuArray(menuTextx: "     Add Lead", menuActionx: "sales", indexx: -1, IDx: menuID, parentIDx: parentID, displayx: false)
                myMenuOptions.append(tempLead)
                menuID += 1
            }
            
            if checkReadPermission(invoicingRoleType)
            {
                let temp14 = menuArray(menuTextx: "Invoicing", menuActionx: "", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
                myMenuOptions.append(temp14)
                parentID = menuID
                menuID += 1
                
                let temp15 = menuArray(menuTextx: "     Staff Invoicing", menuActionx: menuStaffInvoicing, indexx: 0, IDx: menuID, parentIDx: parentID, displayx: false)
                myMenuOptions.append(temp15)
                menuID += 1
                
                let temp15a = menuArray(menuTextx: "     Staff Invoices To Pay", menuActionx: "Staff To Pay", indexx: 0, IDx: menuID, parentIDx: parentID, displayx: false)
                myMenuOptions.append(temp15a)
                menuID += 1
                
                let temp15b = menuArray(menuTextx: "     Client Invoices", menuActionx: "Client Invoices", indexx: 0, IDx: menuID, parentIDx: parentID, displayx: false)
                myMenuOptions.append(temp15b)
                menuID += 1
                
                let temp15c = menuArray(menuTextx: "     Invoice Settings", menuActionx: "Invoice Settings", indexx: 0, IDx: menuID, parentIDx: parentID, displayx: false)
                myMenuOptions.append(temp15c)
                menuID += 1
            }
            
            if checkReadPermission(salesRoleType) || checkReadPermission(clientRoleType)
            {
                let temp17 = menuArray(menuTextx: "Clients", menuActionx: "", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
                myMenuOptions.append(temp17)
                parentID = menuID
                menuID += 1
                
                for item in clientList.clients
                {
                    let tempClient = menuArray(menuTextx: "     \(item.name)", menuActionx: "client", indexx: item.clientID, IDx: menuID, parentIDx: parentID, displayx: false)
                    myMenuOptions.append(tempClient)
                    menuID += 1
                }
                
                let tempClient = menuArray(menuTextx: "     Add Client", menuActionx: "client", indexx: -1, IDx: menuID, parentIDx: parentID, displayx: false)
                myMenuOptions.append(tempClient)
                menuID += 1
            }
            
            if checkReadPermission(pmRoleType)
            {
                let temp17a = menuArray(menuTextx: "Projects", menuActionx: "", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
                myMenuOptions.append(temp17a)
                parentID = menuID
                menuID += 1
                
                for item in projectList.projects
                {
                    var clientName: String = ""
                    
                    if item.clientID > 0
                    {
                        let temp = clientList.clients.filter {$0.clientID == item.clientID}
                        
                        if temp.count > 0
                        {
                            clientName = " - \(temp[0].name)"
                        }
                    }
                    let tempClient = menuArray(menuTextx: "     \(item.projectName) \(clientName)", menuActionx: "project", indexx: item.projectID, IDx: menuID, parentIDx: parentID, displayx: false)
                    myMenuOptions.append(tempClient)
                    menuID += 1
                }
            }
            
            if checkReadPermission(hrRoleType)
            {
                let temp17b = menuArray(menuTextx: "People", menuActionx: "", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
                myMenuOptions.append(temp17b)
                parentID = menuID
                menuID += 1
                
                for item in peopleList.people
                {
                    let tempClient = menuArray(menuTextx: "     \(item.name)", menuActionx: "person", indexx: item.personID, IDx: menuID, parentIDx: parentID, displayx: false)
                    myMenuOptions.append(tempClient)
                    menuID += 1
                }
                
                let tempPerson = menuArray(menuTextx: "     Add Person", menuActionx: "person", indexx: -1, IDx: menuID, parentIDx: parentID, displayx: false)
                myMenuOptions.append(tempPerson)
                menuID += 1
            }
            
            let temp10 = menuArray(menuTextx: "Reports", menuActionx: "Reports", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
            myMenuOptions.append(temp10)
            menuID += 1
            
            let temp12 = menuArray(menuTextx: "New Communication", menuActionx: "New Communication", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
            myMenuOptions.append(temp12)
            menuID += 1
            
            if checkReadPermission(adminRoleType)
            {
                let temp16 = menuArray(menuTextx: "Settings", menuActionx: "Settings", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
                myMenuOptions.append(temp16)
                menuID += 1
            }
        }
    }
    
    public func toggleSubMenus(parentID: Int)
    {
        for item in myMenuOptions
        {
            if item.parentID == parentID
            {
                item.display = !item.display
            }
        }
    }

    public func save()
    {
        myCloudDB.saveUser(myUserID, name: myName, phraseDate: myPhraseDate, passPhrase: myPassPhrase, email: myEmail, personID: myPersonID, defaultCalendar: mydefaultCalendar)
    }
    
    public func delete() -> Bool
    {
        if myTeams.count == 0
        {
            return false
        }
        else
        {
            myCloudDB.deleteUser(myUserID)
            return true
        }
    }
    
    public func generatePassPhrase()
    {
        myPassPhrase = randomString(length: 16)
        
        let calendar = Calendar.current
        myPhraseDate = calendar.date(byAdding: .day, value: 1, to: Date())!

        save()
    }
    
    private func randomString(length: Int64) -> String
    {
        let letters : String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var retString: String = ""
        
        for _ in 1...length
        {
            let randomIndex  = Int(arc4random_uniform(UInt32(letters.count)))
            let a = letters.index(letters.startIndex, offsetBy: randomIndex)
            retString +=  String(letters[a])
        }
        
        return retString
    }
    
    public func addInitialUserRoles()
    {
        var recordCount: Int64 = 0
        
        // Check to see if this is a new team - this is done by seeing if there any roles entries yet
        
        let basePermission = writePermission
        
        let processRecords = currentUser.currentTeam!.getRoleTypes()
        
        for myItem in processRecords
        {
            if recordCount == processRecords.count - 1
            {
                addRoleToUser(roleType: myItem, accessLevel: basePermission)
                usleep(500)
            }
            else
            {
                addRoleToUser(roleType: myItem, accessLevel: basePermission)
                recordCount += 1
                usleep(500)
            }
        }
        
        loadRoles()
    }
}

public struct Users {
    public var email: String?
    public var name: String?
    public var teamID: Int64
    public var userID: Int64
    public var passPhrase: String?
    public var phraseDate: Date?
    public var defaultCalendar: String?
}

extension CloudKitInteraction
{
    private func populateUsers(_ records: [CKRecord]) -> [Users]
    {
        var tempArray: [Users] = Array()

        for record in records
        {
            var teamID: Int64 = 0
            if record.object(forKey: "teamID") != nil
            {
                teamID = record.object(forKey: "teamID") as! Int64
            }
            
            var userID: Int64 = 0
            if record.object(forKey: "userID") != nil
            {
                userID = record.object(forKey: "userID") as! Int64
            }
            
            var phraseDate: Date = getDefaultDate()
            if record.object(forKey: "phraseDate") != nil
            {
                phraseDate = record.object(forKey: "phraseDate") as! Date
            }
            
            let tempItem = Users(email: record.object(forKey: "email") as? String,
                                 name: record.object(forKey: "name") as? String,
                                 teamID: teamID,
                                 userID: userID,
                                 passPhrase: record.object(forKey: "passPhrase") as? String,
                                 phraseDate: phraseDate,
                                 defaultCalendar: record.object(forKey: "defaultCalendar") as? String
            )
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getUserCount() -> Int64
    {
//let predicate: NSPredicate = NSPredicate(value: true)
        let workingTeamID: Int64 = (currentUser.currentTeam?.teamID)!
        
        let predicate: NSPredicate = NSPredicate(format: "teamID == \(workingTeamID)")
        let query: CKQuery = CKQuery(recordType: "DBUsers", predicate: predicate)
        
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        return Int64(returnArray.count)
    }
    
    func getAllUserCount() -> Int64
    {
        let predicate: NSPredicate = NSPredicate(value: true)
        //let workingTeamID: Int64 = (currentUser.currentTeam?.teamID)!
        
       // let predicate: NSPredicate = NSPredicate(format: "teamID == \(workingTeamID)")
        let query: CKQuery = CKQuery(recordType: "DBUsers", predicate: predicate)
        
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        return Int64(returnArray.count)
    }
    
    public func getTeamUserCount() -> Int
    {
        //let predicate: NSPredicate = NSPredicate(value: true)
        let workingTeamID: Int64 = (currentUser.currentTeam?.teamID)!
        
        let predicate: NSPredicate = NSPredicate(format: "teamID == \(workingTeamID)")
        let query: CKQuery = CKQuery(recordType: "UserTeams", predicate: predicate)
        
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        return returnArray.count
    }
    
    func checkExistingUser(email: String) -> [Users]
    {
        let predicate: NSPredicate = NSPredicate(format: "email == \"\(email)\"")
        let query: CKQuery = CKQuery(recordType: "DBUsers", predicate: predicate)
        
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()

        let userArray: [Users] = populateUsers(returnArray)
        
        return userArray
    }
    
    func getUserList(userList: String) -> [Users]
    {
        let predicate: NSPredicate = NSPredicate(format: "userID IN { \(userList) }")
        let query: CKQuery = CKQuery(recordType: "DBUsers", predicate: predicate)

        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let userArray: [Users] = populateUsers(returnArray)
        
        return userArray
    }

    func teamOwnerList() -> [teamOwnerItem]
    {
        return teamOwnerRecords
    }
    
    func createNewUser(_ userID: Int64, name: String, email: String) -> Bool
    {
        var retVal: Bool = true
        let record = CKRecord(recordType: "DBUsers")
        record.setValue(userID, forKey: "userID")
        record.setValue(name, forKey: "name")
        record.setValue(email, forKey: "email")
        
        self.publicDB.save(record, completionHandler:
            { (savedRecord, saveError) in
                if saveError != nil
                {
                    NSLog("Error saving record: \(saveError!.localizedDescription)")
                    self.saveOK = false
                    retVal = false
                }
                else
                {
                    if debugMessages
                    {
                        NSLog("Successfully saved record!")
                    }
                }
        })
        
        return retVal
    }
    
    func getUser(_ userID: Int64) -> returnUser?
    {
        let predicate = NSPredicate(format: "(userID == \(userID))") // better be accurate to get only the record you need
        let query: CKQuery = CKQuery(recordType: "DBUsers", predicate: predicate)
        
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        for record in returnArray
        {
            var storedUserID: Int64 = 0
            if record.object(forKey: "userID") != nil
            {
                storedUserID = record.object(forKey: "userID") as! Int64
            }
            
            var personID: Int64 = 0
            if record.object(forKey: "personID") != nil
            {
                personID = record.object(forKey: "personID") as! Int64
            }
            
            var phraseDate = getDefaultDate()
            if record.object(forKey: "phraseDate") != nil
            {
                phraseDate = record.object(forKey: "phraseDate") as! Date
            }
            
            var name: String = ""
            if record.object(forKey: "name") != nil
            {
                name = record.object(forKey: "name") as! String
            }
            
            var passPhrase: String = ""
            if record.object(forKey: "passPhrase") != nil
            {
                passPhrase = record.object(forKey: "passPhrase") as! String
            }
            
            var email: String = ""
            if record.object(forKey: "email") != nil
            {
                email = record.object(forKey: "email") as! String
            }
            
            var defaultCalendar: String = ""
            if record.object(forKey: "defaultCalendar") != nil
            {
                defaultCalendar = record.object(forKey: "defaultCalendar") as! String
            }
            
            self.returnUserEntry = returnUser(
                userID: storedUserID,
                name: name,
                passPhrase: passPhrase,
                phraseDate: phraseDate,
                email: email,
                personID: personID,
                defaultCalendar: defaultCalendar)
        }
        
        return returnUserEntry
    }

    func saveUser(_ userID: Int64, name: String, phraseDate: Date, passPhrase: String, email: String, personID: Int64, defaultCalendar: String)
    {
        let sem = DispatchSemaphore(value: 0)

        let predicate = NSPredicate(format: "(userID == \(userID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "DBUsers", predicate: predicate)
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

                    record!.setValue(name, forKey: "name")
                    record!.setValue(phraseDate, forKey: "phraseDate")
                    record!.setValue(passPhrase, forKey: "passPhrase")
                    record!.setValue(email, forKey: "email")
                    record!.setValue(personID, forKey: "personID")
                    record!.setValue(defaultCalendar, forKey: "defaultCalendar")
                    
                    // Save this record again
                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                            self.saveOK = false
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
                    let record = CKRecord(recordType: "DBUsers")
                    record.setValue(userID, forKey: "userID")
                    record.setValue(name, forKey: "name")
                    record.setValue(phraseDate, forKey: "phraseDate")
                    record.setValue(passPhrase, forKey: "passPhrase")
                    record.setValue(email, forKey: "email")
                    record.setValue(personID, forKey: "personID")
                    record.setValue(defaultCalendar, forKey: "defaultCalendar")

                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                            self.saveOK = false
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
    
    func deleteUser(_ userID: Int64)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "(userID == \(userID))")
        let query: CKQuery = CKQuery(recordType: "DBUsers", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in

            self.performPublicDelete(results!)
            sem.signal()
        })
        
        sem.wait()
    }
    
    func getUsersList(userList: String) -> [Users]
    {
        returnUserArray.removeAll()
        
        let predicate = NSPredicate(format: "userID IN { \(userList) } AND (updateType != \"Delete\")") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "DBUsers", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let userArray: [Users] = populateUsers(returnArray)
        
        return userArray
    }
    
    func getAllUsers() -> [Users]
    {
        returnUserArray.removeAll()
        
        let predicate = NSPredicate(format: "TRUEPREDICATE") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "DBUsers", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let userArray: [Users] = populateUsers(returnArray)
        
        return userArray
    }
    
    private func processUserList(_ sourceRecord: CKRecord)
    {
        var storedUserID: Int64 = 0
        if sourceRecord.object(forKey: "userID") != nil
        {
            storedUserID = sourceRecord.object(forKey: "userID") as! Int64
        }
        
        var personID: Int64 = 0
        if sourceRecord.object(forKey: "personID") != nil
        {
            personID = sourceRecord.object(forKey: "personID") as! Int64
        }
        
        var phraseDate = getDefaultDate()
        if sourceRecord.object(forKey: "phraseDate") != nil
        {
            phraseDate = sourceRecord.object(forKey: "phraseDate") as! Date
        }
        
        var name: String = ""
        if sourceRecord.object(forKey: "name") != nil
        {
            name = sourceRecord.object(forKey: "name") as! String
        }
        
        var passPhrase: String = ""
        if sourceRecord.object(forKey: "passPhrase") != nil
        {
            passPhrase = sourceRecord.object(forKey: "passPhrase") as! String
        }
        
        var email: String = ""
        if sourceRecord.object(forKey: "email") != nil
        {
            email = sourceRecord.object(forKey: "email") as! String
        }
        
        var defaultCalendar: String = ""
        if sourceRecord.object(forKey: "defaultCalendar") != nil
        {
            defaultCalendar = sourceRecord.object(forKey: "defaultCalendar") as! String
        }
        
        let returnUserEntry = returnUser(
            userID: storedUserID,
            name: name,
            passPhrase: passPhrase,
            phraseDate: phraseDate,
            email: email,
            personID: personID,
            defaultCalendar: defaultCalendar)

        returnUserArray.append(returnUserEntry)
    }
    
    func retrieveUserList() -> [returnUser]
    {
        return returnUserArray
    }
    
    func validateUser(email: String, passPhrase: String) -> [Users]
    {
        returnUserArray.removeAll()
        
        let predicate = NSPredicate(format: "(email == \"\(email)\") AND (passPhrase == \"\(passPhrase)\") AND (%@ != phraseDate) AND (%@ <= phraseDate) AND (updateType != \"Delete\")", getDefaultDate() as CVarArg, Date() as CVarArg) // better be accurate to get only the record you need
        
    //    let predicate = NSPredicate(format: "TRUEPREDICATE") // better be accurate to get only the record you need
        
        
        let query = CKQuery(recordType: "DBUsers", predicate: predicate)
        
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let userArray: [Users] = populateUsers(returnArray)
        
        return userArray
    }
}

