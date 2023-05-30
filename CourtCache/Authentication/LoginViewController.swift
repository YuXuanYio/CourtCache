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
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        guard let password = passwordTextField.text else {
            displayMessage(title: "Error", message: "Please enter a password")
            self.activityIndicator.stopAnimating()
            return
        }
        guard let email = emailTextField.text else {
            displayMessage(title: "Error", message: "Please enter an email")
            self.activityIndicator.stopAnimating()
            return
        }
        auth.signIn(withEmail: email, password: password) {
            (user, error) in
            if let error = error {
                self.displayMessage(title: "Error", message: error.localizedDescription)
                self.activityIndicator.stopAnimating()
                return
            }
        }
        self.databaseController?.setUpCardsListener()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.activityIndicator.stopAnimating()
//            self.performSegue(withIdentifier: "toMainSegue", sender: nil)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseController = appDelegate.databaseController
        emailTextField.delegate = self
        passwordTextField.delegate = self
        hideKeyboardWhenTappedAround()
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
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
