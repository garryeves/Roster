//
//  addressesViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 16/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

//
//  newUserViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 12/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

public class addressesViewController: UIViewController
{
    @IBOutlet weak var lblSreet1: UILabel!
    @IBOutlet weak var lblStreet2: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblState: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblPostcode: UILabel!
    @IBOutlet weak var txtStreet1: UITextField!
    @IBOutlet weak var txtStreet2: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtState: UITextField!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var txtPostcode: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    
    var workingPerson: person!
    var workingClient: client!
    var workingProject: project!
    var delegate: MyPickerDelegate!
    
    private var displayList: [String] = Array()
    var workingAddress: address!
    var addressType: String!
    
    override public func viewDidLoad()
    {
        displayItem()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSave(_ sender: UIButton)
    {
        if workingAddress == nil
        {
            workingAddress = address(teamID: workingPerson.teamID, addressType: addressType, personID: workingPerson.personID)
          //  workingAddress.addressType = addressType
          //  workingAddress.personID = workingPerson.personID
            sleep(1)
        }
        workingAddress.addressLine1 = txtStreet1.text!
        workingAddress.addressLine2 = txtStreet2.text!
        workingAddress.city = txtCity.text!
        workingAddress.state = txtState.text!
        workingAddress.country = txtCountry.text!
        workingAddress.postcode = txtPostcode.text!
        workingAddress.save()
        workingPerson.loadAddresses()
        delegate.refreshScreen!()
    }
    
    func displayItem()
    {
        if workingAddress != nil
        {
            txtStreet1.text = workingAddress.addressLine1
            txtStreet2.text = workingAddress.addressLine2
            txtCity.text = workingAddress.city
            txtState.text = workingAddress.state
            txtCountry.text = workingAddress.country
            txtPostcode.text = workingAddress.postcode
        }
    }
    
    func hideFields()
    {
        lblSreet1.isHidden = true
        lblStreet2.isHidden = true
        lblCity.isHidden = true
        lblState.isHidden = true
        lblCountry.isHidden = true
        lblPostcode.isHidden = true
        txtStreet1.isHidden = true
        txtStreet2.isHidden = true
        txtCity.isHidden = true
        txtState.isHidden = true
        txtCountry.isHidden = true
        txtPostcode.isHidden = true
        btnSave.isHidden = true
    }
    
    func showFields()
    {
        lblSreet1.isHidden = false
        lblStreet2.isHidden = false
        lblCity.isHidden = false
        lblState.isHidden = false
        lblCountry.isHidden = false
        lblPostcode.isHidden = false
        txtStreet1.isHidden = false
        txtStreet2.isHidden = false
        txtCity.isHidden = false
        txtState.isHidden = false
        txtCountry.isHidden = false
        txtPostcode.isHidden = false
        btnSave.isHidden = false
    }
}

