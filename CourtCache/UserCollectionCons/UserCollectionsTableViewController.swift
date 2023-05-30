//
//  UserCollectionsTableViewController.swift
//  CourtCache
//
//  Created by Yu Xuan Yio on 29/5/2023.
//

import UIKit
import CoreData

class UserCollectionsTableViewController: UITableViewController, DatabaseListener {

    var listenerType: ListenerType = .cards
    weak var databaseController: DatabaseProtocol?
    var appDelegate = {
        return UIApplication.shared.delegate as! AppDelegate
    }()
    let CELL_CARD = "cardCell"
    var cardList: [Card] = []
    var userCollection: [(String, Int, [Card])] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseController = appDelegate.databaseController
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
        print(userCollection)
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func loadImageData(filename: String) -> UIImage? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]

        let imageURL = documentsDirectory.appendingPathComponent(filename)
        let image = UIImage(contentsOfFile: imageURL.path)
        
        return image
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return userCollection.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userCollection[section].1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_CARD, for: indexPath) as! UserCollectionTableViewCell
        let card = userCollection[indexPath.section].2[indexPath.row]
        cell.yearLabel.text = card.year
        cell.playerNameLabel.text = card.player
        cell.setLabel.text = "\(String(describing: card.set!))" + ", " + "\(String(describing: card.variant!))"
        cell.cardCellImageView.image = loadImageData(filename: card.imagePath ?? "")
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
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return userCollection[section].0
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
