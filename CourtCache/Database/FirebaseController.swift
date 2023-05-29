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
    var currentUser: FirebaseAuth.User?
    
    override init() {
        FirebaseApp.configure()
        database = Firestore.firestore()
        usersRef = database.collection("users")
        super.init()
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
    
    func createUser(username: String, email: String, firebaseUser: FirebaseAuth.User) {
        let user = User()
        user.username = username
        user.email = email
        
        let userRef = usersRef?.document(firebaseUser.uid)
        
        do {
            try userRef?.setData(from: user)
        } catch {
            print("Failed to serialize user")
        }
        currentUser = firebaseUser
    }
    
    func addUserCard(player: String, team: String, year: String, set: String, variant: String, numbered: Bool, number: String, auto: Bool, patch: Bool) {
        guard let uid = currentUser?.uid else {
            return
        }
        let card = Card()
        card.player = player
        card.team = team
        card.year = year
        card.set = set
        card.variant = variant
        card.numbered = numbered
        card.number = number
        card.auto = auto
        card.patch = patch
        do {
            try usersRef?.document(uid).collection(team).addDocument(from: card)
        } catch {
            print("Failed to serialise card")
        }
    }
}
