//
//  contactsViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 17/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

public class contactsViewController: UIViewController, MyPickerDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var lblContactType: UILabel!
    @IBOutlet weak var lblDetails: UILabel!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var txtDetails: UITextField!
    
    var workingPerson: person!
    var workingClient: client!
    var workingProject: project!
    
    private var displayList: [String] = Array()
    var workingContact: contactItem!
    
    override public func viewDidLoad()
    {
        if workingPerson.contacts.count > 0
        {
            if workingContact == nil
            {
                workingContact = workingPerson.contacts[0]
            }
            displayItem()
        }
        else
        {
            btnSelect.setTitle("Select", for: .normal)
            hideFields()
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnAddressType(_ sender: UIButton)
    {
        displayList.removeAll()
        
        for myItem in (currentUser.currentTeam?.getDropDown(dropDownType: "Contacts"))!
        {
            displayList.append(myItem)
        }
        
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
            
            pickerView.source = "Contacts"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = sender.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnSave(_ sender: UIButton)
    {
        workingContact.contactValue = txtDetails.text!
        workingContact.contactType = btnSelect.currentTitle!
        workingContact.save()
        workingPerson.loadContacts()
    }
    
    public func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "Contacts"
        {
            // loop through addresses to find matching record.  If none found then create a new address
            var itemFound: Bool = false
            
            for myItem in workingPerson.contacts
            {
                if myItem.contactType == displayList[selectedItem]
                {
                    workingContact = myItem
                    itemFound = true
                    break
                }
            }
            
            if !itemFound
            {
                var tempPerson: Int64 = 0
                var tempClient: Int64 = 0
                var tempProject: Int64 = 0
                
                if workingPerson != nil
                {
                    tempPerson = workingPerson.personID
                }
                if workingClient != nil
                {
                    tempClient = workingClient.clientID
                }
                if workingProject != nil
                {
                    tempProject = workingProject.projectID
                }
                
                workingContact = contactItem(teamID: currentUser.currentTeam!.teamID, contactType: displayList[selectedItem], personID: tempPerson, clientID: tempClient, projectID: tempProject)
            }
            
            displayItem()
            showFields()
        }
    }
    
    func displayItem()
    {
        txtDetails.text = workingContact.contactValue
        btnSelect.setTitle(workingContact.contactType, for: .normal)
    }
    
    func hideFields()
    {
        lblContactType.isHidden = true
        lblDetails.isHidden = true
        btnSave.isHidden = true
        txtDetails.isHidden = true
    }
    
    func showFields()
    {
        lblContactType.isHidden = false
        lblDetails.isHidden = false
        btnSave.isHidden = false
        txtDetails.isHidden = false
    }
}


