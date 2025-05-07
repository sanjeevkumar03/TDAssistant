//  DropdownFormCell.swift
//  Created by Sanjeev Kumar on 25/04/24.
//  Copyright © 2024 Telus Digital. All rights reserved.

import UIKit

protocol DropdownFormCellDelegate: AnyObject {
    func didUpdateDropdownAtIndexPath(_ indexPath: IndexPath, with text: String, hasValidInput: Bool)
}

class DropdownFormCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleMandatoryLabel: UILabel!
    @IBOutlet weak var dropDownValueTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var dropDownValueContainer: UIView!
    
    static let cellIdentifier = "DropdownFormCell"
    static let nibName = "DropdownFormCell"
    private let pickerView = UIPickerView()
    private let toolbar = UIToolbar(frame: .init(x: 0.0, y: 0.0, width: 100.0, height: 44.0))
    var fieldDetails: Prop? = nil
    var fieldIndexPath: IndexPath?
    var emptyFieldError = ""
    var isGenAINewTheme: Bool = false
    var fontName: String = ""
    weak var delegate: DropdownFormCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dropDownValueContainer.layer.borderColor = UIColor.lightGray.cgColor
        dropDownValueContainer.layer.borderWidth = 1
        dropDownValueContainer.layer.cornerRadius = 4
        self.configurePickerView()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureFormField(isShowErrorLabel: Bool = false) {
        titleLabel.font = isGenAINewTheme ? GenAIFonts().bold() : GenAIFonts().bold(fontSize: 15)
        dropDownValueTextField.font = isGenAINewTheme ? GenAIFonts().normal() : GenAIFonts().normal(fontSize: 15)
        titleLabel.textColor = isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : UIColor.black
        dropDownValueTextField.textColor = isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : UIColor.black
        titleMandatoryLabel.textColor = isGenAINewTheme ? VAColorUtility.errorRedColor_NT : UIColor.red
        titleLabel.text = fieldDetails?.label ?? ""
        dropDownValueTextField.text = fieldDetails?.userInputValue ?? ""
        dropDownValueTextField.placeholder = "\(LanguageManager.shared.localizedString(forKey: "Select"))..."
        titleMandatoryLabel.isHidden = !(fieldDetails?.propRequired ?? false)
        emptyFieldError = "\(LanguageManager.shared.localizedString(forKey: "Please select")) \((fieldDetails?.label ?? "").lowercased())"
        dropDownValueTextField.inputView = pickerView
        self.configureToolbar()
        if isShowErrorLabel {
            self.updateErrorField()
        } else {
            self.hideErrorLabel()
        }
    }
    private func configurePickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    private func configureToolbar() {
        let cancelButton = UIBarButtonItem(title: LanguageManager.shared.localizedString(forKey: "Cancel"), style: .done, target: self, action: #selector(didTapCancelButton))
        cancelButton.tintColor = isGenAINewTheme ? VAColorUtility.green_NT : #colorLiteral(red: 0.2947866321, green: 0.1562722623, blue: 0.4264383316, alpha: 1)
        let doneButton = UIBarButtonItem(title: LanguageManager.shared.localizedString(forKey: "Done"), style: .done, target: self, action: #selector(didTapDoneButton))
        doneButton.tintColor = isGenAINewTheme ? VAColorUtility.green_NT : #colorLiteral(red: 0.2947866321, green: 0.1562722623, blue: 0.4264383316, alpha: 1)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolbar.sizeToFit()
        dropDownValueTextField.inputAccessoryView = toolbar
    }
    
    @objc private func didTapCancelButton() {
        updateErrorField()
        endEditing(true)
    }
    
    @objc private func didTapDoneButton() {
        let selectedIndex = pickerView.selectedRow(inComponent: 0)
        dropDownValueTextField.text = (fieldDetails?.options?[selectedIndex].label ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        updateErrorField()
        endEditing(true)
    }
    
    private func updateErrorField() {
        var hasValidInput: Bool = false
        if (fieldDetails?.propRequired ?? false) && (dropDownValueTextField.text?.isEmpty ?? false) {
            self.errorLabel.text = emptyFieldError
            self.errorLabel.isHidden = false
            hasValidInput = false
        } else {
            self.hideErrorLabel()
            hasValidInput = true
        }
        if let indexPath = fieldIndexPath {
            delegate?.didUpdateDropdownAtIndexPath(indexPath, with: dropDownValueTextField.text ?? "", hasValidInput: hasValidInput)
        }
    }
    
    private func hideErrorLabel() {
        self.errorLabel.text = ""
        self.errorLabel.isHidden = true
    }
    
    @IBAction func openDropDownTapped(_ sender: Any) {
        self.dropDownValueTextField.becomeFirstResponder()
    }
}

extension DropdownFormCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        fieldDetails?.options?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        fieldDetails?.options?[row].label ?? ""
    }
}

