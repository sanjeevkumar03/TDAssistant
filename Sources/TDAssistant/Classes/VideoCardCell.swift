// VideoCardCell.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit
import AVKit
import SDWebImage

// MARK: Protocol definition
protocol VideoCardCellDelegate: AnyObject {
    func didTapPlayButton(videoUrl: String, index: Int)
}

class VideoCardCell: UITableViewCell {

    // MARK: Outlet declaration
    @IBOutlet weak var avatarViewWidth: NSLayoutConstraint!
    @IBOutlet weak var botImgBGView: UIView!
    @IBOutlet weak var botImgView: UIImageView!
    @IBOutlet weak var chatBubbleImgView: UIImageView!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var playVideoButton: UIButton!
    @IBOutlet weak var videoImgView: UIImageView!
    @IBOutlet weak var playImgView: UIImageView!

    // MARK: Property declaration
    static let nibName = "VideoCardCell"
    static let identifier = "VideoCardCell"
    static let nibName_NT = "VideoCardCell-NT"
    static let identifier_NT = "VideoCardCell-NT"
    var videoUrl: String = ""
    var index: Int?
    var configurationModal: VAConfigurationModel?
    weak var delegate: VideoCardCellDelegate?
    var isShowBotImage: Bool = true
    var isGenAINewTheme: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        self.playVideoButton.setTitle("", for: .normal)
    }

    @IBAction func playButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapPlayButton(videoUrl: self.videoUrl, index: self.index!)
    }

    func configureCell(videoUrl: String, index: Int) {
        if !isGenAINewTheme {
            self.setCardUI()
            self.videoImgView.layer.cornerRadius = 4
            self.playVideoButton.layer.cornerRadius = 4
            self.playImgView.layer.cornerRadius = 4
            self.containerViewWidth.constant = ChatBubble.getChatBubbleWidth()
            self.chatBubbleImgView.tintColor = VAColorUtility.receiverBubbleColor
        }
        self.videoUrl = videoUrl
        self.index = index
        if videoUrl.contains("www.youtube.com") || videoUrl.contains("youtu.be") {
            self.playImgView.image = UIImage(named: "youtubePlayIcon", in: Bundle.module, compatibleWith: nil)
            let videoID = Helper.getYouTubeVideoIdForThumbnailGeneration(videoUrl: videoUrl)
            if videoID.isEmpty {
                self.videoImgView.image = UIImage(named: "placeholderImage", in: Bundle.module, with: nil)
            } else {
                let thumbnailUrl = "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg"
                if let url = URL(string: thumbnailUrl) {
                    self.videoImgView.sd_setImage(with: url,
                                                  placeholderImage: UIImage(named: "placeholderImage",
                                                                            in: Bundle.module, with: nil))
                }
            }
        } else {
            if !isGenAINewTheme {
                self.playImgView.image = UIImage(systemName: "play.circle.fill")
            } else {
                self.playImgView.image = UIImage(named: "playIcon-NT", in: Bundle.module, with: nil)
            }
            self.generateThumbnail(url: URL(string: videoUrl)!) { thumbImage in
                DispatchQueue.main.async {
                    self.videoImgView.image = thumbImage
                }
            }
        }
    }

    func generateThumbnail(url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 0.0, preferredTimescale: 600)
            let times = [NSValue(time: time)]
            imageGenerator.generateCGImagesAsynchronously(forTimes: times, completionHandler: { _, image, _, _, _ in
                if let image = image {
                    completion(UIImage(cgImage: image))
                } else {
                    let thumbImage = UIImage(named: "placeholderImage", in: Bundle.module, with: nil)!
                    completion(thumbImage)
                }
            })
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
            self.botImgView.image = UIImage(named: "botIcon", 
                                            in: Bundle.module,
                                            with: nil)?.withRenderingMode(.alwaysTemplate)
            self.botImgView.tintColor = VAColorUtility.senderBubbleColor
        }
    }
}
