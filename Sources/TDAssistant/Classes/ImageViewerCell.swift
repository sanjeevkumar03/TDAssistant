// ImageViewerCell.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit
import SDWebImage

class ImageViewerCell: UICollectionViewCell {
    // MARK: Outlet Declaration
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    // MARK: Property Declaration
    static let nibName = "ImageViewerCell"
    static let identifier = "ImageViewerCell"
    var imageContentMode: UIView.ContentMode = .scaleAspectFit

    // MARK: Cell lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 3.0
        self.scrollView.delegate = self
    }

    // MARK: Custom methods
    /// Used to configure image card
    /// - Parameter imageURL: It accepts image url string.
    func configure(imageURL: String, image: UIImage?) {
        imageView.contentMode = imageContentMode
        if image != nil {
            imageView.image = image
        } else {
            if let url = URL(string: imageURL) {
                imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholderImage", in: Bundle.module, with: nil))
            } else {
                imageView.image = UIImage(named: "placeholderImage", in: Bundle.module, with: nil)
            }
        }

    }
}

// MARK: UIScrollViewDelegate
extension ImageViewerCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
