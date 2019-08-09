//
//  settingViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 15/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit
import CloudKit

struct decodeItem
{
    var name: String = ""
    var value: String = ""
    var source: String = ""
}

public class settingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, MyPickerDelegate
{
    public var communicationDelegate: myCommunicationDelegate?
    
    @IBOutlet weak var tblCalendar: UITableView!
    @IBOutlet weak var tblSettings: UITableView!
    @IBOutlet weak var btnTeam: UIButton!
    @IBOutlet weak var btnPassword: UIButton!
    @IBOutlet weak var btnPerAddInfo: UIButton!
    @IBOutlet weak var btnDropbown: UIButton!
    @IBOutlet weak var btnSwitchUsers: UIButton!
    @IBOutlet weak var btnRestore: UIButton!
    @IBOutlet weak var btnNewTeam: UIButton!
    @IBOutlet weak var btnLinkPersonTask: UIButton!
    @IBOutlet weak var btnInAppPurchase: UIButton!
    @IBOutlet weak var btnCoachingSessionsMaintenance: UIButton!
    @IBOutlet weak var lblDefaultCalendar: UILabel!
    @IBOutlet weak var btnDefaultCalendar: UIButton!
    @IBOutlet weak var btnDuplicateShifts: UIButton!
    
    fileprivate var calendarList: iOSCalendarList!
    fileprivate var decodeList: [decodeItem] = Array()
    
    private var displayList: [String] = Array()
    private var teamList: userTeams!
    private var newTeam: team!
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        
        if currentUser.checkWritePermission(coachingRoleType)
        {
            btnCoachingSessionsMaintenance.isHidden = false
        }
        else
        {
            btnCoachingSessionsMaintenance.isHidden = true
        }
        
        refreshScreen()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView
        {
        case tblCalendar:
            if calendarList != nil
            {
                return calendarList.list.count
            }
            else
            {
                return 0
            }
            
        case tblSettings:
            return decodeList.count
            
        default:
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblCalendar:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellCalendar", for: indexPath) as! oneLabelTable
                
                cell.lbl1.text = calendarList.list[indexPath.row].name
                
                if calendarList.list[indexPath.row].state
                {
                    cell.backgroundColor = cyanColour
                }
                else
                {
                    cell.backgroundColor = UIColor.white
                }
                
                return cell
            
            case tblSettings:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellSettings", for: indexPath) as! settingEntryItem
                
                cell.lblName.text = decodeList[indexPath.row].name
                cell.txtValue.text = decodeList[indexPath.row].value
                cell.source = decodeList[indexPath.row].source
                
                return cell
            
            default:
                return UITableViewCell()
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView
        {
            case tblCalendar:
               calendarList.list[indexPath.row].state = !calendarList.list[indexPath.row].state
                
                tblCalendar.reloadData()
                
            case tblSettings:
                let _ = 1
                
                
            default:
                let _ = 1
        }
    }
    
    @IBAction func btnPrivacy(_ sender: UIButton)
    {
        if let url = URL(string: "https://nextactions.com.au/privacy-statement/") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func btnTerms(_ sender: UIButton)
    {
        if let url = URL(string: "https://nextactions.com.au/applications-terms-and-conditions/") {
            UIApplication.shared.open(url, options: [:])
        }
    }

    @IBAction func btnTeam(_ sender: UIButton)
    {
        let orgEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "orgEdit") as! orgEditViewController
        orgEditViewControl.workingOrganisation = currentUser!.currentTeam
        self.present(orgEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnInAppPurchase(_ sender: UIButton)
    {
        let passwordView = loginStoryboard.instantiateViewController(withIdentifier: "renewalView") as! IAPViewController
        passwordView.modalPresentationStyle = .popover
        
        let popover = passwordView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        passwordView.preferredContentSize = CGSize(width: 800,height: 800)
        
        self.present(passwordView, animated: true, completion: nil)
    }
    
    @IBAction func btnPassword(_ sender: UIButton)
    {
        let passwordView = loginStoryboard.instantiateViewController(withIdentifier: "setPassword") as! setPasswordViewController
        passwordView.modalPresentationStyle = .popover
        
        let popover = passwordView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        passwordView.preferredContentSize = CGSize(width: 600,height: 500)
        
        self.present(passwordView, animated: true, completion: nil)
    }
    
    @IBAction func btnPerAddInfo(_ sender: UIButton)
    {
        let addPerInfoViewControl = personStoryboard.instantiateViewController(withIdentifier: "AddPersonInfo") as! addPerInfoMaintenanceViewController
        self.present(addPerInfoViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnDropdowns(_ sender: UIButton)
    {
        let dropdownEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "dropdownMaintenance") as! dropdownMaintenanceViewController
        self.present(dropdownEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnRestore(_ sender: UIButton)
    {
        let deletedItemsViewControl = settingsStoryboard.instantiateViewController(withIdentifier: "securityDeletedItems") as! securityDeletedItemsViewController
        self.present(deletedItemsViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnSwitchUsers(_ sender: UIButton)
    {
        let newView = settingsStoryboard.instantiateViewController(withIdentifier: "emailTemplateListView") as! emailTemplateListViewController
        newView.modalPresentationStyle = .popover
        
        let popover = newView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = self.btnSwitchUsers
        popover.sourceRect = self.btnSwitchUsers.bounds
        popover.permittedArrowDirections = .any
        newView.preferredContentSize = CGSize(width: 800,height: 800)
        
        self.present(newView, animated: true, completion: nil)
    }
    
    @IBAction func btnDefaultCalendar(_ sender: UIButton) {
        displayList.removeAll()
        
        displayList.append("")
        for item in calendarList.list
        {
            displayList.append(item.name)
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
            
            pickerView.source = "Calendar"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 600,height: 400)
            pickerView.currentValue = sender.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    public func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "TeamList"
        {
            if selectedItem >= 0
            {
                currentUser.currentTeam = team(teamID: teamList.UserTeams[selectedItem].teamID)
                writeDefaultInt("teamID", value: Int(currentUser.currentTeam!.teamID))
            }
        }
        else if source == "Calendar"
        {
            if selectedItem >= 0
            {
                btnDefaultCalendar.setTitle(calendarList.list[selectedItem - 1].name, for: .normal)
                currentUser.defaultCalendar = calendarList.list[selectedItem - 1].name
                currentUser.save()
            }
        }
    }
    
    @IBAction func btnNewTeam(_ sender: UIButton)
    {
        // Create a new team
        
        let alert = UIAlertController(title: "Create Team", message: "This may take a couple of minutes", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,
                                      handler: { (action: UIAlertAction) -> () in
                                        self.btnSwitchUsers.isEnabled = false
                                        self.btnTeam.isEnabled = false
                                        self.btnPerAddInfo.isEnabled = false
                                        self.btnDropbown.isEnabled = false
                                        self.btnRestore.isEnabled = false
                                        self.btnTeam.isEnabled = false
                                        self.btnNewTeam.isEnabled = false
                                        self.btnPassword.isEnabled = false
                                        self.btnLinkPersonTask.isEnabled = false
                                        
                                        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.createTeam), userInfo: nil, repeats: false)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default,
                                      handler: { (action: UIAlertAction) -> () in
                                        let _ = 1
        }))
        
        alert.isModalInPopover = true
        let popover = alert.popoverPresentationController
        popover!.delegate = self
        popover!.sourceView = btnNewTeam
        
        self.present(alert, animated: false, completion: nil)
    }
    
    @objc func createTeam()
    {
        newTeam = team()
        
        // Add team to use
        currentUser.addTeamToUser(newTeam)
        newTeam.teamOwner = currentUser.userID
        currentUser.currentTeam = newTeam
        currentUser.addInitialUserRoles()
        // Pass this into team maintence screen
        writeDefaultInt("teamID", value: Int(newTeam!.teamID))
        
        refreshScreen()
        btnPassword.isEnabled = true
        let orgEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "orgEdit") as! orgEditViewController
        orgEditViewControl.workingOrganisation = currentUser!.currentTeam
        self.present(orgEditViewControl, animated: true, completion: nil)
    }
    
//    @IBAction func btnBack(_ sender: Any)
//    {
//        communicationDelegate!.refreshScreen!()
//        dismiss(animated: true, completion: nil)
//    }
    
    @IBAction func btnLinkPersonTask(_ sender: UIButton)
    {
//        let personTaskLinkViewControl = personStoryboard.instantiateViewController(withIdentifier: "personTaskLink") as! personTaskLinkViewController
//        personTaskLinkViewControl.modalPresentationStyle = .popover
//        
//        let popover = personTaskLinkViewControl.popoverPresentationController!
//        popover.delegate = self
//        popover.sourceView = sender
//        popover.sourceRect = sender.bounds
//        popover.permittedArrowDirections = .any
//        personTaskLinkViewControl.preferredContentSize = CGSize(width: 500,height: 300)
//        
//        self.present(personTaskLinkViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnCoachingSessionsMaintenance(_ sender: UIButton) {
        let passwordView = settingsStoryboard.instantiateViewController(withIdentifier: "sessionMaintenance") as! sessionMaintenanceViewController
        passwordView.modalPresentationStyle = .popover
        
        let popover = passwordView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        passwordView.preferredContentSize = CGSize(width: 800,height: 800)
        
        self.present(passwordView, animated: true, completion: nil)
    }
    
    public func refreshScreen()
    {
        if userTeams(userID: currentUser.userID).UserTeams.count > 1
        {
            DispatchQueue.main.async
            {
                self.btnSwitchUsers.isHidden = false
            }
        }
        else
        {
            DispatchQueue.main.async
            {
                self.btnSwitchUsers.isHidden = true
            }
        }
        
        if currentUser.checkReadPermission(adminRoleType)
        {
            DispatchQueue.main.async
            {
                self.btnTeam.isEnabled = true
                self.btnPerAddInfo.isEnabled = true
                self.btnDropbown.isEnabled = true
                self.btnRestore.isEnabled = true
            }
        }
        else
        {
            DispatchQueue.main.async
            {
                self.btnTeam.isEnabled = false
                self.btnPerAddInfo.isEnabled = false
                self.btnDropbown.isEnabled = false
                self.btnRestore.isEnabled = false
            }
        }
        
        if currentUser.currentTeam!.teamOwner == currentUser.userID
        {
            DispatchQueue.main.async
            {
                self.btnTeam.isEnabled = true
            }
        }
        
        DispatchQueue.main.async
        {
            self.calendarList = iOSCalendarList()
            self.tblCalendar.reloadData()
            self.buildDecodeArray()
            
            if currentUser.checkWritePermission(coachingRoleType)
            {
                self.btnCoachingSessionsMaintenance.isHidden = false
            }
            else
            {
                self.btnCoachingSessionsMaintenance.isHidden = true
            }
        }
        
        btnDefaultCalendar.setTitle(currentUser.defaultCalendar, for: .normal)
    }
    
    func buildDecodeArray()
    {
        decodeList.removeAll()
        
        var calBefore = readDefaultInt("CalBefore")
        
        if calBefore == -1
        {
            writeDefaultInt("CalBefore", value: 2)
            calBefore = 2
        }
        
        let newItemBefore = decodeItem(name: "Number of weeks before today", value: "\(calBefore)", source: "CalBefore")
        decodeList.append(newItemBefore)
        
        var calAfter = readDefaultInt("CalAfter")
        
        if calAfter == -1
        {
            writeDefaultInt("CalAfter", value: 4)
            calAfter = 4
        }
        let newItemAfter = decodeItem(name: "Number of weeks after today", value: "\(calAfter)", source: "CalAfter")
        decodeList.append(newItemAfter)
        
        tblSettings.reloadData()
    }
 
    @IBAction func btnDuplicateShifts(_ sender: UIButton) {
        // Here we will check for duplicate shifts

        var shiftList: [shift] = Array()
        
        let shiftCheck = shifts(teamID: currentUser.currentTeam!.teamID)

        shiftCheck.checkForDuplicates(true)
        
        let secondShifts = shiftCheck
        
        for item in shiftCheck.shifts
        {
            for searchItem in secondShifts.shifts
            {
                if item.projectID == searchItem.projectID &&
                    item.personID != searchItem.personID &&
                    item.workDate == searchItem.workDate &&
                    item.startTime == searchItem.startTime &&
                    item.endTime == searchItem.endTime &&
                    item.recordID != searchItem.recordID &&
                    item.status == shiftStatusOpen &&
                    searchItem.status == shiftStatusOpen &&
                    item.personID != 0
                {
                    if searchItem.personID != 0
                    {
                        var itemFound: Bool = false
                        
                        for existingItem in shiftList
                        {
                            // Check for existing row
                            
                            if searchItem.recordID == existingItem.recordID
                            {
                                itemFound = true
                                break
                            }
                        }
                        
                        if !itemFound
                        {
                            shiftList.append(searchItem)
                        }
                    }
                }
            }
        }
        
        if shiftList.count == 0
        {
            let alert = UIAlertController(title: "Clean up duplicate shifts", message: "Completed", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,
                                          handler: { (action: UIAlertAction) -> () in
                                            let _ = 1
            }))
            
            alert.isModalInPopover = true
            let popover = alert.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = btnDuplicateShifts
            
            self.present(alert, animated: false, completion: nil)
        }
        else
        {
            let dupsView = shiftsStoryboard.instantiateViewController(withIdentifier: "dupShiftsView") as! duplicateShiftsViewController
            
            dupsView.shiftList = shiftList
            self.present(dupsView, animated: true, completion: nil)
        }
    }
}

class settingEntryItem: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var txtValue: UITextField!
    
    var source: String!
    
    @IBAction func txtValue(_ sender: UITextField)
    {
        if source == "CalBefore" || source == "CalAfter"
        {
            if sender.text!.isNumber
            {
                writeDefaultInt(source, value: Int(sender.text!)!)
            }
        }
    }
}

