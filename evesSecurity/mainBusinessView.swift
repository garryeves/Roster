////
////  mainBusinessView.swift
////  Shift Dashboard
////
////  Created by Garry Eves on 13/7/19.
////  Copyright © 2019 Garry Eves. All rights reserved.
////
//
//import SwiftUI
//import evesShared
//
//struct mainBusinessView : View {
//    
//    @EnvironmentObject var userAuth: UserAuth
//    
//    @State var showModal = true
//    @State var addComms = false
//    
//    var body: some View {
//        return NavigationView {
//            leftMainView()
//            
//            if userAuth.menuSelected == "Roster" {
//                rosterView()
//            }
//            else if userAuth.menuSelected == menuEventPlanning {
//                eventPlanningView()
//            }
//            else if userAuth.menuSelected == menuEventTemplates {
//                eventTemplateView()
//            }
//            else if userAuth.menuSelected == menuMonthlyRoster {
//                monthlyRosterView()
//            }
//            else if userAuth.menuSelected == menuWeeklyRoster {
//                weeklyRosterView()
//            }
//            else if userAuth.menuSelected == menuMonthlyBookings {
//                monthlyBookingsView()
//            }
//            else if userAuth.menuSelected == "Course" {
//                Text("do course")
//            }
//            else if userAuth.menuSelected == "sales" {
//                leadItemView()
//            }
//            else if userAuth.menuSelected == menuStaffInvoicing {
//                staffInvoicingView()
//            }
//            else if userAuth.menuSelected == "Staff To Pay" {
//                staffInvoicesToPayView()
//            }
//            else if userAuth.menuSelected == "Client Invoices" {
//                clientInvoicesView()
//            }
//            else if userAuth.menuSelected == "Invoice Settings" {
//                invoiceSettingsView()
//            }
//            else if userAuth.menuSelected == "client" {
//                clientItemView()
//            }
//            else if userAuth.menuSelected == "project" {
//                projectItemView()
//            }
//            else if userAuth.menuSelected == "person" {
//               // self.showModal = true
//                
//         //       let toShow = Modal(personItemView()) { self.showModal.toggle() }
//                
//           //     let toShow = Text("test")
////                Text("")
////                    .presentation(self.showModal ?  Modal(personItemView()) : nil)
//                
//                personItemView()
//            }
//            else if userAuth.menuSelected == "Reports" {
//                Text("do reports")
//            }
//            else if userAuth.menuSelected == "New Communication" {
//               // userAuth.addComms = true
//               // communicationEntryView(addComms: self.$addComms)
//            }
//            else if userAuth.menuSelected == "Settings" {
//                settingsView()
//            }
//            else
//            {
//                mainScreenView()
//            }
//        }
//        
//    }
//}
//
//#if DEBUG
//struct mainBusinessView_Previews : PreviewProvider {
//    static var previews: some View {
//        mainBusinessView()
//    }
//}
//#endif
//
//
////case "Shift":
////let workingShift = object as! shift
////
////if workingShift.type == eventShiftType
////{
////    let workingProject = project(projectID: workingShift.projectID, teamID: currentUser.currentTeam!.teamID)
////
////    let viewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "eventPlanningForm") as! eventPlanningViewController
////    viewControl.currentEvent = workingProject
////    splitViewController?.showDetailViewController(viewControl, sender: self)
////}
////else
////{
////    let viewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "rosterForm") as! shiftMaintenanceViewController
////    viewControl.delegate = delegate
////    splitViewController?.showDetailViewController(viewControl, sender: self)
////}
