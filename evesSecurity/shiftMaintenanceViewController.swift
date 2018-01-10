//
//  shiftMaintenanceViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 21/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class shiftMaintenanceViewController: UIViewController, MyPickerDelegate, UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var lblWEDate: UILabel!
    @IBOutlet weak var lblWETitle: UILabel!
    @IBOutlet weak var tblShifts: UITableView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnback: UIBarButtonItem!
    @IBOutlet weak var btnCreateShift: UIButton!
    @IBOutlet weak var btnPreviousWeek: UIButton!
    @IBOutlet weak var btnNextWeek: UIButton!
    @IBOutlet weak var btnShare: UIBarButtonItem!

    var communicationDelegate: myCommunicationDelegate?
    
    fileprivate var peopleList: people!
    fileprivate var shiftList: [mergedShiftList] = Array()
    var currentWeekEndingDate: Date!
    fileprivate var contractList: projects!
    fileprivate var displayList: [String] = Array()
    
    override func viewDidLoad()
    {
        if currentWeekEndingDate == nil
        {
            currentWeekEndingDate = Date().getWeekEndingDate.startOfDay
        }
        refreshScreen()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return shiftList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        // if rate has a shift them do not allow iot to be removed, unenable button
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"cellRoster", for: indexPath) as! shiftListItem
        
        cell.mainView = self
        cell.sourceView = cell
        cell.peopleList = peopleList
        cell.weeklyRecord = shiftList[indexPath.row]
        
        // Get the client details
        
        let tempProject = project(projectID: shiftList[indexPath.row].projectID, teamID: currentUser.currentTeam!.teamID)
        
        if tempProject.clientID != 0
        {
            cell.rateList = rates(clientID: tempProject.clientID, teamID: currentUser.currentTeam!.teamID)
        }

        cell.shiftLineID = shiftList[indexPath.row].shiftLineID

        cell.lblContract.text = shiftList[indexPath.row].contract
        cell.txtDescription.text = shiftList[indexPath.row].description
        cell.btnShiftType.setTitle(shiftList[indexPath.row].type, for: .normal)
        
        displayTableRowDay(btnStart: cell.btnStartSun, btnEnd: cell.btnEndSun, btnRate: cell.btnRateSun, btnPerson: cell.btnPersonSun, sourceShift: shiftList[indexPath.row].sunShift, dateAdjustment: 0)
        displayTableRowDay(btnStart: cell.btnStartMon, btnEnd: cell.btnEndMon, btnRate: cell.btnRateMon, btnPerson: cell.btnPersonMon, sourceShift: shiftList[indexPath.row].monShift, dateAdjustment: -6)
        displayTableRowDay(btnStart: cell.btnStartTue, btnEnd: cell.btnEndTue, btnRate: cell.btnRateTue, btnPerson: cell.btnPersonTue, sourceShift: shiftList[indexPath.row].tueShift, dateAdjustment: -5)
        displayTableRowDay(btnStart: cell.btnStartWed, btnEnd: cell.btnEndWed, btnRate: cell.btnRateWed, btnPerson: cell.btnPersonWed, sourceShift: shiftList[indexPath.row].wedShift, dateAdjustment: -4)
        displayTableRowDay(btnStart: cell.btnStartThu, btnEnd: cell.btnEndThu, btnRate: cell.btnRateThu, btnPerson: cell.btnPersonThu, sourceShift: shiftList[indexPath.row].thuShift, dateAdjustment: -3)
        displayTableRowDay(btnStart: cell.btnStartFri, btnEnd: cell.btnEndFri, btnRate: cell.btnRateFri, btnPerson: cell.btnPersonFri, sourceShift: shiftList[indexPath.row].friShift, dateAdjustment: -2)
        displayTableRowDay(btnStart: cell.btnStartSat, btnEnd: cell.btnEndSat, btnRate: cell.btnRateSat, btnPerson: cell.btnPersonSat, sourceShift: shiftList[indexPath.row].satShift, dateAdjustment: -1)
 
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E dd MMM"
        
        let headerView = tableView.dequeueReusableCell(withIdentifier: "shiftHeader") as! shiftHeaderItem
        
        headerView.lblMon.text = dateFormatter.string(from: currentWeekEndingDate.add(.day, amount: -6))
        headerView.lblTue.text = dateFormatter.string(from: currentWeekEndingDate.add(.day, amount: -5))
        headerView.lblWed.text = dateFormatter.string(from: currentWeekEndingDate.add(.day, amount: -4))
        headerView.lblThu.text = dateFormatter.string(from: currentWeekEndingDate.add(.day, amount: -3))
        headerView.lblFri.text = dateFormatter.string(from: currentWeekEndingDate.add(.day, amount: -2))
        headerView.lblSat.text = dateFormatter.string(from: currentWeekEndingDate.add(.day, amount: -1))
        headerView.lblSun.text = dateFormatter.string(from: currentWeekEndingDate)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 35
    }
    
    private func displayTableRowDay(btnStart: UIButton, btnEnd: UIButton, btnRate: UIButton, btnPerson: UIButton, sourceShift: shift?, dateAdjustment: Int)
    {
        if sourceShift != nil
        {
            btnStart.setTitle(sourceShift?.startTimeString, for: .normal)
            btnEnd.setTitle(sourceShift?.endTimeString, for: .normal)
            
            if sourceShift?.rateID == 0
            {
                btnRate.setTitle("Rate", for: .normal)
            }
            else
            {
                btnRate.setTitle(sourceShift?.rateDescription, for: .normal)
            }
            
            if sourceShift?.personID == 0
            {
                btnPerson.setTitle("Person", for: .normal)
            }
            else
            {
                btnPerson.setTitle(sourceShift?.personName, for: .normal)
            }

            btnRate.isHidden = false
            btnPerson.isHidden = false
            
            if sourceShift?.clientInvoiceNumber != 0 || sourceShift?.personInvoiceNumber != 0
            {
                btnRate.isEnabled = false
                
                if sourceShift?.personInvoiceNumber != 0
                {
                    btnPerson.isEnabled = false
                }
            }
            else
            {
                btnRate.isEnabled = true
                btnPerson.isEnabled = true
            }
        }
        else
        {
            btnStart.setTitle("Set", for: .normal)
            btnEnd.setTitle("Set", for: .normal)
            btnRate.isHidden = true
            btnPerson.isHidden = true
            btnRate.setTitle("Rate", for: .normal)
            btnPerson.setTitle("Person", for: .normal)
        }
    }
    
    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        communicationDelegate?.refreshScreen!()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnAdd(_ sender: UIButton)
    {
        contractList = projects(teamID: currentUser.currentTeam!.teamID, includeEvents: false)
        
        displayList.removeAll()
        
        for myItem in contractList.projects
        {
            displayList.append(myItem.projectName)
        }
        
        if displayList.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "project"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 400,height: 400)
            pickerView.currentValue = sender.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnCreateShift(_ sender: UIButton)
    {
        // get the details for previous week
        
        let previousWEDate = currentWeekEndingDate.add(.day, amount: -7)
        
        // now go and see if there are any entries for that weeks
      
        let previousShifts = shifts(teamID: currentUser.currentTeam!.teamID, WEDate: previousWEDate)
        
        var recordCount: Int = 0
        for myItem in previousShifts.shifts
        {
            var newShift: shift!
            
            if recordCount == previousShifts.shifts.count - 1
            {
                newShift = shift(projectID: myItem.projectID, workDate: myItem.workDate.add(.day, amount: 7), weekEndDate: currentWeekEndingDate, teamID: currentUser.currentTeam!.teamID, shiftLineID: myItem.shiftLineID, type: myItem.type)
            }
            else
            {
                newShift = shift(projectID: myItem.projectID, workDate: myItem.workDate.add(.day, amount: 7), weekEndDate: currentWeekEndingDate, teamID: currentUser.currentTeam!.teamID, shiftLineID: myItem.shiftLineID, type: myItem.type, saveToCloud: false)
                recordCount += 1
            }
            
            newShift.shiftDescription = myItem.shiftDescription
            newShift.startTime = myItem.startTime
            newShift.endTime = myItem.endTime
            newShift.rateID = myItem.rateID
            newShift.save()
        }
        
        if recordCount == 0
        {
            //No previous weeks so we only need to show the sleect contract bits
            lblWETitle.isHidden = false
            btnCreateShift.isHidden = true
            btnAdd.isHidden = false
        }
        else
        {
            refreshScreen()
        }
    }
    
    @IBAction func btnPreviousWeek(_ sender: UIButton)
    {
        currentWeekEndingDate = currentWeekEndingDate.add(.day, amount: -7)
        refreshScreen()
    }
    
    @IBAction func btnNextWeek(_ sender: UIButton)
    {
        currentWeekEndingDate = currentWeekEndingDate.add(.day, amount: 7)
        refreshScreen()
    }
    
    @IBAction func btnShare(_ sender: UIBarButtonItem)
    {
        let tempReport = report(name: reportWeeklyRoster)
        
        let titleString = "\(currentUser.currentTeam!.name) Roster For Week Ending \(lblWEDate.text!)"
        tempReport.subject = titleString

        let headerLine = reportLine()
        headerLine.column1 = "Name"
        tempReport.columnWidth1 = 16.8
        headerLine.column2 = "Mon"
        tempReport.columnWidth2 = 11.8
        headerLine.column3 = "Tue"
        tempReport.columnWidth3 = 11.8
        headerLine.column4 = "Wed"
        tempReport.columnWidth4 = 11.8
        headerLine.column5 = "Thu"
        tempReport.columnWidth5 = 11.8
        headerLine.column6 = "Fri"
        tempReport.columnWidth6 = 11.8
        headerLine.column7 = "Sat"
        tempReport.columnWidth7 = 11.8
        headerLine.column8 = "Sun"
        tempReport.columnWidth8 = 11.8

        tempReport.header = headerLine
        tempReport.landscape()
        
        var currentContract: String = ""
        
        var firstTime: Bool = true
        
        if shiftList.count > 0
        {
            for myShift in shiftList
            {
                if myShift.contract != currentContract
                {
                    if !firstTime
                    {
                        let drawLine = reportLine()
                        drawLine.drawLine = true
                        tempReport.append(drawLine)
                    }
                    firstTime = false
                    let newReportLine = reportLine()
                    newReportLine.column1 = myShift.contract
                    tempReport.append(newReportLine)
                    currentContract = myShift.contract
                }
                else
                {
                    let drawLine = reportLine()
                    drawLine.drawLine = true
                    drawLine.lineColour = UIColor.gray
                    
                    tempReport.append(drawLine)
                }
                
                let newTimeLine = reportLine()
                let newPersonLine = reportLine()
                
                newTimeLine.column1 = myShift.description
            
                if myShift.monShift != nil
                {
                    newTimeLine.column2 = "\(myShift.monShift.startTimeString) - \(myShift.monShift.endTimeString)"
                    if myShift.monShift.personID != 0
                    {
                        newPersonLine.column2 = "\(myShift.monShift.personName)"
                    }
                }
                
                if myShift.tueShift != nil
                {
                    newTimeLine.column3 = "\(myShift.tueShift.startTimeString) - \(myShift.tueShift.endTimeString)"
                    if myShift.tueShift.personID != 0
                    {
                        newPersonLine.column3 = "\(myShift.tueShift.personName)"
                    }
                }
                
                if myShift.wedShift != nil
                {
                    newTimeLine.column4 = "\(myShift.wedShift.startTimeString) - \(myShift.wedShift.endTimeString)"
                    if myShift.wedShift.personID != 0
                    {
                        newPersonLine.column4 = "\(myShift.wedShift.personName)"
                    }
                }
                
                if myShift.thuShift != nil
                {
                    newTimeLine.column5 = "\(myShift.thuShift.startTimeString) - \(myShift.thuShift.endTimeString)"
                    if myShift.thuShift.personID != 0
                    {
                        newPersonLine.column5 = "\(myShift.thuShift.personName)"
                    }
                }
                
                if myShift.friShift != nil
                {
                    newTimeLine.column6 = "\(myShift.friShift.startTimeString) - \(myShift.friShift.endTimeString)"
                    if myShift.friShift.personID != 0
                    {
                        newPersonLine.column6 = "\(myShift.friShift.personName)"
                    }
                }
                
                if myShift.satShift != nil
                {
                    newTimeLine.column7 = "\(myShift.satShift.startTimeString) - \(myShift.satShift.endTimeString)"
                    if myShift.satShift.personID != 0
                    {
                        newPersonLine.column7 = "\(myShift.satShift.personName)"
                    }
                }
                
                if myShift.sunShift != nil
                {
                    newTimeLine.column8 = "\(myShift.sunShift.startTimeString) - \(myShift.sunShift.endTimeString)"
                    if myShift.sunShift.personID != 0
                    {
                        newPersonLine.column8 = "\(myShift.sunShift.personName)"
                    }
                }
                
                tempReport.append(newTimeLine)
                tempReport.append(newPersonLine)
            }
        
            let activityViewController = tempReport.activityController
            
            activityViewController.popoverPresentationController!.sourceView = btnCreateShift
            
            present(activityViewController, animated:true, completion:nil)
        }
    }

    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "project"
        {
            if selectedItem >= 0
            {
                // We have a new object, with a selected item, so we can go ahead and create a new summary row
                
                // create a dummy shift entry so we can get the sort order correct
                
                // Get the ntex shiftlineID
                    
                let lineID = myDatabaseConnection.getNextID("shiftLineID", teamID: contractList.projects[selectedItem].teamID)
                
                let workDate = currentWeekEndingDate.add(.day, amount: -1)
                
                let newShift = shift(projectID: contractList.projects[selectedItem].projectID, workDate: workDate, weekEndDate: currentWeekEndingDate, teamID: currentUser.currentTeam!.teamID, shiftLineID: lineID, type: shiftShiftType)
                
                newShift.startTime = getDefaultDate()
                newShift.endTime = getDefaultDate()
                newShift.save()
                    
                shiftList = shifts(teamID: currentUser.currentTeam!.teamID, WEDate: currentWeekEndingDate, type: shiftShiftType).weeklyShifts
                
                tblShifts.reloadData()
                
                let oldLastCellPath = IndexPath(row: shiftList.count - 1, section: 0)
                tblShifts.scrollToRow(at: oldLastCellPath, at: .bottom, animated: true)
            }
        }
    }
    
    func refreshScreen()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        lblWEDate.text = dateFormatter.string(from: currentWeekEndingDate)
        
        peopleList = people(teamID: currentUser.currentTeam!.teamID, canRoster: true)
        shiftList = shifts(teamID: currentUser.currentTeam!.teamID, WEDate: currentWeekEndingDate, type: shiftShiftType).weeklyShifts
        
        if shiftList.count == 0
        {
            lblWETitle.isHidden = true
            btnCreateShift.isHidden = false
            btnAdd.isHidden = true
        }
        else
        {
            lblWETitle.isHidden = false
            btnCreateShift.isHidden = true
            btnAdd.isHidden = false
        }
        
        tblShifts.reloadData()
    }
}

class shiftListItem: UITableViewCell, UIPopoverPresentationControllerDelegate, MyPickerDelegate
{
    @IBOutlet weak var lblContract: UILabel!
    @IBOutlet weak var txtDescription: UITextField!
    
    @IBOutlet weak var btnStartMon: UIButton!
    @IBOutlet weak var btnEndMon: UIButton!
    @IBOutlet weak var btnStartTue: UIButton!
    @IBOutlet weak var btnEndTue: UIButton!
    @IBOutlet weak var btnStartWed: UIButton!
    @IBOutlet weak var btnEndWed: UIButton!
    @IBOutlet weak var btnStartThu: UIButton!
    @IBOutlet weak var btnEndThu: UIButton!
    @IBOutlet weak var btnStartFri: UIButton!
    @IBOutlet weak var btnEndFri: UIButton!
    @IBOutlet weak var btnStartSat: UIButton!
    @IBOutlet weak var btnEndSat: UIButton!
    @IBOutlet weak var btnStartSun: UIButton!
    @IBOutlet weak var btnEndSun: UIButton!
    @IBOutlet weak var btnRateMon: UIButton!
    @IBOutlet weak var btnPersonMon: UIButton!
    
    @IBOutlet weak var btnRateTue: UIButton!
    @IBOutlet weak var btnPersonTue: UIButton!
    
    @IBOutlet weak var btnRateWed: UIButton!
    @IBOutlet weak var btnPersonWed: UIButton!
    
    @IBOutlet weak var btnRateThu: UIButton!
    @IBOutlet weak var btnPersonThu: UIButton!
    
    @IBOutlet weak var btnRateFri: UIButton!
    @IBOutlet weak var btnPersonFri: UIButton!
    
    @IBOutlet weak var btnRateSat: UIButton!
    @IBOutlet weak var btnPersonSat: UIButton!
    
    @IBOutlet weak var btnRateSun: UIButton!
    @IBOutlet weak var btnPersonSun: UIButton!
    
    @IBOutlet weak var btnShiftType: UIButton!
    
    @IBOutlet weak var constrainStartMon: NSLayoutConstraint!
    @IBOutlet weak var contraintMonTue: NSLayoutConstraint!
    @IBOutlet weak var constraintTueWed: NSLayoutConstraint!
    @IBOutlet weak var constraintWedThu: NSLayoutConstraint!
    @IBOutlet weak var constraintThuFri: NSLayoutConstraint!
    @IBOutlet weak var constrainFriSat: NSLayoutConstraint!
    @IBOutlet weak var constraintSatSun: NSLayoutConstraint!
    
    var peopleList: people!
    var rateList: rates!
    var weeklyRecord: mergedShiftList!
    var shiftLineID: Int!
    var projectID: Int!
    
    var sourceView: shiftListItem!
    var mainView: shiftMaintenanceViewController!
    
    fileprivate var displayList: [String] = Array()
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        
        let step1 = (bounds.width - (6 * 3) - 16) / 7   // This gives the width of the cell  width - gaps between cells - standard inset
        let step2 = CGFloat(45 + 45 + 8)    // This is the size of the group to display - width of both fields + the dash
        let step3 = ((step1 - step2) / 2) + CGFloat(3)   // This is the amount to indent
 
        contraintMonTue.constant = step3
        constraintTueWed.constant = step3
        constraintWedThu.constant = step3
        constraintThuFri.constant = step3
        constrainFriSat.constant = step3
        constraintSatSun.constant = step3
        constrainStartMon.constant = step3

        super.layoutSubviews()
    }

    @IBAction func btnRate(_ sender: UIButton)
    {
        displayList.removeAll()
        
        for myItem in rateList.rates
        {
            displayList.append(myItem.rateName)
        }
        
        displayList.append("")
        displayList.append("Delete Shift")
        
        if displayList.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = sourceView
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            switch sender
            {
                case btnRateMon:
                    pickerView.source = "btnRateMon"
                
                case btnRateTue:
                    pickerView.source = "btnRateTue"
                
                case btnRateWed:
                    pickerView.source = "btnRateWed"
                
                case btnRateThu:
                    pickerView.source = "btnRateThu"
                
                case btnRateFri:
                    pickerView.source = "btnRateFri"
                
                case btnRateSat:
                    pickerView.source = "btnRateSat"
                
                case btnRateSun:
                    pickerView.source = "btnRateSun"
                
                default:
                    print("shiftListItem btnRate got unexpected entry")
            }
            
            pickerView.delegate = sourceView
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 300,height: 500)
            pickerView.currentValue = sender.currentTitle!
            mainView.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnPerson(_ sender: UIButton)
    {
        displayList.removeAll()
        
        for myItem in peopleList.people
        {
            displayList.append(myItem.name)
        }
        
        if displayList.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = sourceView
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            switch sender
            {
                case btnPersonMon:
                    pickerView.source = "btnPersonMon"
                
                case btnPersonTue:
                    pickerView.source = "btnPersonTue"
                
                case btnPersonWed:
                    pickerView.source = "btnPersonWed"
                
                case btnPersonThu:
                    pickerView.source = "btnPersonThu"
                
                case btnPersonFri:
                    pickerView.source = "btnPersonFri"
                
                case btnPersonSat:
                    pickerView.source = "btnPersonSat"
                
                case btnPersonSun:
                    pickerView.source = "btnPersonSun"
                
                default:
                    print("shiftListItem btnPerson got unexpected entry")
            }

            pickerView.delegate = sourceView
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 300,height: 500)
            pickerView.currentValue = sender.currentTitle!
            mainView.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnSelectTime(_ sender: UIButton)
    {
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
        pickerView.modalPresentationStyle = .popover
        //      pickerView.isModalInPopover = true
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = sourceView
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        switch sender
        {
            case btnStartMon:
                pickerView.source = "btnStartMon"
                if btnStartMon.currentTitle == "Set"
                {
                    pickerView.currentDate = getDefaultDate()
                }
                else
                {
                    pickerView.currentDate = weeklyRecord.monShift.startTime
                }
                
            case btnEndMon:
                pickerView.source = "btnEndMon"
                if btnEndMon.currentTitle == "Set"
                {
                    pickerView.currentDate = getDefaultDate()
                }
                else
                {
                    pickerView.currentDate = weeklyRecord.monShift.endTime
            }
            
            case btnStartTue:
                pickerView.source = "btnStartTue"
                if btnStartTue.currentTitle == "Set"
                {
                    pickerView.currentDate = getDefaultDate()
                }
                else
                {
                    pickerView.currentDate = weeklyRecord.tueShift.startTime
            }
            
            case btnEndTue:
                pickerView.source = "btnEndTue"
                if btnEndTue.currentTitle == "Set"
                {
                    pickerView.currentDate = getDefaultDate()
                }
                else
                {
                    pickerView.currentDate = weeklyRecord.tueShift.endTime
            }

            case btnStartWed:
                pickerView.source = "btnStartWed"
                if btnStartWed.currentTitle == "Set"
                {
                    pickerView.currentDate = getDefaultDate()
                }
                else
                {
                    pickerView.currentDate = weeklyRecord.wedShift.startTime
            }
            
            case btnEndWed:
                pickerView.source = "btnEndWed"
                if btnEndWed.currentTitle == "Set"
                {
                    pickerView.currentDate = getDefaultDate()
                }
                else
                {
                    pickerView.currentDate = weeklyRecord.wedShift.endTime
            }

            case btnStartThu:
                pickerView.source = "btnStartThu"
                if btnStartThu.currentTitle == "Set"
                {
                    pickerView.currentDate = getDefaultDate()
                }
                else
                {
                    pickerView.currentDate = weeklyRecord.thuShift.startTime
            }
            
            case btnEndThu:
                pickerView.source = "btnEndThu"
                if btnEndThu.currentTitle == "Set"
                {
                    pickerView.currentDate = getDefaultDate()
                }
                else
                {
                    pickerView.currentDate = weeklyRecord.thuShift.endTime
            }

            case btnStartFri:
                pickerView.source = "btnStartFri"
                if btnStartFri.currentTitle == "Set"
                {
                    pickerView.currentDate = getDefaultDate()
                }
                else
                {
                    pickerView.currentDate = weeklyRecord.friShift.startTime
            }
            
            case btnEndFri:
                pickerView.source = "btnEndFri"
                if btnEndFri.currentTitle == "Set"
                {
                    pickerView.currentDate = getDefaultDate()
                }
                else
                {
                    pickerView.currentDate = weeklyRecord.friShift.endTime
            }

            case btnStartSat:
                pickerView.source = "btnStartSat"
                if btnStartSat.currentTitle == "Set"
                {
                    pickerView.currentDate = getDefaultDate()
                }
                else
                {
                    pickerView.currentDate = weeklyRecord.satShift.startTime
            }
            
            case btnEndSat:
                pickerView.source = "btnEndSat"
                if btnEndSat.currentTitle == "Set"
                {
                    pickerView.currentDate = getDefaultDate()
                }
                else
                {
                    pickerView.currentDate = weeklyRecord.satShift.endTime
            }

            case btnStartSun:
                pickerView.source = "btnStartSun"
                if btnStartSun.currentTitle == "Set"
                {
                    pickerView.currentDate = getDefaultDate()
                }
                else
                {
                    pickerView.currentDate = weeklyRecord.sunShift.startTime
            }
            
            case btnEndSun:
                pickerView.source = "btnEndSun"
                if btnEndSun.currentTitle == "Set"
                {
                    pickerView.currentDate = getDefaultDate()
                }
                else
                {
                    pickerView.currentDate = weeklyRecord.sunShift.endTime
            }

            default:
                    print("shiftListItem btnSelectTime got unexpected entry")
        }
        
        pickerView.delegate = sourceView
        pickerView.showTimes = true
        pickerView.showDates = false
        pickerView.minutesInterval = 5
        pickerView.display24Hour = true
        
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        mainView.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnShiftType(_ sender: UIButton)
    {
        displayList.removeAll()
        
        for myItem in (currentUser.currentTeam?.getDropDown(dropDownType: "Shift"))!
        {
            if myItem != eventShiftType
            {
                displayList.append(myItem)
            }
        }
        
        if displayList.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = sourceView
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            pickerView.source = "shiftType"
            
            pickerView.delegate = sourceView
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 300,height: 500)
            pickerView.currentValue = sender.currentTitle!
            mainView.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func txtDescription(_ sender: UITextField)
    {
        if weeklyRecord.sunShift == nil && weeklyRecord.sunShift == nil && weeklyRecord.sunShift == nil && weeklyRecord.sunShift == nil && weeklyRecord.sunShift == nil && weeklyRecord.sunShift == nil && weeklyRecord.sunShift == nil && weeklyRecord.sunShift == nil
        {
            // Do nothing
        }
        else
        {
            // Update the rows, because of the way I built the data model need to update each days entry
            
            if weeklyRecord.monShift != nil
            {
                weeklyRecord.monShift.shiftDescription = sender.text!
                weeklyRecord.monShift.save()
            }
            
            if weeklyRecord.tueShift != nil
            {
                weeklyRecord.tueShift.shiftDescription = sender.text!
                weeklyRecord.tueShift.save()
            }
            
            if weeklyRecord.wedShift != nil
            {
                weeklyRecord.wedShift.shiftDescription = sender.text!
                weeklyRecord.wedShift.save()
            }
            
            if weeklyRecord.thuShift != nil
            {
                weeklyRecord.thuShift.shiftDescription = sender.text!
                weeklyRecord.thuShift.save()
            }
            
            if weeklyRecord.friShift != nil
            {
                weeklyRecord.friShift.shiftDescription = sender.text!
                weeklyRecord.friShift.save()
            }
            
            if weeklyRecord.satShift != nil
            {
                weeklyRecord.satShift.shiftDescription = sender.text!
                weeklyRecord.satShift.save()
            }
            
            if weeklyRecord.sunShift != nil
            {
                weeklyRecord.sunShift.shiftDescription = sender.text!
                weeklyRecord.sunShift.save()
            }
        }
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if selectedItem >= 0
        {
            // We have a new object, with a selected item, so we can go ahead and create a new summary row
            switch source
            {
                case "shiftType":
                    var workingType: String = ""
                    
                    if selectedItem > 0
                    {
                        switch selectedItem
                        {
                            case 1:
                            workingType = calloutShiftType
                                
                            case 2:
                                workingType = overtimeShiftType
                                    
                            case 3:
                                workingType = regularShiftType
                                
                            case 4:
                                workingType = shiftShiftType
                                
                            default:
                                workingType = "Unknown"
                            
                        }
                        
                        // Update the rows, because of the way I built the data model need to update each days entry
                        
                        if weeklyRecord.monShift != nil
                        {
                            weeklyRecord.monShift.type = workingType
                            weeklyRecord.monShift.save()
                        }
                        
                        if weeklyRecord.tueShift != nil
                        {
                            weeklyRecord.tueShift.type = workingType
                            weeklyRecord.tueShift.save()
                        }
                        
                        if weeklyRecord.wedShift != nil
                        {
                            weeklyRecord.wedShift.type = workingType
                            weeklyRecord.wedShift.save()
                        }
                        
                        if weeklyRecord.thuShift != nil
                        {
                            weeklyRecord.thuShift.type = workingType
                            weeklyRecord.thuShift.save()
                        }
                        
                        if weeklyRecord.friShift != nil
                        {
                            weeklyRecord.friShift.type = workingType
                            weeklyRecord.friShift.save()
                        }
                        
                        if weeklyRecord.satShift != nil
                        {
                            weeklyRecord.satShift.type = workingType
                            weeklyRecord.satShift.save()
                        }
                        
                        if weeklyRecord.sunShift != nil
                        {
                            weeklyRecord.sunShift.type = workingType
                            weeklyRecord.sunShift.save()
                        }
                        
                        btnShiftType.setTitle(workingType, for: .normal)
                    }

            case "btnRateMon":
                
                    // For Rates, the last 2 rows are used to determin if should delete the shift
                    
                    if selectedItem > displayList.count - 2
                    {
                        if displayList[selectedItem] == "Delete Shift"
                        {
                            if weeklyRecord.monShift != nil
                            {
                                weeklyRecord.monShift.delete()
                                
                                weeklyRecord.monShift = nil
                                
                                btnRateMon.isHidden = true
                                btnPersonMon.isHidden = true
                                
                                btnStartMon.setTitle("00:00", for: .normal)
                                btnEndMon.setTitle("00:00", for: .normal)
                            }
                        }
                        
                        break
                    }

                    btnRateMon.setTitle(rateList.rates[selectedItem].rateName, for: .normal)
                
                    if weeklyRecord.monShift == nil
                    {
                        weeklyRecord.monShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -6), teamID: currentUser.currentTeam!.teamID)
                    }

                    weeklyRecord.monShift.rateID = rateList.rates[selectedItem].rateID
                    weeklyRecord.monShift.save()
                
                case "btnRateTue":
                    
                    // For Rates, the last 2 rows are used to determin if should delete the shift
                    
                    if selectedItem > displayList.count - 2
                    {
                        if displayList[selectedItem] == "Delete Shift"
                        {
                            if weeklyRecord.tueShift != nil
                            {
                                weeklyRecord.tueShift.delete()
                                
                                weeklyRecord.tueShift = nil
                                
                                btnRateTue.isHidden = true
                                btnPersonTue.isHidden = true
                                
                                btnStartTue.setTitle("00:00", for: .normal)
                                btnEndTue.setTitle("00:00", for: .normal)
                            }
                        }
                        
                        break
                    }
                    
                    btnRateTue.setTitle(rateList.rates[selectedItem].rateName, for: .normal)
                    
                    if weeklyRecord.tueShift == nil
                    {
                        weeklyRecord.tueShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -5), teamID: currentUser.currentTeam!.teamID)
                    }
                
                    weeklyRecord.tueShift.rateID = rateList.rates[selectedItem].rateID
                    weeklyRecord.tueShift.save()
                
                case "btnRateWed":
                    // For Rates, the last 2 rows are used to determin if should delete the shift
                    
                    if selectedItem > displayList.count - 2
                    {
                        if displayList[selectedItem] == "Delete Shift"
                        {
                            if weeklyRecord.wedShift != nil
                            {
                                weeklyRecord.wedShift.delete()
                                
                                weeklyRecord.wedShift = nil
                                
                                btnRateWed.isHidden = true
                                btnPersonWed.isHidden = true
                                
                                btnStartWed.setTitle("00:00", for: .normal)
                                btnEndWed.setTitle("00:00", for: .normal)
                            }
                        }
                        
                        break
                    }
                    
                    btnRateWed.setTitle(rateList.rates[selectedItem].rateName, for: .normal)
                    
                    if weeklyRecord.wedShift == nil
                    {
                        weeklyRecord.wedShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -4), teamID: currentUser.currentTeam!.teamID)
                    }
                    
                    weeklyRecord.wedShift.rateID = rateList.rates[selectedItem].rateID
                    weeklyRecord.wedShift.save()
                
                case "btnRateThu":
                    // For Rates, the last 2 rows are used to determin if should delete the shift
                    
                    if selectedItem > displayList.count - 2
                    {
                        if displayList[selectedItem] == "Delete Shift"
                        {
                            if weeklyRecord.thuShift != nil
                            {
                                weeklyRecord.thuShift.delete()
                                
                                weeklyRecord.thuShift = nil
                                
                                btnRateThu.isHidden = true
                                btnPersonThu.isHidden = true
                                
                                btnStartThu.setTitle("00:00", for: .normal)
                                btnEndThu.setTitle("00:00", for: .normal)
                            }
                        }
                        
                        break
                    }
                    
                    btnRateThu.setTitle(rateList.rates[selectedItem].rateName, for: .normal)
                    
                    if weeklyRecord.thuShift == nil
                    {
                        weeklyRecord.thuShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -3), teamID: currentUser.currentTeam!.teamID)
                    }
                    
                    weeklyRecord.thuShift.rateID = rateList.rates[selectedItem].rateID
                    weeklyRecord.thuShift.save()
                
                case "btnRateFri":
                    // For Rates, the last 2 rows are used to determin if should delete the shift
                    
                    if selectedItem > displayList.count - 2
                    {
                        if displayList[selectedItem] == "Delete Shift"
                        {
                            if weeklyRecord.friShift != nil
                            {
                                weeklyRecord.friShift.delete()
                                
                                weeklyRecord.friShift = nil
                                
                                btnRateFri.isHidden = true
                                btnPersonFri.isHidden = true
                                
                                btnStartFri.setTitle("00:00", for: .normal)
                                btnEndFri.setTitle("00:00", for: .normal)
                            }
                        }
                        
                        break
                    }
                    
                    btnRateFri.setTitle(rateList.rates[selectedItem].rateName, for: .normal)
                    
                    if weeklyRecord.friShift == nil
                    {
                        weeklyRecord.friShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -2), teamID: currentUser.currentTeam!.teamID)
                    }

                    weeklyRecord.friShift.rateID = rateList.rates[selectedItem].rateID
                    weeklyRecord.friShift.save()
                
                case "btnRateSat":
                    // For Rates, the last 2 rows are used to determin if should delete the shift
                    
                    if selectedItem > displayList.count - 2
                    {
                        if displayList[selectedItem] == "Delete Shift"
                        {
                            if weeklyRecord.satShift != nil
                            {
                                weeklyRecord.satShift.delete()
                                
                                weeklyRecord.satShift = nil
                                
                                btnRateSat.isHidden = true
                                btnPersonSat.isHidden = true
                                
                                btnStartSat.setTitle("00:00", for: .normal)
                                btnEndSat.setTitle("00:00", for: .normal)
                            }
                        }
                        
                        break
                    }
                    
                    btnRateSat.setTitle(rateList.rates[selectedItem].rateName, for: .normal)
                    
                    if weeklyRecord.satShift == nil
                    {
                        weeklyRecord.satShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -1), teamID: currentUser.currentTeam!.teamID)
                    }
                    
                    weeklyRecord.satShift.rateID = rateList.rates[selectedItem].rateID
                    weeklyRecord.satShift.save()
                
                case "btnRateSun":
                    // For Rates, the last 2 rows are used to determin if should delete the shift
                    
                    if selectedItem > displayList.count - 2
                    {
                        if displayList[selectedItem] == "Delete Shift"
                        {
                            if weeklyRecord.sunShift != nil
                            {
                                weeklyRecord.sunShift.delete()
                                
                                weeklyRecord.sunShift = nil
                                
                                btnRateSun.isHidden = true
                                btnPersonSun.isHidden = true
                                
                                btnStartSun.setTitle("00:00", for: .normal)
                                btnEndSun.setTitle("00:00", for: .normal)
                            }
                        }
                        
                        break
                    }
                    
                    btnRateSun.setTitle(rateList.rates[selectedItem].rateName, for: .normal)
                    
                    if weeklyRecord.sunShift == nil
                    {
                        weeklyRecord.sunShift = createShiftEntry(workDate: weeklyRecord.WEDate, teamID: currentUser.currentTeam!.teamID)
                    }
                    
                    weeklyRecord.sunShift.rateID = rateList.rates[selectedItem].rateID
                    weeklyRecord.sunShift.save()
                
                case "btnPersonMon":
                    btnPersonMon.setTitle(peopleList.people[selectedItem].name, for: .normal)
                  
                    if weeklyRecord.monShift == nil
                    {
                        weeklyRecord.monShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -6), teamID: currentUser.currentTeam!.teamID)
                    }
                    
                    weeklyRecord.monShift.personID = peopleList.people[selectedItem].personID
                    weeklyRecord.monShift.save()
                
                case "btnPersonTue":
                    btnPersonTue.setTitle(peopleList.people[selectedItem].name, for: .normal)
                    
                    if weeklyRecord.tueShift == nil
                    {
                        weeklyRecord.tueShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -5), teamID: currentUser.currentTeam!.teamID)
                    }
                    
                    weeklyRecord.tueShift.personID = peopleList.people[selectedItem].personID
                    weeklyRecord.tueShift.save()
                
                case "btnPersonWed":
                    btnPersonWed.setTitle(peopleList.people[selectedItem].name, for: .normal)
                    
                    if weeklyRecord.wedShift == nil
                    {
                        weeklyRecord.wedShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -4), teamID: currentUser.currentTeam!.teamID)
                    }
                    
                    weeklyRecord.wedShift.personID = peopleList.people[selectedItem].personID
                    weeklyRecord.wedShift.save()
                
                case "btnPersonThu":
                    btnPersonThu.setTitle(peopleList.people[selectedItem].name, for: .normal)
                    
                    if weeklyRecord.thuShift == nil
                    {
                        weeklyRecord.thuShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -3), teamID: currentUser.currentTeam!.teamID)
                    }
                    
                    weeklyRecord.thuShift.personID = peopleList.people[selectedItem].personID
                    weeklyRecord.thuShift.save()
                
                case "btnPersonFri":
                    btnPersonFri.setTitle(peopleList.people[selectedItem].name, for: .normal)
                    
                    if weeklyRecord.friShift == nil
                    {
                        weeklyRecord.friShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -2), teamID: currentUser.currentTeam!.teamID)
                    }
                    
                    weeklyRecord.friShift.personID = peopleList.people[selectedItem].personID
                    weeklyRecord.friShift.save()
                
                case "btnPersonSat":
                    btnPersonSat.setTitle(peopleList.people[selectedItem].name, for: .normal)
                    
                    if weeklyRecord.satShift == nil
                    {
                        weeklyRecord.satShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -1), teamID: currentUser.currentTeam!.teamID)
                    }
                    
                    weeklyRecord.satShift.personID = peopleList.people[selectedItem].personID
                    weeklyRecord.satShift.save()
                
                case "btnPersonSun":
                    btnPersonSun.setTitle(peopleList.people[selectedItem].name, for: .normal)
                    
                    if weeklyRecord.sunShift == nil
                    {
                        weeklyRecord.sunShift = createShiftEntry(workDate: weeklyRecord.WEDate, teamID: currentUser.currentTeam!.teamID)
                    }
                    
                    weeklyRecord.sunShift.personID = peopleList.people[selectedItem].personID
                    weeklyRecord.sunShift.save()
                
                default:
                    print("shiftListItem myPickerDidFinish-Int got unexpected entry \(source)")
            }
        }
    }
    
    func myPickerDidFinish(_ source: String, selectedDate:Date)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        switch source
        {
            case "btnStartMon":
                btnStartMon.setTitle(dateFormatter.string(from: selectedDate), for: .normal)
                
                if weeklyRecord.monShift == nil
                {
                    weeklyRecord.monShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -6), teamID: currentUser.currentTeam!.teamID)
                    btnRateMon.isHidden = false
                    btnPersonMon.isHidden = false
                }
                
                weeklyRecord.monShift.startTime = selectedDate
                weeklyRecord.monShift.save()
            
            case "btnEndMon":
                btnEndMon.setTitle(dateFormatter.string(from: selectedDate), for: .normal)

                if weeklyRecord.monShift == nil
                {
                    weeklyRecord.monShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -6), teamID: currentUser.currentTeam!.teamID)
                    btnRateMon.isHidden = false
                    btnPersonMon.isHidden = false
                }
                
                weeklyRecord.monShift.endTime = selectedDate
                weeklyRecord.monShift.save()


            case "btnStartTue":
                btnStartTue.setTitle(dateFormatter.string(from: selectedDate), for: .normal)

                if weeklyRecord.tueShift == nil
                {
                    weeklyRecord.tueShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -5), teamID: currentUser.currentTeam!.teamID)
                    btnRateTue.isHidden = false
                    btnPersonTue.isHidden = false
                }
                
                weeklyRecord.tueShift.startTime = selectedDate
                weeklyRecord.tueShift.save()

            case "btnEndTue":
                btnEndTue.setTitle(dateFormatter.string(from: selectedDate), for: .normal)

                if weeklyRecord.tueShift == nil
                {
                    weeklyRecord.tueShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -5), teamID: currentUser.currentTeam!.teamID)
                    btnRateTue.isHidden = false
                    btnPersonTue.isHidden = false
                }
                
                weeklyRecord.tueShift.endTime = selectedDate
                weeklyRecord.tueShift.save()

            case "btnStartWed":
                btnStartWed.setTitle(dateFormatter.string(from: selectedDate), for: .normal)

                if weeklyRecord.wedShift == nil
                {
                    weeklyRecord.wedShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -4), teamID: currentUser.currentTeam!.teamID)
                    btnRateWed.isHidden = false
                    btnPersonWed.isHidden = false
                }
                
                weeklyRecord.wedShift.startTime = selectedDate
                weeklyRecord.wedShift.save()

            case "btnEndWed":
                btnEndWed.setTitle(dateFormatter.string(from: selectedDate), for: .normal)

                if weeklyRecord.wedShift == nil
                {
                    weeklyRecord.wedShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -4), teamID: currentUser.currentTeam!.teamID)
                    btnRateWed.isHidden = false
                    btnPersonWed.isHidden = false
                }
                
                weeklyRecord.wedShift.endTime = selectedDate
                weeklyRecord.wedShift.save()

            case "btnStartThu":
                btnStartThu.setTitle(dateFormatter.string(from: selectedDate), for: .normal)

                if weeklyRecord.thuShift == nil
                {
                    weeklyRecord.thuShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -3), teamID: currentUser.currentTeam!.teamID)
                    btnRateThu.isHidden = false
                    btnPersonThu.isHidden = false
                }
                
                weeklyRecord.thuShift.startTime = selectedDate
                weeklyRecord.thuShift.save()

            case "btnEndThu":
                btnEndThu.setTitle(dateFormatter.string(from: selectedDate), for: .normal)

                if weeklyRecord.thuShift == nil
                {
                    weeklyRecord.thuShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -3), teamID: currentUser.currentTeam!.teamID)
                    btnRateThu.isHidden = false
                    btnPersonThu.isHidden = false
                }
                
                weeklyRecord.thuShift.endTime = selectedDate
                weeklyRecord.thuShift.save()

            case "btnStartFri":
                btnStartFri.setTitle(dateFormatter.string(from: selectedDate), for: .normal)

                if weeklyRecord.friShift == nil
                {
                    weeklyRecord.friShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -2), teamID: currentUser.currentTeam!.teamID)
                    btnRateFri.isHidden = false
                    btnPersonFri.isHidden = false
                }
                
                weeklyRecord.friShift.startTime = selectedDate
                weeklyRecord.friShift.save()

            case "btnEndFri":
                btnEndFri.setTitle(dateFormatter.string(from: selectedDate), for: .normal)

                if weeklyRecord.friShift == nil
                {
                    weeklyRecord.friShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -2), teamID: currentUser.currentTeam!.teamID)
                    btnRateFri.isHidden = false
                    btnPersonFri.isHidden = false
                }
                
                weeklyRecord.friShift.endTime = selectedDate
                weeklyRecord.friShift.save()

            case "btnStartSat":
                btnStartSat.setTitle(dateFormatter.string(from: selectedDate), for: .normal)

                if weeklyRecord.satShift == nil
                {
                    weeklyRecord.satShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -1), teamID: currentUser.currentTeam!.teamID)
                    btnRateSat.isHidden = false
                    btnPersonSat.isHidden = false
                }
                
                weeklyRecord.satShift.startTime = selectedDate
                weeklyRecord.satShift.save()

            case "btnEndSat":
                btnEndSat.setTitle(dateFormatter.string(from: selectedDate), for: .normal)

                if weeklyRecord.satShift == nil
                {
                    weeklyRecord.satShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -1), teamID: currentUser.currentTeam!.teamID)
                    btnRateSat.isHidden = false
                    btnPersonSat.isHidden = false
                }
                
                weeklyRecord.satShift.endTime = selectedDate
                weeklyRecord.satShift.save()

            case "btnStartSun":
                btnStartSun.setTitle(dateFormatter.string(from: selectedDate), for: .normal)

                if weeklyRecord.sunShift == nil
                {
                    weeklyRecord.sunShift = createShiftEntry(workDate: weeklyRecord.WEDate, teamID: currentUser.currentTeam!.teamID)
                    btnRateSun.isHidden = false
                    btnPersonSun.isHidden = false
                }
                
                weeklyRecord.sunShift.startTime = selectedDate
                weeklyRecord.sunShift.save()

            case "btnEndSun":
                btnEndSun.setTitle(dateFormatter.string(from: selectedDate), for: .normal)

                if weeklyRecord.sunShift == nil
                {
                    weeklyRecord.sunShift = createShiftEntry(workDate: weeklyRecord.WEDate, teamID: currentUser.currentTeam!.teamID)
                    btnRateSun.isHidden = false
                    btnPersonSun.isHidden = false
                }
                
                weeklyRecord.sunShift.endTime = selectedDate
                weeklyRecord.sunShift.save()

            default:
                print("shiftListItem myPickerDidFinish-Date got unexpected entry \(source)")
        }
    }
    
    private func createShiftEntry(workDate: Date, teamID: Int) -> shift
    {
        if shiftLineID == nil
        {
            // Get the ntex shiftlineID
            
            shiftLineID = myDatabaseConnection.getNextID("shiftLineID", teamID: teamID)
        }
        
        let newShift = shift(projectID: weeklyRecord.projectID, workDate: workDate, weekEndDate: weeklyRecord.WEDate, teamID: currentUser.currentTeam!.teamID, shiftLineID: shiftLineID, type: shiftShiftType)
        
        newShift.shiftDescription = txtDescription.text!
        
        return newShift
    }
}

class shiftHeaderItem: UITableViewCell
{
    @IBOutlet weak var lblSun: UILabel!
    @IBOutlet weak var lblMon: UILabel!
    @IBOutlet weak var lblTue: UILabel!
    @IBOutlet weak var lblWed: UILabel!
    @IBOutlet weak var lblThu: UILabel!
    @IBOutlet weak var lblFri: UILabel!
    @IBOutlet weak var lblSat: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

