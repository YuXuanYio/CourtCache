//
//  ProfileViewController.swift
//  CourtCache
//
//  Created by Yu Xuan Yio on 28/5/2023.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController, DatabaseListener {
    
    var listenerType: ListenerType = .user
    var authHandle: AuthStateDidChangeListenerHandle?
    weak var databaseController: DatabaseProtocol?
    var appDelegate = {
        return UIApplication.shared.delegate as! AppDelegate
    }()
    var userDetails: User?
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var updateTimer: Timer?
    let currentAuthUser = Auth.auth().currentUser

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var bottomRightView: UIView!
    @IBOutlet weak var bottomLeftView: UIView!
    @IBOutlet weak var topLeftView: UIView!
    @IBOutlet weak var topRightView: UIView!
    
    @IBOutlet weak var totalCardsLabel: UILabel!
    @IBOutlet weak var rookiesLabel: UILabel!
    @IBOutlet weak var autosLabel: UILabel!
    @IBOutlet weak var slabsLabel: UILabel!
    
    
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
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        super.viewDidLoad()
        updateTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateUserData), userInfo: nil, repeats: true)
        initViews()
        navigationController?.navigationBar.prefersLargeTitles = true
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
    
    func reloadData() {
        if let totalCards = userDetails?.totalCards, let rookies = userDetails?.rookies, let autos = userDetails?.autos, let slabs = userDetails?.slabs, let username = userDetails?.username {
            emailLabel.text = currentAuthUser?.email
            usernameLabel.text = username
            
            totalCardsLabel.text = String(totalCards)
            rookiesLabel.text = String(rookies)
            autosLabel.text = String(autos)
            slabsLabel.text = String(slabs)
            
        }
    }
    
    @objc func updateUserData() {
        // Fetch the user data and update the view
        if userDetails?.username == nil {
            userDetails = databaseController?.currentUserProfile
            self.reloadData()
        } else {
            // If userDetails is not nil, stop the timer
            updateTimer?.invalidate()
            updateTimer = nil
        }
    }
    
    func initViews() {
        bottomLeftView.layer.cornerRadius = 20
        bottomRightView.layer.cornerRadius = 20
        topLeftView.layer.cornerRadius = 20
        topRightView.layer.cornerRadius = 20
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editProfileSegue" {
            let destination = segue.destination as! EditProfileViewController
            guard let userDetails = userDetails else {
                return
            }
            destination.userDetail = userDetails
        }
    }

}
