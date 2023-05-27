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
    var variant: String?
    var set: String?
    var numbered: Bool?
    var auto: Bool?
    
}
