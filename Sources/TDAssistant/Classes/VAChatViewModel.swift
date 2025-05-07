// VAChatViewModel.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import Foundation
import UIKit

enum CallTransferType {
    case genesys
    case genesysInternal
    case tids
    case oracle
    case CC360
    case none
}// seamless transfer, internal

enum UserStatus {
    case active
    case inactive
    case close
}

enum UserTypingStatus {
    case typing
    case paused
}

enum AgentCallTransferState: String {
    case agentJoin = "join"
    case agentUnJoin = "unjoin"
    case none = "none"
}

enum AgentCallTransferTypingState {
    case composing
    case paused
    case delivered
    case none
}

struct TIDSModel {
    var agentJoinStatus: AgentCallTransferState = .agentUnJoin
    var typingStatus: AgentCallTransferTypingState = .none
    var agentName: String = ""
}

enum SenderMessageType {
    case text
    case signature
    case location
    case qrCode
    case formFields
}

struct PreChatFormFieldType {
    static let textField = "Text"
    static let textView = "Textarea"
    static let dropDown = "Dropdown"
}

struct NLUTypes {
    static let GenAI = "genAi"
    static let GenAINLU = "genAiNlu"
    static let Snips = "snips"
    static let XavNLU = "xavnlu"
}

class VAChatViewModel {

    // Constants and Varibles
    var configIntegrationModel: VAConfigIntegration?
    var configurationModel: VAConfigurationModel?

    var arrayOfMessages2D: [[MockMessage]] = []
    var arrayOfSuggestions: [Suggestion] = []
    var arrayOfOptions: [String] = [] // Header Options
    var messageData: MessageData?

    var isMessageTyping: Bool = true
    var isSSO: Int = 0
    var ssoSessionId: String = ""

    var isResetTapped: Bool = false
    var isFeedback: Bool = false
    var isFeedbackGivenByUser: Bool = false
    var isThumbFeedback: Bool = false
    var isThumbsUp: Bool = true
    var maxCharacterLength: Int = 250
    var feedbackMaxCharacterLength: Int = 500

    var textViewOriginalText: String = ""

    var isSecured: Bool = true

    var defaultPlaceholder = LanguageManager.shared.localizedString(forKey: "Ask me something")
    var feedbackPlaceholder = LanguageManager.shared.localizedString(forKey: "Want to share feedback?")
    var settingPlaceholder = LanguageManager.shared.localizedString(forKey: "Settings")
    var privacyPolicyPlaceholder = LanguageManager.shared.localizedString(forKey: "Privacy Policy")

    var isChatToolWaitingForAgent: Bool = false
    var isQueueBannerForOracle: Bool = false

    var isCallTransfer: Bool = false
    var callTransferType: CallTransferType = .none

    var oracleContext: [Dictionary<String, Any>] = []
    var oracleMetaData: [String: Any] = [:]

    var TIDSCallTransferModel: TIDSModel = TIDSModel(agentJoinStatus: .none,
                                                            typingStatus: .none,
                                                            agentName: "")

    var lastMessageCDATA: String = ""

    var selectedMessageModelForReply: [String: Any] = [:]
    var isButtonClickEnabled: Bool = true
    var autoDetectedLanguageId: String = ""

    // UnreadMessage
    var showUnreadCount: Bool = false
    var unreadCount: Double = 0
    var unreadMessageIndexPath: IndexPath?
    var messageFromAgentChatTool: String = ""

    var waitingForAgentIndexPath: IndexPath?
    var isRequestingNewSession: Bool = false
    var isPokedByAgent: Bool = false
    var isAgentAcceptedCC360CallTransfer: Bool = false
    var isChatToolChatClosed: Bool = false
    var isAgentConnectedToChat: Bool = false
    // Api Response Closures
    var onSuccessResponseConfigApi: (() -> Void) = {}
    var onSuccessResponseSuggestionApi: ((_ searchedText: String) -> Void) = {_ in }
    var onFailureResponseConfigApi: ((_ errorMessage: String, _ isRetry: Bool) -> Void) = {_, _  in}
    var onFailureResponseSuggestionApi: ((_ errorMessage: String) -> Void) = {_ in}
    var noInternetConnection: (() -> Void) = {}
    var isXMPPStreamConnectionError: Bool = false
    var sessionStartMsg: Int = 0
    var prechatForm: CustomForm?
    var prechatFormUserInputs: [String:String]? = [:]
    // end

    // Initilizer
    init() {
        self.arrayOfSuggestions = []
        self.arrayOfMessages2D = []
    }
    // end

    /// This function is used to update VAConfigurations with VAConfigurationModel
    /// - Parameter model: VAConfigurationModel
    private func updateVAConfigurationModel(with model: VAConfigurationModel) {
        VAConfigurations.vHost = model.result?.vhost ?? ""
        VAConfigurations.botName = model.result?.name ?? ""

        VAConfigurations.arrayOfLanguages = model.result?.language ?? []
        let userSelectedLanguage  = VAConfigurations.getCurrentLanguageCode()
        let engLangCode = LanguageConfiguration.english.rawValue
        let engLangModel = model.result?.language?.filter({ $0.lang?.lowercased() == engLangCode })
        if userSelectedLanguage == "" {
            if engLangModel?.isEmpty ?? true {
                VAConfigurations.language = LanguageConfiguration(rawValue: model.result?.language?.first?.lang ?? "")
            } else {
                VAConfigurations.language = .english
            }
            UserDefaultsManager.shared.setBotLanguage(VAConfigurations.language?.rawValue ?? "")
        } else {
            let userSelectedLangModel = model.result?.language?.filter({ $0.lang?.lowercased() == userSelectedLanguage })
            if userSelectedLangModel?.isEmpty ?? true {
                if engLangModel?.isEmpty ?? true {
                    VAConfigurations.language = LanguageConfiguration(rawValue: model.result?.language?.first?.lang ?? "")
                } else {
                    VAConfigurations.language = .english
                }
            }
            UserDefaultsManager.shared.setBotLanguage(VAConfigurations.language?.rawValue ?? "")
        }
    }

    // MARK: - Check for option view
    /// This function is used to check the Options i.e Setting and Privacy Policy
    /// - Returns: Bool
    func checkForOptionsViewVisiblity() -> Bool {
        var arrayOfOptions: [String] = []
        var isOptionsViewVisible: Bool = false
        let settingVisiblity = self.configIntegrationModel?.settingVisiblity ?? false
        let privacyVisiblity = self.configIntegrationModel?.privacyVisiblity ?? false
        if settingVisiblity == false && privacyVisiblity == false {
            arrayOfOptions = []
            isOptionsViewVisible = false
        } else if settingVisiblity == true && privacyVisiblity == true {
            arrayOfOptions = [settingPlaceholder, privacyPolicyPlaceholder]
            isOptionsViewVisible = true
        } else if settingVisiblity == true && privacyVisiblity == false {
            arrayOfOptions = [settingPlaceholder]
            isOptionsViewVisible = true
        } else {
            arrayOfOptions = [privacyPolicyPlaceholder]
            isOptionsViewVisible = true
        }
        self.arrayOfOptions = arrayOfOptions
        return !isOptionsViewVisible
    }
    // end

    // MARK: - configuration API
    /// This function is used to get the configuration from server
    func callGetConfigurationApi() {
        APIManager.sharedInstance.getConfiguration(successBlock: { (data) in
            if let configData = data {
                // Update VAConfigurations Model
                self.updateVAConfigurationModel(with: configData)

                self.configurationModel = configData
                self.prechatForm = configData.result?.customForm
                if configData.result?.integration?.count ?? 0 > 0 {
                    self.configIntegrationModel = configData.result?.integration![0]

                    // Update Color Utility
                    VAColorUtility.initWithConfigurationData(model: self.configIntegrationModel)

                    DispatchQueue.main.async { // Correct
                        // call success completion handler
                        self.onSuccessResponseConfigApi()
                    }
                } else {
                    DispatchQueue.main.async {
                        // call failure completion handler
                        self.onFailureResponseConfigApi(LanguageManager.shared.localizedString(forKey: "Oops, this service is temporarily unavailable"), false)
                    }
                }
            }
        }) { (_, retry)  in
            DispatchQueue.main.async {
                // call failure completion handler
                self.onFailureResponseConfigApi(LanguageManager.shared.localizedString(forKey: "Oops, this service is temporarily unavailable"), retry)
            }
        }
    }

    // MARK: - Suggestion API
    /// This function is used to call the suggestion api
    /// - Parameter txt: String
    func callSuggestionsAPI(txt: String) {
        var intent: Int = 0

        /// update itent if isReset button not tapped
        if self.isResetTapped == false {
            intent = self.messageData?.intent ?? 0
        }
        let langCode = self.configurationModel?.result?.autoLangDetection == false ? VAConfigurations.getCurrentLanguageCode() : (self.autoDetectedLanguageId == "" ? VAConfigurations.getCurrentLanguageCode() : self.autoDetectedLanguageId)
        /// api call
        let service = configurationModel?.result?.nluService ?? ""
        APIManager.sharedInstance.getSuggestion(service: service, text: txt, contextId: intent, languageCode: langCode, successBlock: { (data) in
            if let configData = data {
                // update array
                self.arrayOfSuggestions = configData
                DispatchQueue.main.async {
                    // call success completion handler
                    self.onSuccessResponseSuggestionApi(txt)
                }
            }
        }) { (_) in
            // no need to handle
        }
    }
}
