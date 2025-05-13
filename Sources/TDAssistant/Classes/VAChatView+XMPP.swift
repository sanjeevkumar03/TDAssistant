// VAChatView+XMPP.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import Foundation
import XMPPFramework
import AVKit
import SwiftyXMLParser

typealias ServerMessageResponse = (messageArray: [MockMessage], isQuickReply: Bool)

extension VAChatViewController {
    /// This func creates connection with xmpp server
    func connectXMPPwith() {
        do {
            try self.xmppController = XMPPController(
                hostName: VAConfigurations.XMPPHostName,
                userJIDString: VAConfigurations.userJid,
                password: VAConfigurations.password)
            // debugPrint("User JID: \(VAConfigurations.userJid)")
            self.xmppController.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
            self.xmppController.connect()
        } catch {
            UIAlertController.openAlertWithOk(LanguageManager.shared.localizedString(forKey: "Oops!"), LanguageManager.shared.localizedString(forKey: "Something went wrong"), LanguageManager.shared.localizedString(forKey: "OK"), completion: nil)
        }
    }

    func disconnectSocket() {
        self.xmppController?.xmppStream.removeDelegate(self)
        self.xmppController?.xmppReconnect.deactivate()
        self.xmppController?.xmppStream.disconnect()
        self.xmppController = nil
    }

    private func handleChatToolIQResponse(xmppIQ: XMPPIQ) {
        debugPrint("Chattool IQ: \(xmppIQ)")
        self.viewModel.isChatToolWaitingForAgent = true
        CustomLoader.hide()
    }

    func sendIQ() {
        if let iq = DDXMLElement.element(withName: "iq") as? DDXMLElement {
            iq.addAttribute(withName: "id", stringValue: VAConfigurations.userUUID)// UID...
            iq.addAttribute(withName: "type", stringValue: "get")
            iq.addAttribute(withName: "to", stringValue: VAConfigurations.vHost)// VHOST....
            iq.addAttribute(withName: "xmlns", stringValue: "jabber:client")
            
            if let query = DDXMLElement.element(withName: "query") as? DDXMLElement {
                // IsChatTool need to send extra attributes
                if VAConfigurations.isChatTool, VAConfigurations.skill.isEmpty == false {
                    //query.addAttribute(withName: "ejsession", stringValue: "0")
                    let sessionID = UserDefaultsManager.shared.getSessionID()
                    query.addAttribute(withName: "ejsession", stringValue: "\(sessionID)")
                    query.addAttribute(withName: "nickname", stringValue: VAConfigurations.customData?.userName ?? "")
                    query.addAttribute(withName: "skill", stringValue: VAConfigurations.skill)
                    query.addAttribute(withName: "with", stringValue: "skillAgent")
                    // agentjid = jid
                } else {
                    // Reconnection of xmpp stream after disconnection
                    let sessionID = UserDefaultsManager.shared.getSessionID()
                    debugPrint("Session id sent for reconnection: \(sessionID))")
                    query.addAttribute(withName: "ejsession", stringValue: "\(sessionID)")
                }
                query.addAttribute(withName: "xmlns", stringValue: "xavbot:simulate:create:room")
                iq.addChild(query)
                print("Create Room IQ:\n\(iq)")
                xmppController.xmppStream.send(iq)
            }
        }
    }

    func botSetupBasedOnReceivedMessage(isFeedbackShown: Bool) -> Bool {
        var isTextFeedbackShown: Bool = false

        if self.viewTextInputBG.isHidden, !VAConfigurations.isChatbotMinimized {
            self.viewTextInputBG.isHidden = false
            self.txtViewMessage.text = self.viewModel.defaultPlaceholder
        }

        // Show Masked icons
        self.showMaskedMessage()

        // Setup Live agent button
        self.updateLiveAgentButton()

        // Show Feedback
        let textFeedback = self.viewModel.messageData?.feedback?["text_feedback"]
        if (textFeedback ?? false) && !isFeedbackShown {
            self.showFeedbackInputTextBar()
            isTextFeedbackShown = true
        }
        if self.viewModel.configurationModel?.result?.resetContext ?? false, (textFeedback ?? false) == false {
            if self.viewModel.isFeedback == true && self.viewModel.isQueueBannerForOracle == true {
                self.hideFeedbackInputTextBar()
                self.setMessageInputBarOnMessageGet()
            } else {
                self.setMessageInputBarOnMessageGet()
            }
        }
        return isTextFeedbackShown
    }

    private func handleResponseOfXMPP(message: XMPPMessage) {
        let removedCDATA = message.body?.replacingOccurrences(of: "![CDATA[", with: "")
        let removedBracket = removedCDATA?.dropLast().dropLast()
        let removedBackSlash = removedBracket?.replacingOccurrences(of: "", with: "")
        guard let messageData = removedBackSlash?.parseJsonResponse() else {
            return
        }
        self.viewSuggestions.isHidden = true
        self.searchedText = ""
        self.setCircularProgress()
        debugPrint("Bot Response: \(message)")
        self.viewModel.isButtonClickEnabled = true
        self.viewModel.isCallTransfer = messageData.callTransfer
        if messageData.optional?["agent_type"] as? String == "HumanAgent" && messageData.optional?["live_agent"] as? Bool == true && self.viewModel.callTransferType == .none && self.viewModel.isCallTransfer == false {
            self.handleViewForPokedConversation(isPoked: true)
        }
        if isHistoryMessage {
            self.handleHistoryMessages(message: message, messageData: messageData, messageStr: removedBackSlash)
        } else {
            if (removedBackSlash ?? "").contains("agentjoin") && (removedBackSlash ?? "").contains("doNotRespond") && (removedBackSlash ?? "").contains("skill") && self.viewModel.callTransferType == .none {
                if let data = removedBackSlash?.data(using: .utf8) {
                    do {
                        if let jsonDict = try? (JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any]) {
                            let isDoNotRespond = jsonDict["doNotRespond"] as? Bool ?? false
                            if let agentJoin = jsonDict["agentjoin"] as? String {
                                if (agentJoin == "join" || agentJoin == "unjoin") && isDoNotRespond {
                                    self.viewModel.callTransferType = .tids
                                    self.viewModel.isPokedByAgent = false
                                }
                            }
                        }
                    }
                }
            }
            self.viewModel.messageData = messageData
            self.viewModel.autoDetectedLanguageId = messageData.languageId
            if (removedBackSlash ?? "").contains("ack_feedback") {///To hide message loader in case feedback is not enabled for bot
                self.imgViewTyping.isHidden = true
                self.viewModel.isFeedbackGivenByUser = false
            }
            if self.viewModel.isCallTransfer {
                self.handleCallTransferResponse(message: message, messageData: messageData, isCallTransfer: self.viewModel.isCallTransfer, historyMsgTime: nil)
            } else {
                if messageData.responseList.count > 0 {
                    if self.viewModel.callTransferType == .tids {
                        self.viewModel.callTransferType = .none
                    }
                    if self.viewModel.isPokedByAgent {
                        self.viewModel.isPokedByAgent = false
                    }
                    if self.viewModel.callTransferType == .CC360 && messageData.optional?["live_agent"] as? String == "accepted" {
                        self.viewModel.isAgentAcceptedCC360CallTransfer = true
                    }
                    if messageData.optional?["live_agent"] as? Bool == false && self.viewModel.callTransferType == .CC360 && self.viewModel.isAgentAcceptedCC360CallTransfer == true {
                        self.viewModel.callTransferType = .none
                        self.viewModel.isAgentAcceptedCC360CallTransfer = false
                    }
                    if self.viewModel.configurationModel?.result?.genAINewTheme ?? false {
                        self.addMessageToArrayNewGenAITheme(message: message, messageData: messageData)
                    } else {
                        self.addMessageToArrayGeneric(message: message, messageData: messageData)
                    }
                } else {
                    // Call Transfer
                    if self.viewModel.callTransferType == .tids || VAConfigurations.isChatTool || self.viewModel.isPokedByAgent {
                        self.handleTIDSConversation(message: message)
                    }
                }
            }
        }
    }
    
    func addMessageToArrayGeneric(message: XMPPMessage, messageData: MessageData) {
        var timer: Double = 0.0
        let defaultDelayTimer: Double = 0.02
        var isFirstMsg = self.viewModel.arrayOfMessages2D.isEmpty
        for index in 0...messageData.responseList.count {
            if index == messageData.responseList.count {
                timer += defaultDelayTimer
            } else {
                let responseModel = messageData.responseList[index]
                if index == 0 && isFirstMsg {
                    timer += defaultDelayTimer
                    isFirstMsg = false
                    // Hide Loader
                    CustomLoader.hide()
                } else {
                    if let delay = responseModel.delay {
                        var msgDelay = Double(Double(delay) / Double(1000))
                        if messageData.responseList.count == 1 {
                            msgDelay = defaultDelayTimer
                        }
                        timer += (msgDelay == 0 ? defaultDelayTimer : msgDelay)
                    } else {
                        timer += defaultDelayTimer
                    }
                }
            }
            var isShowBotImage: Bool = true
            if index != 0 {
                isShowBotImage = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + timer, execute: {
                if index == messageData.responseList.count {
                    if (self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAI || self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAINLU) {
                        self.invalidateGenAISendMsgDelayTimer()
                    }
                    DispatchQueue.main.async {
                        self.showDateMessage(message: message, messageData: messageData)
                    }
                } else {
                    var response: MessageResponse = messageData.responseList[index]
                    response.context = messageData.contexts ?? []
                    self.updateArrayWithMessageFromServer(message: message, messageData: messageData, response: response, isShowBotImage: isShowBotImage, isShowTypeWritingAnimation: (index == messageData.responseList.count-1))
                    //self.btnSendMessage.isUserInteractionEnabled = true
                }

                /// Replace this method with its definition if messages are not shown in correct order
                _ = self.botSetupBasedOnReceivedMessage(isFeedbackShown: false)
            })
        }
    }
    
    func addMessageToArrayNewGenAITheme(message: XMPPMessage, messageData: MessageData) {
        var timer: Double = 0.0
        let defaultDelayTimer: Double = 0.02
        for index in 0...messageData.responseList.count {
            if index == 0 || index == 1 {
                timer += defaultDelayTimer
            } else {
                let responseModel = messageData.responseList[index-1]
                if let delay = responseModel.delay {
                    let msgDelay = Double(Double(delay) / Double(1000))
                    timer += (msgDelay == 0 ? defaultDelayTimer : msgDelay)
                } else {
                    timer += defaultDelayTimer
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + timer, execute: {
                if index == 0 {
                    CustomLoader.hide()
                    self.showDateMessageNewGenAITheme(message: message, messageData: messageData)
                } else {
                    var response: MessageResponse = messageData.responseList[index-1]
                    response.context = messageData.contexts ?? []
                    self.updateArrayWithMessageFromServer(message: message, messageData: messageData, response: response, isShowBotImage: false, isShowTypeWritingAnimation: (index == messageData.responseList.count))
                    if index == messageData.responseList.count {
                        if (self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAI || self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAINLU) {
                            self.invalidateGenAISendMsgDelayTimer()
                        }
                        self.updateCardsAfterMessagesAreLoadedForAParticularQuery()
                    }
                }
                if index == messageData.responseList.count {
                    /// Replace this method with its definition if messages are not shown in correct order
                    _ = self.botSetupBasedOnReceivedMessage(isFeedbackShown: false)
                }
            })
        }
    }

    func setMessageSequence(messageData: MessageData, isDateMsg: Bool = false) -> Int {
        var messageSequence: Int = 0
        if messageData.userMessageId == nil {
            let allMessages = self.viewModel.arrayOfMessages2D.flatMap({$0})
            if allMessages.count > 0 {
                if let lastSenderMsg = (allMessages.filter({$0.sender.id == VAConfigurations.userUUID})).last {
                    let msgSequence = lastSenderMsg.messageSequance
                    messageSequence = msgSequence + 1
                }
            } else {
                messageSequence = 1
            }
        } else {
            if messageData.userMessageId == 0 {
                let allMessages = self.viewModel.arrayOfMessages2D.flatMap({$0})
                if allMessages.count > 0 {
                    if let lastSenderMsg = (allMessages.filter({$0.sender.id == VAConfigurations.userUUID})).last {
                        let msgSequence = lastSenderMsg.messageSequance
                        messageSequence = msgSequence + 1
                    } else {
                        messageSequence = 1
                    }
                } else {
                    messageSequence = 1
                }
            } else {
                if self.viewModel.isFeedbackGivenByUser {
                    if isDateMsg {
                        messageSequence = (self.viewModel.arrayOfMessages2D.last?.last?.messageSequance ?? 0)
                    } else {
                        if self.viewModel.arrayOfMessages2D.last?.last?.isFeedback ?? false {
                            /// Thumbs up and down feedback
                            messageSequence = (self.viewModel.arrayOfMessages2D.last?.last?.messageSequance ?? 0) + 1
                        } else {
                            /// Text feedback
                            let allMessages = self.viewModel.arrayOfMessages2D.flatMap({$0})
                            if allMessages.count > 0 {
                                if let lastSenderMsg = (allMessages.filter({$0.sender.id == VAConfigurations.userUUID})).last {
                                    let msgSequence = lastSenderMsg.messageSequance
                                    messageSequence = msgSequence + 1
                                } else {
                                    messageSequence = 1
                                }
                            } else {
                                messageSequence = 1
                            }
                        }
                    }
                } else {
                    messageSequence = messageData.userMessageId ?? 0
                }
            }
        }
        return messageSequence;
    }
    
    func showDateMessage(message: XMPPMessage, messageData: MessageData) {
        if /*self.viewModel.callTransferType == .none && */self.viewModel.isQueueBannerForOracle == false || self.viewModel.arrayOfMessages2D.last?.first?.sender.id.lowercased() != VAConfigurations.userUUID.lowercased() {
            let serverMessage = self.getMessage(response: nil, sender: message.from?.user ?? "", messageType: "")
            var newMessageModel = serverMessage.messageArray.first
            newMessageModel?.showBotImage = false
            newMessageModel?.messageSequance = setMessageSequence(messageData: messageData, isDateMsg: true)
            newMessageModel?.sentiment = messageData.sentiment ?? 0
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                var hasDateInLastMsg = false
                var hasDateInSecondLastMsg = false
                let item = self.viewModel.arrayOfMessages2D.last?.last
                switch item?.kind {
                case .dateFeedback:
                    hasDateInLastMsg = true
                default:
                    break
                }
                if hasDateInLastMsg == true {
                    if self.viewModel.arrayOfMessages2D.count > 1 {
                        if self.viewModel.arrayOfMessages2D[self.viewModel.arrayOfMessages2D.count-2].first?.sender.id.lowercased() != VAConfigurations.userUUID.lowercased() {
                            let item = self.viewModel.arrayOfMessages2D[self.viewModel.arrayOfMessages2D.count-2].last
                            switch item?.kind {
                            case .dateFeedback:
                                hasDateInSecondLastMsg = true
                            default:
                                break
                            }
                        } else {
                            hasDateInSecondLastMsg = true
                        }
                    }
                }
                if hasDateInLastMsg == false && self.viewModel.arrayOfMessages2D.isEmpty == false {
                    self.viewModel.arrayOfMessages2D[self.viewModel.arrayOfMessages2D.count-1].append(newMessageModel!)
                } else if hasDateInSecondLastMsg == false && self.viewModel.arrayOfMessages2D.count > 1 {
                    self.viewModel.arrayOfMessages2D[self.viewModel.arrayOfMessages2D.count-2].append(newMessageModel!)
                }
                self.reloadAndScrollToBottom(isAnimate: false)
            }
        }
        self.updateCardsAfterMessagesAreLoadedForAParticularQuery()
    }
    func updateCardsAfterMessagesAreLoadedForAParticularQuery() {
        let isNewGenAITheme = self.viewModel.configurationModel?.result?.genAINewTheme ?? false
        self.viewLiveAgent.isUserInteractionEnabled = true
        self.btnSendMessage.isUserInteractionEnabled = true
        /// Carousel card options are disabled once any carousel option is selected. Below code is to enable the options
        let carouselCards = self.chatTableView.subviews.compactMap {$0 as? CarouselCardCell}
        for item in carouselCards {
            for subitem in item.contentView.subviews {
                if isNewGenAITheme {
                    if !subitem.subviews.isEmpty {
                        subitem.subviews.first?.subviews.forEach { $0.isUserInteractionEnabled = true }
                    }
                } else {
                    if subitem.subviews.count > 2 {
                        subitem.subviews[2].subviews.first?.subviews.forEach { $0.isUserInteractionEnabled = true }
                    }
                }
            }
        }
        self.enableButtonCardsOptions()
        if self.viewModel.arrayOfMessages2D.last?.last?.allowSign ?? false {
            self.view.endEditing(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
//                self.addSignatureView()
                self.configureSignatureView()
            })
        } else if self.viewModel.arrayOfMessages2D.last?.last?.qrCode ?? false {
            self.view.endEditing(true)
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.showUploadOptionsView()
                self.allowUserToType(isEnable: false)
            })
        } else if self.viewModel.arrayOfMessages2D.last?.last?.location ?? false {
            self.view.endEditing(true)
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.showUploadOptionsView()
                self.allowUserToType(isEnable: false)
            })
        } else if self.viewModel.arrayOfMessages2D.last?.last?.isCustomFormInFlow ?? false {
            self.view.endEditing(true)
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.viewModel.prechatFormUserInputs = [:]
                let formIndex = (self.viewModel.arrayOfMessages2D.last?.count ?? 0) - (isNewGenAITheme ? 1 : 2)
                self.viewModel.prechatForm = self.viewModel.arrayOfMessages2D.last?[formIndex].customForm
                var title = ""
                var canSkip = false
                switch self.viewModel.arrayOfMessages2D.last?[formIndex].kind {
                case .textItem(let textItem):
                    title = textItem.textProtocol?.title ?? ""
                case .quickReply(let buttonItem):
                    title = buttonItem.quickReplyProtocol?.title ?? ""
                    canSkip = true
                    break
                default:
                    break
                }
                self.showPrechatFormInChatFlow(title: title, canSkip: canSkip)
            })
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.hideUploadOptionsView()
            })
        }
        self.imgViewTyping.isHidden = true
        //        if !self.viewBGQueue.isHidden {
        //            self.viewBGQueue.isHidden = true
        //            self.viewQueue.isHidden = true
        //        }
        if self.viewModel.isFeedbackGivenByUser {
            self.viewModel.isFeedbackGivenByUser = false
        }
    }
    func showDateMessageNewGenAITheme(message: XMPPMessage, messageData: MessageData) {
        let serverMessage = self.getMessage(response: nil, sender: message.from?.user ?? "", messageType: "")
        var newMessageModel = serverMessage.messageArray.first
        newMessageModel?.showBotImage = true
        newMessageModel?.messageSequance = (self.viewModel.arrayOfMessages2D.last?.first?.messageSequance ?? 0) + 1
        newMessageModel?.sentiment = messageData.sentiment ?? 0
        newMessageModel?.userMsgId = messageData.userMessageId
        /*if self.viewModel.arrayOfMessages2D.isEmpty {
            self.viewModel.arrayOfMessages2D.append([newMessageModel!])
        }  else {
            self.viewModel.arrayOfMessages2D[self.viewModel.arrayOfMessages2D.count-1].append(newMessageModel!)
        }*/
        self.viewModel.arrayOfMessages2D.append([newMessageModel!])
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.reloadAndScrollToBottom(isAnimate: false)
        }
    }

    func allowUserToType(isEnable: Bool) {
        self.speechToTextButton.isUserInteractionEnabled = isEnable
        self.txtViewMessage.isUserInteractionEnabled = isEnable
    }
    func checkMessageIndexAndAddToArray(message: MockMessage?) {
        if VAConfigurations.isChatbotMinimized {
            switch message?.kind {
            case .dateFeedback, .agentStatus:
                break
            default:
                self.newMessagesCount += 1
                // FIXME: - Message notification
                // self.updateUnreadMsgsCount()
            }
        } else {
            self.newMessagesCount = 0
        }
        if self.viewModel.arrayOfMessages2D.count > 0 {
            let index = self.viewModel.arrayOfMessages2D.firstIndex { innerArray -> Bool in
                innerArray.filter({$0.messageSequance == message?.messageSequance}).count > 0
            }
            if index == nil {
                self.viewModel.arrayOfMessages2D.append([message!])
            } else {
                self.viewModel.arrayOfMessages2D[index!].append(message!)
            }
        } else {
            self.viewModel.arrayOfMessages2D.append([message!])
        }
    }

    func updateArrayWithMessageFromServer(message: XMPPMessage, messageData: MessageData, response: MessageResponse, isShowBotImage: Bool, isShowTypeWritingAnimation: Bool = false) {
        let serverMessage = self.getMessage(response: response, sender: message.from?.user ?? "", messageType: response.responseType)
        if var newMessageModel = serverMessage.messageArray.first {
            newMessageModel.showBotImage = isShowBotImage
            if self.viewModel.callTransferType == .oracle || self.viewModel.callTransferType == .genesysInternal {
                if (self.viewModel.oracleMetaData["live_agent"] as? String != nil) && (self.viewModel.oracleMetaData["live_agent"] as? String ?? "" == "queue") && (messageData.optional?["live_agent"] as? Bool != nil) && (messageData.optional?["live_agent"] as? Bool ?? false == false) {
                } else {
                    if messageData.iAgentHandoff == nil || messageData.iAgentHandoff != true {
                        self.viewModel.oracleMetaData = messageData.optional ?? [:]
                    }
                }
            }
            if messageData.optional?["live_agent"] as? String ?? "" == "cancel" {
                self.viewModel.oracleMetaData = [:]
                if self.viewBGQueue.isHidden == false {
                    self.viewBGQueue.isHidden = true
                    self.viewQueue.isHidden = true
                    self.btnSendMessage.isUserInteractionEnabled = true
                }
            }
            if let liveAgent = messageData.optional?["live_agent"] as? String {
                if liveAgent == "queue" {
                    var message: String = ""

                    switch newMessageModel.kind {
                    case .textItem(let textItem):
                        message = textItem.textProtocol?.title ?? ""
                    default:
                        debugPrint("")
                    }

                    if self.viewBGQueue.isHidden {
                        self.viewBGQueue.isHidden = false
                        self.viewQueue.isHidden = false
                        self.lblQueueMessage.text = message
                        self.btnSendMessage.isUserInteractionEnabled = true
                    }

                    self.viewModel.isQueueBannerForOracle = true

                } else if liveAgent == "cancel" || liveAgent == "accepted"{
                    if self.viewBGQueue.isHidden == false {
                        self.viewBGQueue.isHidden = true
                        self.viewQueue.isHidden = true
                        self.btnSendMessage.isUserInteractionEnabled = true
                    }

                    if liveAgent == "cancel"{
                        if self.viewModel.callTransferType == .oracle || self.viewModel.callTransferType == .genesysInternal || self.viewModel.callTransferType == .CC360 {
                            self.viewModel.callTransferType = .none
                        }
                    }

                    if self.viewModel.isFeedback == true && self.viewModel.isQueueBannerForOracle == true {
                        self.hideFeedbackInputTextBar()
                    } else { }

                    self.viewModel.isQueueBannerForOracle = false

                    newMessageModel.showBotImage = true
                    newMessageModel.isAgent = true
                    newMessageModel.isQuickReplyMsg = serverMessage.isQuickReply

                    newMessageModel.delay = Double((response.delay ?? 0)/1000)
                    newMessageModel.preventTyping = response.preventTyping
                    newMessageModel.isPrompt = messageData.isPrompt ?? false
                    newMessageModel.responseType = response.responseType
                    newMessageModel.replyIndex = messageData.replyIndex ?? 0
                    newMessageModel.messageSequance = self.setMessageSequence(messageData: messageData)
                    newMessageModel.userMsgId = messageData.userMessageId
                    newMessageModel.isShowTypingEffectAnimation = isShowTypeWritingAnimation
                    // debugPrint("messageSequance: \(messageData.userMessageId)")
                    self.checkMessageIndexAndAddToArray(message: newMessageModel)
                    self.reloadAndScrollToBottom(isAnimate: true)

                } else {
                    // Oracle Right now handling
                    if self.viewModel.callTransferType == .oracle || self.viewModel.callTransferType == .genesysInternal {
                        newMessageModel.showBotImage = true
                        newMessageModel.isAgent = true
                    } else {
                        newMessageModel.isAgent = false
                    }
                    newMessageModel.delay = Double((response.delay ?? 0)/1000)
                    newMessageModel.preventTyping = response.preventTyping
                    newMessageModel.isPrompt = messageData.isPrompt ?? false
                    newMessageModel.responseType = response.responseType
                    newMessageModel.replyIndex = messageData.replyIndex ?? 0
                    newMessageModel.messageSequance = self.setMessageSequence(messageData: messageData)
                    // debugPrint("messageSequance: \(messageData.userMessageId)")
                    newMessageModel.isQuickReplyMsg = serverMessage.isQuickReply
                    newMessageModel.isShowTypingEffectAnimation = isShowTypeWritingAnimation
                    newMessageModel.userMsgId = messageData.userMessageId
                    self.checkMessageIndexAndAddToArray(message: newMessageModel)
                    self.reloadAndScrollToBottom(isAnimate: false)
                }
            } else {
                if self.viewModel.callTransferType == .oracle || self.viewModel.callTransferType == .genesysInternal || (self.viewModel.callTransferType == .CC360 && self.viewModel.isAgentAcceptedCC360CallTransfer) {
                    newMessageModel.showBotImage = true
                    newMessageModel.isAgent = true
                } else {
                    newMessageModel.isAgent = false
                }
                newMessageModel.delay = Double(Double(response.delay ?? 0)/Double(1000))
                newMessageModel.preventTyping = response.preventTyping
                newMessageModel.isPrompt = messageData.isPrompt ?? false
                newMessageModel.responseType = response.responseType
                newMessageModel.replyIndex = messageData.replyIndex ?? 0
                newMessageModel.messageSequance = self.setMessageSequence(messageData: messageData)
                // debugPrint("messageSequance: \(messageData.userMessageId)")
                newMessageModel.isQuickReplyMsg = serverMessage.isQuickReply
                newMessageModel.sentiment = messageData.sentiment ?? 0
                newMessageModel.allowSign = messageData.allowSign
                newMessageModel.location = messageData.location
                newMessageModel.qrCode = messageData.qrCode
                newMessageModel.isCustomFormInFlow = messageData.isCustomFormInFlow
                newMessageModel.customForm = messageData.customForm
                newMessageModel.userMsgId = messageData.userMessageId
                newMessageModel.isShowTypingEffectAnimation = isShowTypeWritingAnimation
                self.checkMessageIndexAndAddToArray(message: newMessageModel)
                self.reloadAndScrollToBottom(isAnimate: false)
            }
        }
    }

    func sendUserTypingState(state: UserTypingStatus) {
        let str: String = ""
        if let body = DDXMLElement.element(withName: "body", stringValue: str) as? DDXMLElement {
            if let completeMessage = DDXMLElement.element(withName: "message") as? DDXMLElement {
                completeMessage.addAttribute(withName: "type", stringValue: "groupchat")
                completeMessage.addAttribute(withName: "to", stringValue: "bot_\(VAConfigurations.userUUID)@conference.\(VAConfigurations.vHost)")

                completeMessage.addAttribute(withName: "from",
                                             stringValue: "\(VAConfigurations.userUUID)@\(VAConfigurations.vHost)")// username+"@"+VHOST
                completeMessage.addAttribute(withName: "xml:lang",
                                             stringValue: "\(VAConfigurations.getCurrentLanguageCode())")
                completeMessage.addChild(body)

                switch state {
                case .typing:
                    let xmppMessage = XMPPMessage(from: completeMessage)
                    xmppMessage.addComposingChatState()
                    xmppController?.xmppStream.send(completeMessage)
                case .paused:
                    let xmppMessage = XMPPMessage(from: completeMessage)
                    xmppMessage.addPausedChatState()
                    xmppController?.xmppStream.send(completeMessage)
                }
            }
        }
    }

    func changeChatStatusToClosed() {
        if let iq = DDXMLElement.element(withName: "iq") as? DDXMLElement {
            iq.addAttribute(withName: "id", stringValue: VAConfigurations.userUUID)// UID...
            iq.addAttribute(withName: "type", stringValue: "get")
            iq.addAttribute(withName: "to", stringValue: VAConfigurations.vHost)// VHOST....
            iq.addAttribute(withName: "xmlns", stringValue: "jabber:client")
            
            if let query = DDXMLElement.element(withName: "query") as? DDXMLElement {
                query.addAttribute(withName: "roomjid", stringValue: "bot_\(VAConfigurations.userUUID)@conference.\(VAConfigurations.vHost)")
                query.addAttribute(withName: "xmlns", stringValue: "xavbot:skill:user:release")
                iq.addChild(query)
                print("Release user IQ:\n\(iq)")
                if xmppController != nil {
                    xmppController.xmppStream.send(iq)
                }
            }
        }
    }

    func getMessage(response: MessageResponse?, sender: String, messageType: String) -> ServerMessageResponse {
        let uniqueID = NSUUID().uuidString
        let sender = Sender(id: sender, displayName: sender)
        let date = Date()
        let messageType = messageType
        var mockMsgArray: [MockMessage] = []

        switch messageType {

        case "text":
            var text = response?.botAnswers?[0]
            text = text == nil ? "" : text
            var citations: [CitationObject]? = nil
            if let citationsArray = response?.citations as? [NSDictionary] {
                let citObj = Citations(citationsArray)
                citations = citObj.citations
            }
            
            let textItem = TextItem(title: text!, isShowSenderIcon: true, source: response?.prop ?? nil, citations: citations, isNewGenAITheme: (self.viewModel.configurationModel?.result?.genAINewTheme ?? false))
            var item = MockMessage(textItem: textItem,
                                   sender: sender,
                                   messageId: uniqueID,
                                   date: date)
            item.context = response?.context ?? []
            mockMsgArray.append(item)
            return (mockMsgArray, false)

        case "image":
            /*var imageWidth: CGFloat = 200
            var imageHeight: CGFloat = 200
            if let imgUrl = URL(string: response?.botAnswers?[0] ?? "") {
                if let imageSource = CGImageSourceCreateWithURL(imgUrl as CFURL, nil) {
                    if let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary? {
                        imageWidth = imageProperties[kCGImagePropertyPixelWidth] as! CGFloat
                        imageHeight = imageProperties[kCGImagePropertyPixelHeight] as! CGFloat
                    }
                }
            }*/
            mockMsgArray.append(MockMessage(imageItem: ImageItem(url: response?.botAnswers?[0] ?? "", isShowSenderIcon: true, imageWidth: 0, imageHeight: 0),
                                            sender: sender,
                                            messageId: uniqueID,
                                            date: date))
            return (mockMsgArray, false)
            
        case "video":
            let urlString = response?.botAnswers?[0] ?? ""
            mockMsgArray.append(MockMessage(videoUrlString: urlString, sender: sender, messageId: uniqueID, date: date))
            return (mockMsgArray, false)

        case "url":
            let url = response?.botAnswers?[0]
            let urlItem = URLItem(title: url ?? "", isShowSenderIcon: true)
            mockMsgArray.append(MockMessage(urlItem: urlItem, sender: sender, messageId: uniqueID, date: date))
            return (mockMsgArray, false)

        case "quick_reply":
            mockMsgArray.append(MockMessage(quickReply: response!.quickReply!, sender: sender, messageId: uniqueID, date: date))
            return (mockMsgArray, true)

        case "carousel":
            for carousel in response!.carousalArray {
                var item = MockMessage(carousel: carousel,
                                       sender: sender,
                                       messageId: uniqueID,
                                       date: date)
                item.context = response?.context ?? []
                mockMsgArray.append(item)
            }
            return (mockMsgArray, false)

        case "props":
            let prop = response?.prop
            mockMsgArray.append(MockMessage(propItem: prop!,
                                            sender: sender,
                                            messageId: uniqueID,
                                            date: date))

            return (mockMsgArray, false)

        case "multi_ops":
            let multiOps = response?.multiOps

            var messageModel = MockMessage(multiOptional: multiOps!,
                                           sender: sender,
                                           messageId: uniqueID,
                                           date: date)

            messageModel.isMultiSelect = response?.multiSelect ?? false

            messageModel.isMultiOpsTapped = false

            messageModel.allowSkip = multiOps?.allowSkip ?? false

            mockMsgArray.append(messageModel)

            return (mockMsgArray, false)

        default:
            if self.viewModel.configurationModel?.result?.genAINewTheme ?? false {
                mockMsgArray.append(MockMessage(dateItem: "",
                                                sender: sender,
                                                messageId: uniqueID,
                                                date: date))
            } else {
                mockMsgArray.append(MockMessage(dateFeedback: "",
                                                sender: sender,
                                                messageId: uniqueID,
                                                date: date))
            }
            return (mockMsgArray, false)
        }
    }

    func showMaskedMessage() {
        if self.viewModel.messageData?.masked ?? false {
            self.viewSecureMessage.isHidden = false
            self.viewSecureMsgWidthConstraint.constant = 30
            self.imgSecureMessage.image = UIImage(named: "secureHide", in: Bundle.module, compatibleWith: nil)
            self.viewModel.isSecured = true
        } else {
            self.viewSecureMessage.isHidden = true
            self.viewSecureMsgWidthConstraint.constant = 0
        }
    }

    func getImage(urlStr: String) -> UIImage {
        return UIImage(named: "placeholderImage", in: Bundle.module, with: nil)!
    }

    private func generateThumbnail(url: URL) -> UIImage {
        do {
            let asset = AVURLAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imageGenerator.copyCGImage(at: .zero,
                                                         actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            return UIImage(named: "placeholderImage", in: Bundle.module, with: nil)!
        }
    }

    func enableButtonCardsOptions() {
        /// Button  options are disabled once any button is selected. Below code is to enable the options
        self.allowUserActivity = true
        let buttonCards = self.chatTableView.subviews.compactMap {$0 as? ButtonCardCell}
        for item in buttonCards {
            item.allowUserActivity = true
            for subitem in item.contentView.subviews {
                subitem.subviews.forEach { $0.isUserInteractionEnabled = true }
                if subitem.subviews.count > 3 {
                    if subitem.subviews[3].subviews.count > 1 {
                        subitem.subviews[3].subviews.forEach { $0.isUserInteractionEnabled = true }
                    }
                }
                if subitem.subviews.count == 1 {
                    let quickReplyCell: [QuickReplyCell] = subitem.subviews.first?.subviews.compactMap {$0 as? QuickReplyCell} ?? []

                    for qrCell in quickReplyCell {
                        qrCell.isUserInteractionEnabled = true
                        qrCell.allowUserActivity = true
                        for qrCellSubItem in qrCell.contentView.subviews {
                            // qrCell.isUserInteractionEnabled = true
                            qrCellSubItem.subviews.forEach { $0.isUserInteractionEnabled = true }
                        }
                    }
                }
            }
        }
    }

    func updateMultiOpsItemOnMessageSend() {
        if self.viewModel.arrayOfMessages2D.count > 0 {
            for iIndex in 0...self.viewModel.arrayOfMessages2D.count - 1 {
                for jIndex in 0...self.viewModel.arrayOfMessages2D[iIndex].count - 1 {
                    var model = self.viewModel.arrayOfMessages2D[iIndex][jIndex]
                    switch model.kind {
                    case .multiOps:
                        // if model.isMultiOpsTapped == false {
                        model.isMultiOpsTapped = true
                        self.viewModel.arrayOfMessages2D[iIndex][jIndex] = model
                        self.chatTableView.reloadRows(at: [IndexPath(row: jIndex, section: iIndex)], with: .none)
                        // }
                    default:
                        break
                    }
                }
            }
        }
    }

    func getEcryptedText(inputText: String) -> String {
        let sessionId = UserDefaultsManager.shared.getSessionID()
        let AES = CryptoJS.AES()
        // AES encryption
        let encrypted = AES.encrypt(inputText, password: self.viewModel.messageData?.encryptionKey ?? "")
        let encryptedText = sessionId + encrypted
        return encryptedText
    }

    func callNumber(phoneNumber: String) {
        if let phoneCallURL = URL(string: "telprompt://\(phoneNumber)") {
            let application: UIApplication = UIApplication.shared
            if application.canOpenURL(phoneCallURL) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    application.openURL(phoneCallURL as URL)
                }
            }
        }
    }
}

// MARK: - XMPPStreamDelegate
extension VAChatViewController: XMPPStreamDelegate {
    func xmppStreamDidConnect(_ sender: XMPPStream) {
        self.viewTextInputBG.isUserInteractionEnabled = true
    }

    func xmppMessageArchiveManagement(_ xmppMessageArchiveManagement: XMPPMessageArchiveManagement, didReceiveMAMMessage message: XMPPMessage) {
    }

    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        self.sendIQ()
    }
    
    func xmppStream(_ sender: XMPPStream, didNotRegister error: DDXMLElement) {
        print("XMPPStream didNotRegister error: \(error)")
    }

    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
        print("XMPPStream didNotAuthenticate error: \(error)")
    }
    
    func xmppStreamConnectDidTimeout(_ sender: XMPPStream) {
        print("xmppStreamConnectDidTimeout")
        self.showServiceUnAvailableErrorAlert()
    }
    
    func xmppStreamDidStartNegotiation(_ sender: XMPPStream) {
        print("xmppStreamDidStartNegotiation:")
    }

    func xmppStream(_ sender: XMPPStream, didFailToSend iq: XMPPIQ, error: Error) {
        print("didFailToSend iq:")
    }
    
    func xmppStream(_ sender: XMPPStream, didFailToSend presence: XMPPPresence, error: Error) {
        print("didFailToSend presence:")
    }
    
    func xmppStreamWasTold(toDisconnect sender: XMPPStream) {
        print("xmppStreamWasTold toDisconnect:")
    }

    func xmppStreamWasTold(toAbortConnect sender: XMPPStream) {
        print("xmppStreamWasTold toAbortConnect:")
    }
    
    func xmppStream(_ sender: XMPPStream, didReceiveError error: DDXMLElement) {
        debugPrint("didReceiveError ==== \(error.description)")
        self.viewModel.isXMPPStreamConnectionError = true
        CustomLoader.hide()
        let alert = UIAlertController.init(title: "", message: LanguageManager.shared.localizedString(forKey: "Chatbot cannot connect to the server at the moment. Please retry."), preferredStyle: .alert)
        let close = UIAlertAction.init(title: LanguageManager.shared.localizedString(forKey: "Close"), style: .default) { _ in
            self.closeChatbot()
        }
        let action = UIAlertAction.init(title: LanguageManager.shared.localizedString(forKey: "Connect"), style: .default) { _ in
            self.viewModel.isXMPPStreamConnectionError = false
            CustomLoader.show()
            try? self.xmppController?.xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
        }
        alert.addAction(close)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func xmppStreamDidDisconnect(_ sender: XMPPStream, withError error: Error?) {
        print("xmppStreamDidDisconnect with error: \(String(describing: error?.localizedDescription))")
        if let error = error as? NSError {
            if error.code == 61 || error.code == 8 {
                self.showServiceUnAvailableErrorAlert()
                return
            }
        }
        if !self.viewModel.isXMPPStreamConnectionError {
            try? xmppController?.xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
        }        
    }
    
    func xmppStreamDidSendClosingStreamStanza(_ sender: XMPPStream) {
        print("xmppStreamDidSendClosingStreamStanza:")
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive presence: XMPPPresence) {
        // print("Presence:\n\(presence)")
        let data: Data? = presence.description.data(using: .utf8)
        let xml = XML.parse(data ?? Data())
        if VAConfigurations.isChatTool {
            if xml.element?.childElements.first?.attributes["type"] == "unavailable" && (xml.element?.childElements.first?.childElements.first?.childElements.count ?? 0) > 1 && xml.element?.childElements.first?.childElements.first?.childElements[1].attributes["code"] == "332" {
                ///Conversation ended by agent
                VAConfigurations.virtualAssistant?.delegate?.chatClosedByAgent?()
            }
        } else {
            if xml.element?.childElements.first?.attributes["id"]?.hasPrefix("selfJoinRoom") ?? false {
                /// conversation poked
                self.handleViewForPokedConversation(isPoked: true)
            } else if xml.element?.childElements.first?.attributes["id"]?.hasPrefix("autocreatebot") ?? false {
                self.handleViewForPokedConversation(isPoked: false)
            }
        }
    }
    /*func xmppStream(_ stream:XMPPStream, didReceive presence:XMPPPresence) {
        
    }*/
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        debugPrint("xmppStream didReceive iq: \(iq)")
        if iq.attributeStringValue(forName: "id") == VAConfigurations.userUUID {
            let data: Data? = iq.description.data(using: .utf8)
            let xml = XML.parse(data ?? Data())
            let filter = xml.element?.childElements[0].childElements.filter({ element in
                if element.name == "response"{
                    return true
                } else {
                    return false
                }
            })

            if filter?.count ?? 0 > 0 {
                self.viewModel.messageFromAgentChatTool = filter?[0].text ?? ""
            }
            self.checkForErrorsFromXMPP(xmlChildElement: xml.element?.childElements ?? [], iqData: data)
            if !UserDefaultsManager.shared.isChatBotInitialized() {
                UserDefaultsManager.shared.initializeChatBot()
                if VAConfigurations.isChatTool, VAConfigurations.skill.isEmpty == false {
                    self.handleChatToolIQResponse(xmppIQ: iq)
                } else {
                    if !self.viewModel.isRequestingNewSession && xml.element?.childElements.first?.attributes["type"] != "error" {
                        self.sendWelcomeToServer(query: VAConfigurations.query)
                    }
                }
            }
        }
        return true
    }

    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        print("xmppStream didReceive message:\n \(message)")
        let data: Data? = message.description.data(using: .utf8)
        // let xml = try? XML.parse(data ?? Data())
        let xml = XML.parse(data ?? Data())
        var chatInviteAttributes: [String: String]?
        let childElement2 = xml.element?.childElements[0].childElements as? [XML.Element]
        if !(childElement2?.isEmpty ?? true) {
            let childElement3 = childElement2?[0].childElements
            if !(childElement3?.isEmpty ?? true) {
                chatInviteAttributes = childElement3![0].attributes
            }
        }
        if chatInviteAttributes != nil && chatInviteAttributes?["mode"] as? String ?? "" == "simulate0" {
            let alert = UIAlertController(title: LanguageManager.shared.localizedString(forKey: "Chat Invite"), message: "\(LanguageManager.shared.localizedString(forKey: "You have a new chat invite from")) \(chatInviteAttributes?["name"] ?? "")", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: LanguageManager.shared.localizedString(forKey: "Reject"), style: .default)
            let acceptAction = UIAlertAction(title: LanguageManager.shared.localizedString(forKey: "Accept"), style: .default) { _ in
                self.sendAgentChatInviteAcceptedIQ(inviteAttributes: chatInviteAttributes!)
            }
            alert.addAction(cancelAction)
            alert.addAction(acceptAction)
            self.present(alert, animated: true)
        } else {
            if let checkStr: String = message.body {
                if ((childElement2?.count ?? 0) > 1 && childElement2?[1].name == "delay") && checkStr == "*******" {
                    ///Off the record History message
                    print("off the record history msg")
                } else if !checkStr.contains("![CDATA[") {
                    return
                }
            }
            if message.body == nil {
                return
            }
            if let childElement22 = childElement2 {
                if childElement22.count > 1 && childElement22[1].attributes.keys.count > 0 {
                    let childElement2Attributes = childElement22[1].attributes
                    if childElement2Attributes["code"] == "500" && childElement2Attributes["type"] == "wait" {
                        print("\nUnable to serve, you are too fast in typing")
                        self.lblQueueMessage.text = LanguageManager.shared.localizedString(forKey: "Unable to serve, you are too fast in typing")
                        if self.viewBGQueue.isHidden == true {
                            self.viewBGQueue.isHidden = false
                            self.viewQueue.isHidden = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now()+2.0, execute: {
                            self.viewBGQueue.isHidden = true
                            self.viewQueue.isHidden = true
                        })
                        return
                    }
                }
            }
            /// Check whether message received is history msg or not
            if xml.element?.childElements.first?.childElements.count ?? 0 > 1 && xml.element?.childElements.first?.childElements[1].name ?? "" == "delay" && VAConfigurations.customData?.isGroupSSO == false {
                debugPrint("Received history message")
                self.isHistoryMessage = true
            } else {
                self.isHistoryMessage = false
            }
            self.handleResponseOfXMPP(message: message)
        }
    }
    
    func checkForErrorsFromXMPP(xmlChildElement: [XML.Element], iqData: Data?) {
        if xmlChildElement.first?.childElements.first?.childElements.first?.attributes["type"] == "cancel" && xmlChildElement.first?.childElements.first?.childElements.first?.attributes["code"] == "1103" {
            if VAConfigurations.isChatTool {
                self.showSessionExpiredAlertForChatTool()
            } else if  VAConfigurations.customData?.isGroupSSO == true {
                self.showServiceUnAvailableErrorAlert(isFromGroupSSO: true)
            }else {
                debugPrint("Old session not claimed")
                self.startNewSessionAsOldSessionNotClaimed()
            }
        } else if xmlChildElement.first?.childElements.first?.childElements.first?.attributes["type"] == "cancel" && xmlChildElement.first?.childElements.first?.childElements.first?.attributes["code"] == "1101"  && !VAConfigurations.isChatTool {
            self.showServiceUnAvailableErrorAlert()
        } else if (xmlChildElement.first?.childElements.count ?? 0) > 1 && xmlChildElement.first?.childElements[1].attributes["type"] == "cancel" && xmlChildElement.first?.childElements[1].attributes["code"] == "1101"  && !VAConfigurations.isChatTool {
            self.showServiceUnAvailableErrorAlert()
        } else if xmlChildElement.first?.attributes["type"] == "error" && VAConfigurations.isChatTool && VAConfigurations.skill.isEmpty == false {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                CustomLoader.hide()
            }
            if self.viewModel.arrayOfMessages2D.isEmpty {
                let alert = UIAlertController.init(title: "", message: self.viewModel.messageFromAgentChatTool, preferredStyle: .alert)
                let action = UIAlertAction.init(title: LanguageManager.shared.localizedString(forKey: "OK"), style: .default) { _ in
                    self.closeChatbot()
                }
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            // initiate  NSXMLParser with this data
            let parser: XMLParser? = XMLParser(data: iqData ?? Data())
            parser?.delegate = self
            var _: Bool? = parser?.parse()
            parser?.shouldResolveExternalEntities = true
        }
    }
    func startNewSessionAsOldSessionNotClaimed() {
        // Chatbot
        CustomLoader.show()
        self.viewModel.arrayOfSuggestions.removeAll()
        self.viewModel.arrayOfMessages2D.removeAll()
        self.viewModel.messageData = nil
        if self.viewSuggestions.isHidden == false {
            self.viewSuggestions.isHidden = true
        }
        UIView.performWithoutAnimation {
            self.chatTableView.reloadData()
        }
        UserDefaultsManager.shared.deInitializeChatBot()
        UserDefaultsManager.shared.resetUserUUID()
        VAConfigurations.userUUID = VAConfigurations.generateUUID()
        UserDefaultsManager.shared.resetSessionID()
        self.disconnectSocket()
        self.viewTextInputBG.isHidden = true
        // self.isSessionDisconnected = true
        self.viewModel.isRequestingNewSession = true
        if self.viewBGQueue.isHidden == false {
            self.viewBGQueue.isHidden = true
            self.viewQueue.isHidden = true
            self.viewModel.callTransferType = .none
            self.viewModel.isPokedByAgent = false
            self.viewModel.isAgentAcceptedCC360CallTransfer = false
            self.btnSendMessage.isUserInteractionEnabled = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            self.isOldSessionNotClaimed = true
            self.viewModel.callGetConfigurationApi()
        }
    }
    func showSessionExpiredAlertForChatTool() {
        CustomLoader.hide()
        print("Chattool - Old session not claimed")
        let alert = UIAlertController.init(title: "", message: LanguageManager.shared.localizedString(forKey: "Your session has been expired. Please start a new conversation."), preferredStyle: .alert)
        let close = UIAlertAction.init(title: LanguageManager.shared.localizedString(forKey: "OK"), style: .default) { _ in
            VAConfigurations.virtualAssistant?.delegate?.oldSessionNotClaimedStartNewConversationWithNewJID?()
            self.closeChatbot()
            return
        }
        alert.addAction(close)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showServiceUnAvailableErrorAlert(isFromGroupSSO: Bool = false) {
        CustomLoader.hide()
        let alert = UIAlertController.init(title: "", message: isFromGroupSSO ? "Unable to launch chatbot. Please retry after some time." : LanguageManager.shared.localizedString(forKey: "Oops, this service is temporarily unavailable"), preferredStyle: .alert)
        let action = UIAlertAction.init(title: LanguageManager.shared.localizedString(forKey: "OK"), style: .default) { _ in
            self.closeChatbot()
            return
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: XMLParserDelegate
extension VAChatViewController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        ///Removed code from here
        if let sessionId = attributeDict["session_id"] {
            let oldSessionID = UserDefaultsManager.shared.getSessionID()
            if sessionId != oldSessionID &&  oldSessionID != "0" && oldSessionID != "" {
                /// Post Notification
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sessionExpired"), object: [:])
                }

                // Remove banner of call transfer if session renewed
                /*if self.viewModel.callTransferType == .oracle || self.viewModel.callTransferType == .genesysInternal {
                 if self.viewModel.isQueueBannerForOracle {
                 self.viewBGQueue.isHidden = true
                 self.viewQueue.isHidden = true
                 self.viewModel.callTransferType = .none
                 }
                 }*/
                if self.viewBGQueue.isHidden == false {
                    self.viewBGQueue.isHidden = true
                    self.viewQueue.isHidden = true
                    self.viewModel.callTransferType = .none
                    self.viewModel.isPokedByAgent = false
                    self.viewModel.isAgentAcceptedCC360CallTransfer = false
                    self.btnSendMessage.isUserInteractionEnabled = true
                }

                /// Remove all previous messages
                self.viewModel.arrayOfMessages2D.removeAll()
                self.viewModel.messageData = nil
                self.viewModel.arrayOfSuggestions.removeAll()
                if self.viewSuggestions.isHidden == false {
                    self.viewSuggestions.isHidden = true
                }
                /// Reload tableview
                UIView.performWithoutAnimation {
                    self.chatTableView.reloadData()
                }
                /// Send welcome message
                self.sendWelcomeToServer(query: "")
            } else if VAConfigurations.customData?.isGroupSSO == true && sessionId != oldSessionID && (oldSessionID == "0" || oldSessionID == ""){
                UserDefaultsManager.shared.initializeChatBot()
                self.sendWelcomeToServer(query: "")
            }///Group sso
            UserDefaultsManager.shared.setSessionID(sessionId == "" ? "0" : sessionId)
            if self.isSessionDisconnected {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    CustomLoader.hide()
                }
                self.isSessionDisconnected = false
            }
            if self.viewModel.isRequestingNewSession && !VAConfigurations.isChatTool {
                /// Send welcome message
                self.sendWelcomeToServer(query: "")
                self.viewModel.isRequestingNewSession = false
            }
            /// Restore previous session
            let lastMessageId = Int(attributeDict["last_msg"] ?? "0") ?? 0
            self.viewModel.sessionStartMsg = Int(attributeDict["session_start_msg"] ?? "0") ?? 0
            if elementName == "results" && lastMessageId > 0 && lastMessageId > self.viewModel.sessionStartMsg {
                debugPrint("Restoring last session:\nSession id: \(attributeDict["session_id"] ?? "0")\nLast msg: \(attributeDict["last_msg"] ?? "0")")
                self.sendHistoryIQ(lastMsgID: "\(lastMessageId+1)")
            } else if elementName == "results" && lastMessageId > 0 && lastMessageId == self.viewModel.sessionStartMsg {
                CustomLoader.hide()
                if VAConfigurations.isChatTool {
                    self.showSessionExpiredAlertForChatTool()
                } else {
                    _ = self.botSetupBasedOnReceivedMessage(isFeedbackShown: false)
                }
            }
            debugPrint("New Session id: \(UserDefaultsManager.shared.getSessionID())")
        }
    }
}
