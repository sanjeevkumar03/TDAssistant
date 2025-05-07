// VAChatViewController.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit
import XMPPFramework
import IQKeyboardManagerSwift
import AVFoundation
import Speech
import AVKit
import ProgressHUD
import MapKit

class VAChatViewController: UIViewController {
    
    // MARK: - Outlet declaration
    @IBOutlet weak var chatTableView: UITableView! {
        didSet {
            self.chatTableView.delegate = self
            self.chatTableView.dataSource = self
            self.chatTableView.showsVerticalScrollIndicator = false
            self.chatTableView.showsHorizontalScrollIndicator = false
            self.chatTableView.backgroundColor = .clear
            self.chatTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        }
    }
    @IBOutlet weak var suggestionTableView: UITableView! {
        didSet {
            self.suggestionTableView.delegate = self
            self.suggestionTableView.dataSource = self
            self.suggestionTableView.showsVerticalScrollIndicator = false
            self.suggestionTableView.showsHorizontalScrollIndicator = false
            self.suggestionTableView.backgroundColor = .clear
            self.suggestionTableView.rowHeight = UITableView.automaticDimension
            self.suggestionTableView.estimatedRowHeight = 38
        }
    }
    @IBOutlet weak var suggestionTableSeparator: UIView!
    @IBOutlet weak var suggestionsViewLeading: NSLayoutConstraint!
    @IBOutlet weak var suggestionsViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var hConstViewSuggestion: NSLayoutConstraint!
    @IBOutlet weak var suggestionTitleLabel: UILabel!
    @IBOutlet weak var suggestionTitleLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var viewOptions: UIView!
    @IBOutlet weak var wConstViewRefresh: NSLayoutConstraint!
    @IBOutlet weak var msgInputStackBottom: NSLayoutConstraint!
    @IBOutlet weak var bConstViewTextInput: NSLayoutConstraint!
    @IBOutlet weak var viewTextInputBG: UIView!
    @IBOutlet weak var viewRefreshLeading: NSLayoutConstraint!
    @IBOutlet weak var viewRefresh: UIView!
    @IBOutlet weak var imgRefresh: UIImageView!
    @IBOutlet weak var viewCross: UIView!
    @IBOutlet weak var viewCrossInside: UIView!
    @IBOutlet weak var imgCross: UIImageView!
    @IBOutlet weak var viewSuggestions: UIView!
    @IBOutlet weak var textInputStack: UIStackView!
    @IBOutlet weak var textInputStackLeading: NSLayoutConstraint!
    @IBOutlet weak var textInputStackTrailing: NSLayoutConstraint!
    @IBOutlet weak var viewTextInput: UIView!
    @IBOutlet weak var imgHeaderLogo: UIImageView!
    @IBOutlet weak var viewHeaderSeperator: UIView!
    @IBOutlet weak var viewTextInputSeperator: UIView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var imgOptions: UIImageView!
    @IBOutlet weak var btnOptions: UIButton!
    @IBOutlet weak var imgClose: UIImageView!
    @IBOutlet weak var imgMinimize: UIImageView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var imgSend: UIImageView!
    @IBOutlet weak var imgSendHeight: NSLayoutConstraint!
    @IBOutlet weak var imgSendCenterX: NSLayoutConstraint!
    @IBOutlet weak var sendMsgBgView: UIView!
    @IBOutlet weak var btnSendMessage: UIButton!
    @IBOutlet weak var sendMsgViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var viewLiveAgent: UIView!
    @IBOutlet weak var imgLiveAgent: UIView!
    @IBOutlet weak var wConstraintLiveAgent: NSLayoutConstraint!
    @IBOutlet weak var wConstraintViewOptions: NSLayoutConstraint!
    @IBOutlet weak var viewSecureMsgWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtViewMessage: UITextView! {
        didSet {
            self.txtViewMessage.delegate = self
            self.txtViewMessage.textContainerInset = UIEdgeInsets(top: 11, left: 0, bottom: 10, right: 0)
            self.txtViewMessage.textContainer.lineFragmentPadding = 0
            self.txtViewMessage.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var msgTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var msgTextViewLeading: NSLayoutConstraint!
    @IBOutlet weak var btnShowSecureMessage: UIButton!
    @IBOutlet weak var viewSecureMessage: UIView!
    @IBOutlet weak var imgSecureMessage: UIImageView!
    @IBOutlet weak var viewBGQueue: UIView!
    @IBOutlet weak var viewQueue: UIView!
    @IBOutlet weak var lblQueueMessage: UILabel!
    @IBOutlet weak var imgViewTyping: UIImageView!
    
    @IBOutlet weak var viewShowReplyMessage: UIView!
    @IBOutlet weak var btnCancelReply: UIButton!
    @IBOutlet weak var lblReplyMessage: UILabel!
    @IBOutlet weak var btnReplyMessage: UIButton!
    
    @IBOutlet weak var maximizeView: UIView!
    @IBOutlet weak var maximizeImageContainer: UIView!
    @IBOutlet weak var maximizeImage: UIImageView!
    @IBOutlet weak var unreadMsgsView: UIView!
    @IBOutlet weak var unreadMsgCountLabel: UILabel!
    /// Speech to text
    @IBOutlet weak var speechToTextView: UIView!
    @IBOutlet weak var microphoneImage: UIImageView!
    @IBOutlet weak var speechToTextButton: UIButton!
    /// Upload View
    @IBOutlet weak var uploadView: UIView!
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var uploadViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var uploadButton: UIButton!
    /// Digital Signature View
    @IBOutlet weak var signatureView: SwiftSignatureView!
    @IBOutlet weak var signatureCloseImageView: UIImageView!
    @IBOutlet weak var signatureBackgroundView: UIView!
    @IBOutlet weak var signatureContainerView: UIView!
    @IBOutlet weak var signatureTitleLabel: UILabel!
    @IBOutlet weak var clearSignatureButton: UIButton!
    @IBOutlet weak var sendSignatureButton: UIButton!
    /// QR Code Scanner View
    @IBOutlet weak var qrCodeContainerTitle: UILabel!
    @IBOutlet weak var qrScannerView: QRScannerView!
    @IBOutlet weak var qrScannerCloseImageView: UIImageView!
    @IBOutlet weak var qrScannerBackgroundView: UIView!
    @IBOutlet weak var qrScannerContainerView: UIView!
    @IBOutlet weak var rescanQRCodeButtonContainer: UIView!
    @IBOutlet weak var rescanQRCodeButton: UIButton!
    @IBOutlet weak var scannedCodeDescContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var scannedCodeDescContainerView: UIView!
    @IBOutlet weak var scannedCodeTitleLabel: UILabel!
    @IBOutlet weak var scannedCodeLabel: UILabel!
    @IBOutlet weak var uploadedQRCodeImageContainer: UIView!
    @IBOutlet weak var uploadedQRCodeImageView: UIImageView!
    @IBOutlet weak var uploadedFromGalleryButtonContainer: UIView!
    @IBOutlet weak var uploadedQRCodeFromGalleryButton: UIButton!
    @IBOutlet weak var sendQRCodeButtonContainer: UIView!
    @IBOutlet weak var sendQRCodeButton: UIButton!
    /// Location
    @IBOutlet weak var locationContainerTitle: UILabel!
    @IBOutlet weak var locationCloseImageView: UIImageView!
    @IBOutlet weak var locationBackgroundView: UIView!
    @IBOutlet weak var locationContainerView: UIView!
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var sendLocationButtonContainer: UIView!
    @IBOutlet weak var sendLocationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    /// Prechat form builder
    @IBOutlet weak var prechatFormCloseImageView: UIImageView!
    @IBOutlet weak var prechatFormTitle: UILabel!
    @IBOutlet weak var prechatFormContainer: UIView!
    @IBOutlet weak var prechatFormBackgroundView: UIView!
    @IBOutlet weak var closePrechatFormView: UIView!
    @IBOutlet weak var prechatFormBackgroundViewLeading: NSLayoutConstraint!
    @IBOutlet weak var prechatFormBackgroundViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var prechatFormBackgroundViewTop: NSLayoutConstraint!
    @IBOutlet weak var prechatFormBackgroundViewBottom: NSLayoutConstraint!
    @IBOutlet var prechatFormTableHeight: NSLayoutConstraint!
    @IBOutlet weak var clearFormButton: UIButton!
    @IBOutlet weak var submitFormButton: UIButton!
    @IBOutlet weak var preChatFormTable: UITableView!
    
    // MARK: Property declaration
    var xmppController: XMPPController!
    var alrController: UIAlertController?
    var circularProgress: ProgressBarView?
    var searchedText: String = ""
    var viewModel: VAChatViewModel = VAChatViewModel()
    var isChangeAgentStatus: Bool = true
    var isSessionDisconnected: Bool = false
    var isHistoryMessage: Bool = false
    var historyMsgFeedback: Bool?
    var historyMessagesReloadTimer: Timer?
    var audioPlayer: AVAudioPlayer?
    var newMessagesCount: Int = 0
    var fontName: String = ""
    var autoSuggestionFontSize: Double = 0.0
    var dateTimeFontSize: Double = 0.0
    var textFontSize: Double = 0.0
    var defaultFontSize: Double = 16.0
    var maximumFontSize: Double = 18.0
    var minimumFontSize: Double = 10.0
    var msgComposingStateCounter = 0
    var msgComposingStateDelayTimer: Timer?
    /// Speech to text
    let audioEngine = AVAudioEngine()
    // let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    let audioSession = AVAudioSession.sharedInstance()/// Create instance of audio session to record voice
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var isListeningToSpeech: Bool = false
    var speechDelayTimer: Timer?
    var translatedText: String = ""
    var languagesArray: [String] = []
    var allowUserActivity: Bool = false
    
    /// Text to speech
    let speechSynthesizer = AVSpeechSynthesizer()
    /// Digital Signature
    var hasSignatureAdded: Bool = false
    /// QR Code
    var qrCodeValue: String = ""
    var qrCodeImage: UIImage?
    
    lazy var locationManager: CLLocationManager = {
        var locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10.0  // Movement threshold for new events
        return locationManager
    }()
    var userLocation: CLLocation?
    /// Pre chat form
    var hasErrorsInPrechatFormDuringSubmit: Bool = false
    
    var genAISendMsgDelayCounter = 0
    var getAISendMsgDelayTimer: Timer?
    var isOldSessionNotClaimed: Bool? = nil
    var isShowingCustomFormInFlow: Bool = false
    var isNewGenAITheme: Bool = false
    var msgTextViewMinHeight: CGFloat = 40
    var isGenAiTextFeedbackHistory: Bool = false
    //let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle(for: VAChatViewController.self))
    let storyboardObj = UIStoryboard(name: "Main", bundle: Bundle.module)
    let bundleObj = Bundle.module
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        /// enable light theme 
        overrideUserInterfaceStyle = .light
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.setupView()
        self.lblHeader.text = ""
        self.txtViewMessage.text = ""
        self.lblHeader.textAlignment = .center
        self.viewNavigation.isHidden = true
        CustomLoader.show()
        /// call configuration api
        DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
            self.viewModel.callGetConfigurationApi()
        }
        let imageData = try? Data(contentsOf: bundleObj.url(forResource: "typing", withExtension: "gif")!)
        self.imgViewTyping.image = UIImage.gif(data: imageData!)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.closeBtnNotification(notification:)),
            name: Notification.Name("closeButtonNotification"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.methodOfReceivedNotification(notification:)),
            name: Notification.Name("NotificationIdentifier"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.agentStatusNotification),
            name: Notification.Name("AgentStatus"),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageChangedFromSettings),
            name: Notification.Name("LanguageChangedFromSettings"),
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.endEditing(true)
        self.setLocalization()
        // enable IQKeyboardManager
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.toolbarConfiguration.placeholderConfiguration.showPlaceholder = false
        /// update agent status
        self.changeAgentStatusToActive()
        isChangeAgentStatus = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /// update agent status
        if isChangeAgentStatus {
            self.changeAgentStatusToInActive()
        }
        if isChangeAgentStatus == false {
            isChangeAgentStatus = true
        }
        self.view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /// update text input bottom
        self.msgInputStackBottom.constant = self.view.safeAreaInsets.bottom + 1
    }
    
    // MARK: - HideKeyboardWhenTappedAround
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    /// Screen localization
    func setLocalization() {
        let defaultPlaceholder = self.viewModel.defaultPlaceholder
        let feedbackPlaceholder = self.viewModel.feedbackPlaceholder
        self.viewModel.defaultPlaceholder = LanguageManager.shared.localizedString(forKey: "Ask me something")
        self.viewModel.feedbackPlaceholder = LanguageManager.shared.localizedString(forKey: "Want to share feedback?")
        
        self.txtViewMessage.keyboardType = .default
        self.txtViewMessage.autocorrectionType = .no
        
        self.viewModel.settingPlaceholder = LanguageManager.shared.localizedString(forKey: "Settings")
        self.viewModel.privacyPolicyPlaceholder = LanguageManager.shared.localizedString(forKey: "Privacy Policy")
        if self.txtViewMessage.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" || (self.txtViewMessage.text == defaultPlaceholder || self.txtViewMessage.text == feedbackPlaceholder) {
            if self.viewModel.isFeedback {
                self.txtViewMessage.text = self.viewModel.feedbackPlaceholder
            } else {
                self.txtViewMessage.text = self.viewModel.defaultPlaceholder
            }
        }
        
        _ = self.viewModel.checkForOptionsViewVisiblity()
        languagesArray.removeAll()
        for item in VAConfigurations.arrayOfLanguages {
            languagesArray.append(item.displayName ?? "")
        }
        // Handled text to speech icon - keyboard
        /*if VAConfigurations.isTextToSpeechEnable == true {
         self.txtViewMessage.keyboardType = .default
         self.txtViewMessage.autocorrectionType = .no
         } else {
         self.txtViewMessage.keyboardType = .emailAddress
         self.txtViewMessage.autocorrectionType = .no
         }*/
        self.localizeScannerView()
        self.localizeSignatureView()
    }
    
    // MARK: Notification Observers
    @objc func closeBtnNotification(notification: Notification) {
        self.viewModel.arrayOfMessages2D.removeAll()
        self.viewModel.arrayOfSuggestions.removeAll()
        if self.viewSuggestions.isHidden == false {
            self.viewSuggestions.isHidden = true
        }
        self.closeChatbot()
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        if let vcObj = storyboardObj.instantiateViewController(withIdentifier: "VAImageViewerVC") as? VAImageViewerVC {
            vcObj.image = notification.object as? UIImage
            self.present(vcObj, animated: true, completion: nil)
        }
    }
    @objc func languageChangedFromSettings() {
        self.viewModel.autoDetectedLanguageId = ""
    }
    
    // MARK: Keyboard Notifications
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            let newHeight = keyboardHeight - view.safeAreaInsets.bottom
            if self.txtViewMessage.isFirstResponder && (bConstViewTextInput.constant == 0 || newHeight != bConstViewTextInput.constant) {
                self.moveMessageInputView(keyboardHeight)
            }
        }
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        if bConstViewTextInput.constant != 0 {
            self.moveMessageInputView(0)
        }
    }
    
    //MARK: Table height observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){
        if((object as? UITableView) == preChatFormTable && keyPath == "contentSize") {
            if let newvalue = change?[.newKey]{
                let newsize  = newvalue as! CGSize
                if newsize.height > UIScreen.main.bounds.height * 0.7 {
                    self.prechatFormTableHeight.constant = UIScreen.main.bounds.height * 0.7
                } else {
                    self.prechatFormTableHeight.constant = newsize.height
                }
            }
        } else if ((object as? UITableView) == suggestionTableView && keyPath == "contentSize") {
            if let newvalue = change?[.newKey]{
                let newsize  = newvalue as! CGSize
                self.hConstViewSuggestion.constant = (newsize.height + (isNewGenAITheme ? 40 : 0))
                
            }
        }
    }
    
    // MARK: - Update Message Input View
    private func moveMessageInputView(_ height: CGFloat) {
        let bottomInsets: CGFloat = self.parent?.parent == nil ? (view.safeAreaInsets.bottom) : (self.parent?.parent?.view.safeAreaInsets.bottom ?? 0)
        self.bConstViewTextInput.constant = height == 0 ? 0 : (height - bottomInsets)
        UIView.animate(withDuration: 0.01) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: Did Enter Background Notifications
    @objc func didEnterBackground() {
        if VAConfigurations.isChatTool { // Only for ChatTool
            self.viewModel.showUnreadCount = true
            self.changeAgentStatusToInActive()
        } else if self.viewModel.isPokedByAgent {
            self.changeAgentStatusToInActive()
        }
    }
    
    // MARK: Will Terminate Notifications
    @objc func appWillTerminate() {
        /// Functionality disabled as session restoration enabled in chattool
        /*if VAConfigurations.isChatTool { // Only for ChatTool
         self.changeChatStatusToClosed()
         }*/
    }
    
    // MARK: Did Become Active Notifications
    @objc func applicationDidBecomeActive() {
        self.changeAgentStatusToActive()
        // Reconnect to stream if disconnected
        if xmppController != nil && xmppController.xmppStream.isDisconnected {
            self.txtViewMessage.resignFirstResponder()
            CustomLoader.show()
            self.isSessionDisconnected = true
            try? xmppController.xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
            if self.viewBGQueue.isHidden == false {
                self.lblQueueMessage.text = LanguageManager.shared.localizedString(forKey: "You are no longer connnected with live agent.")
                DispatchQueue.main.asyncAfter(deadline: .now()+2.5) {
                    self.viewBGQueue.isHidden = true
                    self.viewQueue.isHidden = true
                    self.viewModel.callTransferType = .none
                    self.viewModel.isPokedByAgent = false
                    self.viewModel.isAgentAcceptedCC360CallTransfer = false
                    self.btnSendMessage.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    // MARK: Agent Status Notifications
    @objc func agentStatusNotification() {
        /// update agent status to active
        self.changeAgentStatusToActive()
    }
    
    // MARK: Change AgentStatus To Active
    func changeAgentStatusToActive() {
        if self.viewModel.arrayOfMessages2D.count > 0 && (self.viewModel.callTransferType == .tids || VAConfigurations.isChatTool || self.viewModel.isPokedByAgent) {
            self.showAgentOnlineOrAwayStatus(state: .active)
        }
    }
    
    // MARK: Change AgentStatus To In-Active
    func changeAgentStatusToInActive() {
        if self.viewModel.arrayOfMessages2D.count > 0 && (self.viewModel.callTransferType == .tids || VAConfigurations.isChatTool || self.viewModel.isPokedByAgent) {
            self.showAgentOnlineOrAwayStatus(state: .inactive)
        }
    }
    
    // MARK: Setup UiView
    /// This function is used to setup view
    private func setupView() {
        self.imgViewTyping.isHidden = true
        self.viewTextInputBG.isUserInteractionEnabled = false
        self.updateUI()
        self.viewSuggestions.isHidden = true
        self.viewModel.arrayOfSuggestions.removeAll()
        self.searchedText = ""
        self.navigationController?.navigationBar.isHidden = true
        self.btnSendMessage.setTitle("", for: .normal)
        self.btnRefresh.setTitle("", for: .normal)
        self.btnCross.setTitle("", for: .normal)
        self.btnCancelReply.setTitle("", for: .normal)
        self.btnReplyMessage.setTitle("", for: .normal)
        self.txtViewMessage.text = self.viewModel.defaultPlaceholder
        self.txtViewMessage.textContainer.lineBreakMode = .byTruncatingHead
        self.viewSuggestions.backgroundColor = VAColorUtility.white
        self.viewSecureMessage.isHidden = true
        self.viewSecureMsgWidthConstraint.constant = 0
        self.btnShowSecureMessage.setTitle("", for: .normal)
        self.viewBGQueue.isHidden = true
        self.viewQueue.isHidden = true
        self.lblQueueMessage.textColor = VAColorUtility.white
        /// configure tableview cells
        self.configureMessagesTable()
        self.unreadMsgsView.isHidden = true
        self.unreadMsgCountLabel.text = ""
        /// Speech
        self.speechRecognizer?.delegate = self
        self.speechSynthesizer.delegate = self
        self.disableSpeechMode()
        self.uploadView.isHidden = true
        self.uploadViewWidthConstraint.constant = 0
    }
    
    
    // MARK: - Configure the UI with custom UIColor
    /// This function is used to configure UI
    func configureUIWithColor() {
        // Background Color
        self.view.backgroundColor = isNewGenAITheme ? UIColor.white : VAColorUtility.themeColor
        // Maximize view background color
        self.maximizeView.backgroundColor = VAColorUtility.themeColor
        // Header Color
        self.viewNavigation.backgroundColor = isNewGenAITheme ? UIColor.white : VAColorUtility.defaultHeaderColor
        // Text Input Color
        self.viewTextInputBG.backgroundColor = isNewGenAITheme ? UIColor.white : VAColorUtility.defaultTextInputColor
        self.viewTextInput.layer.borderColor = isNewGenAITheme ? UIColor.clear.cgColor : VAColorUtility.defaultThemeTextIconColor.cgColor
        // Header Options Color
        self.imgOptions.tintColor = VAColorUtility.defaultButtonColor
        // Header Close Color
        self.imgClose.tintColor = VAColorUtility.defaultButtonColor
        // Header minimize Color
        self.imgMinimize.tintColor = VAColorUtility.defaultButtonColor
        // maximize image Color
        self.maximizeImage.tintColor = VAColorUtility.defaultButtonColor
        // maximize image container Color
        self.maximizeImageContainer.layer.borderColor = VAColorUtility.defaultButtonColor.cgColor
        // TextInput Refresh
        self.imgRefresh.tintColor = isNewGenAITheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.themeTextIconColor
        // Send
        self.imgSend.tintColor = isNewGenAITheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.defaultThemeTextIconColor
        // Cross
        self.imgCross.tintColor = VAColorUtility.white
        // TextView
        self.txtViewMessage.textColor = VAColorUtility.defaultThemeTextIconColor
        // Header Seperator Color
        self.viewHeaderSeperator.backgroundColor = VAColorUtility.defaultThemeTextIconColor
        self.lblHeader.textColor = VAColorUtility.defaultButtonColor
        self.imgSecureMessage.tintColor = VAColorUtility.white
        self.viewSecureMessage.backgroundColor = isNewGenAITheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.themeTextIconColor
        self.viewCrossInside.backgroundColor = VAColorUtility.buttonColor
        self.suggestionTableSeparator.backgroundColor = VAColorUtility.defaultThemeTextIconColor
        /// Reply View
        self.btnReplyMessage.backgroundColor = VAColorUtility.white
        self.btnReplyMessage.tintColor = VAColorUtility.senderBubbleColor
        self.btnReplyMessage.imageView?.layer.transform = CATransform3DMakeScale(0.9, 0.9, 0.9)
        self.btnCancelReply.tintColor = VAColorUtility.senderBubbleColor
        self.btnCancelReply.imageView?.layer.transform = CATransform3DMakeScale(0.8, 0.8, 0.8)
        self.lblReplyMessage.textColor = VAColorUtility.senderBubbleColor
        /// Banner
        // self.viewBGQueue.backgroundColor = VAColorUtility.senderBubbleColor
        // self.lblQueueMessage.textColor = VAColorUtility.senderBubbleTextIconColor
        self.maximizeImageContainer.layer.borderColor = VAColorUtility.senderBubbleColor.cgColor
        self.maximizeImage.tintColor = VAColorUtility.senderBubbleColor
        /// Upload
        self.uploadImageView.tintColor = isNewGenAITheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.senderBubbleColor
    }
    // end
    
    /// This function used for Reload UITableView
    /// - Returns: Bool
    func isReloadCompleteTable() -> Bool {
        var lastBotMsgSequence = 0
        let allMessages = self.viewModel.arrayOfMessages2D.flatMap({$0})
        if allMessages.count > 0 {
            if let lastBotMsg = (allMessages.filter({$0.sender.id != VAConfigurations.userUUID})).last {
                lastBotMsgSequence = lastBotMsg.messageSequance
            }
        }
        var hasQuickReplyInLastBotMsg = false
        if lastBotMsgSequence != 0 {
            hasQuickReplyInLastBotMsg = ((allMessages.filter({$0.messageSequance == lastBotMsgSequence})).filter({$0.isQuickReplyMsg == true})).count > 0 ? true : false
        }
        let isLastMsgFromBot = lastBotMsgSequence == allMessages.last?.messageSequance
        if self.viewModel.configurationModel?.result?.quickReply == true || hasQuickReplyInLastBotMsg == false || isLastMsgFromBot {
            return false
        } else {
            return true
        }
    }
    
    // MARK: - Reload And Scroll UITableView
    /// This function is used to reload the tableview and scroll the table at bottom
    /// - Parameters:
    ///   - isAnimate: Bool
    func reloadAndScrollToBottom(isAnimate: Bool, reloadSection: Int? = nil, isFeedback: Bool = false) {
        let sectionToReload = reloadSection
        let lastSection = self.viewModel.arrayOfMessages2D.count - 1
        let secondLastSection = lastSection - 1
        // let totalMessagesCount = self.viewModel.arrayOfMessages2D.flatMap({$0}).count
        if lastSection == 0 {
            UIView.performWithoutAnimation {
                self.chatTableView.reloadData()
            }
        } else if sectionToReload != nil && sectionToReload ?? 0 > lastSection {
            self.chatTableView.beginUpdates()
            self.chatTableView.deleteSections([sectionToReload!], with: .top)
            self.chatTableView.endUpdates()
        } else if sectionToReload != nil {
            UIView.performWithoutAnimation {
                self.chatTableView.reloadSections(IndexSet(integer: sectionToReload!), with: .none)
                let rows = self.chatTableView.numberOfRows(inSection: secondLastSection)
                if rows != self.viewModel.arrayOfMessages2D[secondLastSection].count && secondLastSection != sectionToReload {
                    self.chatTableView.reloadSections(IndexSet(integer: secondLastSection), with: .none)
                }
            }
        } else if self.isReloadCompleteTable() && self.viewModel.arrayOfMessages2D[secondLastSection].count <= self.chatTableView.numberOfRows(inSection: secondLastSection) {
            UIView.performWithoutAnimation {
                self.chatTableView.beginUpdates()
                /// We use insertRows in case of reloading particular row of tableview. ReloadRow will not work in that case
                let indexToReload = self.viewModel.arrayOfMessages2D[lastSection].count - 1
                if indexToReload == 0 {
                    self.chatTableView.insertSections(IndexSet(integer: lastSection), with: .none)
                }
                self.chatTableView.insertRows(at: [IndexPath(row: indexToReload, section: lastSection)], with: .none)
                self.chatTableView.reloadSections(IndexSet(integer: secondLastSection), with: .none)
                self.chatTableView.endUpdates()
                
            }
        } else {
            UIView.performWithoutAnimation {
                var isSimultaneousMsgs = false
                var isSectionAdded = false
                if secondLastSection > 0 {
                    let thirdLastSection = secondLastSection-1
                    let rows = self.chatTableView.numberOfRows(inSection: thirdLastSection)
                    if rows != self.viewModel.arrayOfMessages2D[thirdLastSection].count {
                        self.chatTableView.beginUpdates()
                        self.chatTableView.insertRows(at: [IndexPath(row: self.viewModel.arrayOfMessages2D[thirdLastSection].count-1, section: thirdLastSection)], with: .none)
                        self.chatTableView.endUpdates()
                    }
                }
                let rows = self.chatTableView.numberOfRows(inSection: secondLastSection)
                if rows != self.viewModel.arrayOfMessages2D[secondLastSection].count {
                    if rows < self.viewModel.arrayOfMessages2D[secondLastSection].count {
                        for index in rows..<self.viewModel.arrayOfMessages2D[secondLastSection].count {
                            self.chatTableView.insertRows(at: [IndexPath(row: index, section: secondLastSection)], with: .none)
                        }
                        self.chatTableView.reloadSections(IndexSet(arrayLiteral: secondLastSection), with: .none)
                        isSimultaneousMsgs = true
                    } else {
                        self.chatTableView.beginUpdates()
                        /// We use insertRows in case of reloading particular row of tableview. ReloadRow will not work in that case
                        let indexToReload = self.viewModel.arrayOfMessages2D[lastSection].count - 1
                        if indexToReload == 0 {
                            isSectionAdded = true
                            self.chatTableView.insertSections(IndexSet(integer: lastSection), with: .none)
                            self.chatTableView.insertRows(at: [IndexPath(row: indexToReload, section: lastSection)], with: .none)
                        }
                        if isSectionAdded == false && self.chatTableView.numberOfRows(inSection: lastSection) < self.viewModel.arrayOfMessages2D[lastSection].count {
                            self.chatTableView.insertRows(at: [IndexPath(row: indexToReload, section: lastSection)], with: .none)
                        }
                        self.chatTableView.reloadSections(IndexSet(integer: secondLastSection), with: .none)
                        self.chatTableView.endUpdates()
                    }
                }
                if !isSectionAdded && !isSimultaneousMsgs {
                    var isRowAdded = false
                    self.chatTableView.beginUpdates()
                    /// We use insertRows in case of reloading particular row of tableview. ReloadRow will not work in that case
                    let indexToReload = self.viewModel.arrayOfMessages2D[lastSection].count - 1
                    if indexToReload == 0 && self.chatTableView.numberOfSections <= lastSection {
                        self.chatTableView.insertSections(IndexSet(integer: lastSection), with: .none)
                        self.chatTableView.insertRows(at: [IndexPath(row: indexToReload, section: lastSection)], with: .none)
                        isRowAdded = true
                    }
                    if isRowAdded == false && self.chatTableView.numberOfRows(inSection: lastSection) < self.viewModel.arrayOfMessages2D[lastSection].count {
                        self.chatTableView.insertRows(at: [IndexPath(row: indexToReload, section: lastSection)], with: .none)
                    }
                    for (sectionIndex, items) in self.viewModel.arrayOfMessages2D.enumerated() {
                        if sectionIndex < self.viewModel.arrayOfMessages2D.count-1 {
                            let currrentRows = self.chatTableView.numberOfRows(inSection: sectionIndex)
                            if items.count != currrentRows {
                                for itemIndex in currrentRows..<self.viewModel.arrayOfMessages2D[sectionIndex].count {
                                    self.chatTableView.insertRows(at: [IndexPath(row: itemIndex, section: sectionIndex)], with: .none)
                                }
                                self.chatTableView.reloadSections(IndexSet(arrayLiteral: sectionIndex), with: .none)
                            }
                        }
                    }
                    self.chatTableView.endUpdates()
                }
            }
            if isFeedback {
                let rowToReload = self.viewModel.arrayOfMessages2D[lastSection-1].count-1
                self.chatTableView.reloadRows(at: [IndexPath(item: rowToReload, section: lastSection-1)], with: .none)
            }
        }
        self.scrollChatTableToBottom(isAnimate: true)
    }
    // end
    
    /// This func hides quick reply button from the chat based on settings
    func handlePersistQuickReplyButtons() {
        if isNewGenAITheme {
            self.handlePersistQuickReplyButtonsNewGenAITheme()
        } else {
            self.handlePersistQuickReplyButtonsGeneric()
        }
    }
    func handlePersistQuickReplyButtonsGeneric() {
        var startIndex = 0
        if self.viewModel.arrayOfMessages2D.count > 2 {
            startIndex = self.viewModel.arrayOfMessages2D.count-2
        }
        for index in startIndex..<self.viewModel.arrayOfMessages2D.count {
            self.viewModel.arrayOfMessages2D[index] = self.viewModel.arrayOfMessages2D[index].map({
                var dict = $0
                dict.isHideQuickReplyButtons = true
                return dict
            })
        }
        /// If quick_reply == true then button will stay on the bot even after they are clicked
        if self.viewModel.configurationModel?.result?.quickReply == false {
            for index in startIndex..<self.viewModel.arrayOfMessages2D.count {
                var isButtonCardWithTitle = false
                if index >= self.viewModel.arrayOfMessages2D.count {
                    break
                }
                if self.viewModel.arrayOfMessages2D[index].first?.sender.id.lowercased() == VAConfigurations.userUUID.lowercased() {
                    continue
                }
                var messages = self.viewModel.arrayOfMessages2D[index]
                var itemsToRemove = [MockMessage]()
                for item in messages {
                    switch item.kind {
                    case .quickReply(let buttonItem):
                        if buttonItem.quickReplyProtocol?.title == "" {
                            itemsToRemove.append(item)
                        } else {
                            isButtonCardWithTitle = true
                        }
                    default:
                        break
                    }
                }
                if isButtonCardWithTitle {
                    self.chatTableView.reloadSections(IndexSet(integer: index), with: .none)
                }
                for item in itemsToRemove {
                    if let msgIndex = messages.firstIndex(where: {$0.messageId == item.messageId}) {
                        messages.remove(at: msgIndex)
                    }
                }
                if itemsToRemove.count > 0 {
                    var updatedMessages: [MockMessage] = []
                    for (index, item) in messages.enumerated() {
                        switch item.kind {
                        case .dateFeedback:
                            if index == (messages.count-1) {
                                updatedMessages.append(item)
                            } else {
                                break
                            }
                        default:
                            updatedMessages.append(item)
                        }
                    }
                    messages = updatedMessages
                    if messages.count == 1 && messages[0].sender.id != VAConfigurations.userUUID {
                        self.viewModel.arrayOfMessages2D.remove(at: index)
                        self.chatTableView.deleteSections(IndexSet(integer: index), with: .none)
                    } else {
                        messages[0].showBotImage = true
                        self.viewModel.arrayOfMessages2D[index] = messages
                        self.chatTableView.reloadSections(IndexSet(integer: index), with: .none)
                    }
                } else {
                    
                }
            }
            
            for (index, messages) in self.viewModel.arrayOfMessages2D.enumerated() {
                for (subIndex, _) in messages.enumerated() {
                    if subIndex == 0 {
                        self.viewModel.arrayOfMessages2D[index][subIndex].showBotImage = true
                        break
                    }
                }
            }
            for (index, messages) in self.viewModel.arrayOfMessages2D.enumerated() {
                for (subIndex, subMessage) in messages.enumerated() {
                    if subIndex == 0 {
                        if messages.count > 0 {
                            switch subMessage.kind {
                            case .dateFeedback:
                                self.viewModel.arrayOfMessages2D[index].remove(at: subIndex)
                            default:
                                break
                            }
                        }
                        break
                    }
                }
            }
        }
    }
    func handlePersistQuickReplyButtonsNewGenAITheme() {
        var startIndex = 0
        ///Remove feedback card if user didn't provide the feedback and send another msg
        if !self.viewModel.arrayOfMessages2D.isEmpty {
            let lastResponseIndex = self.viewModel.arrayOfMessages2D.count-1
            let lastResponseLastMsgIndex = self.viewModel.arrayOfMessages2D[lastResponseIndex].count-1
            switch self.viewModel.arrayOfMessages2D[lastResponseIndex][lastResponseLastMsgIndex].kind {
            case .feedbackItem(_):
                self.viewModel.arrayOfMessages2D[lastResponseIndex].remove(at: lastResponseLastMsgIndex)
            default:
                break
            }
        }
        ///
        if self.viewModel.arrayOfMessages2D.count > 2 {
            startIndex = self.viewModel.arrayOfMessages2D.count-2
        }
        for index in startIndex..<self.viewModel.arrayOfMessages2D.count {
            self.viewModel.arrayOfMessages2D[index] = self.viewModel.arrayOfMessages2D[index].map({
                var dict = $0
                dict.isHideQuickReplyButtons = true
                return dict
            })
        }
        /// If quick_reply == true then button will stay on the bot even after they are clicked
        if self.viewModel.configurationModel?.result?.quickReply == false {
            for index in startIndex..<self.viewModel.arrayOfMessages2D.count {
                var isButtonCardWithTitle = false
                if index >= self.viewModel.arrayOfMessages2D.count {
                    break
                }
                if self.viewModel.arrayOfMessages2D[index].first?.sender.id.lowercased() == VAConfigurations.userUUID.lowercased() {
                    continue
                }
                var messages = self.viewModel.arrayOfMessages2D[index]
                var itemsToRemove = [MockMessage]()
                for item in messages {
                    switch item.kind {
                    case .quickReply(let buttonItem):
                        if buttonItem.quickReplyProtocol?.title == "" {
                            itemsToRemove.append(item)
                        } else {
                            isButtonCardWithTitle = true
                        }
                    default:
                        break
                    }
                }
                if isButtonCardWithTitle {
                    self.chatTableView.reloadSections(IndexSet(integer: index), with: .none)
                }
                for item in itemsToRemove {
                    if let msgIndex = messages.firstIndex(where: {$0.messageId == item.messageId}) {
                        messages.remove(at: msgIndex)
                    }
                }
                if itemsToRemove.count > 0 {
                    var updatedMessages: [MockMessage] = []
                    for (index, item) in messages.enumerated() {
                        switch item.kind {
                        case .dateFeedback:
                            if index == (messages.count-1) {
                                updatedMessages.append(item)
                            } else {
                                break
                            }
                        default:
                            updatedMessages.append(item)
                        }
                    }
                    messages = updatedMessages
                    if messages.count == 1 && messages[0].sender.id != VAConfigurations.userUUID {
                        self.viewModel.arrayOfMessages2D.remove(at: index)
                        self.chatTableView.deleteSections(IndexSet(integer: index), with: .none)
                    } else {
                        messages[0].showBotImage = true
                        self.viewModel.arrayOfMessages2D[index] = messages
                        self.chatTableView.reloadSections(IndexSet(integer: index), with: .none)
                    }
                } else {
                    
                }
            }
            
            for (index, messages) in self.viewModel.arrayOfMessages2D.enumerated() {
                for (subIndex, _) in messages.enumerated() {
                    if subIndex == 0 {
                        self.viewModel.arrayOfMessages2D[index][subIndex].showBotImage = true
                        break
                    }
                }
            }
            for (index, messages) in self.viewModel.arrayOfMessages2D.enumerated() {
                for (subIndex, subMessage) in messages.enumerated() {
                    if subIndex == 0 {
                        if messages.count > 0 {
                            switch subMessage.kind {
                            case .dateFeedback:
                                self.viewModel.arrayOfMessages2D[index].remove(at: subIndex)
                            default:
                                break
                            }
                        }
                        break
                    }
                }
            }
        }
    }
    // end
    
    // MARK: - Scroll UITableView to bottom
    /// This function is used to scroll the UITableView to bottom
    /// - Parameter isAnimate: Nool
    func scrollChatTableToBottom(isAnimate: Bool) {
        let totalMessages = self.viewModel.arrayOfMessages2D.flatMap({$0}).count
        if totalMessages > 4 {
            let lastSection = self.viewModel.arrayOfMessages2D.count-1
            let lastMsgIndex = self.viewModel.arrayOfMessages2D[lastSection].count-1
            let indexPath = IndexPath.init(row: lastMsgIndex, section: lastSection)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.25) {
                self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: isAnimate)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.checkAndDisableTypingIfRequired()
        }
    }
    // end
    
    // MARK: - Disable/Enable typing for specific cards
    /// This function is used to disable typing for specific cards
    func checkAndDisableTypingIfRequired() {
        // FIXME: Uncomment once prevent typing functionality needs to be enabled.
        /*
         let lastMessage = self.viewModel.arrayOfMessages2D.last
         if lastMessage?.filter({$0.preventTyping == true}) != nil && lastMessage?.filter({$0.preventTyping == true}).count ?? 0 > 0 {
         //let isTextFeedback = self.viewModel.messageData?.feedback?["text_feedback"] ?? false
         if /*!isTextFeedback && */!self.viewModel.isFeedback {
         if self.viewTextInputBG.isHidden == false {
         self.viewTextInputBG.isHidden = true
         self.view.endEditing(true)
         }
         }
         }
         */
    }
    
    /// This func is used to enable typing if it is disable for a card and user hit on any url button.
    func enableTypingIfRequired() {
        let lastMessage = self.viewModel.arrayOfMessages2D.last
        if lastMessage?.filter({$0.preventTyping == true}) != nil && lastMessage?.filter({$0.preventTyping == true}).count ?? 0 > 0 {
            if self.viewTextInputBG.isHidden == true && !VAConfigurations.isChatbotMinimized {
                self.viewTextInputBG.isHidden = false
                self.txtViewMessage.text = self.viewModel.defaultPlaceholder
            }
        }
    }
    // end
    
    // MARK: - Update UI on api response
    /// This func is used to update ui after api response
    func updateUI() {
        /// On Success response of Configuration api
        self.viewModel.onSuccessResponseConfigApi = { [weak self] in
            self?.isNewGenAITheme = self?.viewModel.configurationModel?.result?.genAINewTheme ?? false
            if self?.isOldSessionNotClaimed == nil && VAConfigurations.customData?.isGroupSSO == false && self?.viewModel.prechatForm?.settings?.props != nil && self?.viewModel.prechatForm?.settings?.props?.isEmpty == false {
                CustomLoader.hide()
                self?.showPrechatFormAtBotLaunch()
            } else {
                self?.isOldSessionNotClaimed = nil
                self?.handleConfigAPIResponse()
            }
        }
        /// On success repsponse of suggestion api
        self.viewModel.onSuccessResponseSuggestionApi = { [weak self] (userQuery) in
            self?.searchedText = userQuery
            if self?.txtViewMessage.text.count ?? 0 >= 3 && self?.txtViewMessage.text != self?.viewModel.defaultPlaceholder && self?.txtViewMessage.text != self?.viewModel.feedbackPlaceholder {
                self?.viewSuggestions.isHidden = false
                /*if self?.viewModel.arrayOfSuggestions.count ?? 0 > 4 {
                    self?.hConstViewSuggestion.constant = 150
                } else {
                    self?.hConstViewSuggestion.constant = CGFloat((self?.viewModel.arrayOfSuggestions.count ?? 0) * 50)
                }*/
                // reload suggestion UITableView
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self?.suggestionTableView.reloadData()
                }
            } else {
                if self?.viewSuggestions.isHidden == false {
                    // hide suggestion view
                    self?.viewSuggestions.isHidden = true
                    self?.viewModel.arrayOfSuggestions.removeAll()
                }
            }
        }
        /// On failure repsponse of configuration api
        self.viewModel.onFailureResponseConfigApi = { [weak self] (errorMessage, isRetry) in
            guard let safeSelf = self else {return}
            CustomLoader.hide()
            var buttonTitle = LanguageManager.shared.localizedString(forKey: "OK")
            if isRetry {
                buttonTitle = LanguageManager.shared.localizedString(forKey: "Retry")
            }
            UIAlertController.openAlertWithOk(LanguageManager.shared.localizedString(forKey: "Error"), errorMessage, buttonTitle, view: safeSelf) {
                // self?.dismiss(animated: true, completion: nil)
                if isRetry {
                    CustomLoader.show()
                    self?.viewModel.callGetConfigurationApi()
                } else {
                    self?.closeChatbot()
                }
            }
        }
        /// On failure repsponse of suggestion api
        self.viewModel.onFailureResponseSuggestionApi = { [weak self] (_) in
            guard let safeSelf = self else {return}
            safeSelf.viewSuggestions.isHidden = true
            safeSelf.viewModel.arrayOfSuggestions.removeAll()
            safeSelf.searchedText = ""
        }
        /// No Internet connection
        self.viewModel.noInternetConnection = { [weak self] in
            guard let safeSelf = self else {return}
            CustomLoader.hide()
            UIAlertController.openAlertWithOk(LanguageManager.shared.localizedString(forKey: "Error"), LanguageManager.shared.localizedString(forKey: "No Internet Connection"), LanguageManager.shared.localizedString(forKey: "OK"), view: safeSelf, completion: nil)
        }
    }
    // end
    
    func handleConfigAPIResponse() {
        CustomLoader.show()
        if VAConfigurations.customData?.isGroupSSO == true {
            let jidSeparated = (VAConfigurations.customData?.groupSssoJid ?? "").components(separatedBy: "@").first ?? ""
            VAConfigurations.userJid = jidSeparated.lowercased() + "@" + VAConfigurations.vHost
            DispatchQueue.main.async {
                UserDefaultsManager.shared.resetSessionID()
                UserDefaultsManager.shared.setUserUUID(jidSeparated)
            }
        } else {
            VAConfigurations.userJid = VAConfigurations.userUUID.lowercased() + "@" + VAConfigurations.vHost
        }
        print("User JID: \(VAConfigurations.userJid)")
        self.newMessagesCount = 0
        /// Set Custom font and size
        let suggestionFontSize: Double = ((self.viewModel.configIntegrationModel?.settings?.autoSuggestionFont?.value ?? "") == "" ? self.defaultFontSize : Double((self.viewModel.configIntegrationModel?.settings?.autoSuggestionFont?.value)!)) ?? 0.0
        self.autoSuggestionFontSize = suggestionFontSize > self.maximumFontSize ? self.maximumFontSize : (suggestionFontSize < self.minimumFontSize ? self.minimumFontSize : suggestionFontSize)
        
        let dateFontSize = ((self.viewModel.configIntegrationModel?.settings?.dateTimeFont?.value ?? "") == "" ? self.defaultFontSize : Double((self.viewModel.configIntegrationModel?.settings?.dateTimeFont?.value)!))!
        self.dateTimeFontSize = dateFontSize > self.maximumFontSize ? self.maximumFontSize : (dateFontSize < self.minimumFontSize ? self.minimumFontSize : dateFontSize)
        
        let textFontSize = ((self.viewModel.configIntegrationModel?.settings?.textFont?.value ?? "") == "" ? self.defaultFontSize : Double((self.viewModel.configIntegrationModel?.settings?.textFont?.value)!))!
        self.textFontSize = textFontSize > self.maximumFontSize ? self.maximumFontSize : (textFontSize < self.minimumFontSize ? self.minimumFontSize : textFontSize)
        var fontFamily = ""
        if self.viewModel.configIntegrationModel?.settings?.customFont == true {
            fontFamily = self.viewModel.configIntegrationModel?.settings?.customFontTitle ?? ""
        } else {
            fontFamily = self.viewModel.configIntegrationModel?.settings?.fontFamily?.value ?? ""
        }
        
        self.fontName = Font.getFontName(family: fontFamily)
        
        if isNewGenAITheme {
            self.viewModel.maxCharacterLength = self.viewModel.configurationModel?.result?.genAISettings?.widgetEnteredTextMaxLimit ?? self.viewModel.maxCharacterLength
        }
        
        // configure messagent input bar
        self.configureMessageInputBar()
        /// update the header image and title
        self.setupHeaderImageAndTitle()
        /// update UIColor with response of Configuration Api
        self.configureUIWithColor()
        /// circular progress on send button
        self.setCircularProgress()
        /// Suggestions view
        self.configureSuggestionsView()
        let isHideOptionsView = self.viewModel.checkForOptionsViewVisiblity()
        self.viewOptions.isHidden = isHideOptionsView
        if isHideOptionsView {
            self.wConstraintViewOptions.constant = 0
        }
        /// check for live agent is available or not
        if self.viewModel.configIntegrationModel?.liveAgntVisiblity == true {
            /// show live agent view
            self.viewLiveAgent.isHidden = false
        } else {
            /// hide live agent view
            self.viewLiveAgent.isHidden = true
            self.wConstraintLiveAgent.constant = 0
        }
        
        /// check for sso active or not
        if VAConfigurations.customData?.isGroupSSO == true && (self.viewModel.configurationModel?.result?.ssoActive ?? false) && VAConfigurations.isChatTool == false {
            self.viewModel.isSSO = 1
            self.viewModel.ssoSessionId = VAConfigurations.customData?.groupSsoToken ?? ""
            CustomLoader.show()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.connectXMPPwith()
            }
        } else if VAConfigurations.customData?.isGroupSSO == false && (self.viewModel.configurationModel?.result?.ssoActive ?? false) && VAConfigurations.isChatTool == false {
            /// enable is true than user should be authenticate first
            CustomLoader.hide()
            self.authenticateUserBeforeEnablingChatbot()
        } else {
            /// connnect with xmpp server
            self.connectXMPPwith()
        }
        /// localization
        self.setLocalization()
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
//            self.configureSignatureView()
//            self.configureQRScannerView()
//            self.configureMapView()
        }
    }
    // MARK: - Authenticate user beforw enabling chatbot
    func authenticateUserBeforeEnablingChatbot() {
        // let isOneLoginSSO = self.viewModel.configurationModel?.result?.ssoType == SSOType.oneLogin ? true : false
        let isOneLoginSSO = (self.viewModel.configurationModel?.result?.ssoType == SSOType.oneLogin || self.viewModel.configurationModel?.result?.ssoType == SSOType.saml) ? true : false
        let ssoUrl = getSSORedirectURL(ssoAuthUrl: self.viewModel.configurationModel?.result?.ssoAuthUrl ?? "", isOneLoginSSO: isOneLoginSSO, isAuthorisationOnStartup: true)
        self.viewModel.isMessageTyping = false
        // open sso auth controller
        self.openSSOAuthController(ssoUrlStr: ssoUrl, isAuthenticateOnLaunch: true, isOneLoginSSO: isOneLoginSSO, cardIndexPath: nil)
    }
    // end
    
    // MARK: - Set up header image and title
    /// This function is used to update header image and title
    func setupHeaderImageAndTitle() {
        self.viewNavigation.isHidden = false
        // Header Title
        /*self.lblHeader.text = self.viewModel.configurationModel?.result?.name ?? ""
         self.lblHeader.font = UIFont(name: fontName, size: textFontSize)*/
        self.lblHeader.isHidden = true ///As per feedback comments (Aditya T)
        // Header Image
        if self.viewModel.configurationModel?.result?.headerLogo?.isEmpty ?? true {
            self.imgHeaderLogo?.image = UIImage(named: "telus-icon", in: bundleObj, with: nil)
        } else {
            ImageDownloadManager().loadImage(imageURL: self.viewModel.configurationModel?.result?.headerLogo ?? "") {[weak self] (_, downloadedImage) in
                if let img = downloadedImage {
                    DispatchQueue.main.async {
                        self?.imgHeaderLogo?.image = img
                    }
                }
            }
        }
    }
    /// Layout handling for suggestions view
    private func configureSuggestionsView() {
        self.suggestionTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        if isNewGenAITheme {
            self.suggestionTitleLabelHeight.constant = 40
            self.suggestionsViewLeading.constant = 16
            self.suggestionsViewTrailing.constant = 16
            self.viewSuggestions.layer.cornerRadius = 10
            self.viewSuggestions.borderWidth = 1
            self.viewSuggestions.borderColor = VAColorUtility.borderColor_NT
            self.suggestionTitleLabel.text = "Suggestions"
            self.suggestionTitleLabel.textColor = VAColorUtility.greyCharcoal_NT
            self.viewSuggestions.backgroundColor = VAColorUtility.lightGrey_NT
            self.suggestionTableSeparator.backgroundColor = VAColorUtility.borderColor_NT
        } else {
            self.suggestionTitleLabelHeight.constant = 0
            self.suggestionsViewLeading.constant = 0
            self.suggestionsViewTrailing.constant = 0
            self.viewSuggestions.layer.cornerRadius = 0
            self.viewSuggestions.borderWidth = 0
            self.viewSuggestions.backgroundColor = .white
            self.suggestionTableSeparator.backgroundColor = VAColorUtility.defaultThemeTextIconColor
        }
    }
    
    /// This function is used to open VAChatTranscriptVC
    func openChatTranscriptScreen() {
        if let vcObj = storyboardObj.instantiateViewController(withIdentifier: "VAChatTranscriptVC") as? VAChatTranscriptVC {
            vcObj.textFontSize = textFontSize
            vcObj.fontName = fontName
            vcObj.isFeedbackSkipped = true
            vcObj.configResulModel = self.viewModel.configurationModel?.result
            vcObj.logoWidth = self.imgHeaderLogo.bounds.width
            vcObj.isGenAINewTheme = self.isNewGenAITheme
            self.navigationController?.pushViewController(vcObj, animated: true)
        }
    }
    
    /// This function is used to open the Custom Feedback screen
    func moveToCustomFeedback() {
        if let feedbackSurveyVC = storyboardObj.instantiateViewController(withIdentifier: "FeedbackSurveyVC") as? FeedbackSurveyVC {
            feedbackSurveyVC.npsSettings = self.viewModel.configurationModel?.result?.npsSettings
            feedbackSurveyVC.chatTranscriptEnabled = self.viewModel.configurationModel?.result?.emailConv ?? false
            feedbackSurveyVC.textFontSize = textFontSize
            feedbackSurveyVC.fontName = fontName
            feedbackSurveyVC.configResulModel = self.viewModel.configurationModel?.result
            feedbackSurveyVC.logoWidth = self.imgHeaderLogo.bounds.width
            feedbackSurveyVC.isGenAINewTheme = self.isNewGenAITheme
            self.navigationController?.pushViewController(feedbackSurveyVC, animated: false)
        }
    }
    
    /// This function is used to open the Normal Feedback screen
    func moveToNormalFeedback() {
        if let normalFeedbackVC = storyboardObj.instantiateViewController(withIdentifier: "NormalFeedbackVC") as? NormalFeedbackVC {
            normalFeedbackVC.npsSettings = self.viewModel.configurationModel?.result?.npsSettings
            normalFeedbackVC.chatTranscriptEnabled = self.viewModel.configurationModel?.result?.emailConv ?? false
            normalFeedbackVC.isCustomizeSurveyEnabled = self.viewModel.configurationModel?.result?.npsSettings?.customTheme ?? false
            normalFeedbackVC.textFontSize = textFontSize
            normalFeedbackVC.fontName = fontName
            normalFeedbackVC.configResulModel = self.viewModel.configurationModel?.result
            normalFeedbackVC.logoWidth = self.imgHeaderLogo.bounds.width
            normalFeedbackVC.isGenAINewTheme = self.isNewGenAITheme
            self.navigationController?.pushViewController(normalFeedbackVC, animated: false)
        }
    }
    // end
    
    // MARK: - Close ChatBot
    /// This function is used to close the chatbot
    func validateCloseChatbot() {
        if VAConfigurations.isChatTool { /// Only for virtual agent
            /// Release agent/end chat with live agent
            self.changeChatStatusToClosed()
        } else {
            if self.viewModel.callTransferType == .tids || self.viewModel.isPokedByAgent {
                /// Release agent/end chat with live agent
                self.changeChatStatusToClosed()
            }
            /// Graceful closure of chat/end chat with virtual agent
            self.sendCloseChatbotMsgToServer()
        }
        self.disconnectSocket()
        self.isChangeAgentStatus = false
        self.viewModel.isMessageTyping = false
        self.validateFeedbackOrChatTranscriptScreen()
    }
    
    /// This function opens the feedback or chat transcript screen based on the settings enabled from admin
    func validateFeedbackOrChatTranscriptScreen() {
        /// check nps feedback enable or not
        let isNPS = self.viewModel.configurationModel?.result?.enableNps ?? false
        /// check for chat transcript enable or not
        let isChatTranscript = self.viewModel.configurationModel?.result?.emailConv ?? false
        /// get nps rating
        let rating = self.viewModel.configurationModel?.result?.npsSettings?.ratings ?? false
        /// if custom theme is true and rating false then open custom feedback screen else open normal feedabck
        if isNPS {
            if self.viewModel.configurationModel?.result?.npsSettings?.customTheme ?? false && rating == true {
                /// open custom feedback screen
                self.moveToCustomFeedback()
            } else {
                /// open normal feedback screen
                self.moveToNormalFeedback()
            }
        } else {
            /// if chat transcript is true then open VAChatTranscriptVC screen else close the chatbot
            if isChatTranscript == true {
                self.openChatTranscriptScreen()
            } else {
                self.closeChatbot()
            }
        }
    }
    
    func hideChoiceCardOptionsOfLastResponseBeforeSendingMessage() {
        let lastBotResponse = self.viewModel.arrayOfMessages2D.last
        if lastBotResponse?.count ?? 0 > 1 {
            let messageIndex = isNewGenAITheme ? (lastBotResponse!.count-1) : (lastBotResponse!.count-2)
            let lastMessage = lastBotResponse![messageIndex]
            if lastMessage.responseType == "multi_ops" {
                self.viewModel.arrayOfMessages2D[self.viewModel.arrayOfMessages2D.count-1][messageIndex].isMultiOpsTapped = true
                self.viewModel.arrayOfMessages2D[self.viewModel.arrayOfMessages2D.count-1][messageIndex].allowSkip = false
                self.chatTableView.beginUpdates()
                self.chatTableView.reloadSections(IndexSet(integer: self.viewModel.arrayOfMessages2D.count-1), with: .none)
                self.chatTableView.endUpdates()
            }
        }
    }
    
    @objc func updateGenAISendMsgDelayCounter() {
        if self.genAISendMsgDelayCounter < (self.viewModel.configurationModel?.result?.genAIApiTimeout ?? 30) {
            self.genAISendMsgDelayCounter += 1
            print("genAISendMsgDelayCounter : \(genAISendMsgDelayCounter)")
        } else {
            self.invalidateGenAISendMsgDelayTimer()
        }
    }
    func invalidateGenAISendMsgDelayTimer() {
        self.getAISendMsgDelayTimer?.invalidate()
        self.getAISendMsgDelayTimer = nil
        self.genAISendMsgDelayCounter = 0
        self.btnSendMessage.isUserInteractionEnabled = true
        self.imgViewTyping.isHidden = true
        print("genAISendMsgDelayCounter cleared")
    }
    func startGenAISendMsgDelayTimer() {
        self.invalidateGenAISendMsgDelayTimer()
        self.genAISendMsgDelayCounter = 0
        let fireDate = Date().addingTimeInterval(TimeInterval(1.0))
        self.getAISendMsgDelayTimer = Timer(fireAt: fireDate, interval: 1.0, target: self, selector: #selector(self.updateGenAISendMsgDelayCounter), userInfo: nil, repeats: true)
        RunLoop.main.add(self.getAISendMsgDelayTimer!, forMode: RunLoop.Mode.common)
    }
    
    // MARK: Button actions
    /// This is used when user tapped on send message button
    @IBAction func btnSendMessageTapped(_ sender: UIButton) {
        if self.txtViewMessage.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.txtViewMessage.text = ""
            return
        }
        let isTextFeedback = self.viewModel.messageData?.feedback?["click_feedback"] ?? false
        
        if (self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAI || self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAINLU) && !isTextFeedback && !self.viewModel.isPokedByAgent {
            if genAISendMsgDelayCounter == 0 {
                self.startGenAISendMsgDelayTimer()
                self.sendUserMessageOnTapOfSendButton(userInput: self.txtViewMessage.text)
            }
        } else {
            self.sendUserMessageOnTapOfSendButton(userInput: self.txtViewMessage.text)
        }
    }
    func sendUserMessageOnTapOfSendButton(userInput: String) {
        if VAConfigurations.isChatTool{
            ///Remove unread message status cell
            self.removeUnreadMessageCell()
        }
        let lastBotResponse = self.viewModel.arrayOfMessages2D.last
        /// Disable send button to not allow user to send multiple messages at same time in case of live agent/call transfer
        self.btnSendMessage.isUserInteractionEnabled = false
        if VAConfigurations.isChatTool || self.viewModel.isPokedByAgent || self.viewModel.isCallTransfer || self.viewModel.callTransferType != .none {
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                self.btnSendMessage.isUserInteractionEnabled = true
            }
        }
        self.disableSpeechMode()
        self.hideChoiceCardOptionsOfLastResponseBeforeSendingMessage()
        /*if self.viewModel.messageData?.isPrompt == true && userInput.isEmpty == false && self.viewModel.isCallTransfer == false && self.viewModel.callTransferType == .none && self.viewModel.isPokedByAgent == false {
         self.btnSendMessage.isUserInteractionEnabled = false
         }*/
        var messageString: String = ""
        var messageStringForModel: String = ""
        var isRegexMatched: Bool = false
        if let array = self.viewModel.configIntegrationModel?.redaction, array.count > 0 {
            for index in 0..<array.count {
                let model = array[index]
                if model.active != nil && model.active == true {
                    if let regex = model.regex {
                        isRegexMatched = userInput.matches(regex)
                        if isRegexMatched {
                            break
                        }
                    }
                }
            }
        }
        if isRegexMatched {
            if self.viewModel.messageData?.masked == nil || self.viewModel.messageData?.masked == false {
                messageString = String(repeating: "*", count: userInput.count)
                messageStringForModel = userInput
            } else {
                messageString = String(repeating: "●", count: 10)
                messageStringForModel = userInput
            }
        } else if self.viewModel.messageData?.masked ?? false {
            messageString = self.viewModel.textViewOriginalText
            messageStringForModel = String(repeating: "●", count: 10)/// this is to show user 10 dots whether user types 1 character or 100 chars so that user cant guess how many characters user has typed.
        } else {
            messageString = userInput
            messageStringForModel = userInput
        }
        
        if messageString == self.viewModel.defaultPlaceholder || messageString == self.viewModel.feedbackPlaceholder || messageString.count == 0 {
            // Do nothing
        } else {
            var message = MockMessage(text: messageStringForModel, sender: Sender(id: VAConfigurations.userUUID, displayName: VAConfigurations.customData?.userName ?? ""), messageId: UUID().uuidString, date: Date())
            
            message.sentiment = self.viewModel.messageData?.sentiment ?? 0
            message.masked = self.viewModel.messageData?.masked ?? nil
            if self.viewModel.arrayOfMessages2D.count == 0 {
                message.messageSequance = 1
            } else {
                message.messageSequance = (self.viewModel.arrayOfMessages2D.last?.first?.messageSequance ?? 0)+1// self.viewModel.arrayOfMessages2D.count + 1
            }
            if VAConfigurations.isChatTool {
                message.enableSpecificMsgReply = true
            }
            if VAConfigurations.isChatTool, self.viewModel.selectedMessageModelForReply.count > 0 {
                message.repliedMessageDict = self.viewModel.selectedMessageModelForReply
            }
            self.handlePersistQuickReplyButtons()
            // let isTextFeedback = self.viewModel.messageData?.feedback?["text_feedback"] ?? false
            let isTextFeedback = self.viewModel.messageData?.feedback?["click_feedback"] ?? false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.viewModel.arrayOfMessages2D.append([message])
                self.reloadAndScrollToBottom(isAnimate: false, isFeedback: isTextFeedback)
                
                if self.viewModel.callTransferType == .oracle || self.viewModel.callTransferType == .genesysInternal {
                    self.sendDataToServer(data: messageString, context: self.viewModel.oracleContext, senderMessageType: SenderMessageType.text)
                } else {
                    if isTextFeedback {
                        self.viewModel.isFeedbackGivenByUser = true
                        self.sendDataToServer(data: messageString, userMessageId: "\(self.viewModel.messageData?.userMessageId ?? 0)", senderMessageType: SenderMessageType.text)
                    } else {
                        if lastBotResponse?.count ?? 0 > 1 {
                            let messageIndex = lastBotResponse!.count-2
                            let lastMessage = lastBotResponse![messageIndex]
                            switch lastMessage.kind {
                            case .multiOps(let multiOpsProtocol):
                                self.handleChoiceCardResponseOnTyping(multiOpsProtocol: multiOpsProtocol, messageString: messageString)
                            case .quickReply(let quickReply):
                                self.handleButtonCardResponseOnTyping(quickReply: quickReply, messageString: messageString)
                            default:
                                //if self.viewModel.messageData?.masked
                                self.sendDataToServer(data: messageString, senderMessageType: SenderMessageType.text)
                            }
                        } else {
                            self.sendDataToServer(data: messageString, senderMessageType: SenderMessageType.text)
                        }
                    }
                }
                // Reset
                self.setCircularProgress()
                if self.viewModel.isFeedback {
                    //self.hideFeedbackInputTextBar()
                } else {
                    self.txtViewMessage.text = ""
                    self.viewModel.textViewOriginalText = ""
                    self.viewSecureMessage.isHidden = true
                    self.viewSecureMsgWidthConstraint.constant = 0
                }
                if self.viewShowReplyMessage.isHidden == false {
                    self.viewShowReplyMessage.isHidden = true
                    self.viewModel.selectedMessageModelForReply = [:]
                }
            }
        }
        self.viewSuggestions.isHidden = true
        self.viewModel.arrayOfSuggestions.removeAll()
        self.searchedText = ""
    }
    ///Handling of choice card: If user types text of skip button, options instead of clicking it
    func handleChoiceCardResponseOnTyping(multiOpsProtocol: MultiOpsProtocol, messageString: String) {
        let multiOps = multiOpsProtocol.multiOps
        let skipButtonText = (multiOps?.options.count ?? 0) > 0 ? multiOps?.options[0].label ?? "" : ""
        let choices = multiOps?.choices.filter({$0.label.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == messageString.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)})
        if skipButtonText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == messageString.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
            let templateId = multiOps?.options[0].data ?? "0"
            let option = multiOps?.options[0].label ?? ""
            self.viewModel.messageData?.isPrompt = false
            self.sendDataToServer(data: templateId, showLabelText: option, templateId: 0, isPrompt: false, senderMessageType: SenderMessageType.text)
        } else if choices != nil && !(choices?.isEmpty ?? true) {
            self.sendDataToServer(data: choices?.first?.value ?? "", templateId: 0, isPrompt: false, senderMessageType: SenderMessageType.text)
        } else {
            self.viewModel.messageData?.isPrompt = false
            self.sendDataToServer(data: messageString, templateId: 0, isPrompt: false, senderMessageType: SenderMessageType.text)
        }
    }
    ///Handling of button card: If user types text of buttons options instead of clicking it
    func handleButtonCardResponseOnTyping(quickReply: QuickReplyProtocol, messageString: String) {
        let responseContext = self.viewModel.messageData?.contexts?.first ?? [:]
        let context = ["intent_id": responseContext["intent_id"] as? Int ?? 0, "intent_name": responseContext["intent_name"] as? String ?? "", "intent_uid": responseContext["intent_uid"] as? String ?? ""] as [String: Any]
        let availableOptions = quickReply.quickReplyProtocol?.otherButtons.filter({$0.text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == messageString.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)})
        if !(availableOptions?.isEmpty ?? true) {
            let model = availableOptions!.first!
            if model.type == "goto" {
                self.sendDataToServer(data: model.text, templateId: Int(model.data), context: [context], senderMessageType: SenderMessageType.text)
            } else if model.type == "query" {
                self.sendDataToServer(data: model.data, showLabelText: model.text, isQuery: true, context: [context], isPrompt: false, senderMessageType: SenderMessageType.text)
            } else {
                self.sendDataToServer(data: messageString, senderMessageType: SenderMessageType.text)
            }
        } else {
            self.sendDataToServer(data: messageString, senderMessageType: SenderMessageType.text)
        }
    }
    
    /// This is used when user tapped on show secure  message button
    @IBAction func btnShowSecureMessageTapped(_ sender: UIButton) {
        if self.viewModel.messageData?.masked ?? false {
            self.handleSecureMessageButton(isSecure: self.viewModel.isSecured)
        }
    }
    
    /// This is used when user tapped on option button
    @IBAction func btnOptionsTapped(_ sender: UIButton) {
        self.isChangeAgentStatus = false
        self.changeAgentStatusToInActive()
        self.viewModel.isMessageTyping = false
        self.view.endEditing(true)
        
        // open list view
        VAPopoverListVC.openPopoverListView(arrayOfData: self.viewModel.arrayOfOptions, viewController: self, sender: sender, fontName: self.fontName, textFontSize: self.textFontSize, isGenaAINewTheme: self.isNewGenAITheme) { (index, _) in
            if self.viewModel.arrayOfOptions[index] == LanguageManager.shared.localizedString(forKey: "Settings") {
                /// open settings screen
                if let settingViewController = self.storyboardObj.instantiateViewController(withIdentifier: "VASettingsVC") as? VASettingsVC {
                    settingViewController.configIntegrationModel = self.viewModel.configIntegrationModel
                    settingViewController.chatTranscriptEnabled = self.viewModel.configurationModel?.result?.integration?[0].chatTranscript ?? false// self.viewModel.configurationModel?.result?.emailConv ?? false
                    settingViewController.fontName = self.fontName
                    settingViewController.textFontSize = self.textFontSize
                    settingViewController.isGenAINewTheme = self.isNewGenAITheme
                    self.navigationController?.pushViewController(settingViewController, animated: true)
                }
            } else {
                /// open privacy policy
                if let vcObj = self.storyboardObj.instantiateViewController(withIdentifier: "VAWebViewerVC") as? VAWebViewerVC {
                    vcObj.fontName = self.fontName
                    vcObj.textFontSize = self.textFontSize
                    vcObj.webUrl = self.viewModel.configIntegrationModel?.privacyUrl ?? ""
                    vcObj.titleString = LanguageManager.shared.localizedString(forKey: "Privacy Policy")
                    vcObj.isGenAINewTheme = self.isNewGenAITheme
                    self.present(vcObj, animated: true, completion: nil)
                }
            }
        }
    }
    
    /// This is used when user tapped on close button
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        self.validateCloseChatbot()
    }
    
    /// This function is used to minimize chatbot
    @IBAction func btnMinimizeChatbotTapped(_ sender: UIButton) {
        if self.txtViewMessage.isFirstResponder {
            self.view.endEditing(true)
        }
        self.maximizeView.isHidden = false
        self.chatTableView.isHidden = true
        self.viewTextInputBG.isHidden = true
        self.viewNavigation.isHidden = true
        self.maximizeView.backgroundColor = .clear
        self.view.backgroundColor = .clear
        self.view.bringSubviewToFront(maximizeView)
        self.viewSuggestions.isHidden = true
        if self.viewQueue.isHidden == false {
            self.viewBGQueue.isHidden = true
            self.viewQueue.isHidden = true
        }
        if VAConfigurations.isChatTool {
            self.viewShowReplyMessage.isHidden = true
            self.viewModel.showUnreadCount = true
        }
        // FIXME: - Message notification
        // self.updateUnreadMsgsCount()
        VAConfigurations.isChatbotMinimized = true
        if VAConfigurations.isChatTool && self.viewModel.isAgentConnectedToChat {
            self.changeAgentStatusToInActive()
        }
        //VAConfigurations.virtualAssistant?.delegate?.didTapMinimizeChatbot()
    }
    
    /// This function is used to maximize chatbot
    @IBAction func btnMaximizeChatbotTapped(_ sender: UIButton) {
        self.maximizeView.isHidden = true
        self.chatTableView.isHidden = false
        self.viewNavigation.isHidden = false
        self.view.backgroundColor = VAColorUtility.themeColor
        self.view.sendSubviewToBack(self.maximizeView)
        self.newMessagesCount = 0
        VAConfigurations.isChatbotMinimized = false
        if !VAConfigurations.isChatTool {
            self.viewTextInputBG.isHidden = false
        } else if (self.viewModel.isAgentConnectedToChat && !self.viewModel.isChatToolChatClosed) {
            self.viewTextInputBG.isHidden = false
        }
        if self.viewModel.arrayOfSuggestions.isEmpty == false && self.txtViewMessage.text.count > 3 {
            self.viewSuggestions.isHidden = false
        }
        if VAConfigurations.isChatTool && self.viewModel.isAgentConnectedToChat {
            self.changeAgentStatusToActive()
        }
        //VAConfigurations.virtualAssistant?.delegate?.didTapMaximizeChatbot()
    }
    
    /// This is used when user tapped on send refresh button
    @IBAction func btnRefreshTapped(_ sender: UIButton) {
        // set call transfer none if intent refreshed
        if self.viewModel.callTransferType != .CC360 && self.viewModel.callTransferType != .tids {
            self.viewModel.callTransferType = .none
        }
        self.hideReset()
    }
    
    /// This is used when user tapped on cross  button
    @IBAction func btnCrossTapped(_ sender: UIButton) {
        if self.viewSuggestions.isHidden == false {
            self.viewSuggestions.isHidden = true
            self.viewModel.arrayOfSuggestions.removeAll()
            self.searchedText = ""
            self.setCircularProgress()
        }
        self.hideCross()
    }
    
    /// This is used when user tapped on live agent button
    @IBAction func btnLiveAgentTapped(_ sender: UIButton) {
        if (self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAI || self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAINLU) {
            if genAISendMsgDelayCounter == 0 {
                self.startGenAISendMsgDelayTimer()
                self.liveAgentButtonClicked()
            }
        } else {
            self.liveAgentButtonClicked()
        }
    }
    
    private func liveAgentButtonClicked() {
        self.txtViewMessage.resignFirstResponder()
        self.handlePersistQuickReplyButtons()
        self.hideChoiceCardOptionsOfLastResponseBeforeSendingMessage()
        var message = MockMessage(text: self.viewModel.configIntegrationModel?.ixName ?? "", sender: Sender(id: VAConfigurations.userUUID, displayName: VAConfigurations.customData?.userName ?? ""), messageId: UUID().uuidString, date: Date())
        if self.viewModel.arrayOfMessages2D.count == 0 {
            message.messageSequance = 1
        } else {
            message.messageSequance = (self.viewModel.arrayOfMessages2D.last?.first?.messageSequance ?? 0)+1// self.viewModel.arrayOfMessages2D.count + 1
        }
        self.viewModel.arrayOfMessages2D.append([message])
        
        // let isTextFeedback = self.viewModel.messageData?.feedback?["text_feedback"] ?? false
        let isTextFeedback = self.viewModel.messageData?.feedback?["click_feedback"] ?? false
        self.reloadAndScrollToBottom(isAnimate: false, isFeedback: isTextFeedback)
        
        self.viewModel.messageData = nil
        self.viewModel.isFeedback = false
        
        self.sendDataToServer(data: self.viewModel.configIntegrationModel?.ixName ?? "", showLabelText: "", templateId: nil, isQuery: false, context: [], templateUid: self.viewModel.configIntegrationModel?.ixId ?? "", query: "", userMessageId: "", actualIntent: [], replyToMessage: [:], isPrompt: false, isAddContext: false, senderMessageType: SenderMessageType.text)
        // self.sendUserMessageToServer(data: self.viewModel.configIntegrationModel?.ix_name ?? "", showLabelText: "", template_id: nil, isQuery: false, context: [], template_uid: self.viewModel.configIntegrationModel?.ix_id ?? "", isAddContext: false)
        self.txtViewMessage.text = ""
        // Reset
        self.setCircularProgress()
    }
    
    /// This is used when user tapped on cancel button. This will be available when connect with agent
    @IBAction func btnCancelReplyTapped(_ sender: UIButton) {
        self.viewShowReplyMessage.isHidden = true
        self.viewModel.selectedMessageModelForReply = [:]
        
    }
    /// Speech to text
    @IBAction func speechToTextTapped(_ sender: UIButton) {
        if (self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAI || self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAINLU) {
            if genAISendMsgDelayCounter == 0 {
                self.takeUserInputFromMike()
            }
        } else {
            self.takeUserInputFromMike()
        }
    }
    private func takeUserInputFromMike() {
        if isListeningToSpeech {
            self.disableSpeechMode()
        } else {
            if SFSpeechRecognizer()?.isAvailable ?? false {
                self.checkSpeechPermissions()
            }
        }
    }
    /// Digital Signature
    @IBAction func uploadOptionButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            if !self.isNewGenAITheme && (self.viewModel.arrayOfMessages2D.last?.first?.location ?? false) {
                self.requestLocationPermissions()
            } else if self.isNewGenAITheme && (self.viewModel.arrayOfMessages2D.last?.count ?? 0) > 1 && (self.viewModel.arrayOfMessages2D.last?[1].location ?? false) {
                self.requestLocationPermissions()
            } else {
                self.showQRCodeScannerOptions()
            }
        })
    }
}

// MARK: - VAChatViewController extension
extension VAChatViewController {
    // MARK: - Handle Secure Message Button
    /// This function is used when user tapped on hide or show secure button
    /// - Parameter isSecure: Bool
    func handleSecureMessageButton(isSecure: Bool) {
        if isSecure {
            self.imgSecureMessage.image = UIImage(named: "secureShow", in: bundleObj, compatibleWith: nil)
            self.txtViewMessage.text = self.viewModel.textViewOriginalText
            self.viewModel.isSecured = false
        } else {
            self.imgSecureMessage.image = UIImage(named: "secureHide", in: bundleObj, compatibleWith: nil)
            self.txtViewMessage.text = String(repeating: "•", count: self.txtViewMessage.text.count)
            self.viewModel.isSecured = true
        }
    }
    
    func setMessageInputBarOnMessageGet() {
        self.showReset()
    }
    
    // MARK: - Show feedback input text bar
    func showFeedbackInputTextBar() {
        if isNewGenAITheme {
            if (self.viewModel.configurationModel?.result?.genAIThumbsFeedback ?? false) {
                let sender = Sender(id: self.viewModel.arrayOfMessages2D.last?.last?.sender.id ?? "", displayName: self.viewModel.arrayOfMessages2D.last?.last?.sender.displayName ?? "")
                var feedbackMsg = MockMessage(feedbackItem: "", sender: sender, messageId: UUID().uuidString, date: self.viewModel.arrayOfMessages2D.last?.last?.sentDate ?? Date())
                feedbackMsg.messageSequance = self.viewModel.arrayOfMessages2D.last?.last?.messageSequance ?? 1
                feedbackMsg.userMsgId = self.viewModel.arrayOfMessages2D.last?.last?.userMsgId
                self.viewModel.arrayOfMessages2D[self.viewModel.arrayOfMessages2D.count-1].append(feedbackMsg)
                self.chatTableView.beginUpdates()
                let section = self.viewModel.arrayOfMessages2D.count-1
                if var index = self.viewModel.arrayOfMessages2D.last?.count {
                    index = index-1
                    self.chatTableView.insertRows(at: [IndexPath(row: index, section: section)], with: .none)
                }
                self.chatTableView.endUpdates()
                self.scrollChatTableToBottom(isAnimate: false)
            }
        } else {
            showCross()
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                if self.viewSuggestions.isHidden == false {
                    self.viewSuggestions.isHidden = true
                    self.viewModel.arrayOfSuggestions.removeAll()
                    self.txtViewMessage.text = self.viewModel.feedbackPlaceholder
                    self.txtViewMessage.textColor = VAColorUtility.defaultThemeTextIconColor
                    self.txtViewMessage.resignFirstResponder()
                    self.setCircularProgress()
                }
            }
        }
    }
    
    // MARK: - Hide feedback input text bar
    func hideFeedbackInputTextBar() {
        hideCross()
    }
    
    // MARK: - Configure MessageInputBar
    func configureMessageInputBar() {
        self.viewTextInputSeperator.isHidden = isNewGenAITheme
        self.textInputStackLeading.constant = isNewGenAITheme ? 16 : 8
        self.textInputStackTrailing.constant = isNewGenAITheme ? 16 : 8
        self.textInputStack.layer.cornerRadius = isNewGenAITheme ? 22 : 0
        self.textInputStack.layer.borderWidth = isNewGenAITheme ? 1 : 0
        self.textInputStack.layer.borderColor = VAColorUtility.borderColor_NT.cgColor
        self.viewTextInput.layer.cornerRadius = isNewGenAITheme ? 0 : 8
        self.viewTextInput.layer.borderWidth = isNewGenAITheme ? 0 : 1
        self.viewRefreshLeading.constant = isNewGenAITheme ? 4 : 0
        self.sendMsgViewTrailing.constant = isNewGenAITheme ? 4 : 0
        self.txtViewMessage.font = isNewGenAITheme ? GenAIFonts().normal() : UIFont(name: fontName, size: defaultFontSize)
        self.txtViewMessage.text = self.viewModel.defaultPlaceholder
        self.txtViewMessage.textContainer.maximumNumberOfLines = isNewGenAITheme ? 10 : 1
        self.msgTextViewLeading.constant = isNewGenAITheme ? 2 : 8
        self.imgSendHeight.constant = isNewGenAITheme ? 13 : 18
        if self.isNewGenAITheme {
            self.imgSendCenterX.constant = -2
            self.sendMsgBgView.backgroundColor = VAColorUtility.lightSilver_NT
        }
        self.sendMsgBgView.isHidden = !self.isNewGenAITheme
        self.imgSend.image = UIImage(named: (isNewGenAITheme ? "sendMsg-NT" : "sendGrey"), in: bundleObj, with: nil)
        self.configureInputBarItems()
    }
    
    // MARK: - Configure InputBarItems
    private func configureInputBarItems() {
        setCircularProgress()
        setResetButton()
        manageResetButton()
        hideCross()
    }
    
    // MARK: - Set Circular Progress
    func setCircularProgress() {
        if circularProgress != nil {
            circularProgress?.progress = 0
            if isNewGenAITheme {
                self.sendMsgBgView.backgroundColor = VAColorUtility.lightSilver_NT
                self.adjustTextViewHeight()
            }
            self.imgSend.tintColor = isNewGenAITheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.defaultThemeTextIconColor
        } else {
            DispatchQueue.main.async {
                self.circularProgress = ProgressBarView(frame: self.btnSendMessage.bounds)
                self.circularProgress!.trackLyrLineWidth = self.isNewGenAITheme ? 2.0 : 1.0
                self.circularProgress!.trackClr = VAColorUtility.defaultThemeTextIconColor
                self.circularProgress!.progressClr = self.isNewGenAITheme ? VAColorUtility.defaultSenderBubbleColor : VAColorUtility.themeTextIconColor
                self.circularProgress!.isUserInteractionEnabled = false
                self.circularProgress!.backgroundColor = .clear
                self.btnSendMessage.addSubview(self.circularProgress!)
            }
        }
    }
    
    // MARK: - Set Reset Button
    func setResetButton() {
        if VAConfigurations.isChatTool {
            self.viewRefresh.isHidden = true
        } else {
            self.viewRefresh.isHidden = false
            self.btnRefresh.tintColor = self.viewModel.configIntegrationModel?.settings?.widgetTextColor?.hexToUIColor ?? .green
        }
    }
    
    // MARK: - Manage Reset Button
    func manageResetButton() {
        if !(self.viewModel.configurationModel?.result?.resetContext ?? false) || self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAI {
            hideReset()
        } else {
            showReset()
        }
    }
    
    // MARK: - Show and Hide Refresh Button
    func showReset() {
        if VAConfigurations.isChatTool {
            self.viewRefresh.isHidden = true
        } else {
            self.viewRefresh.isHidden = false
        }
        self.viewCross.isHidden = true
        if !txtViewMessage.isFirstResponder {
            self.txtViewMessage.text = self.viewModel.defaultPlaceholder
            self.txtViewMessage.textColor = VAColorUtility.defaultThemeTextIconColor
        }
        if isNewGenAITheme {
            self.msgTextViewLeading.constant = 2
        }
    }
    
    func hideReset() {
        self.viewRefresh.isHidden = true
        self.viewCross.isHidden = true
        self.viewModel.isResetTapped = true
        self.viewSuggestions.isHidden = true
        self.viewModel.arrayOfSuggestions.removeAll()
        self.searchedText = ""
        self.viewSecureMessage.isHidden = true
        self.viewSecureMsgWidthConstraint.constant = 0
        self.viewModel.isSecured = false
        self.txtViewMessage.resignFirstResponder()
        self.txtViewMessage.text = self.viewModel.defaultPlaceholder
        self.txtViewMessage.textColor = VAColorUtility.defaultThemeTextIconColor
        self.viewModel.isFeedback = false
        self.setCircularProgress()
        self.viewModel.messageData = nil
        self.hideUploadOptionsView()
        self.allowUserToType(isEnable: true)
        if isNewGenAITheme {
            self.msgTextViewLeading.constant = 16
        }
    }
    
    // MARK: - Show and Hide Cross Button
    func showCross() {
        DispatchQueue.main.async {
            self.txtViewMessage.endEditing(true)
            self.viewCross.isHidden = false
            self.viewRefresh.isHidden = true
            if self.txtViewMessage.isFirstResponder == false {
                self.txtViewMessage.text = self.viewModel.feedbackPlaceholder
                self.txtViewMessage.textColor = VAColorUtility.defaultThemeTextIconColor
                self.setCircularProgress()
            }
            self.viewModel.isFeedback = true
        }
    }
    
    func hideCross() {
        self.txtViewMessage.resignFirstResponder()
        self.viewCross.isHidden = true
        self.txtViewMessage.textColor = VAColorUtility.defaultThemeTextIconColor
        self.txtViewMessage.text = self.viewModel.defaultPlaceholder
        manageResetButton()
        self.viewModel.isFeedback = false
        self.setCircularProgress()
        self.checkAndDisableTypingIfRequired()
    }
    
    /// Close chatbot
    func closeChatbot() {
        // UIView.appearance().semanticContentAttribute = .forceLeftToRight
        UserDefaultsManager.shared.resetAllUserDefaults()
        VAConfigurations.virtualAssistant?.delegate?.didTapCloseChatbot()
        CustomLoader.hide()
        if self.parent?.parent == nil {
            self.dismiss(animated: false) {
            }
        } else {
            if self.parent?.children.count ?? 0 > 0 {
                let viewControllers: [UIViewController] = self.parent!.children
                for viewContoller in viewControllers {
                    viewContoller.willMove(toParent: nil)
                    viewContoller.view.removeFromSuperview()
                    viewContoller.removeFromParent()
                }
            }
        }
    }
    /// Handle unread messages count when chatbot is minimised
    func updateUnreadMsgsCount() {
        if self.newMessagesCount > 0 {
            if self.unreadMsgsView.isHidden {
                self.unreadMsgsView.isHidden = false
            }
            self.unreadMsgCountLabel.text = self.newMessagesCount > 9 ? "9+" : "\(self.newMessagesCount)"
            self.playNewMessageSound()
        } else {
            self.unreadMsgsView.isHidden = true
        }
    }
    
    // MARK: Show and Hide Upload Options Button
    func showUploadOptionsView() {
        self.uploadView.isHidden = false
        self.uploadViewWidthConstraint.constant = 30
        /*self.uploadImageView.transform = self.uploadImageView.transform.scaledBy(x: 0.5, y: 0.5)
         UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
         self.uploadImageView.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
         }) { success in
         self.uploadImageView.transform = CGAffineTransform.identity
         }*/
    }
    func hideUploadOptionsView() {
        self.uploadView.isHidden = true
        self.uploadViewWidthConstraint.constant = 0
    }
}

extension VAChatViewController {
    /// Sound is played when chat bot is minimised and new message arrives
    func playNewMessageSound() {
        let bundlePath = bundleObj
        guard let path = bundlePath.path(forResource: "new-message", ofType: "wav") else {
            return }
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

// MARK: - VAChatViewController extensiom for AgentTransferDelegate
extension VAChatViewController: AgentTransferDelegate {
    func backButtonTapped() {
        self.viewModel.isMessageTyping = false
        self.validateFeedbackOrChatTranscriptScreen()
    }
}

// MARK: - Send image message
extension VAChatViewController {
    func sendImageMessageToBot(image: UIImage, messageStr: String? = "", messageType: SenderMessageType) {
        var message = MockMessage(imageItem: ImageItem(url: "", isShowSenderIcon: true, image: image, message: messageType == .location ? messageStr : ""), sender: Sender(id: VAConfigurations.userUUID, displayName: VAConfigurations.customData?.userName ?? ""), messageId: UUID().uuidString, date: Date())
        message.sentiment = self.viewModel.messageData?.sentiment ?? 0
        message.masked = self.viewModel.messageData?.masked ?? nil
        if self.viewModel.arrayOfMessages2D.count == 0 {
            message.messageSequance = 1
        } else {
            message.messageSequance = (self.viewModel.arrayOfMessages2D.last?.first?.messageSequance ?? 0)+1
        }
        self.handlePersistQuickReplyButtons()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.viewModel.arrayOfMessages2D.append([message])
            self.reloadAndScrollToBottom(isAnimate: false, isFeedback: false)
        }
        self.sendDataToServer(data: messageStr ?? "", senderMessageType: messageType)
        // Reset
        self.setCircularProgress()
        if self.viewModel.isFeedback {
            self.hideFeedbackInputTextBar()
        } else {
            self.txtViewMessage.text = ""
            self.viewModel.textViewOriginalText = ""
            self.viewSecureMessage.isHidden = true
            self.viewSecureMsgWidthConstraint.constant = 0
        }
        if self.viewShowReplyMessage.isHidden == false {
            self.viewShowReplyMessage.isHidden = true
            self.viewModel.selectedMessageModelForReply = [:]
        }
        self.viewSuggestions.isHidden = true
        self.viewModel.arrayOfSuggestions.removeAll()
        self.searchedText = ""
        self.allowUserToType(isEnable: true)
    }
    
    func sendCustomFormDataToBot() {
        var formValues = ""
        var formValuesNewTheme: [[String:String]] = []
        let formData = self.viewModel.prechatForm?.settings?.props
        var valuesInserted = 0
        for index in 0..<(formData?.count ?? 0) {
            let inputName = formData?[index].inputName ?? ""
            let filtered = self.viewModel.prechatFormUserInputs?.filter({$0.key == inputName})
            if !(filtered?.isEmpty ?? true) {
                var input = ""
                valuesInserted += 1
                if !(filtered?.first?.value.isEmpty ?? true) {
                    if valuesInserted < (self.viewModel.prechatFormUserInputs?.count ?? 0) {
                        input = "<b>\(formData?[index].label ?? "")</b><br>\(filtered?.first?.value ?? "")<br><br>"
                        // input = "<b>\(formData?[index].label ?? "")</b><br>\(filtered?.first?.value ?? "")<br>----------------------------------<br>"
                    } else {
                        input = "<b>\(formData?[index].label ?? "")</b><br>\(filtered?.first?.value ?? "")"
                    }
                    if isNewGenAITheme {
                        formValuesNewTheme.append(["title": formData?[index].label ?? "", "desc": filtered?.first?.value ?? ""])
                    } else {
                        formValues.append(input)
                    }
                }
            }
        }
        if isNewGenAITheme {
            do {
                let data =  try JSONSerialization.data(withJSONObject:formValuesNewTheme, options: .prettyPrinted)
                formValues = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
            } catch {
                print(error.localizedDescription)
            }
        }
        var message = MockMessage(text: formValues.isEmpty ? "Form: No input provided" : formValues, isFormFields: true, sender: Sender(id: VAConfigurations.userUUID, displayName: VAConfigurations.customData?.userName ?? ""), messageId: UUID().uuidString, date: Date())
        
        message.sentiment = self.viewModel.messageData?.sentiment ?? 0
        message.masked = self.viewModel.messageData?.masked ?? nil
        if self.viewModel.arrayOfMessages2D.count == 0 {
            message.messageSequance = 1
        } else {
            message.messageSequance = (self.viewModel.arrayOfMessages2D.last?.first?.messageSequance ?? 0)+1
        }
        self.handlePersistQuickReplyButtons()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.viewModel.arrayOfMessages2D.append([message])
            self.reloadAndScrollToBottom(isAnimate: false, isFeedback: false)
        }
        if formValues.isEmpty {
            self.sendDataToServer(data: "customform", customFormValues: [:],senderMessageType: SenderMessageType.formFields)
        } else {
            self.sendDataToServer(data: "customform", customFormValues: self.viewModel.prechatFormUserInputs,senderMessageType: SenderMessageType.formFields)
        }
        // Reset
        self.setCircularProgress()
        if self.viewModel.isFeedback {
            self.hideFeedbackInputTextBar()
        } else {
            self.txtViewMessage.text = ""
            self.viewModel.textViewOriginalText = ""
            self.viewSecureMessage.isHidden = true
            self.viewSecureMsgWidthConstraint.constant = 0
        }
        if self.viewShowReplyMessage.isHidden == false {
            self.viewShowReplyMessage.isHidden = true
            self.viewModel.selectedMessageModelForReply = [:]
        }
        self.viewSuggestions.isHidden = true
        self.viewModel.arrayOfSuggestions.removeAll()
        self.searchedText = ""
        self.allowUserToType(isEnable: true)
    }
}
