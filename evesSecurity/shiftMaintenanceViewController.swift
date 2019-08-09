//
//  shiftMaintenanceViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 21/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

public class shiftMaintenanceViewController: UIViewController, MyPickerDelegate, UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var lblWEDate: UILabel!
    @IBOutlet weak var lblWETitle: UILabel!
    @IBOutlet weak var tblShifts: UITableView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnCreateShift: UIButton!
    @IBOutlet weak var btnPreviousWeek: UIButton!
    @IBOutlet weak var btnNextWeek: UIButton!
    @IBOutlet weak var btnShare: UIBarButtonItem!

   // public var communicationDelegate: myCommunicationDelegate?
    public var delegate: mainScreenProtocol!
    
    fileprivate var peopleList: people!
    fileprivate var shiftList: [mergedShiftList] = Array()
    public var currentWeekEndingDate: Date!
    fileprivate var contractList: projects!
    fileprivate var displayList: [String] = Array()
    
    override public func viewDidLoad()
    {
        if currentWeekEndingDate == nil
        {
            currentWeekEndingDate = Date().getWeekEndingDate.startOfDay
        }
        peopleList = people(teamID: currentUser.currentTeam!.teamID, canRoster: true)

        refreshScreen()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate.loadShifts()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return shiftList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
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
        
        displayTableRowDay(btnTimes: cell.btnSetTimesSun, btnPer: cell.btnPickPersonSun, btnCreate: cell.btnCreateShiftSun, sourceShift: shiftList[indexPath.row].sunShift, dateAdjustment: 0)
        displayTableRowDay(btnTimes: cell.btnSetTimesMon, btnPer: cell.btnPickPersonMon,  btnCreate: cell.btnCreateShiftMon, sourceShift: shiftList[indexPath.row].monShift, dateAdjustment: -6)
        displayTableRowDay(btnTimes: cell.btnSetTimesTue, btnPer: cell.btnPickPersonTue,  btnCreate: cell.btnCreateShiftTue, sourceShift: shiftList[indexPath.row].tueShift, dateAdjustment: -5)
        displayTableRowDay(btnTimes: cell.btnSetTimesWed, btnPer: cell.btnPickPersonWed,  btnCreate: cell.btnCreateShiftWed, sourceShift: shiftList[indexPath.row].wedShift, dateAdjustment: -4)
        displayTableRowDay(btnTimes: cell.btnSetTimesThu, btnPer: cell.btnPickPersonThu,  btnCreate: cell.btnCreateShiftThu, sourceShift: shiftList[indexPath.row].thuShift, dateAdjustment: -3)
        displayTableRowDay(btnTimes: cell.btnSetTimesFri, btnPer: cell.btnPickPersonFri,  btnCreate: cell.btnCreateShiftFri, sourceShift: shiftList[indexPath.row].friShift, dateAdjustment: -2)
        displayTableRowDay(btnTimes: cell.btnSetTimesSat, btnPer: cell.btnPickPersonSat,  btnCreate: cell.btnCreateShiftSat, sourceShift: shiftList[indexPath.row].satShift, dateAdjustment: -1)
 
        cell.txtDescription.isHidden = true
        cell.btnShiftType.isHidden = true
        return cell
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
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
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 35
    }
    
    private func displayTableRowDay(btnTimes: UIButton, btnPer: UIButton, btnCreate: UIButton, sourceShift: shift?, dateAdjustment: Int)
    {
        var timeString: String = ""
        
        if sourceShift != nil
        {
            btnCreate.isHidden = true
            btnTimes.isHidden = false
            btnPer.isHidden = false
            
            btnTimes.setTitleColor(darkGreenColour, for: .normal)
            btnPer.setTitleColor(darkGreenColour, for: .normal)

            if sourceShift?.startTimeString == ""
            {
                timeString = "Start"
            }
            else
            {
                timeString = "\(sourceShift?.startTimeString ?? "Start")"
                
                if sourceShift?.startTimeString == sourceShift?.endTimeString
                {
                    btnTimes.setTitleColor(.red, for: .normal)
                    btnPer.setTitleColor(.red, for: .normal)
                }
            }
            
            if sourceShift?.endTimeString == ""
            {
                timeString += "-End"
            }
            else
            {
                timeString += "-\(sourceShift?.endTimeString ?? "End")"
            }
            
            if timeString == ""
            {
                btnTimes.setTitle("Set Times", for: .normal)
            }
            else
            {
                btnTimes.setTitle(timeString, for: .normal)
            }
            
            if sourceShift?.rateID == 0
            {
                btnTimes.setTitleColor(.red, for: .normal)
                btnPer.setTitleColor(.red, for: .normal)
            }
            else
            {
                if sourceShift?.rateDescription == ""
                {
                    btnTimes.setTitleColor(.red, for: .normal)
                    btnPer.setTitleColor(.red, for: .normal)
                }
                else
                {
                    let tempRates = rates(teamID: (currentUser.currentTeam?.teamID)!)
                    
                    if !tempRates.checkRate((sourceShift?.rateID)!)

                    {
                        btnTimes.setTitleColor(.red, for: .normal)
                        btnPer.setTitleColor(.red, for: .normal)
                    }
                }
            }
            
            if sourceShift?.personID == 0
            {
                btnTimes.setTitleColor(.red, for: .normal)
                btnPer.setTitleColor(.red, for: .normal)
                
                btnPer.setTitle("Pick Person", for: .normal)
            }
            else
            {
                btnPer.setTitle(sourceShift?.personName, for: .normal)
            }
            
            if sourceShift?.personInvoiceNumber != 0
            {
                btnPer.isEnabled = false
            }
            else
            {
                btnPer.isEnabled = true
            }
            
            if sourceShift?.personInvoiceNumber != 0 || sourceShift?.clientInvoiceNumber != 0
            {
                btnTimes.setTitleColor(.gray, for: .normal)
                btnPer.setTitleColor(.gray, for: .normal)
                btnPer.isEnabled = false
                btnTimes.isEnabled = false
            }
        }
        else
        {
            btnCreate.isHidden = false
            btnPer.isHidden = true
            btnTimes.isHidden = true
        }
    }
    
//    @IBAction func btnBack(_ sender: UIBarButtonItem)
//    {
//        usleep(500)
//        currentUser.currentTeam?.shifts = nil
//
//        DispatchQueue.global().async
//        {
//            currentUser.currentTeam?.shifts = myCloudDB.getShifts(teamID: (currentUser.currentTeam?.teamID)!)
//        }
//
//        communicationDelegate?.refreshScreen!()
//        self.dismiss(animated: true, completion: nil)
//    }
    
    @IBAction func btnAdd(_ sender: UIButton)
    {
        contractList = projects(teamID: currentUser.currentTeam!.teamID, includeEvents: false, isActive: true)
        
        displayList.removeAll()
        
        for myItem in contractList.projectList
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
        
        for myItem in previousShifts.shifts
        {
            var newShift: shift!

            newShift = shift(projectID: myItem.projectID, workDate: myItem.workDate.add(.day, amount: 7), weekEndDate: currentWeekEndingDate, teamID: currentUser.currentTeam!.teamID, shiftLineID: myItem.shiftLineID, type: myItem.type)
            
            newShift.shiftDescription = myItem.shiftDescription
            newShift.startTime = myItem.startTime
            newShift.endTime = myItem.endTime
            newShift.rateID = myItem.rateID
            newShift.save()
        }
        
        refreshScreen()
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

    public func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "project"
        {
            if selectedItem >= 0
            {
                // We have a new object, with a selected item, so we can go ahead and create a new summary row
                
                // create a dummy shift entry so we can get the sort order correct
                
                // Get the ntex shiftlineID
                    
                let lineID = myCloudDB.getNextID("shiftLineID", teamID: contractList.projectList[selectedItem].teamID)
                
                let workDate = currentWeekEndingDate.add(.day, amount: -1)
                
                let newShift = shift(projectID: contractList.projectList[selectedItem].projectID, workDate: workDate, weekEndDate: currentWeekEndingDate, teamID: currentUser.currentTeam!.teamID, shiftLineID: lineID, type: shiftShiftType)
                
                newShift.startTime = getDefaultDate()
                newShift.endTime = getDefaultDate()
                newShift.save()
                
                shiftList = shifts(teamID: currentUser.currentTeam!.teamID, WEDate: currentWeekEndingDate, type: shiftShiftType).weeklyShifts
                
                tblShifts.reloadData()
                
                if shiftList.count > 0
                {
                    let oldLastCellPath = IndexPath(row: shiftList.count - 1, section: 0)
                    tblShifts.scrollToRow(at: oldLastCellPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    public func refreshScreen()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        lblWEDate.text = dateFormatter.string(from: currentWeekEndingDate)
        
        shiftList = shifts(teamID: currentUser.currentTeam!.teamID, WEDate: currentWeekEndingDate, type: shiftShiftType).weeklyShifts
        
        if shiftList.count == 0
        {
            lblWETitle.isHidden = true
            btnCreateShift.isHidden = false
           // btnAdd.isHidden = true
            btnAdd.isHidden = false
        }
        else
        {
            lblWETitle.isHidden = false
            btnCreateShift.isHidden = true
            btnAdd.isHidden = false
        }
        
        tblShifts.reloadData()
    }
    
    public func shiftDeleted(projectID: Int64, shiftLineID: Int64, weekEndDate: Date, workDate: Date, teamID: Int64)
    {
        var rowCount: Int = 0
        
        for item in (currentUser.currentTeam?.ShiftList)!
        {
            if item.projectID == projectID && item.shiftLineID == shiftLineID && item.weekEndDate == weekEndDate && item.workDate == workDate && item.teamID == teamID
            {
                currentUser.currentTeam?.removeShift(rowCount)
                break
            }
            rowCount += 1
        }
        refreshScreen()
    }
}

class shiftListItem: UITableViewCell, UIPopoverPresentationControllerDelegate, MyPickerDelegate
{
    @IBOutlet weak var lblContract: UILabel!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var btnShiftType: UIButton!
    
    @IBOutlet weak var btnSetTimesMon: UIButton!
    @IBOutlet weak var btnSetTimesTue: UIButton!
    @IBOutlet weak var btnSetTimesWed: UIButton!
    @IBOutlet weak var btnSetTimesThu: UIButton!
    @IBOutlet weak var btnSetTimesFri: UIButton!
    @IBOutlet weak var btnSetTimesSat: UIButton!
    @IBOutlet weak var btnSetTimesSun: UIButton!
    
    @IBOutlet weak var btnCreateShiftMon: UIButton!
    @IBOutlet weak var btnCreateShiftTue: UIButton!
    @IBOutlet weak var btnCreateShiftWed: UIButton!
    @IBOutlet weak var btnCreateShiftThu: UIButton!
    @IBOutlet weak var btnCreateShiftFri: UIButton!
    @IBOutlet weak var btnCreateShiftSat: UIButton!
    @IBOutlet weak var btnCreateShiftSun: UIButton!
    
    @IBOutlet weak var btnPickPersonMon: UIButton!
    @IBOutlet weak var btnPickPersonTue: UIButton!
    @IBOutlet weak var btnPickPersonWed: UIButton!
    @IBOutlet weak var btnPickPersonThu: UIButton!
    @IBOutlet weak var btnPickPersonFri: UIButton!
    @IBOutlet weak var btnPickPersonSat: UIButton!
    @IBOutlet weak var btnPickPersonSun: UIButton!
    
    var peopleList: people!
    var rateList: rates!
    var weeklyRecord: mergedShiftList!
    var shiftLineID: Int64!
    var projectID: Int64!
    
    var sourceView: shiftListItem!
    var mainView: shiftMaintenanceViewController!
    
    fileprivate var displayList: [String] = Array()
    
    @IBAction func updateShift(_ sender: UIButton)
    {
        let pickerView = shiftsStoryboard.instantiateViewController(withIdentifier: "shiftDetails") as! shiftDetailsView
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = sourceView
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.delegate = mainView
        pickerView.peopleList = peopleList
        
        switch sender
        {
            case btnSetTimesMon, btnPickPersonMon:
                pickerView.currentShift = weeklyRecord.monShift

            case btnSetTimesTue, btnPickPersonTue:
                pickerView.currentShift = weeklyRecord.tueShift

            case btnSetTimesWed, btnPickPersonWed:
                pickerView.currentShift = weeklyRecord.wedShift

            case btnSetTimesThu, btnPickPersonThu:
                pickerView.currentShift = weeklyRecord.thuShift

            case btnSetTimesFri, btnPickPersonFri:
                pickerView.currentShift = weeklyRecord.friShift

            case btnSetTimesSat, btnPickPersonSat:
                pickerView.currentShift = weeklyRecord.satShift
            
            case btnSetTimesSun, btnPickPersonSun:
                pickerView.currentShift = weeklyRecord.sunShift
            
            default:
                print("shiftListItem - updateShift - Unknown Sender")
        }
        
        pickerView.preferredContentSize = CGSize(width: 500,height: 800)
        
        if pickerView.currentShift.clientInvoiceNumber == 0 && pickerView.currentShift.personInvoiceNumber == 0
        {
            mainView.present(pickerView, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func createShift(_ sender: UIButton)
    {
        let pickerView = shiftsStoryboard.instantiateViewController(withIdentifier: "shiftDetails") as! shiftDetailsView
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = sourceView
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.delegate = mainView
        
        switch sender
        {
            case btnCreateShiftMon:
                if weeklyRecord.monShift == nil
                {
                    weeklyRecord.monShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -6), teamID: currentUser.currentTeam!.teamID)
                    weeklyRecord.monShift.startTime = getDefaultDate()
                    weeklyRecord.monShift.endTime = getDefaultDate()
                }
                pickerView.currentShift = weeklyRecord.monShift
            
            case btnCreateShiftTue:
                if weeklyRecord.tueShift == nil
                {
                    weeklyRecord.tueShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -5), teamID: currentUser.currentTeam!.teamID)
                    weeklyRecord.tueShift.startTime = getDefaultDate()
                    weeklyRecord.tueShift.endTime = getDefaultDate()
                }
                pickerView.currentShift = weeklyRecord.tueShift
            
            case btnCreateShiftWed:
                if weeklyRecord.wedShift == nil
                {
                    weeklyRecord.wedShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -4), teamID: currentUser.currentTeam!.teamID)
                    weeklyRecord.wedShift.startTime = getDefaultDate()
                    weeklyRecord.wedShift.endTime = getDefaultDate()
                }
                pickerView.currentShift = weeklyRecord.wedShift
            
            case btnCreateShiftThu:
                if weeklyRecord.thuShift == nil
                {
                    weeklyRecord.thuShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -3), teamID: currentUser.currentTeam!.teamID)
                    weeklyRecord.thuShift.startTime = getDefaultDate()
                    weeklyRecord.thuShift.endTime = getDefaultDate()
                }
                pickerView.currentShift = weeklyRecord.thuShift
            
            case btnCreateShiftFri:
                if weeklyRecord.friShift == nil
                {
                    weeklyRecord.friShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -2), teamID: currentUser.currentTeam!.teamID)
                    weeklyRecord.friShift.startTime = getDefaultDate()
                    weeklyRecord.friShift.endTime = getDefaultDate()
                }
                pickerView.currentShift = weeklyRecord.friShift
            
            case btnCreateShiftSat:
                if weeklyRecord.satShift == nil
                {
                    weeklyRecord.satShift = createShiftEntry(workDate: weeklyRecord.WEDate.add(.day, amount: -1), teamID: currentUser.currentTeam!.teamID)
                    weeklyRecord.satShift.startTime = getDefaultDate()
                    weeklyRecord.satShift.endTime = getDefaultDate()
                }
                pickerView.currentShift = weeklyRecord.satShift
            
            case btnCreateShiftSun:
                if weeklyRecord.sunShift == nil
                {
                    weeklyRecord.sunShift = createShiftEntry(workDate: weeklyRecord.WEDate, teamID: currentUser.currentTeam!.teamID)
                    weeklyRecord.sunShift.startTime = getDefaultDate()
                    weeklyRecord.sunShift.endTime = getDefaultDate()
                }
                pickerView.currentShift = weeklyRecord.sunShift
            
            default:
                print("shiftListItem - createShift - Unknown Sender")
        }
        
        pickerView.peopleList = peopleList
        pickerView.preferredContentSize = CGSize(width: 500,height: 800)
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
    
    private func createShiftEntry(workDate: Date, teamID: Int64) -> shift
    {
        if shiftLineID == nil
        {
            // Get the ntex shiftlineID
            
            shiftLineID = myCloudDB.getNextID("shiftLineID", teamID: teamID)
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

