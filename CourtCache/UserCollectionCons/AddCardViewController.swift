//
//  AddCardViewController.swift
//  CourtCache
//
//  Created by Yu Xuan Yio on 29/5/2023.
//

import UIKit

class AddCardViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let NO = 0
    let YES = 1
    weak var databaseController: DatabaseProtocol?
    var appDelegate = {
        return UIApplication.shared.delegate as! AppDelegate
    }()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var passedImage: UIImage? = nil
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var playerTextField: UITextField!
    @IBOutlet weak var teamTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var rookieSegmenetedControl: UISegmentedControl!
    @IBOutlet weak var setTextField: UITextField!
    @IBOutlet weak var variantTextField: UITextField!
    @IBOutlet weak var numberedSegmentedControl: UISegmentedControl!
    @IBOutlet weak var numberedTextField: UITextField!
    @IBOutlet weak var autoSegmentedControl: UISegmentedControl!
    @IBOutlet weak var patchSegmentedControl: UISegmentedControl!
    @IBOutlet weak var gradedSegmentedControl: UISegmentedControl!
    @IBOutlet weak var gradedTextField: UITextField!
    @IBOutlet weak var addCardButton: UIButton!
    
    @IBAction func addCardPressed(_ sender: Any) {
        addCardButton.isEnabled = false
        activityIndicator.startAnimating()
        guard let image = cardImageView.image, let placeholderImage = UIImage(named: "tapToAddPhoto"),
              let imageData = image.jpegData(compressionQuality: 1.0),
              let placeholderImageData = placeholderImage.jpegData(compressionQuality: 1.0),
              imageData != placeholderImageData else {
            self.activityIndicator.stopAnimating()
            displayMessage(title: "Error", message: "Please provide an image of the card")
            return
        }
        
        guard let image = cardImageView.image else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        
        guard let player = playerTextField.text else {
            displayMessage(title: "Error", message: "Please enter a valid player")
            self.activityIndicator.stopAnimating()
            return
        }
        guard let team = teamTextField.text else {
            displayMessage(title: "Error", message: "Please enter a valid team")
            self.activityIndicator.stopAnimating()
            return
        }
        guard let year = yearTextField.text else {
            displayMessage(title: "Error", message: "Please enter a valid year")
            self.activityIndicator.stopAnimating()
            return
        }
        guard let set = setTextField.text else {
            displayMessage(title: "Error", message: "Please enter a valid set")
            self.activityIndicator.stopAnimating()
            return
        }
        guard let variant = variantTextField.text else {
            displayMessage(title: "Error", message: "Please enter a valid variant")
            self.activityIndicator.stopAnimating()
            return
        }
        var numbered = false, auto = false, patch = false, graded = false, rookie = false
        var number = "-"
        var grade = "-"
        if rookieSegmenetedControl.selectedSegmentIndex != NO {
            rookie = true
        }
        if numberedSegmentedControl.selectedSegmentIndex != NO {
            numbered = true
            number = numberedTextField.text ?? "-"
        }
        if autoSegmentedControl.selectedSegmentIndex != NO {
            auto = true
        }
        if patchSegmentedControl.selectedSegmentIndex != NO {
            patch = true
        }
        if gradedSegmentedControl.selectedSegmentIndex != NO {
            graded = true
            grade = addSpaceBetweenLettersAndNumbers(in: gradedTextField.text ?? "-")
        }
        
        databaseController?.addUserCard(player: player, team: team, year: year, rookie: rookie, set: set, variant: variant, numbered: numbered, number: number, auto: auto, patch: patch, graded: graded, grade: grade, imageData: imageData)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.activityIndicator.stopAnimating()
            self.addCardButton.isEnabled = true
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseController = appDelegate.databaseController
        if passedImage == nil {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(gesture:)))
            cardImageView.addGestureRecognizer(tapGesture)
            cardImageView.isUserInteractionEnabled = true
        } else {
            cardImageView.image = passedImage
        }
        initTextFieldDelegates()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Add A Card"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Gallery Picker Related Functions
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
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
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        cardImageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TextField and Keyboard Related Functions
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func initTextFieldDelegates() {
        playerTextField.delegate = self
        playerTextField.autocapitalizationType = .none

        teamTextField.delegate = self
        teamTextField.autocapitalizationType = .none

        yearTextField.delegate = self
        yearTextField.autocapitalizationType = .none

        setTextField.delegate = self
        setTextField.autocapitalizationType = .none

        variantTextField.delegate = self
        variantTextField.autocapitalizationType = .none

        numberedTextField.delegate = self
        numberedTextField.autocapitalizationType = .none

        gradedTextField.delegate = self
        gradedTextField.autocapitalizationType = .allCharacters

        hideKeyboardWhenTappedAround()
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == playerTextField{
            return !autoCompleteText( in : textField, using: string, suggestionsArray: playerNames)
        } else if textField == teamTextField {
            return !autoCompleteText( in : textField, using: string, suggestionsArray: teams)
        } else if textField == yearTextField {
            return !autoCompleteText( in : textField, using: string, suggestionsArray: years)
        } else if textField == setTextField {
            return !autoCompleteText( in : textField, using: string, suggestionsArray: sets)
        }
        return true
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
