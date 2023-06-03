//
//  CardViewController.swift
//  CourtCache
//
//  Created by Yu Xuan Yio on 30/5/2023.
//

import UIKit
import SafariServices

class CardViewController: UIViewController {
    
    var card: Card = Card()
    var cardImage: UIImage = UIImage()
    var lastSoldURL: String = "https://www.ebay.com/sch/i.html?_nkw="
    
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var cardDetailsTextView: UITextView!
    
    @IBAction func viewLastSoldPressed(_ sender: Any) {
        if let url = URL(string: lastSoldURL) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Card Details"
        cardDetailsTextView.isUserInteractionEnabled = false
        guard let year = card.year, let playerName = card.player, let cardSet = card.set, let variant = card.variant, let grade = card.grade, let cardNumber = card.number else {
            displayMessage(title: "Error", message: "Fail to load card")
            navigationController?.popViewController(animated: true)
            return
        }
        cardImageView.image = cardImage
        lastSoldURL += year + "+" + replaceSpacesWithPlus(in: playerName)
        cardDetailsTextView.text = year + " " + playerName
        if card.rookie == true {
            cardDetailsTextView.text += " Rookie"
            lastSoldURL += "+Rookie+"
        }
        cardDetailsTextView.text += " " + cardSet + " " + variant
        lastSoldURL += replaceSpacesWithPlus(in: cardSet) + "+" + replaceSpacesWithPlus(in: variant)
        if card.numbered == true {
            cardDetailsTextView.text += " " + cardNumber
            lastSoldURL += "+" + removeBeforeSlash(in: cardNumber)
        }
        if card.graded == true {
            cardDetailsTextView.text += "\n\nGrade: " + grade
            lastSoldURL += "+" + replaceSpacesWithPlus(in: grade)
        }
        lastSoldURL += "&LH_Complete=1&LH_Sold=1"
    }
    
    func replaceSpacesWithPlus(in text: String) -> String {
        return text.replacingOccurrences(of: " ", with: "+")
    }
    
    func removeBeforeSlash(in text: String) -> String {
        let components = text.components(separatedBy: "/")
        if let lastComponent = components.last {
            return "/" + lastComponent
        } else {
            return text
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editCardSegue" {
            let destination = segue.destination as! EditCardViewController
            destination.card = card
            destination.cardImage = cardImage
        }
    }

}
