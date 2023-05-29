//
//  AuthViewController.swift
//  CourtCache
//
//  Created by Yu Xuan Yio on 28/5/2023.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    var authHandle: AuthStateDidChangeListenerHandle?
    var auth = Auth.auth()
    var appDelegate = {
        return UIApplication.shared.delegate as! AppDelegate
    }()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBAction func loginPressed(_ sender: Any) {
        guard let password = passwordTextfield.text else {
            displayMessage(title: "Error", message: "Please enter a password")
            return
        }
        guard let email = emailTextField.text else {
            displayMessage(title: "Error", message: "Please enter an email")
            return
        }
        auth.signIn(withEmail: email, password: password) {
            (user, error) in
            if let error = error {
                self.displayMessage(title: "Error", message: error.localizedDescription)
            }
        }
        self.performSegue(withIdentifier: "toMainSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseController = appDelegate.databaseController
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        authHandle = auth.addStateDidChangeListener() {
            (auth, user) in
            guard user != nil else {return}
            self.databaseController?.currentUser = user
            self.databaseController?.setUpCardsListener()
            self.performSegue(withIdentifier: "toMainSegue", sender: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let authHandle = authHandle else {
            return
        }
        auth.removeStateDidChangeListener(authHandle)
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
