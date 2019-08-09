//
//  IAPViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 26/6/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

public let NotificationIAPSStarted = Notification.Name("NotificationIAPSStarted")

public class IAPViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tblIAPs: UITableView!
    @IBOutlet weak var lblProgress: UILabel!

    fileprivate var iap: IAPHandler!

    var communicationDelegate: myCommunicationDelegate?
    
    override public func viewDidLoad()
    {
        notificationCenter.addObserver(self, selector: #selector(self.refreshScreen), name: NotificationIAPSListed, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.purchaseMade), name: NotificationIAPSPurchased, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.purchaseStarted), name: NotificationIAPSStarted, object: nil)
        
        lblProgress.isHidden = true
        iap = IAPHandler()
        iap.listPurchases()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return iap.productsCount
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cellIAP", for: indexPath) as! IAPItem
            
        cell.lblDescription.text = iap.productNames[indexPath.row]
        cell.lblCost.text = iap.productCost[indexPath.row]
        cell.entryID = indexPath.row
        cell.iap = iap
        
        if iap.canMakePurchases
        {
            cell.btnSubscribe.isEnabled = true
        }
        else
        {
            cell.btnSubscribe.isEnabled = false
        }
        
        return cell

    }
    
    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc public func refreshScreen()
    {
        notificationCenter.removeObserver(NotificationIAPSListed)
        tblIAPs.reloadData()
    }
    
    @objc func purchaseStarted()
    {
        notificationCenter.removeObserver(NotificationIAPSStarted)
        tblIAPs.isHidden = true
        lblProgress.isHidden = false
    }
    
    @objc func purchaseMade()
    {
        notificationCenter.removeObserver(NotificationIAPSPurchased)
        // Now we need to handle the return.  
        
        if communicationDelegate != nil
        {
            communicationDelegate!.refreshScreen!()
        }
        dismiss(animated: true, completion: nil)
    }
}

class IAPItem: UITableViewCell
{
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblCost: UILabel!
    @IBOutlet weak var btnSubscribe: UIButton!
    
    var entryID: Int!
    var iap: IAPHandler!
    
    @IBAction func btnSubscribe(_ sender: UIButton)
    {
        notificationCenter.post(name: NotificationIAPSStarted, object: nil)
        iap.purchaseProduct(entryID)
    }
}
