//
//  CardImageMetaData+CoreDataProperties.swift
//  CourtCache
//
//  Created by Yu Xuan Yio on 30/5/2023.
//
//

import Foundation
import CoreData


extension CardImageMetaData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardImageMetaData> {
        return NSFetchRequest<CardImageMetaData>(entityName: "CardImageMetaData")
    }

    @NSManaged public var filename: String?
    @NSManaged public var uid: String?

}

extension CardImageMetaData : Identifiable {

}
