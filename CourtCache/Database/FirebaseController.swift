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
import CoreData

class FirebaseController: NSObject, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var database: Firestore
    var usersRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    var cardList: [Card]
    var cardRef: CollectionReference?
    var managedObjectContext: NSManagedObjectContext?

    override init() {
        FirebaseApp.configure()
        database = Firestore.firestore()
        usersRef = database.collection("users")
        cardList = [Card]()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer?.viewContext

        super.init()
    }

    func cleanup() {
        return
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)

        if listener.listenerType == .cards || listener.listenerType == .all {
            listener.onCardsChange(change: .update, cards: cardList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
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
    
    func addUserCard(player: String, team: String, year: String, rookie: Bool, set: String, variant: String, numbered: Bool, number: String, auto: Bool, patch: Bool, graded: Bool?, grade: String?, imageData: Data) {
        
        guard let uid = currentUser?.uid else {
            return
        }
        let card = Card()
        card.player = player
        card.team = team
        card.year = year
        card.rookie = rookie
        card.set = set
        card.variant = variant
        card.numbered = numbered
        card.number = number
        card.auto = auto
        card.patch = patch
        card.graded = graded
        card.grade = grade
        // NOTE: Add uniqueID path of image to card and try storing into coredata again. 
        
        let uniqueID = UUID().uuidString
        let storageRef = Storage.storage().reference().child("images/\(uid)/\(uniqueID).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        card.imagePath = "images/\(uid)/\(uniqueID).jpg"
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
                self.addUserCardImageToCoreData(imagePath: card.imagePath!, imageData: imageData, uid: uid)
                // Then, save the card to Firestore.
                do {
                    try self.usersRef?.document(uid).collection("cards").document(uniqueID).setData(from: card)
                } catch {
                    print("Failed to serialise card")
                }
            }
        }
    }
    
    func addUserCardImageToCoreData(imagePath: String, imageData: Data, uid: String) {
        let pathsList = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = pathsList[0]
        let imageFile = documentDirectory.appendingPathComponent(imagePath)
        let imageDirectory = imageFile.deletingLastPathComponent()

        do {
            try FileManager.default.createDirectory(at: imageDirectory, withIntermediateDirectories: true, attributes: nil)
            try imageData.write(to: imageFile)
            let cardImageEntity = NSEntityDescription.insertNewObject(forEntityName: "CardImageMetaData", into: managedObjectContext!) as! CardImageMetaData
            cardImageEntity.uid = uid
            cardImageEntity.filename = imagePath
            try managedObjectContext?.save()
        } catch {
            print("Error storing image into local storage: \(error)")
        }
    }
    
    func setUpCardsListener() {
        guard let uid = currentUser?.uid else {
            return
        }
        cardRef = database.collection("users").document(uid).collection("cards")
        cardRef?.addSnapshotListener() {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseCardsSnapshot(snapshot: querySnapshot)
        }
    }
    
    func parseCardsSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach {
            (change) in
            var parsedCard: Card?
            do {
                parsedCard = try change.document.data(as: Card.self)
            } catch {
                print("Unable to decode card. Is the card malformed?")
                return
            }
            guard let card = parsedCard else {
                print("Document doesn't exist")
                return;
            }
            if change.type == .added {
                cardList.insert(card, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                cardList[Int(change.oldIndex)] = card
            }
            else if change.type == .removed {
                cardList.remove(at: Int(change.oldIndex))
            }
            listeners.invoke {
                (listener) in
                if listener.listenerType == ListenerType.cards || listener.listenerType == ListenerType.all {
                    listener.onCardsChange(change: .update, cards: cardList)
                }
            }
        }
    }
    
}
