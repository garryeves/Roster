//
//  clientMaintenanceViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 19/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

public class clientMaintenanceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, myCommunicationDelegate, UIPopoverPresentationControllerDelegate, UITextViewDelegate
{
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var tblContracts: UITableView!
    @IBOutlet weak var btnAddContract: UIButton!
    @IBOutlet weak var btnContact: UIButton!
    @IBOutlet weak var lblContracts: UILabel!
    @IBOutlet weak var lblContact: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnAddComms: UIButton!
    @IBOutlet weak var lblActive: UILabel!
    @IBOutlet weak var switchActive: UISwitch!
    @IBOutlet weak var btnAddEvent: UIButton!
    @IBOutlet weak var btnShowComms: UIButton!
    @IBOutlet weak var switchArchived: UISwitch!
    
    public  var communicationDelegate: myCommunicationDelegate?
    
    fileprivate var contractsList: projects!
    public var selectedClient: client!
    fileprivate var selectedContract: project!
    
    override public func viewDidLoad()
    {
        txtNotes.layer.borderColor = UIColor.lightGray.cgColor
        txtNotes.layer.borderWidth = 0.5
        txtNotes.layer.cornerRadius = 5.0
        txtNotes.layer.masksToBounds = true
        txtNotes.delegate = self

        switchActive.isOn = false
        
        hideFields()
        
        if selectedClient != nil
        {
            refreshScreen()
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
            case tblContracts:
                if contractsList == nil
                {
                    tblContracts.isHidden = true
                    return 0
                }
                else
                {
                    tblContracts.isHidden = false
                    return contractsList.projects.count
                }

            default:
                return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblContracts:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellContract", for: indexPath) as! twoLabelTable
                
                if contractsList.projects[indexPath.row].projectStatus == archivedProjectStatus
                {
                    cell.lbl1.text = "Archived -  \(contractsList.projects[indexPath.row].projectName)"
                }
                else
                {
                    cell.lbl1.text = contractsList.projects[indexPath.row].projectName
                }
                cell.lbl2.text = contractsList.projects[indexPath.row].type
                
                return cell

            default:
                return UITableViewCell()
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView
        {
            case tblContracts:
                let myOptions: UIAlertController = UIAlertController(title: "Select Action", message: "Select action to take", preferredStyle: .actionSheet)
                
                if contractsList.projects[indexPath.row].projectStatus != archivedProjectStatus
                {
                    let myOption2a = UIAlertAction(title: "Archive", style: .default, handler: { (action: UIAlertAction) -> () in
                        self.contractsList.projects[indexPath.row].projectStatus = archivedProjectStatus
                    })
                    myOptions.addAction(myOption2a)
                    
//                    let myOption2b = UIAlertAction(title: "Edit", style: .default, handler: { (action: UIAlertAction) -> () in
//                        
//                        let contractEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
//                        contractEditViewControl.communicationDelegate = self
//                        contractEditViewControl.workingContract = self.contractsList.projects[indexPath.row]
//                        contractEditViewControl.displayBackButton = true
//                        self.present(contractEditViewControl, animated: true, completion: nil)
//                    })
//                    myOptions.addAction(myOption2b)
                }
                else
                {
                    let myOption2a = UIAlertAction(title: "Re-Activate", style: .default, handler: { (action: UIAlertAction) -> () in
                        self.contractsList.projects[indexPath.row].projectStatus = "Initiation"
                    })
                    myOptions.addAction(myOption2a)
                }
                
                myOptions.popoverPresentationController!.sourceView = tblContracts
                
                self.present(myOptions, animated: true, completion: nil)
            
            default:
                let _ = 1
        }
    }
    
    @IBAction func btnShowComms(_ sender: UIButton) {
        let commsView = settingsStoryboard.instantiateViewController(withIdentifier: "commsList") as! commsListViewController
        commsView.modalPresentationStyle = .popover
        
        let popover = commsView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        commsView.preferredContentSize = CGSize(width: 800,height: 800)
        commsView.passedClient = selectedClient
        self.present(commsView, animated: true, completion: nil)
    }
    
    @IBAction func btnAddEvent(_ sender: UIButton) {
        var newProject : project? = nil
        
        let alert = UIAlertController(title: "Event Name", message: "What is the name of your event", preferredStyle: UIAlertController.Style.alert)
        
        let action = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            
            if textField.text! != ""
            {
                newProject = project(teamID: currentUser.currentTeam!.teamID, clientID: self.selectedClient.clientID, projectType: eventProjectType, projectName: textField.text!)
                
                self.contractsList.append(newProject!)
                
                self.tblContracts.reloadData()
            }
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = ""
        }
        
        alert.addAction(action)
        
        
        let cancelOption = UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction) -> () in
            let _ = 1
        })
        
        alert.addAction(cancelOption)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func switchArchived(_ sender: UISwitch) {
        refreshScreen()
    }
    
    @IBAction func btnAddComms(_ sender: UIButton)
    {
//        let newComm = commsLogEntry(teamID: (currentUser.currentTeam?.teamID)!)
//        newComm.clientID = selectedClient.clientID
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
    
    @IBAction func btnContact(_ sender: UIButton)
    {
        let peopleEditViewControl = personStoryboard.instantiateViewController(withIdentifier: "personForm") as! personViewController
        peopleEditViewControl.clientID = selectedClient.clientID
        self.present(peopleEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnAddContract(_ sender: UIButton)
    {
        var newProject : project? = nil
        
        let alert = UIAlertController(title: "Project Name", message: "What is the name of your project", preferredStyle: UIAlertController.Style.alert)
        
        let action = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            
            if textField.text! != ""
            {
                newProject = project(teamID: currentUser.currentTeam!.teamID, clientID: self.selectedClient.clientID, projectType: regularProjectType, projectName: textField.text!)
                
                self.contractsList.append(newProject!)
                
                self.tblContracts.reloadData()
            }
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = ""
        }
        
        alert.addAction(action)
        
        
        let cancelOption = UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction) -> () in
            let _ = 1
        })
        
        alert.addAction(cancelOption)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnAdd(_ sender: UIButton)
    {
//        let rateMaintenanceEditViewControl = clientsStoryboard.instantiateViewController(withIdentifier: "ratesView") as! ratesViewController
//        rateMaintenanceEditViewControl.passedClient = selectedClient
//        rateMaintenanceEditViewControl.modalPresentationStyle = .popover
//        
//        let popover = rateMaintenanceEditViewControl.popoverPresentationController!
//        popover.delegate = self
//        popover.sourceView = sender
//        popover.sourceRect = sender.bounds
//        popover.permittedArrowDirections = .any
//        
//        rateMaintenanceEditViewControl.preferredContentSize = CGSize(width: 800,height: 800)
//        
//        self.present(rateMaintenanceEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func txtName(_ sender: UITextField)
    {
        if txtName.text != ""
        {
            selectedClient.name = txtName.text!
            
            currentUser.currentTeam?.clients = nil
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView == txtNotes
        {
            selectedClient.note = txtNotes.text!
        }
    }
    
    @IBAction func switchActive(_ sender: UISwitch) {
        selectedClient.isActive = sender.isOn
    }
    
    func hideFields()
    {
        txtName.isHidden = true
        txtNotes.isHidden = true
        btnAddContract.isHidden = true
        btnContact.isHidden = true
        lblContracts.isHidden = true
        lblContact.isHidden = true
        lblNote.isHidden = true
        lblName.isHidden = true
        btnAdd.isHidden = true
        btnAddComms.isHidden = true
        switchActive.isHidden = true
        lblActive.isHidden = true
        
        if currentUser.checkWritePermission(pmRoleType) || currentUser.checkWritePermission(salesRoleType)
        {
            btnAdd.isEnabled = true
            btnAddContract.isEnabled = true
        }
        else
        {
            btnAdd.isEnabled = false
            btnAddContract.isEnabled = false
        }
    }
    
    func showFields()
    {
        txtName.isHidden = false
        txtNotes.isHidden = false
        btnAddContract.isHidden = false
 //       btnContact.isHidden = false
        lblContracts.isHidden = false
 //       lblContact.isHidden = false
        lblNote.isHidden = false
        lblName.isHidden = false
        btnAdd.isHidden = false
        btnAddComms.isHidden = false
        switchActive.isHidden = false
        lblActive.isHidden = false
        
        if currentUser.checkWritePermission(salesRoleType)
        {
            btnAdd.isEnabled = true
            btnAddContract.isEnabled = true
            btnAddEvent.isEnabled = true
        }
        else
        {
            btnAdd.isEnabled = false
            btnAddContract.isEnabled = false
            btnAddEvent.isEnabled = false
        }
    }
    
    public func refreshScreen()
    {
        if selectedClient == nil
        {
            txtName.text = ""
            txtNotes.text = ""
            btnAdd.isHidden = true
            switchActive.isHidden = true
        }
        else
        {
            contractsList = projects(clientID: selectedClient.clientID, teamID: currentUser.currentTeam!.teamID, isActive: !switchArchived.isOn)
            tblContracts.reloadData()

            txtName.text = selectedClient.name
            txtNotes.text = selectedClient.note
            switchActive.isOn = selectedClient.isActive
            
            showFields()
            
            if selectedClient.name == ""
            {
                btnAdd.isHidden = true
            }
            else
            {
                btnAdd.isHidden = false
            }
        }
    }
}
