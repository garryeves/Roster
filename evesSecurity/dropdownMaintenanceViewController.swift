//
//  dropdownMaintenanceViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 17/6/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

public class dropdownMaintenanceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var tblDropdowns: UITableView!
    @IBOutlet weak var tblValues: UITableView!
    @IBOutlet weak var lblNewValue: UILabel!
    @IBOutlet weak var txtValue: UITextField!
    @IBOutlet weak var btnAdd: UIButton!

    var communicationDelegate: myCommunicationDelegate?

    fileprivate var dropdownList: [String] = Array()
    fileprivate var valueList: dropdowns!
    fileprivate var currentDropdownType: String = ""

    override public func viewDidLoad()
    {
        hideFields()

        // Load the list of dropdown type list

        dropdownList = dropdowns(teamID: currentUser.currentTeam!.teamID).dropDownTypes
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
            case tblDropdowns:
                return dropdownList.count

            case tblValues:
                if valueList == nil
                {
                    return 0
                }
                else
                {
                    return valueList.dropdowns.count
                }

            default:
                return 0
        }
   }
//
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblDropdowns:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellDropdown", for: indexPath) as! oneLabelTable

                cell.lbl1.text = dropdownList[indexPath.row]
                return cell

            case tblValues:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellValue", for: indexPath) as! oneLabelTable

                cell.lbl1.text = valueList.dropdowns[indexPath.row].dropdownValue

                return cell

            default:
                return UITableViewCell()
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView
        {
            case tblDropdowns:
                currentDropdownType = dropdownList[indexPath.row]

                refreshScreen()

            default:
                let _ = 1
        }
    }

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        if tableView == tblValues
        {
            if valueList.dropdowns[indexPath.row].dropdownValue == archivedProjectStatus
            {
                return UITableViewCell.EditingStyle.none
            }
            return UITableViewCell.EditingStyle.delete
        }
        return UITableViewCell.EditingStyle.none
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if tableView == tblValues
        {
            if editingStyle == .delete
            {
                if valueList.dropdowns[indexPath.row].dropdownValue != archivedProjectStatus
                {
                    valueList.dropdowns[indexPath.row].delete()
                    valueList.remove(indexPath.row)
                    tblValues.reloadData()
                }
                else
                {
                    let alert = UIAlertController(title: "Dropdown Maintenance", message:
                        "You can not delete the \(archivedProjectStatus) value.  This is a System Required value.", preferredStyle: .alert)

                    let yesOption = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)

                    alert.addAction(yesOption)
                    self.present(alert, animated: false, completion: nil)
                }
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.row > destinationIndexPath.row
        {
            // Moving from lower down the table
            valueList.dropdowns[sourceIndexPath.row].order = Int64(destinationIndexPath.row + 1)

            var item = destinationIndexPath.row
            
            while item < sourceIndexPath.row
            {
                valueList.dropdowns[item].order = Int64(item + 2)
                
                item += 1
            }
        }
        else if sourceIndexPath.row < destinationIndexPath.row
        {
            // Moving from higher in the table
            valueList.dropdowns[sourceIndexPath.row].order = Int64(destinationIndexPath.row + 1)
            
            var item = sourceIndexPath.row + 1
   
            while item <= destinationIndexPath.row
            {
                valueList.dropdowns[item].order = Int64(item)
                
                item += 1
            }
        }
        
        valueList.sort()
        tableView.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if valueList.dropdowns[indexPath.row].dropdownValue == archivedProjectStatus
        {
            return false
        }
        return true
    }

    @IBAction func txtValue(_ sender: UITextField)
    {
        if txtValue.text! == ""
        {
            btnAdd.isHidden = true
        }
        else
        {
            btnAdd.isHidden = false
        }
    }

    @IBAction func btnAdd(_ sender: UIButton)
    {
        let newItem = dropdownItem(dropdownType: currentDropdownType, dropdownValue: txtValue.text!, teamID: currentUser.currentTeam!.teamID, order: 99, saveRecord: true)

        txtValue.text = ""
        btnAdd.isHidden = true

        valueList.append(newItem)
        tblValues.reloadData()
    }

    public func refreshScreen()
    {
        if currentDropdownType != ""
        {
            valueList = dropdowns(dropdownType: currentDropdownType, teamID: currentUser.currentTeam!.teamID)
            tblValues.reloadData()
            showFields()
            tblValues.isEditing = true
        }
    }

    func showFields()
    {
        tblDropdowns.isHidden = false
        tblValues.isHidden = false
        lblNewValue.isHidden = false
        txtValue.isHidden = false
        if txtValue.text! == ""
        {
            btnAdd.isHidden = true
        }
        else
        {
            btnAdd.isHidden = false
        }
    }

    func hideFields()
    {
        tblDropdowns.isHidden = false
        tblValues.isHidden = true
        lblNewValue.isHidden = true
        txtValue.isHidden = true
        btnAdd.isHidden = true
    }
}
