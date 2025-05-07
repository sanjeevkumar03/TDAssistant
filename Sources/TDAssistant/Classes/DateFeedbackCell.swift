//  DateFeedbackCell.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit

// MARK: Protocol definition
protocol DateFeedbackCellDelegate: AnyObject {
    func didTapFeedbackThumbsUp(indexPath: IndexPath)
    func didTapFeedbackThumbsDown(indexPath: IndexPath)
}

class DateFeedbackCell: UITableViewCell {

    // MARK: Outlet Declaration
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var thumbsUpView: UIView!
    @IBOutlet weak var thumbsDownView: UIView!
    @IBOutlet weak var thumbsUpButton: UIButton!
    @IBOutlet weak var thumbsDownButton: UIButton!
    @IBOutlet weak var thumbsUpImgView: UIImageView!
    @IBOutlet weak var thumbsDownImgView: UIImageView!
    @IBOutlet weak var dateLabelTop: NSLayoutConstraint!
    @IBOutlet weak var dateLabelLeading: NSLayoutConstraint!
    @IBOutlet weak var dateLabelBottom: NSLayoutConstraint!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!

    // MARK: Property Declaration
    static let nibName = "DateFeedbackCell"
    static let identifier = "DateFeedbackCell"
    weak var delegate: DateFeedbackCellDelegate?
    private var indexPath: IndexPath!
    var configurationModal: VAConfigurationModel?
    var fontName: String = ""
    var textFontSize: Double = 0.0

    // MARK: Cell lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        containerViewWidth.constant = ChatBubble.getChatBubbleWidth()
        self.thumbsUpImgView.image = UIImage(named: "thumbsUp-deselected", in: Bundle.module, with: nil)
        self.thumbsDownImgView.image = UIImage(named: "thumbsDown-deselected", in: Bundle.module, with: nil)
        thumbsUpButton.setTitle("", for: .normal)
        thumbsDownButton.setTitle("", for: .normal)
    }

    // MARK: Custom Methods
    func updateViewForFeedback(isFeedbackEnabled: Bool, model: MockMessage) {
        if model.isFeedback {
            if model.isThumbsUpFeedback {
                self.thumbsUpImgView.image = UIImage(named: "thumbsUp-selected", in: Bundle.module, with: nil)
                self.thumbsUpView.isHidden = false
                self.thumbsDownView.isHidden = true
            } else {
                self.thumbsDownImgView.image = UIImage(named: "thumbsDown-selected", in: Bundle.module, with: nil)
                self.thumbsUpView.isHidden = true
                self.thumbsDownView.isHidden = false
            }
        } else {
            if isFeedbackEnabled {
                self.thumbsUpImgView.image = UIImage(named: "thumbsUp-deselected", in: Bundle.module, with: nil)
                self.thumbsDownImgView.image = UIImage(named: "thumbsDown-deselected", in: Bundle.module, with: nil)
                thumbsUpView.isHidden = false
                thumbsDownView.isHidden = false
            } else {
                thumbsUpView.isHidden = true
                thumbsDownView.isHidden = true
            }
        }

        if isFeedbackEnabled || model.isFeedback {
            dateLabelTop.constant = 0
            dateLabelBottom.constant = 10
        } else {
            dateLabelTop.constant = 0
            dateLabelBottom.constant = 0
        }
    }
    func configure(model: MockMessage, isShowFeedback: Bool, indexPath: IndexPath) {
        dateLabel.font = UIFont(name: fontName, size: textFontSize)
        self.indexPath = indexPath
        dateLabel.textColor = VAColorUtility.themeTextIconColor
        self.thumbsUpView.tintColor = VAColorUtility.themeTextIconColor
        self.thumbsDownView.tintColor = VAColorUtility.themeTextIconColor
        dateLabel.text = getMessageTime(date: model.sentDate)
        updateViewForFeedback(isFeedbackEnabled: isShowFeedback, model: model)
        if configurationModal?.result?.enableAvatar ?? true {
            dateLabelLeading.constant = 68
        } else {
            dateLabelLeading.constant = 25
        }
    }

    // MARK: Button Actions
    @IBAction func thumbsUpTapped(_ sender: UIButton) {
        delegate?.didTapFeedbackThumbsUp(indexPath: self.indexPath)
        self.thumbsUpImgView.image = UIImage(named: "thumbsUp-selected", in: Bundle.module, with: nil)
        self.thumbsDownView.isHidden = true
    }

    @IBAction func thumbsDownTapped(_ sender: UIButton) {
        delegate?.didTapFeedbackThumbsDown(indexPath: self.indexPath)
        self.thumbsDownImgView.image = UIImage(named: "thumbsDown-selected", in: Bundle.module, with: nil)
        self.thumbsUpView.isHidden = true
    }
}
