//  TextAreaFormCell.swift
//  Created by Sanjeev Kumar on 25/04/24.
//  Copyright © 2024 Telus Digital. All rights reserved.

import UIKit

protocol TextAreaFormCellDelegate: AnyObject {
    func didUpdateTextViewAtIndexPath(_ indexPath: IndexPath, with text: String, hasValidInput: Bool)
}

class TextAreaFormCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleMandatoryLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var textViewContainer: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    static let cellIdentifier = "TextAreaFormCell"
    static let nibName = "TextAreaFormCell"
    weak var delegate: TextAreaFormCellDelegate?
    var fieldDetails: Prop? = nil
    var fieldIndexPath: IndexPath?
    var textViewPlaceholder = ""
    var emptyFieldError = ""
    var invalidInputError = ""
    var maxLengthReachedError = ""
    var regexPattern: String = ""
    var fieldMaxLength: Int = 50
    var isGenAINewTheme: Bool = false
    var fontName: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descTextView.textContainerInset = .zero
        descTextView.textContainer.lineFragmentPadding = 0
        textViewContainer.layer.borderColor = UIColor.lightGray.cgColor
        textViewContainer.layer.borderWidth = 1
        textViewContainer.layer.cornerRadius = 4
        descTextView.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureFormField(isShowErrorLabel: Bool = false) {
        titleLabel.font = isGenAINewTheme ? GenAIFonts().bold() : GenAIFonts().bold(fontSize: 15)
        descTextView.font = isGenAINewTheme ? GenAIFonts().normal() : GenAIFonts().normal(fontSize: 15)
        titleLabel.textColor = isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : UIColor.black
        titleMandatoryLabel.textColor = isGenAINewTheme ? VAColorUtility.errorRedColor_NT : UIColor.red
        titleLabel.text = fieldDetails?.label ?? ""
        titleMandatoryLabel.isHidden = !(fieldDetails?.propRequired ?? false)
        textViewPlaceholder = fieldDetails?.placeHolder ?? ""
        let typedText = fieldDetails?.userInputValue ?? ""
        if typedText.isEmpty {
            descTextView.text = textViewPlaceholder
            descTextView.textColor = .lightGray
        } else {
            descTextView.text = typedText
            descTextView.textColor = isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : .black
        }
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
        if (fieldDetails?.propRequired ?? false) && (descTextView.text == "" || (descTextView.text.trimmingCharacters(in: .whitespacesAndNewlines) == textViewPlaceholder)) {
            self.errorLabel.text = emptyFieldError
            self.errorLabel.isHidden = false
            hasValidInput = false
        } else if !(fieldDetails?.propRequired ?? false) && (descTextView.text == "" || (descTextView.text.trimmingCharacters(in: .whitespacesAndNewlines) == textViewPlaceholder)) {
            self.hideErrorLabel()
            hasValidInput = true
        }  else if (descTextView.text?.count ?? 0) > fieldMaxLength {
            self.errorLabel.text = maxLengthReachedError
            self.errorLabel.isHidden = false
            hasValidInput = false
        } else if !regexPattern.isEmpty {
            let isValidString = (descTextView.text ?? "").matches(regexPattern)
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
            delegate?.didUpdateTextViewAtIndexPath(indexPath, with: descTextView.text, hasValidInput: hasValidInput)
        }
    }
    private func hideErrorLabel() {
        self.errorLabel.text = ""
        self.errorLabel.isHidden = true
    }
}

extension TextAreaFormCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceholder {
            textView.text = ""
            textView.textColor = isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : .black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            textView.text = textViewPlaceholder
            textView.textColor = .lightGray
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            self.updateErrorField()
            return false
        }
        let currentString = (textView.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: text)
        return newString.count <= (fieldMaxLength+1)
    }
    func textViewDidChange(_ textView: UITextView) {
        //print(textView.text ?? "")
        self.updateErrorField()
    }
}
