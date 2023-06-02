//
//  ChangeDetailViewController.swift
//  CourtCache
//
//  Created by Yu Xuan Yio on 2/6/2023.
//

import UIKit
import FirebaseAuth

class ChangeDetailViewController: UIViewController {
    
    var detailType = ""
    var userDetail = User()
    let currentAuthUser = Auth.auth().currentUser
    weak var databaseController: DatabaseProtocol?
    var appDelegate = {
        return UIApplication.shared.delegate as! AppDelegate
    }()

    @IBOutlet weak var oldDetailLabel: UILabel!
    @IBOutlet weak var oldDetailTextField: UITextField!
    @IBOutlet weak var newDetailLabel: UILabel!
    @IBOutlet weak var newDetailTextField: UITextField!
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        if detailType == "Email" {
            if ((newDetailTextField.text?.isEmpty) == nil) {
                displayMessage(title: "Error", message: "Please enter a valid Email")
            }
            guard let newEmail = newDetailTextField.text else {
                return
            }
            currentAuthUser?.updateEmail(to: newEmail) { error in
              if let error = error {
                  self.displayMessage(title: "Error", message: error.localizedDescription)
              } else {
                  self.displayMessageDismissAction(title: "Success", message: "Please check your new email for the confirmation")
              }
            }
        } else {
            if ((newDetailTextField.text?.isEmpty) == nil) {
                displayMessage(title: "Error", message: "Please enter a valid Username")
            }
            guard let username = newDetailTextField.text else {
                return
            }
            databaseController?.updateUserUsername(username: username)
        }
    }
    
    override func viewDidLoad() {
        databaseController = appDelegate.databaseController
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        oldDetailTextField.isUserInteractionEnabled = false
        if detailType == "Email" {
            navigationItem.title = "Change Email"
            oldDetailLabel.text = "Current Email:"
            oldDetailTextField.text = currentAuthUser?.email
            newDetailLabel.text = "New Email:"
        } else {
            navigationItem.title = "Change Username"
            oldDetailLabel.text = "Current Username:"
            oldDetailTextField.text = userDetail.username
            newDetailLabel.text = "New Username:"
        }
    }
    
    func displayMessageDismissAction(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,  preferredStyle: .alert)
        let alertActionDimiss = UIAlertAction(title: "Dismiss", style: .default) {
            (action) in
            self.navigationController?.popToRootViewController(animated: true)
        }
        alertController.addAction(alertActionDimiss)
        self.present(alertController, animated: true, completion: nil)
    }

}
