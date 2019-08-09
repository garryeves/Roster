//
//  personViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 16/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit
import ContactsUI

public class personViewController: UIViewController, UIPopoverPresentationControllerDelegate, myCommunicationDelegate, MyPickerDelegate, CNContactPickerDelegate, UITextViewDelegate
{
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var btnDOB: UIButton!
    @IBOutlet weak var btnGender: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDOB: UILabel!
    @IBOutlet weak var lblGener: UILabel!
    @IBOutlet weak var lblNotes: UILabel!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var lblRoster: UILabel!
    @IBOutlet weak var switchRoster: UISwitch!
    @IBOutlet weak var lblLastName: UILabel!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var btnShowComms: UIButton!
    @IBOutlet weak var btnShowRoster: UIButton!
    @IBOutlet weak var btnAddComms: UIButton!
    @IBOutlet weak var lblActive: UILabel!
    @IBOutlet weak var switchActive: UISwitch!
    @IBOutlet weak var btnCoachingSessions: UIButton!
    
    var communicationDelegate: myCommunicationDelegate?
    var clientID: Int64!
    var projectID: Int64!
    
    private var keyboardDisplayed: Bool = false
    public var selectedPerson: person!
    private var displayList: [String] = Array()

    override public func viewDidLoad()
    {
        txtNotes.layer.borderColor = UIColor.lightGray.cgColor
        txtNotes.layer.borderWidth = 0.5
        txtNotes.layer.cornerRadius = 5.0
        txtNotes.layer.masksToBounds = true
        txtNotes.delegate = self
        
        hideFields()
        
        if selectedPerson != nil
        {
            showFields()
            loadDetails()
            refreshScreen()
        }

        if currentUser.checkWritePermission(coachingRoleType)
        {
            btnCoachingSessions.isHidden = false
        }
        else
        {
            btnCoachingSessions.isHidden = true
        }
        
        if currentUser.currentTeam!.ShiftList == nil
        {
            btnShowRoster.isHidden = true
        }
        else
        {
            if (currentUser.currentTeam?.ShiftList?.count)! > 0
            {
                btnShowRoster.isHidden = false
            }
            else
            {
                btnShowRoster.isHidden = true
            }
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchRoster(_ sender: UISwitch)
    {
        if sender.isOn
        {
            selectedPerson.canRoster = true
        }
        else
        {
            selectedPerson.canRoster = false
        }
    }
    
    @IBAction func switchActive(_ sender: UISwitch)
    {
        selectedPerson.isActive = sender.isOn
    }
    
    @IBAction func btnDOB(_ sender: UIButton)
    {
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
        pickerView.modalPresentationStyle = .popover
        //      pickerView.isModalInPopover = true
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "DOB"
        pickerView.delegate = self
        if selectedPerson.dob == getDefaultDate()
        {
            pickerView.currentDate = Date()
        }
        else
        {
            pickerView.currentDate = selectedPerson.dob
        }
        pickerView.showTimes = false
        
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnGender(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("Female")
        displayList.append("Male")
        displayList.append("Other")
        
        if displayList.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            //      pickerView.isModalInPopover = true
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "gender"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = sender.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
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
        commsView.passedPerson = selectedPerson
        self.present(commsView, animated: true, completion: nil)
    }
    
    @IBAction func btnAddressList(_ sender: UIButton) {
//        let commsView = personStoryboard.instantiateViewController(withIdentifier: "addressList") as! addressListViewController
//        commsView.modalPresentationStyle = .popover
//        
//        let popover = commsView.popoverPresentationController!
//        popover.delegate = self
//        popover.sourceView = sender
//        popover.sourceRect = sender.bounds
//        popover.permittedArrowDirections = .any
//        
//        commsView.preferredContentSize = CGSize(width: 800,height: 800)
//        commsView.passedPerson = selectedPerson
//        self.present(commsView, animated: true, completion: nil)
    }
    
    @IBAction func btnContactList(_ sender: UIButton) {
//        let commsView = personStoryboard.instantiateViewController(withIdentifier: "contactList") as! contactListViewController
//        commsView.modalPresentationStyle = .popover
//        
//        let popover = commsView.popoverPresentationController!
//        popover.delegate = self
//        popover.sourceView = sender
//        popover.sourceRect = sender.bounds
//        popover.permittedArrowDirections = .any
//        
//        commsView.preferredContentSize = CGSize(width: 800,height: 800)
//        commsView.passedPerson = selectedPerson
//        self.present(commsView, animated: true, completion: nil)
    }
    
    @IBAction func btnPersonalInfoList(_ sender: UIButton) {
        let commsView = personStoryboard.instantiateViewController(withIdentifier: "addInfoList") as! addInfoListViewController
        commsView.modalPresentationStyle = .popover
        
        let popover = commsView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        commsView.preferredContentSize = CGSize(width: 400,height: 800)
        commsView.passedPerson = selectedPerson
        self.present(commsView, animated: true, completion: nil)
    }
    
    @IBAction func btnShowRoster(_ sender: UIButton)
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
//        commsView.passedPerson = selectedPerson
//        self.present(commsView, animated: true, completion: nil)
    }
    
    @IBAction func btnCoachingSessions(_ sender: UIButton) {
        let commsView = coursesStoryboard.instantiateViewController(withIdentifier: "sessionNotesViewController") as! sessionNotesViewController
        commsView.modalPresentationStyle = .popover
        
        let popover = commsView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        commsView.preferredContentSize = CGSize(width: 800,height: 800)
        commsView.passedPerson = selectedPerson
        self.present(commsView, animated: true, completion: nil)
    }
    
    @IBAction func btnAddComms(_ sender: UIButton)
    {
//        let newComm = commsLogEntry(teamID: (currentUser.currentTeam?.teamID)!)
//        newComm.personID = selectedPerson.personID
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
    
    public func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView == txtNotes
        {
            selectedPerson.note = txtNotes.text!
        }
    }
    
    @IBAction func btnImport(_ sender: UIButton)
    {
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        self.present(cnPicker, animated: true, completion: nil)
    }
    
    public func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact])
    {
        contacts.forEach{ contact in
            
            let workingContact = iOSContact(contactRecord: contact)
            
            let workingRecord = person(teamID: currentUser.currentTeam!.teamID)
            if clientID != nil
            {
                workingRecord.clientID = clientID
            }
            
            if projectID != nil
            {
                workingRecord.projectID = projectID
            }
            
            workingRecord.lastName = workingContact.lastName
            workingRecord.firstName = workingContact.firstName
            
            if workingContact.dateOfBirth != nil
            {
                workingRecord.dob  = workingContact.dateOfBirth!
            }
            
            workingRecord.save()
            
            for myItem in workingContact.addresses
            {
                for myType in ["Home", "Office", "Other"]
                {
                    if myItem.type == myType
                    {
                        let workingAddress = address(teamID: currentUser.currentTeam!.teamID, addressType: myItem.type, personID: workingRecord.personID)
                        workingAddress.addressLine1 = myItem.line1
                        workingAddress.addressLine2 = myItem.line2
                        workingAddress.city = myItem.city
                        workingAddress.state = myItem.state
                        workingAddress.country = myItem.country
                        workingAddress.postcode = myItem.postcode
                        
                        workingAddress.save()
                        break
                    }
                }
            }
            
            for myItem in workingContact.phoneNumbers
            {
                for myType in ["Home Phone", "Office Phone", "Mobile Phone"]
                {
                    if myItem.type == myType
                    {
                        let workingDetail = contactItem(teamID: currentUser.currentTeam!.teamID, contactType: myItem.type, personID: workingRecord.personID, clientID: 0, projectID: 0)

                        sleep(1)
                        workingDetail.contactValue = myItem.detail

                        workingDetail.save()
                        break
                    }
                }
            }

            for myItem in workingContact.emailAddresses
            {
                for myType in ["Home Email", "Office Email"]
                {
                    if myItem.type == myType
                    {
                        let workingDetail = contactItem(teamID: currentUser.currentTeam!.teamID, contactType: myItem.type, personID: workingRecord.personID, clientID: 0, projectID: 0)
                        
                        sleep(1)
                        workingDetail.contactValue = myItem.detail

                        workingDetail.save()
                        break
                    }
                }
            }
            
            sleep(1)
        }
        
        hideFields()
        refreshScreen()
    }
    
    public func contactPickerDidCancel(_ picker: CNContactPickerViewController)
    {
        print("Cancel Contact Picker")
    }
    
    @IBAction func txtName(_ sender: UITextField)
    {
        if sender == txtName
        {
            selectedPerson.firstName = txtName.text!
        }
        
        if sender == txtLastName
        {
            selectedPerson.lastName = txtLastName.text!
        }
    }
    
    func validateName(_ postAction: String)
    {
        let currentLastName = selectedPerson.lastName
        let currentFirstName = selectedPerson.firstName
        let newFirstName = txtName.text!
        let newLastName = txtLastName.text
        
//        if (currentName != "" && currentName != "Name") && newFirstName != currentFirstName
        if (newLastName != currentLastName) || (newFirstName != currentFirstName)
        {
            let alert = UIAlertController(title: "Change Name", message:
                "Change name from \(currentFirstName) \(currentLastName) to \(newFirstName) \(newLastName!)", preferredStyle: UIAlertController.Style.alert)
            
            let yesOption = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler:  {(action: UIAlertAction) -> () in
                self.selectedPerson.lastName = newLastName!
                self.selectedPerson.firstName = newFirstName
                
                if postAction == "exit"
                {
                    self.dismiss(animated: true, completion: nil)
                    self.communicationDelegate?.refreshScreen!()
                }
            })
            
            let noOption = UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction) -> () in
                if postAction == "exit"
                {
                    self.dismiss(animated: true, completion: nil)
                    self.communicationDelegate?.refreshScreen!()
                }
            })
            
            alert.addAction(yesOption)
            alert.addAction(noOption)
            self.present(alert, animated: false, completion: nil)
        }
        else if (selectedPerson.name == "" || selectedPerson.name == "Name") && ((newLastName != "" && newLastName != "Name") || (newFirstName != "" && newFirstName != "Name"))
        {
            self.selectedPerson.lastName = newLastName!
            self.selectedPerson.firstName = newFirstName
            
            if postAction == "exit"
            {
                self.dismiss(animated: true, completion: nil)
                self.communicationDelegate?.refreshScreen!()
            }
        }
        else
        {
            if postAction == "exit"
            {
                self.dismiss(animated: true, completion: nil)
                self.communicationDelegate?.refreshScreen!()
            }
        }
    }
    
    public func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "gender"
        {
            selectedPerson.gender = displayList[selectedItem]
            btnGender.setTitle(displayList[selectedItem], for: .normal)
        }
    }

    public func myPickerDidFinish(_ source: String, selectedDate:Date)
    {
        if source == "DOB"
        {
            selectedPerson.dob = selectedDate
            btnDOB.setTitle(selectedPerson.dobText, for: .normal)
        }
    }
    
    func hideFields()
    {
        txtName.isHidden = true
        btnDOB.isHidden = true
        btnGender.isHidden = true
        lblName.isHidden = true
        lblDOB.isHidden = true
        lblGener.isHidden = true
        lblNotes.isHidden = true
        txtNotes.isHidden = true
        lblRoster.isHidden = true
        switchRoster.isHidden = true
        switchActive.isHidden = true
        lblLastName.isHidden = true
        txtLastName.isHidden = true
        btnShowComms.isHidden = true
        btnShowRoster.isHidden = true
        btnAddComms.isHidden = true
    }
    
    func showFields()
    {
        txtName.isHidden = false
        btnDOB.isHidden = false
        btnGender.isHidden = false
        lblName.isHidden = false
        lblDOB.isHidden = false
        lblGener.isHidden = false
        lblNotes.isHidden = false
        txtNotes.isHidden = false
        lblRoster.isHidden = false
        switchRoster.isHidden = false
        switchActive.isHidden = false
        lblLastName.isHidden = false
        txtLastName.isHidden = false
        btnShowComms.isHidden = false
        btnShowRoster.isHidden = false
        btnAddComms.isHidden = false
    }
    
    public func refreshScreen()
    {
//        if clientID != nil
//        {
//            myPeople = people(clientID: clientID, teamID: currentUser.currentTeam!.teamID)
//        }
//        else if projectID != nil
//        {
//            myPeople = people(projectID: projectID, teamID: currentUser.currentTeam!.teamID)
//        }
//        else
//        {
//            myPeople = people(teamID: currentUser.currentTeam!.teamID)
//        }
//
//        tblPeople.reloadData()
        loadDetails()
    }
    
    func loadDetails()
    {
        if selectedPerson != nil
        {
            txtName.text = selectedPerson.firstName
            txtLastName.text = selectedPerson.lastName
            btnDOB.setTitle(selectedPerson.dobText, for: .normal)
            btnGender.setTitle(selectedPerson.gender, for: .normal)
            txtNotes.text = selectedPerson.note
            switchActive.isOn = selectedPerson.isActive
            
            if appName == "EvesSecurity"
            {
                lblRoster.isHidden = false
                switchRoster.isHidden = false
                if selectedPerson.canRoster
                {
                    switchRoster.isOn = true
                }
                else
                {
                    switchRoster.isOn = false
                }
            }
            else
            {
                lblRoster.isHidden = true
                switchRoster.isHidden = true
            }
        }
    }
}

class personListItem: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDOB: UILabel!
}

class personAddInfoListItem: UITableViewCell, MyPickerDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnYesNo: UIButton!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var txtValue: UITextField!
    
    var parentViewController: addInfoListViewController!
    var addInfoEntry: personAddInfoEntry!
    var passedPerson: person!
    var addInfoName: String!

    fileprivate var displayList: [String] = Array()
    
    @IBAction func btnYesNo(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("")
        displayList.append("Yes")
        displayList.append("No")
        
        if displayList.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "YesNo"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = sender.currentTitle!
            parentViewController.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnDate(_ sender: UIButton)
    {
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "Date"
        pickerView.delegate = self
        pickerView.currentDate = Date()
        pickerView.showTimes = false
        
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        parentViewController.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func txtValue(_ sender: UITextField)
    {
        if addInfoEntry == nil
        {
            addInfoEntry = personAddInfoEntry(addInfoName: addInfoName, personID: passedPerson.personID, teamID: (currentUser.currentTeam?.teamID)!)
        }
        
        addInfoEntry.stringValue = sender.text!
        addInfoEntry.save()
        
        currentUser.currentTeam?.personAddInfoEntry = nil
        
        NotificationCenter.default.post(name: NotificationAddInfoDone, object: nil)
    }
    
    public func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "YesNo"
        {
            if selectedItem >= 0
            {
                if addInfoEntry == nil
                {
                    addInfoEntry = personAddInfoEntry(addInfoName: addInfoName, personID: passedPerson.personID, teamID: (currentUser.currentTeam?.teamID)!)
                }
                
                addInfoEntry!.stringValue = displayList[selectedItem]
                addInfoEntry!.save()
                
                currentUser.currentTeam?.personAddInfoEntry = nil
                
                NotificationCenter.default.post(name: NotificationAddInfoDone, object: nil)
            }
        }
    }
    
    public func myPickerDidFinish(_ source: String, selectedDate:Date)
    {
        if source == "Date"
        {
            if addInfoEntry == nil
            {
                addInfoEntry = personAddInfoEntry(addInfoName: addInfoName, personID: passedPerson.personID, teamID: (currentUser.currentTeam?.teamID)!)
            }
            
            addInfoEntry.dateValue = selectedDate
            addInfoEntry.save()
            
            currentUser.currentTeam?.personAddInfoEntry = nil
            
            NotificationCenter.default.post(name: NotificationAddInfoDone, object: nil)
        }
    }
}

class contactDetailsItem: UITableViewCell
{
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var txtDetail: UITextField!
    
    var contactDetail: contactItem!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func txtDetails(_ sender: UITextField)
    {
//        if contactDetail == nil
//        {
//            contactDetail = contactItem(teamID: teamID)
//            contactDetail.personID = personID
//            contactDetail.contactType = lblType.text!
//        }
        contactDetail.contactValue = sender.text!
        contactDetail.save()
    }
}

