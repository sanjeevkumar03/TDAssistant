// ButtonCardCell.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit
import SDWebImage

// MARK: Protocol definition
protocol ButtonCardCellDelegate: AnyObject {
    func didTapSSOButton(response: BotQRButton, cardIndexPath: IndexPath, ssoType: String)
    func didTapQuickReplyButton(response: BotQRButton, context: [Dictionary<String, Any>], cardIndexPath: IndexPath, selectedButtonIndex: Int)
}

class ButtonCardCell: UITableViewCell {
    // MARK: Outlet Declaration
    @IBOutlet weak var avatarViewWidth: NSLayoutConstraint!
    @IBOutlet weak var botImgBGView: UIView!
    @IBOutlet weak var botImgView: UIImageView!
    @IBOutlet weak var chatBubbleImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var SSOContainerView: UIView!
    @IBOutlet weak var SSOButton: UIButton!
    @IBOutlet weak var SSOBtnTitleLabel: UILabel!
    @IBOutlet weak var SSOContainerBottom: NSLayoutConstraint!
    @IBOutlet weak var SSOContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var SSOContainerLeading: NSLayoutConstraint!
    @IBOutlet weak var SSOContainerTrailing: NSLayoutConstraint!
    @IBOutlet weak var collectionContainerView: UIView!
    @IBOutlet weak var collectionContainerLeading: NSLayoutConstraint!
    @IBOutlet weak var collectionContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionContainerSuperviewTop: NSLayoutConstraint!
    @IBOutlet weak var collectionContainerTop: NSLayoutConstraint!
    @IBOutlet weak var buttonCollectionWidth: NSLayoutConstraint!
    @IBOutlet var buttonCollectionContainerTrailing_NT: NSLayoutConstraint!
    @IBOutlet weak var buttonCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonsCollection: UICollectionView!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var cardViewTrailingEqual: NSLayoutConstraint!
    @IBOutlet weak var cardViewTrailingGreaterThan: NSLayoutConstraint!
    @IBOutlet weak var buttonCollectionTop: NSLayoutConstraint!
    @IBOutlet weak var textWithSSOBottom: NSLayoutConstraint!

    // MARK: Property Declaration
    static let nibName = "ButtonCardCell"
    static let identifier = "ButtonCardCell"
    static let nibName_NT = "ButtonCardCell-NT"
    static let identifier_NT = "ButtonCardCell-NT"
    let buttonMinimumWidth: CGFloat = 80
    typealias CardControlsWidth = (titleWidth: CGFloat, ssoButtonWidth: CGFloat, quickReplyBtnWithLongestTextWidth: CGFloat)
    var configurationModal: VAConfigurationModel?
    var context: [Dictionary<String, Any>] = []
    var quickReplyResponse: QuickReply?
    let flowLayout = UICollectionViewFlowLayout()
    weak var delegate: ButtonCardCellDelegate?
    var isHideQuickReplyButton: Bool = false
    var cardIndexPath: IndexPath?
    var isShowBotImage: Bool = true
    let quickReplyCollectionMaxWidth = UIScreen.main.bounds.width-100
    var cardButtonsWidth: CardControlsWidth?
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var allowUserActivity: Bool = false
    var isGenAINewTheme: Bool = false
    var typingEffectSpeed: Double = 0.003
    var isShowTypingEffectAnimation: Bool = false

    // MARK: Cell lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        SSOButton.setTitle("", for: .normal)
    }

    // MARK: Custom methods
    func configure() {
        self.layoutIfNeeded()
        if !isGenAINewTheme{
            containerViewWidth.constant = ChatBubble.getChatBubbleWidth()
            cardViewTrailingGreaterThan.isActive = true
            SSOContainerView.clipsToBounds = true
            SSOContainerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            self.configureCardUI()
            self.SSOBtnTitleLabel.font = UIFont(name: fontName, size: textFontSize)
        }
        self.setCardWidth()
        if quickReplyResponse?.title == "" {
            self.titleLabel.isHidden = true
        } else {
            self.titleLabel.isHidden = false
            self.showAttributedText()
            if !isGenAINewTheme{
                self.chatBubbleImgView.isHidden = false
            }
        }
        if configurationModal?.result?.quickReply == false && isHideQuickReplyButton == true {
            SSOContainerView.isHidden = true
            SSOContainerHeight.constant = 0
            collectionContainerView.isHidden = true
            self.collectionContainerHeight.isActive = true
            if !isGenAINewTheme{
                textWithSSOBottom.isActive = true
            }
        } else {
            if !isGenAINewTheme{
                textWithSSOBottom.isActive = false
            }
            if quickReplyResponse?.ssoButton == nil {
                SSOContainerView.isHidden = true
                SSOContainerHeight.constant = 0
            } else {
                SSOContainerView.isHidden = false
                let ssoTitle = self.quickReplyResponse?.ssoButton?.attributedText
                if isGenAINewTheme{
                    ssoTitle?.addAttribute(.font, value: GenAIFonts().bold()!, range: NSRange(location: 0, length: ssoTitle?.length ?? 0))
                    ssoTitle?.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: ssoTitle?.length ?? 0))
                }
                self.SSOBtnTitleLabel.attributedText = ssoTitle
                self.SSOBtnTitleLabel.textAlignment = .center
                if !isGenAINewTheme{
                    self.SSOBtnTitleLabel.textColor = VAColorUtility.buttonColor
                    SSOContainerLeading.constant = isShowBotImage ? 12 : 9
                }
                SSOContainerHeight.constant = isGenAINewTheme ? 40 : 36
                // SSOContainerTrailing.constant = isShowBotImage ? 3 : 4
            }
            if isGenAINewTheme{
                if (quickReplyResponse?.title == "" && quickReplyResponse?.ssoButton == nil) || quickReplyResponse?.ssoButton == nil {
                     buttonCollectionTop.constant = 4
                } else {
                     buttonCollectionTop.constant = 12
                }
            } else {
                if quickReplyResponse?.title == "" && quickReplyResponse?.ssoButton == nil {
                    chatBubbleImgView.isHidden = true
                    collectionContainerSuperviewTop.isActive = true
                    collectionContainerTop.isActive = false
                    SSOContainerBottom.constant = 0
                     buttonCollectionTop.constant = 0
                } else {
                    chatBubbleImgView.isHidden = false
                    collectionContainerSuperviewTop.isActive = false
                    collectionContainerTop.isActive = true
                    SSOContainerBottom.constant = 4
                     buttonCollectionTop.constant = 0// 5
                }
            }

            if quickReplyResponse?.otherButtons.count ?? 0 > 0 {
                self.collectionContainerView.isHidden = false
                self.collectionContainerHeight.isActive = false
            } else {
                collectionContainerView.isHidden = true
                self.collectionContainerHeight.isActive = true
            }
            if !isGenAINewTheme{
                if configurationModal?.result?.enableAvatar ?? true {
                    collectionContainerLeading.constant = isShowBotImage ? 60 : 56
                } else {
                    collectionContainerLeading.constant = isShowBotImage ? 20 : 16
                }
            }
            self.configureButtonCollectionLayout()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
                UIView.performWithoutAnimation {
                    self.buttonsCollection.reloadData()
                }
            }
            self.buttonsCollection.flashScrollIndicators()
            self.buttonsCollection.contentOffset = .zero
        }
    }
    func showAttributedText() {
        let attributedStr: NSMutableAttributedString = quickReplyResponse?.attributedTitle ?? NSMutableAttributedString(string: "")
        if !isGenAINewTheme{
            attributedStr.addAttribute(.font, value: UIFont(name: fontName, size: textFontSize)!, range: NSRange(location: 0, length: attributedStr.length))
        } else {
            attributedStr.addAttribute(.font, value: GenAIFonts().bold()!, range: NSRange(location: 0, length: attributedStr.length))
        }
        if isGenAINewTheme && isShowTypingEffectAnimation && self.configurationModal?.result?.genAITypeWritingEffect ?? false {
            self.typewriteAttributedText(attributedStr, label: self.titleLabel)
        } else {
            self.titleLabel.attributedText = attributedStr
        }
    }
    func configureCardUI() {
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
        SSOBtnTitleLabel.textColor = VAColorUtility.buttonColor
        SSOContainerView.layer.borderColor = VAColorUtility.buttonColor.cgColor
        titleLabel.textColor = VAColorUtility.receiverBubbleTextIconColor
    }
    func setBotImage() {
        if let url = URL(string: self.configurationModal?.result?.avatar ?? "") {
            botImgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            botImgView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholderImage", in: Bundle.module, with: nil))
        } else {
            self.botImgView.image = UIImage(named: "botIcon", in: Bundle.module, with: nil)?.withRenderingMode(.alwaysTemplate)
            self.botImgView.tintColor = VAColorUtility.senderBubbleColor
        }
    }
    /// This function is used to configure button collection which shows button at the bottom of button card if available.
    func configureButtonCollection() {
        self.buttonsCollection.register(UINib(nibName: QuickReplyCell.nibName, bundle: Bundle.module), forCellWithReuseIdentifier: QuickReplyCell.identifier)
        self.buttonsCollection.layoutIfNeeded()
        self.buttonsCollection.delegate = self
        self.buttonsCollection.dataSource = self
    }
    func configureButtonCollectionLayout() {
        if (configurationModal?.result?.integration?[0].horizontalQuickReply == true) {
            flowLayout.scrollDirection = .horizontal
            buttonCollectionHeight.constant = isGenAINewTheme ? 40 : 50
            buttonsCollection.isScrollEnabled = true
            flowLayout.minimumInteritemSpacing = 10
        } else {
            flowLayout.scrollDirection = .vertical
            buttonCollectionHeight.constant = CGFloat((self.quickReplyResponse?.otherButtons.count ?? 0) * ((isGenAINewTheme ? 40 : 45) + 5))
            buttonsCollection.isScrollEnabled = false
            flowLayout.minimumLineSpacing = 5
        }
        self.buttonsCollection.collectionViewLayout = flowLayout
        self.configureButtonCollection()
    }

    func getWidthOfControls() -> CardControlsWidth {
        var buttonsText = ""
        if configurationModal?.result?.integration?[0].horizontalQuickReply == false {
            // Considering item with largest text from array
            if let largestButton = self.quickReplyResponse?.otherButtons.max(by: {$1.text.count > $0.text.count}) {
                buttonsText = largestButton.text
            }
        }
        let buttonsWithLongestTextWidth: CGFloat =  buttonsText.size(OfFont: UIFont(name: fontName, size: textFontSize)!).width
        let titleWidth: CGFloat =  quickReplyResponse?.title.size(OfFont: UIFont(name: fontName, size: textFontSize)!).width ?? 0
        let ssoButtonWidth: CGFloat = quickReplyResponse?.ssoButton?.text.size(OfFont: UIFont(name: fontName, size: textFontSize)!).width ?? 0
        return CardControlsWidth(titleWidth, ssoButtonWidth, buttonsWithLongestTextWidth)
    }

    func setCardWidth() {
        cardButtonsWidth = getWidthOfControls()
        if self.configurationModal?.result?.integration?[0].horizontalQuickReply == true {
            if !isGenAINewTheme {
                self.buttonCollectionWidth.constant = self.quickReplyCollectionMaxWidth
            } else {
                self.buttonCollectionWidth.isActive = false
                self.buttonCollectionContainerTrailing_NT.isActive = true
            }
        } else {
            if isGenAINewTheme {
                self.buttonCollectionWidth.isActive = true
                self.buttonCollectionContainerTrailing_NT.isActive = false
            }
            if cardButtonsWidth!.quickReplyBtnWithLongestTextWidth > self.quickReplyCollectionMaxWidth {
                self.buttonCollectionWidth.constant = self.quickReplyCollectionMaxWidth
            } else {
                let calculatedWidth = self.cardButtonsWidth!.quickReplyBtnWithLongestTextWidth + 30
                self.buttonCollectionWidth.constant = calculatedWidth < buttonMinimumWidth ? buttonMinimumWidth : calculatedWidth
            }
        }
    }

    // MARK: Button Actions
    @IBAction func SSOButtonTapped(_ sender: UIButton) {
        if let ssoButton = quickReplyResponse?.ssoButton {
            delegate?.didTapSSOButton(response: ssoButton, cardIndexPath: cardIndexPath!, ssoType: quickReplyResponse?.ssoType ?? "")
        }
    }

}

// MARK: UICollectionViewDelegate & UICollectionViewDataSource
extension ButtonCardCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quickReplyResponse?.otherButtons.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let buttonCell = collectionView.dequeueReusableCell(withReuseIdentifier: QuickReplyCell.identifier, for: indexPath)
        if indexPath.item >= (quickReplyResponse?.otherButtons.count ?? 0) {
            return buttonCell
        }
        if let cell = buttonCell as? QuickReplyCell {
            cell.quickReplyButton.tag = indexPath.item
            cell.allowUserActivity = allowUserActivity
            cell.isButtonClicked = quickReplyResponse?.otherButtons[indexPath.item].isButtonClicked ?? false
            cell.configure(item: quickReplyResponse?.otherButtons[indexPath.item], isGenAINewTheme: isGenAINewTheme)
            cell.delegate = self
            if isGenAINewTheme {
                cell.quickReplyBottom.constant = configurationModal?.result?.integration?[0].horizontalQuickReply == true ? 0 : 0
                cell.titleLabel.font = GenAIFonts().bold()
            } else {
                cell.quickReplyBottom.constant = configurationModal?.result?.integration?[0].horizontalQuickReply == true ? 10 : 0
                cell.titleLabel.font = UIFont(name: fontName, size: textFontSize-1)
            }
            return cell
        }
        return buttonCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item >= (quickReplyResponse?.otherButtons.count ?? 0) {
            return CGSize(width: 0, height: 0)
        }
        var buttonWidthWithMaxText: CGFloat = 0
        if configurationModal?.result?.integration?[0].horizontalQuickReply == false {
            for item in quickReplyResponse!.otherButtons {
                let attributedText = item.attributedText!
                let titleWidth = attributedText.width()
                buttonWidthWithMaxText = titleWidth > buttonWidthWithMaxText ? titleWidth : buttonWidthWithMaxText
            }
            buttonWidthWithMaxText += 10
        }
        if configurationModal?.result?.integration?[0].horizontalQuickReply == true {
            var textWidth = ((quickReplyResponse?.otherButtons[indexPath.item].attributedText?.width() ?? 50.0) + 20)
            let chatBubbleWidth = ChatBubble.getChatBubbleWidth() - 50
            textWidth = textWidth > chatBubbleWidth ? chatBubbleWidth : textWidth
            let cellWidth = textWidth < self.buttonMinimumWidth ? self.buttonMinimumWidth : textWidth
            return CGSize(width: cellWidth, height: isGenAINewTheme ? 40 : 50 )
        } else if buttonWidthWithMaxText < quickReplyCollectionMaxWidth && (quickReplyResponse?.otherButtons.count ?? 0) > 1 {
            let cellWidth = buttonWidthWithMaxText < self.buttonMinimumWidth ? self.buttonMinimumWidth : buttonWidthWithMaxText
            return CGSize(width: cellWidth, height: isGenAINewTheme ? 40 : 45 )
        } else {
            return CGSize(width: collectionView.bounds.width, height: isGenAINewTheme ? 40 : 45)
        }
    }
}

// MARK: QuickReplyCellDelegate
extension ButtonCardCell: QuickReplyCellDelegate {
    func didTapQuickReplyButton(response: BotQRButton, index: Int) {
        delegate?.didTapQuickReplyButton(response: response, context: self.context, cardIndexPath: cardIndexPath!, selectedButtonIndex: index)
    }
}

extension ButtonCardCell {
    private func typewriteAttributedText(_ attributedText: NSAttributedString, label: UILabel) {
        label.attributedText = NSAttributedString(string: "")
        var characterIndex = 0
        let textLength = attributedText.length
        Timer.scheduledTimer(withTimeInterval: typingEffectSpeed, repeats: true) { timer in
            if characterIndex < textLength {
                let range = NSRange(location: 0, length: characterIndex + 1)
                label.attributedText = attributedText.attributedSubstring(from: range)
                characterIndex += 1
                if characterIndex % 5 == 0 || characterIndex == textLength {
                    if let tableView = label.findTableViewSuperview(), let indexPath = tableView.indexPath(for: self) {
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
