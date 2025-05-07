//  DateCell.swift
//  TIVirtualAssistant
//  Created by Sanjeev Kumar on 28/11/24.
//  Copyright © 2024 Telus International. All rights reserved.

import UIKit

class DateCell: UITableViewCell {
    // MARK: Outlet Declaration
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var dateViewHeight: NSLayoutConstraint!
    @IBOutlet weak var avatarViewWidth: NSLayoutConstraint!
    
    // MARK: Property Declaration
    static let nibName = "DateCell"
    static let identifier = "DateCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configure(date: Date, isEnableAvatar: Bool) {
        self.dateLabel.text = getMessageTime(date: date)
        self.setCardUI(isEnableAvatar: isEnableAvatar)
    }
    func setCardUI(isEnableAvatar: Bool) {
        if isEnableAvatar {
            avatarView.isHidden = false
        } else {
            avatarViewWidth.constant = 0
            avatarView.isHidden = true
            dateViewHeight.constant = 20
        }
    }
}
