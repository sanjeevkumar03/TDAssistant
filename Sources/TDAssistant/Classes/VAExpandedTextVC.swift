// VAExpandedTextVC.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit

// MARK: - Protocol definition
/// Protocol to handle interactions with expanded text links or URLs.
protocol VAExpandedTextVCDelegate: AnyObject {
    func didTapOnExpandedTextQueryLink(displayText: String, dataQuery: String, indexPath: IndexPath)
    func didTapOnExpandedTextURL(url: String)
}

/// `VAExpandedTextVC` is responsible for displaying expanded text content.
/// It handles interactions with links, query attributes, and session expiration.
class VAExpandedTextVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var seperatorTitleView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var closeButtonImg: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!

    // MARK: - Properties
    var htmlText: NSAttributedString?
    var normalText: String = ""
    var originalText: String = ""
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var chatTableIndexPath: IndexPath? = nil
    var isGenAINewTheme: Bool = false
    weak var delegate: VAExpandedTextVCDelegate?

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Enable light theme for the view controller
        overrideUserInterfaceStyle = .light
        /// Configure the background view
        bgView.isHidden = true
        /// Configure the text view
        textView.tintColor = #colorLiteral(red: 0, green: 0.3647058824, blue: 1, alpha: 1)
        textView.delegate = self
        textView.linkTextAttributes = [.underlineStyle: 0]
        if htmlText == nil {
            // Display plain text if HTML text is not provided
            textView.text = normalText
            textView.font = UIFont(name: fontName, size: textFontSize)
        } else {
            // Display HTML text
            textView.attributedText = htmlText
        }

        /// Configure the close button image
        self.closeButtonImg.image = UIImage(named: "crossIcon", in: Bundle.module, with: nil)
        self.closeButtonImg.tintColor = isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.defaultButtonColor

        /// Add observer for session expiration notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleSessionExpiredState(notification:)),
            name: Notification.Name("sessionExpired"),
            object: nil
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /// Show the background view
        bgView.isHidden = false
        /// Adjust the scroll view height based on the text content
        if textView.contentSize.height > self.view.bounds.height * 0.8 {
            scrollViewHeight.constant = self.view.bounds.height * 0.8
        } else {
            scrollViewHeight.constant = textView.contentSize.height
        }
        self.view.layoutIfNeeded()
    }

    // MARK: - Handle Session Expired State
    /// Handles the session expiration notification by dismissing the view controller.
    @objc func handleSessionExpiredState(notification: Notification) {
        self.dismiss(animated: false, completion: nil)
    }

    // MARK: - Custom Methods
    /// Configures the background view.
    func setupView() {
        self.bgView.backgroundColor = VAColorUtility.receiverBubbleColor
    }

    // MARK: - Button Actions
    /// Handles the close button tap action to dismiss the view controller.
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
}

// MARK: - UITextViewDelegate
extension VAExpandedTextVC: UITextViewDelegate {
    /// Handles interactions with text attachments in the text view.
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let attachment = textAttachment.image {
            // Open the image viewer for the attached image
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.module)
            if let vcObj = storyBoard.instantiateViewController(withIdentifier: "VAImageViewerVC") as? VAImageViewerVC {
                vcObj.image = attachment
                if attachment.size.width <= 200 && attachment.size.height <= 200 {
                    vcObj.imageContentMode = .center
                }
                vcObj.modalPresentationStyle = .overCurrentContext
                self.present(vcObj, animated: true, completion: nil)
            }
        }
        return true
    }

    /// Handles interactions with URLs in the text view.
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print(URL)
        if UIApplication.shared.canOpenURL(URL) == false {
            // Handle custom query links
            let newRange = Range(characterRange, in: textView.text ?? "")!
            let subString = textView.text[newRange]
            let queryLink = String(subString)

            let dataQuery = self.getDataQueryAttributeFromHtmlString(queryText: queryLink)
            if let indexPath = chatTableIndexPath {
                delegate?.didTapOnExpandedTextQueryLink(displayText: queryLink, dataQuery: dataQuery, indexPath: indexPath)
            }
            self.dismiss(animated: false, completion: nil)
            return false
        } else {
            // Handle standard URLs
            self.dismiss(animated: false) { [self] in
                delegate?.didTapOnExpandedTextURL(url: URL.absoluteString)
            }
            return false
        }
    }

    /// Extracts the `data-query` attribute from the HTML string based on the query text.
    func getDataQueryAttributeFromHtmlString(queryText: String) -> String {
        var splittedText = originalText.components(separatedBy: "data-query")
        splittedText.removeFirst()
        for item in splittedText {
            if item.contains("data-displayname=\"\(queryText)\"") || item.contains("data-displayname=\" \(queryText)\"") ||
                item.contains("data-displayname=\"\(queryText) \"") ||
                item.contains("data-displayname=\" \(queryText) \"") {
                let splittedItem = item.components(separatedBy: "data-displayname")
                let dataQuery = splittedItem.first ?? ""
                return dataQuery.replacingOccurrences(of: "=\"", with: "").replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return ""
    }
}
