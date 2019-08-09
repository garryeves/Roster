//
//  addPerInfoMaintenanceViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 18/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

public class addPerInfoMaintenanceViewController: UIViewController, UIPopoverPresentationControllerDelegate, MyPickerDelegate, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var btnType: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var tblInfo: UITableView!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    
    fileprivate var addInfoRecords: personAdditionalInfos!
    
    fileprivate var displayList: [String] = Array()
    
    override public func viewDidLoad()
    {
        addInfoRecords = personAdditionalInfos(teamID: currentUser!.currentTeam!.teamID)
        btnType.setTitle("Select", for: .normal)
        
        btnSave.isHidden = true
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 //   addInfoCell
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return addInfoRecords.personAdditionalInfos.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier:"addInfoCell", for: indexPath) as! personAddInfoItem
        
        cell.lblDescription.text = addInfoRecords.personAdditionalInfos[indexPath.row].addInfoName
        cell.lblType.text = addInfoRecords.personAdditionalInfos[indexPath.row].addInfoType
        cell.addInfoID = addInfoRecords.personAdditionalInfos[indexPath.row].addInfoID

        return cell
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        if tableView == tblInfo
        {
            return UITableViewCell.EditingStyle.delete
        }
        return UITableViewCell.EditingStyle.none
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if tableView == tblInfo
        {
            if editingStyle == .delete
            {
                addInfoRecords.personAdditionalInfos[indexPath.row].delete()
                addInfoRecords = personAdditionalInfos(teamID: currentUser!.currentTeam!.teamID)
                tblInfo.reloadData()
            }
        }
    }
    
    public func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "choices"
        {
            if selectedItem >= 0
            {
                btnType.setTitle(displayList[selectedItem], for: .normal)
            
                btnSave.isHidden = false
            }
        }
    }
    
    @IBAction func btnType(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append(perInfoText)
        displayList.append(perInfoDate)
        displayList.append(perInfoYesNo)
        
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
            
            pickerView.source = "choices"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = btnType.currentTitle!
            
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnSave(_ sender: UIButton)
    {
        if txtDescription.text! != ""
        {
            let workingItem = personAdditionalInfo(teamID: currentUser.currentTeam!.teamID)
            workingItem.addInfoName = txtDescription.text!
            workingItem.addInfoType = btnType.currentTitle!
            
            workingItem.save()
            
            addInfoRecords = personAdditionalInfos(teamID: currentUser!.currentTeam!.teamID)

            tblInfo.reloadData()
            
            txtDescription.text = ""
            btnType.setTitle("Select", for: .normal)
            
            btnSave.isHidden = true
        }
    }

    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
}

class personAddInfoItem: UITableViewCell
{
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblType: UILabel!
    
    var addInfoID: Int64!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

