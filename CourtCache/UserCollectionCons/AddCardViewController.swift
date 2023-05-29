//
//  AddCardViewController.swift
//  CourtCache
//
//  Created by Yu Xuan Yio on 29/5/2023.
//

import UIKit

class AddCardViewController: UIViewController {
    
    
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var playerTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var setTextField: UITextField!
    @IBOutlet weak var variantTextField: UITextField!
    @IBOutlet weak var numberedSegmentedControl: UISegmentedControl!
    @IBOutlet weak var numberedTextField: UITextField!
    @IBOutlet weak var autoSegmentedControl: UISegmentedControl!
    @IBOutlet weak var patchSegmentedControl: UISegmentedControl!
    
    @IBAction func addCardPressed(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(playerNames)
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
