// VAChatView+HistoryMessages.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import Foundation
import XMPPFramework
import SwiftyXMLParser

extension VAChatViewController {

    func sendHistoryIQ(lastMsgID: String) {
        self.viewModel.arrayOfSuggestions.removeAll()
        if !self.viewModel.arrayOfMessages2D.isEmpty {
            CustomLoader.show()
            self.viewModel.arrayOfMessages2D.removeAll()
            UIView.performWithoutAnimation {
                self.chatTableView.reloadData()
            }
        }
        if self.viewSuggestions.isHidden == false {
            self.viewSuggestions.isHidden = true
        }
        self.viewModel.messageData = nil
        if let iq = DDXMLElement.element(withName: "iq") as? DDXMLElement {
            iq.addAttribute(withName: "from",
                            stringValue: "\(VAConfigurations.userUUID)@\(VAConfigurations.vHost)")// username+"@"+VHOST
            iq.addAttribute(withName: "to", stringValue: VAConfigurations.vHost)// VHOST....
            iq.addAttribute(withName: "type", stringValue: "get")
            iq.addAttribute(withName: "xmlns", stringValue: "jabber:client")
            
            if let query = DDXMLElement.element(withName: "query") as? DDXMLElement {
                query.addAttribute(withName: "last_msg_id", stringValue: lastMsgID)
                if VAConfigurations.isChatTool, VAConfigurations.skill.isEmpty == false {
                    query.addAttribute(withName: "maxstanza", stringValue: "500")
                } else {
                    query.addAttribute(withName: "maxstanza", stringValue: "100")
                }
                query.addAttribute(withName: "xmlns", stringValue: "xavbot:get:history")
                iq.addChild(query)
                print("Get History IQ:\n\(iq)")
                xmppController.xmppStream.send(iq)
            }
        }
    }

    func invalidateHistoryMessagesReloadTimer() {
        self.historyMessagesReloadTimer?.invalidate()
        self.historyMessagesReloadTimer = nil
    }

    func restartHistoryMessagesReloadTimer() {
        self.invalidateSpeechDelayTimer()
        let fireDate = Date().addingTimeInterval(TimeInterval(3.0))
        self.historyMessagesReloadTimer = Timer(fireAt: fireDate, interval: 3.0, target: self, selector: #selector(self.reloadHistoryMessageTimerFired), userInfo: nil, repeats: false)
        RunLoop.main.add(self.historyMessagesReloadTimer!, forMode: RunLoop.Mode.common)
    }

    @objc func reloadHistoryMessageTimerFired() {
        // debugPrint("Reload history message timer fired : \(self.isHistoryMessage)")
        if self.isHistoryMessage {
            // debugPrint("Reloaded history messages using timer")
            self.invalidateHistoryMessagesReloadTimer()
            self.reloadHistoryMessages()
        }
    }

    private func getHistoryMsgTime(timeStr: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.calendar = Calendar.current
        formatter.timeZone = TimeZone.current
        guard let date = formatter.date(from: timeStr) else {
            return Date()
        }
        return date
    }

    func handleHistoryMessagesAgent(message: XMPPMessage, messageData: MessageData, jsonDict: [String: Any], xml: XML.Accessor?, msgTime: Date) {
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
                            } else {
                            }
                        } else {
                        }
                        var messages: [MockMessage] = []
                        var message = MockMessage(agentName: message.from?.resource ?? "", agentMessage: msg, doNotRespond: isDoNotRespond,
                                                  sender: Sender(id: "agentMessage",
                                                                 displayName: "agentMessage"),
                                                  messageId: UUID().uuidString,
                                                  date: msgTime)
                        message.repliedMessageDict = replyToMessageDict
                        message.delay = 0
                        message.enableSpecificMsgReply = true/*!isDoNotRespond*/
                        messages.append(message)
                        self.viewModel.arrayOfMessages2D.insert(messages, at: 0)
                        /*if !messages.isEmpty {
                            var dateMessage = MockMessage(dateFeedback: "",
                                                          sender: Sender(id: "agentMessage",
                                                                         displayName: "agentMessage"),
                                                          messageId: UUID().uuidString,
                                                          date: Date())
                            dateMessage.messageSequance = message.messageSequance
                            messages.append(dateMessage)
                            self.viewModel.arrayOfMessages2D.insert(messages, at: 0)
                        }*/
                    }
                }
            }
        }
    }
    
    func handleOracleCallTransferQueueHistory(messageData: MessageData, jsonDict: [String: Any]) {
        self.viewBGQueue.isHidden = false
        self.viewQueue.isHidden = false
        // let queueMsg = ((((jsonDict["content"] as? [String:Any])?["response_list"] as? [[String:Any]])?.first as? [String:Any])?["response"] as? [String])?.first ?? ""
        let queueMsg = LanguageManager.shared.localizedString(forKey: "You are no longer connnected with live agent.")
        self.viewModel.isQueueBannerForOracle = true
        self.lblQueueMessage.text = queueMsg
    }

    func handleHistoryMessages(message: XMPPMessage, messageData: MessageData, messageStr: String?) {
        self.restartHistoryMessagesReloadTimer()
        var isHistoryMsgFromSender = false
        var msgTime = Date()
        if message.body == "*******" {
            self.handleOffTheRecordConversationHistory(message: message, messageData: messageData)
        } else {
            if let data = messageStr?.data(using: .utf8) {
                do {
                    if let jsonDict = try? (JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any]) {
                        let data: Data? = message.description.data(using: .utf8)
                        // let xml = try? XML.parse(data ?? Data())
                        let xml = XML.parse(data ?? Data())
                        let timeStamp = xml.element?.childElements[0].childElements[1].attributes["stamp"]
                        let msgId = Int(xml.element?.childElements.first?.attributes["msg_id"] as? String ?? "0") ?? 0
                        msgTime = getHistoryMsgTime(timeStr: timeStamp ?? "")
                        
                        let isSelfMsg = jsonDict["selfMsg"] as? Bool ?? false
                        let isQueued = jsonDict["queued"] as? Bool ?? false
                        // let isQueuedOracleTransfer = (((jsonDict["content"] as? [String:Any])?["optional"] as? [String:Any])?["live_agent"] as? String ?? "") == "queue" ? true : false
                        let isDoNotRespond = jsonDict["doNotRespond"] as? Bool ?? false
                        if let agentJoin = jsonDict["agentjoin"] as? String {
                            var agentName: String = ""
                            if let from = xml.element?.childElements[0].attributes["from"] {
                                let split = from.components(separatedBy: "/")
                                if split.count > 1 {
                                    agentName = "\(split[1])"
                                }
                            }
                            if agentJoin == "join" && isDoNotRespond {
                                let connectStr = LanguageManager.shared.localizedString(forKey: "is now connected to chat")
                                let completeMsg = "\(agentName) \(connectStr)"
                                var message = MockMessage(agentName: agentName, agentStatus: connectStr, sender: Sender(id: "agentStatus", displayName: "agentStatus"), messageId: UUID().uuidString, date: msgTime)
                                message.messageSequance = 1
                                message.enableSpecificMsgReply = !isDoNotRespond
                                var isAddMsg = true
                                if !self.viewModel.arrayOfMessages2D.isEmpty {
                                    let oldMessage = self.viewModel.arrayOfMessages2D.first?.first
                                    switch oldMessage?.kind {
                                    case .agentStatus(let status):
                                        let oldMsgStatus = status.statusMessage?.status ?? ""
                                        if oldMsgStatus == completeMsg {
                                            isAddMsg = false
                                        }
                                    default:
                                        break
                                    }
                                }
                                if isAddMsg {
                                    self.viewModel.arrayOfMessages2D.insert([message], at: 0)
                                } else {
                                    return
                                }
                                self.viewBGQueue.isHidden = true
                                self.viewQueue.isHidden = true
                            } else if agentJoin == "unjoin" && isDoNotRespond {
                                let disconnectStr = LanguageManager.shared.localizedString(forKey: "has disconnected the chat")
                                let completeMsg = "\(agentName) \(disconnectStr)"
                                var message = MockMessage(agentName: agentName, agentStatus: disconnectStr, sender: Sender(id: "agentStatus", displayName: "agentStatus"), messageId: UUID().uuidString, date: msgTime)
                                message.messageSequance = 1
                                message.enableSpecificMsgReply = !isDoNotRespond
                                var isAddMsg = true
                                if !self.viewModel.arrayOfMessages2D.isEmpty {
                                    let oldMessage = self.viewModel.arrayOfMessages2D.first?.first
                                    switch oldMessage?.kind {
                                    case .agentStatus(let status):
                                        let oldMsgStatus = status.statusMessage?.status ?? ""
                                        if oldMsgStatus == completeMsg {
                                            isAddMsg = false
                                        }
                                    default:
                                        break
                                    }
                                }
                                if isAddMsg {
                                    self.viewModel.arrayOfMessages2D.insert([message], at: 0)
                                } else {
                                    return
                                }
                            }
                            return
                        }
                        if VAConfigurations.isChatTool && (msgId <= 1 || (self.viewModel.sessionStartMsg + 1) == msgId) {
                            var replyToMessageDict: [String: Any] = [:]
                            if let replyToMessage = jsonDict["replyToMessage"] as? [String: Any] {
                                if replyToMessage.count > 0 {
                                    replyToMessageDict = replyToMessage
                                }
                            }
                            var message = MockMessage(agentName: message.from?.resource ?? "", agentMessage: jsonDict["msg"] as? String ?? "", doNotRespond: isDoNotRespond,
                                                      sender: Sender(id: "agentMessage",
                                                                     displayName: "agentMessage"),
                                                      messageId: UUID().uuidString,
                                                      date: msgTime)
                            message.repliedMessageDict = replyToMessageDict
                            message.delay = 0
                            message.messageSequance = 1
                            message.enableSpecificMsgReply = true/*!isDoNotRespond*/
                            self.viewModel.arrayOfMessages2D.insert([message], at: 0)
                            /*var dateMessage = MockMessage(dateFeedback: "",
                             sender: Sender(id: "agentMessage",
                             displayName: "agentMessage"),
                             messageId: UUID().uuidString,
                             date: msgTime)
                             dateMessage.messageSequance = 1
                             self.viewModel.arrayOfMessages2D.insert([message, dateMessage], at: 0)*/
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15 ) {
                                self.reloadHistoryMessages()
                            }
                            return
                        } else if isQueued || isSelfMsg || isDoNotRespond {
                            return
                        }
                        if let messageFrom = message.from?.full {
                            if let historySender = messageFrom.components(separatedBy: "@").last {
                                let currentSender = "conference.\(VAConfigurations.vHost)/\(VAConfigurations.userUUID.lowercased())"
                                if currentSender == historySender {
                                    debugPrint("History message from sender:  \(jsonDict["msg"] as? String ?? "")")
                                    isHistoryMsgFromSender = true
                                } else {
                                    debugPrint("History message from bot:  \(jsonDict["msg"] as? String ?? "")")
                                }
                            }
                        }
                        if isHistoryMsgFromSender {
                            let msg = jsonDict["msg"] as? String ?? ""
                            let isWelcomeMsg = jsonDict["welcome_msg_check"] as? Bool ?? false
                            let showLabelText = jsonDict["showLabelText"] as? String ?? ""
                            let isMsgTyped = jsonDict["is_typed"] as? Bool ?? true
                            let isMaskedMsg = jsonDict["isMaskedInput"] as? Bool ?? false
                            if let userFeedback = jsonDict["thumbsup"] as? Bool {
                                self.historyMsgFeedback = userFeedback
                                if isNewGenAITheme {
                                    if self.viewModel.arrayOfMessages2D.isEmpty {
                                        /// If last msg in history was feedback and text feedback is disabled then only thumbs up & down feedback will show
                                        self.setupFeedbackMsgForHistoryGenAI(messageData: messageData, isThumbsUp: userFeedback)
                                        return
                                    } else {
                                        switch self.viewModel.arrayOfMessages2D[0][0].kind {
                                        case .feedbackItem(_):
                                            break
                                        default:
                                            self.setupFeedbackMsgForHistoryGenAI(messageData: messageData, isThumbsUp: userFeedback)
                                            return
                                        }
                                    }
                                }
                            }
                            if !isWelcomeMsg && (isMsgTyped || !msg.isEmpty ) {
                                if jsonDict["qrCode"] != nil {
                                    let qrCodeImg = self.generateQRCode(from: jsonDict["qrCode"] as? String ?? "")
                                    var message = MockMessage(imageItem: ImageItem(url: "", isShowSenderIcon: true, image: qrCodeImg), sender: Sender(id: VAConfigurations.userUUID.lowercased(), displayName: VAConfigurations.customData?.userName ?? ""), messageId: UUID().uuidString, date: msgTime)
                                    message.sentiment = self.viewModel.messageData?.sentiment ?? 0
                                    message.messageSequance = 1 ///Message sequence is updated after loading all history message in reloadHistoryMessages function.
                                    message.masked = isMaskedMsg
                                    
                                    self.viewModel.arrayOfMessages2D.insert([message], at: 0)
                                } else if jsonDict["digitalSign"] != nil {
                                    /*let base64Regex = "^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$"
                                     let predicate = NSPredicate(format: "SELF MATCHES %@", base64Regex)
                                     let isBase64EncodedStr = predicate.evaluate(with: msg)*/
                                    let image = convertBase64StringToImage(imageBase64String: msg)
                                    var message = MockMessage(imageItem: ImageItem(url: "", isShowSenderIcon: true, image: image), sender: Sender(id: VAConfigurations.userUUID.lowercased(), displayName: VAConfigurations.customData?.userName ?? ""), messageId: UUID().uuidString, date: msgTime)
                                    message.sentiment = self.viewModel.messageData?.sentiment ?? 0
                                    message.messageSequance = 1
                                    message.masked = isMaskedMsg
                                    self.viewModel.arrayOfMessages2D.insert([message], at: 0)
                                } else if jsonDict["latLng"] != nil {
                                    let image = UIImage(named: "locationIcon", in: Bundle.module, compatibleWith: nil)
                                    var message = MockMessage(imageItem: ImageItem(url: "", isShowSenderIcon: true, image: image, message: jsonDict["msg"] as? String ?? ""), sender: Sender(id: VAConfigurations.userUUID.lowercased(), displayName: VAConfigurations.customData?.userName ?? ""), messageId: UUID().uuidString, date: msgTime)
                                    message.sentiment = self.viewModel.messageData?.sentiment ?? 0
                                    message.messageSequance = 1
                                    message.masked = isMaskedMsg
                                    self.viewModel.arrayOfMessages2D.insert([message], at: 0)
                                } else if jsonDict["custom_form"] as? Bool == true {
                                    if let formFields = jsonDict["user_details"] as? [String:Any] {
                                        var valuesInserted = 0
                                        var input = ""
                                        var formValues = ""
                                        var formValuesNewTheme: [[String:String]] = []
                                        for (key, value) in formFields {
                                            if !((value as? String ?? "").isEmpty) {
                                                let keyName = key.replacingOccurrences(of: "_", with: " ").capitalized
                                                valuesInserted += 1
                                                if valuesInserted < formFields.keys.count {
                                                    input = "<b>\(keyName)</b><br>\(value)<br><br>"
                                                        //"<b>\(keyName)</b><br>\(value)<br>----------------------------------<br>"
                                                } else {
                                                    input = "<b>\(keyName)</b><br>\(value)"
                                                }
                                                if self.isNewGenAITheme {
                                                    formValuesNewTheme.append(["title": keyName, "desc": "\(value)"])
                                                } else {
                                                    formValues.append(input)
                                                }
                                            }
                                        }
                                        if self.isNewGenAITheme {
                                            do {
                                                let data =  try JSONSerialization.data(withJSONObject:formValuesNewTheme, options: .prettyPrinted)
                                                formValues = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
                                            } catch {
                                                print(error.localizedDescription)
                                            }
                                        }
                                        var message = MockMessage(text: formValues.isEmpty ? "Form: No input provided" : formValues, isFormFields: true, sender: Sender(id: VAConfigurations.userUUID.lowercased(), displayName: VAConfigurations.customData?.userName ?? ""), messageId: UUID().uuidString, date: msgTime)
                                        message.sentiment = self.viewModel.messageData?.sentiment ?? 0
                                        message.messageSequance = 1
                                        message.masked = isMaskedMsg
                                        self.viewModel.arrayOfMessages2D.insert([message], at: 0)
                                    }
                                } else {
                                    guard !(isNewGenAITheme && (jsonDict["is_text_feedback"] as? Bool) == true) else {
                                        isGenAiTextFeedbackHistory = true
                                        return
                                    }
                                    var userMsg = showLabelText.isEmpty ? msg : showLabelText.trimHTMLTags() ?? ""
                                    if isMaskedMsg {
                                        userMsg = String(repeating: "●", count: 10)
                                    } else {
                                        let allowedChars = "*"
                                        let redactedStr = Set(userMsg)
                                        let isRedactedText = redactedStr.isSubset(of: allowedChars)
                                        if isRedactedText {
                                            userMsg = String(repeating: "*", count: userMsg.count)
                                        }
                                    }
                                    var message = MockMessage(text: userMsg, sender: Sender(id: VAConfigurations.userUUID.lowercased(), displayName: VAConfigurations.customData?.userName ?? ""), messageId: UUID().uuidString, date: msgTime)
                                    message.sentiment = self.viewModel.messageData?.sentiment ?? 0
                                    message.messageSequance = 1
                                    message.masked = isMaskedMsg
                                    if VAConfigurations.isChatTool {
                                        var replyToMessageDict: [String: Any] = [:]
                                        if let replyToMessage = jsonDict["replyToMessage"] as? [String: Any] {
                                            if replyToMessage.count > 0 {
                                                replyToMessageDict = replyToMessage
                                            }
                                        }
                                        message.repliedMessageDict = replyToMessageDict
                                        message.enableSpecificMsgReply = true
                                    }
                                    self.viewModel.arrayOfMessages2D.insert([message], at: 0)
                                }
                            } else if isWelcomeMsg && !isMsgTyped {
                                debugPrint("All history messages completed now reload the table")
                                self.reloadHistoryMessages()
                            }
                        } else {
                            var isLiveAgent = false
                            var hasBotResponse = false
                            var isOracleTransferQueued = false
                            if self.viewModel.messageData == nil {
                                self.viewModel.messageData = messageData
                            }
                            if let content = jsonDict["content"] as? [String: Any] {
                                if let optional = content["optional"] as? [String: Any] {
                                    if let liveAgent = optional["live_agent"] as? Bool {
                                        isLiveAgent = liveAgent
                                    }
                                    if let liveAgent = optional["live_agent"] as? String {
                                        isOracleTransferQueued = liveAgent == "queue" ? true : false
                                    }
                                }
                                if !isLiveAgent {
                                    if let responseList = content["response_list"] as? [[String: Any]] {
                                        hasBotResponse = responseList.count > 0
                                    }
                                }
                                
                            }
                            if let content = jsonDict["content"] as? [String: Any] {
                                if isNewGenAITheme && (content["thumbs_feedback"] as? Bool ?? false) {
                                    self.setupFeedbackMsgForHistoryGenAI(messageData: messageData, isThumbsUp: (content["feedback"] as? String)?.lowercased() == "up" ? true : false)
                                    return
                                }
                            }
                            if messageData.responseList.first?.responseType == "call_transfer" {
                                return
                            }
                            if isOracleTransferQueued && self.viewModel.arrayOfMessages2D.isEmpty {
                                self.handleOracleCallTransferQueueHistory(messageData: messageData, jsonDict: jsonDict)
                            } else if (self.viewModel.callTransferType == .tids || VAConfigurations.isChatTool || self.viewModel.isPokedByAgent) && !hasBotResponse {
                                self.handleHistoryMessagesAgent(message: message, messageData: messageData, jsonDict: jsonDict, xml: xml, msgTime: msgTime)
                            } else {
                                var messages: [MockMessage] = []
                                for index in 0...messageData.responseList.count {
                                    if isNewGenAITheme {
                                        if index == 0 {
                                            ///Date Msg
                                            let dateMsg = self.setupDateMsgForHistory(message: message, messageData: messageData, msgTime: msgTime)
                                            messages.append(dateMsg!)
                                        } else {
                                            ///Other Msgs
                                            let msg = self.setupHistoryMessage(message: message, messageData: messageData, msgIndex: index-1)
                                            messages.append(msg!)
                                            if index == messageData.responseList.count {
                                                /// Insert feedback card under its response
                                                if !self.viewModel.arrayOfMessages2D.isEmpty && self.viewModel.arrayOfMessages2D[0].count == 1 {
                                                    switch self.viewModel.arrayOfMessages2D[0][0].kind {
                                                    case .feedbackItem(_):
                                                        var feedbackMsg = self.viewModel.arrayOfMessages2D[0][0]
                                                        feedbackMsg.sender = messages[0].sender
                                                        messages.append(feedbackMsg)
                                                        self.viewModel.arrayOfMessages2D.remove(at: 0)
                                                    default:
                                                        break
                                                    }
                                                }
                                                ///Add messages to array after adding feedback at the end of messages if feedback is present
                                                self.viewModel.arrayOfMessages2D.insert(messages, at: 0)
                                            }
                                        }
                                    } else {
                                        if index == messageData.responseList.count {
                                            if !messages.isEmpty {
                                                ///Date Msg
                                                let dateMsg = self.setupDateMsgForHistory(message: message, messageData: messageData, msgTime: msgTime)
                                                messages.append(dateMsg!)
                                                self.viewModel.arrayOfMessages2D.insert(messages, at: 0)
                                            }
                                        } else {
                                            ///Other Msgs
                                            let msg = self.setupHistoryMessage(message: message, messageData: messageData, msgIndex: index)
                                            messages.append(msg!)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func setupFeedbackMsgForHistoryGenAI(messageData: MessageData, isThumbsUp: Bool) {
        let sender = Sender(id: self.viewModel.arrayOfMessages2D.last?.last?.sender.id ?? "", displayName: self.viewModel.arrayOfMessages2D.last?.last?.sender.displayName ?? "")
        var feedbackMsg = MockMessage(feedbackItem: "", sender: sender, messageId: UUID().uuidString, date: self.viewModel.arrayOfMessages2D.last?.last?.sentDate ?? Date())
        feedbackMsg.messageSequance = self.viewModel.arrayOfMessages2D.last?.last?.messageSequance ?? 1
        feedbackMsg.userMsgId = self.viewModel.arrayOfMessages2D.last?.last?.userMsgId
        feedbackMsg.showBotImage = true
        feedbackMsg.messageSequance = 1
        feedbackMsg.qrCode = false
        feedbackMsg.location = false
        feedbackMsg.allowSign = false
        feedbackMsg.isCustomFormInFlow = false
        feedbackMsg.customForm = messageData.customForm
        feedbackMsg.userMsgId = messageData.userMessageId
        feedbackMsg.isFeedback = true
        feedbackMsg.isThumbsUpFeedback = isThumbsUp
        feedbackMsg.isTextFeedbackProvided = self.isGenAiTextFeedbackHistory
        self.isGenAiTextFeedbackHistory = false
        self.viewModel.arrayOfMessages2D.insert([feedbackMsg], at: 0)
        self.historyMsgFeedback = nil
    }
    func setupDateMsgForHistory(message: XMPPMessage, messageData: MessageData, msgTime: Date) -> MockMessage? {
        let serverMessage = self.getMessage(response: nil, sender: message.from?.user ?? "", messageType: "")
        var newMessageModel = serverMessage.messageArray.first
        newMessageModel?.sentDate = msgTime
        newMessageModel?.showBotImage = isNewGenAITheme ? true : false
        newMessageModel?.messageSequance = 1
        newMessageModel?.qrCode = messageData.qrCode
        newMessageModel?.location = messageData.location
        newMessageModel?.allowSign = messageData.allowSign
        newMessageModel?.isCustomFormInFlow = messageData.isCustomFormInFlow
        newMessageModel?.customForm = messageData.customForm
        newMessageModel?.userMsgId = messageData.userMessageId
        if self.historyMsgFeedback != nil {
            newMessageModel?.isFeedback = true
            newMessageModel?.isThumbsUpFeedback = self.historyMsgFeedback!
        }
        self.historyMsgFeedback = nil
        return newMessageModel
    }
    
    func setupHistoryMessage(message: XMPPMessage, messageData: MessageData, msgIndex: Int) -> MockMessage? {
        var response: MessageResponse = messageData.responseList[msgIndex]
        response.context = messageData.contexts ?? []
        let isShowBotImage = isNewGenAITheme ? false : (msgIndex == 0 ? true : false)
        let serverMessage = self.getMessage(response: response, sender: message.from?.user ?? "", messageType: response.responseType)
        var newMessageModel = serverMessage.messageArray.first
        newMessageModel?.showBotImage = isShowBotImage
        newMessageModel?.isAgent = false
        newMessageModel?.delay = Double(Double(response.delay ?? 0)/Double(1000))
        newMessageModel?.preventTyping = response.preventTyping
        newMessageModel?.isPrompt = messageData.isPrompt ?? false
        newMessageModel?.responseType = response.responseType
        newMessageModel?.replyIndex = messageData.replyIndex ?? 0
        newMessageModel?.isQuickReplyMsg = serverMessage.isQuickReply
        newMessageModel?.sentiment = messageData.sentiment ?? 0
        newMessageModel?.messageSequance = 1
        newMessageModel?.qrCode = messageData.qrCode
        newMessageModel?.location = messageData.location
        newMessageModel?.allowSign = messageData.allowSign
        newMessageModel?.isCustomFormInFlow = messageData.isCustomFormInFlow
        newMessageModel?.customForm = messageData.customForm
        newMessageModel?.userMsgId = messageData.userMessageId
        return newMessageModel
    }
    
    ///Handling of off the record messages in history
    func handleOffTheRecordConversationHistory(message: XMPPMessage, messageData: MessageData) {
        var msgTime = Date()
        let data: Data? = message.description.data(using: .utf8)
        // let xml = try? XML.parse(data ?? Data())
        let xml = XML.parse(data ?? Data())
        let timeStamp = xml.element?.childElements[0].childElements[1].attributes["stamp"]
        let msgId = Int(xml.element?.childElements.first?.attributes["msg_id"] as? String ?? "0") ?? 0
        msgTime = getHistoryMsgTime(timeStr: timeStamp ?? "")
        var isReloadOffTheRecordMsgs = false
        if (self.viewModel.sessionStartMsg + 1) == msgId {
            isReloadOffTheRecordMsgs = true
        }
        if let messageFrom = message.from?.full {
            if let historySender = messageFrom.components(separatedBy: "@").last {
                let currentSender = "conference.\(VAConfigurations.vHost)/\(VAConfigurations.userUUID.lowercased())"
                if currentSender == historySender {
                    debugPrint("off the record History message from sender")
                    if isReloadOffTheRecordMsgs {
                        self.reloadHistoryMessages()
                        return
                    }
                    var message = MockMessage(text: message.body ?? "*******", sender: Sender(id: VAConfigurations.userUUID.lowercased(), displayName: VAConfigurations.customData?.userName ?? ""), messageId: UUID().uuidString, date: msgTime)
                    message.sentiment = self.viewModel.messageData?.sentiment ?? 0
                    message.messageSequance = 1
                    message.masked = false
                    self.viewModel.arrayOfMessages2D.insert([message], at: 0)
                    
                } else {
                    debugPrint("off the record History message from bot")
                    var messages: [MockMessage] = []
                    let responseDict: NSDictionary = ["response": ["\(message.body ?? "*******")"], "response_type": "text"]
                    let response = MessageResponse(responseDict)
                    var serverMessage = self.getMessage(response: response, sender: message.from?.user ?? "", messageType: "text")
                    var newMessageModel = serverMessage.messageArray.first
                    newMessageModel?.showBotImage = true
                    newMessageModel?.isAgent = false
                    newMessageModel?.delay = 0
                    newMessageModel?.responseType = "text"
                    newMessageModel?.messageSequance = 1
                    newMessageModel?.qrCode = false
                    newMessageModel?.location = false
                    newMessageModel?.allowSign = false
                    newMessageModel?.isCustomFormInFlow = false
                    messages.append(newMessageModel!)
                    
                    serverMessage = self.getMessage(response: nil, sender: message.from?.user ?? "", messageType: "")
                    newMessageModel = serverMessage.messageArray.first
                    newMessageModel?.sentDate = msgTime
                    newMessageModel?.showBotImage = false
                    newMessageModel?.messageSequance = 1
                    newMessageModel?.qrCode = false
                    newMessageModel?.location = false
                    newMessageModel?.allowSign = false
                    newMessageModel?.isCustomFormInFlow = false
                    messages.append(newMessageModel!)
                    self.viewModel.arrayOfMessages2D.insert(messages, at: 0)
                    self.historyMsgFeedback = nil
                    
                    if isReloadOffTheRecordMsgs {
                        self.reloadHistoryMessages()
                    }
                }
            }
        }
    }

    func reloadHistoryMessages() {
        self.isHistoryMessage = false
        var messagesToRemove: [Int] = []
        DispatchQueue.main.async {
            self.invalidateHistoryMessagesReloadTimer()
        }
        /// Setting message sequance property for messages
        for index in 0..<self.viewModel.arrayOfMessages2D.count {
            self.viewModel.arrayOfMessages2D[index] = self.viewModel.arrayOfMessages2D[index].map({
                var dict = $0
                dict.messageSequance = index + 1
                return dict
            })
        }
        for index in 0..<self.viewModel.arrayOfMessages2D.count {
            /// Choice card & button card handling
            if index < self.viewModel.arrayOfMessages2D.count-1 {
                // get message model for selected indexPath
                var messages = self.viewModel.arrayOfMessages2D[index]
                if messages.first?.sender.id != VAConfigurations.userUUID.lowercased() {
                    /// Message from bot
                    var subMessagesToRemove: [Int] = []
                    for (subIndex, item) in messages.enumerated() {
                        switch item.kind {
                            /// Choice card: hide the options from choice card that are before last message
                        case .multiOps:
                            self.viewModel.arrayOfMessages2D[index][subIndex].isMultiOpsTapped = true
                            self.viewModel.arrayOfMessages2D[index][subIndex].allowSkip = false
                            messages[subIndex].isMultiOpsTapped = true
                            messages[subIndex].allowSkip = false
                        case .quickReply(let buttonItem):
                            /// Button Card handling of hiding button options based on the setting. If quick_reply == true then button will stay on the bot even after they are clicked
                            if self.viewModel.configurationModel?.result?.quickReply == false {
                                if buttonItem.quickReplyProtocol?.title == "" {
                                    if self.viewModel.arrayOfMessages2D[index].count <= 2 {
                                        if !messagesToRemove.contains(index) {
                                            messagesToRemove.append(index)
                                        }
                                    } else {
                                        subMessagesToRemove.append(subIndex)
                                    }
                                }
                            }
                        default:
                            break
                        }
                    }
                    /// Removing button card from intent that has no title and hide buttons option is enabled from admin. This is the case when there is an answer card other than quick reply is available in response.
                    if !subMessagesToRemove.isEmpty {
                        for item in subMessagesToRemove.reversed() {
                            messages.remove(at: item)
                        }
                    }
                    if !messages.isEmpty {
                        messages[0].showBotImage = true
                        messages = messages.map({
                            var dict = $0
                            dict.isHideQuickReplyButtons = true
                            return dict
                        })
                        self.viewModel.arrayOfMessages2D[index] = messages
                    }
                }
            }
        }
        for msgIndex in messagesToRemove.reversed() {
            self.viewModel.arrayOfMessages2D.remove(at: msgIndex)
        }

        self.chatTableView.reloadData()
        self.imgViewTyping.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            CustomLoader.hide()
            self.scrollChatTableToBottom(isAnimate: false)
            _ = self.botSetupBasedOnReceivedMessage(isFeedbackShown: false)
            self.enableButtonCardsOptions()
            if self.viewModel.arrayOfMessages2D.last?.last?.allowSign ?? false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                    self.addSignatureView()
                })
            } else if self.viewModel.arrayOfMessages2D.last?.last?.qrCode ?? false {
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    self.showUploadOptionsView()
                    self.allowUserToType(isEnable: false)
                })
            } else if self.viewModel.arrayOfMessages2D.last?.last?.location ?? false {
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    self.showUploadOptionsView()
                    self.allowUserToType(isEnable: false)
                })
            }  else if self.viewModel.arrayOfMessages2D.last?.last?.isCustomFormInFlow ?? false {
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    self.viewModel.prechatFormUserInputs = [:]
                    self.viewModel.prechatForm = self.viewModel.arrayOfMessages2D.last?.last?.customForm
                    var title = ""
                    var canSkip = false
                    var formIndex = (self.viewModel.arrayOfMessages2D.last?.count ?? 0) - 2
                    formIndex = formIndex < 0 ? 0 : formIndex
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
            }
            let messages = self.viewModel.arrayOfMessages2D.last
            var isDoNotRespond: Bool = false
            for index in 0..<(messages?.count ?? 0) {
                switch messages![index].kind {
                case .agentMessage(let msg):
                    if msg.agentMessage?.doNotRespond == true {
                        isDoNotRespond = true
                    }
                default:
                    break
                }
            }
            if isDoNotRespond {
                self.viewTextInputBG.isHidden = true
                self.viewShowReplyMessage.isHidden = true
            } else {
                if VAConfigurations.isChatTool {
                    self.viewModel.isAgentConnectedToChat = true
                }
            }
        }
        if self.viewModel.isPokedByAgent {
            self.changeAgentStatusToActive()
        }
    }
}
