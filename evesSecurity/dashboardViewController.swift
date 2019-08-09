//
//  dashboardViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 22/6/18.
//  Copyright © 2018 Garry Eves. All rights reserved.
//

import UIKit
import evesShared

class dashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, myCommunicationDelegate, shiftLoadDelegate, UIPopoverPresentationControllerDelegate, dashboardUpdate {

    @IBOutlet weak var lblWelcome: UILabel!
    @IBOutlet weak var tblAlertSummary: UITableView!
    @IBOutlet weak var tblStage: UITableView!
    @IBOutlet weak var tblBookings: UITableView!
    @IBOutlet weak var btnHubspot: UIButton!
    
    fileprivate var alertList: alerts!
    var communicationDelegate: myCommunicationDelegate?
    var delegate: mainScreenProtocol!
    
    fileprivate var firstRun: Bool = true
    fileprivate var hubspotList: [hubspotContact] = Array()
    fileprivate var bookings: simplyBookBookings!
    private var stageCountString: [String] = Array()
    private var stageCountInt: [Int] = Array()
    private var sessionList: sessionNotes!
    private var peopleList: coachingClients!
    private var leadList: leads!
    private var couseSessionList: courseSessions!
    private var summaryArray: [alertSummary] = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        appName = "EvesSecurity"
//        
//        lblWelcome.text = "Welcome \(currentUser.name)"
//
//        reloadTables()

//        DispatchQueue.global().async
//        {
//            while currentUser.currentTeam?.shifts == nil
//            {
//                sleep(1)
//            }
//        }
//
//        tblBookings.isHidden = true
//        btnHubspot.isHidden = true
//
//        if currentUser.checkReadPermission(salesRoleType)
//        {
//            tblStage.isHidden = false
//        }
//        else
//        {
//            tblStage.isHidden = true
//        }
        
//        refreshScreen()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView
        {
            case tblAlertSummary:
                if alertList != nil
                {
                    summaryArray.removeAll()
                    for item in alertList.alertSummaryList
                    {
                        if item.displayAmount != 0
                        {
                            summaryArray.append(item)
                        }
                    }
                    return summaryArray.count
                }
                else
                {
                    return 0
                }
        
            case tblBookings:
                if bookings != nil
                {
                    return bookings.bookings.count
                }
                else
                {
                    return 0
                }
            
            case tblStage:
                return stageCountString.count
            
            default:
                return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblAlertSummary:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellAlerts", for: indexPath) as! twoLabelTable
                
                cell.lbl1.text = summaryArray[indexPath.row].displayText
                cell.lbl2.text = "\(summaryArray[indexPath.row].displayAmount)"
                
                return cell
            
            case tblBookings:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellBooking", for: indexPath) as! bookingCellView
                
                // Configure the cell...
                cell.lblSession?.text = bookings.bookings[indexPath.row].event
                cell.lblSimplyClient?.text = bookings.bookings[indexPath.row].client
                cell.lblStart?.text = "\(bookings.bookings[indexPath.row].startDateString) - \(bookings.bookings[indexPath.row].endTimeString)"
                cell.lblEmail?.text = bookings.bookings[indexPath.row].clientEmail
                
                // Loop through the session notes to see if there is a match for the seesion ID
                
                let temp0 = sessionList.notes.filter { $0.externalBookingType == simplybookingType }
                
                let temp = temp0.filter { $0.externalBookingID == bookings.bookings[indexPath.row].bookingID }
                
                if temp.count == 0
                {
                    cell.btnClient.setTitle("Select Client", for: .normal)
                }
                else
                {
                    let p1 = person(personID: temp[0].personID, teamID: currentUser.currentTeam!.teamID)
                    cell.btnClient.setTitle(p1.name, for: .normal)
                   // cell.lblSkype?.text = temp[0].personRecord.SkyPeID
                    cell.sessionDetails = temp[0]
                }

                cell.btnCreateCalendar.isEnabled = checkCalendar(title: "\(bookings.bookings[indexPath.row].event) - \(bookings.bookings[indexPath.row].client)", startDate: bookings.bookings[indexPath.row].startDate, endDate: bookings.bookings[indexPath.row].endDate)
                
                cell.booking = bookings.bookings[indexPath.row]
                cell.sender = btnHubspot
                cell.parentView = self
                cell.peopleList = peopleList
                cell.couseSessionList = couseSessionList
                
                return cell
        
            case tblStage:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellStage", for: indexPath) as! stageCountCell
                
                // Configure the cell...
                cell.lblStage?.text = stageCountString[indexPath.row]
                cell.lblCount?.text = "\(stageCountInt[indexPath.row])"
                
                return cell
            
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "personCell", for: indexPath)
                
                // Configure the cell...
                cell.textLabel?.text = ""
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView
        {
            case tblBookings:
                var selectedNote: sessionNote!

                let temp = sessionList.notes.filter { $0.externalBookingID == bookings.bookings[indexPath.row].bookingID }

                if temp.count == 0
                {
                    selectedNote = nil
                }
                else
                {
                    selectedNote = temp[0]
                }

                if selectedNote != nil
                {
                    let commsView = coursesStoryboard.instantiateViewController(withIdentifier: "sessionNotesViewController") as! sessionNotesViewController
                    commsView.modalPresentationStyle = .popover

                    let popover = commsView.popoverPresentationController!
                    popover.delegate = self
                    popover.sourceView = btnHubspot
                    popover.sourceRect = btnHubspot.bounds
                    popover.permittedArrowDirections = .any
                    commsView.preferredContentSize = CGSize(width: 800,height: 800)

                    commsView.passedPerson = person(personID: selectedNote.personID, teamID: currentUser.currentTeam!.teamID)
                    commsView.passedNote = selectedNote

                    self.present(commsView, animated: true, completion: nil)
                }

            case tblStage:
                if stageCountInt[indexPath.row] > 0
                {
                    let viewControl = loginStoryboard.instantiateViewController(withIdentifier: "showList") as! showListViewController
                    viewControl.modalPresentationStyle = .popover
                    
                    let popover = viewControl.popoverPresentationController!
                    popover.delegate = self
                    popover.sourceView = tableView
                    popover.sourceRect = tableView.bounds
                    popover.permittedArrowDirections = .any
                    
                    viewControl.preferredContentSize = CGSize(width: 800,height: 800)
                    
                    viewControl.dashboardDelegate = self
                    
                    let temp = leadList.leads.filter { $0.stage == stageCountString[indexPath.row] }
                    
                    viewControl.dataSource = "Leads"
                    viewControl.leadList = temp
                    self.present(viewControl, animated: true, completion: nil)
                }
            
            case tblAlertSummary:
            
                let viewControl = self.storyboard?.instantiateViewController(withIdentifier: "mainScreen") as! securityViewController
                viewControl.modalPresentationStyle = .popover
                
                let popover = viewControl.popoverPresentationController!
                popover.delegate = self
                popover.sourceView = tableView
                popover.sourceRect = tableView.bounds
                popover.permittedArrowDirections = .any
                
                viewControl.preferredContentSize = CGSize(width: 800,height: 800)
                viewControl.selectedType = summaryArray[indexPath.row].displayText
                
                let alertArray = alertList.alertList.filter { $0.type ==  summaryArray[indexPath.row].displayText }
                
                viewControl.dashboardDelegate = self
                viewControl.alertArray = alertArray
                self.present(viewControl, animated: true, completion: nil)

            default:
                let _ = 1
        }
    }
    
//    @IBAction func btnHubspot(_ sender: UIButton) {
//
//        // Loop through Hubspot contacts and add them
//
//        for item in hubspotList
//        {
//            let newPerson = person(teamID: currentUser.currentTeam!.teamID, newName: item.Name)
//
//            let _ = contactItem(teamID: currentUser.currentTeam!.teamID,
//                                           contactType: "Office Email",
//                                           contactValue: item.Email,
//                                           personID: newPerson.personID, clientID: 0, projectID: 0)
//
//            let _ = contactItem(teamID: currentUser.currentTeam!.teamID,
//                                           contactType: "Office Phone",
//                                           contactValue: item.Phone,
//                                           personID: newPerson.personID, clientID: 0, projectID: 0)
//
//            let newLead = lead(teamID: currentUser.currentTeam!.teamID,
//                         name: item.Name,
//                         source: hubspotType,
//                         sourceID: "\(item.hubspotID)",
//                        ownerID: 0)
//
//            let _ = leadPerson(leadID: newLead.leadID, personID: newPerson.personID, role: "Client Contact", teamID: currentUser.currentTeam!.teamID, saveRecord: true)
//        }
//
//        sleep(2)
//        currentUser.currentTeam!.people = nil
//
//        delegate.reloadMenu()
//
//        leadList = leads(teamID: currentUser.currentTeam!.teamID, isActive: true)
//   //     loadHubspot()
//    }
//
    func displayScreen(screen: String, object: Any)
    {
        switch screen
        {
            case "Project":
                let workingProject = object as! project
                
                let viewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
                //  contractEditViewControl.communicationDelegate = commsDelegate
                viewControl.workingContract = workingProject
                splitViewController?.showDetailViewController(viewControl, sender: self)
            
            case "Client":
                let workingClient = object as! client
                
                let viewControl = clientsStoryboard.instantiateViewController(withIdentifier: "clientMaintenance") as! clientMaintenanceViewController
                viewControl.selectedClient = workingClient
                splitViewController?.showDetailViewController(viewControl, sender: self)
        
            case "Shift":
                let workingShift = object as! shift
                
                if workingShift.type == eventShiftType
                {
                    let workingProject = project(projectID: workingShift.projectID, teamID: currentUser.currentTeam!.teamID)
                    
                    let viewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "eventPlanningForm") as! eventPlanningViewController
                    viewControl.currentEvent = workingProject
                    splitViewController?.showDetailViewController(viewControl, sender: self)
                }
                else
                {
                    let viewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "rosterForm") as! shiftMaintenanceViewController
                    viewControl.delegate = delegate
                    splitViewController?.showDetailViewController(viewControl, sender: self)
                }
            
                case "Lead":
                    let currentLead = object as! lead
                    let viewControl = salesStoryboard.instantiateViewController(withIdentifier: "leadsView") as! leadsViewController
                    viewControl.passedLead = currentLead
                    splitViewController?.showDetailViewController(viewControl, sender: self)
            
            default:
                let _ = 1
        }
    }
    
//    public func reloadTables()
//    {
//        peopleList = coachingClients(teamID: currentUser.currentTeam!.teamID, isActive: true)
//        couseSessionList = courseSessions(teamID: currentUser.currentTeam!.teamID)
//        sessionList = sessionNotes(teamID: currentUser.currentTeam!.teamID)
//    }
//
    public func refreshScreen()
    {
    }
//        if currentUser.currentTeam?.shifts == nil && !firstRun
//        {
//            DispatchQueue.global().async
//            {
//                currentUser.currentTeam?.loadShifts(self)
//
//                    // myCloudDB.getShifts(teamID: (currentUser.currentTeam?.teamID)!)
//            }
//        }

//        buildAlerts()

//        if currentUser.currentTeam!.subscriptionDate < Date().startOfDay
//        {
//            tblAlertSummary.isHidden = true
//
//            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.notSubscribedMessage), userInfo: nil, repeats: false)
//        }
//        else if myCloudDB.getTeamUserCount() > Int(currentUser.currentTeam!.subscriptionLevel)
//        {
//            tblAlertSummary.isHidden = true
//
//            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.exceedSubscriptionMessage), userInfo: nil, repeats: false)
//        }
//        else
//        {
//            tblAlertSummary.reloadData()
//        }

//        leadList = leads(teamID: currentUser.currentTeam!.teamID, isActive: true)
//
//        // Chec to see if we have API details to do our loads
//        
//        let tempAPI = externalSources(teamID: currentUser.currentTeam!.teamID)
//        
//        for item in tempAPI.apis
//        {
//            switch item.externalsource
//            {
//                case hubspotType:
//                    DispatchQueue.global().async
//                    {
//                        self.loadHubspot()
//                    }
//                
//                case simplybookingType:
//                    DispatchQueue.global().async
//                    {
//                        self.loadBookings()
//                    }
//        
//                default:
//                    let _ = 1
//            }
//        }
//
//        loadStages()

//    }
    
//    func loadHubspot()
//    {
//        hubspotList.removeAll()
//        let hubspotEntries = hubspotContacts()
//        for item in hubspotEntries.contacts
//        {
//            var personFound: Bool = false
//
//            for leadToCheck in leads(teamID: currentUser.currentTeam!.teamID, isActive: false).leads
//            {
//                if leadToCheck.externalSource == hubspotType
//                {
//                    if "\(item.hubspotID)" == leadToCheck.externalID
//                    {
//                        personFound = true
//                        break
//                    }
//                }
//            }
//
//            if !personFound
//            {
//                hubspotList.append(item)
//            }
//        }
//
//        DispatchQueue.main.async
//        {
//            switch self.hubspotList.count
//            {
//                case 0:
//                    self.btnHubspot.setTitle("There are no HubSpot contacts to add", for: .normal)
//                    self.btnHubspot.isEnabled = false
//
//                case 1:
//                    self.btnHubspot.setTitle("There is 1 HubSpot contact to add.  Press to create them.", for: .normal)
//                    self.btnHubspot.isEnabled = true
//
//                default:
//                    self.btnHubspot.setTitle("There are \(self.hubspotList.count) HubSpot contacts to add.  Press to create them.", for: .normal)
//                    self.btnHubspot.isEnabled = true
//            }
//
//            self.btnHubspot.isHidden = false
//        }
//    }
//
//    func loadBookings()
//    {
//        bookings = simplyBookBookings()
//        DispatchQueue.main.async
//        {
//            self.tblBookings.isHidden = false
//            self.tblBookings.reloadData()
//        }
//    }
//
//    func loadStages()
//    {
//        if currentUser.checkReadPermission(salesRoleType)
//        {
//            stageCountString.removeAll()
//            stageCountInt.removeAll()
//
//            let temp = leadList.leads.filter { $0.stage == "" }
//
//            if temp.count > 0
//            {
//                stageCountString.append(NoStageLabel)
//                stageCountInt.append(temp.count)
//            }
//
//            for item in (currentUser.currentTeam?.getDropDown(dropDownType: salesProjectType))!
//            {
//                if item != archivedProjectStatus
//                {
//                    stageCountString.append(item)
//
//                    let temp = leadList.leads.filter { $0.stage == item }
//
//                    stageCountInt.append(temp.count)
//                }
//            }
//
//            tblStage.isHidden = false
//            tblStage.reloadData()
//        }
//        else
//        {
//            tblStage.isHidden = true
//        }
//    }
    
    func checkCalendar(title: String, startDate: Date, endDate: Date) -> Bool
    {
//        let prefix = "Coaching session - "
////        var itemTitle = ""
////        if title.hasPrefix(prefix)
////        {
////            itemTitle = String(title.dropFirst(prefix.count))
////        }
////        else
////        {
////            itemTitle = title
////        }
//
//        let tempStart = startDate.startOfDay
//        let tempEnd = endDate.add(.day, amount: 1).startOfDay
//        
//        let calendarSource: iOSCalendarList = iOSCalendarList()
//        let calItems = calendarSource.searchEvents(startDate: tempStart, endDate: tempEnd)
////print("In  title = \(itemTitle) ")
//        for item in calItems
//        {
//            var insideTitle = ""
//            if item.title!.hasPrefix(prefix)
//            {
//                insideTitle = String(item.title!.dropFirst(prefix.count))
//            }
//            else
//            {
//                insideTitle = item.title!
//            }
//
////print("event = \(insideTitle) \(item.startDate!) - \(item.endDate!)")
//
//            if insideTitle == title && item.startDate! == startDate && item.endDate! == endDate
//            {
//                return false
//            }
//        }
        
        return true
    }
    
//    @objc func exceedSubscriptionMessage()
//    {
//        let usercount: Int = myCloudDB.getTeamUserCount()
//
//        let alert = UIAlertController(title: "Subscription count exceeded", message:
//            "Your team has too many Users.  You currently have \(usercount) users but your subscription is for \(currentUser.currentTeam?.subscriptionLevel ?? 0) users.  Please contact your Administrator.", preferredStyle: UIAlertController.Style.alert)
//
//        let yesOption = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
//
//        alert.addAction(yesOption)
//        self.present(alert, animated: false, completion: nil)
//
//    }
//
//    @objc func notSubscribedMessage()
//    {
//
//        let alert = UIAlertController(title: "Subscription Expired", message:
//            "Your teams subscription has expired.  Please contact your Administrator in order to have the Subscription renewed.", preferredStyle: UIAlertController.Style.alert)
//
//        let yesOption = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
//
//        alert.addAction(yesOption)
//        self.present(alert, animated: false, completion: nil)
//
//    }
    
//    func buildAlerts()
//    {
//        if alertList == nil
//        {
//            alertList = alerts()
//        }
//        else
//        {
//            alertList.clearAlerts()
//        }
//
//        notificationCenter.removeObserver(NotificationAlertUpdate)
//
//        notificationCenter.addObserver(self, selector: #selector(securityViewController.displayAlertList), name: NotificationAlertUpdate, object: nil)
//
//        DispatchQueue.global().async
//        {
//            self.alertList.clientAlerts(currentUser.currentTeam!.teamID)
//            self.alertList.projectAlerts(currentUser.currentTeam!.teamID)
//
//            while currentUser.currentTeam?.shifts == nil
//            {
//                sleep(1)
//            }
//            self.firstRun = false
//            self.alertList.shiftAlerts(currentUser.currentTeam!.teamID)
//        }
//    }
//
//    @objc func displayAlertList()
//    {
//        DispatchQueue.main.async
//        {
//            self.tblAlertSummary.reloadData()
//        }
//    }
}

class bookingCellView: UITableViewCell, MyPickerDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var lblSession: UILabel!
    @IBOutlet weak var lblSimplyClient: UILabel!
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var btnClient: UIButton!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var btnCreateCalendar: UIButton!
    
    var sender: UIButton!
    var parentView: dashboardViewController!
    var sessionDetails: sessionNote!
    var booking: simplyBookBooking!
    var peopleList: coachingClients!
    var couseSessionList: courseSessions!
    
    fileprivate var pickerOptions: [String] = Array()
    
    @IBAction func btnClient(_ sender: UIButton) {
//        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
//        pickerView.modalPresentationStyle = .popover
//
//        let popover = pickerView.popoverPresentationController!
//        popover.delegate = self
//        popover.sourceView = sender
//        popover.sourceRect = sender.bounds
//        popover.permittedArrowDirections = .any
//
//        pickerView.delegate = self
//        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
//
//        pickerOptions.removeAll()
//        pickerOptions.append("")
//
//        for item in peopleList.clients
//        {
//            pickerOptions.append(item.name)
//        }
//
//        pickerView.source = "people"
//        pickerView.currentValue = btnClient.currentTitle!
//
//        pickerView.pickerValues = pickerOptions
//
//        parentView.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnCreateCalendar(_ sender: UIButton) {
//        let temp = iOSCalendarList()
//
//        temp.createEvent(title: "\(booking!.event) - \(booking!.client)", startDate: booking!.startDate, endDate: booking!.endDate)
    }
    
//    public func myPickerDidFinish(_ source: String, selectedItem:Int)
//    {
//        switch source
//        {
//            case "people":
//                if selectedItem == 0
//                {
//                    if sessionDetails != nil
//                    {
//                        sessionDetails.personID = 0
//                    }
//                }
//                else
//                {
//                    if sessionDetails != nil
//                    {
//                        sessionDetails.personID = peopleList.clients[selectedItem - 1].personID
//                        sessionDetails.externalBookingType = simplybookingType
//                        sessionDetails.externalBookingID = booking.bookingID
//                    }
//                    else
//                    {
//                        // Find the session ID to match the
//                        var sessionID: Int64 = 0
//
//                        for item in couseSessionList.sessions
//                        {
//                            if  lblSession.text!.uppercased().contains(item.name.uppercased())
//                            {
//                                sessionID = item.sessionID
//                                break
//                            }
//                        }
//
//                        sessionDetails = sessionNote(teamID: currentUser.currentTeam!.teamID, sessionID: sessionID, personID: peopleList.clients[selectedItem - 1].personID)
//
//                        sessionDetails.sessionDate = booking.startDate
//                        sessionDetails.externalBookingType = simplybookingType
//                        sessionDetails.externalBookingID = booking.bookingID
//                    }
//                }
//                btnClient.setTitle(pickerOptions[selectedItem], for: .normal)
//
//            default:
//                print("bookingCellView myPickerDidFinish unknown return valye \(source)")
//        }
//    }
    
}

class stageCountCell: UITableViewCell
{
    @IBOutlet weak var lblStage: UILabel!
    @IBOutlet weak var lblCount: UILabel!
}

