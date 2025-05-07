// VAChatTranscriptVC
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit

/// `VAChatTranscriptVC` is responsible for managing the chat transcript screen.
/// It handles UI setup, localization, and user interactions such as sending the chat transcript via email.
class VAChatTranscriptVC: UIViewController {
    
    // MARK: - Outlets
    // UI components connected via Interface Builder
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var imgHeaderLogo: UIImageView!
    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var feedbackTitleLabel: UILabel!
    @IBOutlet weak var transcriptTitleLabel: UILabel!
    @IBOutlet weak var sendChatLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var sendTranscriptMailButton: UIButton!
    @IBOutlet weak var closeButtonBottom: NSLayoutConstraint!
    @IBOutlet weak var headerLogoWidth: NSLayoutConstraint!
    @IBOutlet weak var closeButtonWidth: NSLayoutConstraint!

    // MARK: - Properties
    // Variables for configuration and UI customization
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var configIntegrationModel: VAConfigIntegration?
    var isFeedbackSkipped: Bool = false
    var configResulModel: VAConfigResultModel?
    var logoWidth: CGFloat = 0.0
    var isGenAINewTheme: Bool = false

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Enable light theme for the view controller
        overrideUserInterfaceStyle = .light
        /// Disable the interactive pop gesture
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        /// Set up the UI components
        self.setUI()
    }

    // MARK: - Custom Methods

    /// Sets up the UI components and applies necessary configurations.
    func setUI() {
        self.setupHeaderImageAndTitle() // Configure header image and title
        self.setLocalization() // Apply localized strings to UI elements
        
        // Adjust close button's bottom constraint based on safe area insets
        if self.view.safeAreaInsets.bottom > 0 {
            self.closeButtonBottom.constant = 0
        } else {
            self.closeButtonBottom.constant = 16
        }
        
        // Configure header label
        self.lblHeader.textColor = VAColorUtility.defaultButtonColor
        self.lblHeader.font = isGenAINewTheme ? GenAIFonts().normal(fontSize: 16) : UIFont(name: fontName, size: 16)
        
        // Configure email text field
        self.emailTF.text = VAConfigurations.customData?.email
        self.emailTF.isUserInteractionEnabled = emailTF.text?.isEmpty ?? true
        
        // Style email container
        self.emailContainer.layer.borderWidth = 1.0
        self.emailContainer.layer.borderColor = isGenAINewTheme ? VAColorUtility.borderColor_NT.cgColor : UIColor.lightGray.cgColor
        self.emailContainer.layer.cornerRadius = isGenAINewTheme ? 6 : 4
        
        // Style close button
        self.closeButton.layer.cornerRadius = isGenAINewTheme ? 22.0 : 8.0
        self.closeButton.borderWidth = 1
        self.closeButton.setTitleColor(isGenAINewTheme ? VAColorUtility.green_NT : VAColorUtility.white, for: .normal)
        self.closeButton.borderColor = isGenAINewTheme ? VAColorUtility.green_NT : VAColorUtility.senderBubbleColor
        self.closeButton.titleLabel?.font = isGenAINewTheme ? GenAIFonts().bold(fontSize: 16) : UIFont(name: fontName, size: textFontSize)
        self.closeButtonWidth.constant = isGenAINewTheme ? 150 : UIScreen.main.bounds.width - 48
        self.closeButton.backgroundColor = isGenAINewTheme ? VAColorUtility.white : VAColorUtility.senderBubbleColor
        
        // Style send transcript button
        self.sendTranscriptMailButton.tintColor = isGenAINewTheme ? VAColorUtility.green_NT : VAColorUtility.senderBubbleColor
        
        // Style labels
        self.feedbackTitleLabel.textColor = VAColorUtility.senderBubbleColor
        self.transcriptTitleLabel.textColor = VAColorUtility.themeTextIconColor
        self.sendChatLabel.textColor = VAColorUtility.themeTextIconColor
        self.emailTF.textColor = VAColorUtility.themeTextIconColor
        
        // Configure fonts for labels
        var boldFont = ""
        let fontArray = fontName.components(separatedBy: "-")
        boldFont = fontArray.count > 1 ? fontArray.first! + "-Bold" : fontName + "-Bold"
        let isBoldFont = UIFont(name: boldFont, size: textFontSize)?.isBold
        if isBoldFont == true {
            self.feedbackTitleLabel.font = isGenAINewTheme ? GenAIFonts().bold(fontSize: 18) : UIFont(name: boldFont, size: textFontSize + 4)
            self.transcriptTitleLabel.font = isGenAINewTheme ? GenAIFonts().bold(fontSize: 16) : UIFont(name: boldFont, size: textFontSize)
        } else {
            self.feedbackTitleLabel.font = isGenAINewTheme ? GenAIFonts().bold(fontSize: 18) : UIFont.boldSystemFont(ofSize: textFontSize + 4)
            self.transcriptTitleLabel.font = isGenAINewTheme ? GenAIFonts().bold(fontSize: 16) : UIFont.boldSystemFont(ofSize: textFontSize)
        }
        self.sendChatLabel.font = isGenAINewTheme ? GenAIFonts().normal(fontSize: 15) : UIFont(name: fontName, size: textFontSize)
        self.emailTF.font = isGenAINewTheme ? GenAIFonts().normal() : UIFont(name: fontName, size: textFontSize)
    }

    /// Applies localized strings to UI elements.
    func setLocalization() {
        feedbackTitleLabel.text = LanguageManager.shared.localizedString(forKey: isFeedbackSkipped ? "Thank You" : "Thanks for your feedback!")
        transcriptTitleLabel.text = LanguageManager.shared.localizedString(forKey: "Chat Transcript")
        sendChatLabel.text = LanguageManager.shared.localizedString(forKey: "Send Chat Transcript to your email address")
        emailTF.placeholder = LanguageManager.shared.localizedString(forKey: "Please Enter Email")
        closeButton.setTitle(LanguageManager.shared.localizedString(forKey: "Close"), for: .normal)
    }
    
    /// Configures the header image and title.
    func setupHeaderImageAndTitle() {
        self.lblHeader.isHidden = true // Hide header label as per feedback
        self.headerLogoWidth.constant = logoWidth
        
        // Load header logo image
        if configResulModel?.headerLogo?.isEmpty ?? true {
            self.imgHeaderLogo?.image = UIImage(named: "telus-icon", in: Bundle.module, with: nil)
        } else {
            ImageDownloadManager().loadImage(imageURL: configResulModel?.headerLogo ?? "") {[weak self] (_, downloadedImage) in
                if let img = downloadedImage {
                    DispatchQueue.main.async {
                        self?.imgHeaderLogo?.image = img
                    }
                }
            }
        }
    }

    // MARK: - Button Actions

    /// Handles the close button tap action.
    @IBAction func closeBtnAction(_ sender: Any) {
        self.closeChatbot()
    }

    /// Handles the send button tap action.
    @IBAction func sendBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        
        // Validate email input
        if emailTF.text?.isEmpty ?? false {
            // Show alert for empty email
            UIAlertController.openAlertWithOk(LanguageManager.shared.localizedString(forKey: "Error"),
                                              LanguageManager.shared.localizedString(forKey: "Please Enter Email"),
                                              LanguageManager.shared.localizedString(forKey: "OK"), view: self,
                                              completion: nil)
        } else if isValidEmail(emailTF.text!) {
            // Send transcript via API
            APIManager.sharedInstance.postTranscript(
                botId: VAConfigurations.botId,
                email: emailTF.text ?? "",
                language: VAConfigurations.getCurrentLanguageCode(),
                sessionId: UserDefaultsManager.shared.getSessionID(),
                user: VAConfigurations.userJid) { (resultStr) in
                    DispatchQueue.main.async {
                        // Show success alert
                        UIAlertController.openAlertWithOk(LanguageManager.shared.localizedString(forKey: "Email Sent"),
                                                          LanguageManager.shared.localizedString(forKey: "Email will be sent to you shortly"),
                                                          LanguageManager.shared.localizedString(forKey: "OK"),
                                                          view: self) {
                            self.closeChatbot()
                        }
                    }
                }
        } else {
            // Show alert for invalid email
            UIAlertController.openAlertWithOk(LanguageManager.shared.localizedString(forKey: "Error"),
                                              LanguageManager.shared.localizedString(forKey: "Please enter valid email"),
                                              LanguageManager.shared.localizedString(forKey: "OK"), view: self, 
                                              completion: nil)
        }
    }

    /// Closes the chatbot and resets user defaults.
    private func closeChatbot() {
        UserDefaultsManager.shared.resetAllUserDefaults()
        VAConfigurations.virtualAssistant?.delegate?.didTapCloseChatbot()
        CustomLoader.hide()
        
        if self.parent?.parent == nil {
            self.dismiss(animated: false, completion: nil)
        } else {
            if self.parent?.children.count ?? 0 > 0 {
                let viewControllers: [UIViewController] = self.parent!.children
                for viewController in viewControllers {
                    viewController.willMove(toParent: nil)
                    viewController.view.removeFromSuperview()
                    viewController.removeFromParent()
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension VAChatTranscriptVC: UITextFieldDelegate {
    /// Handles the return key press on the text field.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
