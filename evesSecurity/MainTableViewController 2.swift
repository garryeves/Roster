//
//  MainTableViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 17/6/18.
//  Copyright © 2018 Garry Eves. All rights reserved.
//

import UIKit
import evesShared

class MainTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, mainScreenProtocol, shiftLoadDelegate {

//    private var menuOptions: [menuArray] = Array()
//    private var displayOptions: [menuArray] = Array()
    @IBOutlet var menuTable: UITableView!
    @IBOutlet weak var rootView: UINavigationItem!
    @IBOutlet weak var btnActive: UIBarButtonItem!
    
    private var alertView: securityViewController!
    private var clientList: clients!
    private var projectList: projects!
    private var peopleList: people!
    private var leadList: leads!
    private var showActive: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.title = currentUser.currentTeam?.name

        btnActive.title = "Active"
        
        // Build up an array of menu options
        let mainViewControl = self.storyboard?.instantiateViewController(withIdentifier: "dashboardView") as! dashboardViewController
        
        if currentUser.currentTeam?.shifts == nil
        {
            DispatchQueue.global().async
            {
                currentUser.currentTeam?.loadShifts(nil)
                    
                    //  myCloudDB.getShifts(teamID: (currentUser.currentTeam?.teamID)!)
            }
        }
        
        reloadMenu()
        
    //    let alertViewControl = self.storyboard?.instantiateViewController(withIdentifier: "mainScreen") as! securityViewController
   //     mainViewControl.communicationDelegate = self
    //    alertView = alertViewControl
        mainViewControl.delegate = self
        splitViewController?.showDetailViewController(mainViewControl, sender: self)

    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    @IBAction func btnActive(_ sender: UIBarButtonItem) {
        showActive = !showActive
        
        if showActive
        {
            btnActive.title = "Active"
            currentUser.currentTeam?.clients = nil
            currentUser.currentTeam?.people = nil
        }
        else
        {
            btnActive.title = "All"
            currentUser.currentTeam?.clients = nil
            currentUser.currentTeam?.people = nil
        }
        reloadMenu()
    }
    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        
////        displayOptions.removeAll()
////        for item in menuOptions
////        {
////            if item.display == true
////            {
////                displayOptions.append(item)
////            }
////        }
//        return displayOptions.count
//    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath)

//        cell.textLabel?.text = displayOptions[indexPath.row].menuText
//
//        if displayOptions[indexPath.row].menuAction == ""
//        {
//            cell.accessoryType = .disclosureIndicator
//        }
//        else
//        {
//            cell.accessoryType = .none
//        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        alertView = nil
//        switch displayOptions[indexPath.row].menuAction
//        {
//            case "Dashboard" :
//                let viewControl = self.storyboard?.instantiateViewController(withIdentifier: "dashboardView") as! dashboardViewController
//                //     mainViewControl.communicationDelegate = self
//                viewControl.delegate = self
//             //   alertView = viewControl
//                splitViewController?.showDetailViewController(viewControl, sender: self)
//
//            case "Alerts" :
//                let viewControl = self.storyboard?.instantiateViewController(withIdentifier: "mainScreen") as! securityViewController
//                //     mainViewControl.communicationDelegate = self
//                viewControl.delegate = self
//                alertView = viewControl
//                splitViewController?.showDetailViewController(viewControl, sender: self)
//
//            case "Roster" :
//                let viewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "rosterForm") as! shiftMaintenanceViewController
//                viewControl.delegate = self
//                splitViewController?.showDetailViewController(viewControl, sender: self)
//
//            case menuEventPlanning :
//              //  let viewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "eventPlanningForm") as! eventPlanningViewController
//                let split = invoiceStoryboard.instantiateViewController(withIdentifier: "personInvoiceSplit") as! childSplitView
//                mainDelegate = self
//                split.targetItem = menuEventPlanning
//                mainViewController = splitViewController
//                self.view.window?.rootViewController = split
//
//               // splitViewController?.showDetailViewController(viewControl, sender: self)
//
//            case menuEventTemplates :
//               // let viewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "eventTemplateForm") as! eventTemplateVoewController
//                let split = invoiceStoryboard.instantiateViewController(withIdentifier: "personInvoiceSplit") as! childSplitView
//                split.targetItem = menuEventTemplates
//                mainViewController = splitViewController
//                self.view.window?.rootViewController = split
//
//            //    splitViewController?.showDetailViewController(viewControl, sender: self)
//
//            case menuMonthlyRoster :
//                   // let viewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "monthlyRoster") as! monthlyRosterViewController
//                    let split = invoiceStoryboard.instantiateViewController(withIdentifier: "personInvoiceSplit") as! childSplitView
//                    split.targetItem = menuMonthlyRoster
//                    mainViewController = splitViewController
//                    self.view.window?.rootViewController = split
//
//                 //   splitViewController?.showDetailViewController(viewControl, sender: self)
//
//            case menuWeeklyRoster :
//                let split = invoiceStoryboard.instantiateViewController(withIdentifier: "personInvoiceSplit") as! childSplitView
//                split.targetItem = menuWeeklyRoster
//                mainViewController = splitViewController
//                self.view.window?.rootViewController = split
//
//            case menuMonthlyBookings :
//                let viewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "monthlySummary") as! monthlySummaryViewController
//                viewControl.communicationDelegate = self
//                splitViewController?.showDetailViewController(viewControl, sender: self)
//
//            case "Reports" :
//                    let viewControl = reportsStoryboard.instantiateViewController(withIdentifier: "reportScreen") as! reportView
//                    splitViewController?.showDetailViewController(viewControl, sender: self)
//
//            case "New Communication" :
//                let newComm = commsLogEntry(teamID: (currentUser.currentTeam?.teamID)!)
//
//                let viewControl = settingsStoryboard.instantiateViewController(withIdentifier: "commsLogView") as! commsLogView
//                viewControl.modalPresentationStyle = .popover
//
//                let popover = viewControl.popoverPresentationController!
//                popover.delegate = self
//                popover.sourceView = tableView
//                popover.sourceRect = tableView.bounds
//                popover.permittedArrowDirections = .any
//
//                viewControl.preferredContentSize = CGSize(width: 500,height: 800)
//                viewControl.workingEntry = newComm
//                self.present(viewControl, animated: true, completion: nil)
//
//            case menuStaffInvoicing :
//                let split = invoiceStoryboard.instantiateViewController(withIdentifier: "personInvoiceSplit") as! childSplitView
//
//                split.targetItem = menuStaffInvoicing
//                mainViewController = splitViewController
//                self.view.window?.rootViewController = split
//
//            case "Staff To Pay" :
//                let viewControl = invoiceStoryboard.instantiateViewController(withIdentifier: "staffInvoicesToPayView") as! staffInvoicesToPayViewController
//                splitViewController?.showDetailViewController(viewControl, sender: self)
//
//
//            case "Client Invoices" :
//                let split = invoiceStoryboard.instantiateViewController(withIdentifier: "clientInvoiceSplitView") as! clientInvoiceSplitViewController
//                mainViewController = splitViewController
//                self.view.window?.rootViewController = split
//
//            case "Settings" :
//                 let viewControl = settingsStoryboard.instantiateViewController(withIdentifier: "settings") as! settingsViewController
//                 splitViewController?.showDetailViewController(viewControl, sender: self)
//
//            case "client" :
//                var selectedClient: client!
//                if displayOptions[indexPath.row].index == -1
//                {
//                    selectedClient = client(teamID: (currentUser.currentTeam?.teamID)!)
//                }
//                else
//                {
//                    selectedClient = client(clientID: displayOptions[indexPath.row].index, teamID: (currentUser.currentTeam?.teamID)!)
//                }
//                let viewControl = clientsStoryboard.instantiateViewController(withIdentifier: "clientMaintenance") as! clientMaintenanceViewController
//                viewControl.selectedClient = selectedClient
//                splitViewController?.showDetailViewController(viewControl, sender: self)
//
//            case "project" :
//                let selectedproject = project(projectID: displayOptions[indexPath.row].index, teamID: (currentUser.currentTeam?.teamID)!)
//                let viewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
//                viewControl.workingContract = selectedproject
//                viewControl.delegate = self
//                splitViewController?.showDetailViewController(viewControl, sender: self)
//               // contractEditViewControl.communicationDelegate = self
//
//            case "person" :
//                var currentPerson: person!
//                if displayOptions[indexPath.row].index == -1
//                {
//                    currentPerson = person(teamID: (currentUser.currentTeam?.teamID)!)
//                }
//                else
//                {
//                    currentPerson = person(personID: displayOptions[indexPath.row].index, teamID: (currentUser.currentTeam?.teamID)!)
//                }
//
//                let viewControl = personStoryboard.instantiateViewController(withIdentifier: "personForm") as! personViewController
//                viewControl.selectedPerson = currentPerson
//                splitViewController?.showDetailViewController(viewControl, sender: self)
//
//            case "sales" :
//                var currentLead: lead!
//                if displayOptions[indexPath.row].index == -1
//                {
//                    // new lead
//                    currentLead = lead(teamID: (currentUser.currentTeam?.teamID)!, name: "New", source: "App", sourceID: "0", ownerID: 0)
//                }
//                else
//                {
//                    currentLead = lead(leadID: displayOptions[indexPath.row].index, teamID: (currentUser.currentTeam?.teamID)!)
//                }
//
//                let viewControl = salesStoryboard.instantiateViewController(withIdentifier: "leadsView") as! leadsViewController
//                viewControl.passedLead = currentLead
//                splitViewController?.showDetailViewController(viewControl, sender: self)
//
//            case "Course" :
//                let viewControl = coursesStoryboard.instantiateViewController(withIdentifier: "coursesView") as! coursesViewController
//                splitViewController?.showDetailViewController(viewControl, sender: self)
//
//            case "Invoice Settings" :
//                let viewControl = invoiceStoryboard.instantiateViewController(withIdentifier: "invoiceSettingsView") as! invoiceSettingsViewController
//                splitViewController?.showDetailViewController(viewControl, sender: self)
//
//            case "" :
//                for item in menuOptions
//                {
//                    if item.parentID == displayOptions[indexPath.row].ID
//                    {
//                        item.display = !item.display
//                    }
//                }
//
//                tableView.reloadData()
//
//            default:
//                let _ = 1
//        }
    }
    
    public func refreshScreen()
    {
        if alertView != nil
        {
            DispatchQueue.main.async
            {
                self.alertView.refreshScreen()
            }
        }
    }
    
    func reloadMenu()
    {
        clientList = clients(teamID: (currentUser.currentTeam?.teamID)!, isActive: showActive)
        
        if currentUser.checkReadPermission(pmRoleType)
        {
            projectList = projects(teamID: currentUser.currentTeam!.teamID, includeEvents: true, isActive: true)
        }
        
        peopleList = people(teamID: (currentUser.currentTeam?.teamID)!, isActive: showActive)
        
        leadList = leads(teamID: (currentUser.currentTeam?.teamID)!, isActive: showActive)
        
//        loadMenu()
    }
    
    func loadShifts()
    {
//        menuOptions.removeAll()
//        let temp0 = menuArray(menuTextx: "Loading Shifts.  Please wait.", menuActionx: "", indexx: 0, IDx: 0, parentIDx: 0, displayx: true)
//        menuOptions.append(temp0)
//        DispatchQueue.main.async
//        {
//            self.menuTable.reloadData()
//        }
//
//        //currentUser.currentTeam?.shifts = nil
//     //   currentUser.currentTeam?.reloadShiftData = true
//
//        DispatchQueue.global().async
//        {
//            currentUser.currentTeam?.loadShifts(self)
//
//                //myCloudDB.getShifts(teamID: (currentUser.currentTeam?.teamID)!)
//
//            DispatchQueue.main.async
//            {
//                self.loadMenu()
//            }
//        }
    }
    
//    func loadMenu()
//    {
//        menuOptions.removeAll()
//        var menuID: Int = 1
//        var parentID: Int = 0
//
//        let tempA = menuArray(menuTextx: "Dashboard", menuActionx: "Dashboard", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
//        menuOptions.append(tempA)
//        menuID += 1
//
////        let temp0 = menuArray(menuTextx: "Alerts", menuActionx: "Alerts", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
////        menuOptions.append(temp0)
////        menuID += 1
//
//        if currentUser.checkReadPermission(rosteringRoleType)
//        {
//            let temp5 = menuArray(menuTextx: "Rostering", menuActionx: "", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
//            menuOptions.append(temp5)
//            parentID = menuID
//            menuID += 1
//
//            let temp6 = menuArray(menuTextx: "     Roster", menuActionx: "Roster", indexx: 0, IDx: menuID, parentIDx: parentID, displayx: false)
//            menuOptions.append(temp6)
//            menuID += 1
//
//            let temp7 = menuArray(menuTextx: "     Event Planning", menuActionx: menuEventPlanning, indexx: 0, IDx: menuID, parentIDx: parentID, displayx: false)
//            menuOptions.append(temp7)
//            menuID += 1
//
//            let temp8 = menuArray(menuTextx: "     Event Templates", menuActionx: menuEventTemplates, indexx: 0, IDx: menuID, parentIDx: parentID, displayx: false)
//            menuOptions.append(temp8)
//            menuID += 1
//
//            let temp8a = menuArray(menuTextx: "     Monthly Roster", menuActionx: menuMonthlyRoster, indexx: 0, IDx: menuID, parentIDx: parentID, displayx: false)
//            menuOptions.append(temp8a)
//            menuID += 1
//
//            let temp8b = menuArray(menuTextx: "     Weekly Roster", menuActionx: menuWeeklyRoster, indexx: 0, IDx: menuID, parentIDx: parentID, displayx: false)
//            menuOptions.append(temp8b)
//            menuID += 1
//
//            let temp8c = menuArray(menuTextx: "     Monthly Bookings", menuActionx: menuMonthlyBookings, indexx: 0, IDx: menuID, parentIDx: parentID, displayx: false)
//            menuOptions.append(temp8c)
//            menuID += 1
//        }
//
//        if currentUser.checkReadPermission(coachingRoleType)
//        {
//            let temp8c = menuArray(menuTextx: "Coaching", menuActionx: "Course", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
//            menuOptions.append(temp8c)
//            menuID += 1
//        }
//
//        if currentUser.checkReadPermission(salesRoleType)
//        {
//            let temp8b = menuArray(menuTextx: "Sales", menuActionx: "", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
//            menuOptions.append(temp8b)
//            parentID = menuID
//            menuID += 1
//
//            for item in leadList.leads
//            {
//                let tempLead = menuArray(menuTextx: "     \(item.name)", menuActionx: "sales", indexx: item.leadID, IDx: menuID, parentIDx: parentID, displayx: false)
//                menuOptions.append(tempLead)
//                menuID += 1
//            }
//
//            let tempLead = menuArray(menuTextx: "     Add Lead", menuActionx: "sales", indexx: -1, IDx: menuID, parentIDx: parentID, displayx: false)
//            menuOptions.append(tempLead)
//            menuID += 1
//        }
//
//        if currentUser.checkReadPermission(invoicingRoleType)
//        {
//            let temp14 = menuArray(menuTextx: "Invoicing", menuActionx: "", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
//            menuOptions.append(temp14)
//            parentID = menuID
//            menuID += 1
//
//            let temp15 = menuArray(menuTextx: "     Staff Invoicing", menuActionx: menuStaffInvoicing, indexx: 0, IDx: menuID, parentIDx: parentID, displayx: false)
//            menuOptions.append(temp15)
//            menuID += 1
//
//            let temp15a = menuArray(menuTextx: "     Staff Invoices To Pay", menuActionx: "Staff To Pay", indexx: 0, IDx: menuID, parentIDx: parentID, displayx: false)
//            menuOptions.append(temp15a)
//            menuID += 1
//
//            let temp15b = menuArray(menuTextx: "     Client Invoices", menuActionx: "Client Invoices", indexx: 0, IDx: menuID, parentIDx: parentID, displayx: false)
//            menuOptions.append(temp15b)
//            menuID += 1
//
//            let temp15c = menuArray(menuTextx: "     Invoice Settings", menuActionx: "Invoice Settings", indexx: 0, IDx: menuID, parentIDx: parentID, displayx: false)
//            menuOptions.append(temp15c)
//            menuID += 1
//        }
//
//        if currentUser.checkReadPermission(salesRoleType) || currentUser.checkReadPermission(clientRoleType)
//        {
//            let temp17 = menuArray(menuTextx: "Clients", menuActionx: "", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
//            menuOptions.append(temp17)
//            parentID = menuID
//            menuID += 1
//
//            for item in clientList.clients
//            {
//                let tempClient = menuArray(menuTextx: "     \(item.name)", menuActionx: "client", indexx: item.clientID, IDx: menuID, parentIDx: parentID, displayx: false)
//                menuOptions.append(tempClient)
//                menuID += 1
//            }
//
//            let tempClient = menuArray(menuTextx: "     Add Client", menuActionx: "client", indexx: -1, IDx: menuID, parentIDx: parentID, displayx: false)
//            menuOptions.append(tempClient)
//            menuID += 1
//        }
//
//        if currentUser.checkReadPermission(pmRoleType)
//        {
//            let temp17a = menuArray(menuTextx: "Projects", menuActionx: "", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
//            menuOptions.append(temp17a)
//            parentID = menuID
//            menuID += 1
//
//            for item in projectList.projects
//            {
//                var clientName: String = ""
//
//                if item.clientID > 0
//                {
//                    let temp = clientList.clients.filter {$0.clientID == item.clientID}
//
//                    if temp.count > 0
//                    {
//                        clientName = " - \(temp[0].name)"
//                    }
//                }
//                let tempClient = menuArray(menuTextx: "     \(item.projectName) \(clientName)", menuActionx: "project", indexx: item.projectID, IDx: menuID, parentIDx: parentID, displayx: false)
//                menuOptions.append(tempClient)
//                menuID += 1
//            }
//        }
//
//        if currentUser.checkReadPermission(hrRoleType)
//        {
//            let temp17b = menuArray(menuTextx: "People", menuActionx: "", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
//            menuOptions.append(temp17b)
//            parentID = menuID
//            menuID += 1
//
//            for item in peopleList.people
//            {
//                let tempClient = menuArray(menuTextx: "     \(item.name)", menuActionx: "person", indexx: item.personID, IDx: menuID, parentIDx: parentID, displayx: false)
//                menuOptions.append(tempClient)
//                menuID += 1
//            }
//
//            let tempPerson = menuArray(menuTextx: "     Add Person", menuActionx: "person", indexx: -1, IDx: menuID, parentIDx: parentID, displayx: false)
//            menuOptions.append(tempPerson)
//            menuID += 1
//        }
//
//        let temp10 = menuArray(menuTextx: "Reports", menuActionx: "Reports", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
//        menuOptions.append(temp10)
//        menuID += 1
//
//        let temp12 = menuArray(menuTextx: "New Communication", menuActionx: "New Communication", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
//        menuOptions.append(temp12)
//        menuID += 1
//
//        if currentUser.checkReadPermission(adminRoleType)
//        {
//            let temp16 = menuArray(menuTextx: "Settings", menuActionx: "Settings", indexx: 0, IDx: menuID, parentIDx: 0, displayx: true)
//            menuOptions.append(temp16)
//            menuID += 1
//            menuTable.reloadData()
//        }
//    }
}
