//
//  DatabaseProtocol.swift
//  CourtCache
//
//  Created by Yu Xuan Yio on 28/5/2023.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case all
    case cards
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onCardsChange(change: DatabaseChange, cards: [Card])
}

protocol DatabaseProtocol: AnyObject {
    var currentUser: FirebaseAuth.User? {get set}
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func createUser(username: String, email: String, firebaseUser: FirebaseAuth.User)
    func addUserCard(player: String, team: String, year: String, rookie: Bool, set: String, variant: String, numbered: Bool, number: String, auto: Bool, patch: Bool, graded: Bool?, grade: String?, imageData: Data)
    func addUserCardImageToCoreData(imagePath: String, imageData: Data, uid: String) 
    func setUpCardsListener()
}
