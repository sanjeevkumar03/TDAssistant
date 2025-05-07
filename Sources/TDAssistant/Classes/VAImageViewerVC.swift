// VAImageViewerVC.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit

/// `VAImageViewerVC` is responsible for displaying a collection of images in a full-screen viewer.
/// It supports pagination, zooming, and closing the viewer.
class VAImageViewerVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var imageCollection: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var closeButton: UIButton!

    // MARK: - Properties
    var images: [String] = []
    var image: UIImage?
    var selectedImageIndex: Int = 0
    var isScrolledInitially: Bool = false
    var imageContentMode: UIView.ContentMode = .scaleAspectFit

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Enable light theme for the view controller
        overrideUserInterfaceStyle = .light
        /// Set up the collection view
        self.setUpCollectionVeiw()
        /// Set up the page indicator
        self.setPageIndicator()
        /// Configure the close button
        self.closeButton.setTitle("", for: .normal)
        self.closeButton.tintColor = VAColorUtility.defaultButtonColor
        self.closeButton.imageView?.layer.transform = CATransform3DMakeScale(0.95, 0.95, 0.95)

        // Scroll to the initially selected image after a slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.imageCollection.isPagingEnabled = false
            self.imageCollection.scrollToItem(at: IndexPath(item: self.selectedImageIndex, section: 0), at: .left, animated: false)
            self.imageCollection.isPagingEnabled = true
        }

        // Add observer for session expiration notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleSessionExpiredState(notification:)),
            name: Notification.Name("sessionExpired"),
            object: nil
        )
    }

    // MARK: - Handle Session Expired State
    /// Handles the session expiration notification by dismissing the view controller.
    @objc func handleSessionExpiredState(notification: Notification) {
        if self.navigationController == nil || self.navigationController?.viewControllers.first == self {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: false)
        }
    }

    // MARK: - Set up UICollectionView
    /// Configures the collection view with its delegate, data source, and layout.
    func setUpCollectionVeiw() {
        self.view.layoutIfNeeded()
        // Register the custom cell for the collection view
        imageCollection.register(UINib(nibName: ImageViewerCell.nibName, bundle: Bundle.module), forCellWithReuseIdentifier: ImageViewerCell.identifier)
        // Configure the layout for the collection view
        if let layout = imageCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: imageCollection.bounds.width, height: imageCollection.bounds.height)
        }
        imageCollection.delegate = self
        imageCollection.dataSource = self
        imageCollection.reloadData()
    }

    // MARK: - Set Page Indicator
    /// Configures the page indicator (dots) for pagination.
    func setPageIndicator() {
        if images.count > 0 {
            pageControl.numberOfPages = images.count
            pageControl.currentPage = selectedImageIndex
            pageControl.currentPageIndicatorTintColor = VAColorUtility.defaultButtonColor
            pageControl.tintColor = .lightGray
            pageControl.pageIndicatorTintColor = .lightGray
        }
    }

    // MARK: - Button Actions
    /// Handles the close button tap action to dismiss the viewer.
    @IBAction func closeTapped(_ sender: Any) {
        if self.navigationController == nil || self.navigationController?.viewControllers.first == self {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: false)
        }
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension VAImageViewerVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    /// Returns the number of items in the collection view.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count == 0 ? 1 : images.count
    }

    /// Configures the cell for a given index path in the collection view.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell: ImageViewerCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageViewerCell.identifier, for: indexPath) as? ImageViewerCell {
            cell.imageContentMode = imageContentMode
            if images.count == 0 {
                // Configure the cell with a single image
                cell.configure(imageURL: "", image: image)
            } else {
                // Configure the cell with an image URL
                cell.configure(imageURL: images[indexPath.item], image: nil)
            }
            return cell
        }
        return UICollectionViewCell()
    }

    /// Returns the size for each item in the collection view.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }

    /// Resets the zoom scale when a cell is about to be displayed.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ImageViewerCell {
            cell.scrollView.zoomScale = 1
        }
    }
}

// MARK: - UIScrollViewDelegate
extension VAImageViewerVC: UIScrollViewDelegate {
    /// Updates the current page indicator in the page control as the user scrolls.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let xPoint = scrollView.contentOffset.x + scrollView.frame.width / 2
        let yPoint = scrollView.frame.height / 2
        let center = CGPoint(x: xPoint, y: yPoint)
        if let indexPath = imageCollection.indexPathForItem(at: center) {
            self.pageControl.currentPage = indexPath.row
        }
    }
}
