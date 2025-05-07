// FeedbackSurveyVC.swift
// Copyright © 2024 Telus Digital. All rights reserved.

/// This file manages the Feedback Survey screen, including UI setup, user interactions, and feedback submission.
import UIKit
import IQKeyboardManagerSwift

class FeedbackSurveyVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var imgHeaderLogo: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ratingsTitleLblHC: NSLayoutConstraint!
    @IBOutlet weak var ratingsTitleLbl: UILabel!

    // Rating buttons
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var fourButton: UIButton!
    @IBOutlet weak var fiveButton: UIButton!
    @IBOutlet weak var sixButton: UIButton!
    @IBOutlet weak var sevenButton: UIButton!
    @IBOutlet weak var eightButton: UIButton!
    @IBOutlet weak var nineButton: UIButton!
    @IBOutlet weak var tenButton: UIButton!

    // Stack views for ratings
    @IBOutlet weak var parentStack: UIStackView!
    @IBOutlet weak var oneToFiveSV: UIStackView!
    @IBOutlet weak var sixToNineSV: UIStackView!

    // Labels for additional feedback and issue resolution
    @IBOutlet weak var lblStaticAdditionalFeedback: UILabel!
    @IBOutlet weak var lblStaticResolveIssue: UILabel!

    // Collection view for answer tags
    @IBOutlet weak var answerTagsCollView: UICollectionView! {
        didSet {
            configureAnswerTagsCollectionView()
        }
    }
    @IBOutlet weak var answerTagsCollHightConst: NSLayoutConstraint!
    @IBOutlet weak var answersTagContainer: UIView!
    @IBOutlet weak var answersTagTitleLabel: UILabel!
    @IBOutlet weak var answersTagTitleLabelTC: NSLayoutConstraint!

    // Radio buttons for "Yes" and "No"
    @IBOutlet weak var radioButtonViewContainer: UIView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var radioButtonViewContainerHC: NSLayoutConstraint!

    // Feedback text view
    @IBOutlet weak var feedTextViewContainer: UIView!
    @IBOutlet weak var feedTextView: UITextView!
    @IBOutlet weak var feedTextViewContainerHC: NSLayoutConstraint!

    // Buttons for submitting or skipping feedback
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!

    // Rating views
    @IBOutlet weak var viewRatingA: UIStackView!
    @IBOutlet weak var viewRatingB: UIStackView!
    @IBOutlet weak var lblHighestRatingA: UILabel!
    @IBOutlet weak var lblLowestRatingA: UILabel!
    @IBOutlet weak var lblHighestRatingB: UILabel!
    @IBOutlet weak var lblLowestRatingB: UILabel!

    // Feedback character limit label
    @IBOutlet weak var lblFeedbackCharLimit: UILabel!

    // Header logo width constraint
    @IBOutlet weak var headerLogoWidth: NSLayoutConstraint!

    // Buttons stack view
    @IBOutlet weak var buttonsStack: UIStackView!
    @IBOutlet weak var buttonStackBottom: NSLayoutConstraint!

    // MARK: - Properties
    var ansArray = [String]()
    var selectedIndexPath = IndexPath(item: -1, section: -1)
    var selectedTagIndexPath = IndexPath(item: -1, section: -1)
    var npsSettings: VAConfigNPSSettings?
    var ratingScale = 0
    var ratingConfig: VAConfigNPSSettingsData?

    var isFeedbackTypeEmoji = false
    var isAdditionalFeedback = false
    var isAnswersTag = false
    var isRadioShow = true

    var selectedAnswerTagArr = [IndexPath]()
    var selectedAnswerTagValueArr = [String]()
    var score = 0
    var isIssueResolved: Bool?

    var ratingViewOrder: RatingOrder = .ascend
    var additionalFeedbackPlaceholder = ""
    var maxCharacterLimit: Int = 250
    var chatTranscriptEnabled: Bool = false
    var radioUnselectedImg = UIImage()
    var radioSelectedImg = UIImage()
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var configResulModel: VAConfigResultModel?
    var logoWidth: CGFloat = 0.0
    var isGenAINewTheme: Bool = false
    
    enum RatingOrder {
        case ascend
        case descend
    }

    // MARK: - UIViewController Life Cycle
override func viewDidLoad() {
    super.viewDidLoad()
    setupInitialUI()
    setLocalization()
    setUI()
}

override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    configureKeyboardManager(enable: true)
}

override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    configureKeyboardManager(enable: false)
}

// MARK: - Setup Functions

/// Sets up the initial UI state for the feedback survey screen.
private func setupInitialUI() {
    overrideUserInterfaceStyle = .light
    navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    hideRatingsView()
    hideAnswersTag()
    hideRadio()
    hideAdditionalFeedback()
}

/// Configures the keyboard manager for the screen.
private func configureKeyboardManager(enable: Bool) {
    IQKeyboardManager.shared.enable = enable
    IQKeyboardManager.shared.enableAutoToolbar = false
    IQKeyboardManager.shared.toolbarConfiguration.placeholderConfiguration.showPlaceholder = false
}

    // MARK: Localization
    /// Sets localized text for UI elements.
    func setLocalization() {
        let localizedTexts = [
            (yesButton, "YES"),
            (noButton, "NO"),
            (submitButton, "Submit"),
            (skipButton, chatTranscriptEnabled ? "Skip feedback" : "Close")
        ]

        localizedTexts.forEach { button, key in
            button?.setTitle(LanguageManager.shared.localizedString(forKey: key), for: .normal)
            button?.titleLabel?.minimumScaleFactor = 0.5
            button?.titleLabel?.adjustsFontSizeToFitWidth = true
        }

        answersTagTitleLabel.text = LanguageManager.shared.localizedString(forKey: "What went well?")
        lblStaticAdditionalFeedback.text = LanguageManager.shared.localizedString(forKey: "Additional Feedback")
        lblStaticResolveIssue.text = LanguageManager.shared.localizedString(forKey: "Did we resolve your issue?")
        additionalFeedbackPlaceholder = LanguageManager.shared.localizedString(forKey: "Feedback Comment")
    }

    // MARK: - SetUI
    /// Configures the UI elements for the feedback survey screen.
    func setUI() {
        configureFontsAndBackground()
        configureTextColors()
        configureButtonColors()
        configureSkipButtonTitle()
        configureRadioImages()
        filterRatingsInitialData()
        configureRatingScale()
        configureRatingType()
        configureButtonsStack()
        configureSubmitAndSkipButtons()
        setupHeaderImageAndTitle()
    }

    /// Configures fonts and background color for UI elements.
    private func configureFontsAndBackground() {
        self.view.backgroundColor = isGenAINewTheme ? .white : VAColorUtility.themeColor
        let normalFont = isGenAINewTheme ? GenAIFonts().normal() : UIFont(name: fontName, size: textFontSize)

        [yesButton, noButton, oneButton, twoButton, threeButton, fourButton, fiveButton,
         sixButton, sevenButton, eightButton, nineButton, tenButton].forEach {
            $0?.titleLabel?.font = normalFont
        }

        answersTagTitleLabel.font = isGenAINewTheme ? GenAIFonts().bold(fontSize: 15) : UIFont(name: fontName, size: textFontSize)
        lblStaticAdditionalFeedback.font = isGenAINewTheme ? GenAIFonts().bold(fontSize: 15) : UIFont(name: fontName, size: textFontSize)
        lblStaticResolveIssue.font = isGenAINewTheme ? GenAIFonts().bold(fontSize: 15) : UIFont(name: fontName, size: textFontSize)
        feedTextView.font = normalFont
        lblLowestRatingA.font = normalFont
        lblLowestRatingB.font = normalFont
        lblHighestRatingA.font = normalFont
        lblHighestRatingB.font = normalFont
        ratingsTitleLbl.font = isGenAINewTheme ? GenAIFonts().bold(fontSize: 16) : UIFont(name: fontName, size: textFontSize)
        lblFeedbackCharLimit.font = normalFont
        lblHeader.font = isGenAINewTheme ? GenAIFonts().normal(fontSize: 16) : UIFont(name: fontName, size: 16)
    }

    /// Configures text colors for UI elements.
    private func configureTextColors() {
        lblHeader.textColor = VAColorUtility.defaultButtonColor
        let textColor = isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.themeTextIconColor

        [lblStaticAdditionalFeedback, lblStaticResolveIssue, lblLowestRatingA, lblLowestRatingB,
         lblHighestRatingA, lblHighestRatingB, ratingsTitleLbl, lblFeedbackCharLimit].forEach {
            $0?.textColor = textColor
        }
    }

    /// Configures button colors for rating buttons.
    private func configureButtonColors() {
        let tintColor = isGenAINewTheme ? VAColorUtility.purple_NT : VAColorUtility.senderBubbleColor

        [oneButton, twoButton, threeButton, fourButton, fiveButton,
         sixButton, sevenButton, eightButton, nineButton, tenButton].forEach {
            $0?.tintColor = tintColor
        }
    }

    /// Configures the skip button title based on chat transcript settings.
    private func configureSkipButtonTitle() {
        let skipTitle = chatTranscriptEnabled ? "Skip feedback" : "Close"
        skipButton.setTitle(LanguageManager.shared.localizedString(forKey: skipTitle), for: .normal)
    }

    /// Configures the radio button images.
    private func configureRadioImages() {
        radioUnselectedImg = UIImage(named: "radio-unChecked", in: Bundle.module, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        radioSelectedImg = UIImage(named: "radio-checked", in: Bundle.module, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.yesButton.setTitleColor(self.isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.themeTextIconColor, for: .normal)
            self.noButton.setTitleColor(self.isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.themeTextIconColor, for: .normal)
            self.yesButton.tintColor = self.isGenAINewTheme ? VAColorUtility.purple_NT : VAColorUtility.senderBubbleColor
            self.noButton.tintColor = self.isGenAINewTheme ? VAColorUtility.purple_NT : VAColorUtility.senderBubbleColor
            self.yesButton.setImage(self.radioUnselectedImg, for: .normal)
            self.noButton.setImage(self.radioUnselectedImg, for: .normal)
        }
    }

    /// Configures the rating scale visibility.
    private func configureRatingScale() {
        if ratingConfig?.ratingScale == "1 to 10" {
            ratingScale = 10
            sixToNineSV.isHidden = false
        } else if ratingConfig?.ratingScale == "1 to 5" {
            ratingScale = 5
            sixToNineSV.isHidden = true
        } else {
            ratingScale = 0
        }
    }

    /// Configures the rating type (numeric or emoji).
    private func configureRatingType() {
        if let ratingType = ratingConfig?.ratingType, ratingType == "numeric" {
            updateMinMaxRating()
        } else {
            viewRatingA.isHidden = true
            viewRatingB.isHidden = true
        }
    }

    /// Configures the buttons stack layout based on the theme.
    private func configureButtonsStack() {
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

    /// Configures the appearance of the submit and skip buttons.
    private func configureSubmitAndSkipButtons() {
        submitButton.layer.cornerRadius = isGenAINewTheme ? 22 : 8.0
        submitButton.setTitleColor(isGenAINewTheme ? VAColorUtility.white : VAColorUtility.senderBubbleColor, for: .normal)
        submitButton.isUserInteractionEnabled = false
        submitButton.backgroundColor = isGenAINewTheme ? VAColorUtility.borderColor_NT : UIColor.clear
        submitButton.titleLabel?.font = isGenAINewTheme ? GenAIFonts().bold(fontSize: 16) : UIFont(name: fontName, size: textFontSize)

        if isGenAINewTheme {
            skipButton.layer.cornerRadius = 22.0
            skipButton.layer.borderWidth = 1.0
            skipButton.layer.borderColor = VAColorUtility.green_NT.cgColor
        } else {
            submitButton.layer.borderWidth = 1
            submitButton.layer.borderColor = VAColorUtility.senderBubbleColor.cgColor
        }

        skipButton.titleLabel?.font = isGenAINewTheme ? GenAIFonts().bold(fontSize: 16) : UIFont(name: fontName, size: textFontSize)
        skipButton.backgroundColor = .white
        skipButton.setTitleColor(isGenAINewTheme ? VAColorUtility.green_NT : VAColorUtility.senderBubbleColor, for: .normal)
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

/// Filters and initializes the rating configuration data.
func filterRatingsInitialData() {
    guard let npsData = npsSettings?.data, !npsData.isEmpty else {
        showDefaultRatingsView()
        return
    }

    ratingConfig = findRatingConfig(for: npsData) ?? findFallbackRatingConfig(in: npsData)
    ratingViewOrder = determineRatingOrder(from: ratingConfig?.ratingViewOrder)
    showRatingsView(title: determineRatingsTitle(from: ratingConfig?.message))
}

/// Finds the rating configuration for the current language.
/// - Parameter npsData: The array of NPS settings data.
/// - Returns: The matching rating configuration, if found.
private func findRatingConfig(for npsData: [VAConfigNPSSettingsData]) -> VAConfigNPSSettingsData? {
    return npsData.first { $0.lang == VAConfigurations.language?.rawValue }
}

/// Finds a fallback rating configuration if no language-specific configuration is found.
/// - Parameter npsData: The array of NPS settings data.
/// - Returns: A fallback rating configuration, if available.
private func findFallbackRatingConfig(in npsData: [VAConfigNPSSettingsData]) -> VAConfigNPSSettingsData? {
    return npsData.first { $0.ratingWiseQuestions?.isEmpty == false }
}

/// Determines the rating order based on the configuration.
/// - Parameter order: The rating view order string.
/// - Returns: The corresponding `RatingOrder` value.
private func determineRatingOrder(from order: String?) -> RatingOrder {
    return order == "desc" ? .descend : .ascend
}

/// Determines the title for the ratings view.
/// - Parameter message: The message from the rating configuration.
/// - Returns: The title to display.
private func determineRatingsTitle(from message: String?) -> String {
    if let title = message, !title.isEmpty {
        return title.htmlToString
    }
    return LanguageManager.shared.localizedString(forKey: "Regarding the TELUS Virtual Assistant that just helped you, how would you rate its performance?")
}

/// Displays the default ratings view with a generic title.
private func showDefaultRatingsView() {
    let defaultTitle = LanguageManager.shared.localizedString(forKey: "Regarding the TELUS Virtual Assistant that just helped you, how would you rate its performance?")
    showRatingsView(title: defaultTitle)
}

    // MARK: - Update Minimum and Maximum Rating lable
    /// Updates the minimum and maximum rating labels based on the rating configuration and order.
    func updateMinMaxRating() {
        let labels = generateMinMaxLabels(scale: ratingConfig?.ratingScale, order: ratingViewOrder)
        assignMinMaxLabels(labels)
    }

    /// Generates the minimum and maximum labels based on the rating scale and order.
    /// - Parameters:
    ///   - scale: The rating scale.
    ///   - order: The rating order.
    /// - Returns: A tuple containing the minimum and maximum labels.
    private func generateMinMaxLabels(scale: String?, order: RatingOrder) -> (min: String, max: String) {
        let minLabel = ratingConfig?.minLabel ?? ""
        let maxLabel = ratingConfig?.maxLabel ?? ""

        switch order {
        case .descend:
            return scale == "1 to 5" ? (maxLabel, minLabel) : (maxLabel, minLabel)
        case .ascend:
            return scale == "1 to 5" ? (minLabel, maxLabel) : (minLabel, maxLabel)
        }
    }

    /// Assigns the minimum and maximum labels to the appropriate UI elements.
    /// - Parameter labels: A tuple containing the minimum and maximum labels.
    private func assignMinMaxLabels(_ labels: (min: String, max: String)) {
        let scale = ratingConfig?.ratingScale ?? ""

        if scale == "1 to 5" {
            lblLowestRatingA.text = labels.min
            lblHighestRatingA.text = labels.max
            viewRatingA.isHidden = false
            viewRatingB.isHidden = true
        } else if scale == "1 to 10" {
            lblLowestRatingA.text = labels.min
            lblHighestRatingA.text = ""
            lblLowestRatingB.text = ""
            lblHighestRatingB.text = labels.max
            viewRatingA.isHidden = false
            viewRatingB.isHidden = false
        }
    }

    // MARK: - Show Rating View
    func showRatingsView(title: String) {
        self.ratingsTitleLbl.text = title
        self.ratingsTitleLbl.isHidden = false
        self.ratingsTitleLblHC.constant = 30
        self.ratingConfig?.ratingType == "emoji" ? self.setRatingViewAsEmoji():self.setRatingViewAsNumber()
    }
    // end

    // MARK: - Hide Rating View
    func hideRatingsView() {
        self.ratingsTitleLbl.isHidden = true
        self.ratingsTitleLblHC.constant = 0
    }
    // end

    // MARK: - Set Rating View for Emoji
    /// Configures the rating view for emoji rating type.
    func setRatingViewAsEmoji() {
        let emojiImages = generateEmojiImages(scale: ratingConfig?.ratingScale, order: ratingViewOrder)
        assignEmojiImagesToButtons(emojiImages)
    }

    /// Generates emoji image names based on the rating scale and order.
    /// - Parameters:
    ///   - scale: The rating scale.
    ///   - order: The rating order.
    /// - Returns: An array of emoji image names.
    private func generateEmojiImages(scale: String?, order: RatingOrder) -> [String] {
        switch order {
        case .descend:
            if scale == "1 to 5" {
                return ["emoji9", "emoji7", "emoji6", "emoji4", "emoji2"]
            } else {
                return ["emoji10", "emoji9", "emoji8", "emoji7", "emoji6", "emoji5", "emoji4", "emoji3", "emoji2", "emoji1"]
            }
        case .ascend:
            if scale == "1 to 5" {
                return ["emoji2", "emoji4", "emoji6", "emoji7", "emoji9"]
            } else {
                return ["emoji1", "emoji2", "emoji3", "emoji4", "emoji5", "emoji6", "emoji7", "emoji8", "emoji9", "emoji10"]
            }
        }
    }

    /// Assigns emoji images to rating buttons.
    /// - Parameter emojiImages: An array of emoji image names.
    private func assignEmojiImagesToButtons(_ emojiImages: [String]) {
        let buttons = [oneButton, twoButton, threeButton, fourButton, fiveButton,
                       sixButton, sevenButton, eightButton, nineButton, tenButton]
        let bundle = Bundle.module

        for (index, imageName) in emojiImages.enumerated() {
            buttons[index]?.setImage(
                UIImage(named: imageName, in: bundle, with: nil)?.withRenderingMode(.alwaysTemplate),
                for: .normal
            )
        }
    }

    // MARK: - Set Rating View for Numeric rating type
    /// Configures the rating view for numeric rating type.
    func setRatingViewAsNumber() {
        configureNumericButtonsAppearance()

        let titles = generateNumericButtonTitles(scale: ratingConfig?.ratingScale, order: ratingViewOrder)
        assignTitlesToButtons(titles)
    }

    /// Configures the appearance of numeric rating buttons.
    private func configureNumericButtonsAppearance() {
        let backgroundColor = isGenAINewTheme ? VAColorUtility.lightPurple_NT : VAColorUtility.receiverBubbleColor
        let titleColor = isGenAINewTheme ? VAColorUtility.purple_NT : VAColorUtility.senderBubbleColor

        [oneButton, twoButton, threeButton, fourButton, fiveButton,
         sixButton, sevenButton, eightButton, nineButton, tenButton].forEach { button in
            button?.roundedShadowView(cornerRadius: 5, borderWidth: 0, borderColor: .clear)
            button?.backgroundColor = backgroundColor
            button?.setTitleColor(titleColor, for: .normal)
        }
    }

    /// Generates titles for numeric rating buttons based on the scale and order.
    /// - Parameters:
    ///   - scale: The rating scale.
    ///   - order: The rating order.
    /// - Returns: An array of titles for the buttons.
    private func generateNumericButtonTitles(scale: String?, order: RatingOrder) -> [String] {
        switch order {
        case .descend:
            if scale == "1 to 5" {
                return ["5", "4", "3", "2", "1"]
            } else {
                return ["10", "9", "8", "7", "6", "5", "4", "3", "2", "1"]
            }
        case .ascend:
            if scale == "1 to 5" {
                return ["1", "2", "3", "4", "5"]
            } else {
                return ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
            }
        }
    }

    /// Assigns titles to numeric rating buttons.
    /// - Parameter titles: An array of titles for the buttons.
    private func assignTitlesToButtons(_ titles: [String]) {
        let buttons = [oneButton, twoButton, threeButton, fourButton, fiveButton,
                       sixButton, sevenButton, eightButton, nineButton, tenButton]

        for (index, title) in titles.enumerated() {
            buttons[index]?.setTitle(LanguageManager.shared.localizedString(forKey: title), for: .normal)
        }
    }

    // end

    // MARK: - Hide Answer Tag
    func hideAnswersTag() {
        self.answersTagTitleLabelTC.constant = 0
        self.answerTagsCollHightConst.constant = 0
        self.answersTagTitleLabel.text = ""
        self.answersTagTitleLabel.isHidden = true
        self.answerTagsCollView.isHidden = true
        self.answersTagContainer.isHidden = true
    }
    // end

    // MARK: - Show Answer Tag
    func showAnswersTag() {
        self.answerTagsCollHightConst.constant = 30
        self.answerTagsCollView.isHidden = false
        answersTagContainer.isHidden = false
        answersTagTitleLabel.isHidden = false
        answersTagTitleLabelTC.constant = 20
        self.answerTagsCollView.reloadData()
    }
    // end

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

    // MARK: - Hide Additional Feedback view
    func hideAdditionalFeedback() {
        feedTextViewContainer.isHidden = true
        feedTextViewContainerHC.constant = 0
    }
    // end

    // MARK: - Show Additional Feedback view
    func showAdditionalFeedback() {
        self.feedTextView.roundedShadowView(cornerRadius: isGenAINewTheme ? 6 : 10, borderWidth: 1, borderColor: isGenAINewTheme ? VAColorUtility.borderColor_NT : VAColorUtility.themeTextIconColor)
        self.feedTextView.text = self.additionalFeedbackPlaceholder
        self.feedTextView.textColor = UIColor.lightGray
        // Text Content Inset from border
        self.feedTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        feedTextViewContainer.isHidden = false
        // Height fixed 160
        feedTextViewContainerHC.constant = 160
    }
    // end

    // MARK: - Did Load Answer Taqg
    /// Loads the answer tags for the selected rating value.
    /// - Parameter tag: The selected rating value.
    func didLoadAnswerTags(tag: Int) {
        guard let ratingConfig = self.ratingConfig else { return }

        let index = calculateIndex(for: tag, scale: ratingConfig.ratingScale, order: ratingViewOrder)

        if let questionArray = ratingConfig.ratingWiseQuestions, questionArray.count > index {
            let question = questionArray[index]
            if let answerTags = question.answerTags, !answerTags.isEmpty {
                isAnswersTag = true
                ansArray = answerTags
                answersTagTitleLabel.text = question.question
                answersTagTitleLabel.textColor = isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.themeTextIconColor
                showAnswersTag()
            } else {
                hideAnswersTag()
            }
        } else {
            hideAnswersTag()
        }
    }

    /// Calculates the index for the selected tag based on the rating scale and order.
    /// - Parameters:
    ///   - tag: The selected tag.
    ///   - scale: The rating scale.
    ///   - order: The rating order.
    /// - Returns: The calculated index.
    private func calculateIndex(for tag: Int, scale: String?, order: RatingOrder) -> Int {
        switch order {
        case .descend:
            if scale == "1 to 5" {
                return 4 - tag
            } else {
                return 9 - tag
            }
        case .ascend:
            return tag
        }
    }
    
 // MARK: - Close Chatbot
/// Closes the chatbot by resetting user defaults, notifying the delegate, and cleaning up view controllers.
private func closeChatbot() {
    // Reset all user defaults
    UserDefaultsManager.shared.resetAllUserDefaults()
    // Notify the delegate that the chatbot is being closed
    VAConfigurations.virtualAssistant?.delegate?.didTapCloseChatbot()
    CustomLoader.hide()

    // Check if the current view controller has a parent
    if self.parent?.parent == nil {
        self.dismiss(animated: false, completion: nil)
    } else {
        // If there are child view controllers, remove them
        guard let parentController = self.parent else { return }
        for childController in parentController.children {
            childController.willMove(toParent: nil)
            childController.view.removeFromSuperview()
            childController.removeFromParent()
        }
    }
}

// MARK: - Move to Chat Transcript Screen
/// Navigates to the chat transcript screen (`VAChatTranscriptVC`) with the necessary configurations.
func moveToChatTranscriptScreen() {
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.module)
    if let chatTranscriptVC = storyboard.instantiateViewController(withIdentifier: "VAChatTranscriptVC") as? VAChatTranscriptVC {
        // Pass necessary configurations to the new view controller
        chatTranscriptVC.textFontSize = self.textFontSize
        chatTranscriptVC.fontName = self.fontName
        chatTranscriptVC.configResulModel = self.configResulModel
        chatTranscriptVC.logoWidth = self.logoWidth
        chatTranscriptVC.isGenAINewTheme = self.isGenAINewTheme

        self.navigationController?.pushViewController(chatTranscriptVC, animated: false)
    }
}

    // MARK: - IBActions

    /// This function is used when user tap rating button
    @IBAction func emojiBtnAction(_ sender: UIButton) {
        // Enable and style the submit button
        configureSubmitButton(isEnabled: true)

        // Reset feedback text view if necessary
        if feedTextView.text == additionalFeedbackPlaceholder || feedTextView.text.isEmpty {
            feedTextView.text = ""
            feedTextView.endEditing(true)
            npsSettings?.additionalFeedback == true ? showAdditionalFeedback() : hideAdditionalFeedback()
        }

        // Show or hide radio buttons based on issue resolution setting
        npsSettings?.issueResolved == true ? showRadio() : hideRadio()

        // Configure rating view based on rating type
        ratingConfig?.ratingType == "emoji" ? setRatingViewAsEmoji() : setRatingViewAsNumber()

        // Update button appearance
        configureRatingButton(sender, isEmoji: ratingConfig?.ratingType == "emoji")

        // Load answer tags
        didLoadAnswerTags(tag: sender.tag)

        // Reset selected answer tags
        selectedAnswerTagArr.removeAll()
        selectedAnswerTagValueArr.removeAll()

        // Update button images and calculate score
        updateButtonImagesAndScore(for: sender)
    }

    /// Configures the submit button's state and appearance.
    /// - Parameter isEnabled: Whether the button should be enabled.
    private func configureSubmitButton(isEnabled: Bool) {
        submitButton.isUserInteractionEnabled = isEnabled
        submitButton.backgroundColor = isEnabled ? (isGenAINewTheme ? VAColorUtility.green_NT : VAColorUtility.senderBubbleColor) : .clear
        submitButton.setTitleColor(isEnabled ? VAColorUtility.white : .clear, for: .normal)
    }

    /// Configures the appearance of a rating button.
    /// - Parameters:
    ///   - button: The button to configure.
    ///   - isEmoji: Whether the rating type is emoji.
    private func configureRatingButton(_ button: UIButton, isEmoji: Bool) {
        button.backgroundColor = isEmoji ? .clear : (isGenAINewTheme ? VAColorUtility.purple_NT : VAColorUtility.senderBubbleColor)
        button.setTitleColor(isEmoji ? .clear : (isGenAINewTheme ? VAColorUtility.white : VAColorUtility.receiverBubbleColor), for: .normal)
    }

    /// Updates the button images and calculates the score based on the selected button.
    /// - Parameter sender: The selected button.
    private func updateButtonImagesAndScore(for sender: UIButton) {
        let isEmoji = ratingConfig?.ratingType == "emoji"
        let scale = ratingConfig?.ratingScale ?? ""
        let order = ratingViewOrder

        if isEmoji {
            updateEmojiButtonImages(for: sender, scale: scale, order: order)
        }
        score = calculateScore(for: sender.tag, scale: scale, order: order)
    }

    /// Updates the images of emoji buttons based on the selected button.
    /// - Parameters:
    ///   - sender: The selected button.
    ///   - scale: The rating scale.
    ///   - order: The rating order.
    private func updateEmojiButtonImages(for sender: UIButton, scale: String, order: RatingOrder) {
        let imagePrefix = "emoji"
        let filledSuffix = "-filled"
        let bundle = Bundle.module

        let tagToImageIndex: (Int) -> Int? = { tag in
            switch order {
            case .descend:
                return scale == "1 to 5" ? (9 - tag * 2) : (10 - tag)
            case .ascend:
                return scale == "1 to 5" ? (2 + tag * 2) : (1 + tag)
            }
        }

        if let imageIndex = tagToImageIndex(sender.tag) {
            let imageName = "\(imagePrefix)\(imageIndex)\(filledSuffix)"
            sender.setImage(UIImage(named: imageName, in: bundle, with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }

    /// Calculates the score based on the selected button's tag.
    /// - Parameters:
    ///   - tag: The tag of the selected button.
    ///   - scale: The rating scale.
    ///   - order: The rating order.
    /// - Returns: The calculated score.
    private func calculateScore(for tag: Int, scale: String, order: RatingOrder) -> Int {
        switch order {
        case .descend:
            return scale == "1 to 5" ? (5 - tag) * 2 : 10 - tag
        case .ascend:
            return scale == "1 to 5" ? (1 + tag) * 2 : 1 + tag
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

    /// This function is used when user tap submit button
    @IBAction func submitBtnAction(_ sender: Any) {
        let strIssueResolved = isIssueResolved.map { $0 ? "true" : "false" } ?? ""
        let feedbackMsg = (feedTextView.text == additionalFeedbackPlaceholder) ? "" : (feedTextView.text ?? "")

        APIManager.sharedInstance.submitNPSSurveyFeedback(
            reason: selectedAnswerTagValueArr,
            score: score,
            feedback: feedbackMsg,
            issueResolved: strIssueResolved
        ) { [weak self] resultStr in
            DispatchQueue.main.async {
                guard let self = self else { return }
                IQKeyboardManager.shared.enable = false
                UIAlertController.openAlertWithOk(
                    LanguageManager.shared.localizedString(forKey: "Message!"),
                    resultStr,
                    LanguageManager.shared.localizedString(forKey: "OK"),
                    view: self
                ) {
                    self.chatTranscriptEnabled ? self.moveToChatTranscriptScreen() : self.closeChatbot()
                }
            }
        }
    }

    /// This function is used when user tap close button
    @IBAction func closeBtnAction(_ sender: Any) {
        // Disable IQKeyboardManager
        IQKeyboardManager.shared.enable = false
        // if chatTranscript is enabled than open VAChatTranscriptVC controller else send notification on previous UIViewController
        if self.chatTranscriptEnabled == true {
            self.moveToChatTranscriptScreen()
        } else {
            self.closeChatbot()
        }
    }

    // MARK: - Helper Functions

    /// Configures the answer tags collection view.
    private func configureAnswerTagsCollectionView() {
        answerTagsCollView.delegate = self
        answerTagsCollView.dataSource = self
        answerTagsCollView.register(
            UINib(nibName: "AnsTagsCollectionViewCell", bundle: Bundle.module),
            forCellWithReuseIdentifier: "AnsTagsCollectionViewCell"
        )
        if let flowLayout = answerTagsCollView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
    }
}
// end

// MARK: - FeedbackSurveyVC extension of UICollectionView
/// UICollectionView used for Answer Tags
extension FeedbackSurveyVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    /// Returns the number of sections in the collection view.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    /// Returns the number of items in the section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.ansArray.count
    }

    /// Configures and returns the cell for the given index path.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnsTagsCollectionViewCell", for: indexPath) as? AnsTagsCollectionViewCell else {
            return UICollectionViewCell()
        }

        // Configure the cell appearance
        configureCell(cell, at: indexPath)

        return cell
    }

    /// Returns the insets for the section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    /// Returns the minimum spacing between items in the same row.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    /// Returns the minimum spacing between rows.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    /// Handles the selection of an item in the collection view.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedItem = collectionView.cellForItem(at: indexPath) as? AnsTagsCollectionViewCell else { return }

        // Update the selected tags and reload the collection view
        updateSelectedTags(for: indexPath, with: selectedItem.name.text)
        self.answerTagsCollView.reloadData()
    }

    // MARK: - Helper Functions

    /// Configures the appearance of a cell at the given index path.
    /// - Parameters:
    ///   - cell: The cell to configure.
    ///   - indexPath: The index path of the cell.
    private func configureCell(_ cell: AnsTagsCollectionViewCell, at indexPath: IndexPath) {
        let isSelected = self.selectedAnswerTagArr.contains(indexPath)

        // Update the cell's background color and text color based on selection
        cell.container.backgroundColor = isSelected
            ? (isGenAINewTheme ? VAColorUtility.green_NT : VAColorUtility.senderBubbleColor)
            : .clear

        cell.name.textColor = isSelected
            ? (isGenAINewTheme ? .white : VAColorUtility.receiverBubbleColor)
            : (isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.themeTextIconColor)

        // Set the cell's text and font
        cell.name.text = "\(ansArray[indexPath.item])"
        cell.name.font = isGenAINewTheme ? GenAIFonts().normal() : UIFont(name: fontName, size: 14)

        // Configure the cell's border
        cell.container.borderColor = isGenAINewTheme ? VAColorUtility.borderColor_NT : VAColorUtility.receiverBubbleColor
        cell.container.layer.borderWidth = 1
    }

    /// Updates the selected tags when an item is selected or deselected.
    /// - Parameters:
    ///   - indexPath: The index path of the selected item.
    ///   - tagName: The name of the selected tag.
    private func updateSelectedTags(for indexPath: IndexPath, with tagName: String?) {
        self.selectedTagIndexPath = indexPath

        if let tagName = tagName {
            if selectedAnswerTagArr.contains(indexPath) {
                // Remove the tag if it is already selected
                selectedAnswerTagArr.removeAll { $0 == indexPath }
                selectedAnswerTagValueArr.removeAll { $0 == tagName }
            } else {
                // Add the tag if it is not already selected
                selectedAnswerTagArr.append(indexPath)
                selectedAnswerTagValueArr.append(tagName)
            }
        }
    }
}

// MARK: - FeedbackSurveyVC extension of UITextViewDelegate
extension FeedbackSurveyVC: UITextViewDelegate {

    /// Handles text changes in the feedback text view and updates the character limit label.
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        if newText.count <= self.maxCharacterLimit {
            self.lblFeedbackCharLimit.text = "\(newText.count)/\(self.maxCharacterLimit)"
        }
        return newText.count <= self.maxCharacterLimit
    }

    /// Prepares the feedback text view for editing by clearing the placeholder text.
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == self.additionalFeedbackPlaceholder {
            clearPlaceholder(for: textView)
        }
        return true
    }

    /// Restores the placeholder text if the feedback text view is empty after editing.
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            setPlaceholder(for: textView)
        }
    }

    // MARK: - Helper Functions

    /// Clears the placeholder text and sets the appropriate text color for editing.
    /// - Parameter textView: The `UITextView` being edited.
    private func clearPlaceholder(for textView: UITextView) {
        textView.text = ""
        textView.textColor = isGenAINewTheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.themeTextIconColor
    }

    /// Sets the placeholder text and color for the feedback text view.
    /// - Parameter textView: The `UITextView` to update.
    private func setPlaceholder(for textView: UITextView) {
        textView.text = self.additionalFeedbackPlaceholder
        textView.textColor = UIColor.lightGray
    }
}
