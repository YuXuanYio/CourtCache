//
//  EditProfileViewController.swift
//  CourtCache
//
//  Created by Yu Xuan Yio on 2/6/2023.
//

import UIKit
import FirebaseAuth
    
class EditProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DatabaseListener {
    
    var listenerType: ListenerType = .user
    var userDetail: User = User()
    var defaultList = ["Email", "Username"]
    let currentAuthUser = Auth.auth().currentUser
    
    @IBOutlet weak var userDetailsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userDetailsTableView.dataSource = self
        userDetailsTableView.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Edit Account Details"
    }
    
    func onCardsChange(change: DatabaseChange, cards: [Card]) {
        return
    }
    
    func onUserValueChange(change: DatabaseChange, user: User) {
        return
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return defaultList.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailsCell", for: indexPath) as! AccountTableViewCell
        cell.setLabel.text = defaultList[indexPath.row]
        if indexPath.row == 0 {
            cell.detailsLabel.text = currentAuthUser?.email
        } else {
            cell.detailsLabel.text = userDetail.username
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetailSegue", sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailSegue" {
            if let selectedIndexPath = userDetailsTableView.indexPathForSelectedRow {
                let destination = segue.destination as! ChangeDetailViewController
                let detailType = defaultList[selectedIndexPath.row]
                destination.detailType = detailType
                destination.userDetail = userDetail
            }
        }
    }

}
