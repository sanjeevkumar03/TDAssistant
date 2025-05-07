// QuickReplyCell.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit

// MARK: Protocol definition
protocol QuickReplyCellDelegate: AnyObject {
    func didTapQuickReplyButton(response: BotQRButton, index: Int)
}

class QuickReplyCell: UICollectionViewCell {

    // MARK: Outlet Declaration
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var quickReplyButton: UIButton!
    @IBOutlet weak var quickReplyBottom: NSLayoutConstraint!

    // MARK: Property Declaration
    static let nibName = "QuickReplyCell"
    static let identifier = "QuickReplyCell"
    weak var delegate: QuickReplyCellDelegate?
    var buttonResponse: BotQRButton?
    var allowUserActivity: Bool = false
    var isButtonClicked: Bool = false
    var isGenAINewTheme: Bool = false

    // MARK: Cell lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        quickReplyButton.setTitle("", for: .normal)
    }

    // MARK: Custom methods
    func configure(item: BotQRButton?, isGenAINewTheme: Bool) {
        buttonResponse = item
        self.titleLabel.attributedText = item?.attributedText
        self.titleLabel.textAlignment = .center
        self.titleLabel.lineBreakMode = .byTruncatingTail
        self.isUserInteractionEnabled = allowUserActivity
        if isGenAINewTheme {
            containerView.layer.cornerRadius = 20
            containerView.layer.borderColor = isButtonClicked ? VAColorUtility.green_NT.withAlphaComponent(0.35).cgColor : VAColorUtility.green_NT.cgColor
            titleLabel.textColor = isButtonClicked ? VAColorUtility.green_NT.withAlphaComponent(0.35) : VAColorUtility.green_NT
        } else {
            containerView.layer.cornerRadius = 4
            titleLabel.textColor = isButtonClicked ? VAColorUtility.buttonColor.withAlphaComponent(0.35) : VAColorUtility.buttonColor
            containerView.layer.borderColor = isButtonClicked ? VAColorUtility.buttonColor.withAlphaComponent(0.35).cgColor : VAColorUtility.buttonColor.cgColor

        }
    }
    // MARK: Button actions
    @IBAction func buttonAction(_ sender: UIButton) {
        self.isUserInteractionEnabled = false
        delegate?.didTapQuickReplyButton(response: buttonResponse!, index: sender.tag)
    }

}
