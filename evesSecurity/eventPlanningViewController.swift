//
//  eventPlanningViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 23/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

public protocol updateProgressBarProtocol
{
    func updatebar()
}

public class eventPlanningViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, myCommunicationDelegate, MyPickerDelegate, UIPopoverPresentationControllerDelegate, updateProgressBarProtocol
{
    @IBOutlet weak var btnTemplate: UIButton!
    @IBOutlet weak var btnCreatePlan: UIButton!
    @IBOutlet weak var btnMaintainTemplates: UIButton!
    @IBOutlet weak var tblRoles: UITableView!
    @IBOutlet weak var lblAddToRole: UILabel!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var btnAddRole: UIButton!
    @IBOutlet weak var lblEventTemplate: UILabel!
    @IBOutlet weak var lblContractName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var lblRoleHead: UILabel!
    @IBOutlet weak var lblPersonHead: UILabel!
    @IBOutlet weak var lblRateHead: UILabel!
    @IBOutlet weak var lblDateHead: UILabel!
    @IBOutlet weak var lblStarHead: UILabel!
    @IBOutlet weak var lblEndHead: UILabel!
    @IBOutlet weak var btnShare: UIBarButtonItem!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var progressbar: UIProgressView!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnResetPlan: UIButton!
    
  //  public var communicationDelegate: myCommunicationDelegate?
  //  public var delegate: mainScreenProtocol!
    
    public var currentEvent: project!
    fileprivate var displayList: [String] = Array()
    fileprivate var currentTemplate: eventTemplateHead!
    fileprivate var templateList: eventTemplateHeads!
    fileprivate var eventDays: [Date] = Array()
    fileprivate var newRoleDate: Date!
    fileprivate var peopleList: people!
    fileprivate var rateList: rates!
    fileprivate var shiftList: [shift] = Array()
    fileprivate var barProgress: Int = 0
    fileprivate var maxBar: Int = 0
    
    override public func viewDidLoad()
    {
        peopleList = people(teamID: currentUser.currentTeam!.teamID, isActive: true)
        btnStatus.setTitle("Select", for: .normal)
        
        progressbar.isHidden = true
        if currentEvent != nil
        {
            eventDays.removeAll()
            
            // Here we are going to build up the list of possible days
            
            if currentEvent.projectStartDate == currentEvent.projectEndDate
            {
                eventDays.append(currentEvent.projectStartDate.startOfDay)
            }
            else
            {
                var tempDate = currentEvent.projectStartDate
                
                while tempDate <= currentEvent.projectEndDate
                {
                    eventDays.append(tempDate.startOfDay)
                    tempDate = tempDate.add(.day, amount: 1)
                }
                
            }
            
            btnDate.setTitle(currentEvent.projectStartDate.formatDateToString, for: .normal)
            if currentEvent.projectStatus != ""
            {
                btnStatus.setTitle(currentEvent.projectStatus, for: .normal)
            }
            else
            {
                btnStatus.setTitle("Select", for: .normal)
            }
            newRoleDate = currentEvent.projectStartDate.startOfDay
            
            refreshScreen()
        }
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if mainDelegate != nil
        {
            mainDelegate.loadShifts()
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
            case tblRoles:
                return shiftList.count
                
            default:
                return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblRoles:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellEvent", for: indexPath) as! eventRoleItem
                
                cell.lblRole.text = shiftList[indexPath.row].shiftDescription
                cell.lblDate.text = shiftList[indexPath.row].workDateShortString
                cell.btnRate.setTitle(shiftList[indexPath.row].rateDescription, for: .normal)
                cell.btnPerson.setTitle(shiftList[indexPath.row].personName, for: .normal)
                cell.btnStart.setTitle(shiftList[indexPath.row].startTimeString, for: .normal)
                cell.btnEnd.setTitle(shiftList[indexPath.row].endTimeString, for: .normal)
                
                cell.mainView = self
                cell.sourceView = cell
                cell.shiftRecord = shiftList[indexPath.row]
                cell.peopleList = peopleList
                cell.rateList = rateList
                
                if shiftList[indexPath.row].personInvoiceNumber != 0 || shiftList[indexPath.row].clientInvoiceNumber != 0
                {
                    cell.btnRate.setTitleColor(.gray, for: .normal)
                    cell.btnPerson.setTitleColor(.gray, for: .normal)
                    cell.btnStart.setTitleColor(.gray, for: .normal)
                    cell.btnEnd.setTitleColor(.gray, for: .normal)
                    cell.btnRate.isEnabled = false
                    cell.btnPerson.isEnabled = false
                    cell.btnStart.isEnabled = false
                    cell.btnEnd.isEnabled = false
                }
                
                return cell
                
            default:
                return UITableViewCell()
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView
        {
            case tblRoles:
                let _ = 1
            
            default:
                let _ = 1
        }
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        if tableView == tblRoles
        {
            return UITableViewCell.EditingStyle.delete
        }
        return UITableViewCell.EditingStyle.none
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if tableView == tblRoles
        {
            if editingStyle == .delete
            {
                shiftList[indexPath.row].delete()
                currentEvent.staff!.remove(indexPath.row)
                
                refreshScreen()
            }
        }
    }
    
//    @IBAction func btnBack(_ sender: UIBarButtonItem)
//    {
//        currentUser.currentTeam?.shifts = nil
//        
//        DispatchQueue.global().async
//        {
//            currentUser.currentTeam?.shifts = myCloudDB.getShifts(teamID: (currentUser.currentTeam?.teamID)!)
//        }
//        
//        currentUser.currentTeam?.eventTemplates = nil
//        
//        communicationDelegate?.refreshScreen!()
//        self.dismiss(animated: true, completion: nil)
//    }

    @IBAction func btnSignIn(_ sender: UIButton) {
        let viewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "eventSignInView") as! eventSignInViewController
        viewControl.modalPresentationStyle = .popover
        
        let popover = viewControl.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = btnSignIn
        popover.sourceRect = btnSignIn.bounds
        popover.permittedArrowDirections = .any
        
        viewControl.preferredContentSize = CGSize(width: 500,height: 800)
        viewControl.eventItem = currentEvent
        self.present(viewControl, animated: true, completion: nil)
    }
    
    public func updatebar()
    {
        barProgress += 1
        let currentProgress = Float(barProgress) / Float(maxBar)
        DispatchQueue.main.async
        {
            self.progressbar.setProgress(currentProgress, animated: true)
            self.progressbar.isHidden = false
        }
    }
    
    @IBAction func btnResetPlan(_ sender: UIButton) {
        let myOptions: UIAlertController = UIAlertController(title: "Delete All Plan Entries", message: "This will delte all Plan entries.  Are you sure you wish to do this.  The entries will be permanently deleted and can not be undone and", preferredStyle: .actionSheet)
        
        let myOptionYes = UIAlertAction(title: "Yes. Permanently Delete The Plan.", style: .default, handler: { (action: UIAlertAction) -> () in

//            self.progressbar.setProgress(0.0,animated: true)
//            self.progressbar.isHidden = false
            self.tblRoles.isHidden = true

            DispatchQueue.global().async
            {
//                let totalRecords = Float(self.currentEvent.staff!.shifts.count)
//                
//                var processedCount: Int = 0
//                
//                for item in self.currentEvent.staff!.shifts
//                {
//                    DispatchQueue.main.async
//                    {
//                        let prog = Float(processedCount)/totalRecords
//                        self.progressbar.setProgress(prog, animated: true)
//                    }
//                    item.delete()
//                    
//                    processedCount += 1
//                }
            
                DispatchQueue.main.async
                {
                    self.currentEvent.staff!.removeAll(projectID: self.currentEvent.projectID, teamID: currentUser.currentTeam!.teamID)
                    self.refreshScreen()
                }
            }
        })
        myOptions.addAction(myOptionYes)

        let myOptionNo = UIAlertAction(title: "No.  Do Not Delete.", style: .default, handler: { (action: UIAlertAction) -> () in
            let _ = 1
        })
        myOptions.addAction(myOptionNo)
        
        myOptions.popoverPresentationController!.sourceView = btnResetPlan
        
        self.present(myOptions, animated: true, completion: nil)
    }
    
    @IBAction func btnCreatePlan(_ sender: UIButton)
    {
        
        currentTemplate.loadRoles()
        let roles = currentTemplate.roles!.roles!
        
        // get the muber of roles to create
        
        var roleCount: Int64 = 0
        var processedCount: Int64 = 0
        
        for item in roles
        {
            roleCount += item.numRequired
        }
        
        progressbar.setProgress(0.0,animated: true)
        progressbar.isHidden = false
        
        myCloudDB.resetSaveArray()
        
        var nextID = myCloudDB.getNextID("shiftLineID", teamID: currentUser.currentTeam!.teamID)
        
        DispatchQueue.global().async
        {
            myCloudDB.setNextID("shiftLineID", teamID: currentUser.currentTeam!.teamID, newValue: (nextID + roleCount + 1))
        }
        
        DispatchQueue.global().async
        {
            for myItem in roles
            {
                let workDay: Date!
                if myItem.dateModifier == 0
                {
                    workDay = self.currentEvent.projectStartDate.startOfDay
                }
                else
                {
                    workDay = self.currentEvent.projectStartDate.add(.day, amount: Int(myItem.dateModifier)).startOfDay
                }
                
                let WEDate = workDay.getWeekEndingDate
                
                var itemCount: Int64 = 0
                
                while itemCount < myItem.numRequired
                {
                    let newShift = shift(projectID: self.currentEvent.projectID,
                                         workDate: workDay,
                                         weekEndDate: WEDate,
                                         teamID: currentUser.currentTeam!.teamID,
                                         shiftLineID: nextID,
                                         type: eventShiftType,
                                         shiftDescription: myItem.role,
                                         startTime: myItem.startTime,
                                         endTime: myItem.endTime)
                    newShift.save(bulkSave: true)
                    
                    self.currentEvent.staff!.append(newShift)
                    
                    DispatchQueue.main.async
                    {
                        let prog = Float(processedCount)/Float(roleCount)
                        self.progressbar.setProgress(prog, animated: true)
                    }
                    processedCount += 1
                    
                    nextID += 1
                    
                    itemCount += 1
                }
            }
            
            self.currentEvent.staff!.sortArray()

            self.barProgress = 0
            self.maxBar = Int(processedCount)
            
            myCloudDB.performBulkPublicSave()

            DispatchQueue.main.async
            {
                self.refreshScreen()
                self.progressbar.isHidden = true
                self.showFields()
            }
        }
    }
    
    @IBAction func btnDate(_ sender: UIButton)
    {
        displayList.removeAll()
        
        for myItem in eventDays
        {
            displayList.append(myItem.formatDateToString)
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
            
            pickerView.source = "workday"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 300,height: 400)
            pickerView.currentValue = btnDate.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnTemplate(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append(""
        )
        templateList = eventTemplateHeads(teamID: currentUser.currentTeam!.teamID)
        for myItem in templateList.templates
        {
            displayList.append(myItem.templateName)
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
            
            pickerView.source = "template"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = btnTemplate.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnSelect(_ sender: UIButton)
    {
        displayList.removeAll()
        
        for myItem in (currentUser.currentTeam?.getDropDown(dropDownType: "Event Roles"))!
        {
            displayList.append(myItem)
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
            
            pickerView.source = "role"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = btnSelect.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnAddRole(_ sender: UIButton)
    {
        createShiftEntry(teamID: currentUser.currentTeam!.teamID, projectID: currentEvent.projectID, shiftDescription: btnSelect.currentTitle!, workDay: newRoleDate, startTime: getDefaultDate(), endTime: getDefaultDate())
        
        refreshScreen()
    }
    
    @IBAction func btnShare(_ sender: UIBarButtonItem)
    {
        let titleString = "\(currentUser.currentTeam!.name) Event Plan for \(currentEvent.projectName)"
        
        let tempReport = report(name: reportEventPlan)

        tempReport.subject = titleString
        
        let headerLine = reportLine()
        headerLine.column1 = "Name"
        tempReport.columnWidth1 = 26.9
        headerLine.column2 = "Date"
        tempReport.columnWidth2 = 13.4
        headerLine.column3 = "Start"
        tempReport.columnWidth3 = 7.8
        headerLine.column4 = "End"
        tempReport.columnWidth4 = 7.8
        headerLine.column5 = "Role"
        tempReport.columnWidth5 = 22
        
        tempReport.header = headerLine
        
        var currentDate: String = ""
        var firstTime: Bool = true
        var currentShiftDescription: String = ""
        var currentStartTime: String = ""
        
        for myShift in shiftList
        {
            if myShift.workDateString != currentDate
            {
                if !firstTime
                {
                    let drawLine = reportLine()
                    drawLine.drawLine = true
                    tempReport.append(drawLine)
                }
        
                currentDate = myShift.workDateString
                currentShiftDescription = myShift.shiftDescription
                currentStartTime = myShift.startTimeString
            }
            
            if myShift.shiftDescription != currentShiftDescription
            {
                if !firstTime
                {
                    let drawLine = reportLine()
                    drawLine.drawLine = true
                    tempReport.append(drawLine)
                }
                currentShiftDescription = myShift.shiftDescription
                currentStartTime = myShift.startTimeString
            }
            else
            {
                if myShift.startTimeString != currentStartTime
                {
                    if !firstTime
                    {
                        let drawLine = reportLine()
                        drawLine.drawLine = true
                        tempReport.append(drawLine)
                    }
                    currentStartTime = myShift.startTimeString
                }
            }
            
            firstTime = false
            let newTimeLine = reportLine()
            
            newTimeLine.column1 = myShift.personName
            newTimeLine.column2 = myShift.workDateString
            newTimeLine.column3 = myShift.startTimeString
            newTimeLine.column4 = myShift.endTimeString
            newTimeLine.column5 = myShift.shiftDescription

            tempReport.append(newTimeLine)
        }
    
        let activityViewController = tempReport.activityController
        
        activityViewController.popoverPresentationController!.sourceView = btnAddRole
        
        present(activityViewController, animated:true, completion:nil)
    }
    
    @IBAction func btnStatus(_ sender: UIButton)
    {
        displayList.removeAll()
        
        for myItem in (currentUser.currentTeam?.getDropDown(dropDownType: eventProjectType))!
        {
            displayList.append(myItem)
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
            
            pickerView.source = "status"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 400,height: 400)
            pickerView.currentValue = btnStatus.currentTitle!
            
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    public func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        switch source
        {
        case "template":
            if selectedItem > 0
            {
                if displayList[selectedItem] == ""
                {
                    btnTemplate.setTitle("Select Template", for: .normal)
                    currentTemplate = nil
                    btnCreatePlan.isHidden = true
                }
                else
                {
                    btnTemplate.setTitle(templateList.templates[selectedItem - 1].templateName, for: .normal)
                    currentTemplate = templateList.templates[selectedItem - 1]
                    btnCreatePlan.isHidden = false
                }
            }
            else
            {
                btnTemplate.setTitle("Select Template", for: .normal)
                currentTemplate = nil
            }
        
        case "role" :
            if selectedItem >= 0
            {
                if displayList[selectedItem] == ""
                {
                    btnSelect.setTitle("Select Role", for: .normal)
                    btnAddRole.isHidden = true
                }
                else
                {
                    btnSelect.setTitle(displayList[selectedItem], for: .normal)
                }
                btnAddRole.isHidden = false
            }
            else
            {
                btnSelect.setTitle("Select Role", for: .normal)
                btnAddRole.isHidden = true
            }
            
        case "workday" :
            var workingItem: Int = 0
            if selectedItem >= 0
            {
                workingItem = selectedItem
            }
            
            btnDate.setTitle(displayList[workingItem], for: .normal)
            newRoleDate = eventDays[workingItem].startOfDay
            
        case "status" :
            if selectedItem >= 0
            {
                currentEvent.projectStatus = displayList[selectedItem]
                btnStatus.setTitle(displayList[selectedItem], for: .normal)
            }
            
        default:
            print("eventPlanningViewController myPickerDidFinish selectedItem got default : \(source)")
        }
    }
    
    func createShiftEntry(teamID: Int64, projectID: Int64, shiftDescription: String, workDay: Date, startTime: Date, endTime: Date)
    {
        let WEDate = workDay.getWeekEndingDate
        
        let shiftLineID = myCloudDB.getNextID("shiftLineID", teamID: teamID)
        
        let newShift = shift(projectID: projectID, workDate: workDay, weekEndDate: WEDate, teamID: teamID, shiftLineID: shiftLineID, type: eventShiftType, shiftDescription: shiftDescription, startTime: startTime, endTime: endTime)
//        newShift.shiftDescription = shiftDescription
//        newShift.startTime = startTime
//        newShift.endTime = endTime
        newShift.save()
        
        currentEvent.staff!.append(newShift)
    }
    
    func hideFields()
    {
        btnTemplate.isHidden = false
        btnTemplate.setTitle("Select Template", for: .normal)
        lblContractName.isHidden = false
        btnCreatePlan.isHidden = true
        btnResetPlan.isHidden = true
        lblEventTemplate.isHidden = false
        tblRoles.isHidden = true
        lblAddToRole.isHidden = true
        btnSelect.isHidden = true
        btnAddRole.isHidden = true
        lblDate.isHidden = true
        btnDate.isHidden = true
        lblRoleHead.isHidden = true
        lblPersonHead.isHidden = true
        lblRateHead.isHidden = true
        lblDateHead.isHidden = true
        lblStarHead.isHidden = true
        lblEndHead.isHidden = true
        btnStatus.isHidden = true
    }
    
    func showFields()
    {
        btnTemplate.isHidden = true
        btnCreatePlan.isHidden = true
        lblEventTemplate.isHidden = true
        tblRoles.isHidden = false
        lblAddToRole.isHidden = false
        btnSelect.isHidden = false
        btnAddRole.isHidden = false
        lblDate.isHidden = false
        btnDate.isHidden = false
        lblContractName.isHidden = false
        lblRoleHead.isHidden = false
        lblPersonHead.isHidden = false
        lblRateHead.isHidden = false
        lblDateHead.isHidden = false
        lblStarHead.isHidden = false
        lblEndHead.isHidden = false
        btnStatus.isHidden = false
    }
    
    func hideAllFields()
    {
        btnTemplate.isHidden = true
        btnCreatePlan.isHidden = true
        lblEventTemplate.isHidden = true
        btnResetPlan.isHidden = true
        tblRoles.isHidden = true
        lblAddToRole.isHidden = true
        btnSelect.isHidden = true
        btnAddRole.isHidden = true
        lblDate.isHidden = true
        btnDate.isHidden = true
        lblContractName.isHidden = true
        lblRoleHead.isHidden = true
        lblPersonHead.isHidden = true
        lblRateHead.isHidden = true
        lblDateHead.isHidden = true
        lblStarHead.isHidden = true
        lblEndHead.isHidden = true
        btnStatus.isHidden = true
    }
    
    public func refreshScreen()
    {
        if currentEvent != nil
        {
            rateList = rates(clientID: currentEvent.clientID, teamID: currentUser.currentTeam!.teamID)
            shiftList = currentEvent.staff!.shifts
            
            if shiftList.count == 0
            {
                hideFields()
                btnSignIn.isEnabled = false
                btnResetPlan.isHidden = true
            }
            else
            {
                tblRoles.isHidden = false
                btnSignIn.isEnabled = true
                btnResetPlan.isHidden = false
                showFields()
            }
            
            lblAddToRole.isHidden = false
            btnSelect.isHidden = false
            lblDate.isHidden = false
            btnDate.isHidden = false
            
            if btnSelect.currentTitle! != "Select"
            {
                btnAddRole.isHidden = false
            }
            else
            {
                btnAddRole.isHidden = true
            }
            
            lblContractName.text = currentEvent.projectName
            
            tblRoles.reloadData()
        }
        else
        {
            hideAllFields()
        }
    }
}

class eventSummaryItem: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

class eventRoleItem: UITableViewCell, UIPopoverPresentationControllerDelegate, MyPickerDelegate
{
    @IBOutlet weak var lblRole: UILabel!
    @IBOutlet weak var btnPerson: UIButton!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnEnd: UIButton!
    @IBOutlet weak var btnRate: UIButton!
    @IBOutlet weak var lblDate: UILabel!
    
    var shiftRecord: shift!
    var peopleList: people!
    var rateList: rates!
    var sourceView: eventRoleItem!
    var mainView: eventPlanningViewController!
    
    fileprivate var displayList: [String] = Array()
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
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
            
            pickerView.source = "person"
            pickerView.delegate = sourceView
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 300,height: 500)
            pickerView.currentValue = btnPerson.currentTitle!
            mainView.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnStart(_ sender: UIButton)
    {
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
        pickerView.modalPresentationStyle = .popover
        //      pickerView.isModalInPopover = true
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = sourceView
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        pickerView.source = "startTime"
        
        pickerView.currentDate = shiftRecord.startTime
        pickerView.delegate = sourceView
        pickerView.showTimes = true
        pickerView.showDates = false
        pickerView.minutesInterval = 5
        pickerView.display24Hour = true
        
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        mainView.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnEnd(_ sender: UIButton)
    {
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
        pickerView.modalPresentationStyle = .popover
        //      pickerView.isModalInPopover = true
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = sourceView
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        pickerView.source = "endTime"
        
        pickerView.currentDate = shiftRecord.endTime
        pickerView.delegate = sourceView
        pickerView.showTimes = true
        pickerView.showDates = false
        pickerView.minutesInterval = 5
        pickerView.display24Hour = true
        
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        mainView.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnRate(_ sender: UIButton)
    {
        displayList.removeAll()
        
        for myItem in rateList.rates
        {
            displayList.append(myItem.rateName)
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
            pickerView.source = "rate"

            pickerView.delegate = sourceView
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 300,height: 500)
            pickerView.currentValue = btnRate.currentTitle!
            mainView.present(pickerView, animated: true, completion: nil)
        }
    }
    
    public func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if selectedItem >= 0
        {
            // We have a new object, with a selected item, so we can go ahead and create a new summary row
            switch source
            {
            case "person":
                btnPerson.setTitle(peopleList.people[selectedItem].name, for: .normal)
                
                shiftRecord.personID = peopleList.people[selectedItem].personID
                shiftRecord.save()
                
            case "rate":
                btnRate.setTitle(rateList.rates[selectedItem].rateName, for: .normal)
                shiftRecord.rateID = rateList.rates[selectedItem].rateID
                shiftRecord.save()
                
             default:
                print("eventRoleItem myPickerDidFinish-Int got unexpected entry \(source)")
            }
        }
    }
    
    public func myPickerDidFinish(_ source: String, selectedDate:Date)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        switch source
        {
            case "startTime":
                btnStart.setTitle(dateFormatter.string(from: selectedDate), for: .normal)

                shiftRecord.startTime = selectedDate
                shiftRecord.save()
                
            case "endTime":
                btnEnd.setTitle(dateFormatter.string(from: selectedDate), for: .normal)
                
                shiftRecord.endTime = selectedDate
                shiftRecord.save()
                
            default:
                print("eventRoleItem myPickerDidFinish-Date got unexpected entry \(source)")
        }
    }
}

