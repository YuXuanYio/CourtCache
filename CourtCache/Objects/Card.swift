//
//  Card.swift
//  CourtCache
//
//  Created by Yu Xuan Yio on 28/5/2023.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift

class Card: NSObject, Codable {
    
    @DocumentID var id: String?
    var player: String?
    var team: String?
    var year: String?
    var set: String?
    var variant: String?
    var numbered: Bool?
    var number: String?
    var auto: Bool?
    var patch: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case player
        case team
        case year
        case set
        case variant
        case numbered
        case number
        case auto
        case patch
    }
}
