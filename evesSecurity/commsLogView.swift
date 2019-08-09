//
//  commsLogView.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 14/4/18.
//  Copyright © 2018 Garry Eves. All rights reserved.
//

import UIKit

public class commsLogView: UIViewController, UIPopoverPresentationControllerDelegate, MyPickerDelegate, UITextViewDelegate
{
    @IBOutlet weak var btnType: UIButton!
    @IBOutlet weak var btnPerson: UIButton!
    @IBOutlet weak var btnClient: UIButton!
    @IBOutlet weak var btnProject: UIButton!
    @IBOutlet weak var txtSummary: UITextField!
    @IBOutlet weak var txtNotes: UITextView!
    
    public var workingEntry: commsLogEntry!
    var leadPeopleList: [leadPerson]!
    
    fileprivate var displayList: [String] = Array()
    
    override public func viewDidLoad()
    {
        if workingEntry != nil
        {
            if workingEntry.clientID == 0
            {
                btnClient.setTitle("Select", for: .normal)
            }
            else
            {
                let temp = client(clientID: workingEntry.clientID, teamID: (currentUser.currentTeam?.teamID)!)
                
                if temp.clientID != workingEntry.clientID
                {
                    btnClient.setTitle("Select", for: .normal)
                }
                else
                {
                   btnClient.setTitle(temp.name, for: .normal)
                }
            }
            
            if workingEntry.projectID == 0
            {
                btnProject.setTitle("Select", for: .normal)
            }
            else
            {
                let temp = project(projectID: workingEntry.projectID, teamID: (currentUser.currentTeam?.teamID)!)
                
                if temp.projectID != workingEntry.projectID
                {
                    btnProject.setTitle("Select", for: .normal)
                }
                else
                {
                    btnProject.setTitle(temp.projectName, for: .normal)
                }
            }
            
            if workingEntry.personID == 0
            {
                btnPerson.setTitle("Select", for: .normal)
            }
            else
            {
                let temp = person(personID: workingEntry.personID, teamID: (currentUser.currentTeam?.teamID)!)
                
                if temp.personID != workingEntry.personID
                {
                    btnPerson.setTitle("Select", for: .normal)
                }
                else
                {
                    btnPerson.setTitle(temp.name, for: .normal)
                }
            }
            
            txtSummary.text = workingEntry.summary
            txtNotes.text = workingEntry.notes
            
            if workingEntry.clientID == 0 && workingEntry.personID == 0  && workingEntry.projectID == 0
            {
                txtSummary.isEnabled = false
                txtNotes.isEditable = false
            }
            
            if workingEntry.type == ""
            {
                btnType.setTitle("Select", for: .normal)
                btnPerson.isEnabled = false
                btnClient.isEnabled = false
                btnProject.isEnabled = false
                txtSummary.isEnabled = false
                txtNotes.isEditable = false
            }
            else
            {
                btnType.setTitle(workingEntry.type, for: .normal)
            }
        }
        else
        {
            btnType.setTitle("Select", for: .normal)
            btnPerson.setTitle("Select", for: .normal)
            btnClient.setTitle("Select", for: .normal)
            btnProject.setTitle("Select", for: .normal)
            
            btnPerson.isEnabled = false
            btnClient.isEnabled = false
            btnProject.isEnabled = false
            txtSummary.isEnabled = false
            txtNotes.isEditable = false
        }

        txtNotes.layer.borderColor = UIColor.lightGray.cgColor
        txtNotes.layer.borderWidth = 0.5
        txtNotes.layer.cornerRadius = 5.0
        txtNotes.layer.masksToBounds = true
        txtNotes.delegate = self
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        switch source
        {
            case "type":
                if selectedItem >= 0
                {
                    workingEntry.type = displayList[selectedItem]
                    
                    btnType.setTitle(displayList[selectedItem], for: .normal)

                    btnPerson.isEnabled = true
                    btnClient.isEnabled = true
                    
                    if workingEntry.projectID == 0
                    {
                        btnProject.isEnabled = false
                    }
                    else
                    {
                        let temp = project(projectID: workingEntry.projectID, teamID: (currentUser.currentTeam?.teamID)!)
                        
                        if temp.projectID != workingEntry.projectID
                        {
                            btnProject.isEnabled = false
                        }
                        else
                        {
                            btnProject.isEnabled = true
                        }
                    }
                    
                    if workingEntry.clientID > 0
                    {
                        btnProject.isEnabled = true
                    }
                    
                    if workingEntry.clientID > 0 || workingEntry.personID > 0
                    {
                        txtNotes.isEditable = true
                        txtSummary.isEnabled = true
                    }
                }
            
            case "client":
                if selectedItem >= 0
                {
                    workingEntry.clientID = clients(teamID: currentUser.currentTeam!.teamID, isActive: true).clients[selectedItem - 1].clientID
                    
                    btnClient.setTitle(displayList[selectedItem], for: .normal)
                    
                    btnProject.isEnabled = true
                    txtSummary.isEnabled = true
                    txtNotes.isEditable = true
                }
            
            case "person":
                if selectedItem >= 0
                {
                    workingEntry.personID = people(teamID: currentUser.currentTeam!.teamID, isActive: true).people[selectedItem - 1].personID
                    
                    btnPerson.setTitle(displayList[selectedItem], for: .normal)
                    txtSummary.isEnabled = true
                    txtNotes.isEditable = true
                }
            
            case "project":
                if selectedItem >= 0
                {
                    workingEntry.projectID = projects(clientID: workingEntry.clientID, teamID: currentUser.currentTeam!.teamID, isActive: true).projects[selectedItem - 1].projectID
                    
                    btnProject.setTitle(displayList[selectedItem], for: .normal)
                    txtSummary.isEnabled = true
                    txtNotes.isEditable = true
                }
            
            default:
                print("commsLogView - myPickerDidFinish - hit default")
        }
    }
    
    
    func topMostController() -> UIViewController {
        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
    
    
    @IBAction func btnType(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("")
        
        var dropDownList: [String] = Array()
        
        dropDownList = (currentUser.currentTeam?.getDropDown(dropDownType: "Communication Log"))!
        
        if dropDownList.count == 0
        {
            currentUser.currentTeam?.populateCommsLogDropDowns()
            dropDownList = (currentUser.currentTeam?.getDropDown(dropDownType: "Communication Log"))!
        }
        
        for myItem in dropDownList
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
            
            pickerView.source = "type"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 400,height: 400)
            pickerView.currentValue = btnType.currentTitle!
            
            topMostController().present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnPerson(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("")
        
        if leadPeopleList != nil
        {
            for item in leadPeopleList
            {
                let temp = person(personID: item.personid, teamID: currentUser.currentTeam!.teamID)
                
                if temp.name != ""
                {
                    displayList.append(temp.name)
                }
            }
        }
        else
        {
            for myItem in people(teamID: currentUser.currentTeam!.teamID, isActive: true).people
            {
                displayList.append(myItem.name)
            }
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
            
            pickerView.source = "person"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 400,height: 400)
            pickerView.currentValue = btnPerson.currentTitle!
            
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnClient(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("")
        
        for myItem in clients(teamID: (currentUser.currentTeam?.teamID)!, isActive: true).clients
        {
            displayList.append(myItem.name)
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
            
            pickerView.source = "client"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 400,height: 400)
            pickerView.currentValue = btnClient.currentTitle!
            
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnProject(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("")
        
        if workingEntry.clientID != 0
        {
            for myItem in projects(clientID: workingEntry.clientID, teamID: (currentUser.currentTeam?.teamID)!, isActive: true).projects
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
                pickerView.currentValue = btnProject.currentTitle!
                
                self.present(pickerView, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func txtSummary(_ sender: UITextField)
    {
        workingEntry.summary = txtSummary.text!
        workingEntry.save()
    }
    
    public func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView == txtNotes
        {
            workingEntry.notes = txtNotes.text!
            workingEntry.save()
        }
    }
}
