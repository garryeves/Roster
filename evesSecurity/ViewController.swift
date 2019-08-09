//
//  ViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 9/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit
import evesShared

class ViewController: UIViewController, myCommunicationDelegate, MyPickerDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var btnDummy: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblMessage2: UILabel!
    
    private var displayList: [String] = Array()
    private var teamList: userTeams!
    
    override func viewDidLoad()
    {
//        let myReachability = Reachability()
//        if !myReachability.isConnectedToNetwork()
//        {
//            lblMessage.text = "You are not connected to the Internet"
//            lblMessage2.text = "Please connect to the Internet to use this app."
//        }
//        else
//        {
//            myCloudDB = CloudKitInteraction()
//            if readDefaultInt(userDefaultName) <= 0
//            {
//                Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.loadNewUserScreen), userInfo: nil, repeats: false)
//            }
//            else
//            {
//                if readDefaultString(userDefaultPassword) != ""
//                {
//                    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.showPasswordScreen), userInfo: nil, repeats: false)
//                }
//                else
//                {
//                    passwordCorrect()
//                }
//            }
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
//    @objc func loadNewUserScreen()
//    {
//        openUser(self, commsDelegate: self)
//    }
//
//    func orgEdit(_ organisation: team?)
//    {
//        openOrg(target: organisation, sourceView: self, commsDelegate: self)
//    }
//
//    func userCreated(_ userRecord: userItem, teamID: Int64)
//    {
//        // Add the user/team combo to userteams
//
//        let myItem = userTeamItem(userID: userRecord.userID, teamID: teamID)
//
//        myItem.save()
//
//        openUserForm(userRecord, sourceView: self, commsDelegate: self)
//    }
//
//    @objc func userLoaded()
//    {
//        notificationCenter.removeObserver(NotificationUserLoaded)
//        callLoadMainScreen()
//    }
//
//    @objc func showPasswordScreen()
//    {
//        openPassword(self, commsDelegate: self)
//    }
//
//    func callLoadMainScreen()
//    {
//gaza move all this into new code
//        if currentUser.currentTeam == nil
//        {
//            currentUser.loadTeams()
//        }
//
//        if readDefaultInt("teamID") >= 0
//        {
//            currentUser.currentTeam = team(teamID: Int64(readDefaultInt("teamID")))
//        }
//
//        let iapInstance = IAPHandler()
//        iapInstance.checkReceipt()
//
//        DispatchQueue.main.async
//        {
//            self.teamList = userTeams(userID: currentUser.userID)
//            self.displayList.removeAll()
//
//            if self.teamList.UserTeams.count > 1
//            {
//                for myItem in self.teamList.UserTeams
//                {
//                    let tempTeam = team(teamID: myItem.teamID)
//                    self.displayList.append(tempTeam.name)
//                }
//
//                if self.displayList.count > 0
//                {
//                    let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
//                    pickerView.modalPresentationStyle = .popover
//
//                    let popover = pickerView.popoverPresentationController!
//                    popover.delegate = self
//                    popover.sourceView = self.btnDummy
//                    popover.sourceRect = self.btnDummy.bounds
//                    popover.permittedArrowDirections = .any
//
//                    pickerView.source = "TeamList"
//                    pickerView.delegate = self
//                    pickerView.pickerValues = self.displayList
//                    pickerView.preferredContentSize = CGSize(width: 600,height: 400)
//                    pickerView.currentValue = self.btnDummy.currentTitle!
//                    self.present(pickerView, animated: true, completion: nil)
//                }
//            }
//            else
//            {
//                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.loadMainScreen), userInfo: nil, repeats: false)
//            }
//        }
 //   }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "TeamList"
        {
            if selectedItem >= 0
            {
                currentUser.currentTeam = team(teamID: teamList.UserTeams[selectedItem].teamID)
                writeDefaultInt("teamID", value: Int(currentUser.currentTeam!.teamID))
   //             loadMainScreen()
            }
        }
    }
    
//    func loadMainScreen()
//    {
//        let myReachability = Reachability()
//        if myReachability.isConnectedToNetwork()
//        {
//            let split = self.storyboard?.instantiateViewController(withIdentifier: "mainSplitViewControl") as! mainSplitView
//
//            self.view.window?.rootViewController = split
//        }
//    }
//
//    func passwordCorrect()
//    {
//        notificationCenter.addObserver(self, selector: #selector(self.userLoaded), name: NotificationUserLoaded, object: nil)
//        currentUser = userItem(userID: Int64(readDefaultString(userDefaultName))!)
//        currentUser.getUserDetails()
//    }
}

