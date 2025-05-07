//  VAChatView+CellDelegates.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import Foundation
import UIKit
import AVFoundation
import AVKit

// MARK: TextCardCellDelegate
extension VAChatViewController: TextCardCellDelegate {

    /// This function is used when user tap on source card and this will open WebView with url
    /// - Parameter url: String
    func didTapOnSourceURL(url: String) {
        if let vcObj = storyboardObj.instantiateViewController(withIdentifier: "VAWebViewerVC") as? VAWebViewerVC {
            vcObj.webUrl = url
            vcObj.titleString = self.viewModel.configurationModel?.result?.name ?? ""
            vcObj.fontName = self.fontName
            vcObj.textFontSize = self.textFontSize
            vcObj.isGenAINewTheme = self.isNewGenAITheme
            self.present(vcObj, animated: true, completion: nil)
        }
    }
    /// This function is used to expand and collapse the text of text card
    func didTapReadMore(section: Int, index: Int) {
        if (self.viewModel.configurationModel?.result?.integration?[0].readMoreLimit?.expandText ?? true) == false {
            if let cell = chatTableView.cellForRow(at: IndexPath(row: index, section: section)) as? TextCardCell {
                if let vcObj = storyboardObj.instantiateViewController(withIdentifier: "VAExpandedTextVC") as? VAExpandedTextVC {
                    vcObj.fontName = self.fontName
                    vcObj.textFontSize = self.textFontSize
                    vcObj.isGenAINewTheme = self.isNewGenAITheme
                    if cell.completeAttributedText != nil {
                        let completeText = cell.getAttributedLabelText(isExpanded: true, isFullText: true)
                        vcObj.htmlText = completeText
                    } else {
                        vcObj.normalText = cell.getLabelText(isExpanded: true, isFullText: true)
                    }
                    vcObj.originalText = cell.originalText
                    vcObj.delegate = self
                    vcObj.chatTableIndexPath = IndexPath(row: index, section: section)
                    present(vcObj, animated: false, completion: nil)
                }
            }
        } else {
            let indexPath = IndexPath(row: index, section: section)
            self.viewModel.arrayOfMessages2D[indexPath.section][indexPath.row].isShowTypingEffectAnimation = false
            chatTableView.beginUpdates()
            if let cell = chatTableView.cellForRow(at: indexPath) as? TextCardCell {
                cell.isCellExpanded = !cell.isCellExpanded
                cell.isShowTypingEffectAnimation = false
                cell.configure()
            }
            chatTableView.endUpdates()
        }
    }

    /// This function open image available in text card
    func didTapOnTextAttachment(image: UIImage) {
        if let vcObj = storyboardObj.instantiateViewController(withIdentifier: "VAImageViewerVC") as? VAImageViewerVC {
            vcObj.image = image
            if image.size.width <= 200 && image.size.height <= 200 {
                vcObj.imageContentMode = .center
            }
            self.navigationController?.pushViewController(vcObj, animated: false)
        }
    }
    /// This function sends query to server if user tap on query link available in text card
    func didTapOnQueryLink(displayText: String, dataQuery: String, indexPath: IndexPath) {
        var isExecuteUserAction = false
        if (self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAI || self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAINLU) {
            if genAISendMsgDelayCounter == 0 {
                self.startGenAISendMsgDelayTimer()
                isExecuteUserAction = true
            }
        } else {
            isExecuteUserAction = true
        }
        if isExecuteUserAction {
            let context = self.viewModel.arrayOfMessages2D[indexPath.section][indexPath.row].context
            self.sendQueryToServer(displayText: displayText, dataQuery: dataQuery, context: context)
        }
    }
    func sendQueryToServer(displayText: String, dataQuery: String, context: [Dictionary<String, Any>] = []) {
        self.hideChoiceCardOptionsOfLastResponseBeforeSendingMessage()
        var message = MockMessage(text: displayText, sender: Sender(id: VAConfigurations.userUUID, displayName: VAConfigurations.customData?.userName ?? ""), messageId: UUID().uuidString, date: Date())
        if self.viewModel.arrayOfMessages2D.count == 0 {
            message.messageSequance = 1
        } else {
            message.messageSequance = (self.viewModel.arrayOfMessages2D.last?.first?.messageSequance ?? 0)+1// self.viewModel.arrayOfMessages2D.count + 1
        }
        self.viewModel.arrayOfMessages2D.append([message])
        // let isTextFeedback = self.viewModel.messageData?.feedback?["text_feedback"] ?? false
        let isTextFeedback = self.viewModel.messageData?.feedback?["click_feedback"] ?? false
        self.reloadAndScrollToBottom(isAnimate: false, isFeedback: isTextFeedback)
        /// If it is true then button click response is sending as feedback
        self.viewModel.isFeedback = false
        self.sendDataToServer(data: dataQuery, showLabelText: displayText, templateId: 0, isQuery: false, context: context, templateUid: "", query: dataQuery, userMessageId: "", actualIntent: [], replyToMessage: [:], isPrompt: false, senderMessageType: SenderMessageType.text)
        self.txtViewMessage.text = ""
        // Reset
        self.setCircularProgress()
    }
    func didTapCitationUrl(title: String, url: String) {
        if let vcObj = storyboardObj.instantiateViewController(withIdentifier: "VAWebViewerVC") as? VAWebViewerVC {
            vcObj.webUrl = url
            vcObj.titleString = title
            vcObj.fontName = self.fontName
            vcObj.textFontSize = self.textFontSize
            vcObj.isGenAINewTheme = self.isNewGenAITheme
            self.present(vcObj, animated: true, completion: nil)
        }
    }
}

// MARK: VAExpandedTextVCDelegate
extension VAChatViewController: VAExpandedTextVCDelegate {
    func didTapOnExpandedTextURL(url: String) {
        if let vcObj = storyboardObj.instantiateViewController(withIdentifier: "VAWebViewerVC") as? VAWebViewerVC {
            vcObj.webUrl = url
            vcObj.titleString = self.viewModel.configurationModel?.result?.name ?? ""
            vcObj.fontName = self.fontName
            vcObj.textFontSize = self.textFontSize
            vcObj.isGenAINewTheme = self.isNewGenAITheme
            self.present(vcObj, animated: true, completion: nil)
        }
    }
    /// This function sends query to server if user tap on query link available in text card
    func didTapOnExpandedTextQueryLink(displayText: String, dataQuery: String, indexPath: IndexPath) {
        var isExecuteUserAction = false
        if (self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAI || self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAINLU) {
            if genAISendMsgDelayCounter == 0 {
                self.startGenAISendMsgDelayTimer()
                isExecuteUserAction = true
            }
        } else {
            isExecuteUserAction = true
        }
        if isExecuteUserAction {
            let context = self.viewModel.arrayOfMessages2D[indexPath.section][indexPath.row].context
            self.sendQueryToServer(displayText: displayText, dataQuery: dataQuery, context: context)
        }
    }

}

// MARK: AgentTextCardCellDelegate
extension VAChatViewController: AgentTextCardCellDelegate {
    /// This function navigates to the original msg for which we are replying to .
    func didTapOldMsg(repliedMessageDict: [String: Any], indexPath: IndexPath) {
        if let msg = repliedMessageDict["msg"] as? String {
            var dataIndexPath: IndexPath!
            for iIndex in 0...self.viewModel.arrayOfMessages2D.count - 1 {
                let section = self.viewModel.arrayOfMessages2D[iIndex]
                for jIndex in 0..<section.count {
                    let model = self.viewModel.arrayOfMessages2D[iIndex][jIndex]
                    switch model.kind {
                    case .textItem(let item):
                        let str = (item.textProtocol?.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                        if str == msg.trimmingCharacters(in: .whitespacesAndNewlines) {
                            dataIndexPath = IndexPath(row: jIndex, section: iIndex)
                            break
                        } else {
                        }
                    case .agentMessage(let agentItem):
                        let str = (agentItem.agentMessage?.message ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                        if str == msg.trimmingCharacters(in: .whitespacesAndNewlines) {
                            dataIndexPath = IndexPath(row: jIndex, section: iIndex)
                            break
                        } else {
                        }
                    case .text(let text, _):
                        let str = (text).trimmingCharacters(in: .whitespacesAndNewlines)
                        if str == msg.trimmingCharacters(in: .whitespacesAndNewlines) {
                            dataIndexPath = IndexPath(row: jIndex, section: iIndex)
                            break
                        } else {
                        }
                    default: break
                    }
                }
            }

            if dataIndexPath != nil {
                if self.chatTableView.indexPathsForVisibleRows?.contains(dataIndexPath) == true {
                    if isNewGenAITheme {
                        if let cell = self.chatTableView.cellForRow(at: dataIndexPath) {
                            UIView.transition(with: cell, duration: 0.75, options: .curveEaseInOut, animations: {
                                cell.backgroundColor = VAColorUtility.lightPurple_NT
                            }, completion: {_ in
                                UIView.transition(with: cell, duration: 0.35) {
                                    cell.backgroundColor = .white
                                }
                            })
                        }
                    } else {
                        self.chatTableView.reloadRows(at: [dataIndexPath], with: .fade)
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                        self.chatTableView.scrollToRow(at: dataIndexPath, at: .top, animated: true)
                    }
                }
            }
        } else { }
    }
    /// This function triggers when user taps on reply button of a particular message
    func didTapOnReplyButton(indexPath: IndexPath) {
        if self.viewTextInputBG.isHidden == false {
            let messageModel = self.viewModel.arrayOfMessages2D[indexPath.section][indexPath.row]
            var msg: String = ""
            switch messageModel.kind {
            case .agentMessage(let item):
                msg = item.agentMessage?.message ?? ""
            case .text(let text, _):
                msg = text
            default:
                print("")
            }
            let replyToMessage: [String: Any] = ["msg": msg, "msgId": messageModel.messageSequance]
            self.lblReplyMessage.text = msg
            self.viewModel.selectedMessageModelForReply = replyToMessage
            self.viewShowReplyMessage.isHidden = false
        }
    }
}

// MARK: URLCardCellDelegate
extension VAChatViewController: URLCardCellDelegate {
    /// This function triggers when user taps on url in url card
    func didTapOnURL(url: String) {
        if let vcObj = storyboardObj.instantiateViewController(withIdentifier: "VAWebViewerVC") as? VAWebViewerVC {
            vcObj.webUrl = url
            vcObj.titleString = self.viewModel.configurationModel?.result?.name ?? ""
            vcObj.fontName = self.fontName
            vcObj.textFontSize = self.textFontSize
            vcObj.isGenAINewTheme = self.isNewGenAITheme
            self.present(vcObj, animated: true, completion: nil)
        }
    }
}

// MARK: ImageCardCellDelegate
extension VAChatViewController: ImageCardCellDelegate {
    /// This function triggers when user taps on image in image card
    func didTapOnImageCardImage(section: Int, index: Int) {
        if let vcObj = storyboardObj.instantiateViewController(withIdentifier: "VAImageViewerVC") as? VAImageViewerVC {
            let kind  = self.viewModel.arrayOfMessages2D[section][index].kind
            switch kind {
            case .imageItem(let item):
                vcObj.images = [item.imageProtocol?.url ?? ""]
            default:
                break
            }
            // vcObj.configurationModal = self.viewModel.configurationModel
            self.navigationController?.pushViewController(vcObj, animated: false)
        }
    }
}

// MARK: SenderImageCardCellDelegate
extension VAChatViewController: SenderImageCellDelegate {
    /// This function triggers when user taps on image in sender image card
    func didTapOnImage(image: UIImage) {
        if let vcObj = storyboardObj.instantiateViewController(withIdentifier: "VAImageViewerVC") as? VAImageViewerVC {
            vcObj.image = image
            // vcObj.configurationModal = self.viewModel.configurationModel
            self.navigationController?.pushViewController(vcObj, animated: false)
        }
    }
}

// MARK: DateFeedbackCellDelegate
extension VAChatViewController: DateFeedbackCellDelegate {
    /// This function triggers when user provides thumbs up feedback
    func didTapFeedbackThumbsUp(indexPath: IndexPath) {
        /*if (self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAI || self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAINLU) {
            if genAISendMsgDelayCounter == 0 {
                self.startGenAISendMsgDelayTimer()
                self.thumbsUpFeedbackGiven(indexPath: indexPath)
            }
        } else {
            self.thumbsUpFeedbackGiven(indexPath: indexPath)
        }*/
        self.thumbsUpFeedbackGiven(indexPath: indexPath)
    }
    
    fileprivate func thumbsUpFeedbackGiven(indexPath: IndexPath) {
        var model = self.viewModel.arrayOfMessages2D[indexPath.section][indexPath.row]
        if model.isFeedback == false { // Check feedback never given by user
            self.viewModel.isMessageTyping = false
            self.viewModel.isThumbFeedback = true
            self.viewModel.isThumbsUp = true
            model.isFeedback = true
            model.isThumbsUpFeedback = true
            self.viewModel.isFeedbackGivenByUser = true
            self.viewModel.arrayOfMessages2D[indexPath.section][indexPath.row] = model
            self.sendDataToServer(data: "", userMessageId: "\(self.viewModel.messageData?.userMessageId ?? 0)", senderMessageType: SenderMessageType.text)
        }
    }
    
    /// This function triggers when user provides thumbs down feedback
    func didTapFeedbackThumbsDown(indexPath: IndexPath) {
        /*if (self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAI || self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAINLU) {
            if genAISendMsgDelayCounter == 0 {
                self.startGenAISendMsgDelayTimer()
                self.thumbsDownFeedbackGiven(indexPath: indexPath)
            }
        } else {
            self.thumbsDownFeedbackGiven(indexPath: indexPath)
        }*/
        self.thumbsDownFeedbackGiven(indexPath: indexPath)
    }
    
    fileprivate func thumbsDownFeedbackGiven(indexPath: IndexPath) {
        var model = self.viewModel.arrayOfMessages2D[indexPath.section][indexPath.row]
        if model.isFeedback == false { // Check feedback never given by user
            self.viewModel.isMessageTyping = false
            self.viewModel.isThumbFeedback = true
            self.viewModel.isThumbsUp = false
            model.isFeedback = true
            model.isThumbsUpFeedback = false
            self.viewModel.isFeedbackGivenByUser = true
            self.viewModel.arrayOfMessages2D[indexPath.section][indexPath.row] = model
            self.sendDataToServer(data: "", userMessageId: "\(self.viewModel.messageData?.userMessageId ?? 0)", senderMessageType: SenderMessageType.text)
        }
    }
}

// MARK: FeedbackCellDelegate
extension VAChatViewController: FeedbackCellDelegate {
    func didTapOnFeedbackViewOptions(indexPath: IndexPath) {
        self.view.endEditing(true)
        chatTableView.beginUpdates()
        chatTableView.endUpdates()
        self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
    
    func didTapOnSendFeedbackMsg(feedbackText: String, indexPath: IndexPath) {
        self.viewModel.isFeedbackGivenByUser = true
        self.viewModel.isFeedback = true
        if let messageId = self.viewModel.arrayOfMessages2D[indexPath.section][indexPath.row].userMsgId {
            self.sendDataToServer(data: feedbackText, userMessageId: "\(messageId)", senderMessageType: SenderMessageType.text)
        }
    }
    func didTapThumbsUpFeedbackGenAI(indexPath: IndexPath) {
        self.thumbsUpFeedbackGiven(indexPath: indexPath)
    }
    
    func didTapThumbsDownFeedbackGenAI(indexPath: IndexPath) {
        self.thumbsDownFeedbackGiven(indexPath: indexPath)
    }
    
}

// MARK: ButtonCardCellDelegate
extension VAChatViewController: ButtonCardCellDelegate {
    /// This function triggers when user clicks sso button in button card
    func didTapSSOButton(response: BotQRButton, cardIndexPath: IndexPath, ssoType: String) {
        let modifiedSSOType = (ssoType == SSOType.oneLogin || ssoType == SSOType.saml) ? SSOType.oneLogin : ssoType
        self.view.endEditing(true)
        if self.viewModel.isButtonClickEnabled == false {
            return
        }
        if self.viewModel.isButtonClickEnabled == true {
            self.viewModel.isButtonClickEnabled = false
        }
        self.viewModel.isMessageTyping = false
        let isOneLoginSSO = (self.viewModel.configurationModel?.result?.ssoType == SSOType.oneLogin || self.viewModel.configurationModel?.result?.ssoType == SSOType.saml) ? true : false
        // let isOneLoginSSO = (ssoType == SSOType.oneLogin || ssoType == SSOType.saml) ? true : false
        var ssoUrl = ""
        var configuredSSO = ""
        if self.viewModel.configurationModel?.result?.ssoType == SSOType.oauth {
            configuredSSO = SSOType.oauth
        } else {
            configuredSSO = SSOType.oneLogin
        }
        if (modifiedSSOType).contains(configuredSSO) {
            ssoUrl = getSSORedirectURL(ssoAuthUrl: response.data, isOneLoginSSO: isOneLoginSSO, isAuthorisationOnStartup: false)
        } else {
            ssoUrl = getSSORedirectURL(ssoAuthUrl: response.templateId, isOneLoginSSO: isOneLoginSSO, isAuthorisationOnStartup: false)

        }
        self.openSSOAuthController(ssoUrlStr: ssoUrl, isAuthenticateOnLaunch: false, isOneLoginSSO: isOneLoginSSO, cardIndexPath: cardIndexPath)
    }

    func openSSOAuthController(ssoUrlStr: String, isAuthenticateOnLaunch: Bool, isOneLoginSSO: Bool, cardIndexPath: IndexPath?) {
        if let popOverAlertVC = storyboardObj.instantiateViewController(withIdentifier: "VASSOAuthenticationVC") as? VASSOAuthenticationVC {
            popOverAlertVC.delegate = self
            popOverAlertVC.ssoURLStr = ssoUrlStr
            popOverAlertVC.isAuthenticateOnLaunch = isAuthenticateOnLaunch
            popOverAlertVC.isOneLoginSSO = isOneLoginSSO
            popOverAlertVC.selectedCardIndexPath = cardIndexPath
            self.navigationController?.navigationBar.isHidden = true
            popOverAlertVC.modalPresentationStyle = .overCurrentContext
            self.present(popOverAlertVC, animated: !isAuthenticateOnLaunch, completion: nil)
            self.viewModel.isButtonClickEnabled = true
        }
    }

    /// This function triggers when user taps on button of button card but not sso button
    func didTapQuickReplyButton(response: BotQRButton, context: [Dictionary<String, Any>], cardIndexPath: IndexPath, selectedButtonIndex: Int) {
        if (self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAI || self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAINLU) {
            if genAISendMsgDelayCounter == 0 {
                self.startGenAISendMsgDelayTimer()
                self.buttonCardQuickReplyButtonTapped(response: response, context: context, cardIndexPath: cardIndexPath, selectedButtonIndex: selectedButtonIndex)
            }
        } else {
            self.buttonCardQuickReplyButtonTapped(response: response, context: context, cardIndexPath: cardIndexPath, selectedButtonIndex: selectedButtonIndex)
        }
    }
    private func buttonCardQuickReplyButtonTapped(response: BotQRButton, context: [Dictionary<String, Any>], cardIndexPath: IndexPath, selectedButtonIndex: Int) {
        self.view.endEditing(true)
        if self.viewModel.isButtonClickEnabled == false {
            return
        }
        if self.viewModel.isButtonClickEnabled == true {
            self.viewModel.isButtonClickEnabled = false
        }
        if self.viewModel.arrayOfMessages2D[cardIndexPath.section][cardIndexPath.row].responseType == "quick_reply" {
            let messageModel = self.viewModel.arrayOfMessages2D[cardIndexPath.section][cardIndexPath.row]
            switch messageModel.kind {
            case .quickReply(let item):
                var otherButtonsTemp = item.quickReplyProtocol?.otherButtons
                otherButtonsTemp? [selectedButtonIndex].isButtonClicked = true
                var quickReply = item
                quickReply.quickReplyProtocol?.otherButtons = otherButtonsTemp ?? []
                var newMessageModel = MockMessage(quickReply: quickReply.quickReplyProtocol!,
                                                  sender: messageModel.sender,
                                                  messageId: messageModel.messageId,
                                                  date: messageModel.sentDate)
                newMessageModel.messageSequance = messageModel.messageSequance
                newMessageModel.isQuickReplyMsg = messageModel.isQuickReplyMsg
                newMessageModel.preventTyping = messageModel.preventTyping
                newMessageModel.responseType = messageModel.responseType
                newMessageModel.showBotImage = messageModel.showBotImage
                self.viewModel.arrayOfMessages2D[cardIndexPath.section] [cardIndexPath.row] = newMessageModel
                if let cell = chatTableView.cellForRow(at: cardIndexPath) as? ButtonCardCell {
                    cell.quickReplyResponse?.otherButtons[selectedButtonIndex].isButtonClicked = true
                    chatTableView.beginUpdates()
                    cell.buttonsCollection.reloadData()
                    chatTableView.endUpdates()
                }
            default:
                break
            }
        }
        self.handlePersistQuickReplyButtons()
        self.viewModel.isMessageTyping = false
        
        //self.reloadAndScrollToBottom(isAnimate: false, reloadSection: cardIndexPath.section)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if response.type == "url" {
                //self.reloadAndScrollToBottom(isAnimate: false)
                if response.data.isValidURL {
                    self.openUrl(url: response.data)
                } else {
                    UIAlertController.showAutoHideAlert(message: "No content to show.", delay: 2.0, controller: self)
                }
                self.invalidateGenAISendMsgDelayTimer()
            } else {
                self.hideChoiceCardOptionsOfLastResponseBeforeSendingMessage()
                self.allowUserActivity = false
                var message = MockMessage(text: response.attributedText?.string ?? response.text, sender: Sender(id: VAConfigurations.userUUID, displayName: VAConfigurations.customData?.userName ?? ""), messageId: UUID().uuidString, date: Date())
                if self.viewModel.arrayOfMessages2D.count == 0 {
                    message.messageSequance = 1
                } else {
                    message.messageSequance = (self.viewModel.arrayOfMessages2D.last?.first?.messageSequance ?? 0)+1// self.viewModel.arrayOfMessages2D.count + 1
                }
                self.viewModel.arrayOfMessages2D.append([message])
                // let isTextFeedback = self.viewModel.messageData?.feedback?["text_feedback"] ?? false
                let isTextFeedback = self.viewModel.messageData?.feedback?["click_feedback"] ?? false
                self.reloadAndScrollToBottom(isAnimate: false, isFeedback: isTextFeedback)
                /// If it is true then button click response is sending as feedback
                self.viewModel.isFeedback = false
                if response.type == "goto" {
                    self.sendDataToServer(data: response.text, templateId: Int(response.data), context: context, senderMessageType: SenderMessageType.text)
                } else {
                    self.sendDataToServer(data: response.data, showLabelText: response.text, isQuery: true, context: context, isPrompt: false, senderMessageType: SenderMessageType.text)
                    // self.sendDataToServer(data: response.text, isQuery: true, context: context)
                }
                self.txtViewMessage.text = ""
                // Reset
                self.setCircularProgress()
            }
        }
    }

    func openUrl(url: String) {
        self.viewModel.isButtonClickEnabled = true
        self.enableTypingIfRequired()
        if let vcObj = storyboardObj.instantiateViewController(withIdentifier: "VAWebViewerVC") as? VAWebViewerVC {
            vcObj.webUrl = url
            vcObj.titleString = self.viewModel.configurationModel?.result?.name ?? ""
            vcObj.fontName = self.fontName
            vcObj.textFontSize = self.textFontSize
            vcObj.isGenAINewTheme = self.isNewGenAITheme
            // self.navigationController?.pushViewController(vcObj, animated: true)
            self.present(vcObj, animated: true, completion: nil)
        }
    }
    
    func getSSORedirectURL(ssoAuthUrl:String, isOneLoginSSO: Bool, isAuthorisationOnStartup: Bool, isGroupSSO: Bool = false) -> String {
        let updatedSsoAuthUrl:String! = ssoAuthUrl.replacingOccurrences(of: "{bot_uid}", with: VAConfigurations.botId)

        var jid = VAConfigurations.userJid + "_"
        if isAuthorisationOnStartup && !isGroupSSO {
            jid += "0"
        } else {
            jid += (UserDefaultsManager.shared.getSessionID())
        }
        debugPrint("JID to create relay state for SSO = \(jid)")
        var finalSSOUrl = "\(updatedSsoAuthUrl!)"
        if isOneLoginSSO {
            finalSSOUrl += "&RelayState=" + getOneLoginSSORelayState(jid: jid)
        } else {
            finalSSOUrl += "&state=" + getSSOState(jid: jid)
        }
        /*if isAuthorisationOnStartup {
            if self.viewModel.configurationModel?.result?.ssoType == SSOType.oneLogin || self.viewModel.configurationModel?.result?.ssoType == SSOType.saml {
                finalSSOUrl += "&RelayState=" + getOneLoginSSORelayState(jid: jid)
            } else {
                finalSSOUrl += "&state=" + getSSOState(jid: jid)
            }
        } else {
            if isOneLoginSSO {
                finalSSOUrl += "&RelayState=" + getOneLoginSSORelayState(jid: jid)
            } else {
                finalSSOUrl += "&state=" + getSSOState(jid: jid)
            }
        }*/
        return finalSSOUrl
    }

    func getOneLoginSSORelayState(jid: String) -> String {
        let hostName = VAConfigurations.parentHost
        let uid = self.viewModel.configurationModel?.result?.uid ?? ""
        /// _mobile is added to check whether the request sent from mobile device or from web. This is used to set the font size of error shown in web page during sso fail.
        let relayState = "\(hostName)_\(jid)_\(uid)_mobile"
        let relayStateBase64 = relayState.toBase64()
        return relayStateBase64
    }

    func getSSOState(jid: String) -> String {
        let jidHash = jid.sha1()
        debugPrint("jidHash: \(jidHash)")
        let hashCodeUrl = jidHash + "," + VAConfigurations.SSOAuthURL
        debugPrint("hashCodeUrl: \(hashCodeUrl)")
        let state = hashCodeUrl.toBase64()
        return state
    }
}

// MARK: VASSOAuthenticationVCDelegate
extension VAChatViewController: VASSOAuthenticationVCDelegate {
    /// This function triggers when user cancel or closes the sso auth screen
    func ssoLogInCancelled(isAuthenticateOnLaunch: Bool) {
        if isAuthenticateOnLaunch {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.closeChatbot()
            }
        }
    }
    /// This function triggers when sso authentication is successful
    func ssoLoggedInSuccessfullyWith(sessionId: String, isAuthenticateOnLaunch: Bool, selectedCardIndexPath: IndexPath?) {
        print(sessionId)
        self.viewModel.isSSO = 1
        self.viewModel.ssoSessionId = sessionId
        if isAuthenticateOnLaunch {
            CustomLoader.show()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.connectXMPPwith()
            }
        } else {
            self.handlePersistQuickReplyButtons()
            self.reloadAndScrollToBottom(isAnimate: false, reloadSection: selectedCardIndexPath?.section)
            self.sendDataToServer(data: "", senderMessageType: SenderMessageType.text)
        }
    }
}

// MARK: ChoiceCardCellDelegate
extension VAChatViewController: ChoiceCardCellDelegate {
    /// This function triggers when user taps on button of type skip in choice card
    func didTapSkipButton(indexPath: IndexPath) {
        if (self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAI || self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAINLU) {
            if genAISendMsgDelayCounter == 0 {
                self.startGenAISendMsgDelayTimer()
                self.choiceCardSkipButtonClicked(indexPath: indexPath)
            }
        } else {
            self.choiceCardSkipButtonClicked(indexPath: indexPath)
        }
    }
    private func choiceCardSkipButtonClicked(indexPath: IndexPath) {
        self.handlePersistQuickReplyButtons()
        let messageModel = self.viewModel.arrayOfMessages2D[indexPath.section][indexPath.row]

        var multiOps: MultiOps?

        switch messageModel.kind {
        case .multiOps(let multiOpsProtocol):
            multiOps = multiOpsProtocol.multiOps
            var newMessageModel = MockMessage(multiOptional: multiOps!,
                                              sender: messageModel.sender,
                                              messageId: messageModel.messageId,
                                              date: messageModel.sentDate)

            newMessageModel.isMultiSelect = messageModel.isMultiSelect

            newMessageModel.isMultiOpsTapped = true

            self.viewModel.arrayOfMessages2D[indexPath.section][indexPath.row] = newMessageModel
            self.chatTableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            let option = multiOps?.options[0].label ?? ""

            let templateId = multiOps?.options[0].data ?? "0"

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                let message = MockMessage(text: option, sender: Sender(id: VAConfigurations.userUUID, displayName: VAConfigurations.customData?.displayName ?? ""), messageId: UUID().uuidString, date: Date())

                self?.viewModel.arrayOfMessages2D.append([message])

                self?.reloadAndScrollToBottom(isAnimate: false)

                var messageData =  self?.viewModel.messageData

                messageData?.isPrompt = false

                self?.viewModel.messageData = messageData

                self?.sendDataToServer(data: templateId, showLabelText: option, templateId: 0, isQuery: false, context: [[String: Any]](), query: self?.viewModel.messageData?.query ?? "", isPrompt: false, senderMessageType: SenderMessageType.text)
            }
        default:
            break
        }
    }

    /// This function is used to send the selected choices in choice message to the server
    /// - Parameter array: [Choice]
    private func sendChoiceMessage(array: [Choice]) {
        var newArray: [Choice] = []
        if array.count > 0 {
            let filterArray = array.filter { obj in
                if obj.isSelected == true {
                    return true
                } else {
                    return false
                }
            }
            newArray = filterArray
        } else {
            newArray = []
        }

        if newArray.count > 0 {
            let formattedArray = (newArray.map {String($0.value)}).joined(separator: ",")

            let labelFormattedArray = (newArray.map {String($0.label)}).joined(separator: ",")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self, labelFormattedArray] in
                var message = MockMessage(text: "\(labelFormattedArray)", sender: Sender(id: VAConfigurations.userUUID, displayName: VAConfigurations.customData?.displayName ?? ""), messageId: UUID().uuidString, date: Date())
                if self?.viewModel.arrayOfMessages2D.count == 0 {
                    message.messageSequance = 1
                } else {
                    message.messageSequance = (self?.viewModel.arrayOfMessages2D.last?.first?.messageSequance ?? 0)+1// self.viewModel.arrayOfMessages2D.count + 1
                }
                // update array with new message
                self?.viewModel.arrayOfMessages2D.append([message])

                // reload
                self?.reloadAndScrollToBottom(isAnimate: false)

                // send data to server
                self?.sendDataToServer(data: formattedArray, showLabelText: labelFormattedArray, templateId: 0, isQuery: false, context: self?.viewModel.messageData?.contexts ?? [], isPrompt: self?.viewModel.messageData?.isPrompt ?? false, senderMessageType: SenderMessageType.text)
            }
        } else {
            // No item selected
        }
    }
    
    /// This function triggers when user click on confirm button after selecting options  in case multiselect is enabled
    func didTapConfirmButton(response: [Choice], indexPath: IndexPath) {
        if (self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAI || self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAINLU) {
            if genAISendMsgDelayCounter == 0 {
                self.startGenAISendMsgDelayTimer()
                self.choiceCardConfirmButtonClicked(response: response, indexPath: indexPath)
            }
        } else {
            self.choiceCardConfirmButtonClicked(response: response, indexPath: indexPath)
        }
    }
    private func choiceCardConfirmButtonClicked(response: [Choice], indexPath: IndexPath) {
        self.handlePersistQuickReplyButtons()
        let messageModel = self.viewModel.arrayOfMessages2D[indexPath.section][indexPath.row]

        var multiOps: MultiOps?

        switch messageModel.kind {
        case .multiOps(let multiOpsProtocol):
            multiOps = multiOpsProtocol.multiOps

            multiOps?.choices = response

            var newMessageModel = MockMessage(multiOptional: multiOps!,
                                              sender: messageModel.sender,
                                              messageId: messageModel.messageId,
                                              date: messageModel.sentDate)

            newMessageModel.isMultiSelect = messageModel.isMultiSelect

            newMessageModel.isMultiOpsTapped = true
            newMessageModel.messageSequance = self.viewModel.arrayOfMessages2D[indexPath.section][indexPath.row].messageSequance

            self.viewModel.arrayOfMessages2D[indexPath.section][indexPath.row] = newMessageModel
            self.chatTableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            self.sendChoiceMessage(array: response)
        default:
            break
        }
    }
    /// This function triggers when user click on more button to view all available choices in choice card
    func didTapMoreOptionsButton(response: [Choice], indexPath: IndexPath, isMultiSelect: Bool) {
        // hide keyboard
        self.view.endEditing(true)
        // open list view
        VAChoicePopupView.openPopupListView(arrayOfData: response, isMultiSelect: isMultiSelect, selectedIndexPath: indexPath, viewController: self, fontName: self.fontName, textFontSize: self.textFontSize) { (_, item, isCrossTapped) in
            if !isCrossTapped && (self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAI || self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAINLU) {
                if self.genAISendMsgDelayCounter == 0 {
                    self.startGenAISendMsgDelayTimer()
                    self.choiceCardOptionClickedFromChoicePopup(indexPath: indexPath, items: item, isCrossTapped: isCrossTapped)
                }
            } else {
                self.choiceCardOptionClickedFromChoicePopup(indexPath: indexPath, items: item, isCrossTapped: isCrossTapped)
            }
        }
    }
    private func choiceCardOptionClickedFromChoicePopup(indexPath: IndexPath, items: [Choice], isCrossTapped: Bool) {
        if isCrossTapped {
            return
        }
        self.handlePersistQuickReplyButtons()
        let messageModel = self.viewModel.arrayOfMessages2D[indexPath.section][indexPath.row]
        var multiOps: MultiOps?
        switch messageModel.kind {
        case .multiOps(let multiOpsProtocol):
            multiOps = multiOpsProtocol.multiOps
            multiOps?.choices = items
            var newMessageModel = MockMessage(multiOptional: multiOps!,
                                              sender: messageModel.sender,
                                              messageId: messageModel.messageId,
                                              date: messageModel.sentDate)

            newMessageModel.isMultiSelect = messageModel.isMultiSelect
            newMessageModel.isMultiOpsTapped = true
            newMessageModel.messageSequance = self.viewModel.arrayOfMessages2D[indexPath.section][indexPath.row].messageSequance
            // update array with new message model
            self.viewModel.arrayOfMessages2D[indexPath.section][indexPath.row] = newMessageModel
            // reload section
            self.chatTableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            self.sendChoiceMessage(array: items)
        default:
            break
        }

    }
}

// MARK: CarouselCardCellDelegate
extension VAChatViewController: CarouselCardCellDelegate {
    /// This function triggers when user taps on any image present in carousel card
    func didTapOnCollectionImage(imageIndex: Int, images: [String]) {
        self.view.endEditing(true)
        if let vcObj = storyboardObj.instantiateViewController(withIdentifier: "VAImageViewerVC") as? VAImageViewerVC {
            vcObj.selectedImageIndex = imageIndex
            vcObj.images = images
            self.navigationController?.pushViewController(vcObj, animated: false)
        }
    }

    /// This function triggers when user taps on any button of carousel card
    func didTapOnCarouselOption(option: Option, context: [Dictionary<String, Any>], cardIndexPath: IndexPath, carouselPageIndex: Int, selectedButtonIndex: Int) -> Bool {
        /// This function will return false only when nlu type is genAI or genAINLU and startGenAISendMsgDelayTimer is running and not zero.
        if (self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAI || self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAINLU) {
            if genAISendMsgDelayCounter == 0 {
                self.startGenAISendMsgDelayTimer()
                self.carouselCardOptionClicked(option: option, context: context, cardIndexPath: cardIndexPath, carouselPageIndex: carouselPageIndex, selectedButtonIndex: selectedButtonIndex)
            } else {
                return false
            }
        } else {
            self.carouselCardOptionClicked(option: option, context: context, cardIndexPath: cardIndexPath, carouselPageIndex: carouselPageIndex, selectedButtonIndex: selectedButtonIndex)
        }
        return true
    }
    private func carouselCardOptionClicked(option: Option, context: [Dictionary<String, Any>], cardIndexPath: IndexPath, carouselPageIndex: Int, selectedButtonIndex: Int) {
        self.view.endEditing(true)
        if self.viewModel.isButtonClickEnabled == false {
            return
        }
        if self.viewModel.isButtonClickEnabled == true {
            self.viewModel.isButtonClickEnabled = false
        }
        self.viewModel.isMessageTyping = false
        if self.viewModel.arrayOfMessages2D[cardIndexPath.section][cardIndexPath.row].responseType == "carousel" {
            let messageModel = self.viewModel.arrayOfMessages2D[cardIndexPath.section][cardIndexPath.row]
            switch messageModel.kind {
            case .carouselItem(let item):
                var carouselCard = item
                carouselCard.carousel?.carouselObjects[carouselPageIndex].options[selectedButtonIndex].isButtonClicked = true
                var newMessageModel = MockMessage(carousel: carouselCard.carousel!,
                                                  sender: messageModel.sender,
                                                  messageId: messageModel.messageId,
                                                  date: messageModel.sentDate)
                newMessageModel.messageSequance = messageModel.messageSequance
                newMessageModel.preventTyping = messageModel.preventTyping
                newMessageModel.responseType = messageModel.responseType
                newMessageModel.showBotImage = messageModel.showBotImage
                self.viewModel.arrayOfMessages2D[cardIndexPath.section] [cardIndexPath.row] = newMessageModel
                if let cell = chatTableView.cellForRow(at: cardIndexPath) as? CarouselCardCell {
                    cell.carouselArray[carouselPageIndex].options[selectedButtonIndex].isButtonClicked = true
                }
            default:
                break
            }
        }
        self.handlePersistQuickReplyButtons()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if option.type == "url" {
                if option.data.isValidURL {
                    self.openUrl(url: option.data)
                }
                self.invalidateGenAISendMsgDelayTimer()
            } else {
                self.hideChoiceCardOptionsOfLastResponseBeforeSendingMessage()
                var message = MockMessage(text: option.label.trimHTMLTags() ?? "", sender: Sender(id: VAConfigurations.userUUID, displayName: VAConfigurations.customData?.userName ?? ""), messageId: UUID().uuidString, date: Date())
                if self.viewModel.arrayOfMessages2D.count == 0 {
                    message.messageSequance = 1
                } else {
                    message.messageSequance = (self.viewModel.arrayOfMessages2D.last?.first?.messageSequance ?? 0)+1// self.viewModel.arrayOfMessages2D.count + 1
                }
                self.viewModel.arrayOfMessages2D.append([message])
                let isTextFeedback = self.viewModel.messageData?.feedback?["text_feedback"] ?? false
                /// If text_feedback is true then button click response is sending as feedback
                self.viewModel.isFeedback = false
                self.reloadAndScrollToBottom(isAnimate: false, isFeedback: isTextFeedback)
                if option.type == "goto" {
                    //self.sendDataToServer(data: option.data, templateId: Int(option.data), context: context, senderMessageType: SenderMessageType.text)
                    self.sendDataToServer(data: option.label, templateId: Int(option.data), context: context, senderMessageType: SenderMessageType.text)
                } else {
                    self.sendDataToServer(data: option.data.trimHTMLTags() ?? "", showLabelText: option.label, isQuery: true, context: context, isPrompt: false, senderMessageType: SenderMessageType.text)
                }
                self.txtViewMessage.text = ""
                // Reset
                self.setCircularProgress()
            }
        }
    }
    /// This function triggers when user scrolls the page in carousel card
    func didScrollCollectionImage(imageIndex: Int, cardIndexPath: IndexPath) {
        self.chatTableView.beginUpdates()
        self.viewModel.arrayOfMessages2D[cardIndexPath.section][cardIndexPath.row].selectedCarouselItemIndex = imageIndex
        if let cell = chatTableView.cellForRow(at: cardIndexPath) as? CarouselCardCell {
            cell.selectedImageIndex = imageIndex
            cell.configure()
        }
        self.chatTableView.endUpdates()
    }
}

// MARK: VideoCardCellDelegate
extension VAChatViewController: VideoCardCellDelegate {
    /// This function triggers when user tap on play button in video card
    func didTapPlayButton(videoUrl: String, index: Int) {
        if videoUrl.contains("www.youtube.com") || videoUrl.contains("youtu.be") {
            // play you tube video
            if let vcObj = storyboardObj.instantiateViewController(withIdentifier: "YoutubePlayerVC") as? YoutubePlayerVC {
                vcObj.videoUrl = videoUrl
                // self.navigationController?.pushViewController(vcObj, animated: true)
                self.present(vcObj, animated: true, completion: nil)
            }
        } else {
            // play video from url
            self.playVideo(url: URL(string: videoUrl)!)
        }
    }

    func playVideo(url: URL) {
        // create player and present as new screen
        let player = AVPlayer(url: url)
        let vcObj = AVPlayerViewController()
        vcObj.player = player
        self.present(vcObj, animated: true) { vcObj.player?.play() }
    }
}

// MARK: Signature view delegates
extension VAChatViewController: SwiftSignatureDelegate {
    func didStart() {
        if hasSignatureAdded == false {
            hasSignatureAdded = true
            self.updateSignatureViewButtons()
        }
    }

    func didFinish() {

    }

    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
    }

    func convertBase64StringToImage (imageBase64String: String) -> UIImage {
        let imageData = Data(base64Encoded: imageBase64String)
        let image = UIImage(data: imageData!)
        return image!
    }
}
