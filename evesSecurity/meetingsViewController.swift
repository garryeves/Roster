//
//  meetingsViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 7/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import UIKit
import EventKit
//import TextExpander

protocol MyMeetingsDelegate
{
    func myMeetingsDidFinish(_ controller:meetingsViewController)
    func myMeetingsAgendaDidFinish(_ controller:meetingAgendaViewController)
}

protocol meetingCommunicationDelegate
{
    func meetingUpdated()
    func callMeetingAgenda(_ meetingRecord: calendarItem)
    func displayTaskList(_ meetingRecord: calendarItem)
}

public class meetingsViewController: UIViewController, MyMeetingsDelegate, MyPickerDelegate, UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate //, SMTEFillDelegate
{
    private var selectedMeeting: calendarItem!
    var meetingCommunication: meetingCommunicationDelegate!
    var meetingsDelegate: MyMeetingsDelegate!
    var delegate: myCommunicationDelegate!
    var actionType: String!
    var passedMeeting: calendarItem!
    
    @IBOutlet weak var lblLocationHead: UILabel!
    @IBOutlet weak var lblAT: UILabel!
    @IBOutlet weak var lblMeetingName: UILabel!
    @IBOutlet weak var lblChairHead: UILabel!
    @IBOutlet weak var lblMinutesHead: UILabel!
    @IBOutlet weak var lblAttendeesHead: UILabel!
    @IBOutlet weak var btnChair: UIButton!
    @IBOutlet weak var btnMinutes: UIButton!
    @IBOutlet weak var btnAddAttendee: UIButton!
    @IBOutlet weak var btnPreviousMinutes: UIButton!
    @IBOutlet weak var lblPreviousMeeting: UILabel!
    @IBOutlet weak var lblNextMeeting: UILabel!
    @IBOutlet weak var btnNextMeeting: UIButton!
    @IBOutlet weak var btnDisplayPreviousMeeting: UIButton!
    @IBOutlet weak var btnDisplayNextMeeting: UIButton!
    @IBOutlet weak var btnAgenda: UIButton!
    @IBOutlet weak var btnCompleted: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtWhere: UITextField!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var btnEndDate: UIButton!
    @IBOutlet weak var lblMeetingTo: UILabel!
    @IBOutlet weak var btnCreatePerson: UIButton!
    @IBOutlet weak var tblAttendees: UITableView!
    
    fileprivate let reuseAttendeeIdentifier = "AttendeeCell"
    fileprivate let reuseAttendeeStatusIdentifier = "AttendeeStatusCell"
    fileprivate let reuseAttendeeAction = "AttendeeActionCell"
    
    fileprivate var pickerOptions: [String] = Array()
    fileprivate var pickerEventArray: [String] = Array()
    fileprivate var pickerStartDateArray: [Date] = Array()
    fileprivate var pickerTarget: String = ""
    fileprivate var mySelectedRow: Int = 0
    fileprivate var rowToAction: Int = 0

    fileprivate var peopleList: people!
    
//    // Textexpander
//    
//    fileprivate var snippetExpanded: Bool = false
//    
//    var textExpander: SMTEDelegateController!

    override public func viewDidLoad()
    {
        super.viewDidLoad()
        btnCompleted.isHidden = true
        
        if passedMeeting != nil
        {
            selectedMeeting = passedMeeting
            selectedMeeting.loadAttendees()
            displayMeeting()
        }
        else
        {
            selectedMeeting = calendarItem(teamID: (currentUser.currentTeam?.teamID)!)
            showFields()
            
            txtName.becomeFirstResponder()
            btnDate.setTitle("Select Date/Time", for: .normal)
            btnEndDate.setTitle("Select Date/Time", for: .normal)
            btnChair.setTitle("Select Chair", for: .normal)
            btnMinutes.setTitle("Select Minute taker", for: .normal)
        }
        
        notificationCenter.addObserver(self, selector: #selector(self.attendeeRemoved(_:)), name: NotificationAttendeeRemoved, object: nil)
        
//        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
//        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
//        self.view.addGestureRecognizer(showGestureRecognizer)
//        
//        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
//        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
//        self.view.addGestureRecognizer(hideGestureRecognizer)



//        // TextExpander
//        textExpander = SMTEDelegateController()
//        txtAttendeeName.delegate = textExpander
//        txtAttendeeEmail.delegate = textExpander
//        textExpander.clientAppName = "EvesCRM"
//        textExpander.fillCompletionScheme = "EvesCRM-fill-xc"
//        textExpander.fillDelegate = self
//        textExpander.nextDelegate = self
    }
    
    override public func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override public func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        currentUser.currentTeam?.meetingAgendas = myCloudDB.getMeetingAgendas(teamID: (currentUser.currentTeam?.teamID)!)
        
        delegate.refreshScreen!()
    }
    override public func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()

        tblAttendees.reloadData()
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if selectedMeeting == nil
        {
            return 0
        }
        else
        {
            return selectedMeeting.attendees.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell : myAttendeeDisplayItem!
        
        cell = tableView.dequeueReusableCell(withIdentifier: reuseAttendeeIdentifier, for: indexPath as IndexPath) as? myAttendeeDisplayItem
        cell.lblName.text = selectedMeeting.attendees[indexPath.row].name
        cell.lblStatus.text = selectedMeeting.attendees[indexPath.row].status
        if actionType != nil
        {
            if actionType == "Agenda"
            {
                cell.btnAction.setTitle("Remove", for: .normal)
            }
            else
            {
                cell.btnAction.setTitle("Record Attendence", for: .normal)
            }
        }
        
        cell.btnAction.tag = indexPath.row
        
        if (indexPath.row % 2 == 0)  // was .row
        {
            cell.backgroundColor = greenColour
        }
        else
        {
            cell.backgroundColor = UIColor.clear
        }
        
        cell.layoutSubviews()
        
        return cell
    }
    
//    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
//    {
//
//    }
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
//    {
//        if tableView == tblPeople
//        {
//            return UITableViewCellEditingStyle.delete
//        }
//        return UITableViewCellEditingStyle.none
//    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
//    {
//        if editingStyle == .delete
//        {
//            if tableView == tblPeople
//            {
//                myPeople.people[indexPath.row].delete()
//            }
//
//            refreshScreen()
//        }
//    }
    
    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnCreateMeeting(_ sender: UIBarButtonItem)
    {
        selectedMeeting = calendarItem(teamID: (currentUser.currentTeam?.teamID)!)
        
        showFields()
        txtName.becomeFirstResponder()
        btnDate.setTitle("Select Date/Time", for: .normal)
        btnEndDate.setTitle("Select Date/Time", for: .normal)
        btnChair.setTitle("Select Chair", for: .normal)
        btnMinutes.setTitle("Select Minute taker", for: .normal)
    }
    
    @objc func handleSwipe(_ recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizer.Direction.left
        {
           // Move to next item in tab hierarchy
            
            let myCurrentTab = self.tabBarController
            
            myCurrentTab!.selectedIndex = myCurrentTab!.selectedIndex + 1
        }
        else
        {
            if meetingsDelegate != nil
            {
                meetingsDelegate.myMeetingsDidFinish(self)
            }
        }
    }
    
    func displayMeeting()
    {
        showFields()
        selectedMeeting.loadAttendees()
        txtWhere.text = selectedMeeting.location
        txtName.text = selectedMeeting.title
        btnDate.setTitle(selectedMeeting.displayStartDate, for: .normal)
        btnEndDate.setTitle(selectedMeeting.displayEndDate, for: .normal)
        
        //       selectedMeeting.loadAgenda()
        
        if currentUser.currentTeam?.meetingAgendas == nil
        {
            currentUser.currentTeam?.meetingAgendas = myCloudDB.getMeetingAgendas(teamID: (currentUser.currentTeam?.teamID)!)
        }
        
        if selectedMeeting.chair != ""
        {
            btnChair.setTitle(selectedMeeting.chair, for: .normal)
        }
        
        if selectedMeeting.minutes != ""
        {
            btnMinutes.setTitle(selectedMeeting.minutes, for: .normal)
        }
        
        if selectedMeeting.previousMinutes != ""
        {
            // Get the previous meetings details
            
            for myItem in (currentUser.currentTeam?.meetingAgendas)!
            {
                if myItem.meetingID == selectedMeeting.previousMinutes
                {
                    let startDateFormatter = DateFormatter()
                    startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                    let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                    
                    let myDisplayString = "\(myItem.name!) - \(myDisplayDate)"
                    
                    btnPreviousMinutes.setTitle(myDisplayString, for: .normal)
                    break
                }
            }
        }

        if selectedMeeting.nextMeeting != ""
        {
            // Get the previous meetings details
            
            for myItem in (currentUser.currentTeam?.meetingAgendas)!
            {
                if myItem.meetingID == selectedMeeting.nextMeeting
                {
                    let startDateFormatter = DateFormatter()
                    startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                    let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)

                    let myDisplayString = "\(myItem.name!) - \(myDisplayDate)"

                    btnNextMeeting.setTitle(myDisplayString, for: .normal)
                    break
                }
            }
        }
        
        if selectedMeeting.previousMinutes != ""
        {
            btnDisplayPreviousMeeting.isHidden = false
        }
        else
        {
            btnDisplayPreviousMeeting.isHidden = true
        }
        
        if selectedMeeting.nextMeeting != ""
        {
            btnDisplayNextMeeting.isHidden = false
        }
        else
        {
            btnDisplayNextMeeting.isHidden = true
        }
    }
    
    @IBAction func txtName(_ sender: UITextField)
    {
        if sender == txtName
        {
            selectedMeeting.title = txtName.text!
        }
        else if sender == txtWhere
        {
            selectedMeeting.location = txtWhere.text!
        }
    }
    
    @IBAction func btnDate(_ sender: UIButton)
    {
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
        pickerView.modalPresentationStyle = .popover
        //      pickerView.isModalInPopover = true
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "startDate"
        pickerView.minimumDate = Date()
        pickerView.minutesInterval = 5
        pickerView.delegate = self
        
        if selectedMeeting.displayStartDate == ""
        {
            pickerView.currentDate = Date()
        }
        else
        {
            pickerView.currentDate = selectedMeeting.startDate
        }
        
        pickerView.showTimes = true
        
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnEndDate(_ sender: UIButton)
    {
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
        pickerView.modalPresentationStyle = .popover
        //      pickerView.isModalInPopover = true
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "endDate"
        pickerView.minimumDate = selectedMeeting.startDate
        pickerView.minutesInterval = 5
        pickerView.delegate = self
        
        if selectedMeeting.endDate < selectedMeeting.startDate
        {
            pickerView.currentDate = selectedMeeting.startDate
        }
        else
        {
            pickerView.currentDate = selectedMeeting.endDate
        }
//        if selectedMeeting.displayEndDate == ""
//        {
//            if selectedMeeting.displayStartDate == ""
//            {
//                pickerView.currentDate = Date()
//            }
//            else
//            {
//                pickerView.currentDate = selectedMeeting.startDate
//            }
//        }
//        else
//        {
//            pickerView.currentDate = selectedMeeting.endDate
//        }
        
        pickerView.showTimes = true
        
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnChairClick(_ sender: UIButton)
    {
        pickerOptions.removeAll(keepingCapacity: false)
    
        if selectedMeeting.attendees.count > 0
        {
            pickerOptions.append("")
            for attendee in selectedMeeting.attendees
            {
                pickerOptions.append(attendee.name)
            }
       
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "chair"
            pickerView.delegate = self
            pickerView.pickerValues = pickerOptions
            pickerView.preferredContentSize = CGSize(width: 400,height: 400)
            pickerView.currentValue = btnChair.currentTitle!
            
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnMinutes(_ sender: UIButton)
    {
        pickerOptions.removeAll(keepingCapacity: false)
        if selectedMeeting.attendees.count > 0
        {
            pickerOptions.append("")
            for attendee in selectedMeeting.attendees
            {
                pickerOptions.append(attendee.name)
            }
            
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "minutes"
            pickerView.delegate = self
            pickerView.pickerValues = pickerOptions
            pickerView.preferredContentSize = CGSize(width: 400,height: 400)
            pickerView.currentValue = btnMinutes.currentTitle!
            
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnAddAttendee(_ sender: UIButton)
    {
        pickerOptions.append("")
        peopleList = people(teamID: (currentUser.currentTeam?.teamID)!, isActive: true)
        for item in peopleList.people
        {
            pickerOptions.append(item.name)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "attendee"
        pickerView.delegate = self
        pickerView.pickerValues = pickerOptions
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnPreviousMinutes(_ sender: UIButton)
    {
        getPreviousMeeting()
    }
    
    @IBAction func btnNextMeeting(_ sender: UIButton)
    {
        getNextMeeting()
    }
    
    public func myPickerDidFinish(_ source: String, selectedDate:Date)
    {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "dd MMM YY"
        
        switch source
        {
            case "startDate":
                if selectedMeeting == nil
                {
                    btnDate.setTitle("selectedDate", for: .normal)
                }
                else
                {
                    selectedMeeting.startDate = selectedDate
                    btnDate.setTitle(selectedMeeting.displayStartDate, for: .normal)
                }
            
            case "endDate":
                if selectedMeeting == nil
                {
                    btnEndDate.setTitle("selectedDate", for: .normal)
                }
                else
                {
                    selectedMeeting.endDate = selectedDate
                    btnEndDate.setTitle(selectedMeeting.displayEndDate, for: .normal)
            }
            
            default:
                print("meetingViewController - myPickerDidFinish: selectedDate - got default \(source)")
        }
    }
    
    public func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        switch source
        {
            case "chair":
                btnChair.setTitle(pickerOptions[selectedItem], for: .normal)
                selectedMeeting.chair = pickerOptions[selectedItem]
            
            case "minutes":
                btnMinutes.setTitle(pickerOptions[selectedItem], for: .normal)
                selectedMeeting.minutes = pickerOptions[selectedItem]
            
            case "attendee":
                if selectedItem > 0
                {
                    selectedMeeting.addAttendee(peopleList.people[selectedItem - 1], type: "Participant" , status: "Added")
                    tblAttendees.reloadData()
                }
            
            case "previousMeeting":
                // Check to see if an existing meeting already has this previos ID
            
                var foundMeeting: MeetingAgenda!
                
                for item in (currentUser.currentTeam?.meetingAgendas)!
                {
                    if item.previousMeetingID == pickerEventArray[selectedItem]
                    {
                        foundMeeting = item
                        break
                    }
                }
            
               // if myItems.count > 0
                if foundMeeting != nil
                { // Existing meeting found
                    let startDateFormatter = DateFormatter()
                    startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                    let myDisplayDate = startDateFormatter.string(from: foundMeeting.startTime! as Date)
                
                    let calendarOption: UIAlertController = UIAlertController(title: "Existing meeting found", message: "A meeting \(foundMeeting.name!) - \(myDisplayDate) has this set as previous meeting.  Do you want to continue, which will clear the previous meeting from the original meeting?  ", preferredStyle: .actionSheet)
                
                    let myYes = UIAlertAction(title: "Yes, update the details", style: .default, handler: { (action: UIAlertAction) -> () in
                        // go and update the previous meeting
                    
                        myCloudDB.updatePreviousAgendaID("", meetingID: foundMeeting.meetingID!, teamID: currentUser.currentTeam!.teamID)
                        
                        self.selectedMeeting.previousMinutes = self.pickerEventArray[selectedItem]
                    
                        if self.selectedMeeting.previousMinutes != ""
                        {
                            // Get the previous meetings details
                        
                            for myDisplayItem in (currentUser.currentTeam?.meetingAgendas)!
                            {
                                if myDisplayItem.meetingID == self.selectedMeeting.previousMinutes
                                {
                                    let startDateFormatter = DateFormatter()
                                    startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                                    let myDisplayDate = startDateFormatter.string(from: myDisplayItem.startTime! as Date)
                                
                                    let myDisplayString = "\(myDisplayItem.name!) - \(myDisplayDate)"
                                
                                    self.btnPreviousMinutes.setTitle(myDisplayString, for: .normal)
                                    self.btnDisplayPreviousMeeting.isHidden = false
                                    break
                                }
                            }
                        }
                    })
                
                    let myNo = UIAlertAction(title: "No, leave the existing details", style: .default, handler: { (action: UIAlertAction) -> () in
                        // do nothing
                    })
                
                    calendarOption.addAction(myYes)
                    calendarOption.addAction(myNo)
                
                    calendarOption.popoverPresentationController?.sourceView = self.view
                    calendarOption.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.width / 2.0, y: self.view.bounds.height / 2.0, width: 1.0, height: 1.0)
                
                    self.present(calendarOption, animated: true, completion: nil)
                }
                else
                {
                    selectedMeeting.previousMinutes = pickerEventArray[selectedItem]
                    
                    if selectedMeeting.previousMinutes != ""
                    {
                        // Get the previous meetings details
                    
                        for myDisplayItem in (currentUser.currentTeam?.meetingAgendas)!
                        {
                            if myDisplayItem.meetingID == selectedMeeting.previousMinutes
                            {
                                let startDateFormatter = DateFormatter()
                                startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                                let myDisplayDate = startDateFormatter.string(from: myDisplayItem.startTime! as Date)
                            
                                let myDisplayString = "\(myDisplayItem.name!) - \(myDisplayDate)"
                            
                                btnPreviousMinutes.setTitle(myDisplayString, for: .normal)
                                
                                btnDisplayPreviousMeeting.isHidden = false
                                break
                            }
                        }
                    }
                }
        
            case "nextMeeting":
                var nextCalItem: calendarItem!
                // Check to see if an existing meeting already has this previos ID
            
                var recordFound: Bool = false
                
                for myItem in (currentUser.currentTeam?.meetingAgendas)!
                {
                    if myItem.meetingID == pickerEventArray[selectedItem]
                    {
                        if myItem.previousMeetingID != ""
                        {
                            let startDateFormatter = DateFormatter()
                            startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                            let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                        
                            let calendarOption: UIAlertController = UIAlertController(title: "Existing meeting found", message: "A meeting \(myItem.name!) - \(myDisplayDate) has this set as next meeting.  Do you want to continue, which will clear the next meeting from the original meeting?  ", preferredStyle: .actionSheet)
                        
                            let myYes = UIAlertAction(title: "Yes, update the details", style: .default, handler: { (action: UIAlertAction) -> () in
                            // go and update the previous meeting
                            
                                let myOriginalNextMeeting = self.selectedMeeting.nextMeeting
                            
                                myCloudDB.updatePreviousAgendaID("", meetingID: myOriginalNextMeeting, teamID: currentUser.currentTeam!.teamID)
                            
                                if self.pickerEventArray[selectedItem] != ""
                                {
                                    // Is there a database entry for the next meeting
                                    
                                    let myMeetingCheck = (currentUser.currentTeam?.meetingAgendas)!.filter { $0.meetingID == self.pickerEventArray[selectedItem]}
                                    
                                    if myMeetingCheck.count == 0
                                    { // No meeting found, so need to create
    //                                        let nextEvent = topCalendar()
    //
    //                                        nextEvent.loadCalendarForEvent(self.pickerEventArray[self.mySelectedRow], startDate: self.pickerStartDateArray[self.mySelectedRow], teamID: currentUser.currentTeam!.teamID)
    //
    //                                        nextCalItem = nextEvent.appointments[0].databaseItem
                                    }
                                    else
                                    { // meeting found use it
                                        nextCalItem = calendarItem( meetingAgenda: myMeetingCheck[0])
                                    }
                                    
                                    // Get the previous meetings details
                                    
                                    self.selectedMeeting.setNextMeeting(nextCalItem)

                                    for myItem in (currentUser.currentTeam?.meetingAgendas)!
                                    {
                                        if myItem.meetingID == self.selectedMeeting.nextMeeting
                                        {
                                            let startDateFormatter = DateFormatter()
                                            startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                                            let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                                        
                                            let myDisplayString = "\(myItem.name!) - \(myDisplayDate)"
                                        
                                            self.btnNextMeeting.setTitle(myDisplayString, for: .normal)
                                            
                                            self.btnDisplayNextMeeting.isHidden = false
                                            break
                                        }
                                    }
                                }
                                else
                                {
                                    self.selectedMeeting.nextMeeting = self.pickerEventArray[selectedItem]
                                }
                            })
                        
                            let myNo = UIAlertAction(title: "No, leave the existing details", style: .default, handler: { (action: UIAlertAction) -> () in
                                // do nothing
                            })
                        
                            calendarOption.addAction(myYes)
                            calendarOption.addAction(myNo)
                        
                            calendarOption.popoverPresentationController?.sourceView = self.view
                            calendarOption.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.width / 2.0, y: self.view.bounds.height / 2.0, width: 1.0, height: 1.0)
                        
                            self.present(calendarOption, animated: true, completion: nil)
                        }
                        else
                        {
                            let myOriginalNextMeeting = pickerEventArray[selectedItem]
                        
                            myCloudDB.updatePreviousAgendaID("", meetingID: myOriginalNextMeeting, teamID: currentUser.currentTeam!.teamID)

                            if pickerEventArray[selectedItem] != ""
                            {
                                // Is there a database entry for the next meeting
                                
                                let myMeetingCheck = (currentUser.currentTeam?.meetingAgendas)!.filter {$0.meetingID == pickerEventArray[selectedItem]}
                                
                                if myMeetingCheck.count == 0
                                { // No meeting found, so need to create
    //                                    let nextEvent = topCalendar()
    //
    //                                    nextEvent.loadCalendarForEvent(pickerEventArray[mySelectedRow], startDate: pickerStartDateArray[mySelectedRow], teamID: currentUser.currentTeam!.teamID)
    //
    //                                    nextCalItem = nextEvent.appointments[0].databaseItem
                                }
                                else
                                { // meeting found use it
                                    nextCalItem = calendarItem(meetingAgenda: myMeetingCheck[0])
                                }
                                
                                // Get the previous meetings details
                                
                                selectedMeeting.setNextMeeting(nextCalItem)
                            
                                for myItem in (currentUser.currentTeam?.meetingAgendas)!
                                {
                                    if myItem.meetingID == selectedMeeting.nextMeeting
                                    {
                                        let startDateFormatter = DateFormatter()
                                        startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                                        let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                                    
                                        let myDisplayString = "\(myItem.name!) - \(myDisplayDate)"
                                    
                                        btnNextMeeting.setTitle(myDisplayString, for: .normal)
                                        btnDisplayNextMeeting.isHidden = false
                                        
                                        break
                                    }
                                }
                            }
                            else
                            {
                                selectedMeeting.nextMeeting = pickerEventArray[selectedItem]
                            }
                        }  // End if
                        recordFound = true
                        break
                        
                    } // End if myItem.meetingID == pickerEventArray[mySelectedRow]
                } // End for
                if recordFound
                {
                    if pickerEventArray[selectedItem] != ""
                    {
                        let myOriginalNextMeeting = self.selectedMeeting.nextMeeting
                
                        myCloudDB.updatePreviousAgendaID("", meetingID: myOriginalNextMeeting, teamID: currentUser.currentTeam!.teamID)

                        // Is there a database entry for the next meeting
         
                        let myMeetingCheck = (currentUser.currentTeam?.meetingAgendas)!.filter {$0.meetingID == pickerEventArray[selectedItem]}
                        
                        if myMeetingCheck.count == 0
                        { // No meeting found, so need to create
//                            let nextEvent = topCalendar()
//
//                            nextEvent.loadCalendarForEvent(pickerEventArray[mySelectedRow], startDate: pickerStartDateArray[mySelectedRow], teamID: currentUser.currentTeam!.teamID)
//
//                            nextCalItem = nextEvent.appointments[0].databaseItem
                        }
                        else
                        { // meeting found use it
                            nextCalItem = calendarItem(meetingAgenda: myMeetingCheck[0])
                        }

                        // Get the previous meetings details
                        
                        selectedMeeting.setNextMeeting(nextCalItem)
                        
                        for myItem in (currentUser.currentTeam?.meetingAgendas)!
                        {
                            if myItem.meetingID == selectedMeeting.nextMeeting
                            {
                                let startDateFormatter = DateFormatter()
                                startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                                let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                            
                                let myDisplayString = "\(myItem.name!) - \(myDisplayDate)"
                            
                                btnNextMeeting.setTitle(myDisplayString, for: .normal)
                                break
                            }
                        }
                    }
                    else
                    {
                        selectedMeeting.nextMeeting = pickerEventArray[selectedItem]
                    }
                }
            
            case "attendence":
                selectedMeeting.attendees[rowToAction].status = pickerOptions[selectedItem]
                selectedMeeting.attendees[rowToAction].save()
        
                selectedMeeting.loadAttendees()
        
                tblAttendees.reloadData()

                rowToAction = 0
        
            default:
                print("meetingviewcontroler,pickerdid return")
        }
        showFields()
    }
    
    @IBAction func btnDisplayPreviousMeeting(_ sender: UIButton)
    {
        let meetingViewControl = meetingStoryboard.instantiateViewController(withIdentifier: "Meetings") as! meetingsViewController

        let tempMeeting = calendarItem(meetingID: selectedMeeting.previousMinutes, teamID: currentUser.currentTeam!.teamID)
        tempMeeting.loadAgenda()
        
        meetingViewControl.passedMeeting = tempMeeting
        meetingViewControl.delegate = delegate
        self.present(meetingViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnDisplayNextMeeting(_ sender: UIButton)
    {
        let meetingViewControl = meetingStoryboard.instantiateViewController(withIdentifier: "Meetings") as! meetingsViewController

        let tempMeeting = calendarItem(meetingID: selectedMeeting.nextMeeting, teamID: currentUser.currentTeam!.teamID)
        tempMeeting.loadAgenda()

        meetingViewControl.passedMeeting = tempMeeting
        meetingViewControl.delegate = delegate
        self.present(meetingViewControl, animated: true, completion: nil)
    }
    
    func hideFields()
    {
        lblLocationHead.isHidden = true
        txtWhere.isHidden = true
        lblAT.isHidden = true
        btnDate.isHidden = true
        lblMeetingName.isHidden = true
        lblChairHead.isHidden = true
        lblMinutesHead.isHidden = true
        lblAttendeesHead.isHidden = true
        tblAttendees.isHidden = true
        btnChair.isHidden = true
        btnMinutes.isHidden = true
        btnCreatePerson.isHidden = true
        btnAddAttendee.isHidden = true
        txtName.isHidden = true
        btnPreviousMinutes.isHidden = true
        lblPreviousMeeting.isHidden = true
        lblNextMeeting.isHidden = true
        btnNextMeeting.isHidden = true
        btnDisplayPreviousMeeting.isHidden = true
        btnDisplayNextMeeting.isHidden = true
        btnEndDate.isHidden = true
        lblMeetingTo.isHidden = true
        if meetingCommunication == nil
        {
            btnAgenda.isHidden = true
        }
   //     btnCompleted.isHidden = true
    }
    
    func showFields()
    {
        lblLocationHead.isHidden = false
        txtWhere.isHidden = false
        lblAT.isHidden = false
        btnDate.isHidden = false
        lblMeetingName.isHidden = false
        lblChairHead.isHidden = false
        lblMinutesHead.isHidden = false
        lblAttendeesHead.isHidden = false
        tblAttendees.isHidden = false
        btnChair.isHidden = false
        btnMinutes.isHidden = false
        btnCreatePerson.isHidden = false
        btnAddAttendee.isHidden = false
        txtName.isHidden = false
        btnPreviousMinutes.isHidden = false
        lblPreviousMeeting.isHidden = false
        lblNextMeeting.isHidden = false
        btnNextMeeting.isHidden = false
        btnEndDate.isHidden = false
        lblMeetingTo.isHidden = false
    
        if selectedMeeting == nil
        {
            btnDisplayPreviousMeeting.isHidden = true
            btnDisplayNextMeeting.isHidden = true
            btnChair.isEnabled = false
            btnMinutes.isEnabled = false
        }
        else
        {
            if selectedMeeting.previousMinutes != ""
            {
                btnDisplayPreviousMeeting.isHidden = false
            }
            else
            {
                btnDisplayPreviousMeeting.isHidden = true
            }
            
            if selectedMeeting.nextMeeting != ""
            {
                btnDisplayNextMeeting.isHidden = false
            }
            else
            {
                btnDisplayNextMeeting.isHidden = true
            }
            
            if selectedMeeting.attendees.count > 0
            {
                btnChair.isEnabled = true
                btnMinutes.isEnabled = true
            }
            else
            {
                btnChair.isEnabled = false
                btnMinutes.isEnabled = false
            }
        }
        
        if meetingCommunication == nil
        {
            btnAgenda.isHidden = false
        }
        
  //      btnCompleted.isHidden = false
    }
    
    @objc func attendeeRemoved(_ notification: Notification)
    {
        let action = notification.userInfo!["Action"] as! String
        let itemToRemove = notification.userInfo!["itemNo"] as! Int
        
        if action == "Remove"
        {
            selectedMeeting.removeAttendee(itemToRemove)
            tblAttendees.reloadData()
        }
        else
        {
            pickerOptions.removeAll()
            
            for myItem in myAttendenceStatus
            {
                pickerOptions.append(myItem)
            }
            
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = btnAddAttendee
            popover.sourceRect = btnAddAttendee.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "attendence"
            pickerView.delegate = self
            pickerView.pickerValues = pickerOptions
            pickerView.preferredContentSize = CGSize(width: 400,height: 400)
          //  pickerView.currentValue = btn.currentTitle!
            
            self.present(pickerView, animated: true, completion: nil)
        }
    }

    func getPreviousMeeting()
    {
        // We only list items here that we have Meeting records for, as otherwise there is no previous actions to get and display
        
        // if a recurring meeting invite then display previous occurances at the top of the list
        
        pickerOptions.removeAll(keepingCapacity: false)
        pickerEventArray.removeAll(keepingCapacity: false)
        pickerStartDateArray.removeAll(keepingCapacity: false)
        
        if selectedMeeting.event != nil
        {
            if selectedMeeting.event!.recurrenceRules != nil
            {
                // Recurring event, so display rucurrences first
             
                // get the meeting id, and remove the trailing portion in order to use in a search
                
                let myItems = searchPastAgendaByPartialMeetingIDBeforeStart(selectedMeeting.meetingID, meetingStartDate: selectedMeeting.startDate)

                if myItems.count > 0
                { // There is an previous meeting
                    for myItem in myItems
                    {
                        if myItem.meetingID != selectedMeeting.meetingID
                        { // Not this meeting meeting
                            let startDateFormatter = DateFormatter()
                            startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                            let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                            
                            pickerOptions.append("\(myItem.name!) - \(myDisplayDate)")
                            pickerEventArray.append(myItem.meetingID!)
                            pickerStartDateArray.append(myItem.startTime! as Date)
                        }
                    }
                }
                
                // display remaining items, newest first

                let myNonItems = searchPastAgendaWithoutPartialMeetingIDBeforeStart(selectedMeeting.meetingID, meetingStartDate: selectedMeeting.startDate)
                
                if myNonItems.count > 0
                { // There is an previous meeting
                    for myItem in myNonItems
                    {
                        if myItem.meetingID != selectedMeeting.meetingID
                        { // Not this meeting meeting
                            let startDateFormatter = DateFormatter()
                            startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                            let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                            
                            pickerOptions.append("\(myItem.name!) - \(myDisplayDate)")
                            pickerEventArray.append(myItem.meetingID!)
                            pickerStartDateArray.append(myItem.startTime! as Date)
                        }
                    }
                }
                
                // Next meeting could also be a non entry so need to show calendar items as well
            }
        }

        //non-recurring event, so display in date order, newest first
        
        // list items prior to meeting date
        
        let myItems = listAgendaReverseDateBeforeStart(selectedMeeting.startDate)
        
        if myItems.count > 0
        { // There is an previous meeting
            for myItem in myItems
            {
                if myItem.meetingID != selectedMeeting.meetingID
                { // Not this meeting meeting
                    let startDateFormatter = DateFormatter()
                    startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                    let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                    
                    pickerOptions.append("\(myItem.name!) - \(myDisplayDate)")
                    pickerEventArray.append(myItem.meetingID!)
                    pickerStartDateArray.append(myItem.startTime! as Date)
                }
            }
        }
        
        if pickerOptions.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = btnPreviousMinutes
            popover.sourceRect = btnPreviousMinutes.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "previousMeeting"
            pickerView.delegate = self
            pickerView.pickerValues = pickerOptions
            pickerView.preferredContentSize = CGSize(width: 400,height: 400)
            pickerView.currentValue = btnPreviousMinutes.currentTitle!
         
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    func getNextMeeting()
    {
        pickerOptions.removeAll(keepingCapacity: false)
        pickerEventArray.removeAll(keepingCapacity: false)
        pickerStartDateArray.removeAll(keepingCapacity: false)
        
        let startDate = selectedMeeting.startDate
        
        let endDateModifier = readDefaultInt("CalAfter")
        
        let endDate = Date().add(.day, amount: (endDateModifier * 7))

        let calendarSource: iOSCalendarList = iOSCalendarList()
        let calItems = calendarSource.searchEvents(startDate: startDate, endDate: endDate)
        
        if calItems.count >  0
        {
            // Go through all the events and print them to the console
            for calItem in calItems
            {
                if selectedMeeting.meetingID != "\(calItem.calendarItemExternalIdentifier!) Date: \(calItem.startDate!)"
                {
                    let startDateFormatter = DateFormatter()
                    startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                    let myDisplayDate = startDateFormatter.string(from: calItem.startDate)
                
                    pickerOptions.append("\(calItem.title!) - \(myDisplayDate)")
                    pickerEventArray.append("\(calItem.calendarItemExternalIdentifier!) Date: \(calItem.startDate!)")
                    pickerStartDateArray.append(calItem.startDate)
                }
            }
        }
        
        if selectedMeeting.event != nil
        {
            if selectedMeeting.event?.recurrenceRules != nil
            {
                // Recurring event, so display rucurrences first
                
                // get the meeting id, and remove the trailing portion in order to use in a search
                
                var myItems: [MeetingAgenda]!
                
                let tempMeetingID = selectedMeeting.meetingID
                if tempMeetingID.range(of: "/") != nil
                {
                    let myStringArr = tempMeetingID.components(separatedBy: "/")
                    myItems = searchPastAgendaByPartialMeetingIDBeforeStart(myStringArr[0], meetingStartDate: selectedMeeting.startDate)
                }
                else
                {
                    myItems = searchPastAgendaByPartialMeetingIDBeforeStart(selectedMeeting.meetingID, meetingStartDate: selectedMeeting.startDate)
                }
                
                if myItems.count > 1
                { // There is an previous meeting
                    for myItem in myItems
                    {
                        if myItem.meetingID != selectedMeeting.meetingID
                        { // Not this meeting meeting
                            let startDateFormatter = DateFormatter()
                            startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                            let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                            
                            pickerOptions.append("\(myItem.name!) - \(myDisplayDate)")
                            pickerEventArray.append(myItem.meetingID!)
                            pickerStartDateArray.append(myItem.startTime! as Date)
                        }
                    }
                }
            }
        }
        
        // list items prior to meeting date
        
        let myItems = listAgendaReverseDateAfterStart(selectedMeeting.startDate)
        
        if myItems.count > 0
        { // There is an previous meeting
            for myItem in myItems
            {
                if myItem.meetingID != selectedMeeting.meetingID
                { // Not this meeting meeting
                    let startDateFormatter = DateFormatter()
                    startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                    let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                    
                    pickerOptions.append("\(myItem.name!) - \(myDisplayDate)")
                    pickerEventArray.append(myItem.meetingID!)
                    pickerStartDateArray.append(myItem.startTime! as Date)
                }
            }
        }
        
        if pickerOptions.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = btnNextMeeting
            popover.sourceRect = btnNextMeeting.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "nextMeeting"
            pickerView.delegate = self
            pickerView.pickerValues = pickerOptions
            pickerView.preferredContentSize = CGSize(width: 400,height: 400)
            pickerView.currentValue = btnNextMeeting.currentTitle!
            
            self.present(pickerView, animated: true, completion: nil)
        }
    }

    func createActivityController() -> UIActivityViewController
    {
        // Build up the details we want to share
        let sourceString: String = ""
        let sharingActivityProvider: SharingActivityProvider = SharingActivityProvider(placeholderItem: sourceString)
        
        let myTmp1 = selectedMeeting.buildShareHTMLString().replacingOccurrences(of: "\n", with: "<p>")
        sharingActivityProvider.HTMLString = myTmp1
        sharingActivityProvider.plainString = selectedMeeting.buildShareString()
        
        if selectedMeeting.startDate.compare(Date()) == ComparisonResult.orderedAscending
        {  // Historical so show Minutes
            sharingActivityProvider.messageSubject = "Minutes for meeting: \(selectedMeeting.title)"
        }
        else
        {
            sharingActivityProvider.messageSubject = "Agenda for meeting: \(selectedMeeting.title)"
        }
        
        let activityItems : Array = [sharingActivityProvider];
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
            // you can specify these if you'd like.
        activityViewController.excludedActivityTypes =  [
                UIActivity.ActivityType.postToTwitter,
                UIActivity.ActivityType.postToFacebook,
                UIActivity.ActivityType.postToWeibo,
                UIActivity.ActivityType.message,
            //        UIActivityTypeMail,
            //        UIActivityTypePrint,
            //        UIActivityTypeCopyToPasteboard,
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.addToReadingList,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToVimeo,
                UIActivity.ActivityType.postToTencentWeibo
            ]

        return activityViewController
    }
    
    func doNothing()
    {
        // as it says, do nothing
    }

    func share(_ sender: AnyObject)
    {
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            let activityViewController: UIActivityViewController = createActivityController()
            activityViewController.popoverPresentationController!.sourceView = sender.view
            present(activityViewController, animated:true, completion:nil)
        }
        else if UIDevice.current.userInterfaceIdiom == .pad
        {
            // actually, you don't have to do this. But if you do want a popover, this is how to do it.
            iPad(sender)
        }
    }
    
    func iPad(_ sender: AnyObject)
    {
        
        let activityViewController: UIActivityViewController = createActivityController()
        activityViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        activityViewController.popoverPresentationController!.sourceView = sender.view
            
        present(activityViewController, animated:true, completion:nil)
        
        
//        if !self.activityPopover.isViewLoaded()
//            {
//            if sender is UIBarButtonItem
//            {
//                let b = sender as! UIBarButtonItem
        
//                self.activityPopover.modalPresentationStyle = UIModalPresentationStyle.Popover
//                self.activityPopover.popoverPresentationController!.sourceView = b.customView
//                presentViewController(self.activityPopover, animated:true, completion:nil)
    //            self.activityPopover.presentPopoverFromBarButtonItem(sender as! UIBarButtonItem,
    //                permittedArrowDirections:.Any,
    //                animated:true)
//            }
//            else
//            {
//                let b = sender as! UIButton
//                self.activityPopover.modalPresentationStyle = UIModalPresentationStyle.Popover
//                self.activityPopover.popoverPresentationController!.sourceView = b
//                presentViewController(self.activityPopover, animated:true, completion:nil)
         //       self.activityPopover.presentPopoverFromRect(b.frame,
         //           inView: self.view,
         //           permittedArrowDirections:.Any,
         //           animated:true)
//            }
//        }
//        else
//        {
//            self.activityPopover.dismissViewControllerAnimated(true, completion: nil)
//        }
    }
    
    func myMeetingsAgendaDidFinish(_ controller:meetingAgendaViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func myMeetingsDidFinish(_ controller:meetingsViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnAgenda(_ sender: UIButton)
    {
        let agendaViewControl = meetingStoryboard.instantiateViewController(withIdentifier: "MeetingAgenda") as! meetingAgendaViewController
        agendaViewControl.passedMeeting = selectedMeeting
        
        self.present(agendaViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnCompleted(_ sender: UIButton)
    {
    }
    
//    //---------------------------------------------------------------
//    // These three methods implement the SMTEFillDelegate protocol to support fill-ins
//    
//    /* When an abbreviation for a snippet that looks like a fill-in snippet has been
//    * typed, SMTEDelegateController will call your fill delegate's implementation of
//    * this method.
//    * Provide some kind of identifier for the given UITextView/UITextField/UISearchBar/UIWebView
//    * The ID doesn't have to be fancy, "maintext" or "searchbar" will do.
//    * Return nil to avoid the fill-in app-switching process (the snippet will be expanded
//    * with "(field name)" where the fill fields are).
//    *
//    * Note that in the case of a UIWebView, the uiTextObject passed will actually be
//    * an NSDictionary with two of these keys:
//    *     - SMTEkWebView          The UIWebView object (key always present)
//    *     - SMTEkElementID        The HTML element's id attribute (if found, preferred over Name)
//    *     - SMTEkElementName      The HTML element's name attribute (if id not found and name found)
//    * (If no id or name attribute is found, fill-in's cannot be supported, as there is
//    * no way for TE to insert the filled-in text.)
//    * Unless there is only one editable area in your web view, this implies that the returned
//    * identifier string needs to include element id/name information. Eg. "webview-field2".
//    */
//    
//    //func identifierForTextArea(_ uiTextObject: AnyObject) -> String
//    func identifier(forTextArea uiTextObject: Any) -> String
//    {
//        var result: String = ""
//
//        if uiTextObject is UITextField
//        {
//            if (uiTextObject as AnyObject).tag == 1
//            {
//                result = "txtAttendeeName"
//            }
//            
//            if (uiTextObject as AnyObject).tag == 2
//            {
//                result = "txtAttendeeEmail"
//            }
//        }
//        
//        if uiTextObject is UITextView
//        {
//            if (uiTextObject as AnyObject).tag == 1
//            {
//                result = "unused"
//            }
//        }
//        
//        if uiTextObject is UISearchBar
//        {
//            result =  "mySearchBar"
//        }
//        
//        return result
//    }
//    
//    /* Usually called milliseconds after identifierForTextArea:, SMTEDelegateController is
//    * about to call [[UIApplication sharedApplication] openURL: "tetouch-xc: *x-callback-url/fillin?..."]
//    * In other words, the TEtouch is about to be activated. Your app should save state
//    * and make any other preparations.
//    *
//    * Return NO to cancel the process.
//    */
//
//    func prepare(forFillSwitch textIdentifier: String) -> Bool
//    {
//        // At this point the app should save state since TextExpander touch is about
//        // to activate.
//        // It especially needs to save the contents of the textview/textfield!
//        
//        return true
//    }
//    
//    /* Restore active typing location and insertion cursor position to a text item
//    * based on the identifier the fill delegate provided earlier.
//    * (This call is made from handleFillCompletionURL: )
//    *
//    * In the case of a UIWebView, this method should build and return an NSDictionary
//    * like the one sent to the fill delegate in identifierForTextArea: when the snippet
//    * was triggered.
//    * That is, you should make the UIWebView become first responder, then return an
//    * NSDictionary with two of these keys:
//    *     - SMTEkWebView          The UIWebView object (key must be present)
//    *     - SMTEkElementID        The HTML element's id attribute (preferred over Name)
//    *     - SMTEkElementName      The HTML element's name attribute (only if no id)
//    * TE will use the same Javascripts that it uses to expand normal snippets to focus the appropriate
//    * element and insert the filled text.
//    *
//    * Note 1: If your app is still loaded after returning from TEtouch's fill window,
//    * probably no work needs to be done (the text item will still be the first
//    * responder, and the insertion cursor position will still be the same).
//    * Note 2: If the requested insertionPointLocation cannot be honored (ie. text has
//    * been reset because of the app switching), then update it to whatever is reasonable.
//    *
//    * Return nil to cancel insertion of the fill-in text. Users will not expect a cancel
//    * at this point unless userCanceledFill is set. Even in the cancel case, they will likely
//    * expect the identified text object to become the first responder.
//    */
//    
//    // func makeIdentifiedTextObjectFirstResponder(_ textIdentifier: String, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>) -> AnyObject
//    public func makeIdentifiedTextObjectFirstResponder(_ textIdentifier: String!, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>!) -> Any!
//    {
//        snippetExpanded = true   
//        
//        let intIoInsertionPointLocation:Int = ioInsertionPointLocation.pointee
//        
//        if "txtAttendeeName" == textIdentifier
//        {
//            txtAttendeeName.becomeFirstResponder()
//            let theLoc = txtAttendeeName.position(from: txtAttendeeName.beginningOfDocument, offset: intIoInsertionPointLocation)
//            if theLoc != nil
//            {
//                txtAttendeeName.selectedTextRange = txtAttendeeName.textRange(from: theLoc!, to: theLoc!)
//            }
//            return txtAttendeeName
//        }
//        else if "txtAttendeeEmail" == textIdentifier
//        {
//            txtAttendeeEmail.becomeFirstResponder()
//            let theLoc = txtAttendeeEmail.position(from: txtAttendeeEmail.beginningOfDocument, offset: intIoInsertionPointLocation)
//            if theLoc != nil
//            {
//                txtAttendeeEmail.selectedTextRange = txtAttendeeEmail.textRange(from: theLoc!, to: theLoc!)
//            }
//            return txtAttendeeEmail
//        }
//
//            //        else if "mySearchBar" == textIdentifier
//            //        {
//            //            searchBar.becomeFirstResponder()
//            // Note: UISearchBar does not support cursor positioning.
//            // Since we don't save search bar text as part of our state, if our app was unloaded while TE was
//            // presenting the fill-in window, the search bar might now be empty to we should return
//            // insertionPointLocation of 0.
//            //            let searchTextLen = searchBar.text.length
//            //            if searchTextLen < ioInsertionPointLocation
//            //            {
//            //                ioInsertionPointLocation = searchTextLen
//            //            }
//            //            return searchBar
//            //        }
//        else
//        {
//            
//            //return nil
//            
//            return "" as AnyObject
//        }
//    }
//    
//    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
//    {
//        if (textExpander.isAttemptingToExpandText)
//        {
//            snippetExpanded = true
//        }
//        return true
//    }
//    
//    // Workaround for what appears to be an iOS 7 bug which affects expansion of snippets
//    // whose content is greater than one line. The UITextView fails to update its display
//    // to show the full content. Try commenting this out and expanding "sig1" to see the issue.
//    //
//    // Given other oddities of UITextView on iOS 7, we had assumed this would be fixed along the way.
//    // Instead, we'll have to work up an isolated case and file a bug. We don't want to bake this kind
//    // of workaround into the SDK, so instead we provide an example here.
//    // If you have a better workaround suggestion, we'd love to hear it.
//    
//    func twiddleText(_ textView: UITextView)
//    {
//        let SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO = UIDevice.current.systemVersion
//        if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO >= "7.0"
//        {
//            textView.textStorage.edited(NSTextStorageEditActions.editedCharacters,range:NSMakeRange(0, textView.textStorage.length),changeInLength:0)
//        }
//    }
//    
//    func textViewDidChange(_ textView: UITextView)
//    {
//        if snippetExpanded
//        {
//            usleep(10000)
//            twiddleText(textView)
//            
//            // performSelector(twiddleText:, withObject: textView, afterDelay:0.01)
//            snippetExpanded = false
//        }
//    }
//    
//    /*
//    // The following are the UITextViewDelegate methods; they simply write to the console log for demonstration purposes
//    
//    func textViewDidBeginEditing(textView: UITextView)
//    {
//    println("nextDelegate textViewDidBeginEditing")
//    }
//    func textViewShouldBeginEditing(textView: UITextView) -> Bool
//    {
//    println("nextDelegate textViewShouldBeginEditing")
//    return true
//    }
//    
//    func textViewShouldEndEditing(textView: UITextView) -> Bool
//    {
//    println("nextDelegate textViewShouldEndEditing")
//    return true
//    }
//    
//    func textViewDidEndEditing(textView: UITextView)
//    {
//    println("nextDelegate textViewDidEndEditing")
//    }
//    
//    func textViewDidChangeSelection(textView: UITextView)
//    {
//    println("nextDelegate textViewDidChangeSelection")
//    }
//    
//    // The following are the UITextFieldDelegate methods; they simply write to the console log for demonstration purposes
//    
//    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
//    {
//    println("nextDelegate textFieldShouldBeginEditing")
//    return true
//    }
//    
//    func textFieldDidBeginEditing(textField: UITextField)
//    {
//    println("nextDelegate textFieldDidBeginEditing")
//    }
//    
//    func textFieldShouldEndEditing(textField: UITextField) -> Bool
//    {
//    println("nextDelegate textFieldShouldEndEditing")
//    return true
//    }
//    
//    func textFieldDidEndEditing(textField: UITextField)
//    {
//    println("nextDelegate textFieldDidEndEditing")
//    }
//    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
//    {
//    println("nextDelegate textField:shouldChangeCharactersInRange: \(NSStringFromRange(range)) Original=\(textField.text), replacement = \(string)")
//    return true
//    }
//    
//    func textFieldShouldClear(textField: UITextField) -> Bool
//    {
//    println("nextDelegate textFieldShouldClear")
//    return true
//    }
//    
//    func textFieldShouldReturn(textField: UITextField) -> Bool
//    {
//    println("nextDelegate textFieldShouldReturn")
//    return true
//    }
//    */
}

class myAttendeeHeader: UICollectionReusableView
{
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblAction: UILabel!
    
}

let NotificationAttendeeRemoved = Notification.Name("NotificationAttendeeRemoved")

class myAttendeeDisplayItem: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnAction: UIButton!

    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnAction(_ sender: UIButton)
    {
        if btnAction.currentTitle == "Remove"
        {
            notificationCenter.post(name: NotificationAttendeeRemoved, object: nil, userInfo:["Action":"Remove","itemNo":btnAction.tag])
        }
        else
        {
            notificationCenter.post(name: NotificationAttendeeRemoved, object: nil, userInfo:["Action":"Attendence","itemNo":btnAction.tag])
        }
    }
}

class meetingCell: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}
