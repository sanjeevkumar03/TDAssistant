// YoutubePlayerVC.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit
@preconcurrency import WebKit
import SDWebImage

/// `YoutubePlayerVC` is responsible for playing YouTube videos within a web view.
/// It handles the configuration of the web view, loading YouTube videos, and managing user interactions.
class YoutubePlayerVC: UIViewController {

    // MARK: - Outlets
    // UI components connected via Interface Builder
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var imgClose: UIImageView!
    @IBOutlet weak var viewHeaderSeperator: UIView!
    @IBOutlet weak var webViewObj: WKWebView!

    // MARK: - Properties
    // Variables for configuration and UI customization
    var videoUrl: String = ""
    var youTubeVideoUrl: URL!
    var didLoadVideo = false
    var webView = WKWebView()

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Enable light theme for the view controller
        overrideUserInterfaceStyle = .light
        /// Set the background color of the view
        self.view.backgroundColor = .black
        /// Set the tint color of the close button
        self.imgClose.tintColor = VAColorUtility.white
        /// Configure the web view after a slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.configureWebView()
            // self.playVideoInIframe() // Uncomment if iframe-based playback is needed
        })
    }

    // MARK: - Custom Methods

    /// Configures the web view for playing YouTube videos.
    func configureWebView() {
        // Create and configure the web view settings
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.allowsInlineMediaPlayback = true // Allow inline playback
        webViewConfig.mediaTypesRequiringUserActionForPlayback = [] // Disable user action requirement for playback
        webViewConfig.allowsPictureInPictureMediaPlayback = true // Enable Picture-in-Picture mode
        webViewConfig.preferences.javaScriptEnabled = true // Enable JavaScript

        // Ensure the layout is updated before adding the web view
        self.view.layoutIfNeeded()

        // Initialize the web view with the configuration
        webView = WKWebView(frame: self.containerView.bounds, configuration: webViewConfig)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = false // Disable navigation gestures
        webView.isOpaque = false // Make the web view transparent
        webView.scrollView.backgroundColor = .black

        // Extract the video ID from the provided video URL
        let videoID = Helper.getYouTubeVideoIdToPlayVideo(videoUrl: videoUrl)
        // Construct the YouTube embed URL
        let url = "https://www.youtube.com/embed/\(videoID)?playsinline=1?autoplay=1"

        // Load the YouTube video in the web view
        if let url = URL(string: url) {
            var youtubeRequest = URLRequest(url: url)
            youtubeRequest.setValue("https://www.youtube.com", forHTTPHeaderField: "Referer") // Set the referer header
            webView.load(youtubeRequest) 
            CustomLoader.show()
            containerView.addSubview(webView)
        }
    }

    /// Plays the video using an iframe-based approach.
    func playVideoInIframe() {
        self.view.layoutIfNeeded() // Ensure the layout is updated
        webViewObj.isHidden = false
        webViewObj.configuration.mediaTypesRequiringUserActionForPlayback = [] // Disable user action requirement for playback

        // Extract the video ID from the provided video URL
        let videoID = videoUrl.components(separatedBy: "=").last ?? ""
        // Construct the YouTube embed URL
        let url = "https://www.youtube.com/embed/\(videoID)"

        // Load the video in the web view object
        if let url = URL(string: url) {
            youTubeVideoUrl = url
            if !didLoadVideo {
                webViewObj.loadHTMLString(embedVideoHtml, baseURL: nil) // Load the iframe HTML
                didLoadVideo = true // Mark the video as loaded
            }
        }
    }

    /// HTML string for embedding the YouTube video using an iframe.
    var embedVideoHtml: String {
        return """
            <!DOCTYPE html>
            <html>
            <body>
            <!-- The <iframe> (and video player) will replace this <div> tag. -->
            <div id="player"></div>

            <script>
            var tag = document.createElement('script');
            tag.src = "https://www.youtube.com/iframe_api";
            var firstScriptTag = document.getElementsByTagName('script')[0];
            firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

            var player;
            function onYouTubeIframeAPIReady() {
            player = new YT.Player('player', {
            playerVars: { 'autoplay': 1, 'controls': 0, 'playsinline': 1 },
            height: '\(webViewObj.frame.height)',
            width: '\(webViewObj.frame.width)',
            videoId: '\(youTubeVideoUrl.lastPathComponent)',
            events: {
            'onReady': onPlayerReady
            }
            });
            }

            function onPlayerReady(event) {
            event.target.playVideo();
            }
            </script>
            </body>
            </html>
            """
    }

    // MARK: - Button Actions

    /// Handles the close button tap action.
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension YoutubePlayerVC: WKNavigationDelegate {

    /// Called when the web view starts loading content.
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }

    /// Called when the web view finishes loading content.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        CustomLoader.hide()
    }

    /// Called when the web view fails to load content.
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        CustomLoader.hide()
        debugPrint(error.localizedDescription)

        // Show an alert indicating the failure to play the video
        let alert = UIAlertController.init(title: LanguageManager.shared.localizedString(forKey: "Error"),
                                           message: LanguageManager.shared.localizedString(forKey: "Unable to play video"),
                                           preferredStyle: .alert)
        let action = UIAlertAction.init(title: LanguageManager.shared.localizedString(forKey: "OK"), style: .default) { _ in }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
