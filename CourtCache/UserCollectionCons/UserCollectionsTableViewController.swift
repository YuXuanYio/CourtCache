//
//  UserCollectionsTableViewController.swift
//  CourtCache
//
//  Created by Yu Xuan Yio on 29/5/2023.
//

import UIKit
import CoreData

class UserCollectionsTableViewController: UITableViewController, DatabaseListener, UISearchBarDelegate {

    var listenerType: ListenerType = .cards
    weak var databaseController: DatabaseProtocol?
    var appDelegate = {
        return UIApplication.shared.delegate as! AppDelegate
    }()
    let CELL_CARD = "cardCell"
    var cardList: [Card] = []
    var userCollection: [(String, Int, [Card])] = []
    var searchedCollection: [(String, Int, [Card])] = []
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseController = appDelegate.databaseController
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Your Collection"
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
    }
    
    func onCardsChange(change: DatabaseChange, cards: [Card]) {
        userCollection = []
        cardList = cards
        for card in cardList {
            guard let team = card.team else {
                continue
            }
            if let index = userCollection.firstIndex(where: { $0.0 == team }) {
                // Increment the count of the found team
                userCollection[index].1 += 1
                userCollection[index].2.append(card)
            } else {
                // If the team is not in the list, add it with a count of 1
                userCollection.append((team, 1, [card]))
            }
        }
        searchedCollection = userCollection
        tableView.reloadData()
    }
    
    func onUserValueChange(change: DatabaseChange, user: User) {
        return
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func loadImageData(card: Card) async -> UIImage? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imageURL = documentsDirectory.appendingPathComponent(card.imagePath ?? "")
        if let image = UIImage(contentsOfFile: imageURL.path) {
            return image
        } else {
            // Image not found in local file system, download from Firebase
            if let url = URL(string: card.imageURL ?? "") {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let image = UIImage(data: data)
                    let imageData = image?.jpegData(compressionQuality: 0.75) ?? Data()
                    self.databaseController?.addUserCardImageToCoreData(imagePath: card.imagePath ?? "", imageData: imageData ?? Data(), uid: self.databaseController?.currentUser?.uid ?? "")
                    return image
                } catch {
                    print("Error downloading image from Firebase: \(error)")
                    return nil
                }
            }
        }
        return nil
    }
    
    func loadImageDataFromCoreData(filename: String) -> UIImage? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]

        let imageURL = documentsDirectory.appendingPathComponent(filename)
        let image = UIImage(contentsOfFile: imageURL.path)
        
        return image
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedCollection = []
        if searchText.isEmpty {
            searchedCollection = userCollection
        } else {
            for tuple in userCollection {
                let team = tuple.0
                let cards = tuple.2
                if team.lowercased().contains(searchText.lowercased()) {
                    // If the team name contains the search text, include all of the team's cards in the searched collection.
                    searchedCollection.append(tuple)
                } else {
                    // Otherwise, filter the team's cards based on the player's name.
                    let filteredCards = cards.filter { card in
                        guard let player = card.player else { return false }
                        return player.lowercased().contains(searchText.lowercased())
                    }
                    if !filteredCards.isEmpty {
                        searchedCollection.append((team, filteredCards.count, filteredCards))
                    }
                }
            }
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchedCollection = userCollection
        tableView.reloadData()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if cardList.count > 0 {
            return searchedCollection.count
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cardList.count > 0 {
            return searchedCollection[section].1
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if cardList.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_CARD, for: indexPath) as! UserCollectionTableViewCell
            let card = searchedCollection[indexPath.section].2[indexPath.row]
            cell.yearLabel.text = card.year
            cell.playerNameLabel.text = card.player
            cell.setLabel.text = "\(String(describing: card.set!))" + ", " + "\(String(describing: card.variant!))"
            cell.cardCellImageView.image = nil
            Task {
                DispatchQueue.main.async {
                    self.activityIndicator.startAnimating()
                }
                let image = await loadImageData(card: card)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    // Check if this cell is still being used for the same index path
                    guard let currentIndexPath = tableView.indexPath(for: cell), currentIndexPath == indexPath else { return }
                    cell.cardCellImageView.image = image
                }
            }
            guard let graded = card.graded else {
                cell.gradeLabel.text = "Error getting grade"
                return cell
            }
            if graded {
                cell.gradeLabel.text = card.grade
            } else {
                cell.gradeLabel.text = "Raw"
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "No cards in your collection. Add some!"
            cell.contentConfiguration = content
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if cardList.count > 0 {
            return searchedCollection[section].0
        }
        return ""
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if cardList.count > 0 {
            return true
        }
        return false
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // NOTE: Delete from database!!! Find out how to clear the firebase photo as well.
            let card = searchedCollection[indexPath.section].2[indexPath.row]
            databaseController?.deleteCard(card: card)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cardList.count > 0 {
            performSegue(withIdentifier: "viewCardSegue", sender: nil)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewCardSegue" {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as! CardViewController
                let card = searchedCollection[selectedIndexPath.section].2[selectedIndexPath.row]
                destination.card = card
                destination.cardImage = loadImageDataFromCoreData(filename: card.imagePath ?? "") ?? UIImage()
            }
        }
    }

}
