// VASettingsVC
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit
import IQKeyboardManagerSwift

/// `VASettingsVC` is responsible for managing the settings screen of the virtual assistant.
/// It allows users to configure language, text-to-speech, and chat transcript options.
class VASettingsVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var channelContainer: UIView!
    @IBOutlet weak var languageContainer: UIView!
    @IBOutlet weak var languagelabel: UILabel!
    @IBOutlet weak var channellabel: UILabel!
    @IBOutlet weak var selectLanguageLbl: UILabel!
    @IBOutlet weak var selectChannelLbl: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var viewHeaderSeperator: UIView!
    @IBOutlet weak var imgChannelDropdown: UIImageView!
    @IBOutlet weak var imgLanguageDropdown: UIImageView!
    @IBOutlet weak var viewChannel: UIView!
    @IBOutlet weak var viewLanguage: UIView!
    @IBOutlet weak var viewTextToSpeech: UIView!
    @IBOutlet weak var viewChatTranscript: UIView!
    @IBOutlet weak var lblTextToSpeech: UILabel!
    @IBOutlet weak var lblEnableTextToSpeech: UILabel!
    @IBOutlet weak var switchTextToSpeech: UISwitch!
    @IBOutlet weak var lblChatTranscript: UILabel!
    @IBOutlet weak var lblSendChatTranscript: UILabel!
    @IBOutlet weak var transcriptEmailTF: UITextField!
    @IBOutlet weak var sendTranscriptMailButton: UIButton!

    // MARK: - Properties
    var languageSelected = ""
    var channelSelected = ""
    var selectedLanguageString: String = ""
    var isTextToSpeechEnable: Bool = true
    var configIntegrationModel: VAConfigIntegration?
    var chatTranscriptEnabled: Bool = false
    var oldSelectedLanguage: String = ""
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var isGenAINewTheme: Bool = false

    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Enable light theme for the view controller
        overrideUserInterfaceStyle = .light
        /// Disable the interactive pop gesture
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        /// Configure the UI elements
        self.configureUI()
        /// Get the current language and update the UI
        self.getCurrentLanguage()
        /// Configure the back button
        self.btnBack.setTitle("", for: .normal)
        /// Configure the email text field
        self.transcriptEmailTF.isUserInteractionEnabled = configIntegrationModel?.editEmail ?? true
        self.transcriptEmailTF.text = VAConfigurations.customData?.email

        // Hide or show specific views based on configuration
        if VAConfigurations.isChatTool {
            /// Hide channel, text-to-speech, and chat transcript options for ChatTool
            self.viewChannel.isHidden = true
            self.viewTextToSpeech.isHidden = true
            self.viewChatTranscript.isHidden = true
        } else {
            if self.chatTranscriptEnabled && !(self.transcriptEmailTF.text?.isEmpty ?? true) {
                /// Show chat transcript option
                self.viewChatTranscript.isHidden = false
            } else {
                /// Hide chat transcript option
                self.viewChatTranscript.isHidden = true
            }
        }
        /// Hide channel selection as per feedback
        self.viewChannel.isHidden = true
        /// Disable text-to-speech for now
        self.viewTextToSpeech.isHidden = true
        /// Set localized strings for UI elements
        self.setLocalization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// Enable IQKeyboardManager for handling keyboard interactions
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.toolbarConfiguration.placeholderConfiguration.showPlaceholder = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /// Disable IQKeyboardManager when the view disappears
        IQKeyboardManager.shared.enable = false
    }

    // MARK: - Get Current Language
    /// Retrieves the current language and updates the language label.
    func getCurrentLanguage() {
        let filteredData = VAConfigurations.arrayOfLanguages.filter { languageModel in
            return languageModel.lang == VAConfigurations.getCurrentLanguageCode()
        }

        if filteredData.count > 0 {
            self.languagelabel.text = filteredData[0].displayName?.capitalized
        } else {
            self.languagelabel.text = "English"
        }
        oldSelectedLanguage = self.languagelabel.text ?? ""
    }

    // MARK: - Localization
    /// Sets localized strings for UI elements.
    func setLocalization() {
        self.lblHeader.text = LanguageManager.shared.localizedString(forKey: "Widget Settings")
        self.transcriptEmailTF.placeholder = LanguageManager.shared.localizedString(forKey: "Please Enter Email")
        self.selectLanguageLbl.text = LanguageManager.shared.localizedString(forKey: "Select Language")
        self.selectChannelLbl.text = LanguageManager.shared.localizedString(forKey: "Select Channel")
        self.saveButton.setTitle(LanguageManager.shared.localizedString(forKey: "Save"), for: .normal)
        self.cancelButton.setTitle(LanguageManager.shared.localizedString(forKey: "Cancel"), for: .normal)
        self.lblTextToSpeech.text = LanguageManager.shared.localizedString(forKey: "Text to speech")
        self.lblEnableTextToSpeech.text = LanguageManager.shared.localizedString(forKey: "Enable text to speech")
        self.lblChatTranscript.text = LanguageManager.shared.localizedString(forKey: "Chat Transcript")
        self.lblSendChatTranscript.text = LanguageManager.shared.localizedString(forKey: "Send Chat Transcript to your email address")
        self.channellabel.text = LanguageManager.shared.localizedString(forKey: "Mobile")
        self.channelSelected = LanguageManager.shared.localizedString(forKey: "Mobile")
    }

    // MARK: - Configure UI
    /// Configures the UI elements with custom colors, fonts, and styles.
    func configureUI() {
        // Apply rounded corners and borders to containers
        let cornerRadius = isGenAINewTheme ? 4 : 8
        let borderColor = isGenAINewTheme ? VAColorUtility.borderColor_NT : VAColorUtility.defaultThemeTextIconColor
        [channelContainer, languageContainer, transcriptEmailTF].forEach {
            $0?.roundedShadowView(cornerRadius: CGFloat(cornerRadius), borderWidth: 1, borderColor: borderColor)
        }

        // Configure background colors
        self.view.backgroundColor = VAColorUtility.white
        self.viewNavigation.backgroundColor = VAColorUtility.defaultHeaderColor
        self.viewHeaderSeperator.backgroundColor = VAColorUtility.defaultThemeTextIconColor

        // Configure tint colors
        let backTintColor = isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.defaultButtonColor
        self.imgBack.tintColor = backTintColor
        self.imgChannelDropdown.tintColor = backTintColor
        self.imgLanguageDropdown.tintColor = backTintColor

        // Configure text-to-speech switch
        self.switchTextToSpeech.isOn = VAConfigurations.isTextToSpeechEnable
        self.switchTextToSpeech.onTintColor = VAColorUtility.senderBubbleColor
        self.switchTextToSpeech.tintColor = VAColorUtility.receiverBubbleColor
        self.switchTextToSpeech.layer.cornerRadius = self.switchTextToSpeech.frame.height / 2.0
        self.switchTextToSpeech.backgroundColor = VAColorUtility.receiverBubbleColor
        self.switchTextToSpeech.clipsToBounds = true

        // Configure buttons
        self.sendTranscriptMailButton.tintColor = isGenAINewTheme ? VAColorUtility.green_NT : VAColorUtility.senderBubbleColor
        self.sendTranscriptMailButton.backgroundColor = .clear
        self.cancelButton.layer.cornerRadius = isGenAINewTheme ? 22.0 : 8.0
        self.cancelButton.layer.borderWidth = 1.0
        self.cancelButton.layer.borderColor = isGenAINewTheme ? VAColorUtility.green_NT.cgColor : VAColorUtility.senderBubbleColor.cgColor
        self.cancelButton.backgroundColor = .white
        self.cancelButton.setTitleColor(isGenAINewTheme ? VAColorUtility.green_NT : VAColorUtility.senderBubbleColor, for: .normal)
        
        self.saveButton.layer.cornerRadius = isGenAINewTheme ? 22.0 : 8.0
        self.saveButton.setTitleColor(VAColorUtility.white, for: .normal)
        self.saveButton.backgroundColor = isGenAINewTheme ? VAColorUtility.borderColor_NT : UIColor.lightGray

        // Add padding to the email text field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.transcriptEmailTF.frame.size.height))
        self.transcriptEmailTF.leftView = paddingView
        self.transcriptEmailTF.leftViewMode = .always

        // Configure fonts
        let normalFont = isGenAINewTheme ? GenAIFonts().normal() : UIFont(name: fontName, size: textFontSize)
        let boldFont = isGenAINewTheme ? GenAIFonts().bold() : UIFont(name: fontName, size: textFontSize)
        let headerFont = isGenAINewTheme ? GenAIFonts().normal(fontSize: 16) : UIFont(name: fontName, size: 16)

        self.lblHeader.font = headerFont
        self.transcriptEmailTF.font = normalFont
        self.sendTranscriptMailButton.titleLabel?.font = normalFont
        self.saveButton.titleLabel?.font = boldFont
        self.cancelButton.titleLabel?.font = boldFont
        self.selectChannelLbl.font = boldFont
        self.selectLanguageLbl.font = boldFont
        self.channellabel.font = normalFont
        self.languagelabel.font = normalFont
        self.lblChatTranscript.font = boldFont
        self.lblSendChatTranscript.font = boldFont

        // Configure text colors
        let txtColor = isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : .black
        [selectLanguageLbl, languagelabel, selectChannelLbl, channellabel, lblChatTranscript, lblSendChatTranscript, transcriptEmailTF].forEach {
            ($0 as? UILabel)?.textColor = txtColor
        }
        if !isGenAINewTheme {
            self.lblHeader.textColor =  VAColorUtility.senderBubbleColor
        }
    }
    
    // MARK: - Present List Popover View
    func presentListingPopover(forChannel: Bool, sender: UIButton) {
        if forChannel {
            let mobile = LanguageManager.shared.localizedString(forKey: "Mobile")
            VAPopoverListVC.openPopoverListView(arrayOfData: [mobile], viewController: self, sender: imgChannelDropdown, fontName: self.fontName, textFontSize: self.textFontSize, isGenaAINewTheme: self.isGenAINewTheme) { (_, item) in
                self.channellabel.text = item
                self.channelSelected = item
                self.saveButton.backgroundColor = self.isGenAINewTheme ? VAColorUtility.green_NT : VAColorUtility.senderBubbleColor
            }
        } else {
            var array: [String] = []
            for item in VAConfigurations.arrayOfLanguages {
                array.append(item.displayName?.capitalized ?? "")
            }

            VAPopoverListVC.openPopoverListView(arrayOfData: array, viewController: self, sender: imgLanguageDropdown, fontName: self.fontName, textFontSize: self.textFontSize, isGenaAINewTheme: self.isGenAINewTheme) { (index, item) in
                self.selectedLanguageString = item
                self.languageSelected =  VAConfigurations.arrayOfLanguages[index].lang ?? ""
                self.languagelabel.text = self.selectedLanguageString.capitalized
                self.saveButton.backgroundColor = self.isGenAINewTheme ? VAColorUtility.green_NT : VAColorUtility.senderBubbleColor
            }
            
        }
    }
    

    // MARK: - Button Actions
    /// Handles the channel button tap action.
    @IBAction func channelBtnClicked(_ sender: UIButton) {
        self.presentListingPopover(forChannel: true, sender: sender)
    }

    /// Handles the language button tap action.
    @IBAction func languageBtnClicked(_ sender: UIButton) {
        self.presentListingPopover(forChannel: false, sender: sender)
    }

    /// Handles the back button tap action.
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    /// Handles the text-to-speech switch value change.
    @IBAction func valueChangedTextToSpeech(_ sender: Any) {
        if let value = sender as? UISwitch {
            self.isTextToSpeechEnable = value.isOn
        }
    }

    /// Handles the save button tap action.
    @IBAction func saveBtnClicked(_ sender: UIButton) {
        DispatchQueue.main.async {
            // Map of language strings to their corresponding configurations
            let languageMap: [String: LanguageConfiguration] = [
                "english": .english,
                "traditional chinese": .chineseTraditional,
                "simplified chinese": .chineseSimplified,
                "french": .french,
                "german": .german,
                "spanish": .spanish,
                "dutch": .dutch,
                "tagalog": .tagalog,
                "turkish": .turkish,
                "punjabi": .punjabi,
                "japanese": .japanese,
                "persian": .persian
            ]

            // Set the language configuration based on the selected language
            if let selectedLanguage = languageMap[self.selectedLanguageString.lowercased()] {
                VAConfigurations.language = selectedLanguage
            }

            // Check if the language has changed and notify if necessary
            if self.oldSelectedLanguage != self.selectedLanguageString {
                NotificationCenter.default.post(name: Notification.Name("LanguageChangedFromSettings"), object: nil)
                UserDefaultsManager.shared.setBotLanguage(VAConfigurations.language?.rawValue ?? "")
                self.setLocalization()
            }

            // Update text-to-speech configuration
            VAConfigurations.isTextToSpeechEnable = self.isTextToSpeechEnable

            // Navigate back to the previous screen
            self.navigationController?.popViewController(animated: true)
        }
    }

    /// Handles the cancel button tap action.
    @IBAction func cancelClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    /// Handles the send chat transcript button tap action.
    @IBAction func sendChatTranscriptBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        let sessionId = UserDefaultsManager.shared.getSessionID()
        if sessionId.isEmpty || sessionId == "0" {
            return
        }
        // Check if email is empty
        if self.transcriptEmailTF.text?.isEmpty ?? false {
            // Show alert for empty email
            UIAlertController.openAlertWithOk(LanguageManager.shared.localizedString(forKey: "Error"),
                                              LanguageManager.shared.localizedString(forKey: "Please Enter Email"),
                                              LanguageManager.shared.localizedString(forKey: "OK"),
                                              view: self,
                                              completion: nil)
        } else if isValidEmail(self.transcriptEmailTF.text!) {
            // Send transcript via API
            CustomLoader.show()
            APIManager.sharedInstance.postTranscript(
                botId: VAConfigurations.botId,
                email: transcriptEmailTF.text ?? "",
                language: VAConfigurations.language?.rawValue ?? "",
                sessionId: sessionId,
                user: VAConfigurations.userJid) { (resultStr) in
                    DispatchQueue.main.async {
                        CustomLoader.hide()
                        UIAlertController.openAlertWithOk(LanguageManager.shared.localizedString(forKey: "Email Sent"),
                                                          LanguageManager.shared.localizedString(forKey: "Email will be sent to you shortly"),
                                                          LanguageManager.shared.localizedString(forKey: "OK"),
                                                          view: self) {}
                    }
                }
        } else {
            // Show alert for invalid email
            UIAlertController.openAlertWithOk(LanguageManager.shared.localizedString(forKey: "Error"),
                                              LanguageManager.shared.localizedString(forKey: "Please enter valid email"),
                                              LanguageManager.shared.localizedString(forKey: "OK"),
                                              view: self,
                                              completion: nil)
        }
    }
}
