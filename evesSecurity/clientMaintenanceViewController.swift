//
//  clientMaintenanceViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 19/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class clientMaintenanceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, myCommunicationDelegate, UIPopoverPresentationControllerDelegate, UITextViewDelegate
{
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var tblContracts: UITableView!
    @IBOutlet weak var btnAddContract: UIButton!
    @IBOutlet weak var btnContact: UIButton!
    @IBOutlet weak var tblClients: UITableView!
    @IBOutlet weak var lblContracts: UILabel!
    @IBOutlet weak var lblContact: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var tblRates: UITableView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var lblRates: UILabel!
    @IBOutlet weak var lblRateName: UILabel!
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var lblStaff: UILabel!
    @IBOutlet weak var lblClient: UILabel!
    @IBOutlet weak var lblGP: UILabel!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var btnAddClient: UIBarButtonItem!
    
    var communicationDelegate: myCommunicationDelegate?
    
    fileprivate var clientList: clients!
    fileprivate var contractsList: projects!
    var selectedClient: client!
    fileprivate var selectedContract: project!
    fileprivate var ratesList: rates!
    
    override func viewDidLoad()
    {
        txtNotes.layer.borderColor = UIColor.lightGray.cgColor
        txtNotes.layer.borderWidth = 0.5
        txtNotes.layer.cornerRadius = 5.0
        txtNotes.layer.masksToBounds = true
        txtNotes.delegate = self
        
        hideFields()
        refreshScreen()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView
        {
            case tblClients:
                if clientList == nil
                {
                    return 0
                }
                else
                {
                    return clientList.clients.count
                }
            
            case tblContracts:
                if contractsList == nil
                {
                    return 0
                }
                else
                {
                    return contractsList.projects.count
                }
            
            case tblRates:
                if ratesList == nil
                {
                    return 0
                }
                else
                {
                    return ratesList.rates.count
                }
            
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblClients:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellClients", for: indexPath) as! oneLabelTable
        
                cell.lbl1.text = clientList.clients[indexPath.row].name
                
                return cell
                
            case tblContracts:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellContract", for: indexPath) as! oneLabelTable
                
                cell.lbl1.text = contractsList.projects[indexPath.row].projectName
            
                return cell
            
            case tblRates:
                // if rate has a shift them do not allow iot to be removed, unenable button
                
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellRates", for: indexPath) as! ratesListItem
                
                cell.lblName.text = ratesList.rates[indexPath.row].rateName
                cell.lblClient.text = ratesList.rates[indexPath.row].chargeAmount.formatCurrency
                cell.lblStaff.text = ratesList.rates[indexPath.row].rateAmount.formatCurrency
                cell.lblStart.text = ratesList.rates[indexPath.row].displayStartDate
                
                // Calculate GP%
                
                let GP = ((ratesList.rates[indexPath.row].chargeAmount - ratesList.rates[indexPath.row].rateAmount) / ratesList.rates[indexPath.row].chargeAmount) * 100
                
                cell.lblGP.text = String(format: "%.1f", GP)
                
            return cell

            default:
                return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView
        {
            case tblClients:
                selectedClient = clientList.clients[indexPath.row]
                refreshScreen()
                
            case tblContracts:
                selectedContract = contractsList.projects[indexPath.row]
                let contractEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
                contractEditViewControl.communicationDelegate = self
                contractEditViewControl.workingContract = selectedContract
                self.present(contractEditViewControl, animated: true, completion: nil)
            
            case tblRates:
                let rateMaintenanceEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "rateMaintenance") as! rateMaintenanceViewController
                rateMaintenanceEditViewControl.communicationDelegate = self
                rateMaintenanceEditViewControl.workingRate = ratesList.rates[indexPath.row]
                rateMaintenanceEditViewControl.modalPresentationStyle = .popover
                
                let popover = rateMaintenanceEditViewControl.popoverPresentationController!
                popover.delegate = self
                popover.sourceView = tableView
                popover.sourceRect = tableView.bounds
                popover.permittedArrowDirections = .any
                
                rateMaintenanceEditViewControl.preferredContentSize = CGSize(width: 500,height: 200)
                
                self.present(rateMaintenanceEditViewControl, animated: true, completion: nil)

            default:
                let _ = 1
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            if tableView == tblRates
            {
                ratesList.rates[indexPath.row].delete()
                ratesList = rates(clientID: selectedClient.clientID, teamID: currentUser.currentTeam!.teamID)
                tblRates.reloadData()
            }
            else if tableView == tblClients
            {
                clientList.clients[indexPath.row].delete()
                refreshScreen()
            }
            else if tableView == tblContracts
            {
                contractsList.projects[indexPath.row].delete()
                contractsList = projects(clientID: selectedClient.clientID, teamID: currentUser.currentTeam!.teamID)
                tblContracts.reloadData()
            }
        }
    }

    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        if txtName.isFirstResponder
        {
            if txtName.text != ""
            {
                selectedClient.name = txtName.text!
            }
        }
        
        if txtNotes.isFirstResponder
        {
            selectedClient.note = txtNotes.text!
        }

        self.dismiss(animated: true, completion: nil)
        communicationDelegate?.refreshScreen!()
    }
    
    @IBAction func btnContact(_ sender: UIButton)
    {
        let peopleEditViewControl = personStoryboard.instantiateViewController(withIdentifier: "personForm") as! personViewController
        peopleEditViewControl.clientID = selectedClient.clientID
        self.present(peopleEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnAddContract(_ sender: UIButton)
    {
        let newProject = project(teamID: currentUser.currentTeam!.teamID)
        newProject.clientID = selectedClient.clientID
        newProject.save()
        
        let contractEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
        contractEditViewControl.communicationDelegate = self
        contractEditViewControl.workingContract = newProject
        self.present(contractEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnAddClient(_ sender: UIBarButtonItem)
    {
        selectedClient = client(teamID: currentUser.currentTeam!.teamID)
        showFields()
        refreshScreen()
    }
    
    @IBAction func btnAdd(_ sender: UIButton)
    {
        let tempRate = rate(clientID: selectedClient.clientID, teamID: currentUser.currentTeam!.teamID)
        
        let rateMaintenanceEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "rateMaintenance") as! rateMaintenanceViewController
        rateMaintenanceEditViewControl.communicationDelegate = self
        rateMaintenanceEditViewControl.workingRate = tempRate
        rateMaintenanceEditViewControl.modalPresentationStyle = .popover
        
        let popover = rateMaintenanceEditViewControl.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        rateMaintenanceEditViewControl.preferredContentSize = CGSize(width: 500,height: 200)
        
        self.present(rateMaintenanceEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func txtName(_ sender: UITextField)
    {
        if txtName.text != ""
        {
            selectedClient.name = txtName.text!
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView == txtNotes
        {
            selectedClient.note = txtNotes.text!
        }
    }
    
    func hideFields()
    {
        txtName.isHidden = true
        txtNotes.isHidden = true
        tblContracts.isHidden = true
        btnAddContract.isHidden = true
        btnContact.isHidden = true
        lblContracts.isHidden = true
        lblContact.isHidden = true
        lblNote.isHidden = true
        lblName.isHidden = true
        tblRates.isHidden = true
        btnAdd.isHidden = true
        lblRates.isHidden = true
        lblRateName.isHidden = true
        lblStart.isHidden = true
        lblStaff.isHidden = true
        lblClient.isHidden = true
        lblGP.isHidden = true
        if currentUser.checkPermission(pmRoleType) == writePermission || currentUser.checkPermission(salesRoleType) == writePermission
        {
            btnAdd.isEnabled = true
            btnAddClient.isEnabled = true
            btnAddContract.isEnabled = true
        }
        else
        {
            btnAdd.isEnabled = false
            btnAddClient.isEnabled = false
            btnAddContract.isEnabled = false
        }
    }
    
    func showFields()
    {
        txtName.isHidden = false
        txtNotes.isHidden = false
        tblContracts.isHidden = false
        btnAddContract.isHidden = false
        btnContact.isHidden = false
        lblContracts.isHidden = false
        lblContact.isHidden = false
        lblNote.isHidden = false
        lblName.isHidden = false
        tblRates.isHidden = false
        btnAdd.isHidden = false
        lblRates.isHidden = false
        lblRateName.isHidden = false
        lblStart.isHidden = false
        lblStaff.isHidden = false
        lblClient.isHidden = false
        lblGP.isHidden = false
        if currentUser.checkPermission(pmRoleType) == writePermission || currentUser.checkPermission(salesRoleType) == writePermission
        {
            btnAdd.isEnabled = true
            btnAddClient.isEnabled = true
            btnAddContract.isEnabled = true
        }
        else
        {
            btnAdd.isEnabled = false
            btnAddClient.isEnabled = false
            btnAddContract.isEnabled = false
        }
    }
    
    func refreshScreen()
    {
        clientList = clients(teamID: currentUser.currentTeam!.teamID)
        tblClients.reloadData()

        if selectedClient == nil
        {
            txtName.text = ""
            txtNotes.text = ""
            tblRates.isHidden = true
            lblRates.isHidden = true
            lblRateName.isHidden = true
            lblStart.isHidden = true
            lblStaff.isHidden = true
            lblClient.isHidden = true
            lblGP.isHidden = true
            btnAdd.isHidden = true
        }
        else
        {
            contractsList = projects(clientID: selectedClient.clientID, teamID: currentUser.currentTeam!.teamID)
            tblContracts.reloadData()

            txtName.text = selectedClient.name
            txtNotes.text = selectedClient.note
            
            ratesList = rates(clientID: selectedClient.clientID, teamID: currentUser.currentTeam!.teamID)
            
            showFields()
            
            if selectedClient.name == ""
            {
                tblRates.isHidden = true
                lblRates.isHidden = true
                lblRateName.isHidden = true
                lblStart.isHidden = true
                lblStaff.isHidden = true
                lblClient.isHidden = true
                lblGP.isHidden = true
                btnAdd.isHidden = true
            }
            else
            {
                tblRates.isHidden = false
                lblRates.isHidden = false
                lblRateName.isHidden = false
                lblStart.isHidden = false
                lblStaff.isHidden = false
                lblClient.isHidden = false
                lblGP.isHidden = false
                btnAdd.isHidden = false
                
                tblRates.reloadData()
            }
        }
    }
}

class ratesListItem: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var lblStaff: UILabel!
    @IBOutlet weak var lblClient: UILabel!
    @IBOutlet weak var lblGP: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

