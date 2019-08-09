//
//  validatePasswordViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 15/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

public class validatePasswordViewController: UIViewController, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnHint: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var txtPassword: UITextField!

    public var communicationDelegate: myCommunicationDelegate?
    
    override public func viewDidLoad()
    {
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnLogin(_ sender: UIButton)
    {
        if txtPassword.text?.uppercased() == readDefaultString(userDefaultPassword).uppercased()
        {
            communicationDelegate?.passwordCorrect!()
            self.dismiss(animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(title: "Password", message: "Incorrect password, please try again", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) -> () in
                self.txtPassword.text = ""
             //   self.txtPassword.becomeFirstResponder
                
            } ))
            
            let popover = alert.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = sender
            popover!.sourceRect = sender.bounds
            
            alert.preferredContentSize = CGSize(width: 600,height: 500)
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    @IBAction func btnHint(_ sender: UIButton)
    {
        let alert = UIAlertController(title: "Password", message: "Your hint = \(readDefaultString(userDefaultPasswordHint))", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        let popover = alert.popoverPresentationController
        popover!.delegate = self
        popover!.sourceView = sender
        popover!.sourceRect = sender.bounds
        
        alert.preferredContentSize = CGSize(width: 600,height: 500)
        self.present(alert, animated: false, completion: nil)
    }
}

