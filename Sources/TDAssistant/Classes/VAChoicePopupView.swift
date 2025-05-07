// VAChoicePopupView.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit

/// `VAChoicePopupView` is responsible for displaying a popup with a list of choices.
/// It supports single and multi-selection and returns the selected choices through a completion block.
class VAChoicePopupView: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seperatorTitleView: UIView!
    @IBOutlet weak var seperatorConfirmView: UIView!
    @IBOutlet weak var crossImgView: UIImageView!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var optionsTable: UITableView! {
        didSet {
            // Set the table view delegate and data source
            self.optionsTable.delegate = self
            self.optionsTable.dataSource = self
            // Register the custom cell for the table view
            self.optionsTable.register(UINib(nibName: ChoiceCardOptionCell.nibName, bundle: Bundle.module), forCellReuseIdentifier: ChoiceCardOptionCell.identifier)
            // Set the estimated row height
            self.optionsTable.estimatedRowHeight = 50
        }
    }
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var hConfirmButtonConst: NSLayoutConstraint!
    @IBOutlet weak var hTableViewConst: NSLayoutConstraint!

    // MARK: - Properties
    private var isMultiSelect: Bool = true
    private var arrayOfData: [Choice] = []
    private var indexPath: IndexPath!
    private var completionBlock: VAChoiceCompletionBlock!
    private var fontName: String = ""
    private var textFontSize: Double = 0.0
    let confirmStaticText = LanguageManager.shared.localizedString(forKey: "Confirm")
    /// Completion block type alias
    internal typealias VAChoiceCompletionBlock = (_ index: IndexPath, _ item: [Choice], _ isCrossTapped: Bool) -> Void

    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Enable light theme for the view controller
        overrideUserInterfaceStyle = .light
        /// Set up the view
        self.setupView()
        /// Add observer for content size to adjust the table view height dynamically
        self.optionsTable.addObserver(self, forKeyPath: "contentSize", options: [], context: nil)
        /// Configure the close button image
        self.crossImgView.image = UIImage(named: "crossIcon", in: Bundle.module, with: nil)
        self.crossImgView.tintColor = VAColorUtility.defaultButtonColor

        /// Add observer for session expiration notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleSessionExpiredState(notification:)),
            name: Notification.Name("sessionExpired"),
            object: nil
        )
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        /// Remove observer for content size
        self.optionsTable.removeObserver(self, forKeyPath: "contentSize")
    }

    // MARK: - Handle Session Expired State
    /// Handles the session expiration notification by dismissing the popup.
    @objc func handleSessionExpiredState(notification: Notification) {
        self.dismiss(animated: false, completion: nil)
    }

    // MARK: - Observe Value
    /// Updates the height of the table view dynamically based on its content size.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        let heightOfTableView = self.optionsTable.contentSize.height
        let heightOfScreen = self.view.bounds.height
        // Adjust the table view height based on the content size and screen height
        if heightOfScreen > (heightOfTableView - 240) {
            self.hTableViewConst.constant = self.optionsTable.contentSize.height
        } else {
            self.hTableViewConst.constant = (heightOfScreen - 240)
        }
    }

    // MARK: - Setup View
    /// Configures the initial setup for the popup view.
    func setupView() {
        self.titleLabel.text = LanguageManager.shared.localizedString(forKey: "More Options")
        self.titleLabel.font = UIFont(name: fontName, size: textFontSize)
        self.confirmButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
        self.bgView.backgroundColor = VAColorUtility.receiverBubbleColor
        self.titleLabel.textColor = VAColorUtility.receiverBubbleTextIconColor
        self.confirmButton.setTitleColor(VAColorUtility.defaultThemeTextIconColor, for: .normal)
        self.seperatorTitleView.isHidden = true
        self.seperatorConfirmView.isHidden = true
        self.confirmButton.setTitle("\(self.confirmStaticText) (0)", for: .normal)
        self.confirmButton.layer.cornerRadius = 4
        self.confirmButton.backgroundColor = VAColorUtility.receiverBubbleColor
        self.confirmView.backgroundColor = VAColorUtility.defaultThemeTextIconColor
        self.titleView.backgroundColor = VAColorUtility.defaultThemeTextIconColor
    }

    // MARK: - Open Popup List View
    /// Opens the popup list view with the provided data and configuration.
    class func openPopupListView(arrayOfData: [Choice], isMultiSelect: Bool, selectedIndexPath: IndexPath,
                                 viewController: UIViewController, fontName: String, textFontSize: Double,
                                 completionHandler: @escaping VAChoiceCompletionBlock) {
        let story = UIStoryboard(name: "Main", bundle: Bundle.module)
        var alert: VAChoicePopupView!
        if #available(iOS 13, *) {
            alert = story.instantiateViewController(identifier: "VAChoicePopupView") as? VAChoicePopupView
        } else {
            alert = story.instantiateViewController(withIdentifier: "VAChoicePopupView") as? VAChoicePopupView
        }
        alert.completionBlock = completionHandler
        alert.openPopupListView(arrayOfData: arrayOfData,
                                isMultiSelect: isMultiSelect,
                                selectedIndexPath: selectedIndexPath,
                                viewController: viewController,
                                fontName: fontName,
                                textFontSize: textFontSize,
                                completionHandler: completionHandler)
    }

    /// Configures and presents the popup list view.
    private func openPopupListView(arrayOfData: [Choice], isMultiSelect: Bool, selectedIndexPath: IndexPath,
                                   viewController: UIViewController, fontName: String, textFontSize: Double,
                                   completionHandler: @escaping VAChoiceCompletionBlock) {
        self.indexPath = selectedIndexPath
        self.isMultiSelect = isMultiSelect
        self.arrayOfData = arrayOfData
        self.fontName = fontName
        self.textFontSize = textFontSize
        /// Set the height of the popup based on the number of items
        if self.arrayOfData.count > 5 {
            self.preferredContentSize = CGSize(width: 200, height: 200)
        } else {
            self.preferredContentSize = CGSize(width: 200, height: 40 * self.arrayOfData.count)
        }
        self.modalPresentationStyle = .overCurrentContext
        /// Present the popup
        viewController.present(self, animated: false) {
            /// Update the title and confirm button fonts
            self.titleLabel.font = UIFont(name: fontName, size: textFontSize)
            self.confirmButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
            /// Update the confirm button based on the selected items
            let filterArray = self.arrayOfData.filter { $0.isSelected }
            let titleColor = filterArray.isEmpty ? VAColorUtility.defaultThemeTextIconColor : VAColorUtility.receiverBubbleTextIconColor
            let title = filterArray.isEmpty ? "\(self.confirmStaticText) (0)" : "\(self.confirmStaticText) (\(filterArray.count))"
            self.confirmButton.setTitleColor(titleColor, for: .normal)
            self.confirmButton.setTitle(title, for: .normal)
            
            /// Adjust the confirm button and background based on selection type
            self.hConfirmButtonConst.constant = isMultiSelect ? 60 : 0
            self.bgView.backgroundColor = isMultiSelect ? VAColorUtility.receiverBubbleColor : VAColorUtility.defaultTextInputColor
            self.confirmButton.backgroundColor = isMultiSelect ? VAColorUtility.receiverBubbleColor : VAColorUtility.defaultTextInputColor
        }
    }

    // MARK: - IBActions
    /// Handles the close button tap action to dismiss the popup.
    @IBAction func crossButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.completionBlock(self.indexPath, self.arrayOfData, true)
        }
    }

    /// Handles the confirm button tap action to return the selected choices.
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        let filterArray = self.arrayOfData.filter { $0.isSelected }
        if filterArray.count > 0 {
            self.dismiss(animated: false) {
                self.completionBlock(self.indexPath, self.arrayOfData, false)
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension VAChoicePopupView: UITableViewDelegate, UITableViewDataSource {
    /// Returns the number of rows in the table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfData.count
    }

    /// Configures the cell for a given row in the table view.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: ChoiceCardOptionCell = tableView.dequeueReusableCell(withIdentifier: ChoiceCardOptionCell.identifier, for: indexPath) as? ChoiceCardOptionCell {
            cell.configure(title: self.arrayOfData[indexPath.row].label, isMultiSelect: self.isMultiSelect, isSelect: self.arrayOfData[indexPath.row].isSelected, isFromPopup: !self.isMultiSelect)
            cell.titleLabel.font = UIFont(name: fontName, size: textFontSize)
            cell.checkboxButton.tag = indexPath.row
            cell.checkboxButton.addTarget(self, action: #selector(checkboxTapped(sender:)), for: .touchUpInside)
            return cell
        }
        return UITableViewCell()
    }

    /// Handles the selection of a row in the table view.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.updateChoiceArrayOnSelection(index: indexPath.row)
    }

    /// Returns the height for each row in the table view.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

    /// Handles the checkbox tap action for a choice.
    @objc func checkboxTapped(sender: UIButton) {
        self.updateChoiceArrayOnSelection(index: sender.tag)
    }

    // MARK: - Update Choice Array
    /// Updates the choice array based on the selection.
    private func updateChoiceArrayOnSelection(index: Int) {
        var choice = self.arrayOfData[index]
        choice.isSelected.toggle()
        self.arrayOfData[index] = choice
        let filterArray = self.arrayOfData.filter { $0.isSelected }
        let titleColor = filterArray.isEmpty ? VAColorUtility.defaultThemeTextIconColor : VAColorUtility.receiverBubbleTextIconColor
        let title = filterArray.isEmpty ? "\(self.confirmStaticText) (0)" : "\(self.confirmStaticText) (\(filterArray.count))"
        self.confirmButton.setTitleColor(titleColor, for: .normal)
        self.confirmButton.setTitle(title, for: .normal)

        self.optionsTable.reloadData()
        if !self.isMultiSelect {
            self.dismiss(animated: false) {
                self.completionBlock(self.indexPath, self.arrayOfData, false)
            }
        }
    }
}
