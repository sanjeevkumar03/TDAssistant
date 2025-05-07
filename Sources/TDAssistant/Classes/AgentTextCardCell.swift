// AgentTextCardCell.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit
import SDWebImage

// MARK: Protocol definition
protocol AgentTextCardCellDelegate: AnyObject {
    func didTapOldMsg(repliedMessageDict: [String: Any], indexPath: IndexPath)
    func didTapOnReplyButton(indexPath: IndexPath)
}

class AgentTextCardCell: UITableViewCell {
    // MARK: Outlet Declaration
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var avatarViewWidth: NSLayoutConstraint!
    @IBOutlet weak var botImgView: UIImageView!
    @IBOutlet weak var chatBubbleImgView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var cardViewTrailingEqual: NSLayoutConstraint!
    @IBOutlet weak var cardViewTrailingGreaterThan: NSLayoutConstraint!
    @IBOutlet weak var oldMessageButton: UIButton!
    @IBOutlet weak var msgContainer: UIView!
    @IBOutlet weak var replyView: UIView!
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var agentNameLabel: UILabel!
    @IBOutlet weak var dateViewHeight: NSLayoutConstraint!
    @IBOutlet weak var msgContainerTop: NSLayoutConstraint!
    @IBOutlet weak var textViewLeading: NSLayoutConstraint!
    @IBOutlet weak var textViewBottom: NSLayoutConstraint!
    @IBOutlet weak var textCardBottom: NSLayoutConstraint!
    
    // MARK: Property Declaration
    static let nibName = "AgentTextCardCell"
    static let identifier = "AgentTextCardCell"
    static let nibName_NT = "AgentTextCardCell-NT"
    static let identifier_NT = "AgentTextCardCell-NT"
    
    var completeText: String = ""
    var completeAttributedText: NSMutableAttributedString?
    var configurationModal: VAConfigurationModel?
    var msgDate: Date? = nil
    weak var delegate: AgentTextCardCellDelegate?
    var repliedMessageDict: [String: Any] = [:]
    var indexPath: IndexPath!
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var isDoNotRespond: Bool = false
    var isChatToolChatClosed: Bool = false
    var dateFontSize: Double = 0.0
    var isGenAINewTheme: Bool = false
    var agentName: String = ""
    var typingEffectSpeed: Double = 0.003
    var isShowTypingEffectAnimation: Bool = false
    
    // MARK: Cell lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        oldMessageButton.setTitle("", for: .normal)
        replyLabel.text = ""
        textView.linkTextAttributes = [.underlineStyle: 0]
    }

    // MARK: Custom methods
    func configure(indexPath: IndexPath) {
        self.indexPath = indexPath
        self.configureCardUI()
        if !isGenAINewTheme {
            containerViewWidth.constant = ChatBubble.getChatBubbleWidth()
            dateLabel.font = UIFont(name: fontName, size: dateFontSize)
            dateLabel.textColor = VAColorUtility.themeTextIconColor
        } else {
            agentNameLabel.text = agentName.isEmpty ? "Agent" : agentName
        }
        dateLabel.text = getMessageTime(date: msgDate ?? Date())
        if isHTMLText(completeText) {
            // Remove extra space
            completeText = completeText.replacingOccurrences(of: "</p><p><br>", with: "")
            // Fix mailto, call tags
            completeText = completeText.replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">").replacingOccurrences(of: "/a&gt", with: "/a>")
            // Adding custom font  to html string
            completeText = "<span style=\"font-family: Helvetica; font-size: 16px\">\(completeText)</span>"
            if !isGenAINewTheme {
                if completeAttributedText?.length ?? 0 > 10 {
                    textView.textAlignment = .left
                } else {
                    textView.textAlignment = .center
                }
            }
            self.showAttributedText()
        } else {
            if !isGenAINewTheme {
                textView.textColor = VAColorUtility.receiverBubbleTextIconColor
                if completeText.count > 10 {
                    textView.textAlignment = .left
                } else {
                    textView.textAlignment = .center
                }
            }
            self.showNormalText()
        }
        let textWidth = self.textView.attributedText?.width()  ?? containerViewWidth.constant
        if !isGenAINewTheme {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.001) {
                if textWidth > self.containerViewWidth.constant {
                    self.cardViewTrailingEqual.isActive = true
                    self.cardViewTrailingGreaterThan.isActive = false
                } else {
                    self.cardViewTrailingEqual.isActive = false
                    self.cardViewTrailingGreaterThan.isActive = true
                }
            }
        }
    }
    func showAttributedText() {
        if let attributedText = self.completeText.htmlToAttributedString as? NSMutableAttributedString {
            self.completeAttributedText = attributedText
            if !isGenAINewTheme {
                self.completeAttributedText?.addAttribute(NSAttributedString.Key.foregroundColor,
                                                          value: VAColorUtility.receiverBubbleTextIconColor,
                                                          range: NSRange(location: 0, length: completeAttributedText!.length))
            }
        }
        
        if isGenAINewTheme && isShowTypingEffectAnimation && self.configurationModal?.result?.genAITypeWritingEffect ?? false {
            self.typewriteAttributedText(completeAttributedText ?? NSMutableAttributedString(string: ""), textView: self.textView)
        } else {
            self.textView.attributedText = completeAttributedText
        }
    }
    func showNormalText() {
        if isGenAINewTheme && isShowTypingEffectAnimation && self.configurationModal?.result?.genAITypeWritingEffect ?? false {
            self.typewriteText(completeText, textView: self.textView)
        } else {
            textView.text = completeText
        }
    }
    func configureCardUI() {
        if !isGenAINewTheme {
            if !VAConfigurations.isChatTool {
                self.botImgView.image = UIImage(named: "chatbot", in: Bundle.module, with: nil)
            } else {
                if let url = URL(string: self.configurationModal?.result?.avatar ?? "") {
                    botImgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                    botImgView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholderImage", in: Bundle.module, with: nil))
                } else {
                    self.botImgView.image = UIImage(named: "botIcon", in: Bundle.module, with: nil)?.withRenderingMode(.alwaysTemplate)
                    self.botImgView.tintColor = VAColorUtility.senderBubbleColor
                }
            }
        }
        if configurationModal?.result?.enableAvatar ?? true {
            avatarView.isHidden = false
            if !isGenAINewTheme {
                self.chatBubbleImgView.image = ChatBubble.createChatBubble(isBotMsg: true)
                self.chatBubbleImgView.tintColor = VAColorUtility.receiverBubbleColor
            }
        } else {
            avatarView.isHidden = true
            avatarViewWidth.constant = 0
            if !isGenAINewTheme {
                chatBubbleImgView.image = ChatBubble.createRoundedChatBubble()
            }
        }
        
        self.replyLabel.textColor = VAColorUtility.receiverBubbleTextIconColor
        if repliedMessageDict.count > 0 {
            if let msg = repliedMessageDict["msg"] as? String {
                self.replyLabel.text = msg
                self.replyView.isHidden = false
            } else {
                self.replyLabel.text = ""
                self.replyView.isHidden = true
            }
            if isGenAINewTheme {
                self.msgContainer.backgroundColor = VAColorUtility.alabaster_NT
                self.msgContainerTop.constant = 8
                self.textViewLeading.constant = 6
                self.textCardBottom.constant = 12
                self.textViewBottom.constant = 4
            }
        } else {
            self.replyLabel.text = ""
            self.replyView.isHidden = true
            if isGenAINewTheme {
                self.msgContainer.backgroundColor = .clear
                self.msgContainerTop.constant = -8
                self.textViewLeading.constant = -6
                self.textCardBottom.constant = 0
                self.textViewBottom.constant = 0
            }
        }
    }

    // MARK: Button Actions
    @IBAction func oldMessageTapped(_ sender: UIButton) {
        delegate?.didTapOldMsg(repliedMessageDict: self.repliedMessageDict, indexPath: self.indexPath)
    }
}

extension AgentTextCardCell {
    private func typewriteAttributedText(_ attributedText: NSAttributedString, textView: UITextView) {
        textView.attributedText = NSAttributedString(string: "")
        var characterIndex = 0
        let textLength = attributedText.length
        Timer.scheduledTimer(withTimeInterval: typingEffectSpeed, repeats: true) { timer in
            if characterIndex < textLength {
                let range = NSRange(location: 0, length: characterIndex + 1)
                textView.attributedText = attributedText.attributedSubstring(from: range)
                characterIndex += 1
                if characterIndex % 5 == 0 || characterIndex == textLength {
                    if let tableView = textView.findTableViewSuperview(), let indexPath = tableView.indexPath(for: self) {
                        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        UIView.performWithoutAnimation {
                            tableView.beginUpdates()
                            tableView.endUpdates()
                        }
                    }
                }
            } else {
                timer.invalidate()
            }
        }
    }
    private func typewriteText(_ text: String, textView: UITextView) {
        textView.text = ""
        var characterIndex = 0
        let textLength = text.count
        
        Timer.scheduledTimer(withTimeInterval: typingEffectSpeed, repeats: true) { timer in
            if characterIndex < textLength {
                let substring = text.prefix(characterIndex + 1)
                textView.text = String(substring)
                characterIndex += 1
                
                if characterIndex % 5 == 0 || characterIndex == textLength {
                    if let tableView = textView.findTableViewSuperview(), let indexPath = tableView.indexPath(for: self) {
                        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        UIView.performWithoutAnimation {
                            tableView.beginUpdates()
                            tableView.endUpdates()
                        }
                    }
                }
            } else {
                timer.invalidate()
            }
        }
    }
}
