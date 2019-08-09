//
//  AgendaItemViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 17/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import UIKit
//import TextExpander

//protocol MyAgendaItemDelegate
//{
//    func myAgendaItemDidFinish(_ controller:agendaItemViewController, actionType: String)
//}

public class agendaItemViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, MyPickerDelegate //, SMTEFillDelegate
{
    var communicationDelegate: myCommunicationDelegate?
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var btnOwner: UIButton!
    @IBOutlet weak var lblTimeAllocation: UILabel!
    @IBOutlet weak var txtTimeAllocation: UITextField!
    @IBOutlet weak var lblNotes: UILabel!
    @IBOutlet weak var txtDiscussionNotes: UITextView!
    @IBOutlet weak var lblDecisionMade: UILabel!
    @IBOutlet weak var txtDecisionMade: UITextView!
    @IBOutlet weak var lblActions: UILabel!
    @IBOutlet weak var btnAddAction: UIButton!
    @IBOutlet weak var tblTasks: UITableView!
    @IBOutlet weak var txtTaskName: UITextField!
    @IBOutlet weak var btnTaskOwner: UIButton!
    
    fileprivate let cellTaskName = "cellTasks"
    
    var event: calendarItem!
    var agendaItem: meetingAgendaItem!
    var actionType: String = ""
    
    private var displayList: [String] = Array()
    
//    // Textexpander
//    
//    fileprivate var snippetExpanded: Bool = false
//    
//    var textExpander: SMTEDelegateController!
    
    fileprivate var currentEditingField: String = ""

    override public func viewDidLoad()
    {
        super.viewDidLoad()
        
        if actionType == agendaStatus
        {
            txtDiscussionNotes.isEditable = false
            txtDecisionMade.isEditable = false
            txtTaskName.isEnabled = false
            btnTaskOwner.isEnabled = false
        }
        else if actionType == finishedStatus
        {
            txtDiscussionNotes.isEditable = false
            txtDecisionMade.isEditable = false
            btnAddAction.isEnabled = false
            txtTitle.isEnabled = false
            txtTimeAllocation.isEnabled = false
            btnOwner.isEnabled = false
            txtTaskName.isEnabled = false
            btnTaskOwner.isEnabled = false
        }
        
        if agendaItem.agendaID != 0
        {
            txtDecisionMade.text = agendaItem.decisionMade
            txtDiscussionNotes.text = agendaItem.discussionNotes
            txtTimeAllocation.text = "\(agendaItem.timeAllocation)"
            if agendaItem.owner == ""
            {
                btnOwner.setTitle("Select", for: .normal)
            }
            else
            {
                btnOwner.setTitle(agendaItem.owner, for: .normal)
            }
            txtTitle.text = agendaItem.title
        }

        txtDiscussionNotes.layer.borderColor = UIColor.lightGray.cgColor
        txtDiscussionNotes.layer.borderWidth = 0.5
        txtDiscussionNotes.layer.cornerRadius = 5.0
        txtDiscussionNotes.layer.masksToBounds = true
        txtDiscussionNotes.delegate = self
        
        txtDecisionMade.layer.borderColor = UIColor.lightGray.cgColor
        txtDecisionMade.layer.borderWidth = 0.5
        txtDecisionMade.layer.cornerRadius = 5.0
        txtDecisionMade.layer.masksToBounds = true
        txtDecisionMade.delegate = self
        
//        // TextExpander
//        textExpander = SMTEDelegateController()
//        txtTitle.delegate = textExpander
//        txtDiscussionNotes.delegate = textExpander
//        txtDecisionMade.delegate = textExpander
//        textExpander.clientAppName = "EvesCRM"
//        textExpander.fillCompletionScheme = "EvesCRM-fill-xc"
//        textExpander.fillDelegate = self
//        textExpander.nextDelegate = self
        myCurrentViewController = agendaItemViewController()
        myCurrentViewController = self
        
        enableTaskAdd()
        agendaItem.loadTasks()
    }
    
    override public func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return agendaItem.tasks.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell : myTaskItem!
 
        cell = tableView.dequeueReusableCell(withIdentifier: cellTaskName, for: indexPath as IndexPath) as? myTaskItem

        cell.lblTaskName.text = agendaItem.tasks[indexPath.row].title
        cell.btnStatus.setTitle(agendaItem.tasks[indexPath.row].status, for: .normal)
        agendaItem.tasks[indexPath.row].loadContexts()
        for myItem in agendaItem.tasks[indexPath.row].contexts
        {
            if myItem.contextType == personContextType
            {
                if myItem.contextID > 0
                {
                    let tempPerson = person(personID: myItem.contextID, teamID: currentUser.currentTeam!.teamID)
                    cell.lblTaskOwner.text = tempPerson.name
                }
                else
                {
                    cell.lblTaskOwner.text = "Not Set"
                }
                break
            }
            else
            {
                cell.lblTaskOwner.text = "Not Set"
            }
        }
        cell.lblTaskTargetDate.text = agendaItem.tasks[indexPath.row].displayDueDate
        cell.taskItem = agendaItem.tasks[indexPath.row]
        cell.mainView = self
        cell.sourceView = cell
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let myOptions = displayTaskOptions(tableView, workingTask: agendaItem.tasks[indexPath.row])
        myOptions.popoverPresentationController!.sourceView = tableView
        
        self.present(myOptions, animated: true, completion: nil)
    }

    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        if txtTitle.isFirstResponder
        {
            if txtTitle.text != ""
            {
                agendaItem.title = txtTitle.text!
            }
        }
        
        if txtTimeAllocation.isFirstResponder
        {
            if txtTimeAllocation.text != ""
            {
                if txtTimeAllocation.text!.isNumber
                {
                    agendaItem.timeAllocation = Int64(txtTimeAllocation.text!)!
                }
            }
        }
        
        if txtDiscussionNotes.isFirstResponder
        {
            if txtDiscussionNotes.text != ""
            {
                agendaItem.discussionNotes = txtDiscussionNotes.text
            }
        }
        
        if txtDecisionMade.isFirstResponder
        {
            if txtDecisionMade.text != ""
            {
                agendaItem.decisionMade = txtDecisionMade.text
            }
        }
        
        agendaItem.save()
        sleep(1)
        self.dismiss(animated: true, completion: nil)
        communicationDelegate?.refreshScreen!()
    }
    
    @IBAction func btnAddAction(_ sender: UIButton)
    {
        let newTask = task(teamID: currentUser.currentTeam!.teamID)
        newTask.title = txtTaskName.text!
        
        newTask.save()
        
        // See if we have the person in the person list
        var myPerson: person!
        
        myPerson = person(name: btnTaskOwner.currentTitle!, teamID: currentUser.currentTeam!.teamID)
        // Person found, so add as context
        
        if myPerson.personID == 0
        {
            //Not an existing person so create a new entry
            myPerson = person(teamID: currentUser.currentTeam!.teamID, taskOwner: btnTaskOwner.currentTitle!)
        }
        
        newTask.addContext(myPerson.personID, contextType: personContextType)
        
        agendaItem.addTask(newTask)
        
//        agendaItem.loadTasks()
        tblTasks.reloadData()
        
        txtTaskName.text = ""
        btnTaskOwner.setTitle("Select", for: .normal)
        enableTaskAdd()
    }
    
    @IBAction func btnOwner(_ sender: UIButton)
    {
        displayList.removeAll(keepingCapacity: false)

        displayList.append("")
        for attendee in event.attendees
        {
            displayList.append(attendee.name)
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
            
            pickerView.source = "Owner"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = sender.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnTaskOwner(_ sender: UIButton)
    {
        displayList.removeAll(keepingCapacity: false)
        
        displayList.append("")
        for attendee in event.attendees
        {
            displayList.append(attendee.name)
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
            
            pickerView.source = "TaskOwner"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = sender.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    public func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        // Write code for select
        if source == "Owner"
        {
            btnOwner.setTitle(displayList[selectedItem], for: .normal)
            agendaItem.owner = btnOwner.currentTitle!
        }
        
        if source == "TaskOwner"
        {
            btnTaskOwner.setTitle(displayList[selectedItem], for: .normal)
            enableTaskAdd()
        }
        
        showFields()
    }
    
    @IBAction func txtTaskName(_ sender: UITextField)
    {
        enableTaskAdd()
    }
    
    func enableTaskAdd()
    {
        if txtTaskName.text != "" && btnTaskOwner.currentTitle != ""  && btnTaskOwner.currentTitle != "Select"
        {
            btnAddAction.isEnabled = true
        }
        else
        {
            btnAddAction.isEnabled = false
        }
    }
    @IBAction func txtTitle(_ sender: UITextField)
    {
        if txtTitle.text != ""
        {
            agendaItem.title = txtTitle.text!
        }
    }
    
    @IBAction func txtTimeAllocation(_ sender: UITextField)
    {
        agendaItem.timeAllocation = Int64(txtTimeAllocation.text!)!
    }
    
    public func textViewDidEndEditing(_ textView: UITextView)
    { //Handle the text changes here
        if textView == txtDiscussionNotes
        {
            agendaItem.discussionNotes = txtDiscussionNotes.text
        }
        if textView == txtDecisionMade
        {
            agendaItem.decisionMade = txtDecisionMade.text
        }
    }
    
    func hideFields()
    {
        lblDescription.isHidden = true
        txtTitle.isHidden = true
        lblOwner.isHidden = true
        btnOwner.isHidden = true
        lblTimeAllocation.isHidden = true
        txtTimeAllocation.isHidden = true
        lblNotes.isHidden = true
        txtDiscussionNotes.isHidden = true
        lblDecisionMade.isHidden = true
        txtDecisionMade.isHidden = true
        lblActions.isHidden = true
        btnAddAction.isHidden = true
        tblTasks.isHidden = true
    }
    
    func showFields()
    {
        lblDescription.isHidden = false
        txtTitle.isHidden = false
        lblOwner.isHidden = false
        btnOwner.isHidden = false
        lblTimeAllocation.isHidden = false
        lblNotes.isHidden = false
        txtDiscussionNotes.isHidden = false
        lblDecisionMade.isHidden = false
        txtDecisionMade.isHidden = false
        lblActions.isHidden = false
        btnAddAction.isHidden = false
        tblTasks.isHidden = false
    }
    
    func displayTaskOptions(_ sourceView: UIView, workingTask: task) -> UIAlertController
    {
        let myOptions: UIAlertController = UIAlertController(title: "Select Action", message: "Select action to take", preferredStyle: .actionSheet)
        
        let myOption1 = UIAlertAction(title: "Edit Action", style: .default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = tasksStoryboard.instantiateViewController(withIdentifier: "tasks") as! taskViewController
            popoverContent.modalPresentationStyle = .popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = sourceView
            popover!.sourceRect = CGRect(x: 700,y: 700,width: 0,height: 0)
            
            popoverContent.passedTaskType = "minutes"
            popoverContent.passedMeeting = self.event
            popoverContent.passedTask = workingTask
            
            popoverContent.preferredContentSize = CGSize(width: 700,height: 700)
            
            self.present(popoverContent, animated: true, completion: nil)
        })
        
        let myOption2 = UIAlertAction(title: "Action Updates", style: .default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = tasksStoryboard.instantiateViewController(withIdentifier: "taskUpdate") as! taskUpdatesViewController
            popoverContent.modalPresentationStyle = .popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = sourceView
            popover!.sourceRect = CGRect(x: 700,y: 700,width: 0,height: 0)
            
            popoverContent.passedTask = workingTask
            
            popoverContent.preferredContentSize = CGSize(width: 700,height: 700)
            
            self.present(popoverContent, animated: true, completion: nil)
        })
        
        myOptions.addAction(myOption1)
        myOptions.addAction(myOption2)
        
        return myOptions
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
//   // func identifierForTextArea(_ uiTextObject: AnyObject) -> String
//    func identifier(forTextArea uiTextObject: Any) -> String
//    {
//        var result: String = ""
//
//        
//        if uiTextObject is UITextField
//        {
//            if (uiTextObject as AnyObject).tag == 1
//            {
//                result = "txtTitle"
//            }
//        }
//        
//        if uiTextObject is UITextView
//        {
//            if (uiTextObject as AnyObject).tag == 1
//            {
//                result = "txtDiscussionNotes"
//            }
//            
//            if (uiTextObject as AnyObject).tag == 2
//            {
//                result = "txtDecisionMade"
//            }
//
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
//    // At this point the app should save state since TextExpander touch is about
//    // to activate.
//    // It especially needs to save the contents of the textview/textfield!
//        
//        agendaItem.title = txtTitle.text!
//        agendaItem.discussionNotes = txtDiscussionNotes.text
//        agendaItem.decisionMade = txtDecisionMade.text
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
////    func makeIdentifiedTextObjectFirstResponder(_ textIdentifier: String, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>) -> AnyObject
//
//    public func makeIdentifiedTextObjectFirstResponder(_ textIdentifier: String!, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>!) -> Any!
//    {
//        snippetExpanded = true
//
//        let intIoInsertionPointLocation:Int = ioInsertionPointLocation.pointee
//        
//        if "txtDiscussionNotes" == textIdentifier
//        {
//            txtDiscussionNotes.becomeFirstResponder()
//            let theLoc = txtDiscussionNotes.position(from: txtDiscussionNotes.beginningOfDocument, offset: intIoInsertionPointLocation)
//            if theLoc != nil
//            {
//                txtDiscussionNotes.selectedTextRange = txtDiscussionNotes.textRange(from: theLoc!, to: theLoc!)
//            }
//            return txtDiscussionNotes
//        }
//        else if "txtDecisionMade" == textIdentifier
//        {
//            txtDecisionMade.becomeFirstResponder()
//            let theLoc = txtDecisionMade.position(from: txtDecisionMade.beginningOfDocument, offset: intIoInsertionPointLocation)
//            if theLoc != nil
//            {
//                txtDecisionMade.selectedTextRange = txtDecisionMade.textRange(from: theLoc!, to: theLoc!)
//            }
//            return txtDecisionMade
//        }
//        else if "txtTitle" == textIdentifier
//        {
//            txtTitle.becomeFirstResponder()
//            let theLoc = txtTitle.position(from: txtTitle.beginningOfDocument, offset: intIoInsertionPointLocation)
//            if theLoc != nil
//            {
//                txtTitle.selectedTextRange = txtTitle.textRange(from: theLoc!, to: theLoc!)
//            }
//            return txtTitle
//        }
////        else if "mySearchBar" == textIdentifier
////        {
////            searchBar.becomeFirstResponder()
//    // Note: UISearchBar does not support cursor positioning.
//    // Since we don't save search bar text as part of our state, if our app was unloaded while TE was
//    // presenting the fill-in window, the search bar might now be empty to we should return
//    // insertionPointLocation of 0.
////            let searchTextLen = searchBar.text.length
////            if searchTextLen < ioInsertionPointLocation
////            {
////                ioInsertionPointLocation = searchTextLen
////            }
////            return searchBar
////        }
//        else
//        {
//
//            //return nil
//
//            return "" as AnyObject
//        }
//    }
//    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
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
//        println("nextDelegate textViewShouldBeginEditing")
//        return true
//    }
//
//    func textViewShouldEndEditing(textView: UITextView) -> Bool
//    {
//        println("nextDelegate textViewShouldEndEditing")
//        return true
//    }
//    
//    func textViewDidEndEditing(textView: UITextView)
//    {
//        println("nextDelegate textViewDidEndEditing")
//    }
//    
//    func textViewDidChangeSelection(textView: UITextView)
//    {
//        println("nextDelegate textViewDidChangeSelection")
//    }
//
//    // The following are the UITextFieldDelegate methods; they simply write to the console log for demonstration purposes
//    
//    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
//    {
//        println("nextDelegate textFieldShouldBeginEditing")
//        return true
//    }
//    
//    func textFieldDidBeginEditing(textField: UITextField)
//    {
//        println("nextDelegate textFieldDidBeginEditing")
//    }
//    
//    func textFieldShouldEndEditing(textField: UITextField) -> Bool
//    {
//        println("nextDelegate textFieldShouldEndEditing")
//        return true
//    }
//    
//    func textFieldDidEndEditing(textField: UITextField)
//    {
//        println("nextDelegate textFieldDidEndEditing")
//    }
//    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
//    {
//        println("nextDelegate textField:shouldChangeCharactersInRange: \(NSStringFromRange(range)) Original=\(textField.text), replacement = \(string)")
//        return true
//    }
//    
//    func textFieldShouldClear(textField: UITextField) -> Bool
//    {
//        println("nextDelegate textFieldShouldClear")
//        return true
//    }
//    
//    func textFieldShouldReturn(textField: UITextField) -> Bool
//    {
//        println("nextDelegate textFieldShouldReturn")
//        return true
//    }
//*/
//    
}

class myTaskItem: UITableViewCell, UIPopoverPresentationControllerDelegate, MyPickerDelegate
{
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var lblTaskTargetDate: UILabel!
    @IBOutlet weak var lblTaskOwner: UILabel!
    @IBOutlet weak var lblTaskName: UILabel!
    
    var taskItem: task!
    var sourceView: myTaskItem!
    var mainView: agendaItemViewController!
    
    private var displayList: [String] = Array()
    
    @IBAction func btnStatus(_ sender: UIButton)
    {
        displayList.removeAll(keepingCapacity: false)
        
        displayList.append(taskStatusOpen)
        displayList.append(taskStatusClosed)
        displayList.append(taskStatusOnHold)
        
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
            
            pickerView.source = "TaskStatus"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = sender.currentTitle!
            mainView.present(pickerView, animated: true, completion: nil)
        }
    }
    
    public func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        // Write code for select
        if source == "TaskStatus"
        {
            btnStatus.setTitle(displayList[selectedItem], for: .normal)
            taskItem.status = btnStatus.currentTitle!
        }
    }
}
