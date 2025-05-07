// AgentTransferVC.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit
@preconcurrency import WebKit
import SDWebImage

// MARK: - Protocol definition
/// Protocol to handle actions from the `AgentTransferVC`.
protocol AgentTransferDelegate: AnyObject {
    /// Called when the back button is tapped.
    func backButtonTapped()
}

/// `AgentTransferVC` is responsible for displaying a web view to transfer the user to an agent.
/// It includes a custom navigation bar and handles web view interactions.
class AgentTransferVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var imgClose: UIImageView!
    @IBOutlet weak var viewHeaderSeperator: UIView!
    @IBOutlet var closeButton: UIButton!
    // MARK: - Properties
    var webUrl: String = "" 
    var titleString: String = ""
    weak var delegate: AgentTransferDelegate?
    var isGenAINewTheme: Bool = false

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Enable light theme for the view controller
        overrideUserInterfaceStyle = .light
        /// Set the title of the screen
        self.titleLabel.text = self.titleString
        /// Configure the UI elements
        self.configureUI()
        /// Configure the web view
        self.configureWebView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /// Hide the custom loader when the view disappears
        CustomLoader.hide()
    }

    // MARK: - Configure the UI
    /// Configures the UI elements with custom colors and styles.
    func configureUI() {
        // Set the background color of the view
        self.view.backgroundColor = VAColorUtility.themeColor

        // Configure the navigation bar
        self.viewNavigation.backgroundColor = VAColorUtility.defaultHeaderColor
        self.imgClose.image = UIImage(named: "back-icon", in: Bundle.module, with: nil)
        self.imgClose.tintColor = isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.defaultButtonColor
        self.titleLabel.font = GenAIFonts().normal(fontSize: 16)
        self.titleLabel.textColor = VAColorUtility.themeTextIconColor

        // Configure the separator color
        self.viewHeaderSeperator.backgroundColor = VAColorUtility.defaultThemeTextIconColor
    }

    // MARK: - Configure Web View
    /// Configures the web view with navigation settings and loads the URL.
    func configureWebView() {
        // Set the web view delegate
        webView.navigationDelegate = self
        // Enable back and forward navigation gestures
        webView.allowsBackForwardNavigationGestures = true
        // Set the background color of the web view
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .clear

        // Validate and format the URL
        let validUrlString = (webUrl.hasPrefix("http") || webUrl.hasPrefix("https")) ? webUrl : "https://\(webUrl)"

        // Enable JavaScript based on iOS version
        if #available(iOS 14.0, *) {
            webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            webView.configuration.preferences.javaScriptEnabled = true
        }

        // Load the URL in the web view
        if let url = URL(string: validUrlString) {
            webView.load(URLRequest(url: url))
        }
    }

    // MARK: - Button Actions
    /// Handles the close button tap action to dismiss the screen.
    @IBAction func closeTapped(_ sender: Any) {
        self.delegate?.backButtonTapped()
    }
}

// MARK: - WKNavigationDelegate
/// Handles web view navigation events.
extension AgentTransferVC: WKNavigationDelegate {
    /// Called when the web view starts loading a page.
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        /// Show the custom loader while the page is loading
        CustomLoader.show(isUserInterationEnabled: true)
    }

    /// Called when the web view finishes loading a page.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        /// Hide the custom loader when the page finishes loading
        CustomLoader.hide()
    }

    /// Called when the web view fails to load a page.
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        /// Hide the custom loader if the page fails to load
        CustomLoader.hide()
    }
}
