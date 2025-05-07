// TextCardCell.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit
import SDWebImage
@preconcurrency import WebKit

// MARK: Protocol definition
protocol TextCardCellDelegate: AnyObject {
    func didTapReadMore(section: Int, index: Int)
    func didTapOnSourceURL(url: String)
    func didTapOnTextAttachment(image: UIImage)
    func didTapOnQueryLink(displayText: String, dataQuery: String, indexPath: IndexPath)
    func didTapCitationUrl(title: String, url: String)
}

class TextCardCell: UITableViewCell {
    // MARK: Outlet Declaration
    @IBOutlet weak var avatarViewWidth: NSLayoutConstraint!
    @IBOutlet weak var botImgBGView: UIView!
    @IBOutlet weak var botImgView: UIImageView!
    @IBOutlet weak var chatBubbleImgView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var readMoreContainerView: UIView!
    @IBOutlet weak var readMoreButton: UIButton!
    @IBOutlet weak var readMoreLabel: UILabel!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var cardViewTrailingEqual: NSLayoutConstraint!
    @IBOutlet weak var cardViewTrailingGreaterThan: NSLayoutConstraint!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var sourceButton: UIButton!
    @IBOutlet weak var sourceView: UIView!
    @IBOutlet weak var sourceViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textCardViewBottom: NSLayoutConstraint!
    @IBOutlet weak var citationContainer: UIView!
    @IBOutlet weak var citationContainerTop: NSLayoutConstraint!
    @IBOutlet weak var citationContainerWidth: NSLayoutConstraint!
    @IBOutlet weak var citationContainerHeight: NSLayoutConstraint!

    // MARK: Property Declaration
    static let nibName = "TextCardCell"
    static let identifier = "TextCardCell"
    static let nibName_NT = "TextCardCell-NT"
    static let identifier_NT = "TextCardCell-NT"
    var isCellExpanded: Bool = false
    var completeText: String = ""
    var originalText: String = ""
    var completeAttributedText: NSMutableAttributedString?
    var configurationModal: VAConfigurationModel?
    weak var delegate: TextCardCellDelegate?
    var textItem: TextItem?
    var isShowBotImage: Bool = true
    var isAgent: Bool = false
    var chatTableSection: Int = 0
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var maxCitations = 0
    var hasMoreOption: Bool = false
    var isCitationViewExpanded: Bool = false
    var seeMoreButtonTag = 999
    var citations: [CitationObject] = []
    var modifiedCitations: [CitationObject] = []
    var isGenAINewTheme: Bool = false
    var readMoreDefaultLimit: Int = 500
    var typingEffectSpeed: Double = 0.003
    var isShowTypingEffectAnimation: Bool = false
    
    // https://gist.github.com/hashaam/31f51d4044a03473c18a168f4999f063
    
    // MARK: Cell lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        readMoreButton.setTitle("", for: .normal)
        self.sourceButton.setTitle("", for: .normal)
        textView.tintColor = #colorLiteral(red: 0, green: 0.3647058824, blue: 1, alpha: 1)
        textView.delegate = self
        textView.linkTextAttributes = [.underlineStyle: 0]
    }

    // MARK: Custom methods
    func configure() {
        let isReadMore = self.configurationModal?.result?.integration?[0].readMoreLimit?.readMore ?? false
        let maxTextLimit = self.configurationModal?.result?.integration?[0].readMoreLimit?.characterCount ?? readMoreDefaultLimit
        isGenAINewTheme = self.configurationModal?.result?.genAINewTheme ?? false
        if let speed = self.configurationModal?.result?.genAITypeWritingEffectSpeed {
            typingEffectSpeed = Double(speed)/1000
        }
        if !isGenAINewTheme {
            containerViewWidth.constant = ChatBubble.getChatBubbleWidth()
        } else {
            textView.textContainer.lineFragmentPadding = 0
            textView.textContainerInset = .zero
            textView.contentInset = .zero
        }
        self.configureCardUI()
        originalText = completeText
        if isHTMLText(originalText) {
            if completeAttributedText?.length ?? 0 <= maxTextLimit {
                readMoreContainerView.isHidden = true
            } else {
                readMoreContainerView.isHidden = isReadMore ? !(completeAttributedText?.length ?? 0 > maxTextLimit) : true
            }
            self.showText()
            if !isGenAINewTheme {
                if completeAttributedText?.length ?? 0 > 10 {
                    textView.textAlignment = .left
                } else {
                    textView.textAlignment = .center
                }
            }
        } else {
            readMoreContainerView.isHidden = !isReadMore || completeAttributedText?.length ?? 0 <= maxTextLimit
            self.showText()
            if !isGenAINewTheme {
                if completeAttributedText?.length ?? 0 > 10 {
                    self.textView.textAlignment = .left
                } else {
                    self.textView.textAlignment = .center
                }
            }
            textView.isHidden = false
        }
        readMoreLabel.text = isCellExpanded == true ? "...\(LanguageManager.shared.localizedString(forKey: "Read Less"))" : "...\(LanguageManager.shared.localizedString(forKey: "Read More"))"
        
        if !isGenAINewTheme {
            readMoreLabel.font = UIFont(name: fontName, size: textFontSize)
            sourceLabel.font = UIFont(name: fontName, size: textFontSize)
            let textWidth = self.textView.attributedText?.width()  ?? containerViewWidth.constant
            if textWidth > containerViewWidth.constant {
                cardViewTrailingEqual.isActive = true
                cardViewTrailingGreaterThan.isActive = false
            } else {
                cardViewTrailingEqual.isActive = false
                cardViewTrailingGreaterThan.isActive = true
            }
        }
    }
    func showText() {
        let attributedText = self.getAttributedLabelText(isExpanded: self.isCellExpanded, isFullText: self.readMoreContainerView.isHidden)
        if isGenAINewTheme && isShowTypingEffectAnimation /*&& self.configurationModal?.result?.genAITypeWritingEffect ?? false*/ {
            self.typewriteAttributedText(attributedText, textView: self.textView)
        } else {
            self.textView.attributedText = attributedText
        }
    }
    func configureCardUI() {
        if !isGenAINewTheme {
            if configurationModal?.result?.enableAvatar ?? true {
                if isShowBotImage {
                    self.setBotImage()
                    botImgBGView.isHidden = false
                    chatBubbleImgView.image = ChatBubble.createChatBubble(isBotMsg: true)
                } else {
                    botImgBGView.isHidden = true
                    chatBubbleImgView.image = ChatBubble.createRoundedChatBubble()
                }
            } else {
                avatarViewWidth.constant = 0
                botImgBGView.isHidden = true
                chatBubbleImgView.image = ChatBubble.createRoundedChatBubble()
            }
            chatBubbleImgView.tintColor = VAColorUtility.receiverBubbleColor
        }
        
        if textItem?.source == nil {
            sourceView.isHidden = true
            sourceViewHeight.constant = 0
            if !isGenAINewTheme {
                textCardViewBottom.isActive = false
            }
        } else {
            sourceView.isHidden = false
            if !isGenAINewTheme {
                sourceViewHeight.constant = 30
                textCardViewBottom.constant = 35
                textCardViewBottom.isActive = true
            } else {
                sourceViewHeight.constant = 25
            }
        }
        if (configurationModal?.result?.enableCitation ?? false) && !(textItem?.citations?.isEmpty ?? false) {
            citationContainer.isHidden = false
            if !isGenAINewTheme {
                textCardViewBottom.isActive = true
            }
            self.citationsInitialSetup()
        } else {
            citationContainerHeight.constant = 0
            citationContainer.isHidden = true
            
        }
    }

    func setBotImage() {
        if self.isAgent && !VAConfigurations.isChatTool {
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

    func getLabelText(isExpanded: Bool, isFullText: Bool) -> String {
        let maxTextLimit = self.configurationModal?.result?.integration?[0].readMoreLimit?.characterCount ?? readMoreDefaultLimit
        if isExpanded || isFullText {
            return completeText
        } else {
            let textToDisplay = Array(completeText.prefix(maxTextLimit))
            return String(textToDisplay)
        }
    }

    func getAttributedLabelText(isExpanded: Bool, isFullText: Bool) -> NSAttributedString {
        let maxTextLimit = self.configurationModal?.result?.integration?[0].readMoreLimit?.characterCount ?? readMoreDefaultLimit
        if isExpanded || isFullText {
            let attributedText = completeAttributedText
            if attributedText?.length ?? 0 > 0 {
                return attributedText!
            } else {
                return NSAttributedString(string: "")
            }
        } else {
            let length = completeAttributedText?.length ?? 0 > maxTextLimit ? maxTextLimit : (completeAttributedText?.length ?? 0)
            if let attributedString = completeAttributedText?.attributedSubstring(from: NSRange(location: 0, length: length)) {
                let attributedText: NSMutableAttributedString = attributedString as? NSMutableAttributedString ?? NSMutableAttributedString(string: "")
                return attributedText
            }
            let attributedText = completeAttributedText
            return attributedText!
        }
    }

    // MARK: Button Actions
    @IBAction func readMoreTapped(_ sender: UIButton) {
        delegate?.didTapReadMore(section: chatTableSection, index: sender.tag)
    }
    @IBAction func sourceTapped(_ sender: UIButton) {
        delegate?.didTapOnSourceURL(url: textItem?.source?.onesource ?? "")
    }
}

extension TextCardCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let attachment = textAttachment.image {
            delegate?.didTapOnTextAttachment(image: attachment)
        }
        return true
    }
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print(URL)
        if UIApplication.shared.canOpenURL(URL) == false {
            let newRange = Range(characterRange, in: textView.text ?? "")!
            let subString = textView.text[newRange]
            let queryLink = String(subString)
            let chatTableIndexPath = IndexPath(row: readMoreButton.tag, section: chatTableSection)
            let dataQuery = self.getDataQueryAttributeFromHtmlString(queryText: queryLink)
            delegate?.didTapOnQueryLink(displayText: queryLink, dataQuery: dataQuery, indexPath: chatTableIndexPath)
            return false
        } else {
            delegate?.didTapOnSourceURL(url: URL.absoluteString)
            return false
        }
        //return true
    }
    func getDataQueryAttributeFromHtmlString(queryText: String) -> String {
        var splittedText = originalText.components(separatedBy: "data-query")
        splittedText.removeFirst()
        for item in splittedText {
            if item.contains("data-displayname=\"\(queryText)\"") || item.contains("data-displayname=\" \(queryText)\"") || item.contains("data-displayname=\"\(queryText) \"") || item.contains("data-displayname=\" \(queryText) \"") {
                let splittedItem = item.components(separatedBy: "data-displayname")
                let dataQuery = splittedItem.first ?? ""
                return dataQuery.replacingOccurrences(of: "=\"", with: "").replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return ""
    }
}

extension String {
    var isValidURL: Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}

/// Citations
extension TextCardCell {
    func citationsInitialSetup() {
        if !isGenAINewTheme {
            citationContainerWidth.constant = containerViewWidth.constant
        }
        maxCitations = configurationModal?.result?.genAISettings?.citationsMaxLimit ?? 2
        citations = textItem?.citations ?? []
        if maxCitations < citations.count {
            hasMoreOption = true
            self.setupSeeMoreView()
        } else {
            modifiedCitations = citations
            self.setupCitationView()
        }
    }
    func setupSeeMoreView() {
        modifiedCitations = Array(citations.prefix(maxCitations))
        let lastOption = CitationObject(["title": "+\(citations.count-maxCitations) more", "url": ""])
        modifiedCitations.append(lastOption)
        isCitationViewExpanded = false
        self.setupCitationView()
    }
    
    func setupSeeLessView() {
        modifiedCitations = citations
        let lastOption = CitationObject(["title": "- see less", "url": ""])
        modifiedCitations.append(lastOption)
        isCitationViewExpanded = true
        self.setupCitationView()
    }
    
    func setupCitationView() {
        for view in citationContainer.subviews {
            view.removeFromSuperview()
        }
        let containerWidth = UIScreen.main.bounds.width - (isGenAINewTheme ? 32 : 60)
        let textMaxWidth: CGFloat = (containerWidth - 126)/3
        var xAxis: CGFloat = 0
        var yAxis: CGFloat = 0
        let citationHeight: CGFloat = 24
        
        for (index, citation) in modifiedCitations.enumerated() {
            let text = citation.title
            var viewWidth: CGFloat = 0
            let citationView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: citationHeight))
            citationView.layer.cornerRadius = 3
            citationView.layer.borderWidth = 1
            citationView.clipsToBounds = true
            citationView.layer.borderColor = UIColor.lightGray.cgColor
            citationView.backgroundColor = .clear
            
            if !hasMoreOption || index < modifiedCitations.count-1 {
                let citationThumbnail = UIImageView(frame: CGRect(x: 6, y: 4, width: 16, height: 16))
                citationThumbnail.backgroundColor = .clear
                if !modifiedCitations[index].url.isEmpty, let url = URL(string: "\(modifiedCitations[index].url)/favicon.ico") {
                    citationThumbnail.sd_setImage(with: url, placeholderImage: UIImage(named: "citation-thumbnail", in: Bundle.module, with: nil))
                } else {
                    citationThumbnail.image = UIImage(named: "citation-thumbnail", in: Bundle.module, with: nil)
                }
                citationView.addSubview(citationThumbnail)
                viewWidth += 22//x+width
            }
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: citationHeight))
            titleLabel.text = text
            titleLabel.textAlignment = .left
            titleLabel.font = GenAIFonts().normal(fontSize: 12)
            titleLabel.backgroundColor = .clear
            titleLabel.textColor = VAColorUtility.green_NT
            titleLabel.numberOfLines = 1
            var textWidth = text.size(withAttributes: [.font: titleLabel.font!]).width + 2
            textWidth = textWidth > textMaxWidth ? textMaxWidth : textWidth
            if !hasMoreOption || index < modifiedCitations.count-1 {
                titleLabel.frame.origin.x = viewWidth+4
                titleLabel.frame.size.width = textWidth
                viewWidth += 4+textWidth//x+textwidth
            } else {
                titleLabel.frame.origin.x = 6
                titleLabel.frame.size.width = textWidth
                viewWidth += 6+textWidth//x+textwidth
                citationView.backgroundColor = VAColorUtility.lightGrey_NT
            }
            citationView.addSubview(titleLabel)
            citationView.frame.size.width = viewWidth+5
            
            let citationButton = UIButton(type: .custom)
            citationButton.frame = CGRect(x: citationView.bounds.origin.x, y: citationView.bounds.origin.y, width: citationView.bounds.width, height: citationView.bounds.height)
            citationButton.titleLabel?.text = ""
            citationButton.backgroundColor = .clear
            citationView.addSubview(citationButton)
            
            if hasMoreOption && index == modifiedCitations.count-1 {
                citationButton.tag = seeMoreButtonTag
            } else {
                citationButton.tag = index
                if citation.url.isEmpty {
                    citationView.backgroundColor = .systemGroupedBackground
                } else {
                    citationView.backgroundColor = .white
                }
            }
            citationButton.addTarget(self, action: #selector(citationClicked), for: .touchUpInside)
            
            if (xAxis + citationView.frame.width) > containerWidth {
                yAxis += citationHeight + 8
                xAxis = 0
                citationView.frame.origin.x = xAxis
                citationView.frame.origin.y = yAxis
                xAxis += citationView.frame.width + 8
            } else {
                citationView.frame.origin.x = xAxis
                citationView.frame.origin.y = yAxis
                xAxis += citationView.frame.width + 8
            }
            citationContainer.addSubview(citationView)
            citationContainerHeight.constant = yAxis+citationHeight
            if !isGenAINewTheme {
                textCardViewBottom.constant = citationContainerHeight.constant + 18
            }
        }
        var view = self.superview
        while (view != nil && (view as? UITableView) == nil) {
          view = view?.superview
        }
        if let tableView = view as? UITableView {
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }
    
    @objc func citationClicked(sender: UIButton) {
        if sender.tag == seeMoreButtonTag {
            isCitationViewExpanded ? setupSeeMoreView() : setupSeeLessView()
        } else {
            if !modifiedCitations[sender.tag].url.isEmpty {
                delegate?.didTapCitationUrl(title: modifiedCitations[sender.tag].title, url: modifiedCitations[sender.tag].url)
            }
        }
    }
}

extension TextCardCell {
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
}
