// CarouselImageCell.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit
import SDWebImage

class CarouselImageCell: UICollectionViewCell {

    // MARK: Outlet Declaration
    @IBOutlet weak var imageView: UIImageView!

    // MARK: Property Declaration
    static let nibName = "CarouselImageCell"
    static let identifier = "CarouselImageCell"

    // MARK: Custom methods
    /// Used to configure image card
    /// - Parameter imageURL: It accepts image url string.
    func configure(imageURL: String) {
        if let url = URL(string: imageURL) {
            imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholderImage", in: Bundle.module, with: nil))
        } else {
            imageView.image = UIImage(named: "placeholderImage", in: Bundle.module, with: nil)
        }
    }
}
