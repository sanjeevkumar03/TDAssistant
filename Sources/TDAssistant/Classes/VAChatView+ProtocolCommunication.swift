//  VAChatView+ProtocolCommunication.swift
//  Copyright © 2024 Telus Digital. All rights reserved.

import Foundation
import XMPPFramework
import UIKit

extension VAChatViewController {
    func sendWelcomeToServer(query: String) {
        debugPrint("sendWelcomeToServer called")
        var arrayOfDictionaries = ["log": "true",
                                   "form_type": "click",
                                   "msg": "GETWELCOMEMESSAGE",
                                   "welcome_msg_check": true,
                                   "bot_id": VAConfigurations.botId,
                                   "bot_name": "\(VAConfigurations.botName)",
                                   "language_id": "\(VAConfigurations.getCurrentLanguageCode())",
                                   "template_id": 0,
                                   "context_id": 0,
                                   "nlu_service": self.viewModel.configurationModel?.result?.nluService ?? "",
                                   "is_typed": false,
                                   "sentiment": 0,
                                   "context_life_span": 0,
                                   "parentHost": VAConfigurations.parentHost,
                                   "internalHost": VAConfigurations.parentHost,
                                   "channel": "mobile",
                                   "device": "mobile",
                                   "version": UIDevice.current.systemVersion,
                                   "os": "iOS",
                                   "ip": self.viewModel.configurationModel?.meta?.ip ?? "",
                                   "browser": "iOS App"] as [String: Any]

        if self.viewModel.isSSO == 1 {
            arrayOfDictionaries["authorized"] = true
            let isOneLoginSSO = self.viewModel.configurationModel?.result?.ssoType == SSOType.oneLogin ? true : false
            let ssoUrl = getSSORedirectURL(ssoAuthUrl: self.viewModel.configurationModel?.result?.ssoAuthUrl ?? "", isOneLoginSSO: isOneLoginSSO, isAuthorisationOnStartup: true, isGroupSSO: VAConfigurations.customData?.isGroupSSO ?? false).components(separatedBy: "&state=").first
            arrayOfDictionaries["SSO_auth_url"] = ssoUrl ?? ""
            arrayOfDictionaries["msg_session"] = self.viewModel.ssoSessionId
            self.viewModel.isSSO = 0
        } else {
            arrayOfDictionaries["authorized"] = false
        }
        // Custom Data
        /// display name of the user, if displayName is not provided we are using priority (tid(Telus ID)/email/phone/username) as displayName in our code. tid-user will pass in prechat if required
        let displayName = VAConfigurations.customData?.displayName == "" ? VAConfigurations.userUUID : VAConfigurations.customData?.displayName
        arrayOfDictionaries["displayName"] = displayName
        if VAConfigurations.customData?.userName.isEmpty ?? true == false {
            arrayOfDictionaries["username"] = VAConfigurations.customData?.userName
        }
        if VAConfigurations.customData?.email.isEmpty ?? true == false {
            arrayOfDictionaries["email"] = VAConfigurations.customData?.email
        }
        if VAConfigurations.customData?.phone.isEmpty ?? true == false {
            arrayOfDictionaries["phone"] = VAConfigurations.customData?.phone
        }
        if VAConfigurations.customData?.tid.isEmpty ?? true == false {
            arrayOfDictionaries["tid"] = VAConfigurations.customData?.tid
        }
        if VAConfigurations.customData?.businessDomain.isEmpty ?? true == false {
            arrayOfDictionaries["businessDomain"] = VAConfigurations.customData?.businessDomain
        }
        if VAConfigurations.customData?.brand.isEmpty ?? true == false {
            arrayOfDictionaries["brand"] = VAConfigurations.customData?.brand
        }
        if VAConfigurations.customData?.productType.isEmpty ?? true == false {
            arrayOfDictionaries["productType"] = VAConfigurations.customData?.productType
        }
        if let language = VAConfigurations.customData?.language?.rawValue {
            arrayOfDictionaries["language"] = language
        }
        for (key, value) in VAConfigurations.customData?.extraData ?? [:] {
            arrayOfDictionaries["\(key)"] = "\(value)"
        }
        /// Prechat form data
        if let preChatInputs = self.viewModel.prechatFormUserInputs {
            for (key, value) in preChatInputs {
                if !value.isEmpty {
                    arrayOfDictionaries["\(key)"] = "\(value)"
                }
            }
            self.viewModel.prechatFormUserInputs = [:]
        }
        ///System selected timezone and timezoneOffset has more priority  then picked from prechat form
        arrayOfDictionaries["timezoneOffset"] = TimeZone.current.offsetInMinutes()
        arrayOfDictionaries["timezone"] = TimeZone.current.identifier
        
        self.viewModel.isResetTapped = false
        if !(query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            arrayOfDictionaries["text"] = query
        }
        CustomLoader.hide()
        ///Showing typing status when welcome message is sent
        self.imgViewTyping.isHidden = false
        self.createRequestForServer(arrayOfDictionaries: arrayOfDictionaries, isWelcomeMsg: true)
    }

    func sendDataToServer(data: String, showLabelText: String = "", templateId: Int? = 0, isQuery: Bool = false,
                          context: [Dictionary<String, Any>] = [], templateUid: String = "", query: String = "",
                          userMessageId: String = "", actualIntent: [Dictionary<String, Any>] = [],
                          replyToMessage: [String: Any] = [:], isPrompt: Bool = true, isAddContext: Bool = true, customFormValues: [String:String]? = nil, senderMessageType: SenderMessageType) {
        debugPrint("Is XMPP Connected: \(xmppController.xmppStream.isConnected)")
        if xmppController.xmppStream.isDisconnected {
            try? xmppController.xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)

            DispatchQueue.main.asyncAfter(deadline: .now()+3.0) {
                self.sendUserMessageToServer(data: data, showLabelText: showLabelText, templateId: templateId, isQuery: isQuery, context: context, templateUid: templateUid, query: query, userMessageId: userMessageId, actualIntent: actualIntent, replyToMessage: replyToMessage, isPrompt: isPrompt, isAddContext: isAddContext, customFormValues: customFormValues, senderMessageType: senderMessageType)
            }
        } else {
            if xmppController.xmppStream.isAuthenticated {
                self.sendUserMessageToServer(data: data, showLabelText: showLabelText, templateId: templateId, isQuery: isQuery, context: context, templateUid: templateUid, query: query, userMessageId: userMessageId, actualIntent: actualIntent, replyToMessage: replyToMessage, isPrompt: isPrompt, isAddContext: isAddContext, customFormValues: customFormValues, senderMessageType: senderMessageType)
            } else {
                try? xmppController.xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
                DispatchQueue.main.asyncAfter(deadline: .now()+3.0) {
                    self.sendUserMessageToServer(data: data, showLabelText: showLabelText, templateId: templateId, isQuery: isQuery, context: context, templateUid: templateUid, query: query, userMessageId: userMessageId, actualIntent: actualIntent, replyToMessage: replyToMessage, isPrompt: isPrompt, isAddContext: isAddContext, customFormValues: customFormValues, senderMessageType: senderMessageType)
                }
            }
        }
    }

    func sendUserMessageToServer(data: String, showLabelText: String = "", templateId: Int? = 0, isQuery: Bool = false,
                                 context: [Dictionary<String, Any>] = [], templateUid: String = "", query: String = "",
                                 userMessageId: String = "", actualIntent: [Dictionary<String, Any>] = [],
                                 replyToMessage: [String: Any] = [:], isPrompt: Bool? = true,
                                 isAddContext: Bool = true, customFormValues: [String:String]? = nil, senderMessageType: SenderMessageType) {
        if (!VAConfigurations.isChatbotMinimized && self.imgViewTyping.isHidden) && self.viewQueue.isHidden {
            self.imgViewTyping.isHidden = isNewGenAITheme && self.viewModel.isFeedbackGivenByUser
        }
        self.viewLiveAgent.isUserInteractionEnabled = false
        self.allowUserActivity = false
        var inputStr = data
        if self.viewModel.messageData?.encrypted == true {
            inputStr = self.getEcryptedText(inputText: inputStr)
        }
        let languageCode = self.viewModel.configurationModel?.result?.autoLangDetection == false ? VAConfigurations.getCurrentLanguageCode() : (self.viewModel.autoDetectedLanguageId == "" ? VAConfigurations.getCurrentLanguageCode() : self.viewModel.autoDetectedLanguageId)
        var arrayOfDictionaries = ["log": "true",
                                   "form_type": "click",
                                   "timezoneOffset": TimeZone.current.offsetInMinutes(),
                                   "timezone": TimeZone.current.identifier,
                                   "msg": inputStr,
                                   "text": inputStr,
                                   "bot_id": "\(VAConfigurations.botId)",
                                   "bot_name": self.viewModel.configurationModel?.result?.name ?? "",
                                   "language_id": "\(languageCode)",
                                   "context_life_span": self.viewModel.messageData?.contextLifeSpan ?? 0,
                                   "user_session_id": self.viewModel.messageData?.userSessionId ?? "",
                                   "sentiment": self.viewModel.messageData?.sentiment ?? 0,
                                   "nlu_service": self.viewModel.configurationModel?.result?.nluService ?? "",
                                   "channel": "mobile",
                                   "device": "mobile",
                                   "version": UIDevice.current.systemVersion,
                                   "os": "iOS"] as [String: Any]
        if isQuery == false {
            arrayOfDictionaries["template_id"] = templateId ?? 0
        }
        if isAddContext {
            if context.isEmpty {
                arrayOfDictionaries["contexts"] = self.viewModel.messageData?.contexts ?? []
            } else {
                arrayOfDictionaries["contexts"] = context
            }
        }

        if self.viewModel.messageData?.contextId != 0 && self.viewModel.messageData?.contextId != nil {
            arrayOfDictionaries["context_id"] = self.viewModel.messageData?.contextId ?? ""
        }

        if self.viewModel.messageData?.isPrompt == true && self.viewModel.isResetTapped == false {
            arrayOfDictionaries["intent"] = self.viewModel.messageData?.intent
            arrayOfDictionaries["intent_name"] = self.viewModel.messageData?.intentName
            arrayOfDictionaries["reply_index"] = self.viewModel.messageData?.replyIndex
            arrayOfDictionaries["user_prompt"] = self.viewModel.messageData?.userPrompt
            arrayOfDictionaries["query"] = self.viewModel.messageData?.query
            arrayOfDictionaries["is_prompt"] = self.viewModel.isMessageTyping ? self.viewModel.messageData?.isPrompt : false
        }
        ///This is done to send correct value of below arguments as sometimes we click on older messages than the latest one and self.viewModel.messageData contains info regaring latest message.
        if (context.isEmpty || (context.first?["intent_uid"] as? String == self.viewModel.messageData?.contexts?.first?["intent_uid"] as? String)) {
            if self.viewModel.messageData?.masked == true {
                arrayOfDictionaries["isMaskedInput"] = true
            }

            if self.viewModel.messageData?.classified == true {
                arrayOfDictionaries["classified"] = true
                arrayOfDictionaries["isClassifiedInput"] = true
            }

            if self.viewModel.messageData?.encrypted == true {
                arrayOfDictionaries["isEncryptedInput"] = true
            }
        }
        if query.isEmpty == false {
            arrayOfDictionaries["query"] = query
        }

        if showLabelText != "" {
            arrayOfDictionaries["showLabelText"] = showLabelText
            arrayOfDictionaries["is_prompt"] = isPrompt /// Changed is_prompt to false from true for query link implementation in text card
        }

        arrayOfDictionaries["is_typed"] = self.viewModel.isMessageTyping  ? true:false

        if self.viewModel.isSSO == 1 {
            let meta = ["sso_response": true, "quick_reply": true]
            arrayOfDictionaries["msg_session"] = self.viewModel.ssoSessionId
            arrayOfDictionaries["authorized"] = true
            arrayOfDictionaries["require_sso"] = true
            arrayOfDictionaries["meta_data"] = meta
            arrayOfDictionaries["is_prompt"] = false
            self.viewModel.isSSO = 0
        }

        if self.viewModel.callTransferType == .oracle || self.viewModel.callTransferType == .genesysInternal {
            arrayOfDictionaries["meta_data"] = self.viewModel.oracleMetaData
        }

        if self.viewModel.isResetTapped {
            arrayOfDictionaries["contexts"] = []
            arrayOfDictionaries["clear_context"] = true
            self.viewModel.isResetTapped = false
        }

        if self.viewModel.isFeedback {
            if self.viewModel.isThumbFeedback == false {
                arrayOfDictionaries["is_text_feedback"] = true
            }
            if !isNewGenAITheme {
                self.hideFeedbackInputTextBar()
            } else {
                self.viewModel.isFeedback = false
            }
        }

        if self.viewModel.isThumbFeedback {
            arrayOfDictionaries["thumbsup"] = self.viewModel.isThumbsUp
            self.viewModel.isThumbFeedback = false
            self.viewModel.isThumbsUp = false
            self.hideFeedbackInputTextBar()
        }
        ///userMessageId is required in case of feedback(text, thumbs up, thumbs down) and live agent transfer
        if userMessageId != "" && userMessageId != "0" {
            arrayOfDictionaries["msg_id"] = userMessageId
        }
        
        if templateUid != "" {
            arrayOfDictionaries["template_uid"] = templateUid
        }
        
        if !actualIntent.isEmpty {
            arrayOfDictionaries["actual_intent"] = actualIntent
            arrayOfDictionaries["agent_call_transferred"] = true
        }

        // For live agent icon click
        if isAddContext == false {
            arrayOfDictionaries.removeValue(forKey: "intent")
            arrayOfDictionaries.removeValue(forKey: "intent_name")
            arrayOfDictionaries.removeValue(forKey: "is_prompt")
            arrayOfDictionaries.removeValue(forKey: "is_text_feedback")
            arrayOfDictionaries["is_typed"] = false
            arrayOfDictionaries["context_life_span"] = 0
            arrayOfDictionaries["template_id"] = 0

        }

        if VAConfigurations.isChatTool, self.viewModel.selectedMessageModelForReply.count > 0 {
            // Handle isChatTool and reply message
            arrayOfDictionaries["replyToMessage"] = self.viewModel.selectedMessageModelForReply
        }
        if senderMessageType == SenderMessageType.signature {
            arrayOfDictionaries["digitalSign"] = true
            arrayOfDictionaries.removeValue(forKey: "text")
        } else if senderMessageType == SenderMessageType.qrCode {
            arrayOfDictionaries["qrCode"] = inputStr
            arrayOfDictionaries.removeValue(forKey: "text")
        } else if senderMessageType == SenderMessageType.location {
            let locationCoordinates = inputStr.components(separatedBy: ",")
            if locationCoordinates.count > 1 {
                let coordinates = ["latitude": locationCoordinates[0], "longitude": locationCoordinates[1]]
                arrayOfDictionaries["latLng"] = coordinates
            }
        } else if senderMessageType == SenderMessageType.formFields {
            arrayOfDictionaries.removeValue(forKey: "text")
            arrayOfDictionaries["custom_form"] = true
            var formValues: [String:String] = [:]
            for (key, value) in customFormValues ?? [:] {
                if !value.isEmpty {
                    formValues["\(key)"] = "\(value)"
                }
            }
            arrayOfDictionaries["user_details"] = formValues
        }
        // ******Live agent transfer********
        self.createRequestForServer(arrayOfDictionaries: arrayOfDictionaries)
    }

    func sendCloseChatbotMsgToServer() {
        self.viewLiveAgent.isUserInteractionEnabled = false
        let languageCode = self.viewModel.configurationModel?.result?.autoLangDetection == false ? VAConfigurations.getCurrentLanguageCode() : (self.viewModel.autoDetectedLanguageId == "" ? VAConfigurations.getCurrentLanguageCode() : self.viewModel.autoDetectedLanguageId)
        let arrayOfDictionaries = ["log": "true",
                                   "form_type": "click",
                                   "timezoneOffset": TimeZone.current.offsetInMinutes(),
                                   "timezone": TimeZone.current.identifier,
                                   "msg": "",
                                   "bot_id": "\(VAConfigurations.botId)",
                                   "bot_name": self.viewModel.configurationModel?.result?.name ?? "",
                                   "language_id": "\(languageCode)",
                                   "template_id": 0,
                                   "context_life_span": 0,
                                   "sentiment": 0,
                                   "is_typed": false,
                                   "welcome_msg_check": false,
                                   "graceful_closure": true,
                                   "nlu_service": self.viewModel.configurationModel?.result?.nluService ?? "",
                                   "channel": "mobile",
                                   "device": "mobile",
                                   "version": UIDevice.current.systemVersion,
                                   "os": "iOS"] as [String: Any]
        self.createRequestForServer(arrayOfDictionaries: arrayOfDictionaries)
    }

    func createRequestForServer(arrayOfDictionaries: [String: Any], isWelcomeMsg: Bool = false) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: arrayOfDictionaries, options: []) {
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            let str = "![CDATA[" + jsonString + "]]"
            debugPrint("User Message: \(str)")
            self.viewModel.lastMessageCDATA = str
            if let body = DDXMLElement.element(withName: "body", stringValue: str) as? DDXMLElement {
                if let completeMessage = DDXMLElement.element(withName: "message") as? DDXMLElement {
                    completeMessage.addAttribute(withName: "type", stringValue: "groupchat")
                    if isWelcomeMsg {
                        completeMessage.addAttribute(withName: "welcome_msg_check", stringValue: "true")
                    }
                    completeMessage.addAttribute(withName: "to", stringValue: "bot_\(VAConfigurations.userUUID)@conference.\(VAConfigurations.vHost)")
                    if self.viewModel.messageData?.classified == true {
                        completeMessage.addAttribute(withName: "otr", stringValue: "true")
                    }

                    completeMessage.addAttribute(withName: "from",
                                                 stringValue: "\(VAConfigurations.userUUID)@\(VAConfigurations.vHost)")// username+"@"+VHOST
                    completeMessage.addAttribute(withName: "xml:lang",
                                                 stringValue: "\(VAConfigurations.getCurrentLanguageCode())")
                    completeMessage.addChild(body)
                    //        print(xmppController.xmppStream.isConnected)
                    //        print("Send Msg =\(completeMessage)")

                    xmppController?.xmppStream.send(completeMessage)
                    // self.updateMultiOpsItemOnMessageSend()
                }
            }
        }
    }
}
