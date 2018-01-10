//
//  dateTimePickerViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 14/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import UIKit

class dateTimePickerView: UIViewController
{
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var currentDate: Date!
    var source: String?
    var delegate: MyPickerDelegate?
    var showTimes: Bool = true
    var showDates: Bool = true
    var minutesInterval: Int = 1
    var minimumDate: Date!
    var maximumDate: Date!
    var display24Hour: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
   //     datePicker.minimumDate = Date()
     
        if showTimes
        {
            if showDates
            {
                datePicker.datePickerMode = .dateAndTime
            }
            else
            {
                datePicker.datePickerMode = .time
            }
        }
        else
        {
            datePicker.datePickerMode = .date
        }
        
        datePicker.minuteInterval = minutesInterval
        
        if minimumDate != nil
        {
            datePicker.minimumDate = minimumDate
        }
        
        if maximumDate != nil
        {
            datePicker.maximumDate = maximumDate
        }
        
        if currentDate != nil
        {
            datePicker.date = currentDate
        }
        else
        {
            datePicker.date = Date()
        }
        
        if display24Hour
        {
            datePicker.locale = Locale(identifier: "en_GB")
        }
        
   //     btnSelect.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        delegate!.myPickerDidFinish!(source!, selectedDate: datePicker.date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func datePicker(_ sender: UIDatePicker)
    {
        let _ = 1
    }
}
