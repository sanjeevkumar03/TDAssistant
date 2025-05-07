// ImageCardCell.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit
import SDWebImage

// MARK: Protocol definition
protocol ImageCardCellDelegate: AnyObject {
    func didTapOnImageCardImage(section: Int, index: Int)
}

class ImageCardCell: UITableViewCell {
    // MARK: Outlet Declaration
    @IBOutlet weak var avatarViewWidth: NSLayoutConstraint!
    @IBOutlet weak var botImgBGView: UIView!
    @IBOutlet weak var botImgView: UIImageView!
    @IBOutlet weak var chatBubbleImgView: UIImageView!
    @IBOutlet weak var msgImgView: UIImageView!
    @IBOutlet weak var msgImgViewWidth: NSLayoutConstraint!
    @IBOutlet weak var msgImgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    
    // MARK: Property Declaration
    static let nibName = "ImageCardCell"
    static let identifier = "ImageCardCell"
    static let nibName_NT = "ImageCardCell-NT"
    static let identifier_NT = "ImageCardCell-NT"
    var configurationModal: VAConfigurationModel?
    weak var delegate: ImageCardCellDelegate?
    var isShowBotImage: Bool = true
    var chatTableSection: Int = 0
    var isGenAINewTheme: Bool = false
    let defaultImageHeight: CGFloat = (UIScreen.current?.bounds.width ?? 320) * 0.45
    let maxImageWidth: CGFloat = (UIScreen.current?.bounds.width ?? 320) * 0.6
    let maxScaleFactor: CGFloat = 1.5

    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImageView(_:)))
        gestureRecognizer.numberOfTapsRequired = 1
        return gestureRecognizer
    }()

    // MARK: Cell lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        msgImgView.addGestureRecognizer(tapGestureRecognizer)
        msgImgView.clipsToBounds = true
    }

    // MARK: Custom methods
    /// Used to configure image card
    /// - Parameter imageURL: It accepts image url string.
    func configure(imageURL: String, imageWidth: CGFloat, imageHeight: CGFloat) {
        if !isGenAINewTheme {
            msgImgView.contentMode = .scaleAspectFit
            msgImgView.layer.cornerRadius = 4
            containerViewWidth.constant = ChatBubble.getChatBubbleWidth()
            chatBubbleImgView.tintColor = VAColorUtility.receiverBubbleColor
        } /*else {
            let imgWidth = imageWidth < 60 ? 60 : imageWidth
            let imgHeight = imageHeight < 60 ? 60 : imageHeight
            let imageRatio: CGFloat = imgWidth/imgHeight
            if imageRatio == 1 {
                let width = imgWidth > maxImageWidth ? maxImageWidth : imgWidth
                self.msgImgViewWidth.constant = width
                self.msgImgViewHeight.constant = width
            } else if imageRatio > 1 {
                let height = imgHeight > defaultImageHeight ? defaultImageHeight : imgHeight
                if imageRatio > maxScaleFactor {
                    self.msgImgViewWidth.constant = height * maxScaleFactor
                    self.msgImgViewHeight.constant = self.msgImgViewWidth.constant * (imgHeight/imgWidth)
                } else {
                    self.msgImgViewWidth.constant = height * imageRatio
                    self.msgImgViewHeight.constant = height
                }
            } else {
                let height = imgHeight < defaultImageHeight ? imgHeight : defaultImageHeight
                self.msgImgViewWidth.constant = height * imageRatio
                self.msgImgViewHeight.constant = height
            }
        }*/
        if let url = URL(string: imageURL) {
            if msgImgView.accessibilityHint != "\(url)" || imageURL.hasSuffix(".gif") {
                if msgImgView.accessibilityHint == "\(url)" { /// This is done to show gif image animation
                    self.msgImgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                    self.msgImgView.accessibilityHint = "\(url)"
                    self.msgImgView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholderImage", in: Bundle.module, with: nil))
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.msgImgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                        self.msgImgView.accessibilityHint = "\(url)"
                        self.msgImgView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholderImage", in: Bundle.module, with: nil))
                    }
                }
            }
        }
        if !isGenAINewTheme {
            self.setCardUI()
        }
    }
    
    func setCardUI() {
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
    /// This function handles tap on imageView
    /// - Parameter sender: UITapGestureRecognizer
    @objc func didTapImageView(_ sender: UITapGestureRecognizer) {
        if let index = sender.view?.tag {
            delegate?.didTapOnImageCardImage(section: chatTableSection, index: index)
        }
    }
}
