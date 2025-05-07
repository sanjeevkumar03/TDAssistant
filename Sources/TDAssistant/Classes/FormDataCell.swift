//  FormDataCell.swift
//  TIVirtualAssistant
//  Created by Sanjeev Kumar on 27/11/24.
//  Copyright © 2024 Telus International. All rights reserved.

import UIKit

class FormDataCell: UITableViewCell {
    // MARK: Outlet Declaration
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var seperatorView: UIView!
    
    // MARK: Property Declaration
    static let nibName = "FormDataCell"
    static let identifier = "FormDataCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
