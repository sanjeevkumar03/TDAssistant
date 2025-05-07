// VASSOAuthenticationVC
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit
@preconcurrency import WebKit

// MARK: - Protocol Definition
/// Protocol to handle SSO authentication success or cancellation events.
protocol VASSOAuthenticationVCDelegate: AnyObject {
    /// Called when SSO login is successful.
    func ssoLoggedInSuccessfullyWith(sessionId: String, isAuthenticateOnLaunch: Bool, selectedCardIndexPath: IndexPath?)
    /// Called when SSO login is cancelled.
    func ssoLogInCancelled(isAuthenticateOnLaunch: Bool)
}

/// `VASSOAuthenticationVC` is responsible for handling SSO authentication.
/// It manages the web view for SSO login, handles navigation events, and communicates the result back to the delegate.
class VASSOAuthenticationVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cancelButton: UIButton!

    // MARK: - Properties
    var ssoURLStr = ""
    var isAuthenticateOnLaunch: Bool = false
    var isOneLoginSSO: Bool = false
    var delegate: VASSOAuthenticationVCDelegate?
    var selectedCardIndexPath: IndexPath?

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Enable light theme for the view controller
        overrideUserInterfaceStyle = .light
        /// Configure the web view for SSO login
        self.configureWebView()
        /// Configure the cancel button
        self.cancelButton.setTitleColor(VAColorUtility.defaultButtonColor, for: .normal)
        self.cancelButton.setTitle(LanguageManager.shared.localizedString(forKey: "Cancel"), for: .normal)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /// Hide the loader when the view disappears
        CustomLoader.hide()
    }

    // MARK: - Custom Methods

    /// Configures the web view for SSO login.
    func configureWebView() {
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true 
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .clear

        // Load the SSO URL in the web view
        if let link = URL(string: ssoURLStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
            webView.load(URLRequest(url: link))
        }
    }

    // MARK: - Button Actions

    /// Handles the cancel button tap action.
    @IBAction func backButton(_ sender: Any) {
        webView.stopLoading()
        CustomLoader.hide()
        self.dismiss(animated: !self.isAuthenticateOnLaunch, completion: nil) // Dismiss the view controller
        /// Notify the delegate about the cancellation
        delegate?.ssoLogInCancelled(isAuthenticateOnLaunch: self.isAuthenticateOnLaunch)
    }
}

// MARK: - WKNavigationDelegate
extension VASSOAuthenticationVC: WKNavigationDelegate {

    /// Called when the web view starts loading content.
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Show the loader while the web view is loading
        CustomLoader.show(isUserInterationEnabled: true)
    }

    /// Called when the web view finishes loading content.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Hide the loader after the content is loaded
        CustomLoader.hide()
    }

    /// Called when the web view fails to load content.
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        debugPrint(error.localizedDescription) // Log the error description
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            /// Hide the loader
            CustomLoader.hide()
            /// Show an alert for the error message
            UIAlertController.openAlertWithOk(LanguageManager.shared.localizedString(forKey: "Error"),
                                              LanguageManager.shared.localizedString(forKey: "Sorry, the requested URL not found!"),
                                              LanguageManager.shared.localizedString(forKey: "OK"),
                                              view: self) {
                /// Dismiss the view controller
                self.dismiss(animated: !self.isAuthenticateOnLaunch, completion: nil)
                /// Notify the delegate about the cancellation
                self.delegate?.ssoLogInCancelled(isAuthenticateOnLaunch: self.isAuthenticateOnLaunch)
            }
        }
    }

    /// Decides whether to allow or cancel a navigation action.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            print(url.absoluteString) // Log the URL being navigated to
            // Check if the URL matches the SSO authentication URLs
            if url.absoluteString.hasPrefix(VAConfigurations.SSOAuthURL) || url.absoluteString.hasPrefix(VAConfigurations.OneLoginSSOAuthURL) {
                debugPrint("Auth SUCCESS")
                // Parse query parameters from the URL
                if let params = url.queryParameters as NSDictionary? {
                    debugPrint(params) // Log the query parameters
                    // Extract the token and validate the type
                    guard let token = params["data"] as? String, params["type"] as? String == "auth" else {
                        return
                    }
                    debugPrint("Token =  \(token)")
                    /// Notify the delegate about the successful login
                    delegate?.ssoLoggedInSuccessfullyWith(sessionId: token, isAuthenticateOnLaunch: isAuthenticateOnLaunch, selectedCardIndexPath: selectedCardIndexPath)
                    self.dismiss(animated: true, completion: nil) // Dismiss the view controller
                }
            }
            debugPrint(navigationAction.request.url as Any) // Log the navigation action URL
            decisionHandler(.allow) // Allow the navigation action
            CustomLoader.hide() // Hide the loader
        }
    }
}

// MARK: - URL Extension
/// Extension to extract query parameters from a URL.
extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
