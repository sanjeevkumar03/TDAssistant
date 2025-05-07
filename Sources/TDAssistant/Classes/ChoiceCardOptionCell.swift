// ChoiceCardOptionCell.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit

class ChoiceCardOptionCell: UITableViewCell {

    // MARK: Outlet declaration
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkboxContainerView: UIView!
    @IBOutlet weak var checkboxImgView: UIImageView!
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var checkboxViewWidth: NSLayoutConstraint!
    @IBOutlet weak var titleLabelLeading: NSLayoutConstraint!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var containerView: UIView!

    // MARK: Property declaration
    static let nibName = "ChoiceCardOptionCell"
    static let identifier = "ChoiceCardOptionCell"
    static let nibName_NT = "ChoiceCardOptionCell-NT"
    static let identifier_NT = "ChoiceCardOptionCell-NT"

    override func awakeFromNib() {
        super.awakeFromNib()
        self.checkboxButton.setTitle("", for: .normal)
    }

    func configure(title: String, isMultiSelect: Bool, isSelect: Bool, isFromPopup: Bool? = false, isNewGenAITheme: Bool = false) {
        self.titleLabel.attributedText = createNormalAttributedString(text: title, isNewGenAITheme: isNewGenAITheme)
        if !isNewGenAITheme {
            self.seperatorView.backgroundColor = VAColorUtility.defaultThemeTextIconColor
            self.titleLabel.textColor = VAColorUtility.receiverBubbleTextIconColor
            // Change background on the basic of multiple selected allowed or not
            if isFromPopup ?? false == true {
                self.backgroundColor = VAColorUtility.defaultTextInputColor
            } else {
                self.backgroundColor = VAColorUtility.receiverBubbleColor
            }
        } else {
            self.titleLabel.textColor = VAColorUtility.greyShuttle_NT
        }
        self.titleLabel.lineBreakMode = .byTruncatingTail
        // Update UI on the basic of cell multiple selection is allowed
        if isMultiSelect {
            // change text alignment
            self.titleLabel.textAlignment = .left
            // show checkbox view
            self.checkboxViewWidth.constant = isNewGenAITheme ? 30 : 46
            self.checkboxButton.isHidden = false
            // set image on the basic of cell selected or not
            if isSelect {
                self.checkboxImgView.image = UIImage(named: isNewGenAITheme ? "checked-NT" : "checked", in: Bundle.module, with: nil)
            } else {
                self.checkboxImgView.image = UIImage(named: isNewGenAITheme ? "unChecked-NT" : "unchecked", in: Bundle.module, with: nil)
            }
            if isNewGenAITheme {
                self.checkboxContainerView.isHidden = false
                self.titleLabelLeading.constant = 0
                self.containerView.layer.cornerRadius = 0
                self.containerView.layer.borderWidth = 0
                self.containerView.backgroundColor = .clear
            } else {
                self.checkboxImgView.tintColor = VAColorUtility.receiverBubbleTextIconColor
            }
        } else {
            // change text alignment
            self.titleLabel.textAlignment = isNewGenAITheme ? .left : .center
            // hide checkbox view
            self.checkboxButton.isHidden = true
            self.checkboxViewWidth.constant = isNewGenAITheme ? 0 : 8
            if isNewGenAITheme {
                self.checkboxContainerView.isHidden = true
                self.titleLabelLeading.constant = 12
                self.containerView.layer.cornerRadius = 4
                self.containerView.layer.borderWidth = 1
                self.containerView.layer.borderColor = VAColorUtility.borderColor_NT.cgColor
                self.containerView.backgroundColor = VAColorUtility.white
            }
        }
    }
}
