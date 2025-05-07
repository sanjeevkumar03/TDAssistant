// NormalFeedbackVC.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit

/// `NormalFeedbackVC` is responsible for collecting user feedback through a survey form.
/// It includes options for rating, additional feedback, and issue resolution.
class NormalFeedbackVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var imgHeaderLogo: UIImageView!
    @IBOutlet weak var emj3Button: UIButton!
    @IBOutlet weak var emj2Button: UIButton!
    @IBOutlet weak var emj1Button: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var feedTextViewContainer: UIView!
    @IBOutlet weak var feedTextView: UITextView!
    @IBOutlet weak var lblStaticTitle: UILabel!
    @IBOutlet weak var lblStaticAdditionalFeedback: UILabel!
    @IBOutlet weak var lblFeedbackCharLimit: UILabel!
    @IBOutlet weak var lblStaticResolveIssue: UILabel!
    @IBOutlet weak var radioButtonViewContainer: UIView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var radioButtonViewContainerHC: NSLayoutConstraint!
    @IBOutlet weak var headerLogoWidth: NSLayoutConstraint!
    @IBOutlet weak var buttonsStack: UIStackView!
    @IBOutlet weak var buttonStackBottom: NSLayoutConstraint!
    
    // MARK: - Properties
    var isAdditionalFeedback: Bool = false
    var ratingScale: Int = 0
    let addtionalFeedbackPlaceholder = LanguageManager.shared.localizedString(forKey: "Feedback Comment")
    var maxCharacterLength: Int = 250
    var chatTranscriptEnabled: Bool = false
    var isIssueResolved: Bool?
    var radioUnselectedImg = UIImage()
    var radioSelectedImg = UIImage()
    var npsSettings: VAConfigNPSSettings?
    var isCustomizeSurveyEnabled: Bool = false
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var configResulModel: VAConfigResultModel?
    var logoWidth: CGFloat = 0.0
    var isGenAINewTheme: Bool = false
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Enable light theme for the view controller
        overrideUserInterfaceStyle = .light
        
        /// Disable the interactive pop gesture
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        /// Hide the additional feedback section initially
        self.hideAdditionalFeedback()
        
        /// Hide the radio buttons (Yes/No) initially
        self.hideRadio()
        
        /// Set the delegate for the feedback text view
        self.feedTextView.delegate = self
        
        /// Set localized strings for UI elements
        self.setLocalization()
        
        /// Configure the UI elements
        self.setupUI()
    }
    // end
    
    // MARK: - Set Localization
/// Sets localized strings for UI elements to ensure the feedback screen supports multiple languages.
func setLocalization() {
    // Configure the "Yes" and "No" buttons
    configureButton(yesButton, titleKey: "YES")
    configureButton(noButton, titleKey: "NO")

    // Configure the static label for the "Did we resolve your issue?" question
    configureLabel(lblStaticResolveIssue, textKey: "Did we resolve your issue?")

    // Configure the "Skip" or "Close" button based on whether chat transcript is enabled
    let skipOrCloseKey = chatTranscriptEnabled ? "Skip feedback" : "Close"
    skipButton.setTitle(LanguageManager.shared.localizedString(forKey: skipOrCloseKey), for: .normal)

    // Configure the static labels for additional feedback and the feedback question
    configureLabel(lblStaticAdditionalFeedback, textKey: "Additional Feedback")
    configureLabel(lblStaticTitle, textKey: "Regarding the TELUS Virtual Assistant that just helped you, how would you rate its performance?")

    // Configure the "Submit" button
    submitButton.setTitle(LanguageManager.shared.localizedString(forKey: "Submit"), for: .normal)
}

/// Configures a button with a localized title and default font settings.
private func configureButton(_ button: UIButton, titleKey: String) {
    button.setTitle(LanguageManager.shared.localizedString(forKey: titleKey), for: .normal)
    button.titleLabel?.minimumScaleFactor = 0.5
    button.titleLabel?.adjustsFontSizeToFitWidth = true
    button.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
}

/// Configures a label with a localized text and default font settings.
private func configureLabel(_ label: UILabel, textKey: String) {
    label.text = LanguageManager.shared.localizedString(forKey: textKey)
    label.font = UIFont(name: fontName, size: textFontSize)
}
    
    // MARK: - Setup UI
    /// Configures the UI elements with custom styles and themes.
    func setupUI() {
        // Configure header image and title
        self.setupHeaderImageAndTitle()
        
        // Configure header label
        self.lblHeader.textColor = VAColorUtility.defaultButtonColor
        self.lblHeader.font = isGenAINewTheme ? GenAIFonts().normal(fontSize: 16) : UIFont(name: fontName, size: 16)
        
        // Configure static labels
        configureStaticLabel(lblStaticTitle, textColor: isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.themeTextIconColor, font: isGenAINewTheme ? GenAIFonts().bold(fontSize: 15) : UIFont(name: fontName, size: textFontSize))
        configureStaticLabel(lblStaticAdditionalFeedback, textColor: isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.themeTextIconColor, font: isGenAINewTheme ? GenAIFonts().bold(fontSize: 15) : UIFont(name: fontName, size: textFontSize))
        
        // Configure emoji buttons
        configureEmojiButton(emj1Button, imageName: "emoji4", tintColor: isGenAINewTheme ? VAColorUtility.purple_NT : VAColorUtility.senderBubbleColor)
        configureEmojiButton(emj2Button, imageName: "emoji6", tintColor: isGenAINewTheme ? VAColorUtility.purple_NT : VAColorUtility.senderBubbleColor)
        configureEmojiButton(emj3Button, imageName: "emoji7", tintColor: isGenAINewTheme ? VAColorUtility.purple_NT : VAColorUtility.senderBubbleColor)
        
        // Configure radio buttons
        configureRadioButtons()
        
        // Configure feedback text view and character limit label
        self.feedTextView.font = isGenAINewTheme ? GenAIFonts().normal() : UIFont(name: fontName, size: textFontSize)
        self.lblFeedbackCharLimit.font = isGenAINewTheme ? GenAIFonts().normal() : UIFont(name: fontName, size: textFontSize)
        
        // Configure button stack layout
        configureButtonStack()
        
        // Configure submit and skip buttons
        configureSubmitButton()
        configureSkipButton()
    }
    
    // MARK: - Helper Functions
    /// Configures a static label with the given text color and font.
    private func configureStaticLabel(_ label: UILabel, textColor: UIColor, font: UIFont?) {
        label.textColor = textColor
        label.font = font
    }
    
    /// Configures an emoji button with the given image and tint color.
    private func configureEmojiButton(_ button: UIButton, imageName: String, tintColor: UIColor) {
        button.tintColor = tintColor
        button.setImage(UIImage(named: imageName, in: Bundle.module, with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    /// Configures the radio buttons (Yes/No) with unselected images and tint colors.
    private func configureRadioButtons() {
        radioUnselectedImg = UIImage(named: "radio-unChecked", in: Bundle.module, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        radioSelectedImg = UIImage(named: "radio-checked", in: Bundle.module, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
            self.yesButton.tintColor = isGenAINewTheme ? VAColorUtility.purple_NT : VAColorUtility.senderBubbleColor
            self.noButton.tintColor = isGenAINewTheme ? VAColorUtility.purple_NT : VAColorUtility.senderBubbleColor
            self.yesButton.setImage(self.radioUnselectedImg, for: .normal)
            self.noButton.setImage(self.radioUnselectedImg, for: .normal)
        }
    }
    
    /// Configures the button stack layout based on the theme.
    private func configureButtonStack() {
        if isGenAINewTheme {
            buttonsStack.axis = .horizontal
            buttonStackBottom.constant = 16
            buttonsStack.distribution = .fillEqually
            buttonsStack.spacing = 24
            buttonsStack.removeArrangedSubview(submitButton)
            buttonsStack.removeArrangedSubview(skipButton)
            buttonsStack.addArrangedSubview(skipButton)
            buttonsStack.addArrangedSubview(submitButton)
        } else {
            buttonsStack.axis = .vertical
            buttonStackBottom.constant = 4
            buttonsStack.distribution = .fillEqually
            buttonsStack.spacing = 4
        }
    }
    
    /// Configures the submit button with styles and themes.
    private func configureSubmitButton() {
        self.submitButton.layer.cornerRadius = isGenAINewTheme ? 22 : 8.0
        self.submitButton.setTitleColor(isGenAINewTheme ? VAColorUtility.white : VAColorUtility.senderBubbleColor, for: .normal)
        self.submitButton.isUserInteractionEnabled = false
        self.submitButton.backgroundColor = isGenAINewTheme ? VAColorUtility.borderColor_NT : UIColor.clear
        self.submitButton.titleLabel?.font = isGenAINewTheme ? GenAIFonts().bold(fontSize: 16) : UIFont(name: fontName, size: textFontSize)
        self.submitButton.layer.borderWidth = isGenAINewTheme ? 0 : 1
        self.submitButton.layer.borderColor = isGenAINewTheme ? nil : VAColorUtility.senderBubbleColor.cgColor
    }
    
    /// Configures the skip button with styles and themes.
    private func configureSkipButton() {
        self.skipButton.layer.cornerRadius = isGenAINewTheme ? 22.0 : 8.0
        self.skipButton.layer.borderWidth = isGenAINewTheme ? 1.0 : 0
        self.skipButton.layer.borderColor = isGenAINewTheme ? VAColorUtility.green_NT.cgColor : nil
        self.skipButton.titleLabel?.font = isGenAINewTheme ? GenAIFonts().bold(fontSize: 16) : UIFont(name: fontName, size: textFontSize)
        self.skipButton.backgroundColor = .white
        self.skipButton.setTitleColor(isGenAINewTheme ? VAColorUtility.green_NT : VAColorUtility.senderBubbleColor, for: .normal)
    }
    
    // MARK: - Set up header image and title
    /// This function is used to update header image and title
    func setupHeaderImageAndTitle() {
        // Header Title
        //self.lblHeader.text = configResulModel?.name ?? ""
        self.lblHeader.isHidden = true ///As per feedback comments (Aditya T)
        // Header Image
        self.headerLogoWidth.constant = logoWidth
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    // MARK: - Hide Additional Feedback view
    func hideAdditionalFeedback() {
        feedTextViewContainer.isHidden = true
        feedTextViewContainer.backgroundColor = .clear
    }
    
    // MARK: - Show Additional Feedback View
    /// Displays the additional feedback text view with placeholder text and styles.
    func showAdditionalFeedback() {
        self.feedTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        self.feedTextView.text = self.addtionalFeedbackPlaceholder
        self.feedTextView.textColor = UIColor.lightGray
        self.feedTextView.roundedShadowView(
            cornerRadius: isGenAINewTheme ? 6 : 10,
            borderWidth: 1, 
            borderColor: isGenAINewTheme ? VAColorUtility.borderColor_NT : VAColorUtility.themeTextIconColor
        )
        self.feedTextViewContainer.isHidden = false
    }
    // MARK: - Hide Radio buttons YES or NO
    func hideRadio() {
        self.radioButtonViewContainer.isHidden = true
        self.radioButtonViewContainerHC.constant = 0
    }
    // end
    
    // MARK: - Show Radio buttons YES or NO
    func showRadio() {
        self.radioButtonViewContainer.isHidden = false
        self.radioButtonViewContainerHC.constant = 80
    }
    // end
    
    /// Closes the chatbot and performs cleanup operations.
    private func closeChatbot() {
        UserDefaultsManager.shared.resetAllUserDefaults()    
        VAConfigurations.virtualAssistant?.delegate?.didTapCloseChatbot()
        // Hide any custom loaders that might be active.
        CustomLoader.hide()
        // Check if the current view controller has no parent or grandparent view controllers.
        if self.parent?.parent == nil {
            self.dismiss(animated: false) {}
        } else {
            // If the current view controller has a parent, check if it has child view controllers.
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
    
    // MARK: - IBAction
    /// Handles the selection of an emoji button and updates the UI accordingly.
    @IBAction func emojiBtnAction(_ sender: UIButton) {
        // Enable the submit button and update its appearance
        self.submitButton.isUserInteractionEnabled = true
        self.submitButton.backgroundColor = isGenAINewTheme ? VAColorUtility.green_NT : VAColorUtility.senderBubbleColor
        self.submitButton.setTitleColor(VAColorUtility.white, for: .normal)
        
        // Check if the feedback text view contains valid text
        if self.feedTextView.text == self.addtionalFeedbackPlaceholder || self.feedTextView.text.isEmpty {
            // Reset the feedback text view
            self.feedTextView.text = ""
            self.feedTextView.endEditing(true)
            
            // Show or hide the additional feedback section based on settings
            if isCustomizeSurveyEnabled && !(self.npsSettings?.additionalFeedback ?? false) {
                hideAdditionalFeedback()
            } else {
                showAdditionalFeedback()
            }
        }
        
        // Show or hide the radio buttons (Yes/No) based on the "issue resolved" setting
        self.npsSettings?.issueResolved ?? false ? showRadio() : hideRadio()
        
        // Update the emoji selection and rating scale based on the selected button
        updateEmojiSelection(for: sender.tag)
    }
    
    /// Updates the emoji selection and sets the corresponding rating scale.
    private func updateEmojiSelection(for tag: Int) {
        // Define the emoji image names and their filled versions
        let emojiImages = [
            (normal: "emoji4", filled: "emoji4-filled"),
            (normal: "emoji6", filled: "emoji6-filled"),
            (normal: "emoji7", filled: "emoji7-filled")
        ]
        
        // Iterate through the emoji buttons and update their images
        [emj1Button, emj2Button, emj3Button].enumerated().forEach { index, button in
            let imageName = index == tag ? emojiImages[index].filled : emojiImages[index].normal
            button?.setImage(
                UIImage(named: imageName, in: Bundle.module, with: nil)?.withRenderingMode(.alwaysTemplate),
                for: .normal
            )
        }
        
        // Set the rating scale based on the selected emoji
        self.ratingScale = [3, 7, 9][tag]
    }
    
    // MARK: - Move to Chat Transcript Screen
    /// Navigates to the chat transcript screen with the required configurations.
    func moveToChatTranscriptScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.module)
        if let chatTranscriptVC = storyboard.instantiateViewController(withIdentifier: "VAChatTranscriptVC") as? VAChatTranscriptVC {
            // Pass necessary configurations to the chat transcript screen
            chatTranscriptVC.textFontSize = self.textFontSize
            chatTranscriptVC.fontName = self.fontName
            chatTranscriptVC.configResulModel = self.configResulModel
            chatTranscriptVC.logoWidth = self.logoWidth
            chatTranscriptVC.isGenAINewTheme = self.isGenAINewTheme
            
            // Navigate to the chat transcript screen
            self.navigationController?.pushViewController(chatTranscriptVC, animated: false)
        }
    }
    
    /// Handles the submission of feedback when the submit button is tapped.
    @IBAction func submitBtnAction(_ sender: Any) {
        // Prepare the feedback message
        let feedbackMsg = (self.feedTextView.text == self.addtionalFeedbackPlaceholder) ? "" : self.feedTextView.text
        
        // Prepare the issue resolved status
        let strIssueResolved: String
        if let isResolved = self.isIssueResolved {
            strIssueResolved = isResolved ? "true" : "false"
        } else {
            strIssueResolved = ""
        }
        
        // Call the API to submit feedback
        APIManager.sharedInstance.submitNPSSurveyFeedback(
            reason: [],
            score: self.ratingScale,
            feedback: feedbackMsg ?? "",
            issueResolved: strIssueResolved
        ) { resultStr in
            DispatchQueue.main.async {
                // Show an alert with the API response
                UIAlertController.openAlertWithOk(
                    LanguageManager.shared.localizedString(forKey: "Message!"),
                    resultStr,
                    LanguageManager.shared.localizedString(forKey: "OK"),
                    view: self
                ) {
                    // Navigate to the chat transcript screen or close the chatbot based on the settings
                    self.chatTranscriptEnabled ? self.moveToChatTranscriptScreen() : self.closeChatbot()
                }
            }
        }
    }
    
    /// This function is called when user tapped on Close button
    @IBAction func closeBtnAction(_ sender: Any) {
        if self.chatTranscriptEnabled == true {
            self.moveToChatTranscriptScreen()
        } else {
            self.closeChatbot()
        }
    }
    
    /// This function is used when user tap no button
    @IBAction func noBtnAction(_ sender: UIButton) {
        self.yesButton.setImage(radioUnselectedImg, for: .normal)
        self.noButton.setImage(radioSelectedImg, for: .normal)
        self.isIssueResolved = false
    }
    
    /// This function is used when user tap yes button
    @IBAction func yesBtnAction(_ sender: UIButton) {
        self.yesButton.setImage(radioSelectedImg, for: .normal)
        self.noButton.setImage(radioUnselectedImg, for: .normal)
        self.isIssueResolved = true
    }
}

// MARK: - NormalFeedbackVC extension of UITextViewDelegate
extension NormalFeedbackVC: UITextViewDelegate {
    
    /// Handles text changes in the feedback text view and updates the character limit label.
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        
        // Dismiss the keyboard when the return key is pressed
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        // Update the character limit label if the new text is within the allowed length
        if newText.count <= self.maxCharacterLength {
            self.lblFeedbackCharLimit.text = "\(newText.count)/\(self.maxCharacterLength)"
        }
        
        // Ensure the new text does not exceed the maximum character length
        return newText.count <= self.maxCharacterLength
    }
    
    /// Prepares the feedback text view for editing by clearing the placeholder text.
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == self.addtionalFeedbackPlaceholder {
            textView.text = ""
            self.feedTextView.textColor = isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.themeTextIconColor
        }
        return true
    }
    
    /// Restores the placeholder text if the feedback text view is empty after editing.
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = self.addtionalFeedbackPlaceholder
            self.feedTextView.textColor = UIColor.lightGray
        }
    }
}
