//
//  FirebaseController.swift
//  CourtCache
//
//  Created by Yu Xuan Yio on 29/4/2023.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseController: NSObject, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var auth = Auth.auth()

    func cleanup() {
        return
    }
    
    func addListener(listener: DatabaseListener) {
        return
    }
    
    func removeListener(listener: DatabaseListener) {
        return
    }
    
    func createUser(uid: String) {
        <#code#>
    }
    
}
