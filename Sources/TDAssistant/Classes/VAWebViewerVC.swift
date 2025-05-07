// VAWebViewerVC.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit
@preconcurrency import WebKit
import SDWebImage

/// `VAWebViewerVC` is responsible for displaying web content or videos in a web view.
/// It handles URL validation, web view configuration, and user interactions.
 class VAWebViewerVC: UIViewController {

    // MARK: - Outlets
    // UI components connected via Interface Builder
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var imgClose: UIImageView!
    @IBOutlet weak var viewHeaderSeperator: UIView!

   // MARK: - Properties
    // Variables for configuration and UI customization
    var webUrl: String = "" 
    var titleString: String = ""
    var fontName: String = "" 
    var textFontSize: Double = 0.0
    var videoFormats = ["mp4", "m4p", "webm", "mkv", "flv", "avi", "mov", "mpg", "mpeg", "3gp"] // Supported video formats
    var isVideoUrl: Bool = false
    var isGenAINewTheme: Bool = false

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Enable light theme for the view controller
        overrideUserInterfaceStyle = .light
        /// Disable the interactive pop gesture
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        /// Set the title of the navigation bar
        self.titleLabel.text = self.titleString
        self.titleLabel.font = UIFont(name: fontName, size: textFontSize)
        /// Configure the UI elements
        self.configureUI()
        /// Configure the web view
        self.configureWebView()
        /// Add observer for session expiration notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleSessionExpiredState(notification:)),
            name: Notification.Name("sessionExpired"),
            object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /// Hide the loader when the view disappears
        CustomLoader.hide()
    }

    /// Handles session expiration notification.
    @objc func handleSessionExpiredState(notification: Notification) {
        /// Dismiss the view controller when the session expires
        self.dismiss(animated: false, completion: nil)
    }

    // MARK: - UI Configuration
    /// Configures the UI elements with custom colors and styles.
    func configureUI() {
        // Set the background color of the view
        self.view.backgroundColor = VAColorUtility.white

        // Set the background color of the navigation bar
        self.viewNavigation.backgroundColor = VAColorUtility.defaultHeaderColor

        // Configure the close button image and tint color
        self.imgClose.image = UIImage(named: "back-icon", in: Bundle.module, with: nil)
        self.imgClose.tintColor = isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.defaultButtonColor

        // Configure the title label
        self.titleLabel.textColor = VAColorUtility.defaultButtonColor
        self.titleLabel.font = isGenAINewTheme ? GenAIFonts().normal(fontSize: 16) : UIFont(name: fontName, size: 16)

        // Set the color of the header separator
        self.viewHeaderSeperator.backgroundColor = VAColorUtility.defaultThemeTextIconColor
    }

    // MARK: - Web View Configuration
    /// Configures the web view for loading web content or videos.
    func configureWebView() {
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .clear

        // Validate the URL and load it in the web view
        let validUrlString = (webUrl.hasPrefix("http") || webUrl.hasPrefix("https")) ? webUrl : "https://\(webUrl)"
        if let url = URL(string: validUrlString) {
            if videoFormats.contains(url.pathExtension) {
                isVideoUrl = true
            }
            webView.load(URLRequest(url: url))
        }
    }

    // MARK: - Button Actions
    /// Handles the close button tap action.
    @IBAction func closeTapped(_ sender: Any) {
        webView.stopLoading()
        CustomLoader.hide()
        // Post a notification for agent status
        NotificationCenter.default.post(name: Notification.Name("AgentStatus"), object: nil)
        // Dismiss the view controller
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - WKNavigationDelegate
extension VAWebViewerVC: WKNavigationDelegate {

    /// Called when the web view starts loading content.
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Show the loader if the URL is not a video
        if !isVideoUrl {
            CustomLoader.show(isUserInterationEnabled: true)
        }
    }

    /// Called when the web view finishes loading content.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Hide the loader after a slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            CustomLoader.hide()
        })
    }

    /// Called when the web view fails to load content.
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // Print the error description
        debugPrint(error.localizedDescription)
        // Hide the loader
        CustomLoader.hide()
        // Show an alert indicating the failure to load the URL
        let alert = UIAlertController.init(title: LanguageManager.shared.localizedString(forKey: "Error"), 
                                           message: LanguageManager.shared.localizedString(forKey: "Unable to load the requested URL"),
                                           preferredStyle: .alert)
        let action = UIAlertAction.init(title: LanguageManager.shared.localizedString(forKey: "OK"), style: .default) { _ in }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    /// Decides whether to allow or cancel a navigation action.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        // Allow the navigation action
        decisionHandler(.allow)
        // Hide the loader after a slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            CustomLoader.hide()
        })
    }
}
