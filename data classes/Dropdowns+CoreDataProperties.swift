//
//  Dropdowns+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation
import CoreData


extension Dropdowns {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Dropdowns> {
        return NSFetchRequest<Dropdowns>(entityName: "Dropdowns")
    }

    @NSManaged public var dropDownType: String?
    @NSManaged public var dropDownValue: String?
    @NSManaged public var teamID: Int64
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
