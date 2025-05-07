// VAChatView+LiveAgent.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import Foundation
import XMPPFramework
import SwiftyXMLParser

extension VAChatViewController {

    func sendAgentChatInviteAcceptedIQ(inviteAttributes: [String: String]) {
        self.viewModel.callTransferType = .tids
        self.viewModel.isPokedByAgent = false
        
        if let iq = DDXMLElement.element(withName: "iq") as? DDXMLElement {
            iq.addAttribute(withName: "id", stringValue: VAConfigurations.userUUID)// UID...
            iq.addAttribute(withName: "type", stringValue: "get")
            iq.addAttribute(withName: "to", stringValue: VAConfigurations.vHost)// VHOST....
            iq.addAttribute(withName: "xmlns", stringValue: "jabber:client")
            
            if let query = DDXMLElement.element(withName: "query") as? DDXMLElement {
                query.addAttribute(withName: "ejsession", stringValue: "0")
                query.addAttribute(withName: "skill", stringValue: VAConfigurations.skill)
                query.addAttribute(withName: "with", stringValue: "skillAgent")
                query.addAttribute(withName: "nickname", stringValue: inviteAttributes["name"] ?? "")
                query.addAttribute(withName: "agentjid", stringValue: inviteAttributes["from"] ?? "")
                query.addAttribute(withName: "message", stringValue: inviteAttributes["message"] ?? "")
                query.addAttribute(withName: "reopen", stringValue: "true")
                query.addAttribute(withName: "reopencount", stringValue: "1")
                query.addAttribute(withName: "xmlns", stringValue: "xavbot:simulate:create:room")
                
                debugPrint("Reopen/Invite Chat for agent IQ:\n\(query)")
                iq.addChild(query)
                xmppController?.xmppStream.send(iq)
            }
        }
        CustomLoader.hide()
    }
    
    func handleViewForPokedConversation(isPoked: Bool) {
        if isPoked {
            self.viewModel.isPokedByAgent = true
            self.viewLiveAgent.isHidden = true
            self.wConstraintLiveAgent.constant = 0
            self.viewSuggestions.isHidden = true
            self.viewModel.arrayOfSuggestions.removeAll()
            self.btnSendMessage.isUserInteractionEnabled = true
            self.searchedText = ""
            if self.viewModel.isFeedback {
                self.hideFeedbackInputTextBar()
            }
            if self.viewSecureMessage.isHidden == false {
                self.viewSecureMessage.isHidden = true
                self.viewSecureMsgWidthConstraint.constant = 0
                self.viewModel.isSecured = false
                self.viewModel.messageData?.masked = false
            }
        } else {
            self.viewModel.callTransferType = .none
            self.viewModel.isPokedByAgent = false
            self.btnSendMessage.isUserInteractionEnabled = true
            if self.viewModel.configIntegrationModel?.liveAgntVisiblity == true {
                self.viewLiveAgent.isHidden = false
                self.wConstraintLiveAgent.constant = 30
            }
        }
        
    }

    func handleCallTransferResponse(message: XMPPMessage, messageData: MessageData, isCallTransfer: Bool, historyMsgTime: Date? = nil) {
        if messageData.responseList.count > 0 {

            var timer: Double = 0.0
            let defaultDelayTimer: Double = 0.02
            timer = 0.0

            var isFeedbackShown: Bool = false
            var isFirstMsg = self.viewModel.arrayOfMessages2D.isEmpty
            for index in 0..<messageData.responseList.count {
                if index == messageData.responseList.count {
                    timer += defaultDelayTimer
                } else {
                    let responseModel = messageData.responseList[index]
                    if index == 0 && isFirstMsg {
                        timer += defaultDelayTimer
                        isFirstMsg = false
                    } else {
                        if let delay = responseModel.delay {
                            let msgDelay = Double(Double(delay) / Double(1000))
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
                    self.imgViewTyping.isHidden = true
                    // Show Feedback
                    let textFeedback = self.viewModel.messageData?.feedback?["text_feedback"]
                    if (textFeedback ?? false) && !isFeedbackShown {
                        self.showFeedbackInputTextBar()
                        isFeedbackShown = true
                    }
                    self.setMessageInputBarOnMessageGet()
                    if self.viewTextInputBG.isHidden, !VAConfigurations.isChatbotMinimized {
                        self.viewTextInputBG.isHidden = false
                        self.txtViewMessage.text = self.viewModel.defaultPlaceholder
                    }
                    if /*self.viewModel.isCallTransfer*/isCallTransfer {
                        var response: MessageResponse = messageData.responseList[index]
                        response.context = messageData.contexts ?? []

                        if response.responseType == "call_transfer" {
                            if response.platformType == "Genesys" {
                                self.viewModel.callTransferType = .genesys
                                self.viewModel.isPokedByAgent = false
                                self.handleGenesysCallTransfer(response: response)
                            } else if response.platformType == "Genesys Internal" {
                                self.viewModel.callTransferType = .genesysInternal
                                self.viewModel.isPokedByAgent = false
                            } else if response.platformType == "TIDS Internal" {
                                self.viewModel.callTransferType = .tids
                                self.viewModel.isPokedByAgent = false
                                if let lastSection = self.viewModel.arrayOfMessages2D.last {
                                    if lastSection.count > 1 {
                                        let lastMessage = lastSection[lastSection.count - 2]
                                        var message: String = ""
                                        switch lastMessage.kind {
                                        case .textItem(let textItem):
                                            message = textItem.textProtocol?.title ?? ""
                                        default:
                                            debugPrint("")
                                        }
                                        if message.contains("no agent") {
                                            self.viewModel.isCallTransfer = false
                                            self.viewModel.callTransferType = .none
                                        } else {
                                            self.appendAgentMessageForTIDSCallTransfer(response: response)
                                        }
                                    } else {
                                        self.appendAgentMessageForTIDSCallTransfer(response: response)
                                    }
                                } else {
                                    self.appendAgentMessageForTIDSCallTransfer(response: response)
                                }
                            } else if response.platformType == "Oracle Right Now" {
                                self.viewModel.callTransferType = .oracle
                                self.viewModel.isPokedByAgent = false
                            } else if response.platformType == "CC360" {
                                self.viewModel.callTransferType = .CC360
                                self.viewModel.isPokedByAgent = false
                            }
                        } else {
                            self.updateArrayWithMessageFromServer(message: message, messageData: messageData, response: response, isShowBotImage: isShowBotImage, isShowTypeWritingAnimation: true)
                            DispatchQueue.main.async {
                                self.showDateMessage(message: message, messageData: messageData)
                            }
                        }
                    } else { }
                    self.updateLiveAgentButton()
                    CustomLoader.hide()
                    // Show Masked icons
                    self.showMaskedMessage()
                })
            }
        }

    }

    private func appendAgentMessageForTIDSCallTransfer(response: MessageResponse) {
        let firstName: String = response.headers["firstname"] as? String ?? ""
        let lastName: String = response.headers["lastname"] as? String ?? ""
        let hiStr = LanguageManager.shared.localizedString(forKey: "Hi")

        let thanksStr = LanguageManager.shared.localizedString(forKey: ", thank you for your patience, we will be connecting you to the next available agent shortly.")

        let messageString = "\(hiStr) \(firstName) \(lastName)\(thanksStr)"
        var message = MockMessage(agentName: "", agentMessage: messageString, doNotRespond: true,
                                  sender: Sender(id: "agentMessage",
                                                 displayName: "agentMessage"),
                                  messageId: UUID().uuidString,
                                  date: Date())
        message.delay = Double((response.delay ?? 0)/1000)
        message.messageSequance = (self.viewModel.arrayOfMessages2D.last?.first?.messageSequance ?? 0)+1/// self.viewModel.arrayOfMessages2D.count + 1
        message.enableSpecificMsgReply = true/*false*/
        /*var dateMessage = MockMessage(dateFeedback: "",
                                      sender: Sender(id: "agentMessage",
                                                     displayName: "agentMessage"),
                                      messageId: UUID().uuidString,
                                      date: Date())
        dateMessage.messageSequance = message.messageSequance
        self.viewModel.arrayOfMessages2D.append([message, dateMessage])*/
        self.btnSendMessage.isUserInteractionEnabled = true
        self.viewModel.arrayOfMessages2D.append([message])

        var waitingMessage = MockMessage(agentName: "", agentStatus: LanguageManager.shared.localizedString(forKey: "Waiting for agent"), sender: Sender(id: "agentStatus", displayName: "agentStatus"), messageId: UUID().uuidString, date: Date())
        waitingMessage.messageSequance = (self.viewModel.arrayOfMessages2D.last?.first?.messageSequance ?? 0)+1
        waitingMessage.enableSpecificMsgReply = false
        self.viewModel.arrayOfMessages2D.append([waitingMessage])

        self.chatTableView.beginUpdates()
        let sectionsToAdd = IndexSet(arrayLiteral: self.viewModel.arrayOfMessages2D.count-2, self.viewModel.arrayOfMessages2D.count-1)
        self.chatTableView.insertSections(sectionsToAdd, with: .none)
        self.chatTableView.endUpdates()

        self.scrollChatTableToBottom(isAnimate: false)
    }

    func updateLiveAgentButton() {
        // If live_agnt_visiblity true then show live agent button and callTransferType should be none
        if self.viewModel.configIntegrationModel?.liveAgntVisiblity == true && self.viewModel.callTransferType == .none {
            if self.viewLiveAgent.isHidden == true {
                self.viewLiveAgent.isHidden = false
                self.wConstraintLiveAgent.constant = 30
                self.viewLiveAgent.isUserInteractionEnabled = true
            } else {}
        } else {
            if self.viewLiveAgent.isHidden == false {
                self.viewLiveAgent.isHidden = true
                self.wConstraintLiveAgent.constant = 0
            } else {}
        }
        self.btnSendMessage.isUserInteractionEnabled = true
    }

    private func showAgentUnreadMessagesIfAvailable() {
        self.viewModel.unreadCount += 1
        if self.viewModel.unreadMessageIndexPath != nil, self.viewModel.unreadCount > 0 {
            var message = MockMessage(agentName: "", agentStatus: "\(Int(self.viewModel.unreadCount)) \(LanguageManager.shared.localizedString(forKey: "unread message(s)"))", sender: Sender(id: "agentStatus", displayName: "agentStatus"), messageId: UUID().uuidString, date: Date())
            message.messageSequance = self.viewModel.arrayOfMessages2D[self.viewModel.unreadMessageIndexPath?.section ?? 0].first?.messageSequance ?? 0
            message.enableSpecificMsgReply = false
            self.viewModel.arrayOfMessages2D[self.viewModel.unreadMessageIndexPath?.section ?? 0] = [message]
            self.chatTableView.reloadSections(IndexSet(integer: self.viewModel.unreadMessageIndexPath?.section ?? 0), with: .none)
        }else{
            if self.viewModel.unreadCount > 0{
                var message = MockMessage(agentName: "", agentStatus: "\(Int(self.viewModel.unreadCount)) \(LanguageManager.shared.localizedString(forKey: "unread message(s)"))", sender: Sender(id: "agentStatus", displayName: "agentStatus"), messageId: UUID().uuidString, date: Date())
                message.messageSequance = (self.viewModel.arrayOfMessages2D.last?.first?.messageSequance ?? 0)+1//self.viewModel.arrayOfMessages2D.count + 1
                message.enableSpecificMsgReply = false
                self.viewModel.arrayOfMessages2D.append([message])
                self.viewModel.unreadMessageIndexPath = IndexPath(row: 0, section: self.viewModel.arrayOfMessages2D.count - 1)
                self.chatTableView.beginUpdates()
                self.chatTableView.insertSections(IndexSet(integer: self.viewModel.arrayOfMessages2D.count-1), with: .none)
                self.chatTableView.endUpdates()
            }
        }
    }
    
    func handleTIDSConversation(message: XMPPMessage) {
        let removedCDATA = message.body?.replacingOccurrences(of: "![CDATA[", with: "")
        let removedBracket = removedCDATA?.dropLast().dropLast()
        let removedBackSlash = removedBracket?.replacingOccurrences(of: "", with: "")

        if let data = removedBackSlash?.data(using: .utf8) {
            do {
                if let jsonDict = try? (JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any]) {
                    if jsonDict["welcome_msg_check"] as? Bool == true {
                        self.viewModel.isChatToolWaitingForAgent = true
                        CustomLoader.hide()
                    } else {
                        if self.viewModel.showUnreadCount && jsonDict["doNotRespond"] == nil {
                            self.showAgentUnreadMessagesIfAvailable()
                        }
                        if let msg = jsonDict["msg"] as? String {
                            let isDoNotRespond: Bool = jsonDict["doNotRespond"] as? Bool ?? false
                            var isQueuedMessage: Bool = false
                            var replyToMessageDict: [String: Any] = [:]
                            if let queued = jsonDict["queued"] as? Bool {
                                isQueuedMessage = queued
                                if queued == true {
                                    self.viewBGQueue.isHidden = false
                                    self.viewQueue.isHidden = false
                                    self.lblQueueMessage.text = msg
                                } else {}
                            } else {
                                self.viewBGQueue.isHidden = true
                                self.viewQueue.isHidden = true
                            }
                            
                            if isQueuedMessage == false {
                                if msg.count > 0 {
                                    // Check for Previous Message
                                    if self.viewModel.lastMessageCDATA == message.body {
                                    } else {
                                        self.viewModel.lastMessageCDATA = ""
                                        if let replyToMessage = jsonDict["replyToMessage"] as? [String: Any] {
                                            if replyToMessage.count > 0 {
                                                replyToMessageDict = replyToMessage
                                            }
                                        }
                                        var message = MockMessage(agentName: message.from?.resource ?? "", agentMessage: msg, doNotRespond: isDoNotRespond,
                                                                  sender: Sender(id: "agentMessage",
                                                                                 displayName: "agentMessage"),
                                                                  messageId: UUID().uuidString,
                                                                  date: Date())
                                        message.repliedMessageDict = replyToMessageDict
                                        message.delay = 0
                                        message.enableSpecificMsgReply = true/*!isDoNotRespond*/
                                        message.messageSequance = (self.viewModel.arrayOfMessages2D.last?.first?.messageSequance ?? 0)+1// self.viewModel.arrayOfMessages2D.count + 1
                                        message.isShowTypingEffectAnimation = true
                                        self.viewModel.arrayOfMessages2D.append([message])
                                        /*
                                        var dateMessage = MockMessage(dateFeedback: "",
                                                                      sender: Sender(id: "agentMessage",
                                                                                     displayName: "agentMessage"),
                                                                      messageId: UUID().uuidString,
                                                                      date: Date())
                                        dateMessage.messageSequance = message.messageSequance
                                        self.viewModel.arrayOfMessages2D.append([message, dateMessage])*/
                                        UIView.performWithoutAnimation {
                                            self.chatTableView.beginUpdates()
                                            self.chatTableView.insertSections(IndexSet(integer: self.viewModel.arrayOfMessages2D.count-1), with: .none)
                                            self.chatTableView.endUpdates()
                                        }
                                        CustomLoader.hide()
                                        self.scrollChatTableToBottom(isAnimate: true)
                                        self.btnSendMessage.isUserInteractionEnabled = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        if self.viewModel.isChatToolWaitingForAgent {
            self.viewModel.isChatToolWaitingForAgent = false
            self.viewModel.isAgentConnectedToChat = false
            var waitingMessage = MockMessage(agentName: "", agentStatus: LanguageManager.shared.localizedString(forKey: "Waiting for agent"), sender: Sender(id: "agentStatus", displayName: "agentStatus"), messageId: UUID().uuidString, date: Date())
            waitingMessage.messageSequance = (self.viewModel.arrayOfMessages2D.last?.first?.messageSequance ?? 0)+1// self.viewModel.arrayOfMessages2D.count + 1
            waitingMessage.enableSpecificMsgReply = false
            self.checkMessageIndexAndAddToArray(message: waitingMessage)

            // self.viewModel.waitingForAgentIndexPath = IndexPath(row: 0, section: self.viewModel.arrayOfMessages2D.count - 1)

            self.reloadAndScrollToBottom(isAnimate: true)

            self.viewModel.callTransferType = .tids
            self.viewModel.isPokedByAgent = false
            self.btnSendMessage.isUserInteractionEnabled = true
        }

        let data: Data? = message.description.data(using: .utf8)

        // let xml = try? XML.parse(data ?? Data())
        let xml = XML.parse(data ?? Data())
        if self.viewModel.callTransferType == .tids || self.viewModel.isPokedByAgent {
            var model = self.viewModel.TIDSCallTransferModel

            var agentName: String = ""

            // Agent Name
            if let from = xml.element?.childElements[0].attributes["from"] {
                let split = from.components(separatedBy: "/")
                if split.count > 1 {
                    model.agentName = "\(split[1])"
                    agentName = "\(split[1])"
                } else { }
            } else { }

            // Join Status
            if let agentJoin = xml.element?.childElements[0].attributes["agentjoin"] {
                if agentJoin == "join" {
                    if self.viewModel.isPokedByAgent == false {
                        model.agentJoinStatus = .agentJoin
                        self.viewModel.isAgentConnectedToChat = true
                        if VAConfigurations.isChatTool {
                            self.viewModel.isChatToolChatClosed = false
                        }
                        let connectStr = LanguageManager.shared.localizedString(forKey: "is now connected to chat")
                        var message = MockMessage(agentName: agentName, agentStatus: connectStr, sender: Sender(id: "agentStatus", displayName: "agentStatus"), messageId: UUID().uuidString, date: Date())
                        // TODO: Check message sequence
                        message.messageSequance = (self.viewModel.arrayOfMessages2D.last?.first?.messageSequance ?? 0)+1
                        message.enableSpecificMsgReply = false
                        
                        let waitingForAgentMsg = LanguageManager.shared.localizedString(forKey: "Waiting for agent")
                        var isWaitingForAgentMsg = false
                        var agentMsgIndex = 0
                        for (index, item) in self.viewModel.arrayOfMessages2D.reversed().enumerated() {
                            if item.first?.sender.id == "agentStatus" {
                                switch item.first?.kind {
                                case .agentStatus(let status):
                                    if status.statusMessage?.status == waitingForAgentMsg {
                                        isWaitingForAgentMsg = true
                                        message.messageSequance = item.first!.messageSequance
                                        agentMsgIndex = self.viewModel.arrayOfMessages2D.count - index - 1
                                        break
                                    }
                                default:
                                    break
                                }
                            }
                            if isWaitingForAgentMsg {
                                break
                            }
                        }
                        if isWaitingForAgentMsg {
                            self.viewModel.arrayOfMessages2D[agentMsgIndex] = [message]
                            self.chatTableView.beginUpdates()
                            self.chatTableView.reloadSections(IndexSet(integer: agentMsgIndex), with: .none)
                            self.chatTableView.endUpdates()
                        } else {
                            self.viewModel.arrayOfMessages2D.append([message])
                            self.chatTableView.beginUpdates()
                            self.chatTableView.insertSections(IndexSet(integer: self.viewModel.arrayOfMessages2D.count-1), with: .none)
                            self.chatTableView.endUpdates()
                        }
                        self.scrollChatTableToBottom(isAnimate: false)
                        self.viewBGQueue.isHidden = true
                        self.viewQueue.isHidden = true
                        // Show TextView  if open from ChatTool
                        if self.viewTextInputBG.isHidden, VAConfigurations.isChatTool, !VAConfigurations.isChatbotMinimized {
                            self.viewTextInputBG.isHidden = false
                            self.txtViewMessage.text = self.viewModel.defaultPlaceholder
                        }
                    }
                    self.btnSendMessage.isUserInteractionEnabled = true
                } else if agentJoin == "unjoin"{
                    if self.viewModel.isPokedByAgent == false {
                        model.agentJoinStatus = .agentUnJoin
                        self.viewModel.isAgentConnectedToChat = false
                        if VAConfigurations.isChatTool {
                            self.viewModel.isChatToolChatClosed = true
                        }
                        let disconnectStr = LanguageManager.shared.localizedString(forKey: "has disconnected the chat")

                        var message = MockMessage(agentName: agentName, agentStatus: disconnectStr, sender: Sender(id: "agentStatus", displayName: "agentStatus"), messageId: UUID().uuidString, date: Date())
                        message.messageSequance = (self.viewModel.arrayOfMessages2D.last?.first?.messageSequance ?? 0)+1// self.viewModel.arrayOfMessages2D.count  + 1
                        message.enableSpecificMsgReply = false
                        let waitingForAgentMsg = LanguageManager.shared.localizedString(forKey: "Waiting for agent")
                        var isWaitingForAgentMsg = false
                        var agentMsgIndex = 0
                        for (index, item) in self.viewModel.arrayOfMessages2D.reversed().enumerated() {
                            if item.first?.sender.id == "agentStatus" {
                                switch item.first?.kind {
                                case .agentStatus(let status):
                                    if status.statusMessage?.status == waitingForAgentMsg {
                                        isWaitingForAgentMsg = true
                                        message.messageSequance = item.first!.messageSequance
                                        agentMsgIndex = self.viewModel.arrayOfMessages2D.count - index - 1
                                        break
                                    }
                                default:
                                    break
                                }
                            }
                            if isWaitingForAgentMsg {
                                break
                            }
                        }
                        if isWaitingForAgentMsg {
                            self.viewModel.arrayOfMessages2D[agentMsgIndex] = [message]
                            self.chatTableView.beginUpdates()
                            self.chatTableView.reloadSections(IndexSet(integer: agentMsgIndex), with: .none)
                            self.chatTableView.endUpdates()
                        } else {
                            self.viewModel.arrayOfMessages2D.append([message])
                            self.chatTableView.beginUpdates()
                            self.chatTableView.insertSections(IndexSet(integer: self.viewModel.arrayOfMessages2D.count-1), with: .none)
                            self.chatTableView.endUpdates()
                        }
                        self.scrollChatTableToBottom(isAnimate: false)
                        // Hide TextView if open from ChatTool
                        if VAConfigurations.isChatTool {
                            self.viewTextInputBG.isHidden = true
                            self.viewShowReplyMessage.isHidden = true
                            self.viewModel.isChatToolChatClosed = true
                            self.viewModel.isAgentConnectedToChat = false
                            UIView.performWithoutAnimation {
                                self.chatTableView.reloadData()
                            }
                        }
                    } else {
                        self.viewModel.isPokedByAgent = false
                    }
                    self.viewModel.callTransferType = .none
                    self.viewModel.isCallTransfer = false
                    self.hideReset()
                    self.updateLiveAgentButton()
                } else {
                    self.btnSendMessage.isUserInteractionEnabled = true
                    model.agentJoinStatus = .none
                }
            } else {}

            // Typing Status
            if let arrayChildElement = xml.element?.childElements[0].childElements {
                for index in 0..<arrayChildElement.count {
                    if arrayChildElement[index].name == "composing"{
                        model.typingStatus = .composing
                        ///Showing agent typing status
                        if !VAConfigurations.isChatbotMinimized {
                            self.imgViewTyping.isHidden = false
                        }
                        break
                    } else if arrayChildElement[index].name == "paused"{
                        model.typingStatus = .paused
                        self.imgViewTyping.isHidden = true
                        break
                    } else {
                        model.typingStatus = .none
                        self.imgViewTyping.isHidden = true
                    }
                }
            } else {
                model.typingStatus = .none
                self.imgViewTyping.isHidden = true
            }

            self.viewModel.TIDSCallTransferModel = model
        }
    }

    func handleGenesysCallTransfer(response: MessageResponse) {
        // Check for header
        if response.headers.count > 0 {
            // Check for native_callback_transfer
            let headerDict = response.headers
            var nativeTransfer: Bool = false
            if let nativeTransferAsBool = headerDict["native_callback_transfer"] as? Bool {
                nativeTransfer = nativeTransferAsBool
            } else if let nativeTransferAsString =  headerDict["native_callback_transfer"] as? String {
                if nativeTransferAsString.lowercased() == "true"{
                    nativeTransfer = true
                } else {
                    nativeTransfer = false
                }
            } else {
                nativeTransfer = false
            }

            if nativeTransfer == true { // Native transfer
                self.sendUserMessageToServer(data: "", showLabelText: "", templateId: nil, isQuery: false, context: [], templateUid: "", query: "", userMessageId: "\(self.viewModel.messageData?.userMessageId ?? 0)", actualIntent: self.viewModel.messageData?.actualIntent ?? [], senderMessageType: SenderMessageType.text)
                DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                    UserDefaultsManager.shared.resetAllUserDefaults()
                    VAConfigurations.virtualAssistant?.delegate?.initiateNativeCallTransfer!(data: headerDict)
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
            } else { // Non native transfer
                self.openAgentTransfer(url: response.url)
            }
        } else {
            // header empty
            self.openAgentTransfer(url: response.url)
        }
    }

    func showAgentOnlineOrAwayStatus(state: UserStatus) {
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
                case .active:
                    let xmppMessage = XMPPMessage(from: completeMessage)
                    xmppMessage.addActiveChatState()
                    xmppController?.xmppStream.send(completeMessage)
                case .inactive:
                    let xmppMessage = XMPPMessage(from: completeMessage)
                    xmppMessage.addInactiveChatState()
                    xmppController?.xmppStream.send(completeMessage)
                case .close:
                    debugPrint("")
                }
            }
        }
    }

    func openAgentTransfer(url: String) {
        // Agent call transfer
        if let agentTransferVC = storyboardObj.instantiateViewController(withIdentifier: "AgentTransferVC") as? AgentTransferVC {
            agentTransferVC.titleString = LanguageManager.shared.localizedString(forKey: "Genesys Call Transfer")
            agentTransferVC.webUrl = url
            agentTransferVC.modalPresentationStyle = .overCurrentContext
            agentTransferVC.delegate = self
            agentTransferVC.isGenAINewTheme = self.isNewGenAITheme
            self.navigationController?.pushViewController(agentTransferVC, animated: true)
        }
    }
}
