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
    
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var playerTextField: UITextField!
    @IBOutlet weak var teamTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var setTextField: UITextField!
    @IBOutlet weak var variantTextField: UITextField!
    @IBOutlet weak var numberedSegmentedControl: UISegmentedControl!
    @IBOutlet weak var numberedTextField: UITextField!
    @IBOutlet weak var autoSegmentedControl: UISegmentedControl!
    @IBOutlet weak var patchSegmentedControl: UISegmentedControl!
    @IBOutlet weak var gradedSegmentedControl: UISegmentedControl!
    @IBOutlet weak var gradedTextField: UITextField!
    
    @IBAction func addCardPressed(_ sender: Any) {
        if cardImageView.image == UIImage(named: "tapToAddPhoto") {
            displayMessage(title: "Error", message: "Please provide an image of the card")
            return
        }
        
        guard let image = cardImageView.image else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        
        guard let player = playerTextField.text else {
            displayMessage(title: "Error", message: "Please enter a valid player")
            return
        }
        guard let team = teamTextField.text else {
            displayMessage(title: "Error", message: "Please enter a valid team")
            return
        }
        guard let year = yearTextField.text else {
            displayMessage(title: "Error", message: "Please enter a valid year")
            return
        }
        guard let set = setTextField.text else {
            displayMessage(title: "Error", message: "Please enter a valid set")
            return
        }
        guard let variant = variantTextField.text else {
            displayMessage(title: "Error", message: "Please enter a valid variant")
            return
        }
        var numbered = false, auto = false, patch = false, graded = false
        var number = "-"
        var grade = "-"
        if numberedSegmentedControl.selectedSegmentIndex != 0 {
            numbered = true
            number = numberedTextField.text ?? "-"
        }
        if autoSegmentedControl.selectedSegmentIndex != 0 {
            auto = true
        }
        if patchSegmentedControl.selectedSegmentIndex != 0 {
            patch = true
        }
        if gradedSegmentedControl.selectedSegmentIndex != 0 {
            graded = true
            grade = gradedTextField.text ?? "-"
        }
        
        databaseController?.addUserCard(player: player, team: team, year: year, set: set, variant: variant, numbered: numbered, number: number, auto: auto, patch: patch, graded: graded, grade: grade, imageData: imageData)
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseController = appDelegate.databaseController
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(gesture:)))
        cardImageView.addGestureRecognizer(tapGesture)
        cardImageView.isUserInteractionEnabled = true
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
    // MARK: - NOTE, ADD TO INFO PLIST
    /*
     <key>NSCameraUsageDescription</key>
     <string>This app requires access to the camera.</string>
     <key>NSPhotoLibraryUsageDescription</key>
     <string>This app requires access to the photo library.</string>
     */
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
