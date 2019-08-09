//
//  orgEditViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 12/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

public class orgEditViewController: UIViewController, MyPickerDelegate, UIPopoverPresentationControllerDelegate, myCommunicationDelegate, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var txtOrgName: UITextField!
    @IBOutlet weak var txtExternalID: UITextField!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var btnUsers: UIButton!
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
    @IBOutlet weak var txtCompanyNo: UITextField!
    @IBOutlet weak var txtTaxNo: UITextField!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var lblSubscription: UILabel!
    @IBOutlet weak var btnRenewal: UIButton!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var btnOwner: UIButton!
    @IBOutlet weak var tblAPI: UITableView!
    @IBOutlet weak var btnSelectAPI: UIButton!
    @IBOutlet weak var btnAddAPI: UIButton!
    
    private var newUserCreated: Bool = false
    private var displayList: [String] = Array()
    private var workingsourceList: [externalSource] = Array()
    
    public var workingOrganisation: team?
    public var communicationDelegate: myCommunicationDelegate?
    
    public var ownerList: [teamOwnerItem] = Array()
    
    @IBOutlet weak var btnStatus: UIButton!
    
    override public func viewDidLoad()
    {
        txtNotes.layer.borderColor = UIColor.lightGray.cgColor
        txtNotes.layer.borderWidth = 0.5
        txtNotes.layer.cornerRadius = 5.0
        txtNotes.layer.masksToBounds = true
        
        var connected: Bool = false
        
        btnAddAPI.isEnabled = false
        
        if currentUser != nil
        {
            workingsourceList = externalSources(teamID: currentUser.currentTeam!.teamID).apis
        }
        
        if workingsourceList.count == 0
        {
            tblAPI.isHidden = true
        }
        else
        {
            tblAPI.isHidden = false
        }
        
        let myReachability = Reachability()
        if myReachability.isConnectedToNetwork()
        {
            connected = true
        }
            
        if workingOrganisation == nil && connected
        {
            workingOrganisation = team()
            // Step 1 is to create a new team
            
            btnStatus.setTitle("Open", for: .normal)
            btnSave.isEnabled = false
            btnUsers.isEnabled = false
            txtOrgName.isEnabled = false
            
            // Now lets go and create an initial user
            
            if currentUser == nil
            {
                currentUser = userItem(currentTeam: workingOrganisation!, userName: "", userEmail: "")
                
                addInitialUserRoles()
            }
            else
            {
                addInitialUserRoles()
            }
            
            if workingOrganisation != nil
            {
                writeDefaultInt("teamID", value: Int(workingOrganisation!.teamID))
            }
            
            DispatchQueue.main.async
            {
                self.btnSave.isEnabled = true
                self.txtOrgName.isEnabled = true
            }
        }
        else if workingOrganisation == nil
        {
            txtOrgName.isEnabled = false
            txtExternalID.isEnabled = false
            txtNotes.isEditable = false
            txtCompanyNo.isEnabled = false
            txtTaxNo.isEnabled = false
            
            btnBack.isEnabled = true
            btnSave.isEnabled = false
            btnUsers.isEnabled = false
            btnStatus.isEnabled = false
            
            let alert = UIAlertController(title: "Create Team", message:
                "You need to be connected to the Internet to create a team", preferredStyle: UIAlertController.Style.alert)
            
            let yesOption = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: nil)
            
            alert.addAction(yesOption)
            self.present(alert, animated: false, completion: nil)
        }
        else if connected
        {
            btnOwner.setTitle("Select", for: .normal)
            
            var workingString = ""
            var firstTime: Bool = true
            
            for myItem in userTeams(teamID: workingOrganisation!.teamID).UserTeams
            {
                if !firstTime
                {
                    workingString += ", "
                }
                firstTime = false
                workingString += "\(myItem.userID)"
            }
            
            if workingString != ""
            {
                for myItem in myCloudDB.getUserList(userList: workingString)
                {
                    if myItem.userID == workingOrganisation!.teamOwner
                    {
                        DispatchQueue.main.async
                            {
                                self.btnOwner.setTitle(myItem.name, for: .normal)
                        }
                        break
                    }
                }
            }
            
            txtOrgName.text = workingOrganisation!.name
            txtExternalID.text = workingOrganisation!.externalID
            txtNotes.text = workingOrganisation!.note
            txtCompanyNo.text = workingOrganisation!.taxNumber
            txtTaxNo.text = workingOrganisation!.companyRegNumber
            
            btnBack.isEnabled = true
            btnSave.isEnabled = true
            btnUsers.isEnabled = true
            btnStatus.isEnabled = true
            btnStatus.setTitle(workingOrganisation!.status, for: .normal)
            
            let usercount = myCloudDB.getTeamUserCount()
            
            DispatchQueue.main.async
            {
                self.lblSubscription.text = "Using \(usercount) of \(self.workingOrganisation!.subscriptionLevel) users.  Your subscription will renew on \(self.workingOrganisation!.subscriptionDateString)"
            }
        }
        else
        {
            txtOrgName.isEnabled = false
            txtExternalID.isEnabled = false
            txtNotes.isEditable = false
            txtCompanyNo.isEnabled = false
            txtTaxNo.isEnabled = false
            
            btnBack.isEnabled = true
            btnSave.isEnabled = false
            btnUsers.isEnabled = false
            btnStatus.isEnabled = false
            
            let alert = UIAlertController(title: "User Login", message: "You are not connected to the Internet.  You must be connected to the Internet to use the app", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,
                                          handler: { (action: UIAlertAction) -> () in
                                            self.dismiss(animated: true, completion: nil)
            }))
            
            alert.isModalInPopover = true
            let popover = alert.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRect(x: (self.view.bounds.width / 2) - 850,y: (self.view.bounds.height / 2) - 350,width: 700 ,height: 700)
            
            self.present(alert, animated: false, completion: nil)
        }
        
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override public func viewDidAppear(_ animated: Bool)
    {
        let myReachability = Reachability()
        if !myReachability.isConnectedToNetwork()
        {
            let alert = UIAlertController(title: "Team Maintenance", message: "You must be connected to the Internet to create or edit teams", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,
                                          handler: { (action: UIAlertAction) -> () in
                                            self.dismiss(animated: true, completion: nil)
            }))
            
            alert.isModalInPopover = true
            let popover = alert.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRect(x: (self.view.bounds.width / 2) - 850,y: (self.view.bounds.height / 2) - 350,width: 700 ,height: 700)
            
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return workingsourceList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cellAPI", for: indexPath) as! APIViewCell
        
        cell.lblService.text = workingsourceList[indexPath.row].externalsource
        
        switch workingsourceList[indexPath.row].externalsource
        {
        case hubspotType:
            cell.lblAPIKey.text = "API Key"
            cell.txtAPIKey.text = workingsourceList[indexPath.row].apikey

            cell.lblSecret1.text = "Client ID"
            cell.txtSecret1.text = workingsourceList[indexPath.row].secret1

            cell.lblSecret2.text = "Secret"
            cell.txtSecret2.text = workingsourceList[indexPath.row].secret2
            
            cell.lblAPIKey.isHidden = false
            cell.txtAPIKey.isHidden = false
            cell.lblSecret1.isHidden = false
            cell.txtSecret1.isHidden = false
            cell.lblSecret2.isHidden = false
            cell.txtSecret2.isHidden = false
            cell.lblSecret3.isHidden = true
            cell.txtSecret3.isHidden = true
            cell.lblSecret4.isHidden = true
            cell.txtSecret4.isHidden = true
            
        case simplybookingType:
            cell.lblAPIKey.text = "API Key"
            cell.txtAPIKey.text = workingsourceList[indexPath.row].apikey
            
            cell.lblSecret1.text = "Company"
            cell.txtSecret1.text = workingsourceList[indexPath.row].secret1
            
            cell.lblSecret2.text = "User"
            cell.txtSecret2.text = workingsourceList[indexPath.row].secret2
            
            cell.lblSecret3.text = "Password"
            cell.txtSecret3.text = workingsourceList[indexPath.row].secret3
            
            cell.lblSecret4.text = "Secret API Key"
            cell.txtSecret4.text = workingsourceList[indexPath.row].secret4
            
            cell.lblAPIKey.isHidden = false
            cell.txtAPIKey.isHidden = false
            cell.lblSecret1.isHidden = false
            cell.txtSecret1.isHidden = false
            cell.lblSecret2.isHidden = false
            cell.txtSecret2.isHidden = false
            cell.lblSecret3.isHidden = false
            cell.txtSecret3.isHidden = false
            cell.lblSecret4.isHidden = false
            cell.txtSecret4.isHidden = false
            
        default:
            cell.lblAPIKey.text = "API Key"
            cell.txtAPIKey.text = "NONE"
            cell.lblAPIKey.isHidden = false
            cell.txtAPIKey.isHidden = false
            cell.lblSecret1.isHidden = true
            cell.txtSecret1.isHidden = true
            cell.lblSecret2.isHidden = true
            cell.txtSecret2.isHidden = true
            cell.lblSecret3.isHidden = true
            cell.txtSecret3.isHidden = true
            cell.lblSecret4.isHidden = true
            cell.txtSecret4.isHidden = true
        }
        cell.APIRecord = workingsourceList[indexPath.row]
        return cell
    }

    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
        
        if newUserCreated
        {
            communicationDelegate?.userCreated!(currentUser, teamID: workingOrganisation!.teamID)
        }
    }
    
    @IBAction func btnRenewal(_ sender: UIButton)
    {
        let renewViewControl = loginStoryboard.instantiateViewController(withIdentifier: "renewalView") as! IAPViewController
        renewViewControl.communicationDelegate = self
        self.present(renewViewControl, animated: true, completion: nil)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSave(_ sender: UIBarButtonItem)
    {
        if workingOrganisation != nil
        {
            workingOrganisation!.name = txtOrgName.text!
            
            var extID: String = ""
            
            if txtExternalID.text! != ""
            {
                extID = txtExternalID.text!
            }
            
            workingOrganisation!.externalID = extID
            workingOrganisation!.note = txtNotes.text
            workingOrganisation!.status = btnStatus.currentTitle!
            workingOrganisation!.taxNumber = txtCompanyNo.text!
            workingOrganisation!.companyRegNumber = txtTaxNo.text!
            
            workingOrganisation?.save()
        }
    }
    
    @IBAction func btnStatus(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append(openTeamState)
        displayList.append(holdTeamState)
        displayList.append(closedTeamState)
        
        if displayList.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
  //          pickerView.isModalInPopover = true
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "status"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = btnStatus.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnOwner(_ sender: UIButton)
    {
        displayList.removeAll()
        
        for myItem in ownerList
        {
            displayList.append(myItem.name)
        }
        
        if displayList.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
 //           pickerView.isModalInPopover = true
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "teamOwner"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = btnStatus.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnUsers(_ sender: UIButton)
    {
        let userEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "userForm") as! userFormViewController
        self.present(userEditViewControl, animated: true, completion: nil)
    }
  
    @IBAction func btnSelectAPI(_ sender: UIButton) {
        displayList.removeAll()
        
        displayList.append("")
        
        for item in sourceList
        {
            displayList.append(item)
        }
        
        if displayList.count > 1
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            //           pickerView.isModalInPopover = true
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "API"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = ""
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnAddAPI(_ sender: UIButton) {
        let newAPI = externalSource(externalSource: btnSelectAPI.currentTitle!, teamID: currentUser.currentTeam!.teamID)
        workingsourceList.append(newAPI)
        
        btnAddAPI.isEnabled = false
        btnSelectAPI.setTitle("Select API", for: .normal)
        tblAPI.isHidden = false
        tblAPI.reloadData()
    }
    
    func addInitialUserRoles()
    {
        writeDefaultInt(userDefaultName, value: Int(currentUser!.userID))

        currentUser.addInitialUserRoles()
        newUserCreated = true
    }
    
    public func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "status"
        {
            btnStatus.setTitle(displayList[selectedItem], for: .normal)
        }
        else if source == "teamOwner"
        {
            btnOwner.setTitle(displayList[selectedItem], for: .normal)
            workingOrganisation!.teamOwner = ownerList[selectedItem].userID
        }
        else if source == "API"
        {
            if selectedItem > 0
            {
                btnSelectAPI.setTitle(displayList[selectedItem], for: .normal)
                btnAddAPI.isEnabled = true
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification)
    {
        let deviceIdiom = getDeviceType()
        
        if deviceIdiom == .pad
        {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            {
                bottomContraint.constant = CGFloat(20) + keyboardSize.height
            }
        }
        
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(_ notification: Notification)
    {
        let deviceIdiom = getDeviceType()
        
        if deviceIdiom == .pad
        {
            bottomContraint.constant = CGFloat(20)
        }
    }
    
    public func refreshScreen()
    {
        let tempID = workingOrganisation!.teamID
        workingOrganisation = team(teamID: tempID)
        
        let usercount = myCloudDB.getTeamUserCount()
        
        DispatchQueue.main.async
        {
            self.lblSubscription.text = "Using \(usercount) of \(self.workingOrganisation!.subscriptionLevel) users.  Your subscription will renew on \(self.workingOrganisation!.subscriptionDateString)"
        }
    }
    
//    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
//        return .none
//    }
}

public class APIViewCell: UITableViewCell
{
    @IBOutlet weak var lblService: UILabel!
    @IBOutlet weak var lblAPIKey: UILabel!
    @IBOutlet weak var lblSecret3: UILabel!
    @IBOutlet weak var txtAPIKey: UITextField!
    @IBOutlet weak var txtSecret3: UITextField!
    @IBOutlet weak var lblSecret1: UILabel!
    @IBOutlet weak var lblSecret2: UILabel!
    @IBOutlet weak var txtSecret1: UITextField!
    @IBOutlet weak var txtSecret2: UITextField!
    @IBOutlet weak var lblSecret4: UILabel!
    @IBOutlet weak var txtSecret4: UITextField!
    
    var APIRecord: externalSource!
    
    @IBAction func textChanged(_ sender: UITextField) {
        if APIRecord != nil
        {
            switch sender
            {
                case txtAPIKey:
                    APIRecord.apikey = sender.text!
                
                case txtSecret1:
                    APIRecord.secret1 = sender.text!

                case txtSecret2:
                    APIRecord.secret2 = sender.text!

                case txtSecret3:
                    APIRecord.secret3 = sender.text!

                case txtSecret4:
                    APIRecord.secret4 = sender.text!

                default:
                    let _ = 1
            }
        }
    }
    
}
