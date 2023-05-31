//
//  CardViewController.swift
//  CourtCache
//
//  Created by Yu Xuan Yio on 30/5/2023.
//

import UIKit

class CardViewController: UIViewController {
    
    var card: Card = Card()
    var cardImage: UIImage = UIImage()
    
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var cardDetailsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Card Details"
        cardDetailsTextView.isUserInteractionEnabled = false
        cardImageView.image = cardImage
        cardDetailsTextView.text = card.year! + " " + card.player!
        if card.rookie == true {
            cardDetailsTextView.text += " Rookie"
        }
        cardDetailsTextView.text += " " + card.set! + " " + card.variant!
        if card.graded == true {
            cardDetailsTextView.text += "\n\nGrade: " + card.grade!
        }
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
