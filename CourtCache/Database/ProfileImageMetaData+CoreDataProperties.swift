//
//  ProfileImageMetaData+CoreDataProperties.swift
//  CourtCache
//
//  Created by Yu Xuan Yio on 1/6/2023.
//
//

import Foundation
import CoreData


extension ProfileImageMetaData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProfileImageMetaData> {
        return NSFetchRequest<ProfileImageMetaData>(entityName: "ProfileImageMetaData")
    }

    @NSManaged public var filename: String?
    @NSManaged public var uid: String?

}

extension ProfileImageMetaData : Identifiable {

}
