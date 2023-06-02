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
    
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        if self.emailTextField.text == "" {
            self.displayMessage(title: "Error", message: "Please enter an email to reset your password")
        }
        displayMessageConfirmForgot(title: "Confirmation of password reset", message: "An email will be sent to your email for you to reset your password")
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
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        authHandle = auth.addStateDidChangeListener() {
            (auth, user) in
            guard user != nil else {return}
            self.databaseController?.currentUser = user
            self.databaseController?.setUpCardsListener()
            self.databaseController?.setUpUserListener()
            self.performSegue(withIdentifier: "toMainSegue", sender: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let authHandle = authHandle else {
            return
        }
        auth.removeStateDidChangeListener(authHandle)
    }
    
    func displayMessageConfirmForgot(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,  preferredStyle: .alert)
        let alertActionNo = UIAlertAction(title: "No", style: .default) {
            (action) in
            return
        }
        let alertActionYes = UIAlertAction(title: "Yes", style: .default) {
            (action) in
            self.auth.sendPasswordReset(withEmail: self.emailTextField.text ?? "test@test.com") {
                error in
                if let error = error {
                    self.displayMessage(title: "Error", message: error.localizedDescription)
                } else {
                    self.displayMessage(title: "Success", message: "Please check your email for a link to reset your password")
                }
            }
        }
        alertController.addAction(alertActionNo)
        alertController.addAction(alertActionYes)
        self.present(alertController, animated: true, completion: nil)
    }

}
