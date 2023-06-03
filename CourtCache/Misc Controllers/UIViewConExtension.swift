//
//  UIViewConExtension.swift
//  CourtCache
//
//  Created by Yu Xuan Yio on 28/5/2023.
//

import Foundation
import UIKit
 
extension UIViewController: UITextFieldDelegate {
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func capitalizeFirstLetter(of string: String) -> String {
        return string.prefix(1).capitalized + string.dropFirst()
    }

    func autoCompleteText(in textField: UITextField, using string: String, suggestionsArray: [String]) -> Bool {
        if !string.isEmpty,
            let selectedTextRange = textField.selectedTextRange,
            selectedTextRange.end == textField.endOfDocument,
            let prefixRange = textField.textRange(from: textField.beginningOfDocument, to: selectedTextRange.start),
            let text = textField.text(in: prefixRange) {
            let prefix = text + string
            let matches = suggestionsArray.filter {
                $0.lowercased().hasPrefix(prefix.lowercased())
            }
            if (matches.count > 0) {
                textField.text = capitalizeFirstLetter(of: matches[0])
                if let start = textField.position(from: textField.beginningOfDocument, offset: prefix.count) {
                    textField.selectedTextRange = textField.textRange(from: start, to: textField.endOfDocument)
                    return true
                }
            }
        }
        return false
    }
    
    func addSpaceBetweenLettersAndNumbers(in text: String) -> String {
        let pattern = "([a-zA-Z]+)(\\d+)"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: text.count)
        let modifiedString = regex?.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "$1 $2")
        return modifiedString ?? text
    }
    
}
