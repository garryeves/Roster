//
//  contractMaintenanceViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 19/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

public class contractMaintenanceViewController: UIViewController, MyPickerDelegate, UIPopoverPresentationControllerDelegate, myCommunicationDelegate, UITextViewDelegate
{
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtNote: UITextView!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var btnStartDate: UIButton!
    @IBOutlet weak var btnEndDate: UIButton!
    @IBOutlet weak var btnContacts: UIButton!
    @IBOutlet weak var txtDept: UITextField!
    @IBOutlet weak var txtInvoicingDay: UITextField!
    @IBOutlet weak var txtDaysToPay: UITextField!
    @IBOutlet weak var btnInvoicingFrequency: UIButton!
    @IBOutlet weak var btnShowComms: UIButton!
    @IBOutlet weak var btnAddComms: UIButton!
    @IBOutlet weak var btnShowShifts: UIButton!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    
    public var delegate: mainScreenProtocol?
    public var communicationDelegate: myCommunicationDelegate?
    public var workingContract: project!
    public var displayBackButton: Bool = false
    
    fileprivate var displayList: [String] = Array()
    
    override public func viewDidLoad()
    {
        txtNote.layer.borderColor = UIColor.lightGray.cgColor
        txtNote.layer.borderWidth = 0.5
        txtNote.layer.cornerRadius = 5.0
        txtNote.layer.masksToBounds = true
        txtNote.delegate = self
        
        if displayBackButton
        {
            btnBack.isEnabled = true
            btnBack.title = "Back"
        }
        else
        {
            btnBack.isEnabled = false
            btnBack.title = ""
        }
        
        refreshScreen()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnShowComms(_ sender: UIButton)
    {
        let commsView = settingsStoryboard.instantiateViewController(withIdentifier: "commsList") as! commsListViewController
        commsView.modalPresentationStyle = .popover
        
        let popover = commsView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        commsView.preferredContentSize = CGSize(width: 800,height: 800)
        commsView.passedProject = workingContract
        self.present(commsView, animated: true, completion: nil)
    }
    
    @IBAction func btnAddComms(_ sender: UIButton)
    {
//        let newComm = commsLogEntry(teamID: (currentUser.currentTeam?.teamID)!)
//        newComm.clientID = workingContract.clientID
//        newComm.projectID = workingContract.projectID
//        
//        let commsView = settingsStoryboard.instantiateViewController(withIdentifier: "commsLogView") as! commsLogView
//        commsView.modalPresentationStyle = .popover
//        
//        let popover = commsView.popoverPresentationController!
//        popover.delegate = self
//        popover.sourceView = sender
//        popover.sourceRect = sender.bounds
//        popover.permittedArrowDirections = .any
//        
//        commsView.preferredContentSize = CGSize(width: 500,height: 800)
//        commsView.workingEntry = newComm
//        self.present(commsView, animated: true, completion: nil)
    }
    
    @IBAction func btnShowShifts(_ sender: UIButton)
    {
//        let commsView = shiftsStoryboard.instantiateViewController(withIdentifier: "personsRoster") as! personsRosterViewController
//        commsView.modalPresentationStyle = .popover
//        
//        let popover = commsView.popoverPresentationController!
//        popover.delegate = self
//        popover.sourceView = sender
//        popover.sourceRect = sender.bounds
//        popover.permittedArrowDirections = .any
//        
//        commsView.preferredContentSize = CGSize(width: 800,height: 800)
//        commsView.passedProject = workingContract
//        self.present(commsView, animated: true, completion: nil)
    }
    
    @IBAction func txtName(_ sender: UITextField)
    {
        if txtName.text! != ""
        {
            workingContract.projectName = txtName.text!
            if delegate != nil
            {
                currentUser.currentTeam?.projects = nil
                delegate!.reloadMenu()
            }
        }
    }
    
    @IBAction func txtDept(_ sender: UITextField)
    {
        workingContract.clientDept = txtDept.text!
    }
    
    @IBAction func txtInvoicingDay(_ sender: UITextField)
    {
        if txtInvoicingDay.text! != ""
        {
            if txtInvoicingDay.text!.isNumber
            {
                workingContract.invoicingDay = Int64(txtInvoicingDay.text!)!
            }
        }
        else
        {
           workingContract.invoicingDay = 0
        }
    }
    
    @IBAction func txtDaysToPay(_ sender: UITextField)
    {
        if txtDaysToPay.text! != ""
        {
            if txtDaysToPay.text!.isNumber
            {
                workingContract.daysToPay = Int64(txtDaysToPay.text!)!
            }
        }
        else
        {
            workingContract.daysToPay = 0
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView == txtNote
        {
            workingContract.note = txtNote.text!
        }
    }
    
    @IBAction func btnStatus(_ sender: UIButton)
    {
        displayList.removeAll()
        
        for myItem in (currentUser.currentTeam?.getDropDown(dropDownType: workingContract.type))!
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

    @IBAction func btnStartDate(_ sender: UIButton)
    {
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
        pickerView.modalPresentationStyle = .popover
        //      pickerView.isModalInPopover = true
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "startDate"
        pickerView.delegate = self
        if workingContract.projectStartDate == getDefaultDate().startOfDay
        {
            pickerView.currentDate = Date()
        }
        else
        {
            pickerView.currentDate = workingContract.projectStartDate.startOfDay
        }
        pickerView.showTimes = false
        
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnEndDate(_ sender: UIButton)
    {
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
        pickerView.modalPresentationStyle = .popover
        //      pickerView.isModalInPopover = true
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "endDate"
        pickerView.delegate = self
        if workingContract.projectEndDate.startOfDay == getDefaultDate().startOfDay
        {
            pickerView.currentDate = Date()
        }
        else
        {
            pickerView.currentDate = workingContract.projectEndDate.startOfDay
        }
        pickerView.showTimes = false
        
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnContacts(_ sender: UIButton)
    {
        let peopleEditViewControl = personStoryboard.instantiateViewController(withIdentifier: "personForm") as! personViewController
        peopleEditViewControl.projectID = workingContract.projectID
        self.present(peopleEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnInvoicingFrequency(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("Annualy")
        displayList.append("At Completion")
        displayList.append("Milestones")
        displayList.append("Monthly")
        displayList.append("Quarterly")
        
        if displayList.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "InvoicingFrequency"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = btnInvoicingFrequency.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func btnBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "status"
        {
            workingContract.projectStatus = displayList[selectedItem]
            if workingContract.projectStatus == ""
            {
                btnStatus.setTitle("Set", for: .normal)
            }
            else
            {
                btnStatus.setTitle(workingContract.projectStatus, for: .normal)
            }
        }
        else if source == "InvoicingFrequency"
        {
            workingContract.invoicingFrequency = displayList[selectedItem]
            if workingContract.invoicingFrequency == ""
            {
                btnInvoicingFrequency.setTitle("Set", for: .normal)
            }
            else
            {
                btnInvoicingFrequency.setTitle(workingContract.invoicingFrequency, for: .normal)
            }
        }
    }
    
    public func myPickerDidFinish(_ source: String, selectedDate:Date)
    {
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(processDateChange(timer :)), userInfo: ["source": source, "selectedDate":selectedDate], repeats: false)
    }
    
    @objc func processDateChange(timer: Timer)
    {
        let info = timer.userInfo as! [String:Any]
        let source = info["source"] as! String
        let selectedDate = info["selectedDate"] as! Date
        
        if source == "startDate"
        {
            var boolSave: Bool = true
            
            if workingContract.projectEndDate.startOfDay != getDefaultDate().startOfDay
            {
                if selectedDate.startOfDay > workingContract.projectEndDate.startOfDay
                {
                    let alert = UIAlertController(title: "Contract Maintenance", message: "Start Date can not be after End Date of \(workingContract.displayProjectEndDate)", preferredStyle: .actionSheet)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,
                                                  handler: { (action: UIAlertAction) -> () in
                                                    let _ = 1
                    }))
                    
                    alert.isModalInPopover = true
                    let popover = alert.popoverPresentationController
                    popover!.delegate = self
                    popover!.sourceView = btnStartDate
                    
                    self.present(alert, animated: false, completion: nil)
                    
                    boolSave = false
                }
            }
            
            if boolSave
            {
                workingContract.projectStartDate = selectedDate.startOfDay
                if workingContract.projectStartDate.startOfDay == getDefaultDate().startOfDay
                {
                    btnStartDate.setTitle("Set", for: .normal)
                }
                else
                {
                    btnStartDate.setTitle(workingContract.displayProjectStartDate, for: .normal)
                }
            }
        }
        else if source == "endDate"
        {
            var boolSave: Bool = true
            
            if workingContract.projectStartDate.startOfDay != getDefaultDate().startOfDay
            {
                if selectedDate.startOfDay < workingContract.projectStartDate.startOfDay
                {
                    let alert = UIAlertController(title: "Contract Maintenance", message: "End Date can not be before Start Date of \(workingContract.displayProjectStartDate)", preferredStyle: .actionSheet)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,
                                                  handler: { (action: UIAlertAction) -> () in
                                                    let _ = 1
                    }))
                    
                    alert.isModalInPopover = true
                    let popover = alert.popoverPresentationController
                    popover!.delegate = self
                    popover!.sourceView = btnEndDate
                    
                    self.present(alert, animated: false, completion: nil)
                    
                    boolSave = false
                }
            }
            
            if boolSave
            {
                workingContract.projectEndDate = selectedDate.startOfDay
                if workingContract.projectEndDate.startOfDay == getDefaultDate().startOfDay
                {
                    btnEndDate.setTitle("Set", for: .normal)
                }
                else
                {
                    btnEndDate.setTitle(workingContract.displayProjectEndDate, for: .normal)
                }
            }
        }
    }
    
    public func refreshScreen()
    {
        if workingContract != nil
        {
            txtName.text = workingContract.projectName
            txtNote.text = workingContract.note
            txtDept.text = workingContract.clientDept
            txtInvoicingDay.text = "\(workingContract.invoicingDay)"
            txtDaysToPay.text = "\(workingContract.daysToPay)"
            
            if workingContract.projectStatus == ""
            {
                btnStatus.setTitle("Set", for: .normal)
            }
            else
            {
                btnStatus.setTitle(workingContract.projectStatus, for: .normal)
            }
            
            if workingContract.projectStartDate.startOfDay == getDefaultDate().startOfDay
            {
                btnStartDate.setTitle("Set", for: .normal)
            }
            else
            {
                btnStartDate.setTitle(workingContract.displayProjectStartDate, for: .normal)
            }
            
            if workingContract.projectEndDate.startOfDay == getDefaultDate().startOfDay
            {
                btnEndDate.setTitle("Set", for: .normal)
            }
            else
            {
                btnEndDate.setTitle(workingContract.displayProjectEndDate, for: .normal)
            }
            
            if workingContract.invoicingFrequency == ""
            {
                btnInvoicingFrequency.setTitle("Set", for: .normal)
            }
            else
            {
                btnInvoicingFrequency.setTitle(workingContract.invoicingFrequency, for: .normal)
            }
        }
    }
}
