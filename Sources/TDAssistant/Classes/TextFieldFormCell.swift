//  TextFieldFormCell.swift
//  Created by Sanjeev Kumar on 25/04/24.
//  Copyright © 2024 Telus Digital. All rights reserved.

import UIKit

protocol TextFieldFormCellDelegate: AnyObject {
    func didUpdateTextFieldAtIndexPath(_ indexPath: IndexPath, with text: String, hasValidInput: Bool)
}
class TextFieldFormCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleMandatoryLabel: UILabel!
    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var textFieldContainer: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    static let cellIdentifier = "TextFieldFormCell"
    static let nibName = "TextFieldFormCell"
    weak var delegate: TextFieldFormCellDelegate?
    var fieldDetails: Prop? = nil
    var fieldIndexPath: IndexPath?
    var emptyFieldError = ""
    var invalidInputError = ""
    var maxLengthReachedError = ""
    var regexPattern: String = ""
    var fieldMaxLength: Int = 50
    var isGenAINewTheme: Bool = false
    var fontName: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textFieldContainer.layer.borderColor = UIColor.lightGray.cgColor
        textFieldContainer.layer.borderWidth = 1
        textFieldContainer.layer.cornerRadius = 4
        descTextField.addTarget(self, action: #selector(textFieldValueChanged(textField:)), for: .editingChanged)
        descTextField.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureFormField(isShowErrorLabel: Bool = false) {
        titleLabel.font = isGenAINewTheme ? GenAIFonts().bold() : GenAIFonts().bold(fontSize: 15)
        descTextField.font = isGenAINewTheme ? GenAIFonts().normal() : GenAIFonts().normal(fontSize: 15)
        titleLabel.textColor = isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : UIColor.black
        descTextField.textColor = isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : UIColor.black
        titleMandatoryLabel.textColor = isGenAINewTheme ? VAColorUtility.errorRedColor_NT : UIColor.red
        titleLabel.text = fieldDetails?.label ?? ""
        descTextField.text = fieldDetails?.userInputValue ?? ""
        descTextField.placeholder = fieldDetails?.placeHolder ?? ""
        titleMandatoryLabel.isHidden = !(fieldDetails?.propRequired ?? false)
        fieldMaxLength = getFormFieldMaxLength(length: fieldDetails?.maxLength)
        emptyFieldError = "\(LanguageManager.shared.localizedString(forKey: "Please enter")) \((fieldDetails?.label ?? "").lowercased())"
        invalidInputError = "\(LanguageManager.shared.localizedString(forKey: "Please enter valid")) \((fieldDetails?.label ?? "").lowercased())"
        maxLengthReachedError = "\(fieldDetails?.label ?? "") \(LanguageManager.shared.localizedString(forKey: "can't be more than")) \(fieldMaxLength) \(LanguageManager.shared.localizedString(forKey: "characters"))."
        regexPattern = fieldDetails?.validation ?? ""
        if regexPattern.first == "/" {
            regexPattern.removeFirst()
        }
        if regexPattern.last == "/" {
            regexPattern.removeLast()
        }
        if isShowErrorLabel {
            self.updateErrorField()
        } else {
            self.hideErrorLabel()
        }
    }

    private func updateErrorField() {
        var hasValidInput: Bool = false
        if (fieldDetails?.propRequired ?? false) && (descTextField.text?.isEmpty ?? false) {
            self.errorLabel.text = emptyFieldError
            self.errorLabel.isHidden = false
            hasValidInput = false
        } else if !(fieldDetails?.propRequired ?? false) && (descTextField.text?.isEmpty ?? false) {
            self.hideErrorLabel()
            hasValidInput = true
        } else if (descTextField.text?.count ?? 0) > fieldMaxLength {
            self.errorLabel.text = maxLengthReachedError
            self.errorLabel.isHidden = false
            hasValidInput = false
        } else if !regexPattern.isEmpty {
            let isValidString = (descTextField.text ?? "").matches(regexPattern)
            if !(isValidString) {
                self.errorLabel.text = invalidInputError
                self.errorLabel.isHidden = false
                hasValidInput = false
            } else {
                self.hideErrorLabel()
                hasValidInput = true
            }
        } else {
            self.hideErrorLabel()
            hasValidInput = true
        }
        if let indexPath = fieldIndexPath {
            delegate?.didUpdateTextFieldAtIndexPath(indexPath, with: descTextField.text ?? "", hasValidInput: hasValidInput)
        }
    }
    
    private func hideErrorLabel() {
        self.errorLabel.text = ""
        self.errorLabel.isHidden = true
    }
}

extension TextFieldFormCell: UITextFieldDelegate {
    @objc private func textFieldValueChanged(textField: UITextField) {
        //print(textField.text ?? "")
        self.updateErrorField()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        return newString.count <= (fieldMaxLength+1)
    }
}


func getFormFieldMaxLength(length: MaxLength?) -> Int {
    var maxLength = 50
    switch length {
        case .string(let text):
        maxLength = Int(text == "" ? "0" : text) ?? 0
        case .integer(let num):
        maxLength = num
    case .none:
        break
    }
    return maxLength
}

