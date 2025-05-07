// SenderCardCell.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit

class SenderCardCell: UITableViewCell {

    // MARK: Outlet Declaration
    @IBOutlet weak var senderImgView: UIImageView!
    @IBOutlet weak var chatBubbleImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var msgContentViewLeading: NSLayoutConstraint!
    @IBOutlet weak var msgContentViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dateLabelTop: NSLayoutConstraint!
    @IBOutlet weak var dateLabelBottom: NSLayoutConstraint!
    @IBOutlet weak var avatarViewWidth: NSLayoutConstraint!
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var replyMessageButton: UIButton!
    @IBOutlet weak var replyBGView: UIView!
    @IBOutlet weak var replyView: UIView!
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!

    // MARK: Property Declaration
    static let nibName = "SenderCardCell"
    static let identifier = "SenderCardCell"
    static let nibName_NT = "SenderCardCell-NT"
    static let identifier_NT = "SenderCardCell-NT"
    
    var bubbleColor: UIColor = .white
    var completeText: String = ""
    var completeAttributedText: NSAttributedString?
    var configIntegration: VAConfigIntegration?
    var configurationModal: VAConfigurationModel?
    var repliedMessageDict: [String: Any] = [:]
    weak var delegate: AgentTextCardCellDelegate?
    var indexPath: IndexPath!
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var dateFontSize: Double = 0.0
    var isChatToolChatClosed: Bool = false
    var isFormFields: Bool = false
    var isGenAINewTheme: Bool = false

    // MARK: Cell lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.textColor = .white
        replyMessageButton.setTitle("", for: .normal)
        replyLabel.text = ""
        replyButton.isHidden = true
        /*replyButton.setTitle("", for: .normal)
         if VAConfigurations.isChatTool {
            self.replyButton.isHidden = false
        } else {
            self.replyButton.isHidden = true
        }
        self.replyButton.borderColor = VAColorUtility.themeColor
        self.replyButton.backgroundColor = VAColorUtility.senderBubbleColor
        self.replyButton.tintColor = VAColorUtility.themeColor
        self.replyButton.imageView?.layer.transform = CATransform3DMakeScale(0.8, 0.8, 0.8)*/
    }

    // MARK: Custom methods
    func configure(indexPath: IndexPath, sentiment: Int?, configIntegration: VAConfigIntegration?, date: Date, masked: Bool?, repliedMessageDict: [String: Any]) {
        isGenAINewTheme = configurationModal?.result?.genAINewTheme ?? false
        
        if !isGenAINewTheme {
            chatBubbleImgView.tintColor = bubbleColor
            containerViewWidth.constant = ChatBubble.getChatBubbleWidth()
            self.titleLabel.font = UIFont(name: fontName, size: textFontSize)
            self.dateLabel.font  = UIFont(name: fontName, size: dateFontSize)
            self.dateLabel.textColor = VAColorUtility.themeTextIconColor
            self.titleLabel.textColor = VAColorUtility.senderBubbleTextIconColor
            self.chatBubbleImgView.tintColor = VAColorUtility.senderBubbleColor
        } else {
            self.titleLabel.textColor = VAColorUtility.black
        }
        self.indexPath = indexPath
        self.repliedMessageDict = repliedMessageDict
        self.setCardUI()
        self.configIntegration = configIntegration
        var senderText = completeText
        if VAConfigurations.isChatTool {
            titleLabel.text = senderText
        } else {
            senderText = masked == false ? completeText : self.checkForTranscript(configIntegration: configIntegration)
            if isFormFields {
                if senderText == "Form: No input provided" {
                    titleLabel.text = senderText
                    titleLabel.textAlignment = .right
                } else {
                    var completeAttributedText: NSMutableAttributedString?
                    completeText = "<span style=\"font-family: \(fontName); font-size: \(textFontSize)px\">\(senderText)</span>"
                    if let attributedText = completeText.htmlToAttributedString as? NSMutableAttributedString {
                        completeAttributedText = attributedText
                        completeAttributedText?.addAttribute(NSAttributedString.Key.foregroundColor,
                                                             value: VAColorUtility.senderBubbleTextIconColor,
                                                             range: NSRange(location: 0, length: completeAttributedText!.length))
                        titleLabel.attributedText = completeAttributedText
                    }
                    titleLabel.textAlignment = .left
                }
            } else {
                titleLabel.text = senderText
                if !isGenAINewTheme {
                    if senderText.count > 10 {
                        titleLabel.textAlignment = .right
                    } else {
                        titleLabel.textAlignment = .center
                    }
                }
            }
        }
        
        self.dateLabel.text = getMessageTime(date: date)
        if !isGenAINewTheme {
            self.senderImgView.image = self.getSenderImage(sentiment: sentiment)
            self.senderImgView.tintColor = VAColorUtility.themeTextIconColor
        }
        self.replyLabel.textColor = VAColorUtility.receiverBubbleTextIconColor
        if self.repliedMessageDict.count > 0 {
            if let msg = self.repliedMessageDict["msg"] as? String {
                self.replyLabel.text = msg
                self.replyBGView.isHidden = false
            } else {
                self.replyLabel.text = ""
                self.replyBGView.isHidden = true
            }
        } else {
            self.replyLabel.text = ""
            self.replyBGView.isHidden = true
        }
    }

    func setCardUI() {
        if configurationModal?.result?.enableAvatar ?? true {
            avatarView.isHidden = false
            if !isGenAINewTheme {
                chatBubbleImgView.image = ChatBubble.createChatBubble(isBotMsg: false)
            }
        } else {
            avatarViewWidth.constant = 0
            avatarView.isHidden = true
            if !isGenAINewTheme {
                msgContentViewLeading.constant = 8
                msgContentViewTrailing.constant = -15
                chatBubbleImgView.image = ChatBubble.createRoundedChatBubble()
            } else {
                dateViewHeight.constant = 20
            }
        }

    }
    func checkForTranscript(configIntegration: VAConfigIntegration?) -> String {
        if let array = configIntegration?.redaction, array.count > 0 {
            var isRegexMatched: Bool = false
            var modifiedString: String = ""
            for index in 0..<array.count {
                let model = array[index]
                if model.active != nil && model.active == true {
                    if let regex = model.regex {
                        isRegexMatched = completeText.matches(regex)
                        if completeText.contains("•") {
                            return "●●●●●●●●●●"/// this is to show user 10 dots whether user types 1 character or 100 chars.
                            ///For security so that user cant guess how many characters user has typed.
                        }
                        if isRegexMatched {
                            modifiedString = String(repeating: "*", count: completeText.count)
                            break
                        }
                    }
                }
            }
            return isRegexMatched ? modifiedString : completeText
        }
        return completeText
    }
    
    func redactedText(_ text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        
        // Apply a redaction style (black box covering the text)
        let range = NSRange(location: 0, length: text.count)
        attributedString.addAttribute(.backgroundColor, value: UIColor.black, range: range)
        attributedString.addAttribute(.foregroundColor, value: UIColor.clear, range: range) // Hide the text
        
        return attributedString
        /*
         // Create some ASCII values
         var asciiVal4 = 9733;
         // Convert the ASCII values to a characters
         var char4 = UnicodeScalar(asciiVal4)!
         print("Char: ",char4);
         */
    }

    private func getSenderImage(sentiment: Int?) -> UIImage {
        if sentiment == 1 {
            return UIImage(named: "emoji7", in: Bundle.module, with: nil)!
        } else if sentiment == -1 {
            return UIImage(named: "emoji3", in: Bundle.module, with: nil)!
        } else {
            return UIImage(named: "emoji6", in: Bundle.module, with: nil)!
        }
    }

    func getLabelText() -> String {
        return completeText
    }

    func getAttributedLabelText() -> NSAttributedString {
        return completeAttributedText!
    }

    @IBAction func replyMessageTapped(_ sender: UIButton) {
        delegate?.didTapOldMsg(repliedMessageDict: self.repliedMessageDict, indexPath: self.indexPath)
    }

    @IBAction func replyButtonTapped(_ sender: UIButton) {
        delegate?.didTapOnReplyButton(indexPath: self.indexPath)
    }
}

extension String {
    mutating func removingRegexMatches(pattern: String, replaceWith: String = "*****") {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: count)
            self = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch { return }
    }
}
