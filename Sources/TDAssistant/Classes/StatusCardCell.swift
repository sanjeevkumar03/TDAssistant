// StatusCardCell.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit

class StatusCardCell: UITableViewCell {

    // MARK: Outlet declaration
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblTitle: UILabel!

    // MARK: Propterty declaration
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var isGenAINewTheme: Bool = false

    static let nibName = "StatusCardCell"
    static let identifier = "StatusCardCell"
    static let nibName_NT = "StatusCardCell-NT"
    static let identifier_NT = "StatusCardCell-NT"

    func configureCell(agentName: String, title: String) {
        if isGenAINewTheme {
            if agentName.isEmpty {
                self.lblTitle.text = title
            } else {
                let attributedText = NSMutableAttributedString(string: "\(agentName) \(title)")
                attributedText.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: agentName.count))
                self.lblTitle.attributedText = attributedText
            }
            self.layoutIfNeeded()
            DispatchQueue.main.async {
                self.bgView.dropShadow(offsetX: 0, offsetY: 1, color: VAColorUtility.black, opacity: 0.14, radius: 2)
            }
        } else {
            self.lblTitle.font = UIFont(name: fontName, size: textFontSize)
            self.bgView.layer.cornerRadius = 12
            self.bgView.backgroundColor = VAColorUtility.receiverBubbleColor
            self.lblTitle.textColor = VAColorUtility.themeTextIconColor
            if agentName.isEmpty {
                self.lblTitle.text = title
            } else {
                self.lblTitle.text = "\(agentName) \(title)"
            }
        }
    }
}
