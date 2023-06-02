//
//  User.swift
//  CourtCache
//
//  Created by Yu Xuan Yio on 28/5/2023.
//

import Foundation
import FirebaseFirestoreSwift

class User: NSObject, Codable {
    
    @DocumentID var id: String?
    var username: String?
    var totalCards: Int?
    var rookies: Int?
    var autos: Int?
    var slabs: Int?
    var profileImageURL: String?
    var profileImagePath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case totalCards
        case rookies
        case autos
        case slabs
        case profileImageURL
        case profileImagePath
    }
    
}
