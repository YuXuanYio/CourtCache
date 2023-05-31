//
//  ProfileViewController.swift
//  CourtCache
//
//  Created by Yu Xuan Yio on 28/5/2023.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DatabaseListener {
    
    var listenerType: ListenerType = .user
    var authHandle: AuthStateDidChangeListenerHandle?
    weak var databaseController: DatabaseProtocol?
    var appDelegate = {
        return UIApplication.shared.delegate as! AppDelegate
    }()
    var userDetails: User?
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var updateTimer: Timer?

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var totalCardsLabel: UILabel!
    @IBOutlet weak var rookiesLabel: UILabel!
    @IBOutlet weak var autosLabel: UILabel!
    @IBOutlet weak var slabsLabel: UILabel!
    
    @IBAction func choosePhotoPressed(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self

        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                print("Camera not available")
            }
        }))

        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        self.tabBarController?.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        databaseController = appDelegate.databaseController
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Profile"
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        emailTextField.isUserInteractionEnabled = false
        usernameTextField.isUserInteractionEnabled = false
// Commented out because user can't edit profile yet
//        emailTextField.delegate = self
//        usernameTextField.delegate = self
//        hideKeyboardWhenTappedAround()
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        super.viewDidLoad()
//        updateTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateUserData), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateTimer?.invalidate()
        updateTimer = nil
        databaseController?.removeListener(listener: self)
    }
    
    func onCardsChange(change: DatabaseChange, cards: [Card]) {
        return
    }
    
    func onUserValueChange(change: DatabaseChange, user: User) {
        userDetails = user
        reloadData()
    }
    
    
//    @objc func updateUserData() {
//        // Fetch the user data and update the view
//        if userDetails == nil {
//            userDetails = databaseController?.currentUserProfile
//            self.reloadData()
//        } else {
//            // If userDetails is not nil, stop the timer
//            updateTimer?.invalidate()
//            updateTimer = nil
//        }
//    }
    
    func reloadData() {
        if let totalCards = userDetails?.totalCards, let rookies = userDetails?.rookies, let autos = userDetails?.autos, let slabs = userDetails?.slabs, let email = userDetails?.email, let username = userDetails?.username {
            emailTextField.text = email
            usernameTextField.text = username
            
            totalCardsLabel.text = String(totalCards)
            rookiesLabel.text = String(rookies)
            autosLabel.text = String(autos)
            slabsLabel.text = String(slabs)
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        profileImageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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
