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
    weak var databaseController: DatabaseProtocol?
    var appDelegate = {
        return UIApplication.shared.delegate as! AppDelegate
    }()
    
    @IBOutlet weak var userDetailsTableView: UITableView!
    
    @IBAction func permanentlyDeletePressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Please re-enter your password", message: "", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.isSecureTextEntry = true
        }
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            guard let password = alertController.textFields?.first?.text else { return }
            let credential = EmailAuthProvider.credential(withEmail: self.currentAuthUser?.email ?? "", password: password)
            
            // Prompt the user for confirmation before deleting the account
            self.currentAuthUser?.reauthenticate(with: credential) { result, error in
                if let error = error {
                    self.displayMessage(title: "Error", message: error.localizedDescription)
                } else {
                    self.displayMessageConfirmDelete(title: "WARNING", message: "This cannot be undone. Are you sure you want to permanently delete your account? All data will be lost.")
                }
            }
        }
        alertController.addAction(confirmAction)
        present(alertController, animated: true)
    }
    
    override func viewDidLoad() {
        databaseController = appDelegate.databaseController
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
    
    func displayMessageConfirmDelete(title: String, message: String) {
        let tempUID = self.currentAuthUser?.uid
        let alertController = UIAlertController(title: title, message: message,  preferredStyle: .alert)
        let alertActionNo = UIAlertAction(title: "No", style: .default) {
            (action) in
            return
        }
        let alertActionYes = UIAlertAction(title: "Yes", style: .default) {
            (action) in
            self.databaseController?.deleteUser(uid: tempUID ?? "")
            self.currentAuthUser?.delete {
                error in
                if let error = error {
                    print(error)
                    self.displayMessage(title: "Error", message: error.localizedDescription)
                } else {
                    self.displayMessageDismissAction(title: "Sorry to see you go", message: "Thank you for being a user of this app!")
                }
            }
        }
        alertController.addAction(alertActionNo)
        alertController.addAction(alertActionYes)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayMessageDismissAction(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,  preferredStyle: .alert)
        let alertActionDimiss = UIAlertAction(title: "Dismiss", style: .default) {
            (action) in
            self.tabBarController?.navigationController?.popToRootViewController(animated: true)
        }
        alertController.addAction(alertActionDimiss)
        self.present(alertController, animated: true, completion: nil)
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
