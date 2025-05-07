//  ResponseMessage.swift
//  Copyright © 2024 Telus Digital. All rights reserved.

import Foundation
import UIKit

/// Bot response model
struct MessageData {
    var botId: Int?
    var contextLifeSpan: Int?
    var contexts: [Dictionary<String, Any>]?
    var feedback: [String: Bool]?
    var contextId: Int?
    var userMessageId: Int?
    var isPrompt: Bool?
    var sentiment: Int?
    var responseList: [MessageResponse] = []
    var userSessionId: String?
    var userDetails: [String: Any]?
    var intentName: String?
    var query: String?
    var replyIndex: Int?
    var userPrompt: [String: Any]?
    var intent: Int?
    var masked: Bool?
    var classified: Bool?
    var encrypted: Bool?
    var encryptionKey: String?
    var ssoType: String?
    var actualIntent: [Dictionary<String, Any>]?
    var optional: [String: Any]?
    var callTransfer: Bool = false
    var languageId: String = ""
    var iAgentHandoff: Bool?
    var allowSign: Bool = false
    var location: Bool = false
    var qrCode: Bool = false
    var isCustomFormInFlow: Bool = false
    var customForm: CustomForm? = nil

    init(messageData: NSDictionary) {
        if messageData["intent_name"] != nil {
            intentName = (messageData["intent_name"] as? String ?? "")
        }
        if messageData["masked"] != nil {
            masked = (messageData["masked"] as? Bool ?? false)
        }
        if messageData["encrypted"] != nil {
            encrypted = (messageData["encrypted"] as? Bool ?? false)
        }
        if messageData["encryption_key"] != nil {
            encryptionKey = messageData["encryption_key"] as? String ?? ""
        }
        if messageData["classified"] != nil {
            classified = (messageData["classified"] as? Bool ?? false)
        }
        if messageData["reply_index"] != nil {
            replyIndex = (messageData["reply_index"] as? Int ?? 0)
        }
        if messageData["user_prompt"] != nil {
            userPrompt = (messageData["user_prompt"] as? [String: Any] ?? [:])
        }
        if messageData["intent"] != nil {
            intent = (messageData["intent"] as? Int ?? 0)
        }
        if messageData["context_id"] != nil {
            contextId = (messageData["context_id"] as? Int ?? 0)
        }
        if messageData["user_message_id"] != nil {
            if messageData["user_message_id"] is NSNull {
                userMessageId = 0
            } else {
                if let id = messageData["user_message_id"] as? Int {
                    userMessageId = id
                } else {
                    userMessageId = Int(messageData["user_message_id"] as? String ?? "0")
                }
            }
        }
        if messageData["actual_intent"] != nil {
            actualIntent = (messageData["actual_intent"] as? [Dictionary<String, Any>] ?? [[:]])
        }
        if messageData["sentiment"] != nil {
            if messageData["sentiment"] is NSNull {
                sentiment = 0
            } else {
                sentiment = (messageData["sentiment"] as? Int ?? 0)
            }
        }
        if messageData["Bot_Id"] != nil {
            botId = (messageData["Bot_Id"] as? Int ?? 0)
        }
        if messageData["context_life_span"] != nil {
            if messageData["context_life_span"] is NSNull {
                contextLifeSpan = 0
            } else {
                contextLifeSpan = (messageData["context_life_span"] as? Int ?? 0)
            }
        }
        if messageData["contexts"] != nil {
            contexts = (messageData["contexts"] as? [Dictionary<String, Any>] ?? [[:]])
        }
        if messageData["feedback"] != nil {
            feedback = (messageData["feedback"] as? [String: Bool] ?? [:])
        }
        if messageData["is_prompt"] != nil {
            isPrompt = (messageData["is_prompt"] as? Bool ?? false)
        }
        if messageData["user_session_id"] != nil {
            userSessionId = messageData["user_session_id"] as? String ?? ""
        }
        if messageData["response_list"] != nil {
            if let respList = messageData["response_list"] as? [NSDictionary] {
                for response in respList {
                    var resp = response as? [String: Any]
                    resp?["sso_type"] = ""
                    if let ssoType = messageData["sso_type"] as? String {
                        resp?["sso_type"] = ssoType
                    }
                    responseList.append(MessageResponse(resp! as NSDictionary))
                }
            }
        }

        if let ssoType = messageData["sso_type"] as? String {
            self.ssoType = ssoType
        } else {
            ssoType = ""
        }
        if let queryString = messageData["query"] as? String {
            query = queryString
        } else {
            query = ""
        }
        if let optionalDict = messageData["optional"] as? [String: Any] {
            optional = optionalDict
        } else {
            optional = [:]
        }
        if let callTransfer = messageData["call_transfer"] as? Bool {
            self.callTransfer = callTransfer
        } else {
            self.callTransfer = false
        }
        if messageData["language_id"] != nil {
            languageId = (messageData["language_id"] as? String ?? "en")
        }
        iAgentHandoff = nil
        if messageData["i_agent_handoff"] != nil {
            iAgentHandoff = (messageData["i_agent_handoff"] as? Bool ?? nil)
        }
        if let value = messageData["allow_sign"] as? Bool {
            allowSign = value
        } else {
            allowSign = false
        }
        if let value = messageData["location"] as? Bool {
            location = value
        } else {
            location = false
        }
        if let value = messageData["qr_code"] as? Bool {
            qrCode = value
        } else {
            qrCode = false
        }
        if let value = messageData["custom_form"] as? Bool {
            isCustomFormInFlow = value
        } else {
            isCustomFormInFlow = false
        }
        if isCustomFormInFlow {
            if let jsonData = try? JSONSerialization.data(withJSONObject:messageData["custom_form_detail"] ?? [:]) {
                self.customForm = try? JSONDecoder().decode(CustomForm.self, from: jsonData)
            }
        }
    }
}

struct MessageResponse {
    let delay: Int?
    var quickReply: QuickReply?
    var carousalArray: [Carousal] = []
    var botAnswers: [String]?
    let responseType: String
    var prop: PropItem?
    let multiSelect: Bool?
    var multiOps: MultiOps?
    var context: [Dictionary<String, Any>] = []
    var ssoType: String?
    var botId: Int?
    var headers: [String: Any] = [:]
    var method: String = ""
    var password: String = ""
    var payload: [String: Any] = [:]
    var platformType: String = ""
    var title: String = ""
    var transferType: String = ""
    var uid: String = ""
    var url: String = ""
    var userSessionId: String = ""
    var username: String = ""
    var validRetry: Bool = false
    var preventTyping: Bool = false
    var citations: [Dictionary<String, Any>] = []

    init(_ dictionary: NSDictionary) {
        if let delayCount = dictionary["delay"] as? Int {
            delay = delayCount
        } else {
            delay = 0
        }

        if let multiSelect = dictionary["multi_select"] as? Bool {
            self.multiSelect = multiSelect
        } else {
            multiSelect = false
        }

        self.responseType = dictionary["response_type"] as? String ?? ""
        if self.responseType == "text" {
            self.botAnswers = dictionary["response"] as? [String]
            if let citations = dictionary["citation"] as? [Dictionary<String, Any>] {
                self.citations = citations
            }
        }
        if self.responseType == "image" || self.responseType == "url" || self.responseType == "video" {
            self.botAnswers = dictionary["response"] as? [String]
        } else if self.responseType == "quick_reply" {
            self.quickReply = QuickReply(dictionary)
        } else if self.responseType == "props" {
            self.prop = PropItem(dictionary["response"] as? NSDictionary ?? [:])
        } else if self.responseType == "carousel" {
            self.carousalArray.append(Carousal(dictionary["response"] as? [NSDictionary] ?? []))
        } else if self.responseType == "multi_ops" {
            multiOps = MultiOps(dictionary["response"] as? NSDictionary ?? [:])
        } else if self.responseType == "call_transfer" {

            if let responseDict = dictionary["response"] as? NSDictionary {
                if let botId = responseDict["bot_id"] as? Int {
                    self.botId = botId
                } else {
                    self.botId = nil
                }

                if let header = responseDict["headers"] as? [String: Any] {
                    self.headers = header
                } else {
                    self.headers = [:]
                }

                if let pass = responseDict["password"] as? String {
                    self.password = pass
                } else {
                    self.password = ""
                }

                if let payloadDict = responseDict["payload"] as? [String: Any] {
                    self.payload = payloadDict
                } else {
                    self.payload = [:]
                }

                if let platformType = responseDict["platform_type"] as? String {
                    self.platformType = platformType
                } else {
                    self.platformType = ""
                }

                if let title = responseDict["title"] as? String {
                    self.title = title
                } else {
                    self.title = ""
                }

                if let transferType = responseDict["transfer_type"] as? String {
                    self.transferType = transferType
                } else {
                    self.transferType = ""
                }

                if let uid = responseDict["uid"] as? String {
                    self.uid = uid
                } else {
                    self.uid = ""
                }

                if let url = responseDict["url"] as? String {
                    self.url = url
                } else {
                    self.url = ""
                }

                if let userSessionId = responseDict["user_session_id"] as? String {
                    self.userSessionId = userSessionId
                } else {
                    self.userSessionId = ""
                }

                if let username = responseDict["username"] as? String {
                    self.username = username
                } else {
                    self.username = ""
                }

                if let validRetry = responseDict["valid_retry"] as? Bool {
                    self.validRetry = validRetry
                } else {
                    self.validRetry = false
                }
            } else {}
        }
        self.ssoType = dictionary["sso_type"] as? String

        if let disableTyping = dictionary["prevent_typing"] as? Bool {
            preventTyping = disableTyping
        } else {
            preventTyping = false
        }
    }
}

struct PropItem: Equatable {
    let onesource: String
    let validRetry: Int

    init(_ dictionary: NSDictionary) {
        self.onesource = dictionary["onesource"] as? String ?? ""
        self.validRetry = dictionary["valid_retry"] as? Int ?? 0
    }
}

struct QuickReply {
    var title: String = ""
    var attributedTitle: NSMutableAttributedString?
    var ssoButton: BotQRButton?
    var otherButtons: [BotQRButton] = []
    var ssoType: String = ""

    init(_ dictionary: NSDictionary) {
        self.title = dictionary["text"] as? String ?? ""
        self.ssoType = dictionary["sso_type"] as? String ?? ""
        let qrButtons = dictionary["response"] as? [NSDictionary] ?? []
        let sso = qrButtons.filter({$0["type"] as? String ?? "" == "sso"})
        self.attributedTitle = createNormalAttributedString(text: dictionary["text"] as? String ?? "", isNewGenAITheme: false)
        if sso.count > 0 {
            ssoButton = BotQRButton(sso.first!)
        }
        for button in qrButtons {
            if button["type"] as? String != "sso" {
                otherButtons.append(BotQRButton(button))
            }
        }
    }
}

struct BotQRButton {
    var text: String
    var data: String
    var templateId: String
    var type: String
    var attributedText: NSMutableAttributedString?
    var isButtonClicked: Bool = false
    init(_ dictionary: NSDictionary) {
        self.text = dictionary["button_text"] as? String ?? ""
        self.data = "\(dictionary["data"] ?? "")"
        self.templateId = "\(dictionary["template_id"] ?? "")"
        self.type = dictionary["type"] as? String ?? ""
        self.attributedText = createNormalAttributedString(text: dictionary["button_text"] as? String ?? "", isNewGenAITheme: false)
    }
}

struct URLItem {
    let title: String
    var isShowSenderIcon: Bool = true

    init(title: String, isShowSenderIcon: Bool) {
        self.title = title
        self.isShowSenderIcon = isShowSenderIcon
    }
}

struct TextItem {
    let title: String
    var attributedText: NSMutableAttributedString?
    var isShowSenderIcon: Bool = true
    var source: PropItem?
    var citations: [CitationObject]?
    init(title: String, isShowSenderIcon: Bool, source: PropItem?, citations: [CitationObject]?, isNewGenAITheme: Bool = false) {
        self.title = title
        self.isShowSenderIcon = isShowSenderIcon
        self.source = source
        self.attributedText = isHTMLText(title) ? createAttributedString(text: title, isNewGenAITheme: isNewGenAITheme) : createNormalAttributedString(text: title, isNewGenAITheme: isNewGenAITheme)
        self.citations = citations
    }
}

struct ImageItem {
    var url: String
    var isShowSenderIcon: Bool = true
    var image: UIImage? = nil
    var message: String? = ""
    var imageWidth: CGFloat = 0.0
    var imageHeight: CGFloat = 0.0
    init(url: String, isShowSenderIcon: Bool, image: UIImage? = nil, message: String? = nil, imageWidth: CGFloat = 0, imageHeight: CGFloat = 0) {
        self.url = url
        self.isShowSenderIcon = isShowSenderIcon
        self.image = image
        self.message = message
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
    }
}

/// A protocol used to represent the data for a media message.
struct VideoItem {
    var urlStr: String
}

struct Citations {
    var citations: [CitationObject] = []
    init(_ citationArray: [NSDictionary]) {
        for citation in citationArray {
            citations.append(CitationObject(citation))
        }
    }
}
struct CitationObject {
    let title: String
    let url: String
    init(_ dictionary: NSDictionary) {
        self.title = dictionary["title"] as? String ?? ""
        self.url = dictionary["url"] as? String ?? ""
    }
}

struct Carousal {
    var carouselObjects: [CarousalObject] = []
    init(_ carouselObjectArray: [NSDictionary]) {
        for carouselObj in carouselObjectArray {
            carouselObjects.append(CarousalObject(carouselObj))
        }
    }
}

struct CarousalObject {
    let image: String
    let text: String
    var attributedTitle: NSMutableAttributedString?
    var options: [Option] = []

    init(_ dictionary: NSDictionary) {
        self.text = dictionary["text"] as? String ?? ""
        self.attributedTitle = createNormalAttributedString(text: dictionary["text"] as? String ?? "", isNewGenAITheme: false)
        self.image = dictionary["image"] as? String ?? ""
        if let options = dictionary["options"] as? [NSDictionary] {
            for option in options {
                self.options.append(Option(option))
            }
        }
    }
}

struct Option {
    let data: String
    let label: String
    var attributedTitle: NSMutableAttributedString?
    let uId: String
    let type: String
    var isButtonClicked: Bool = false
    init(_ dictionary: NSDictionary) {
        self.label = dictionary["label"] as? String ?? ""
        self.attributedTitle = createNormalAttributedString(text: dictionary["label"] as? String ?? "", isNewGenAITheme: false)
        if let data = dictionary["data"] as? String {
            self.data = data
        } else {
            self.data = "\(dictionary["data"] as? Int ?? 0)"
        }
        self.uId = dictionary["uid"] as? String ?? ""
        self.type = dictionary["type"] as? String ?? ""
    }
}

struct MultiOps {
    var choices: [Choice] = []
    var options: [Option] = []
    let text: String
    let validRetry: Int?
    let optionsLimit: Int?
    let allowSkip: Bool?
    let askFollowUp: Bool?
    let followUp: String?
    let followUpCount: Int?
    let userSessionId: String?
    var attributedTitle: NSMutableAttributedString?

    init(_ dictionary: NSDictionary) {
        self.text = dictionary["text"] as? String ?? ""
        self.attributedTitle = createNormalAttributedString(text: dictionary["text"] as? String ?? "", isNewGenAITheme: false)

        if let validEntry = dictionary["valid_retry"] as? Int {
            validRetry = validEntry
        } else {
            validRetry = nil
        }

        if let optionArray = dictionary["options"] as? [NSDictionary] {
            for option in optionArray {
                self.options.append(Option(option))
            }
        }
        if let choices = dictionary["choices"] as? [NSDictionary] {
            for choice in choices {
                self.choices.append(Choice(choice))
            }
        }

        if let limit = dictionary["options_limit"] as? Int {
            optionsLimit = limit
        } else {
            optionsLimit = nil
        }

        if let skip = dictionary["allow_skip"] as? Bool {
            allowSkip = skip
        } else {
            allowSkip = false
        }

        if let askFollow = dictionary["ask_follow_up"] as? Bool {
            askFollowUp = askFollow
        } else {
            askFollowUp = false
        }

        if let followCount = dictionary["follow_up_count"] as? Int {
            followUpCount = followCount
        } else {
            followUpCount = nil
        }

        if let sessionId = dictionary["user_session_id"] as? String {
            userSessionId = sessionId
        } else {
            userSessionId = ""
        }

        if let followUp = dictionary["follow_up"] as? String {
            self.followUp = followUp
        } else {
            followUp = ""
        }
    }
}

struct Choice: Codable {
    let label: String
    let value: String
    var isSelected: Bool = false

    init(_ dictionary: NSDictionary) {
        self.label = dictionary["label"] as? String ?? ""
        if let val = dictionary["value"] as? String {
            self.value = val
        } else if let val2 = dictionary["value"] as? Int {
            self.value = "\(val2)"
        } else {
            self.value = ""
        }
    }
}

struct AgentTextItem {
    let agentName: String
    let message: String
    let doNotRespond: Bool
}

struct AgentStatusItem {
    let agentName: String
    let status: String
}
