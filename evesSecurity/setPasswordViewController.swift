//
//  setPasswordViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 15/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

public class setPasswordViewController: UIViewController, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtVeriftPassword: UITextField!
    @IBOutlet weak var txtHint: UITextField!
    @IBOutlet weak var btnSetPassword: UIBarButtonItem!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    
    override public func viewDidLoad()
    {
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSetPassword(_ sender: UIBarButtonItem)
    {
        if txtPassword.text == txtVeriftPassword.text
        {
            // Passwords are the same
            
            if txtPassword.text! != ""
            {
                removeDefaultString(userDefaultPassword)
                removeDefaultString(userDefaultPasswordHint)
            }
            else if txtPassword.text!.count >= 6
            {
                // And meet minimum password length
                
                writeDefaultString(userDefaultPassword, value: txtPassword.text!)
                writeDefaultString(userDefaultPasswordHint, value: txtHint.text!)
                self.dismiss(animated: true, completion: nil)
            }
            else
            {
                let alert = UIAlertController(title: "Password", message: "Password must be a minimum of 6 characters", preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                alert.isModalInPopover = true
                let popover = alert.popoverPresentationController
                popover!.delegate = self
                popover!.sourceView = txtPassword
                popover!.sourceRect = txtPassword.bounds
                
                alert.preferredContentSize = CGSize(width: 600,height: 500)
                self.present(alert, animated: false, completion: nil)
            }
        }
        else
        {
            let alert = UIAlertController(title: "Password", message: "Password and verification are different", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,
                                          handler: { (action: UIAlertAction) -> () in
                                            self.dismiss(animated: true, completion: nil)
            }))
            
            alert.isModalInPopover = true
            let popover = alert.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = txtPassword
            popover!.sourceRect = txtPassword.bounds
            
            alert.preferredContentSize = CGSize(width: 600,height: 500)
            self.present(alert, animated: false, completion: nil)
        }
    }

    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        dismiss(animated: true, completion: nil)
    }
        
}


