//
//  monthlyRosterViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 31/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit
import DLRadioButton

public class monthlyRosterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, myCommunicationDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var lblContactDetails: UILabel!
    @IBOutlet weak var tblRoster: UITableView!
    @IBOutlet weak var tblContact: UITableView!
    @IBOutlet weak var btnShare: UIBarButtonItem!
    @IBOutlet weak var btnIncludeRates: DLRadioButton!
    @IBOutlet weak var btnNoRates: DLRadioButton!
    @IBOutlet weak var lblRosterHeader: UINavigationItem!
    
    open var communicationDelegate: myCommunicationDelegate?
    
    public var selectedPerson: person!
    public var month: String!
    public var year: String!
    
    fileprivate var workingReport: report!
    
    override public func viewDidLoad()
    {
        if selectedPerson != nil
        {
            selectedPerson.loadContacts()
            tblContact.reloadData()
            lblRosterHeader.title = "\(month!) \(year!) Roster for \(selectedPerson.name)"
            refreshScreen()
        }
        else
        {
            lblRosterHeader.title = menuMonthlyRoster
            hideFields()
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView
        {
            case tblContact:
                if selectedPerson == nil
                {
                    return 0
                }
                else
                {
                    return selectedPerson.contacts.count
                }
                
            case tblRoster:
                if workingReport == nil
                {
                    return 0
                }
                else
                {
                    return workingReport.lines.count
                }
            
            default:
                return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblContact:
                let cell = tableView.dequeueReusableCell(withIdentifier:"contactCell", for: indexPath) as! rosterContactItem
                
                cell.lblType.text = selectedPerson.contacts[indexPath.row].contactType
                cell.lblDetails.text = selectedPerson.contacts[indexPath.row].contactValue
                
                return cell
                
            case tblRoster:
                // if rate has a shift them do not allow iot to be removed, unenable button
                
                let cell = tableView.dequeueReusableCell(withIdentifier:"rosterCell", for: indexPath) as! rosterDisplayItem
                
                cell.lblDate.text = workingReport.lines[indexPath.row].column1
                cell.lblFrom.text = "\(workingReport.lines[indexPath.row].column2) - \(workingReport.lines[indexPath.row].column3)"
                cell.lblContract.text = workingReport.lines[indexPath.row].column5
                cell.lblRate.text = workingReport.lines[indexPath.row].column4

                return cell
            
            default:
                return UITableViewCell()
        }
    }

//    @IBAction func btnBack(_ sender: UIBarButtonItem)
//    {
//        communicationDelegate?.refreshScreen!()
//        self.dismiss(animated: true, completion: nil)
//    }
    
    @IBAction func btnShare(_ sender: UIBarButtonItem)
    {
        if selectedPerson != nil
        {
            let activityViewController = workingReport.activityController
            
            activityViewController.popoverPresentationController!.sourceView = lblContactDetails
            
            present(activityViewController, animated:true, completion:nil)
        }
    }
    
    @IBAction func btnIncludeRates(_ sender: DLRadioButton)
    {
        if sender == btnIncludeRates
        {
            btnNoRates.isSelected = !btnIncludeRates.isSelected
        }
        else
        {
            btnIncludeRates.isSelected = !btnNoRates.isSelected
        }
        
        buildReport()
        tblRoster.reloadData()
    }
    
    func buildReport()
    {
        workingReport = report(name: reportMonthlyRoster)
        workingReport.subject = "Shifts for \(selectedPerson.name) for the month of \(month!)"
        
        workingReport.columnWidth1 = 20
        workingReport.columnWidth2 = 12
        workingReport.columnWidth3 = 12
        workingReport.columnWidth4 = 28
        workingReport.columnWidth5 = 28
        
        let headerLine = reportLine()
        headerLine.column1 = "Date"
        headerLine.column2 = "Start"
        headerLine.column3 = "End"
        headerLine.column4 = "Rate"
        headerLine.column5 = "Where"
        
        workingReport.header = headerLine
        
        if selectedPerson != nil
        {
            for myShift in selectedPerson.shiftArray
            {
                let workingLine = reportLine()
                
                workingLine.column1 = myShift.workDateString
                workingLine.column2 = myShift.startTimeString
                workingLine.column3 = myShift.endTimeString
                
                if btnIncludeRates.isSelected
                {
                    workingLine.column4 = myShift.rateDescription
                }
                else
                {
                    workingLine.column4 = ""
                }
                
                let tempProject = project(projectID: myShift.projectID, teamID: currentUser.currentTeam!.teamID)
                
                workingLine.column5 = tempProject.projectName
                
                workingReport.append(workingLine)
            }
        }
    }
    
    func hideFields()
    {
        lblContactDetails.isHidden = true
        tblRoster.isHidden = true
        tblContact.isHidden = true
        btnIncludeRates.isHidden = true
        btnNoRates.isHidden = true
    }
    
    func showFields()
    {
        lblContactDetails.isHidden = false
        tblRoster.isHidden = false
        tblContact.isHidden = false
        btnIncludeRates.isHidden = false
        btnNoRates.isHidden = false
    }
    
    public func refreshScreen()
    {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "YYYY"
//            let workingYear = dateFormatter.string(from: Date())
//            selectedPerson.loadShifts(month: btnMonth.currentTitle!, year: workingYear, teamID: currentUser.currentTeam!.teamID)
        
        selectedPerson.loadShifts(month: month, year: year, teamID: currentUser.currentTeam!.teamID)
        buildReport()
        tblRoster.reloadData()
    }
}

class rosterContactItem: UITableViewCell
{
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblDetails: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

class rosterDisplayItem: UITableViewCell
{
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblContract: UILabel!
    @IBOutlet weak var lblFrom: UILabel!
    @IBOutlet weak var lblRate: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}




