//
//  alertsClass.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 11/6/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation

import UIKit
import SwiftUI

public struct alertSummary: Identifiable
{
    public let id = UUID()
    public var displayText: String
    public var displayAmount: Int
}

public class alerts: NSObject, Identifiable
{
    public let id = UUID()
    public var alertList: [alertItem] = Array()
    public var alertSummaryList: [alertSummary] = Array()
    public var isLoading: Bool = false
    
    
    public func clearAlerts()
    {
        alertList.removeAll()
        alertSummaryList.removeAll()
    }
    
    public func displayAlertSummary() -> [alertSummary]
    {
        return alertSummaryList.filter { $0.displayAmount > 0 }
    }
}

public class alertItem: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myDisplayText: String = ""
    fileprivate var myName: String = ""
    fileprivate var mySource: String = ""
    fileprivate var myType: String = ""
    fileprivate var mySourceObject: Any!
    
    public var displayText: String
    {
        get
        {
            return myDisplayText
        }
        set
        {
            myDisplayText = newValue
        }
    }
    
    public var type: String
    {
        get
        {
            return myType
        }
        set
        {
            myType = newValue
        }
    }
    
    public var name: String
    {
        get
        {
            return myName
        }
        set
        {
            myName = newValue
        }
    }
    
    public var source: String
    {
        get
        {
            return mySource
        }
        set
        {
            mySource = newValue
        }
    }
    
    public var object: Any?
    {
        get
        {
            return mySourceObject
        }
        set
        {
            mySourceObject = newValue
        }
    }
}
