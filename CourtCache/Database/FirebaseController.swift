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
import FirebaseStorage

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
    
    func addUserCard(player: String, team: String, year: String, set: String, variant: String, numbered: Bool, number: String, auto: Bool, patch: Bool, graded: Bool?, grade: String?, imageData: Data) {
        
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
        card.graded = graded
        card.grade = grade
        
        let uniqueID = UUID().uuidString
        let storageRef = Storage.storage().reference().child("images/\(uid)/\(uniqueID).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        storageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            guard let metadata = metadata else {
                print("Failed to upload image")
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            print("Size of the uploaded image: \(size)")

            // Now that the upload is complete, get the download URL.
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Failed to get download URL")
                    return
                }
                // Set the download URL to the card.
                card.imageURL = downloadURL.absoluteString
                // Then, save the card to Firestore.
                do {
                    try self.usersRef?.document(uid).collection(team).document(uniqueID).setData(from: card)
                } catch {
                    print("Failed to serialise card")
                }
            }
        }
    }
    
    
    
}
