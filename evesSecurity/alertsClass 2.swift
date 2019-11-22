//
//  alertsClass.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 11/6/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#else
import AppKit
#endif
import SwiftUI

public struct alertSummary
{
    public var displayText: String
    public var displayAmount: Int
}

public class alerts: NSObject, Identifiable
{
    public let id = UUID()
    public var alertList: [alertItem] = Array()
    public var alertSummaryList: [alertSummary] = Array()
    
    public func clearAlerts()
    {
        alertList.removeAll()
        alertSummaryList.removeAll()
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
