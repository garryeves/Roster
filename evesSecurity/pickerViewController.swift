//
//  pickerViewController.swift
//  GroupFitness
//
//  Created by Garry Eves on 12/03/2016.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import Foundation

import UIKit

@objc public protocol MyPickerDelegate
{
    @objc optional func myPickerDidFinish(_ source: String, selectedItem:Int)
    @objc optional func myPickerDidFinish(_ source: String, selectedDouble:Double)
    @objc optional func myPickerDidFinish(_ source: String, selectedString:String)
    @objc optional func myPickerDidFinish(_ source: String, selectedDate:Date)
    @objc optional func myPickerDidFinish(_ source: String)
    @objc optional func refreshScreen()
    @objc optional func shiftDeleted(projectID: Int64, shiftLineID: Int64, weekEndDate: Date, workDate: Date, teamID: Int64)
}

public class PickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    @IBOutlet weak var myPicker: UIPickerView!
    
    public var pickerValues: [String]?
    public var source: String?
    public var currentValue: String?
    public var delegate: MyPickerDelegate?
    
    private var selectedRow: Int = 0
    private var maxLines: CGFloat = 0.0
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
                
        // work out the size of the rows
        
        var recordCount: Int = 0
        
        for myItem in pickerValues!
        {
            let textArr = myItem.components(separatedBy: "\n")
            
            if currentValue == myItem
            {
                selectedRow = recordCount
            }
            
            recordCount += 1
            
            var numLinesInt = textArr.count
            
            if numLinesInt < 1
            {
                numLinesInt = 1
            }
            
            let numLines = CGFloat(numLinesInt)
            
            if numLines > maxLines
            {
                maxLines = numLines
            }
        }
        
        myPicker.selectRow(selectedRow, inComponent: 0, animated: true)
    }
    
    override public func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        delegate!.myPickerDidFinish!(source!, selectedItem: selectedRow)
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
        return pickerValues!.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return pickerValues![row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedRow = row
    }
    
//    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
//    {
//        var label : UILabel
//
//        // Work out how many lines are in the incoming string, and use this to calulcate the size of the row
//
//        let textArr = pickerValues![row].components(separatedBy: "\n")
//
//        var numLinesInt = textArr.count
//
//        if numLinesInt < 1
//        {
//            numLinesInt = 1
//        }
//
//        let numLines = CGFloat(numLinesInt)
//
//        if view == nil
//        {
//            label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: UIFont.systemFont(ofSize: UIFont.systemFontSize).lineHeight * numLines * UIScreen.main.scale))
//            label.textAlignment = NSTextAlignment.center
//            if numLinesInt > 1
//            {
//                label.numberOfLines = numLinesInt
//                label.lineBreakMode = NSLineBreakMode.byWordWrapping
//                label.autoresizingMask = UIViewAutoresizing.flexibleWidth
//            }
//        }
//        else
//        {
//            label = view as! UILabel
//        }
//
//        label.text = pickerValues![row]
//
//        return label
//    }
    
//    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
//    {
//        return UIFont.systemFont(ofSize: UIFont.systemFontSize).lineHeight * maxLines * UIScreen.main.scale
//    }
}
