//
//  PersonAdditionalInfo+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 30/3/18.
//
//

import Foundation
import CoreData


extension PersonAdditionalInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersonAdditionalInfo> {
        return NSFetchRequest<PersonAdditionalInfo>(entityName: "PersonAdditionalInfo")
    }

    @NSManaged public var addInfoID: Int64
    @NSManaged public var addInfoName: String?
    @NSManaged public var addInfoType: String?
    @NSManaged public var teamID: Int64
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
