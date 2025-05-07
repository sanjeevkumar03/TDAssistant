// AnsTagsCollectionViewCell.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit

/// `AnsTagsCollectionViewCell` is a custom collection view cell used to display tags or labels in a feedback form.
class AnsTagsCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var container: UIView!

    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        /// Configure the container view with rounded corners
        self.container.layer.cornerRadius = 4
        self.container.layer.masksToBounds = true
    }
}
