//
//  reporting.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 3/6/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation

import UIKit
import SwiftUI
import PDFKit

//import CoreData
import CloudKit

public let reportMonthlyRoster = "reportMonthlyRoster"
public let reportWeeklyRoster = "reportWeeklyRoster"
public let reportContractForMonth = "Contract for Month"
public let reportWagesForMonth = "Wages for Month"
public let reportContractForYear = "Contract Profit for Year"
public let reportEventPlan = "Event Plan"
public let reportContractDates = "Contract between Dates"

public let financialReportType = "Financial"
public let peopleReportType = "People"

public let formatBold = "Bold"
public let formatTotal = "Total"

public let perInfoText = "Text/Number"
public let perInfoDate = "Date"
public let perInfoYesNo = "Yes/No"

var sharingPDF: Data!
var sharingText: String!
var sharingImage: UIImage!
var fileSharingURL: URL!


public let shareExclutionArray = [ UIActivity.ActivityType.addToReadingList,
                                   //UIActivityType.airDrop,
    UIActivity.ActivityType.assignToContact,
    //        UIActivityType.CopyToPasteboard,
    //        UIActivityType.message,
    //        UIActivityType.Mail,
    UIActivity.ActivityType.openInIBooks,
    UIActivity.ActivityType.postToFlickr,
    UIActivity.ActivityType.postToTwitter,
    UIActivity.ActivityType.postToFacebook,
    UIActivity.ActivityType.postToTencentWeibo,
    UIActivity.ActivityType.postToVimeo,
    UIActivity.ActivityType.postToWeibo,
    //        Print,
    UIActivity.ActivityType.saveToCameraRoll
]

struct SwiftUIActivityViewController : UIViewControllerRepresentable {

    let activityViewController = ActivityViewController()

    func makeUIViewController(context: Context) -> ActivityViewController {
        activityViewController
    }
    func updateUIViewController(_ uiViewController: ActivityViewController, context: Context) {
        //
    }
    func shareImage(uiImage: UIImage) {
        activityViewController.uiImage = uiImage
        activityViewController.shareImage()
    }
    
    func shareText(textEntry: String) {
        activityViewController.textEntry = textEntry
        activityViewController.shareText()
    }
    
    func sharePDF(pdfData: Data) {
        activityViewController.pdfData = pdfData
        activityViewController.sharePDF()
    }
}


struct SwiftUIActivityViewControllerText : UIViewControllerRepresentable {
    
    let activityViewController = ActivityViewController()

    init() {
        activityViewController.textEntry = sharingText
        activityViewController.shareText()
    }
    
    func makeUIViewController(context: Context) -> ActivityViewController {
        activityViewController
    }
    func updateUIViewController(_ uiViewController: ActivityViewController, context: Context) {
        //
    }
}

struct SwiftUIActivityViewControllerImage : UIViewControllerRepresentable {

    var pdfData: Data!
    
    let activityViewController = ActivityViewController()

    init() {
        activityViewController.uiImage = sharingImage
        activityViewController.shareImage()
    }
    
    func makeUIViewController(context: Context) -> ActivityViewController {
        activityViewController
    }
    func updateUIViewController(_ uiViewController: ActivityViewController, context: Context) {
        //
    }
}

public class reports: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myReports: [report] = Array()
    
    public init(reportType: String, teamID: Int64)
    {
        super.init()
        
        if currentUser.currentTeam?.reportsData == nil
        {
            currentUser.currentTeam?.reportsData = myCloudDB.getReports(teamID: teamID)
        }
        
        var workingArray: [Reports] = Array()
        
        for item in (currentUser.currentTeam?.reportsData)!
        {
            if item.reportType == reportType
            {
                workingArray.append(item)
            }
        }
        
        for myReport in workingArray
        {
            let reportInstance = report(reportID: myReport.reportID,
                                        reportTitle: myReport.reportTitle,
                                        reportDescription: myReport.reportDescription,
                                        reportType: myReport.reportType,
                                        systemReport: myReport.systemReport,
                                        teamID: myReport.teamID,
                                        orientation: myReport.orientation,
                                        columnTitle1: myReport.columnTitle1,
                                        columnSource1: myReport.columnSource1,
                                        columnWidth1: myReport.columnWidth1,
                                        columnTitle2: myReport.columnTitle2,
                                        columnSource2: myReport.columnSource2,
                                        columnWidth2: myReport.columnWidth2,
                                        columnTitle3: myReport.columnTitle3,
                                        columnSource3: myReport.columnSource3,
                                        columnWidth3: myReport.columnWidth3,
                                        columnTitle4: myReport.columnTitle4,
                                        columnSource4: myReport.columnSource4,
                                        columnWidth4: myReport.columnWidth4,
                                        columnTitle5: myReport.columnTitle5,
                                        columnSource5: myReport.columnSource5,
                                        columnWidth5: myReport.columnWidth5,
                                        columnTitle6: myReport.columnTitle6,
                                        columnSource6: myReport.columnSource6,
                                        columnWidth6: myReport.columnWidth6,
                                        columnTitle7: myReport.columnTitle7,
                                        columnSource7: myReport.columnSource7,
                                        columnWidth7: myReport.columnWidth7,
                                        columnTitle8: myReport.columnTitle8,
                                        columnSource8: myReport.columnSource8,
                                        columnWidth8: myReport.columnWidth8,
                                        columnTitle9: myReport.columnTitle9,
                                        columnSource9: myReport.columnSource9,
                                        columnWidth9: myReport.columnWidth9,
                                        columnTitle10: myReport.columnTitle10,
                                        columnSource10: myReport.columnSource10,
                                        columnWidth10: myReport.columnWidth10,
                                        columnTitle11: myReport.columnTitle11,
                                        columnSource11: myReport.columnSource11,
                                        columnWidth11: myReport.columnWidth11,
                                        columnTitle12: myReport.columnTitle12,
                                        columnSource12: myReport.columnSource12,
                                        columnWidth12: myReport.columnWidth12,
                                        columnTitle13: myReport.columnTitle13,
                                        columnSource13: myReport.columnSource13,
                                        columnWidth13: myReport.columnWidth13,
                                        columnWidth14: myReport.columnWidth14,
                                        columnTitle14: myReport.columnTitle14,
                                        columnSource14: myReport.columnSource14,
                                        selectionCriteria1: myReport.selectionCriteria1,
                                        selectionCriteria2: myReport.selectionCriteria2,
                                        selectionCriteria3: myReport.selectionCriteria3,
                                        selectionCriteria4: myReport.selectionCriteria4,
                                        sortOrder1: myReport.sortOrder1,
                                        sortOrder2: myReport.sortOrder2,
                                        sortOrder3: myReport.sortOrder3,
                                        sortOrder4: myReport.sortOrder4)
            
            myReports.append(reportInstance)
        }
    }
    
    public init(teamID: Int64)
    {
        super.init()
        
        if currentUser.currentTeam?.reportsData == nil
        {
            currentUser.currentTeam?.reportsData = myCloudDB.getReports(teamID: teamID)
        }
        
        for myReport in (currentUser.currentTeam?.reportsData)!
        {
            let reportInstance = report(reportID: myReport.reportID,
                                        reportTitle: myReport.reportTitle,
                                        reportDescription: myReport.reportDescription,
                                        reportType: myReport.reportType,
                                        systemReport: myReport.systemReport,
                                        teamID: myReport.teamID,
                                        orientation: myReport.orientation,
                                        columnTitle1: myReport.columnTitle1,
                                        columnSource1: myReport.columnSource1,
                                        columnWidth1: myReport.columnWidth1,
                                        columnTitle2: myReport.columnTitle2,
                                        columnSource2: myReport.columnSource2,
                                        columnWidth2: myReport.columnWidth2,
                                        columnTitle3: myReport.columnTitle3,
                                        columnSource3: myReport.columnSource3,
                                        columnWidth3: myReport.columnWidth3,
                                        columnTitle4: myReport.columnTitle4,
                                        columnSource4: myReport.columnSource4,
                                        columnWidth4: myReport.columnWidth4,
                                        columnTitle5: myReport.columnTitle5,
                                        columnSource5: myReport.columnSource5,
                                        columnWidth5: myReport.columnWidth5,
                                        columnTitle6: myReport.columnTitle6,
                                        columnSource6: myReport.columnSource6,
                                        columnWidth6: myReport.columnWidth6,
                                        columnTitle7: myReport.columnTitle7,
                                        columnSource7: myReport.columnSource7,
                                        columnWidth7: myReport.columnWidth7,
                                        columnTitle8: myReport.columnTitle8,
                                        columnSource8: myReport.columnSource8,
                                        columnWidth8: myReport.columnWidth8,
                                        columnTitle9: myReport.columnTitle9,
                                        columnSource9: myReport.columnSource9,
                                        columnWidth9: myReport.columnWidth9,
                                        columnTitle10: myReport.columnTitle10,
                                        columnSource10: myReport.columnSource10,
                                        columnWidth10: myReport.columnWidth10,
                                        columnTitle11: myReport.columnTitle11,
                                        columnSource11: myReport.columnSource11,
                                        columnWidth11: myReport.columnWidth11,
                                        columnTitle12: myReport.columnTitle12,
                                        columnSource12: myReport.columnSource12,
                                        columnWidth12: myReport.columnWidth12,
                                        columnTitle13: myReport.columnTitle13,
                                        columnSource13: myReport.columnSource13,
                                        columnWidth13: myReport.columnWidth13,
                                        columnWidth14: myReport.columnWidth14,
                                        columnTitle14: myReport.columnTitle14,
                                        columnSource14: myReport.columnSource14,
                                        selectionCriteria1: myReport.selectionCriteria1,
                                        selectionCriteria2: myReport.selectionCriteria2,
                                        selectionCriteria3: myReport.selectionCriteria3,
                                        selectionCriteria4: myReport.selectionCriteria4,
                                        sortOrder1: myReport.sortOrder1,
                                        sortOrder2: myReport.sortOrder2,
                                        sortOrder3: myReport.sortOrder3,
                                        sortOrder4: myReport.sortOrder4)
            
            myReports.append(reportInstance)
        }
        
        if myReports.count > 1
        {
            myReports.sort
                {
                    if $0.reportType == $1.reportType
                    {
                        return $0.reportName < $1.reportName
                    }
                    else
                    {
                        return $0.reportType < $1.reportType
                    }
            }
        }
    }
    
    public var reports: [report]
    {
        get
        {
            return myReports
        }
    }
}

public class report: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myColumnWidth1: CGFloat = 0.0
    fileprivate var myColumnWidth2: CGFloat = 0.0
    fileprivate var myColumnWidth3: CGFloat = 0.0
    fileprivate var myColumnWidth4: CGFloat = 0.0
    fileprivate var myColumnWidth5: CGFloat = 0.0
    fileprivate var myColumnWidth6: CGFloat = 0.0
    fileprivate var myColumnWidth7: CGFloat = 0.0
    fileprivate var myColumnWidth8: CGFloat = 0.0
    fileprivate var myColumnWidth9: CGFloat = 0.0
    fileprivate var myColumnWidth10: CGFloat = 0.0
    fileprivate var myColumnWidth11: CGFloat = 0.0
    fileprivate var myColumnWidth12: CGFloat = 0.0
    fileprivate var myColumnWidth13: CGFloat = 0.0
    fileprivate var myColumnWidth14: CGFloat = 0.0
    fileprivate var myColumnTitle1: String = ""
    fileprivate var myColumnTitle2: String = ""
    fileprivate var myColumnTitle3: String = ""
    fileprivate var myColumnTitle4: String = ""
    fileprivate var myColumnTitle5: String = ""
    fileprivate var myColumnTitle6: String = ""
    fileprivate var myColumnTitle7: String = ""
    fileprivate var myColumnTitle8: String = ""
    fileprivate var myColumnTitle9: String = ""
    fileprivate var myColumnTitle10: String = ""
    fileprivate var myColumnTitle11: String = ""
    fileprivate var myColumnTitle12: String = ""
    fileprivate var myColumnTitle13: String = ""
    fileprivate var myColumnTitle14: String = ""
    fileprivate var myColumnSource1: String = ""
    fileprivate var myColumnSource2: String = ""
    fileprivate var myColumnSource3: String = ""
    fileprivate var myColumnSource4: String = ""
    fileprivate var myColumnSource5: String = ""
    fileprivate var myColumnSource6: String = ""
    fileprivate var myColumnSource7: String = ""
    fileprivate var myColumnSource8: String = ""
    fileprivate var myColumnSource9: String = ""
    fileprivate var myColumnSource10: String = ""
    fileprivate var myColumnSource11: String = ""
    fileprivate var myColumnSource12: String = ""
    fileprivate var myColumnSource13: String = ""
    fileprivate var myColumnSource14: String = ""
    fileprivate var mySelectionCriteria1: String = ""
    fileprivate var mySelectionCriteria2: String = ""
    fileprivate var mySelectionCriteria3: String = ""
    fileprivate var mySelectionCriteria4: String = ""
    fileprivate var mySortOrder1: String = ""
    fileprivate var mySortOrder2: String = ""
    fileprivate var mySortOrder3: String = ""
    fileprivate var mySortOrder4: String = ""
    fileprivate var myReportType: String = ""
    fileprivate var myReportID: Int64 = 0
    fileprivate var mySystemReport: Bool = false
    fileprivate var myRowHeight: Int = 12
    fileprivate var myReportName: String = ""
    fileprivate var myHeader: reportLine!
    var myLines: [reportLine] = Array()
    fileprivate var myPdfData: Data!
    fileprivate var myDisplayString: String = ""
    fileprivate var mySubject: String = ""
    fileprivate let paperSizePortrait = CGRect(x:0.0, y:0.0, width:595.276, height:841.89)
    fileprivate let paperSizeLandscape = CGRect(x:0.0, y:0.0, width:841.89, height:595.276)
    fileprivate var paperSize = CGRect(x:0.0, y:0.0, width:595.276, height:841.89)
    fileprivate var myPaperOrientation: String = "Portrait"
    fileprivate var disvisor: Double = 2
    fileprivate var leftSide: Int = 50
    fileprivate var myDisplayWidth: CGFloat = 0.0
    var myTeamID: Int64 = 0
    fileprivate var myFileCriteria1: String = ""
    fileprivate var myFileCriteria2: String = ""
    
    public var columnWidth1: CGFloat
    {
        get
        {
            if myColumnWidth1 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth1 / 100)
            }
        }
        set
        {
            myColumnWidth1 = newValue
        }
    }
    
    public var columnWidth2: CGFloat
    {
        get
        {
            if myColumnWidth2 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth2 / 100)
            }
        }
        set
        {
            myColumnWidth2 = newValue
        }
    }
    
    public var columnWidth3: CGFloat
    {
        get
        {
            if myColumnWidth3 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth3 / 100)
            }
        }
        set
        {
            myColumnWidth3 = newValue
        }
    }
    
    public var columnWidth4: CGFloat
    {
        get
        {
            if myColumnWidth4 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth4 / 100)
            }
        }
        set
        {
            myColumnWidth4 = newValue
        }
    }
    
    public var columnWidth5: CGFloat
    {
        get
        {
            if myColumnWidth5 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth5 / 100)
            }
        }
        set
        {
            myColumnWidth5 = newValue
        }
    }
    
    public var columnWidth6: CGFloat
    {
        get
        {
            if myColumnWidth6 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth6 / 100)
            }
        }
        set
        {
            myColumnWidth6 = newValue
        }
    }
    
    public var columnWidth7: CGFloat
    {
        get
        {
            if myColumnWidth7 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth7 / 100)
            }
        }
        set
        {
            myColumnWidth7 = newValue
        }
    }
    
    public var columnWidth8: CGFloat
    {
        get
        {
            if myColumnWidth8 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth8 / 100)
            }
        }
        set
        {
            myColumnWidth8 = newValue
        }
    }
    
    public var columnWidth9: CGFloat
    {
        get
        {
            if myColumnWidth9 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth9 / 100)
            }
        }
        set
        {
            myColumnWidth9 = newValue
        }
    }
    
    public var columnWidth10: CGFloat
    {
        get
        {
            if myColumnWidth10 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth10 / 100)
            }
        }
        set
        {
            myColumnWidth10 = newValue
        }
    }
    
    public var columnWidth11: CGFloat
    {
        get
        {
            if myColumnWidth11 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth11 / 100)
            }
        }
        set
        {
            myColumnWidth11 = newValue
        }
    }
    
    public var columnWidth12: CGFloat
    {
        get
        {
            if myColumnWidth12 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth12 / 100)
            }
        }
        set
        {
            myColumnWidth12 = newValue
        }
    }
    
    public var columnWidth13: CGFloat
    {
        get
        {
            if myColumnWidth13 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth13 / 100)
            }
        }
        set
        {
            myColumnWidth13 = newValue
        }
    }
    
    public var columnWidth14: CGFloat
    {
        get
        {
            if myColumnWidth14 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth14 / 100)
            }
        }
        set
        {
            myColumnWidth14 = newValue
        }
    }
    
    public var columnTitle1: String
    {
        get
        {
            return myColumnTitle1
        }
        set
        {
            myColumnTitle1 = newValue
        }
    }
    
    public var columnTitle2: String
    {
        get
        {
            return myColumnTitle2
        }
        set
        {
            myColumnTitle2 = newValue
        }
    }
    
    public var columnTitle3: String
    {
        get
        {
            return myColumnTitle3
        }
        set
        {
            myColumnTitle3 = newValue
        }
    }
    
    public var columnTitle4: String
    {
        get
        {
            return myColumnTitle4
        }
        set
        {
            myColumnTitle4 = newValue
        }
    }
    
    public var columnTitle5: String
    {
        get
        {
            return myColumnTitle5
        }
        set
        {
            myColumnTitle5 = newValue
        }
    }
    
    public var columnTitle6: String
    {
        get
        {
            return myColumnTitle6
        }
        set
        {
            myColumnTitle6 = newValue
        }
    }
    
    public var columnTitle7: String
    {
        get
        {
            return myColumnTitle7
        }
        set
        {
            myColumnTitle7 = newValue
        }
    }
    
    public var columnTitle8: String
    {
        get
        {
            return myColumnTitle8
        }
        set
        {
            myColumnTitle8 = newValue
        }
    }
    
    public var columnTitle9: String
    {
        get
        {
            return myColumnTitle9
        }
        set
        {
            myColumnTitle9 = newValue
        }
    }
    
    public var columnTitle10: String
    {
        get
        {
            return myColumnTitle10
        }
        set
        {
            myColumnTitle10 = newValue
        }
    }
    
    public var columnTitle11: String
    {
        get
        {
            return myColumnTitle11
        }
        set
        {
            myColumnTitle11 = newValue
        }
    }
    
    public var columnTitle12: String
    {
        get
        {
            return myColumnTitle12
        }
        set
        {
            myColumnTitle12 = newValue
        }
    }
    
    public var columnTitle13: String
    {
        get
        {
            return myColumnTitle13
        }
        set
        {
            myColumnTitle13 = newValue
        }
    }
    
    public var columnTitle14: String
    {
        get
        {
            return myColumnTitle14
        }
        set
        {
            myColumnTitle14 = newValue
        }
    }
    
    public var columnSource1: String
    {
        get
        {
            return myColumnSource1
        }
        set
        {
            myColumnSource1 = newValue
        }
    }
    
    public var columnSource2: String
    {
        get
        {
            return myColumnSource2
        }
        set
        {
            myColumnSource2 = newValue
        }
    }
    
    public var columnSource3: String
    {
        get
        {
            return myColumnSource3
        }
        set
        {
            myColumnSource3 = newValue
        }
    }
    
    public var columnSource4: String
    {
        get
        {
            return myColumnSource4
        }
        set
        {
            myColumnSource4 = newValue
        }
    }
    
    public var columnSource5: String
    {
        get
        {
            return myColumnSource5
        }
        set
        {
            myColumnSource5 = newValue
        }
    }
    
    public var columnSource6: String
    {
        get
        {
            return myColumnSource6
        }
        set
        {
            myColumnSource6 = newValue
        }
    }
    
    public var columnSource7: String
    {
        get
        {
            return myColumnSource7
        }
        set
        {
            myColumnSource7 = newValue
        }
    }
    
    public var columnSource8: String
    {
        get
        {
            return myColumnSource8
        }
        set
        {
            myColumnSource8 = newValue
        }
    }
    
    public var columnSource9: String
    {
        get
        {
            return myColumnSource9
        }
        set
        {
            myColumnSource9 = newValue
        }
    }
    
    public var columnSource10: String
    {
        get
        {
            return myColumnSource10
        }
        set
        {
            myColumnSource10 = newValue
        }
    }
    
    public var columnSource11: String
    {
        get
        {
            return myColumnSource11
        }
        set
        {
            myColumnSource11 = newValue
        }
    }
    
    public var columnSource12: String
    {
        get
        {
            return myColumnSource12
        }
        set
        {
            myColumnSource12 = newValue
        }
    }
    
    public var columnSource13: String
    {
        get
        {
            return myColumnSource13
        }
        set
        {
            myColumnSource13 = newValue
        }
    }
    
    public var columnSource14: String
    {
        get
        {
            return myColumnSource14
        }
        set
        {
            myColumnSource14 = newValue
        }
    }
    
    public var selectionCriteria1: String
    {
        get
        {
            return mySelectionCriteria1
        }
        set
        {
            mySelectionCriteria1 = newValue
            myFileCriteria1 = ""
        }
    }
    
    public var selectionCriteria2: String
    {
        get
        {
            return mySelectionCriteria2
        }
        set
        {
            mySelectionCriteria2 = newValue
        }
    }
    
    public var selectionCriteria3: String
    {
        get
        {
            return mySelectionCriteria3
        }
        set
        {
            mySelectionCriteria3 = newValue
            myFileCriteria2 = ""
        }
    }
    
    public var selectionCriteria4: String
    {
        get
        {
            return mySelectionCriteria4
        }
        set
        {
            mySelectionCriteria4 = newValue
        }
    }
    
    public var sortOrder1: String
    {
        get
        {
            return mySortOrder1
        }
        set
        {
            mySortOrder1 = newValue
        }
    }
    
    public var sortOrder2: String
    {
        get
        {
            return mySortOrder2
        }
        set
        {
            mySortOrder2 = newValue
        }
    }
    
    public var sortOrder3: String
    {
        get
        {
            return mySortOrder3
        }
        set
        {
            mySortOrder3 = newValue
        }
    }
    
    public var sortOrder4: String
    {
        get
        {
            return mySortOrder4
        }
        set
        {
            mySortOrder4 = newValue
        }
    }
    
    public var reportType: String
    {
        get
        {
            return myReportType
        }
        set
        {
            myReportType = newValue
        }
    }
    
    public var reportID: Int64
    {
        get
        {
            return myReportID
        }
    }
    
    public var systemReport: Bool
    {
        get
        {
            return mySystemReport
        }
        set
        {
            mySystemReport = newValue
        }
    }
    
    public var rowHeight: Int
    {
        get
        {
            return myRowHeight
        }
        set
        {
            myRowHeight = newValue
        }
    }
    
    public var reportName: String
    {
        get
        {
            return myReportName
        }
        set
        {
            myReportName = newValue
        }
    }
    
    public var subject: String
    {
        get
        {
            return mySubject
        }
        set
        {
            mySubject = newValue
        }
    }
    
    public var header: reportLine
    {
        get
        {
            return myHeader
        }
        set
        {
            myHeader = newValue
        }
    }
    
    public var lines: [reportLine]
    {
        get
        {
            return myLines
        }
    }
    
    public var count: Int
    {
        get
        {
            return myLines.count
        }
    }
        
    public var displayWidth: CGFloat
    {
        get
        {
            return myDisplayWidth
        }
        set
        {
            myDisplayWidth = newValue
        }
    }
    
    public var showCriteria1: Bool
    {
        var retVal: Bool = false
        
        if myReportType == ""
        {
            retVal = false
        }
        else if mySelectionCriteria1 == ""
        {
            retVal = false
        }
        else if myReportType == peopleReportType
        {
            for myItem in personAdditionalInfos(teamID: myTeamID).personAdditionalInfos
            {
                if myItem.addInfoName == mySelectionCriteria1
                {
                    if myItem.addInfoType == perInfoText || myItem.addInfoType == perInfoYesNo
                    {
                        retVal = true
                    }
                    else
                    {
                        retVal = false
                    }
                    myFileCriteria1 = myItem.addInfoType
                    
                    break
                }
            }
        }
        else
        {
            retVal = false
        }
        
        return retVal
    }
    
    public var showCriteria2: Bool
    {
        var retVal: Bool = false
        
        if myReportType == ""
        {
            retVal = false
        }
        else if mySelectionCriteria3 == ""
        {
            retVal = false
        }
        else if myReportType == peopleReportType
        {
            for myItem in personAdditionalInfos(teamID: myTeamID).personAdditionalInfos
            {
                if myItem.addInfoName == mySelectionCriteria3
                {
                    if myItem.addInfoType == perInfoText || myItem.addInfoType == perInfoYesNo
                    {
                        retVal = true
                    }
                    else
                    {
                        retVal = false
                    }
                    myFileCriteria2 = myItem.addInfoType
                    break
                }
            }
        }
        else
        {
            retVal = false
        }
        
        return retVal
    }
    
    public var criteriaType1: String
    {
        if myFileCriteria1 == ""
        {
            let _ = showCriteria1
        }
        return myFileCriteria1
    }
    
    public var criteriaType2: String
    {
        if myFileCriteria2 == ""
        {
            let _ = showCriteria2
        }
        return myFileCriteria2
    }
    
    public init(teamID: Int64)
    {
        myTeamID = teamID
        myReportID = myCloudDB.getNextID("Reports", teamID: teamID)
        
        if currentUser != nil
        {
            if currentUser.currentTeam != nil
            {
                currentUser.currentTeam?.reportsData = nil
            }
        }
    }
    
    public init(reportID: Int64, teamID: Int64)
    {
        super.init()
        
        if currentUser.currentTeam?.reportsData == nil
        {
            currentUser.currentTeam?.reportsData = myCloudDB.getReports(teamID: teamID)
        }
        
        var myRecord: Reports!
        
        for item in (currentUser.currentTeam?.reportsData)!
        {
            if item.reportID == reportID
            {
                myRecord = item
            }
        }
        
        if myRecord != nil
        {
            myReportID = myRecord.reportID
            myReportName = myRecord.reportTitle
            myReportName = myRecord.reportDescription
            myReportType = myRecord.reportType
            mySystemReport = myRecord.systemReport
            myTeamID = myRecord.teamID
            myPaperOrientation = myRecord.orientation
            myColumnTitle1 = myRecord.columnTitle1
            myColumnSource1 = myRecord.columnSource1
            myColumnWidth1 = CGFloat(myRecord.columnWidth1)
            myColumnTitle2 = myRecord.columnTitle2
            myColumnSource2 = myRecord.columnSource2
            myColumnWidth2 = CGFloat(myRecord.columnWidth2)
            myColumnTitle3 = myRecord.columnTitle3
            myColumnSource3 = myRecord.columnSource3
            myColumnWidth3 = CGFloat(myRecord.columnWidth3)
            myColumnTitle4 = myRecord.columnTitle4
            myColumnSource4 = myRecord.columnSource4
            myColumnWidth4 = CGFloat(myRecord.columnWidth4)
            myColumnTitle5 = myRecord.columnTitle5
            myColumnSource5 = myRecord.columnSource5
            myColumnWidth5 = CGFloat(myRecord.columnWidth5)
            myColumnTitle6 = myRecord.columnTitle6
            myColumnSource6 = myRecord.columnSource6
            myColumnWidth6 = CGFloat(myRecord.columnWidth6)
            myColumnTitle7 = myRecord.columnTitle7
            myColumnSource7 = myRecord.columnSource7
            myColumnWidth7 = CGFloat(myRecord.columnWidth7)
            myColumnTitle8 = myRecord.columnTitle8
            myColumnSource8 = myRecord.columnSource8
            myColumnWidth8 = CGFloat(myRecord.columnWidth8)
            myColumnTitle9 = myRecord.columnTitle9
            myColumnSource9 = myRecord.columnSource9
            myColumnWidth9 = CGFloat(myRecord.columnWidth9)
            myColumnTitle10 = myRecord.columnTitle10
            myColumnSource10 = myRecord.columnSource10
            myColumnWidth10 = CGFloat(myRecord.columnWidth10)
            myColumnTitle11 = myRecord.columnTitle11
            myColumnSource11 = myRecord.columnSource11
            myColumnWidth11 = CGFloat(myRecord.columnWidth11)
            myColumnTitle12 = myRecord.columnTitle12
            myColumnSource12 = myRecord.columnSource12
            myColumnWidth12 = CGFloat(myRecord.columnWidth12)
            myColumnTitle13 = myRecord.columnTitle13
            myColumnSource13 = myRecord.columnSource13
            myColumnWidth13 = CGFloat(myRecord.columnWidth13)
            myColumnWidth14 = CGFloat(myRecord.columnWidth14)
            myColumnTitle14 = myRecord.columnTitle14
            myColumnSource14 = myRecord.columnSource14
            mySelectionCriteria1 = myRecord.selectionCriteria1
            mySelectionCriteria2 = myRecord.selectionCriteria2
            mySelectionCriteria3 = myRecord.selectionCriteria3
            mySelectionCriteria4 = myRecord.selectionCriteria4
            mySortOrder1 = myRecord.sortOrder1
            mySortOrder2 = myRecord.sortOrder2
            mySortOrder3 = myRecord.sortOrder3
            mySortOrder4 = myRecord.sortOrder4
            
            if myPaperOrientation == "Landscape"
            {
                paperSize = paperSizeLandscape
            }
            else
            {
                paperSize = paperSizePortrait
            }
            
            createHeader()
        }
    }
    
    public init(name: String)
    {
        myReportName = name
    }
    
    public init( reportID: Int64,
                 reportTitle: String,
                 reportDescription: String,
                 reportType: String,
                 systemReport: Bool,
                 teamID: Int64,
                 orientation: String,
                 columnTitle1: String,
                 columnSource1: String,
                 columnWidth1: Double,
                 columnTitle2: String,
                 columnSource2: String,
                 columnWidth2: Double,
                 columnTitle3: String,
                 columnSource3: String,
                 columnWidth3: Double,
                 columnTitle4: String,
                 columnSource4: String,
                 columnWidth4: Double,
                 columnTitle5: String,
                 columnSource5: String,
                 columnWidth5: Double,
                 columnTitle6: String,
                 columnSource6: String,
                 columnWidth6: Double,
                 columnTitle7: String,
                 columnSource7: String,
                 columnWidth7: Double,
                 columnTitle8: String,
                 columnSource8: String,
                 columnWidth8: Double,
                 columnTitle9: String,
                 columnSource9: String,
                 columnWidth9: Double,
                 columnTitle10: String,
                 columnSource10: String,
                 columnWidth10: Double,
                 columnTitle11: String,
                 columnSource11: String,
                 columnWidth11: Double,
                 columnTitle12: String,
                 columnSource12: String,
                 columnWidth12: Double,
                 columnTitle13: String,
                 columnSource13: String,
                 columnWidth13: Double,
                 columnWidth14: Double,
                 columnTitle14: String,
                 columnSource14: String,
                 selectionCriteria1: String,
                 selectionCriteria2: String,
                 selectionCriteria3: String,
                 selectionCriteria4: String,
                 sortOrder1: String,
                 sortOrder2: String,
                 sortOrder3: String,
                 sortOrder4: String)
    {
        super.init()
        
        myReportID = reportID
        myReportName = reportTitle
        myReportName = reportDescription
        myReportType = reportType
        mySystemReport = systemReport
        myTeamID = teamID
        myPaperOrientation = orientation
        myColumnTitle1 = columnTitle1
        myColumnSource1 = columnSource1
        myColumnWidth1 = CGFloat(columnWidth1)
        myColumnTitle2 = columnTitle2
        myColumnSource2 = columnSource2
        myColumnWidth2 = CGFloat(columnWidth2)
        myColumnTitle3 = columnTitle3
        myColumnSource3 = columnSource3
        myColumnWidth3 = CGFloat(columnWidth3)
        myColumnTitle4 = columnTitle4
        myColumnSource4 = columnSource4
        myColumnWidth4 = CGFloat(columnWidth4)
        myColumnTitle5 = columnTitle5
        myColumnSource5 = columnSource5
        myColumnWidth5 = CGFloat(columnWidth5)
        myColumnTitle6 = columnTitle6
        myColumnSource6 = columnSource6
        myColumnWidth6 = CGFloat(columnWidth6)
        myColumnTitle7 = columnTitle7
        myColumnSource7 = columnSource7
        myColumnWidth7 = CGFloat(columnWidth7)
        myColumnTitle8 = columnTitle8
        myColumnSource8 = columnSource8
        myColumnWidth8 = CGFloat(columnWidth8)
        myColumnTitle9 = columnTitle9
        myColumnSource9 = columnSource9
        myColumnWidth9 = CGFloat(columnWidth9)
        myColumnTitle10 = columnTitle10
        myColumnSource10 = columnSource10
        myColumnWidth10 = CGFloat(columnWidth10)
        myColumnTitle11 = columnTitle11
        myColumnSource11 = columnSource11
        myColumnWidth11 = CGFloat(columnWidth11)
        myColumnTitle12 = columnTitle12
        myColumnSource12 = columnSource12
        myColumnWidth12 = CGFloat(columnWidth12)
        myColumnTitle13 = columnTitle13
        myColumnSource13 = columnSource13
        myColumnWidth13 = CGFloat(columnWidth13)
        myColumnWidth14 = CGFloat(columnWidth14)
        myColumnTitle14 = columnTitle14
        myColumnSource14 = columnSource14
        mySelectionCriteria1 = selectionCriteria1
        mySelectionCriteria2 = selectionCriteria2
        mySelectionCriteria3 = selectionCriteria3
        mySelectionCriteria4 = selectionCriteria4
        mySortOrder1 = sortOrder1
        mySortOrder2 = sortOrder2
        mySortOrder3 = sortOrder3
        mySortOrder4 = sortOrder4
        
        if myPaperOrientation == "Landscape"
        {
            paperSize = paperSizeLandscape
        }
        else
        {
            paperSize = paperSizePortrait
        }
        
        createHeader()
    }
    
    private func createHeader()
    {
        if myHeader == nil
        {
            myHeader = reportLine()
        }
        
        myHeader.column1 = myColumnTitle1
        myHeader.column2 = myColumnTitle2
        myHeader.column3 = myColumnTitle3
        myHeader.column4 = myColumnTitle4
        myHeader.column5 = myColumnTitle5
        myHeader.column6 = myColumnTitle6
        myHeader.column7 = myColumnTitle7
        myHeader.column8 = myColumnTitle8
        myHeader.column9 = myColumnTitle9
        myHeader.column10 = myColumnTitle10
        myHeader.column11 = myColumnTitle11
        myHeader.column12 = myColumnTitle12
        myHeader.column13 = myColumnTitle13
        myHeader.column14 = myColumnTitle14
    }
    
    public func removeAll()
    {
        myLines.removeAll()
    }
    
    public func append(_ line: reportLine)
    {
        myLines.append(line)
    }
    
    public func portrait()
    {
        paperSize = paperSizePortrait
        myPaperOrientation = "Portrait"
        disvisor = 2
    }
    
    public func landscape()
    {
        paperSize = paperSizeLandscape
        myPaperOrientation = "Landscape"
        disvisor = 1.5
    }
    
    func createPDFFile(filePath: String)
    {
        let pdfMetadata = [
            // The name of the application creating the PDF.
            kCGPDFContextCreator: "Dashboard Export",

            // The name of the PDF's author.
            kCGPDFContextAuthor: "nextactions.com.au",

            // The title of the PDF.
            kCGPDFContextTitle: "Dashboard Export"
        ]
        
        var topSide: Int = 50
        
         let format = UIGraphicsPDFRendererFormat()
         format.documentInfo = pdfMetadata as [String: Any]

        // Creates a new PDF file at the specified path.
        
        var pageBounds = CGRect.zero
        
        if myPaperOrientation == "Landscape" {
            pageBounds = CGRect(x: 0, y: 0, width: 842, height: 595)
        }
        
        UIGraphicsBeginPDFContextToFile(filePath, pageBounds, pdfMetadata)

        // Creates a new page in the current PDF context.
        UIGraphicsBeginPDFPage()

        if mySubject != ""{
            reportHeader(topSide, height: 40)
        }

        topSide += 5 + 40

        if myHeader != nil {
            pageHeader(topSide)
        }

        for item in myLines {
            topSide += 5 + myRowHeight

            if CGFloat(topSide) >= paperSize.height - 50 {
                UIGraphicsBeginPDFPageWithInfo(paperSize, nil)
                if myHeader != nil {
                    topSide = 50
                    pageHeader(topSide)
                }

                topSide += 5 + myRowHeight
            }

            if item.drawLine {
                let trianglePath = UIBezierPath()
                trianglePath.move(to: CGPoint(x: 50, y: topSide))
                trianglePath.addLine(to: CGPoint(x: paperSize.width - 50, y: CGFloat(topSide)))

                item.lineColour.setStroke()
                trianglePath.stroke()
                UIColor.black.setStroke()
            } else {
                lineEntry(item, top: topSide)
            }
        }

        UIGraphicsEndPDFContext()
    }

    private func createDisplayString()
    {
        myDisplayString = mySubject
        myDisplayString += "\n\n"
        
        if myHeader != nil
        {
            myDisplayString += displayLine(myHeader)
            myDisplayString += "\n\n"
        }
        
        for myEntry in myLines
        {
            myDisplayString += displayLine(myEntry)
            myDisplayString += "\n"
        }
    }
    
    private func displayLine(_ sourceLine: reportLine, delimiter: String = " ") -> String
    {
        var returnString: String = ""
        
        returnString += processStringCell(text: sourceLine.column1, width: myColumnWidth1, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column2, width: myColumnWidth2, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column3, width: myColumnWidth3, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column4, width: myColumnWidth4, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column5, width: myColumnWidth5, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column6, width: myColumnWidth6, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column7, width: myColumnWidth7, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column8, width: myColumnWidth8, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column9, width: myColumnWidth9, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column10, width: myColumnWidth10, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column11, width: myColumnWidth11, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column12, width: myColumnWidth12, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column13, width: myColumnWidth13, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column14, width: myColumnWidth14, delimiter: "")
        returnString += "\n"
        
        return returnString
    }
    
    private func processStringCell(text: String, width: CGFloat, delimiter: String) -> String
    {
        var returnString: String = ""
        
        if width > 0
        {
            returnString = "\(text)"
            returnString += "\(delimiter)"
        }
        
        return returnString
    }
    
    private func reportHeader(_ top: Int, height: Int)
    {
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = .center
        
        let titleFontAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20),
            NSAttributedString.Key.paragraphStyle:titleParagraphStyle,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        let headerRect = CGRect(
            x: 10,
            y: top,
            width: Int(paperSize.width),
            height: height)
        
        mySubject.draw(in: headerRect, withAttributes: titleFontAttributes)
    }
    
    private func pageHeader(_ top: Int)
    {
        leftSide = 50
        
        writePDFHeaderEntry(title: myHeader.column1, x: leftSide, y: top, width: myColumnWidth1, height: 20)
        writePDFHeaderEntry(title: myHeader.column2, x: leftSide, y: top, width: myColumnWidth2, height: 20)
        writePDFHeaderEntry(title: myHeader.column3, x: leftSide, y: top, width: myColumnWidth3, height: 20)
        writePDFHeaderEntry(title: myHeader.column4, x: leftSide, y: top, width: myColumnWidth4, height: 20)
        writePDFHeaderEntry(title: myHeader.column5, x: leftSide, y: top, width: myColumnWidth5, height: 20)
        writePDFHeaderEntry(title: myHeader.column6, x: leftSide, y: top, width: myColumnWidth6, height: 20)
        writePDFHeaderEntry(title: myHeader.column7, x: leftSide, y: top, width: myColumnWidth7, height: 20)
        writePDFHeaderEntry(title: myHeader.column8, x: leftSide, y: top, width: myColumnWidth8, height: 20)
        writePDFHeaderEntry(title: myHeader.column9, x: leftSide, y: top, width: myColumnWidth9, height: 20)
        writePDFHeaderEntry(title: myHeader.column10, x: leftSide, y: top, width: myColumnWidth10, height: 20)
        writePDFHeaderEntry(title: myHeader.column11, x: leftSide, y: top, width: myColumnWidth11, height: 20)
        writePDFHeaderEntry(title: myHeader.column12, x: leftSide, y: top, width: myColumnWidth12, height: 20)
        writePDFHeaderEntry(title: myHeader.column13, x: leftSide, y: top, width: myColumnWidth13, height: 20)
        writePDFHeaderEntry(title: myHeader.column14, x: leftSide, y: top, width: myColumnWidth14, height: 20)
    }
    
    private func lineEntry(_ line: reportLine, top: Int)
    {
        leftSide = 50
        
        writePDFEntry(title: line.column1, x: leftSide, y: top, width: myColumnWidth1, height: myRowHeight, format: line.format)
        writePDFEntry(title: line.column2, x: leftSide, y: top, width: myColumnWidth2, height: myRowHeight, format: line.format)
        writePDFEntry(title: line.column3, x: leftSide, y: top, width: myColumnWidth3, height: myRowHeight, format: line.format)
        writePDFEntry(title: line.column4, x: leftSide, y: top, width: myColumnWidth4, height: myRowHeight, format: line.format)
        writePDFEntry(title: line.column5, x: leftSide, y: top, width: myColumnWidth5, height: myRowHeight, format: line.format)
        writePDFEntry(title: line.column6, x: leftSide, y: top, width: myColumnWidth6, height: myRowHeight, format: line.format)
        writePDFEntry(title: line.column7, x: leftSide, y: top, width: myColumnWidth7, height: myRowHeight, format: line.format)
        writePDFEntry(title: line.column8, x: leftSide, y: top, width: myColumnWidth8, height: myRowHeight, format: line.format)
        writePDFEntry(title: line.column9, x: leftSide, y: top, width: myColumnWidth9, height: myRowHeight, format: line.format)
        writePDFEntry(title: line.column10, x: leftSide, y: top, width: myColumnWidth10, height: myRowHeight, format: line.format)
        writePDFEntry(title: line.column11, x: leftSide, y: top, width: myColumnWidth11, height: myRowHeight, format: line.format)
        writePDFEntry(title: line.column12, x: leftSide, y: top, width: myColumnWidth12, height: myRowHeight, format: line.format)
        writePDFEntry(title: line.column13, x: leftSide, y: top, width: myColumnWidth13, height: myRowHeight, format: line.format)
        writePDFEntry(title: line.column14, x: leftSide, y: top, width: myColumnWidth14, height: myRowHeight, format: line.format)
    }
    
    private func writePDFHeaderEntry(title: String, x: Int, y: Int, width: CGFloat, height: Int)
    {
        let displayWidth = Int((paperSize.width - 150) * (width / 100))
        
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = .left
        
        let titleFontAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12),
            NSAttributedString.Key.paragraphStyle:titleParagraphStyle,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        let headerRect = CGRect(
            x: x,
            y: y,
            width: displayWidth,
            height: height)
        
        title.draw(in: headerRect, withAttributes: titleFontAttributes)
        
        leftSide += 5 + displayWidth
    }
    
    private func writePDFEntry(title: String, x: Int, y: Int, width: CGFloat, height: Int, format: String)
    {
        let displayWidth = Int((paperSize.width - 150) * (width / 100))
        
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = .left
        
        let headerRect = CGRect(
            x: x,
            y: y,
            width: displayWidth,
            height: height)
        
        switch format
        {
        case formatBold:
            let dataFontAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 8),
                NSAttributedString.Key.paragraphStyle:titleParagraphStyle,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]

            title.draw(in: headerRect, withAttributes: dataFontAttributes)
            
        case formatTotal:
            let dataFontAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11),
                NSAttributedString.Key.paragraphStyle:titleParagraphStyle,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]

            title.draw(in: headerRect, withAttributes: dataFontAttributes)
            
        default:
            let dataFontAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 8),
                NSAttributedString.Key.paragraphStyle:titleParagraphStyle,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
            title.draw(in: headerRect, withAttributes: dataFontAttributes)
        }
        
        leftSide += 5 + displayWidth
    }
    
    
    public func save()
    {
        let temp = Reports(columnSource1: myColumnSource1,
                           columnSource2: myColumnSource2,
                           columnSource3: myColumnSource3,
                           columnSource4: myColumnSource4,
                           columnSource5: myColumnSource5,
                           columnSource6: myColumnSource6,
                           columnSource7: myColumnSource7,
                           columnSource8: myColumnSource8,
                           columnSource9: myColumnSource9,
                           columnSource10: myColumnSource10,
                           columnSource11: myColumnSource11,
                           columnSource12: myColumnSource12,
                           columnSource13: myColumnSource13,
                           columnSource14: myColumnSource14,
                           columnTitle1: myColumnTitle1,
                           columnTitle2: myColumnTitle2,
                           columnTitle3: myColumnTitle3,
                           columnTitle4: myColumnTitle4,
                           columnTitle5: myColumnTitle5,
                           columnTitle6: myColumnTitle6,
                           columnTitle7: myColumnTitle7,
                           columnTitle8: myColumnTitle8,
                           columnTitle9: myColumnTitle9,
                           columnTitle10: myColumnTitle10,
                           columnTitle11: myColumnTitle11,
                           columnTitle12: myColumnTitle12,
                           columnTitle13: myColumnTitle13,
                           columnTitle14: myColumnTitle14,
                           columnWidth1: Double(myColumnWidth1),
                           columnWidth2: Double(myColumnWidth2),
                           columnWidth3: Double(myColumnWidth3),
                           columnWidth4: Double(myColumnWidth4),
                           columnWidth5: Double(myColumnWidth5),
                           columnWidth6: Double(myColumnWidth6),
                           columnWidth7: Double(myColumnWidth7),
                           columnWidth8: Double(myColumnWidth8),
                           columnWidth9: Double(myColumnWidth9),
                           columnWidth10: Double(myColumnWidth10),
                           columnWidth11: Double(myColumnWidth11),
                           columnWidth12: Double(myColumnWidth12),
                           columnWidth13: Double(myColumnWidth13),
                           columnWidth14: Double(myColumnWidth14),
                           orientation: myPaperOrientation,
                           reportDescription: myReportName,
                           reportID: myReportID,
                           reportTitle: myReportName,
                           reportType: myReportType,
                           selectionCriteria1: mySelectionCriteria1,
                           selectionCriteria2: mySelectionCriteria2,
                           selectionCriteria3: mySelectionCriteria3,
                           selectionCriteria4: mySelectionCriteria4,
                           sortOrder1: mySortOrder1,
                           sortOrder2: mySortOrder2,
                           sortOrder3: mySortOrder3,
                           sortOrder4: mySortOrder4,
                           systemReport: mySystemReport,
                           teamID: myTeamID)
        
        myCloudDB.saveReportsRecordToCloudKit(temp)
    }
    
    public func delete()
    {
        myCloudDB.deleteReport(myReportID, teamID: myTeamID)
        currentUser.currentTeam?.reportsData = nil
    }
    
    public func run()
    {
        // Execute the query associated with the report, and run it
        myLines.removeAll()
        
        if reportType == peopleReportType
        {
            if mySelectionCriteria1 != ""
            {
                for myItem in personAdditionalInfos(teamID: myTeamID).personAdditionalInfos
                {
                    if myItem.addInfoName == mySelectionCriteria1
                    {
                        var dataList: personAddInfoEntries!
                        
                        if mySelectionCriteria2 == ""
                        {
                            dataList = personAddInfoEntries(addInfoName: myItem.addInfoName, teamID: myTeamID)
                        }
                        else
                        {
                            dataList = personAddInfoEntries(addInfoName: myItem.addInfoName, searchString: mySelectionCriteria2, teamID: myTeamID)
                        }
                        //
                        for myDataItem in dataList.personAddEntries
                        {
                            let myPerson = person(personID: myDataItem.personID, teamID: myTeamID)
                            
                            let newLine = reportLine()
                            
                            newLine.column1 = myPerson.name
                            if myItem.addInfoType == perInfoDate
                            {
                                newLine.column2 = myDataItem.dateString
                            }
                            else
                            {
                                newLine.column2 = myDataItem.stringValue
                            }
                            newLine.column3 = ""
                            
                            if criteriaType1 == perInfoDate
                            {
                                newLine.date = myDataItem.dateValue
                            }
                            
                            myLines.append(newLine)
                        }
                        break
                    }
                }
            }
        }
        
        if myLines.count > 0
        {
            // Sorting
            
            if mySortOrder1 != ""
            {
                // Apply a sort order
                
                if myReportType == peopleReportType
                {
                    if mySortOrder1 == "Name"
                    {
                        if mySortOrder2 == "Ascending"
                        {
                            myLines.sort
                                {
                                    // Because workdate has time it throws everything out
                                    if $0.column1 == $1.column1
                                    {
                                        if criteriaType1 == perInfoDate
                                        {
                                            return $0.date < $1.date
                                        }
                                        else
                                        {
                                            return $0.column2 < $1.column2
                                        }
                                    }
                                    else
                                    {
                                        return $0.column1 < $1.column1
                                    }
                            }
                        }
                        else
                        {
                            myLines.sort
                                {
                                    // Because workdate has time it throws everything out
                                    if $0.column1 == $1.column1
                                    {
                                        if criteriaType1 == perInfoDate
                                        {
                                            return $0.date < $1.date
                                        }
                                        else
                                        {
                                            return $0.column2 < $1.column2
                                        }
                                    }
                                    else
                                    {
                                        return $0.column1 > $1.column1
                                    }
                            }
                        }
                    }
                    else
                    {
                        if mySortOrder2 == "Ascending"
                        {
                            myLines.sort
                                {
                                    // Because workdate has time it throws everything out
                                    
                                    if criteriaType1 == perInfoDate
                                    {
                                        if $0.date == $1.date
                                        {
                                            return $0.column1 < $1.column1
                                        }
                                        else
                                        {
                                            return $0.date < $1.date
                                        }
                                    }
                                    else
                                    {
                                        if $0.column2 == $1.column2
                                        {
                                            return $0.column1 < $1.column1
                                        }
                                        else
                                        {
                                            return $0.column2 < $1.column2
                                        }
                                    }
                            }
                        }
                        else
                        {
                            myLines.sort
                                {
                                    // Because workdate has time it throws everything out
                                    if criteriaType1 == perInfoDate
                                    {
                                        if $0.date == $1.date
                                        {
                                            return $0.column1 < $1.column1
                                        }
                                        else
                                        {
                                            return $0.date > $1.date
                                        }
                                    }
                                    else
                                    {
                                        if $0.column2 == $1.column2
                                        {
                                            return $0.column1 < $1.column1
                                        }
                                        else
                                        {
                                            return $0.column2 > $1.column2
                                        }
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
}

public class reportShareSource: UIActivityItemProvider, Identifiable
{
    public let id = UUID()
    fileprivate var myPDFData: Data!
    fileprivate var myDisplayString: String = ""
    
    public init(displayString: String, PDFData: Data)
    {
        super.init(placeholderItem: PDFData)
        myPDFData = PDFData
        myDisplayString = displayString
    }
    
    public init(displayString: String)
    {
        super.init(placeholderItem: displayString)
        myDisplayString = displayString
    }
    
    public init(PDFData: Data)
    {
        super.init(placeholderItem: PDFData)
        myPDFData = PDFData
    }
    
    override public var item: Any
    {
        switch activityType!
        {
        case UIActivity.ActivityType.addToReadingList,
             UIActivity.ActivityType.airDrop,
             UIActivity.ActivityType.assignToContact,
             UIActivity.ActivityType.mail,
             UIActivity.ActivityType.openInIBooks,
             UIActivity.ActivityType.postToFlickr,
             UIActivity.ActivityType.postToVimeo,
             UIActivity.ActivityType.print,
             UIActivity.ActivityType.saveToCameraRoll:
            if myPDFData != nil
            {
                return myPDFData!
            }
            else
            {
                return myDisplayString
            }
            
        case UIActivity.ActivityType.copyToPasteboard,
             UIActivity.ActivityType.message,
             UIActivity.ActivityType.postToFacebook,
             UIActivity.ActivityType.postToTencentWeibo,
             UIActivity.ActivityType.postToTwitter:
            return myDisplayString
            
        default:
            if myPDFData != nil
            {
                return myPDFData!
            }
            else
            {
                return myDisplayString
            }
        }
    }
}

public class reportLine: NSObject, Identifiable
{
    public let id = UUID()
    fileprivate var myColumn1: String = ""
    fileprivate var myColumn2: String = ""
    fileprivate var myColumn3: String = ""
    fileprivate var myColumn4: String = ""
    fileprivate var myColumn5: String = ""
    fileprivate var myColumn6: String = ""
    fileprivate var myColumn7: String = ""
    fileprivate var myColumn8: String = ""
    fileprivate var myColumn9: String = ""
    fileprivate var myColumn10: String = ""
    fileprivate var myColumn11: String = ""
    fileprivate var myColumn12: String = ""
    fileprivate var myColumn13: String = ""
    fileprivate var myColumn14: String = ""
    fileprivate var mySourceObject: Any!
    fileprivate var myDrawLine: Bool = false
    fileprivate var myLineColour: UIColor = UIColor.black
    fileprivate var myDateValue: Date!
    fileprivate var myFormat: String!
    
    public var column1: String
    {
        get
        {
            return myColumn1
        }
        set
        {
            myColumn1 = newValue
        }
    }
    
    public var column2: String
    {
        get
        {
            return myColumn2
        }
        set
        {
            myColumn2 = newValue
        }
    }
    
    public var column3: String
    {
        get
        {
            return myColumn3
        }
        set
        {
            myColumn3 = newValue
        }
    }
    
    public var column4: String
    {
        get
        {
            return myColumn4
        }
        set
        {
            myColumn4 = newValue
        }
    }
    
    public var column5: String
    {
        get
        {
            return myColumn5
        }
        set
        {
            myColumn5 = newValue
        }
    }
    
    public var column6: String
    {
        get
        {
            return myColumn6
        }
        set
        {
            myColumn6 = newValue
        }
    }
    
    public var column7: String
    {
        get
        {
            return myColumn7
        }
        set
        {
            myColumn7 = newValue
        }
    }
    
    public var column8: String
    {
        get
        {
            return myColumn8
        }
        set
        {
            myColumn8 = newValue
        }
    }
    
    public var column9: String
    {
        get
        {
            return myColumn9
        }
        set
        {
            myColumn9 = newValue
        }
    }
    
    public var column10: String
    {
        get
        {
            return myColumn10
        }
        set
        {
            myColumn10 = newValue
        }
    }
    
    public var column11: String
    {
        get
        {
            return myColumn11
        }
        set
        {
            myColumn11 = newValue
        }
    }
    
    public var column12: String
    {
        get
        {
            return myColumn12
        }
        set
        {
            myColumn12 = newValue
        }
    }
    
    public var column13: String
    {
        get
        {
            return myColumn13
        }
        set
        {
            myColumn13 = newValue
        }
    }
    
    public var column14: String
    {
        get
        {
            return myColumn14
        }
        set
        {
            myColumn14 = newValue
        }
    }
    
    public var sourceObject: Any
    {
        get
        {
            return mySourceObject!
        }
        set
        {
            mySourceObject = newValue
        }
    }
    
    public var drawLine: Bool
    {
        get
        {
            return myDrawLine
        }
        set
        {
            myDrawLine = newValue
        }
    }
    
    public var lineColour: UIColor
    {
        get
        {
            return myLineColour
        }
        set
        {
            myLineColour = newValue
        }
    }
    
    public var date: Date
    {
        get
        {
            return myDateValue
        }
        set
        {
            myDateValue = newValue
        }
    }
    
    public var format: String
    {
        get
        {
            if myFormat == nil
            {
                return ""
            }
            return myFormat
        }
        set
        {
            myFormat = newValue
        }
    }
}

public struct Reports {
    public var columnSource1: String
    public var columnSource2: String
    public var columnSource3: String
    public var columnSource4: String
    public var columnSource5: String
    public var columnSource6: String
    public var columnSource7: String
    public var columnSource8: String
    public var columnSource9: String
    public var columnSource10: String
    public var columnSource11: String
    public var columnSource12: String
    public var columnSource13: String
    public var columnSource14: String
    public var columnTitle1: String
    public var columnTitle2: String
    public var columnTitle3: String
    public var columnTitle4: String
    public var columnTitle5: String
    public var columnTitle6: String
    public var columnTitle7: String
    public var columnTitle8: String
    public var columnTitle9: String
    public var columnTitle10: String
    public var columnTitle11: String
    public var columnTitle12: String
    public var columnTitle13: String
    public var columnTitle14: String
    public var columnWidth1: Double
    public var columnWidth2: Double
    public var columnWidth3: Double
    public var columnWidth4: Double
    public var columnWidth5: Double
    public var columnWidth6: Double
    public var columnWidth7: Double
    public var columnWidth8: Double
    public var columnWidth9: Double
    public var columnWidth10: Double
    public var columnWidth11: Double
    public var columnWidth12: Double
    public var columnWidth13: Double
    public var columnWidth14: Double
    public var orientation: String
    public var reportDescription: String
    public var reportID: Int64
    public var reportTitle: String
    public var reportType: String
    public var selectionCriteria1: String
    public var selectionCriteria2: String
    public var selectionCriteria3: String
    public var selectionCriteria4: String
    public var sortOrder1: String
    public var sortOrder2: String
    public var sortOrder3: String
    public var sortOrder4: String
    public var systemReport: Bool
    public var teamID: Int64
}

extension CloudKitInteraction
{
    private func populateReports(_ records: [CKRecord]) -> [Reports]
    {
        var tempArray: [Reports] = Array()
        
        for record in records
        {
            var columnWidth1: Double = 0.0
            if record.object(forKey: "columnWidth1") != nil
            {
                columnWidth1 = record.object(forKey: "columnWidth1") as! Double
            }
            
            var columnWidth2: Double = 0.0
            if record.object(forKey: "columnWidth2") != nil
            {
                columnWidth2 = record.object(forKey: "columnWidth2") as! Double
            }
            
            var columnWidth3: Double = 0.0
            if record.object(forKey: "columnWidth3") != nil
            {
                columnWidth3 = record.object(forKey: "columnWidth3") as! Double
            }
            
            var columnWidth4: Double = 0.0
            if record.object(forKey: "columnWidth4") != nil
            {
                columnWidth4 = record.object(forKey: "columnWidth4") as! Double
            }
            
            var columnWidth5: Double = 0.0
            if record.object(forKey: "columnWidth5") != nil
            {
                columnWidth5 = record.object(forKey: "columnWidth5") as! Double
            }
            
            var columnWidth6: Double = 0.0
            if record.object(forKey: "columnWidth6") != nil
            {
                columnWidth6 = record.object(forKey: "columnWidth6") as! Double
            }
            
            var columnWidth7: Double = 0.0
            if record.object(forKey: "columnWidth7") != nil
            {
                columnWidth7 = record.object(forKey: "columnWidth7") as! Double
            }
            
            var columnWidth8: Double = 0.0
            if record.object(forKey: "columnWidth8") != nil
            {
                columnWidth8 = record.object(forKey: "columnWidth8") as! Double
            }
            
            var columnWidth9: Double = 0.0
            if record.object(forKey: "columnWidth9") != nil
            {
                columnWidth9 = record.object(forKey: "columnWidth9") as! Double
            }
            
            var columnWidth10: Double = 0.0
            if record.object(forKey: "columnWidth10") != nil
            {
                columnWidth10 = record.object(forKey: "columnWidth10") as! Double
            }
            
            var columnWidth11: Double = 0.0
            if record.object(forKey: "columnWidth11") != nil
            {
                columnWidth11 = record.object(forKey: "columnWidth11") as! Double
            }
            
            var columnWidth12: Double = 0.0
            if record.object(forKey: "columnWidth12") != nil
            {
                columnWidth12 = record.object(forKey: "columnWidth12") as! Double
            }
            
            var columnWidth13: Double = 0.0
            if record.object(forKey: "columnWidth13") != nil
            {
                columnWidth13 = record.object(forKey: "columnWidth13") as! Double
            }
            
            var columnWidth14: Double = 0.0
            if record.object(forKey: "columnWidth14") != nil
            {
                columnWidth14 = record.object(forKey: "columnWidth14") as! Double
            }
            
            var reportID: Int64 = 0
            if record.object(forKey: "reportID") != nil
            {
                reportID = record.object(forKey: "reportID") as! Int64
            }
            
            var teamID: Int64 = 0
            if record.object(forKey: "teamID") != nil
            {
                teamID = record.object(forKey: "teamID") as! Int64
            }
            
            var systemReport: Bool = false
            if record.object(forKey: "systemReport") != nil
            {
                if record.object(forKey: "systemReport") as? String == "True"
                {
                    systemReport = true
                }
            }
            
            let tempItem = Reports(columnSource1: record.object(forKey: "columnSource1") as! String,
                                   columnSource2: record.object(forKey: "columnSource2") as! String,
                                   columnSource3: record.object(forKey: "columnSource3") as! String,
                                   columnSource4: record.object(forKey: "columnSource4") as! String,
                                   columnSource5: record.object(forKey: "columnSource5") as! String,
                                   columnSource6: record.object(forKey: "columnSource6") as! String,
                                   columnSource7: record.object(forKey: "columnSource7") as! String,
                                   columnSource8: record.object(forKey: "columnSource8") as! String,
                                   columnSource9: record.object(forKey: "columnSource9") as! String,
                                   columnSource10: record.object(forKey: "columnSource10") as! String,
                                   columnSource11: record.object(forKey: "columnSource11") as! String,
                                   columnSource12: record.object(forKey: "columnSource12") as! String,
                                   columnSource13: record.object(forKey: "columnSource13") as! String,
                                   columnSource14: record.object(forKey: "columnSource14") as! String,
                                   columnTitle1: record.object(forKey: "columnTitle1") as! String,
                                   columnTitle2: record.object(forKey: "columnTitle2") as! String,
                                   columnTitle3: record.object(forKey: "columnTitle3") as! String,
                                   columnTitle4: record.object(forKey: "columnTitle4") as! String,
                                   columnTitle5: record.object(forKey: "columnTitle5") as! String,
                                   columnTitle6: record.object(forKey: "columnTitle6") as! String,
                                   columnTitle7: record.object(forKey: "columnTitle7") as! String,
                                   columnTitle8: record.object(forKey: "columnTitle8") as! String,
                                   columnTitle9: record.object(forKey: "columnTitle9") as! String,
                                   columnTitle10: record.object(forKey: "columnTitle10") as! String,
                                   columnTitle11: record.object(forKey: "columnTitle11") as! String,
                                   columnTitle12: record.object(forKey: "columnTitle12") as! String,
                                   columnTitle13: record.object(forKey: "columnTitle13") as! String,
                                   columnTitle14: record.object(forKey: "columnTitle14") as! String,
                                   columnWidth1: columnWidth1,
                                   columnWidth2: columnWidth2,
                                   columnWidth3: columnWidth3,
                                   columnWidth4: columnWidth4,
                                   columnWidth5: columnWidth5,
                                   columnWidth6: columnWidth6,
                                   columnWidth7: columnWidth7,
                                   columnWidth8: columnWidth8,
                                   columnWidth9: columnWidth9,
                                   columnWidth10: columnWidth10,
                                   columnWidth11: columnWidth11,
                                   columnWidth12: columnWidth12,
                                   columnWidth13: columnWidth13,
                                   columnWidth14: columnWidth14,
                                   orientation: record.object(forKey: "orientation") as! String,
                                   reportDescription: record.object(forKey: "reportDescription") as! String,
                                   reportID: reportID,
                                   reportTitle: record.object(forKey: "reportTitle") as! String,
                                   reportType: record.object(forKey: "reportType") as! String,
                                   selectionCriteria1: record.object(forKey: "selectionCriteria1") as! String,
                                   selectionCriteria2: record.object(forKey: "selectionCriteria2") as! String,
                                   selectionCriteria3: record.object(forKey: "selectionCriteria3") as! String,
                                   selectionCriteria4: record.object(forKey: "selectionCriteria4") as! String,
                                   sortOrder1: record.object(forKey: "sortOrder1") as! String,
                                   sortOrder2: record.object(forKey: "sortOrder2") as! String,
                                   sortOrder3: record.object(forKey: "sortOrder3") as! String,
                                   sortOrder4: record.object(forKey: "sortOrder4") as! String,
                                   systemReport: systemReport,
                                   teamID: teamID)
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getReports(teamID: Int64)->[Reports]
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) && (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Reports", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Reports] = populateReports(returnArray)
        
        return shiftArray
    }
    
    func getReports(teamID: Int64, reportType: String)->[Reports]
    {
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (reportType == \"\(reportType)\") AND (updateType != \"Delete\")")
        
        let query = CKQuery(recordType: "Reports", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Reports] = populateReports(returnArray)
        
        return shiftArray
    }
    
    func getReportDetails(_ reportID: Int64, teamID: Int64)->[Reports]
    {
        let predicate = NSPredicate(format: "(reportID == \(reportID))AND (teamID == \(teamID))")
        
        let query = CKQuery(recordType: "Reports", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        let shiftArray: [Reports] = populateReports(returnArray)
        
        return shiftArray
    }
    
    func deleteReport(_ reportID: Int64, teamID: Int64)
    {
        let predicate = NSPredicate(format: "(reportID == \(reportID))AND (teamID == \(teamID))")
        
        let sem = DispatchSemaphore(value: 0)
        
        let query = CKQuery(recordType: "Reports", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            self.performPublicDelete(records!)
            
            sem.signal()
        })
        sem.wait()
    }
    
    func saveReportsRecordToCloudKit(_ sourceRecord: Reports)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(reportID == \(sourceRecord.reportID)) AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "reports", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else
            {
                // Lets go and get the additional details from the context1_1 table
                
                if records!.count > 0
                {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    
                    record!.setValue(sourceRecord.reportTitle, forKey: "reportTitle")
                    record!.setValue(sourceRecord.reportDescription, forKey: "reportDescription")
                    record!.setValue(sourceRecord.reportType, forKey: "reportType")
                    if sourceRecord.systemReport
                    {
                        record!.setValue("True", forKey: "systemReport")
                    }
                    else
                    {
                        record!.setValue("False", forKey: "systemReport")
                    }
                    record!.setValue(sourceRecord.columnTitle1, forKey: "columnTitle1")
                    record!.setValue(sourceRecord.columnSource1, forKey: "columnSource1")
                    record!.setValue(sourceRecord.columnWidth1, forKey: "columnWidth1")
                    record!.setValue(sourceRecord.columnTitle2, forKey: "columnTitle2")
                    record!.setValue(sourceRecord.columnSource2, forKey: "columnSource2")
                    record!.setValue(sourceRecord.columnWidth2, forKey: "columnWidth2")
                    record!.setValue(sourceRecord.columnTitle3, forKey: "columnTitle3")
                    record!.setValue(sourceRecord.columnSource3, forKey: "columnSource3")
                    record!.setValue(sourceRecord.columnWidth3, forKey: "columnWidth3")
                    record!.setValue(sourceRecord.columnTitle4, forKey: "columnTitle4")
                    record!.setValue(sourceRecord.columnSource4, forKey: "columnSource4")
                    record!.setValue(sourceRecord.columnWidth4, forKey: "columnWidth4")
                    record!.setValue(sourceRecord.columnTitle5, forKey: "columnTitle5")
                    record!.setValue(sourceRecord.columnSource5, forKey: "columnSource5")
                    record!.setValue(sourceRecord.columnWidth5, forKey: "columnWidth5")
                    record!.setValue(sourceRecord.columnTitle6, forKey: "columnTitle6")
                    record!.setValue(sourceRecord.columnSource6, forKey: "columnSource6")
                    record!.setValue(sourceRecord.columnWidth6, forKey: "columnWidth6")
                    record!.setValue(sourceRecord.columnTitle7, forKey: "columnTitle7")
                    record!.setValue(sourceRecord.columnSource7, forKey: "columnSource7")
                    record!.setValue(sourceRecord.columnWidth7, forKey: "columnWidth7")
                    record!.setValue(sourceRecord.columnTitle8, forKey: "columnTitle8")
                    record!.setValue(sourceRecord.columnSource8, forKey: "columnSource8")
                    record!.setValue(sourceRecord.columnWidth8, forKey: "columnWidth8")
                    record!.setValue(sourceRecord.columnTitle9, forKey: "columnTitle9")
                    record!.setValue(sourceRecord.columnSource9, forKey: "columnSource9")
                    record!.setValue(sourceRecord.columnWidth9, forKey: "columnWidth9")
                    record!.setValue(sourceRecord.columnTitle10, forKey: "columnTitle10")
                    record!.setValue(sourceRecord.columnSource10, forKey: "columnSource10")
                    record!.setValue(sourceRecord.columnWidth10, forKey: "columnWidth10")
                    record!.setValue(sourceRecord.columnTitle11, forKey: "columnTitle11")
                    record!.setValue(sourceRecord.columnSource11, forKey: "columnSource11")
                    record!.setValue(sourceRecord.columnWidth11, forKey: "columnWidth11")
                    record!.setValue(sourceRecord.columnTitle12, forKey: "columnTitle12")
                    record!.setValue(sourceRecord.columnSource12, forKey: "columnSource12")
                    record!.setValue(sourceRecord.columnWidth12, forKey: "columnWidth12")
                    record!.setValue(sourceRecord.columnTitle13, forKey: "columnTitle13")
                    record!.setValue(sourceRecord.columnSource13, forKey: "columnSource13")
                    record!.setValue(sourceRecord.columnWidth13, forKey: "columnWidth13")
                    record!.setValue(sourceRecord.columnWidth14, forKey: "columnWidth14")
                    record!.setValue(sourceRecord.columnTitle14, forKey: "columnTitle14")
                    record!.setValue(sourceRecord.columnSource14, forKey: "columnSource14")
                    record!.setValue(sourceRecord.selectionCriteria1, forKey: "selectionCriteria1")
                    record!.setValue(sourceRecord.selectionCriteria2, forKey: "selectionCriteria2")
                    record!.setValue(sourceRecord.selectionCriteria3, forKey: "selectionCriteria3")
                    record!.setValue(sourceRecord.selectionCriteria4, forKey: "selectionCriteria4")
                    record!.setValue(sourceRecord.sortOrder1, forKey: "sortOrder1")
                    record!.setValue(sourceRecord.sortOrder2, forKey: "sortOrder2")
                    record!.setValue(sourceRecord.sortOrder3, forKey: "sortOrder3")
                    record!.setValue(sourceRecord.sortOrder4, forKey: "sortOrder4")
                    record!.setValue(sourceRecord.orientation, forKey: "orientation")
                    
                    // Save this record again
                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                            self.saveOK = false
                            sem.signal()
                        }
                        else
                        {
                            if debugMessages
                            {
                                NSLog("Successfully updated record!")
                            }
                            sem.signal()
                        }
                    })
                }
                else
                {  // Insert
                    let record = CKRecord(recordType: "reports")
                    
                    record.setValue(sourceRecord.reportID, forKey: "reportID")
                    record.setValue(sourceRecord.reportTitle, forKey: "reportTitle")
                    record.setValue(sourceRecord.reportDescription, forKey: "reportDescription")
                    record.setValue(sourceRecord.reportType, forKey: "reportType")
                    if sourceRecord.systemReport
                    {
                        record.setValue("True", forKey: "systemReport")
                    }
                    else
                    {
                        record.setValue("False", forKey: "systemReport")
                    }
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    record.setValue(sourceRecord.columnTitle1, forKey: "columnTitle1")
                    record.setValue(sourceRecord.columnSource1, forKey: "columnSource1")
                    record.setValue(sourceRecord.columnWidth1, forKey: "columnWidth1")
                    record.setValue(sourceRecord.columnTitle2, forKey: "columnTitle2")
                    record.setValue(sourceRecord.columnSource2, forKey: "columnSource2")
                    record.setValue(sourceRecord.columnWidth2, forKey: "columnWidth2")
                    record.setValue(sourceRecord.columnTitle3, forKey: "columnTitle3")
                    record.setValue(sourceRecord.columnSource3, forKey: "columnSource3")
                    record.setValue(sourceRecord.columnWidth3, forKey: "columnWidth3")
                    record.setValue(sourceRecord.columnTitle4, forKey: "columnTitle4")
                    record.setValue(sourceRecord.columnSource4, forKey: "columnSource4")
                    record.setValue(sourceRecord.columnWidth4, forKey: "columnWidth4")
                    record.setValue(sourceRecord.columnTitle5, forKey: "columnTitle5")
                    record.setValue(sourceRecord.columnSource5, forKey: "columnSource5")
                    record.setValue(sourceRecord.columnWidth5, forKey: "columnWidth5")
                    record.setValue(sourceRecord.columnTitle6, forKey: "columnTitle6")
                    record.setValue(sourceRecord.columnSource6, forKey: "columnSource6")
                    record.setValue(sourceRecord.columnWidth6, forKey: "columnWidth6")
                    record.setValue(sourceRecord.columnTitle7, forKey: "columnTitle7")
                    record.setValue(sourceRecord.columnSource7, forKey: "columnSource7")
                    record.setValue(sourceRecord.columnWidth7, forKey: "columnWidth7")
                    record.setValue(sourceRecord.columnTitle8, forKey: "columnTitle8")
                    record.setValue(sourceRecord.columnSource8, forKey: "columnSource8")
                    record.setValue(sourceRecord.columnWidth8, forKey: "columnWidth8")
                    record.setValue(sourceRecord.columnTitle9, forKey: "columnTitle9")
                    record.setValue(sourceRecord.columnSource9, forKey: "columnSource9")
                    record.setValue(sourceRecord.columnWidth9, forKey: "columnWidth9")
                    record.setValue(sourceRecord.columnTitle10, forKey: "columnTitle10")
                    record.setValue(sourceRecord.columnSource10, forKey: "columnSource10")
                    record.setValue(sourceRecord.columnWidth10, forKey: "columnWidth10")
                    record.setValue(sourceRecord.columnTitle11, forKey: "columnTitle11")
                    record.setValue(sourceRecord.columnSource11, forKey: "columnSource11")
                    record.setValue(sourceRecord.columnWidth11, forKey: "columnWidth11")
                    record.setValue(sourceRecord.columnTitle12, forKey: "columnTitle12")
                    record.setValue(sourceRecord.columnSource12, forKey: "columnSource12")
                    record.setValue(sourceRecord.columnWidth12, forKey: "columnWidth12")
                    record.setValue(sourceRecord.columnTitle13, forKey: "columnTitle13")
                    record.setValue(sourceRecord.columnSource13, forKey: "columnSource13")
                    record.setValue(sourceRecord.columnWidth13, forKey: "columnWidth13")
                    record.setValue(sourceRecord.columnWidth14, forKey: "columnWidth14")
                    record.setValue(sourceRecord.columnTitle14, forKey: "columnTitle14")
                    record.setValue(sourceRecord.columnSource14, forKey: "columnSource14")
                    record.setValue(sourceRecord.selectionCriteria1, forKey: "selectionCriteria1")
                    record.setValue(sourceRecord.selectionCriteria2, forKey: "selectionCriteria2")
                    record.setValue(sourceRecord.selectionCriteria3, forKey: "selectionCriteria3")
                    record.setValue(sourceRecord.selectionCriteria4, forKey: "selectionCriteria4")
                    record.setValue(sourceRecord.sortOrder1, forKey: "sortOrder1")
                    record.setValue(sourceRecord.sortOrder2, forKey: "sortOrder2")
                    record.setValue(sourceRecord.sortOrder3, forKey: "sortOrder3")
                    record.setValue(sourceRecord.sortOrder4, forKey: "sortOrder4")
                    record.setValue(sourceRecord.orientation, forKey: "orientation")
                    
                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                            self.saveOK = false
                            sem.signal()
                        }
                        else
                        {
                            if debugMessages
                            {
                                NSLog("Successfully saved record!")
                            }
                            sem.signal()
                        }
                    })
                }
            }
        })
        sem.wait()
    }
}
