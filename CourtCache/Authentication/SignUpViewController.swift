//
//  SignUpViewController.swift
//  CourtCache
//
//  Created by Yu Xuan Yio on 28/5/2023.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    var authHandle: AuthStateDidChangeListenerHandle?
    var auth = Auth.auth()
    var appDelegate = {
        return UIApplication.shared.delegate as! AppDelegate
    }()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func signUpPressed(_ sender: Any) {
        guard let password = passwordTextField.text else {
            displayMessage(title: "Error", message: "Please enter a password")
            return
        }
        guard let email = emailTextField.text else {
            displayMessage(title: "Error", message: "Please enter an email")
            return
        }
        guard let username = usernameTextField.text else {
            displayMessage(title: "Error", message: "Please enter a valid username")
            return
        }
        auth.createUser(withEmail: email, password: password) {
            (authResult, error) in
            if let error = error {
                self.displayMessage(title: "Error", message: error.localizedDescription)
            }
            if let authResult = authResult {
                self.databaseController?.createUser(username: username, email: email, firebaseUser: authResult.user)
                self.performSegue(withIdentifier: "toMainSegue", sender: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseController = appDelegate.databaseController
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
