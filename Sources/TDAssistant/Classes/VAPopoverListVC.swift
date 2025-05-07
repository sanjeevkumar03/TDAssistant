// VAPopoverListVC.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import Foundation
import UIKit

/// `VAPopoverListVC` is responsible for displaying a popover list of items.
/// It allows users to select an item from the list and returns the selected item through a completion block.
class VAPopoverListVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var listTableView: UITableView! {
        didSet {
            // Set the table view delegate and data source
            self.listTableView.delegate = self
            self.listTableView.dataSource = self
        }
    }

    // MARK: - Properties
    private var arrayOfData: [String] = []
    private var completionBlock: VAPopoverCompletionBlock!
    internal typealias VAPopoverCompletionBlock  = (_ index: Int, _ item: String) -> Void
    private var openFromSideMenu: Bool = false
    private var totalItemsCount: Int = 0
    private var fontName: String = ""
    private var textFontSize: Double = 0.0
    private var isGenAINewTheme: Bool = false

    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Enable light theme for the view controller
        overrideUserInterfaceStyle = .light
        /// Set up the view
        self.setupView()
    }

    // MARK: - Setup View
    /// Configures the initial setup for the view.
    func setupView() {
        // Additional setup logic can be added here if needed
    }

    // MARK: - Open Popover List View
    /// Opens the popover list view with the provided data and configuration.
    class func openPopoverListView(arrayOfData: [String], viewController: UIViewController, sender: UIView,
                                   fontName: String, textFontSize: Double, isGenaAINewTheme: Bool,
                                   completionHandler: @escaping VAPopoverCompletionBlock) {
        let story = UIStoryboard(name: "Main", bundle: Bundle.module)
        var alert: VAPopoverListVC!

        // Instantiate the view controller based on iOS version
        if #available(iOS 13, *) {
            alert = story.instantiateViewController(identifier: "VAPopoverListVC") as? VAPopoverListVC
        } else {
            alert = story.instantiateViewController(withIdentifier: "VAPopoverListVC") as? VAPopoverListVC
        }

        // Set the completion block and open the popover
        alert.completionBlock = completionHandler
        alert.openPopoverListView(arrayOfData: arrayOfData, viewController: viewController, sender: sender,
                                  fontName: fontName, textFontSize: textFontSize, isGenaAINewTheme: isGenaAINewTheme,
                                  completionHandler: completionHandler)
    }

    /// Configures and presents the popover list view.
    private func openPopoverListView(arrayOfData: [String], viewController: UIViewController, sender: UIView,
                                     fontName: String, textFontSize: Double, isGenaAINewTheme: Bool,
                                     completionHandler: @escaping VAPopoverCompletionBlock) {
        self.arrayOfData = arrayOfData
        self.fontName = fontName
        self.textFontSize = textFontSize
        self.isGenAINewTheme = isGenaAINewTheme

        // Set the preferred content size based on the number of items
        if self.arrayOfData.count > 5 {
            self.preferredContentSize = CGSize(width: 220, height: 225)
        } else {
            self.preferredContentSize = CGSize(width: 220, height: 44 * self.arrayOfData.count)
        }

        // Configure the popover presentation style
        self.modalPresentationStyle = .popover
        if let popoverPresentationController = self.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.sourceView = sender
            // update UI
            popoverPresentationController.backgroundColor = .white
            popoverPresentationController.delegate = self
            // Present the popover
            viewController.present(self, animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDelegate and UITableViewDataSource
extension VAPopoverListVC: UITableViewDelegate, UITableViewDataSource {
    /// Returns the number of rows in the table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfData.count
    }

    /// Configures the cell for a given row in the table view.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "VAPopoverListCell", for: indexPath) as? VAPopoverListCell {
            cell.titleLabel.text = self.arrayOfData[indexPath.row]
            cell.titleLabel.font = isGenAINewTheme ? GenAIFonts().normal(fontSize: 16) : UIFont(name: fontName, size: textFontSize)
            cell.titleLabel.textColor = isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.themeTextIconColor
            cell.viewSeperator.backgroundColor = VAColorUtility.themeColor

            // Show or hide the separator line for the last cell
            cell.viewSeperator.isHidden = indexPath.row == self.arrayOfData.count - 1
            return cell
        }
        return UITableViewCell()
    }

    /// Handles the selection of a row in the table view.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Dismiss the popover and return the selected item through the completion block
        self.dismiss(animated: true) {
            self.completionBlock(indexPath.row, self.arrayOfData[indexPath.row])
        }
    }

    /// Returns the height for each row in the table view.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension VAPopoverListVC: UIPopoverPresentationControllerDelegate {
    /// Specifies the presentation style for the popover.
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    /// Called when the popover is dismissed.
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        // Notify about the dismissal of the popover
        NotificationCenter.default.post(name: Notification.Name("AgentStatus"), object: nil)
    }

    /// Determines whether the popover should be dismissed.
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}

// MARK: - VAPopoverListCell
/// Custom table view cell for displaying items in the popover list.
class VAPopoverListCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewSeperator: UIView!
}
