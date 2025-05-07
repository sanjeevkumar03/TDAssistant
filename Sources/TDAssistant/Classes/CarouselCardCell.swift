// CarouselCardCell.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit
import SDWebImage

// MARK: Protocol definition
protocol CarouselCardCellDelegate: AnyObject {
    func didScrollCollectionImage(imageIndex: Int, cardIndexPath: IndexPath)
    func didTapOnCollectionImage(imageIndex: Int, images: [String])
    func didTapOnCarouselOption(option: Option, context: [Dictionary<String, Any>], cardIndexPath: IndexPath, carouselPageIndex: Int, selectedButtonIndex: Int) -> Bool
}

class CarouselCardCell: UITableViewCell {

    // MARK: Outlet Declaration
    @IBOutlet weak var avatarViewWidth: NSLayoutConstraint!
    @IBOutlet weak var botImgView: UIImageView!
    @IBOutlet weak var botImgBGView: UIView!
    @IBOutlet weak var chatBubbleImgView: UIImageView!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageCollectionContainer: UIView!
    @IBOutlet weak var imageCollection: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var optionsTable: UITableView!
    @IBOutlet weak var optionsTableHeight: NSLayoutConstraint!
    @IBOutlet weak var imageContainerHeight: NSLayoutConstraint!

    // MARK: Property Declaration
    static let nibName = "CarouselCardCell"
    static let identifier = "CarouselCardCell"
    static let nibName_NT = "CarouselCardCell-NT"
    static let identifier_NT = "CarouselCardCell-NT"
    var carouselArray: [CarousalObject] = []
    var context: [Dictionary<String, Any>] = []
    var carouselButtons: [Option] = []
    var carouselCardIndexPath: IndexPath?
    var selectedImageIndex: Int = 0
    lazy var leftSwipeGestureRecognizer: UISwipeGestureRecognizer = {
        let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        gestureRecognizer.direction = .left
        return gestureRecognizer
    }()
    lazy var rightSwipeGestureRecognizer: UISwipeGestureRecognizer = {
        let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        gestureRecognizer.direction = .right
        return gestureRecognizer
    }()
    weak var delegate: CarouselCardCellDelegate?
    var configurationModal: VAConfigurationModel?
    var isShowBotImage: Bool = true
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var isGenAINewTheme: Bool = false
    var collectionHeight_NT: CGFloat = 0
    
    // MARK: Cell lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.addGestureRecognizer(leftSwipeGestureRecognizer)
        self.contentView.addGestureRecognizer(rightSwipeGestureRecognizer)
        self.layoutIfNeeded()
        self.pageControl.tintColor = .lightGray
        self.pageControl.pageIndicatorTintColor = .lightGray
        self.configureCollectionView()
        self.configureTableView()
        self.imageCollection.isScrollEnabled = false
        collectionHeight_NT = (self.bounds.width/2) + 10
    }
    // MARK: UISwipeGestureRecognizer method
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            if selectedImageIndex < self.carouselArray.count - 1 {
                self.selectedImageIndex = self.pageControl.currentPage + 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    if self.carouselArray[self.selectedImageIndex].image != "" {
                        if self.isGenAINewTheme {
                            self.imageContainerHeight.constant = self.collectionHeight_NT
                        } else {
                            self.imageContainerHeight.constant = self.containerViewWidth.constant / 2
                        }
                    } else {
                        self.imageContainerHeight.constant = 0
                    }
                    self.imageCollection.scrollToItem(at: IndexPath(item: self.selectedImageIndex, section: 0), at: .left, animated: false)
                    self.reloadViews()
                }
            }
        case .right:
            if selectedImageIndex > 0 {
                self.selectedImageIndex = self.pageControl.currentPage - 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    if self.carouselArray[self.selectedImageIndex].image != "" {
                        if self.isGenAINewTheme {
                            self.imageContainerHeight.constant = self.collectionHeight_NT
                        } else {
                            self.imageContainerHeight.constant = self.containerViewWidth.constant / 2
                        }
                    } else {
                        self.imageContainerHeight.constant = 0
                    }
                    self.imageCollection.scrollToItem(at: IndexPath(item: self.selectedImageIndex, section: 0), at: .right, animated: false)
                    self.reloadViews()
                }
            }
        default:
            break
        }
    }

    // MARK: Custom methods
    func setCardUI() {
        if !isGenAINewTheme {
            self.pageControl.currentPageIndicatorTintColor = VAColorUtility.defaultButtonColor
            containerViewWidth.constant = ChatBubble.getChatBubbleWidth()
            self.imageContainerHeight.constant = containerViewWidth.constant/2

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
            chatBubbleImgView.tintColor = VAColorUtility.carouselColor

        } else {
            self.pageControl.currentPageIndicatorTintColor = VAColorUtility.green_NT
            self.imageContainerHeight.constant = self.collectionHeight_NT
        }
        self.titleLabel.text = ""
        self.titleLabel.textColor = VAColorUtility.carouselTextIconColor

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
    func configure() {
        self.setCardUI()
        if self.carouselArray[self.selectedImageIndex].image != "" {
            if self.isGenAINewTheme {
                self.imageContainerHeight.constant = self.collectionHeight_NT
            } else {
                self.imageContainerHeight.constant = self.containerViewWidth.constant/2
            }
        } else {
            self.imageContainerHeight.constant = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.imageCollection.reloadData()
        })
        self.configurePageControl()
        if selectedImageIndex != 0 {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
                self.imageCollection.isPagingEnabled = false
                self.imageCollection.scrollToItem(at: IndexPath(item: self.selectedImageIndex, section: 0), at: .left, animated: false)
                self.imageCollection.isPagingEnabled = true
            }
        }
    }
    func configurePageControl() {
        pageControl.numberOfPages = carouselArray.count
        if carouselArray.count <= 1 {
            self.pageControl.isHidden = true
        } else {
            self.pageControl.isHidden = false
        }
        pageControl.currentPage = selectedImageIndex
        self.setCarouselTitle()
        self.reloadOptionsTable()
    }
    func configureCollectionView() {
        self.imageCollection.register(UINib(nibName: CarouselImageCell.nibName, bundle: Bundle.module), forCellWithReuseIdentifier: CarouselImageCell.identifier)
        if let layout = imageCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        self.imageCollection.delegate = self
        self.imageCollection.dataSource = self
    }
    func configureTableView() {
        optionsTable.tableFooterView = UIView()
        optionsTable.rowHeight = UITableView.automaticDimension
        optionsTable.estimatedRowHeight = 52

        optionsTable.register(UINib(nibName: CarouselOptionCell.nibName, bundle: Bundle.module), forCellReuseIdentifier: CarouselOptionCell.identifier)
        optionsTable.delegate = self
        optionsTable.dataSource = self
        optionsTable.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
    }
    func reloadViews() {
        self.pageControl.currentPage = self.selectedImageIndex
        self.setCarouselTitle()
        self.reloadOptionsTable()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
            self.delegate?.didScrollCollectionImage(imageIndex: self.selectedImageIndex, cardIndexPath: self.carouselCardIndexPath!)
        }
    }
    func setCarouselTitle() {
        if carouselArray[selectedImageIndex].text == "" {
            self.titleLabel.text = ""
            self.titleLabel.isHidden = true
        } else {
            let attributedText = carouselArray[selectedImageIndex].attributedTitle
            if isGenAINewTheme {
                attributedText?.addAttribute(.font, value: GenAIFonts().normal()!, range: NSRange(location: 0, length: attributedText!.length))
            } else {
                attributedText?.addAttribute(.font, value: UIFont(name: fontName, size: textFontSize)!, range: NSRange(location: 0, length: attributedText!.length))
            }
            self.titleLabel.attributedText = attributedText
            self.titleLabel.textAlignment = .center
            self.titleLabel.textColor = VAColorUtility.carouselTextIconColor
            self.titleLabel.isHidden = false
        }
    }
    func reloadOptionsTable() {
        self.carouselButtons = carouselArray[selectedImageIndex].options
        self.optionsTable.reloadData()
        if self.carouselButtons.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.optionsTableHeight.constant = CGFloat(52 * self.carouselButtons.count) //self.optionsTable.contentSize.height + 20
            }
            self.optionsTable.isHidden = false
        } else {
            self.optionsTableHeight.constant = 0
            self.optionsTable.isHidden = true
        }
    }
}

// MARK: UICollectionViewDelegate & UICollectionViewDataSource
extension CarouselCardCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return carouselArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselImageCell.identifier, for: indexPath) as? CarouselImageCell {
            cell.configure(imageURL: self.carouselArray[indexPath.item].image)
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let images: [String] = carouselArray.compactMap({$0.image})
        delegate?.didTapOnCollectionImage(imageIndex: indexPath.item, images: images)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.isGenAINewTheme {
            return CGSize(width: collectionView.bounds.width, height: self.collectionHeight_NT)
        } else {
            return CGSize(width: collectionView.bounds.width, height: containerViewWidth.constant/2)
        }
    }

    func sizeOfImageAt(url: URL) -> CGSize? {
        // with CGImageSource we avoid loading the whole image into memory
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }

        let propertiesOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, propertiesOptions) as? [CFString: Any] else {
            return nil
        }

        if let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
           let height = properties[kCGImagePropertyPixelHeight] as? CGFloat {
            return CGSize(width: width, height: height)
        } else {
            return nil
        }
    }
}

// MARK: Scroll View Delegate
extension CarouselCardCell: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        self.selectedImageIndex = pageIndex
        self.reloadViews()
    }
}

// MARK: UITableViewDelegate & UITableViewDataSource

extension CarouselCardCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carouselButtons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: CarouselOptionCell.identifier, for: indexPath) as? CarouselOptionCell {
            cell.titleLabel.attributedText = carouselButtons[indexPath.row].attributedTitle
            cell.titleLabel.textAlignment = .center
            cell.titleLabel.font = UIFont(name: fontName, size: textFontSize)
            //cell.quickReplyButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
            cell.isButtonClicked = carouselButtons[indexPath.row].isButtonClicked
            cell.configureCardUI(isGenAINewTheme: isGenAINewTheme)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let isClickAllowed = delegate?.didTapOnCarouselOption(option: carouselButtons[indexPath.row], 
                                         context: self.context,
                                         cardIndexPath: carouselCardIndexPath!,
                                         carouselPageIndex: selectedImageIndex,
                                         selectedButtonIndex: indexPath.row)
        if isClickAllowed ?? true {
            if carouselButtons[indexPath.row].type != "url" {
                self.optionsTable.isUserInteractionEnabled = false
            }
            if let cell = tableView.cellForRow(at: indexPath) as? CarouselOptionCell {
                cell.isButtonClicked = true
                cell.configureCardUI(isGenAINewTheme: isGenAINewTheme)
            }
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        optionsTable.layer.removeAllAnimations()
        optionsTableHeight.constant = CGFloat(52 * self.carouselButtons.count)//optionsTable.contentSize.height + 20
        self.layoutIfNeeded()
    }
}

func getAttributedTextFromHTML(text: String) -> NSMutableAttributedString? {
    var completeText: String = text
    var completeAttributedText: NSMutableAttributedString?

    let parsedHtml = parseIFrameTag(htmlText: completeText)

    completeText = parsedHtml
    completeAttributedText = nil

    completeText = completeText.replacingOccurrences(of: "</p><p><br>", with: "")
    completeText = completeText.replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">").replacingOccurrences(of: "/a&gt", with: "/a>")
    if !completeText.contains("‎")/*checking for empty character*/ {
        completeText = completeText.replacingOccurrences(of: "<ol><li>", with: "‎‎<br><ol><li>").replacingOccurrences(of: "<ul><li>", with: "‎‎<br><ul><li>")
    }
    completeText = "<span style=\"font-family: Helvetica; font-size: 16px\">\(completeText)</span>"
    if let attributedText = completeText.htmlToAttributedString as? NSMutableAttributedString {
        completeAttributedText = attributedText
        completeAttributedText?.addAttribute(NSAttributedString.Key.foregroundColor, 
                                             value: VAColorUtility.receiverBubbleTextIconColor,
                                             range: NSRange(location: 0, length: completeAttributedText!.length))
        return completeAttributedText
    }
    return nil
}
