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
    var email: String?
    
}
