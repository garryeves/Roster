//
//  securityViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 15/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//
import UIKit
import evesShared

class securityViewController: UIViewController, myCommunicationDelegate, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, shiftLoadDelegate
{
    @IBOutlet weak var tblAlerts: UITableView!
    @IBOutlet weak var lblAlerts: UITextField!
    
    private var alertList: alerts!
    var alertArray: [alertItem] = Array()
    var dashboardDelegate: dashboardUpdate!
    
    fileprivate var firstRun: Bool = true
    
    var delegate: mainScreenProtocol!
    var communicationDelegate: myCommunicationDelegate?
    var selectedType: String = ""
    
    override func viewDidLoad()
    {
        appName = "EvesSecurity"
        
        refreshScreen()
        
        if selectedType == ""
        {
            DispatchQueue.global().async
            {
                while currentUser.currentTeam?.shifts == nil
                {
                    sleep(1)
                }
            }
        }
      //  connectEventStore()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if alertList != nil
        {
            alertArray = alertList.alertList
        }
        return alertArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cellAlert", for: indexPath) as! alertListItem

        cell.lblAlert.text = alertArray[indexPath.row].displayText
        cell.lblName.text = alertArray[indexPath.row].name

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch alertArray[indexPath.row].source
        {
            case "Project":
                if currentUser.checkReadPermission(salesRoleType) || currentUser.checkReadPermission(pmRoleType)
                {
                    dashboardDelegate.displayScreen(screen: "Project", object: alertArray[indexPath.row].object!)
                }
            
            case "Client":
                if currentUser.checkReadPermission(salesRoleType) ||
                    currentUser.checkReadPermission(clientRoleType)
                {
                    dashboardDelegate.displayScreen(screen: "Client", object: alertArray[indexPath.row].object!)
                }
            
            case "Shift":
                if currentUser.checkReadPermission(rosteringRoleType)
                {
                    dashboardDelegate.displayScreen(screen: "Shift", object: alertArray[indexPath.row].object!)
                }
            
            default:
                let _ = 1
        }
    }
    
    public func refreshScreen()
    {
        if selectedType == ""
        {
            if currentUser.currentTeam?.shifts == nil && !firstRun
            {
                DispatchQueue.global().async
                {
                    currentUser.currentTeam?.loadShifts(self)
                    
                       // myCloudDB.getShifts(teamID: (currentUser.currentTeam?.teamID)!)
                }
            }

            buildAlerts()
          
            if currentUser.currentTeam!.subscriptionDate < Date().startOfDay
            {
                tblAlerts.isHidden = true
                lblAlerts.isHidden = true
                
                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.notSubscribedMessage), userInfo: nil, repeats: false)
            }
            else if myCloudDB.getTeamUserCount() > Int(currentUser.currentTeam!.subscriptionLevel)
            {
                tblAlerts.isHidden = true
                lblAlerts.isHidden = true
                
                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.exceedSubscriptionMessage), userInfo: nil, repeats: false)
            }
            else
            {
                tblAlerts.reloadData()
            }
        }
        else
        {
            tblAlerts.reloadData()
        }
    }
    
    @objc func exceedSubscriptionMessage()
    {
        let usercount: Int = myCloudDB.getTeamUserCount()
  
        let alert = UIAlertController(title: "Subscription count exceeded", message:
            "Your team has too many Users.  You currently have \(usercount) users but your subscription is for \(currentUser.currentTeam?.subscriptionLevel ?? 0) users.  Please contact your Administrator.", preferredStyle: UIAlertController.Style.alert)
        
        let yesOption = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        
        alert.addAction(yesOption)
        self.present(alert, animated: false, completion: nil)
 
    }

    @objc func notSubscribedMessage()
    {
        
        let alert = UIAlertController(title: "Subscription Expired", message:
            "Your teams subscription has expired.  Please contact your Administrator in order to have the Subscription renewed.", preferredStyle: UIAlertController.Style.alert)
        
        let yesOption = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        
        alert.addAction(yesOption)
        self.present(alert, animated: false, completion: nil)
 
    }
    
    func buildAlerts()
    {
        if alertList == nil
        {
                alertList = alerts()
        }
        else
        {
            alertList.clearAlerts()
        }

        notificationCenter.removeObserver(NotificationAlertUpdate)

        notificationCenter.addObserver(self, selector: #selector(securityViewController.displayAlertList), name: NotificationAlertUpdate, object: nil)

        DispatchQueue.global().async
        {
            self.alertList.clientAlerts(currentUser.currentTeam!.teamID)
            self.alertList.projectAlerts(currentUser.currentTeam!.teamID)

            while currentUser.currentTeam?.shifts == nil
            {
                sleep(1)
            }
            self.firstRun = false
            self.alertList.shiftAlerts(currentUser.currentTeam!.teamID)
        }
    }
    
    @objc func displayAlertList()
    {
        DispatchQueue.main.async
        {
            if self.alertList.alertList.count == 0
            {
                self.lblAlerts.text = "No Alerts"
            }
            else
            {
                self.lblAlerts.text = "Alerts"
            }
            self.tblAlerts.reloadData()
        }
    }
}

class alertListItem: UITableViewCell
{
    @IBOutlet weak public var lblAlert: UILabel!
    @IBOutlet weak public var lblName: UILabel!
    
    override public func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}
