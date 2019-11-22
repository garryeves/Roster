//
//  mainBusinessView.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 13/7/19.
//  Copyright © 2019 Garry Eves. All rights reserved.
//

import SwiftUI
import evesShared

struct mainBusinessView : View {
    
    @State var icComms = interClassComms()
    
    var body: some View {
        NavigationView {
            leftMainView(inComms: icComms)
            
            if icComms.menuSelected == "Roster" {
                rosterView()
            }
            else if icComms.menuSelected == menuEventPlanning {
                eventPlanningView()
            }
            else if icComms.menuSelected == menuEventTemplates {
                eventTemplateView()
            }
            else if icComms.menuSelected == menuMonthlyRoster {
                monthlyRosterView()
            }
            else if icComms.menuSelected == menuWeeklyRoster {
                weeklyRosterView()
            }
            else if icComms.menuSelected == menuMonthlyBookings {
                monthlyBookingsView()
            }
            else if icComms.menuSelected == "Course" {
                Text("do course")
            }
            else if icComms.menuSelected == "sales" {
                salesView()
            }
            else if icComms.menuSelected == menuStaffInvoicing {
                staffInvoicingView()
            }
            else if icComms.menuSelected == "Staff To Pay" {
                staffInvoicesToPayView()
            }
            else if icComms.menuSelected == "Client Invoices" {
                clientInvoicesView()
            }
            else if icComms.menuSelected == "Invoice Settings" {
                invoiceSettingsView()
            }
            else if icComms.menuSelected == "client" {
                clientsView()
            }
            else if icComms.menuSelected == "project" {
                projectsView()
            }
            else if icComms.menuSelected == "person" {
                personView()
            }
            else if icComms.menuSelected == "Reports" {
                Text("do reports")
            }
            else if icComms.menuSelected == "New Communication" {
                communicationEntryView()
            }
            else if icComms.menuSelected == "Settings" {
                settingsView()
            }
            else
            {
                mainScreenView()
            }
        }
       
    }
}

#if DEBUG
struct mainBusinessView_Previews : PreviewProvider {
    static var previews: some View {
        mainBusinessView()
    }
}
#endif


//override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
//{
//    alertView = nil
//    //        switch displayOptions[indexPath.row].menuAction
//    //        {
//    //            case "Dashboard" :
//    //                let viewControl = self.storyboard?.instantiateViewController(withIdentifier: "dashboardView") as! dashboardViewController
//    //                //     mainViewControl.communicationDelegate = self
//    //                viewControl.delegate = self
//    //             //   alertView = viewControl
//    //                splitViewController?.showDetailViewController(viewControl, sender: self)
//    //
//    //            case "Alerts" :
//    //                let viewControl = self.storyboard?.instantiateViewController(withIdentifier: "mainScreen") as! securityViewController
//    //                //     mainViewControl.communicationDelegate = self
//    //                viewControl.delegate = self
//    //                alertView = viewControl
//    //                splitViewController?.showDetailViewController(viewControl, sender: self)
//    //
//    //            case "Roster" :
//    //                let viewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "rosterForm") as! shiftMaintenanceViewController
//    //                viewControl.delegate = self
//    //                splitViewController?.showDetailViewController(viewControl, sender: self)
//    //
//    //            case menuEventPlanning :
//    //              //  let viewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "eventPlanningForm") as! eventPlanningViewController
//    //                let split = invoiceStoryboard.instantiateViewController(withIdentifier: "personInvoiceSplit") as! childSplitView
//    //                mainDelegate = self
//    //                split.targetItem = menuEventPlanning
//    //                mainViewController = splitViewController
//    //                self.view.window?.rootViewController = split
//    //
//    //               // splitViewController?.showDetailViewController(viewControl, sender: self)
//    //
//    //            case menuEventTemplates :
//    //               // let viewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "eventTemplateForm") as! eventTemplateVoewController
//    //                let split = invoiceStoryboard.instantiateViewController(withIdentifier: "personInvoiceSplit") as! childSplitView
//    //                split.targetItem = menuEventTemplates
//    //                mainViewController = splitViewController
//    //                self.view.window?.rootViewController = split
//    //
//    //            //    splitViewController?.showDetailViewController(viewControl, sender: self)
//    //
//    //            case menuMonthlyRoster :
//    //                   // let viewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "monthlyRoster") as! monthlyRosterViewController
//    //                    let split = invoiceStoryboard.instantiateViewController(withIdentifier: "personInvoiceSplit") as! childSplitView
//    //                    split.targetItem = menuMonthlyRoster
//    //                    mainViewController = splitViewController
//    //                    self.view.window?.rootViewController = split
//    //
//    //                 //   splitViewController?.showDetailViewController(viewControl, sender: self)
//    //
//    //            case menuWeeklyRoster :
//    //                let split = invoiceStoryboard.instantiateViewController(withIdentifier: "personInvoiceSplit") as! childSplitView
//    //                split.targetItem = menuWeeklyRoster
//    //                mainViewController = splitViewController
//    //                self.view.window?.rootViewController = split
//    //
//    //            case menuMonthlyBookings :
//    //                let viewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "monthlySummary") as! monthlySummaryViewController
//    //                viewControl.communicationDelegate = self
//    //                splitViewController?.showDetailViewController(viewControl, sender: self)
//    //
//    //            case "Reports" :
//    //                    let viewControl = reportsStoryboard.instantiateViewController(withIdentifier: "reportScreen") as! reportView
//    //                    splitViewController?.showDetailViewController(viewControl, sender: self)
//    //
//    //            case "New Communication" :
//    //                let newComm = commsLogEntry(teamID: (currentUser.currentTeam?.teamID)!)
//    //
//    //                let viewControl = settingsStoryboard.instantiateViewController(withIdentifier: "commsLogView") as! commsLogView
//    //                viewControl.modalPresentationStyle = .popover
//    //
//    //                let popover = viewControl.popoverPresentationController!
//    //                popover.delegate = self
//    //                popover.sourceView = tableView
//    //                popover.sourceRect = tableView.bounds
//    //                popover.permittedArrowDirections = .any
//    //
//    //                viewControl.preferredContentSize = CGSize(width: 500,height: 800)
//    //                viewControl.workingEntry = newComm
//    //                self.present(viewControl, animated: true, completion: nil)
//    //
//    //            case menuStaffInvoicing :
//    //                let split = invoiceStoryboard.instantiateViewController(withIdentifier: "personInvoiceSplit") as! childSplitView
//    //
//    //                split.targetItem = menuStaffInvoicing
//    //                mainViewController = splitViewController
//    //                self.view.window?.rootViewController = split
//    //
//    //            case "Staff To Pay" :
//    //                let viewControl = invoiceStoryboard.instantiateViewController(withIdentifier: "staffInvoicesToPayView") as! staffInvoicesToPayViewController
//    //                splitViewController?.showDetailViewController(viewControl, sender: self)
//    //
//    //
//    //            case "Client Invoices" :
//    //                let split = invoiceStoryboard.instantiateViewController(withIdentifier: "clientInvoiceSplitView") as! clientInvoiceSplitViewController
//    //                mainViewController = splitViewController
//    //                self.view.window?.rootViewController = split
//    //
//    //            case "Settings" :
//    //                 let viewControl = settingsStoryboard.instantiateViewController(withIdentifier: "settings") as! settingsViewController
//    //                 splitViewController?.showDetailViewController(viewControl, sender: self)
//    //
//    //            case "client" :
//    //                var selectedClient: client!
//    //                if displayOptions[indexPath.row].index == -1
//    //                {
//    //                    selectedClient = client(teamID: (currentUser.currentTeam?.teamID)!)
//    //                }
//    //                else
//    //                {
//    //                    selectedClient = client(clientID: displayOptions[indexPath.row].index, teamID: (currentUser.currentTeam?.teamID)!)
//    //                }
//    //                let viewControl = clientsStoryboard.instantiateViewController(withIdentifier: "clientMaintenance") as! clientMaintenanceViewController
//    //                viewControl.selectedClient = selectedClient
//    //                splitViewController?.showDetailViewController(viewControl, sender: self)
//    //
//    //            case "project" :
//    //                let selectedproject = project(projectID: displayOptions[indexPath.row].index, teamID: (currentUser.currentTeam?.teamID)!)
//    //                let viewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
//    //                viewControl.workingContract = selectedproject
//    //                viewControl.delegate = self
//    //                splitViewController?.showDetailViewController(viewControl, sender: self)
//    //               // contractEditViewControl.communicationDelegate = self
//    //
//    //            case "person" :
//    //                var currentPerson: person!
//    //                if displayOptions[indexPath.row].index == -1
//    //                {
//    //                    currentPerson = person(teamID: (currentUser.currentTeam?.teamID)!)
//    //                }
//    //                else
//    //                {
//    //                    currentPerson = person(personID: displayOptions[indexPath.row].index, teamID: (currentUser.currentTeam?.teamID)!)
//    //                }
//    //
//    //                let viewControl = personStoryboard.instantiateViewController(withIdentifier: "personForm") as! personViewController
//    //                viewControl.selectedPerson = currentPerson
//    //                splitViewController?.showDetailViewController(viewControl, sender: self)
//    //
//    //            case "sales" :
//    //                var currentLead: lead!
//    //                if displayOptions[indexPath.row].index == -1
//    //                {
//    //                    // new lead
//    //                    currentLead = lead(teamID: (currentUser.currentTeam?.teamID)!, name: "New", source: "App", sourceID: "0", ownerID: 0)
//    //                }
//    //                else
//    //                {
//    //                    currentLead = lead(leadID: displayOptions[indexPath.row].index, teamID: (currentUser.currentTeam?.teamID)!)
//    //                }
//    //
//    //                let viewControl = salesStoryboard.instantiateViewController(withIdentifier: "leadsView") as! leadsViewController
//    //                viewControl.passedLead = currentLead
//    //                splitViewController?.showDetailViewController(viewControl, sender: self)
//    //
//    //            case "Course" :
//    //                let viewControl = coursesStoryboard.instantiateViewController(withIdentifier: "coursesView") as! coursesViewController
//    //                splitViewController?.showDetailViewController(viewControl, sender: self)
//    //
//    //            case "Invoice Settings" :
//    //                let viewControl = invoiceStoryboard.instantiateViewController(withIdentifier: "invoiceSettingsView") as! invoiceSettingsViewController
//    //                splitViewController?.showDetailViewController(viewControl, sender: self)
//    //
//    //            case "" :
//    //                for item in menuOptions
//    //                {
//    //                    if item.parentID == displayOptions[indexPath.row].ID
//    //                    {
//    //                        item.display = !item.display
//    //                    }
//    //                }
//    //
//    //                tableView.reloadData()
//    //
//    //            default:
//    //                let _ = 1
//    //        }
//}
