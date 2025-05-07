//  VAChatView+UITableView.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import Foundation
import UIKit
import AVFoundation
import IQKeyboardManagerSwift

// MARK: - VAChatViewController extension of UITextViewDelegate
extension VAChatViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == self.viewModel.defaultPlaceholder || textView.text == self.viewModel.feedbackPlaceholder || textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            textView.text = ""
            self.txtViewMessage.textColor = VAColorUtility.black
        }
        self.viewModel.isMessageTyping = true
        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        IQKeyboardManager.shared.enable = false
        self.viewModel.isMessageTyping = true
        self.removeUnreadMessageCell()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.viewModel.callTransferType == .tids || self.viewModel.isPokedByAgent {
            self.sendUserTypingState(state: .paused)
        }
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            if !self.isListeningToSpeech && !(self.viewModel.messageData?.masked ?? false) {
                if self.viewModel.isFeedback {
                    textView.text = self.viewModel.feedbackPlaceholder
                } else {
                    textView.text = self.viewModel.defaultPlaceholder
                }
            } else {
                textView.text = ""
                self.txtViewMessage.textColor = VAColorUtility.black
            }
            self.txtViewMessage.textColor = VAColorUtility.defaultThemeTextIconColor
            self.imgSend.tintColor = isNewGenAITheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.defaultThemeTextIconColor
            if self.viewModel.messageData?.masked ?? false {
                if self.viewModel.isSecured == true {
                    textView.text = String(repeating: "•", count: textView.text.count)
                    self.viewSecureMessage.isHidden = false
                    self.viewSecureMsgWidthConstraint.constant = 30
                } else { }
            } else {
                self.viewSecureMessage.isHidden = true
                self.viewSecureMsgWidthConstraint.constant = 0
            }
        }
        if textView.text == self.viewModel.defaultPlaceholder || textView.text == self.viewModel.feedbackPlaceholder || textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            if isNewGenAITheme {
                self.sendMsgBgView.backgroundColor = VAColorUtility.lightSilver_NT
            }
            self.imgSend.tintColor = isNewGenAITheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.defaultThemeTextIconColor
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        self.setCircularProgressForEnteredText(message: textView.text)
        if self.viewModel.messageData?.masked ?? false {
            if self.viewModel.isSecured == true {
                textView.text = String(repeating: "•", count: textView.text.count)
                self.viewSecureMessage.isHidden = false
                self.viewSecureMsgWidthConstraint.constant = 30
            } else {}
            if textView.text.count < self.viewModel.textViewOriginalText.count {
                if self.viewModel.textViewOriginalText.count > 0 {
                    self.viewModel.textViewOriginalText.removeLast()
                }
            }
        } else {
            self.viewSecureMessage.isHidden = true
            self.viewSecureMsgWidthConstraint.constant = 0
        }
        if isNewGenAITheme {
            self.adjustTextViewHeight()
        }
    }
    @objc func updateMsgComposingStateCounter() {
        if self.msgComposingStateCounter < 5 {
            self.msgComposingStateCounter += 1
        } else {
            self.invalidateMsgComposingStateDelayTimer()
        }
    }
    func invalidateMsgComposingStateDelayTimer() {
        self.msgComposingStateDelayTimer?.invalidate()
        self.msgComposingStateDelayTimer = nil
        self.msgComposingStateCounter = 0
    }
    func startMsgComposingStateDelayTimer() {
        self.invalidateMsgComposingStateDelayTimer()
        self.msgComposingStateCounter = 1
        let fireDate = Date().addingTimeInterval(TimeInterval(1.0))
        self.msgComposingStateDelayTimer = Timer(fireAt: fireDate, interval: 1.0, target: self, selector: #selector(self.updateMsgComposingStateCounter), userInfo: nil, repeats: true)
        RunLoop.main.add(self.msgComposingStateDelayTimer!, forMode: RunLoop.Mode.common)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        /// if call transfer type is tids then we need to send typing state
        if (self.viewModel.callTransferType == .tids || self.viewModel.isPokedByAgent) && self.msgComposingStateCounter == 0 {
            self.startMsgComposingStateDelayTimer()
            self.sendUserTypingState(state: .typing)
        }

        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if newText.count > 0 {
            self.imgSend.tintColor = isNewGenAITheme ? UIColor.white : VAColorUtility.themeTextIconColor
            if isNewGenAITheme {
                self.sendMsgBgView.backgroundColor = VAColorUtility.green_NT
            }
        } else {
            self.imgSend.tintColor = isNewGenAITheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.defaultThemeTextIconColor
            if isNewGenAITheme {
                self.sendMsgBgView.backgroundColor = VAColorUtility.lightSilver_NT
            }
        }

        if text == "\n"{
            if isNewGenAITheme {
                if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    self.view.endEditing(true)
                    return false
                } else {
                    return true
                }
            } else {
                self.view.endEditing(true)
                return false
            }
        } else {
            var isQuickReply: Bool = false
            var buttonCards: [MockMessage] = []
            let lastMsgIndex = self.viewModel.arrayOfMessages2D.count - 1
            for index in stride(from: lastMsgIndex, to: -1, by: -1) {
                let item = self.viewModel.arrayOfMessages2D[index]
                if item.first?.sender.id != VAConfigurations.userUUID {
                    buttonCards = item.filter({$0.responseType == "quick_reply"})
                    if buttonCards.count > 0 {
                        isQuickReply = true
                    }
                    break
                }
            }
            if !self.viewModel.isFeedback, self.viewModel.callTransferType == .none, self.viewModel.isPokedByAgent == false { /// if isFeeback is false
                /// if text count greater than 3 then call suggestion api
                if newText.count > 3 {
                    // cancel pervious call for suggestion api
                    NSObject.cancelPreviousPerformRequests(withTarget: self,
                                                           selector: #selector(self.callSuggestionsAPI(txt:)),
                                                           object: nil)
                    /// if response type is multi_ops than suggestion will be from choices card options
                    if self.viewModel.messageData?.responseList.last?.responseType == "multi_ops" && self.viewModel.isResetTapped == false && (self.viewModel.messageData?.masked ?? false) == false {
                            /// get suggestions
                            let suggestions = self.viewModel.messageData?.responseList.last?.multiOps?.choices

                            /// check suggestion greater then 0 else call suggestion api
                            if suggestions != nil && (suggestions?.count ?? 0) > 0 {
                                /// get filter suggestion according to typed text
                                let filtered = suggestions?.filter({$0.label.lowercased().contains(newText.lowercased())})
                                if filtered != nil && filtered?.count ?? 0 > 0 {
                                    self.viewModel.arrayOfSuggestions = []
                                    let context = self.viewModel.messageData?.contexts?.first
                                    for option in filtered! {
                                        let suggestion = Suggestion(originalText: option.label, displayText: option.value, intent_id: context?["intent_id"] as? Int, intent_uid: context?["intent_uid"] as? String, isLocalSearch: true, type: "multi_ops", intentName: context?["intent_name"] as? String, allChoiceOptions: suggestions, filteredChoiceOptions: filtered)
                                        self.viewModel.arrayOfSuggestions.append(suggestion)
                                    }
                                    DispatchQueue.main.async {
                                        /// update suggestion array
                                        self.viewModel.onSuccessResponseSuggestionApi(newText)
                                    }
                                } else { }
                            } else { }
                    } else if isQuickReply && self.viewModel.isResetTapped == false && (self.viewModel.messageData?.masked ?? false) == false {
                            /// if response type is quick_reply than suggestion will the buttons (except urls)
                            var suggestions: [BotQRButton] = []
                            for buttonCard in buttonCards {
                                switch buttonCard.kind {
                                case .quickReply(let items):
                                    suggestions.append(contentsOf: items.quickReplyProtocol?.otherButtons.filter({
                                                $0.type != "url"
                                            }) ?? [])
                                default:
                                    break
                                }
                            }
                            if suggestions.count > 0 {
                                /// get filter suggestion according to typed text
                                let filtered = suggestions.filter({$0.text.lowercased().contains(newText.lowercased())})
                                if filtered.count > 0 {
                                    self.viewModel.arrayOfSuggestions = []
                                    let context = self.viewModel.messageData?.contexts?.first
                                    for option in filtered {
                                        let suggestion = Suggestion(originalText: option.text, displayText: option.templateId, intent_id: context?["intent_id"] as? Int, intent_uid: context?["intent_uid"] as? String, isLocalSearch: true, type: option.type, intentName: context?["intent_name"] as? String)
                                        self.viewModel.arrayOfSuggestions.append(suggestion)
                                    }
                                    DispatchQueue.main.async {
                                        /// update suggestion array
                                        self.viewModel.onSuccessResponseSuggestionApi(newText)
                                    }
                                } else {
                                    if !(self.viewModel.messageData?.isPrompt ?? false) {
                                        perform(#selector(self.callSuggestionsAPI(txt:)),
                                                                                    with: newText, afterDelay: 0.1)
                                    }
                                }
                            } else {
                                if !(self.viewModel.messageData?.isPrompt ?? false) {
                                    perform(#selector(self.callSuggestionsAPI(txt:)),
                                                                                with: newText, afterDelay: 0.1)
                                }
                            }
                        } else {
                            if self.viewModel.messageData?.masked ?? false == true || self.viewModel.messageData?.isPrompt ?? false == true {
                                self.viewSuggestions.isHidden = true
                                self.viewModel.arrayOfSuggestions.removeAll()
                                self.searchedText = ""
                            } else {
                                perform(#selector(self.callSuggestionsAPI(txt:)),
                                        with: newText, afterDelay: 0.1)
                            }
                        }
                } else {
                    self.viewSuggestions.isHidden = true
                    self.viewModel.arrayOfSuggestions.removeAll()
                    self.searchedText = ""
                }
            }

            /// if masked is true than show secure text and button to show or hide secure text
            if self.viewModel.messageData?.masked ?? false {
                self.viewModel.textViewOriginalText.append(text)
                if let char = text.cString(using: String.Encoding.utf8) {
                    let isBackSpace = strcmp(char, "\\b")
                    if isBackSpace == -92 {}
                } else { }
            } else {}
            self.viewModel.isMessageTyping = true
            let maxLength =  self.viewModel.isFeedback ? self.viewModel.feedbackMaxCharacterLength : self.viewModel.maxCharacterLength
            return newText.count <= maxLength
        }
    }

    /// This function is use dto call the suggestion api
    /// - Parameter txt: String
    @objc func callSuggestionsAPI(txt: String) {
        self.viewModel.callSuggestionsAPI(txt: txt)
    }

    /// Update the progress of view based on the number of charactes entered
    func setCircularProgressForEnteredText(message: String) {
        let value = Float(message.count)
        let chararcterCount = self.viewModel.isFeedback ? self.viewModel.feedbackMaxCharacterLength : self.viewModel.maxCharacterLength
        let isOverLimit = message.count > chararcterCount
        if isOverLimit == false {
            self.circularProgress?.progress = (value)/Float(chararcterCount)
        }
    }

    /// This function is used to remove undread message cell. Unread messages are shown in case of chat tool
    func removeUnreadMessageCell() {
        if self.viewModel.showUnreadCount {
            self.viewModel.showUnreadCount = false
            self.viewModel.unreadCount = 0
            if let section = self.viewModel.unreadMessageIndexPath?.section {
                self.viewModel.arrayOfMessages2D.remove(at: section)
            }
            self.viewModel.unreadMessageIndexPath = nil
            DispatchQueue.main.async {
                UIView.performWithoutAnimation {
                    self.chatTableView.reloadData()
                }
            }
        }
    }
    func adjustTextViewHeight() {
        let fixedWidth = txtViewMessage.frame.size.width
        let newSize = txtViewMessage.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        if newSize.height > 75 {
            txtViewMessage.isScrollEnabled = true
        } else {
            txtViewMessage.isScrollEnabled = false
            msgTextViewHeight.constant = newSize.height <= self.msgTextViewMinHeight ? self.msgTextViewMinHeight : newSize.height
        }
        view.layoutSubviews()
    }
 }
 // end

