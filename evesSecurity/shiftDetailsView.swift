//
//  shiftDetailsView.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 6/4/18.
//  Copyright © 2018 Garry Eves. All rights reserved.
//

import UIKit

public class shiftDetailsView: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var dteStart: UIDatePicker!
    @IBOutlet weak var dteEnd: UIDatePicker!
    @IBOutlet weak var pickRate: UIPickerView!
    @IBOutlet weak var pickWho: UIPickerView!
    @IBOutlet weak var btnDelete: UIButton!
    
    var delegate: MyPickerDelegate?
    var currentShift: shift!
    
    private var rateList: rates!
    var peopleList: people!
    
    private var displayRateList: [String] = Array()
    private var displayPeopleList: [String] = Array()
    
    private var currentRateNum: Int = 0
    private var currentPersonNum: Int = 0
    
    private var selectedRow: Int = 0
    private var maxLines: CGFloat = 0.0
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        rateList = rates(clientID: currentShift.clientID, teamID: currentShift.teamID)
    //    peopleList = people(teamID: currentShift.teamID)
        
        dteStart.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        dteEnd.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        if currentShift != nil
        {
            lblDate.text = currentShift.workDateString
            dteStart.date = currentShift.startTime
            dteEnd.date = currentShift.endTime
            
            var loopCount: Int = 1
            
            displayRateList.append("")
            for rat in rateList.rates
            {
                if rat.isActive
                {
                    displayRateList.append(rat.rateName)
                
                    if rat.rateID == currentShift.rateID
                    {
                        currentRateNum = loopCount
                    }
                }
                loopCount += 1
            }
            pickRate.selectRow(currentRateNum, inComponent: 0, animated: true)
            
            loopCount = 1
            displayPeopleList.append("")
            for per in peopleList.people
            {
                displayPeopleList.append(per.name)
                
                if per.personID == currentShift.personID
                {
                    currentPersonNum = loopCount
                }
                loopCount += 1
            }
            pickWho.selectRow(currentPersonNum, inComponent: 0, animated: true)
        }
    }
    
    override public func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
//        delegate!.myPickerDidFinish!(source!, selectedItem: selectedRow)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView
        {
            case pickRate:
                return displayRateList.count
            
            case pickWho:
                return displayPeopleList.count
            
            default:
                return 0
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView
        {
            case pickRate:
                return displayRateList[row]
            
            case pickWho:
                return displayPeopleList[row]
            
            default:
                return ""
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch pickerView
        {
            case pickRate:
                if row == 0
                {
                    currentShift.rateID = 0
                    currentShift.save()
                }
                else
                {
                    currentShift.rateID = rateList.rates[row - 1].rateID
                    currentShift.save()
                }
            
            case pickWho:
                if row == 0
                {
                    currentShift.personID = 0
                    currentShift.save()
                }
                else
                {
                    currentShift.personID = peopleList.people[row - 1].personID
                    currentShift.save()
                }
            
            default:
                print("shiftDetailsView - pickerView - hit default")
        }
        delegate?.refreshScreen!()
    }
    
    @objc func dateChanged(_ sender: UIDatePicker)
    {
        switch sender
        {
            case dteStart:
                currentShift.startTime = sender.date
            currentShift.save()
            
            case dteEnd:
                currentShift.endTime = sender.date
            currentShift.save()
            
            default:
                print("shiftDetailsView - dateChanged - hit default")
        }
        delegate?.refreshScreen!()
    }
    
    @IBAction func btnDelete(_ sender: UIButton)
    {
        currentShift.delete()

        delegate?.shiftDeleted!(projectID: currentShift.projectID, shiftLineID: currentShift.shiftLineID, weekEndDate: currentShift.weekEndDate, workDate: currentShift.workDate, teamID: currentShift.teamID)
        self.dismiss(animated: true)
    }
}
