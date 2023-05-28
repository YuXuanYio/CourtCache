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
    var database: Firestore
    var usersRef: CollectionReference?
    
    override init() {
        FirebaseApp.configure()
        database = Firestore.firestore()
        usersRef = database.collection("users")
    }

    func cleanup() {
        return
    }
    
    func addListener(listener: DatabaseListener) {
        return
    }
    
    func removeListener(listener: DatabaseListener) {
        return
    }
    
    func createUser(username: String, email: String, uid: String) -> User {
        let user = User()
        user.username = username
        user.email = email

        let userRef = usersRef?.document(uid)
        
        do {
            try userRef?.setData(from: user)
        } catch {
            print("Failed to serialize user")
        }
        
        return user
    }
}
