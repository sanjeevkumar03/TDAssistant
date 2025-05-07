// ChoiceCardCell.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit
import SDWebImage

// MARK: Protocol definition
protocol ChoiceCardCellDelegate: AnyObject {
    func didTapConfirmButton(response: [Choice], indexPath: IndexPath)
    func didTapMoreOptionsButton(response: [Choice], indexPath: IndexPath, isMultiSelect: Bool )
    func didTapSkipButton(indexPath: IndexPath)
}

class ChoiceCardCell: UITableViewCell {

    // MARK: Outlet declaration
    @IBOutlet weak var avatarViewWidth: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seperatorTitleView: UIView!
    @IBOutlet weak var seperatorConfirmView: UIView!
    @IBOutlet weak var botImgBGView: UIView!
    @IBOutlet weak var botImgView: UIImageView!
    @IBOutlet weak var chatBubbleImgView: UIImageView!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var choiceStackBottom: NSLayoutConstraint!
    @IBOutlet weak var skipTitleLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var skipView: UIView!
    @IBOutlet weak var optionsTable: UITableView! {
        didSet {
            self.optionsTable.delegate = self
            self.optionsTable.dataSource = self
        }
    }
    @IBOutlet weak var optionsTableHeight: NSLayoutConstraint!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var moreOptionsView: UIView!
    @IBOutlet weak var moreOptionsButton: UIButton!
    @IBOutlet weak var moreOptionsLabel: UILabel!
    @IBOutlet weak var moreOptionsDropdownImageView: UIImageView!
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var skipButtonViewHeight: NSLayoutConstraint!
    @IBOutlet weak var skipButtonViewTop: NSLayoutConstraint!
    @IBOutlet weak var skipButtonViewBottom: NSLayoutConstraint!

    // MARK: Property declaration
    static let nibName = "ChoiceCardCell"
    static let identifier = "ChoiceCardCell"
    static let nibName_NT = "ChoiceCardCell-NT"
    static let identifier_NT = "ChoiceCardCell-NT"
    var arrayOfOptions: [Choice] = []
    var isMultiSelect: Bool = false
    var indexPath: IndexPath?
    weak var delegate: ChoiceCardCellDelegate?
    var configurationModal: VAConfigurationModel?
    var isShowBotImage: Bool = true
    var optionsToShow: Int = 3
    var optionsLimit: Int = 0
    var allowSkipButton: Bool = false
    var isMultiOpsTapped: Bool = false
    let confirmStaticText = LanguageManager.shared.localizedString(forKey: "Confirm")
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var optionsRowHeight: CGFloat = 44.0
    var isGenAINewTheme: Bool = false
    var isOptionTableExpanded: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        self.confirmView.isHidden = true
        self.moreOptionsView.isHidden = true
        self.skipButton.setTitle("", for: .normal)
        self.optionsTable.addObserver(self, forKeyPath: "contentSize", options: [], context: nil)
    }
    
    // MARK: Observer

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // print("Table Height: \(self.optionsTable.contentSize.height)")
        // self.optionsTableHeight.constant = self.optionsTable.contentSize.height
    }

    // MARK: Custom methods

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

    /// Used to configure image card
    /// - Parameter imageURL: It accepts image url string.
    func configure(model: MultiOps?, isMultiSelect: Bool, indexPath: IndexPath, isMultiOpsTapped: Bool, allowSkip: Bool) {
        self.optionsToShow = (model?.optionsLimit == nil || model?.optionsLimit == 0) ? 3 : model?.optionsLimit ?? 3
        self.optionsLimit = self.optionsToShow
        self.isMultiOpsTapped = isMultiOpsTapped
        self.allowSkipButton = allowSkip
        self.optionsRowHeight = isGenAINewTheme ? 34 : 44
        if model?.options.count ?? 0 > 0, self.allowSkipButton == true {
            self.skipButtonViewHeight.constant = 40
            self.skipButton.isHidden = false
            self.skipTitleLabel.isHidden = false

            let skipBtnAttributedStr: NSMutableAttributedString = model?.options[0].attributedTitle ??  NSMutableAttributedString(string: "")
            if !isGenAINewTheme {
                skipBtnAttributedStr.addAttribute(.font, value: UIFont(name: fontName, size: textFontSize)!, range: NSRange(location: 0, length: skipBtnAttributedStr.length))
                self.skipTitleLabel.textColor = VAColorUtility.buttonColor
                self.skipView.layer.cornerRadius = 8
                self.skipView.layer.borderWidth = 1
                self.skipView.layer.borderColor = VAColorUtility.buttonColor.cgColor
                self.skipTitleLabel.attributedText = skipBtnAttributedStr
                self.skipTitleLabel.textColor = VAColorUtility.green_NT
            } else {
                skipBtnAttributedStr.addAttribute(.font, value: GenAIFonts().bold()!, range: NSRange(location: 0, length: skipBtnAttributedStr.length))
                self.skipTitleLabel.attributedText = skipBtnAttributedStr
                self.skipTitleLabel.textColor = VAColorUtility.green_NT
                
            }
            self.skipTitleLabel.textAlignment = .center
            self.skipButtonViewTop.constant = 10
            self.skipButtonViewBottom.constant = 5
        } else {
            self.skipButtonViewHeight.constant = 0
            self.skipButton.isHidden = true
            self.skipTitleLabel.isHidden = true
            self.skipButtonViewTop.constant = 0
            self.skipButtonViewBottom.constant = 0
        }
        
        self.indexPath = indexPath
        self.isMultiSelect = isMultiSelect

        let attributedStr: NSMutableAttributedString = model?.attributedTitle ??  NSMutableAttributedString(string: "")
        if !isGenAINewTheme {
            attributedStr.addAttribute(.font, value: UIFont(name: fontName, size: textFontSize)!, range: NSRange(location: 0, length: attributedStr.length))
            self.titleLabel.textColor = VAColorUtility.receiverBubbleTextIconColor
        } else {
            attributedStr.addAttribute(.font, value: GenAIFonts().bold()!, range: NSRange(location: 0, length: attributedStr.length))
            self.titleLabel.textColor = VAColorUtility.greyCharcoal_NT
        }
        self.titleLabel.attributedText = attributedStr
        
        if !isGenAINewTheme {
            self.setCardUI()
            self.containerViewWidth.constant = UIDevice.current.userInterfaceIdiom == .phone ? (UIScreen.main.bounds.width*0.7) : (UIScreen.main.bounds.width*0.4)
            self.moreOptionsView.backgroundColor = VAColorUtility.receiverBubbleColor
            self.titleView.backgroundColor = VAColorUtility.receiverBubbleColor
            self.titleLabel.textColor = VAColorUtility.receiverBubbleTextIconColor
            self.confirmButton.setTitleColor(VAColorUtility.defaultThemeTextIconColor, for: .normal)
            self.moreOptionsButton.setTitleColor(VAColorUtility.receiverBubbleTextIconColor, for: .normal)
            self.seperatorTitleView.backgroundColor = VAColorUtility.defaultThemeTextIconColor
            self.seperatorConfirmView.backgroundColor = VAColorUtility.defaultThemeTextIconColor

            self.confirmButton.layer.cornerRadius = 4
            self.confirmButton.backgroundColor = VAColorUtility.receiverBubbleColor
            self.confirmView.backgroundColor = VAColorUtility.defaultThemeTextIconColor
        }
        
        /*if isHTMLText(completeText: model?.text ?? ""){
         let completeAttributedText = getAttributedTextFromHTML(text: model?.text ?? "")
         self.titleLabel.attributedText = completeAttributedText
         }else{
         self.titleLabel.text = model?.text ?? ""
         }*/
        self.arrayOfOptions = model?.choices ?? []
        self.optionsTable.register(UINib(nibName: isGenAINewTheme ? ChoiceCardOptionCell.nibName_NT : ChoiceCardOptionCell.nibName, bundle: Bundle.module), forCellReuseIdentifier: isGenAINewTheme ? ChoiceCardOptionCell.identifier_NT : ChoiceCardOptionCell.identifier)
        
        self.updateMoreOptionsView()

        if isMultiOpsTapped {
            UIView.performWithoutAnimation {
                self.optionsTableHeight.constant = 0
                self.confirmView.isHidden = true
                self.moreOptionsView.isHidden = true
                if !isGenAINewTheme {
                    self.seperatorTitleView.isHidden = true
                } else {
                    self.choiceStackBottom.constant = 2
                }
            }
            self.arrayOfOptions = []
        } else {
            if !isGenAINewTheme {
                self.seperatorTitleView.isHidden = false
            }
            if self.arrayOfOptions.count > self.optionsToShow {
                self.confirmView.isHidden = !self.isMultiSelect
                self.moreOptionsView.isHidden = false
                self.updateConfirmButton()
                if isGenAINewTheme {
                    self.choiceStackBottom.constant = isMultiSelect ? 10 : 5
                }
            } else if self.arrayOfOptions.count > 0 && self.arrayOfOptions.count <= self.optionsToShow {
                self.moreOptionsView.isHidden = true
                self.confirmView.isHidden = !self.isMultiSelect
                self.updateConfirmButton()
                if isGenAINewTheme {
                    self.choiceStackBottom.constant = 10
                }
            } else {
                self.confirmView.isHidden = true
                self.moreOptionsView.isHidden = true
            }
        }
        if !isGenAINewTheme {
            if isMultiOpsTapped {
                self.chatBubbleImgView.tintColor = VAColorUtility.receiverBubbleColor
                self.titleView.backgroundColor = VAColorUtility.clear
            } else {
                self.chatBubbleImgView.tintColor = VAColorUtility.receiverBubbleColor
                self.titleView.backgroundColor = VAColorUtility.receiverBubbleColor
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
            self.optionsTable.reloadData()
        }
        self.stackView.layer.cornerRadius = 4
        self.setOptionsTableHeight()
    }
    private func setOptionsTableHeight() {
        if self.isMultiOpsTapped {
            self.optionsTableHeight.constant = 0
        } else {
            if isGenAINewTheme && isOptionTableExpanded {
                self.optionsTable.isScrollEnabled = true
                DispatchQueue.main.asyncAfter(deadline: .now()+0.25, execute: {
                    self.optionsTable.flashScrollIndicators()
                })
            } else {
                self.optionsTable.isScrollEnabled = false
            }
            if self.arrayOfOptions.count > self.optionsLimit {
                self.optionsTableHeight.constant = CGFloat(self.optionsLimit * Int(optionsRowHeight))
            } else {
                self.optionsTableHeight.constant = CGFloat(self.arrayOfOptions.count * Int(optionsRowHeight))
            }
        }
    }
    private func getArraySelectedItem() -> [Choice] {
        if self.arrayOfOptions.count > 0 {
            let filterArray = self.arrayOfOptions.filter { obj in
                if obj.isSelected == true {
                    return true
                } else {
                    return false
                }
            }
            return filterArray
        } else {
            return []
        }
    }
    private func updateMoreOptionsView() {
        DispatchQueue.main.async { [self] in
            if !isGenAINewTheme {
                self.moreOptionsButton.setTitle(LanguageManager.shared.localizedString(forKey: "More Options"), for: .normal)
                self.moreOptionsButton.titleLabel?.font = UIFont(name: self.fontName, size: self.textFontSize)
                self.skipButton.titleLabel?.font = UIFont(name: self.fontName, size: self.textFontSize)
            } else {
                let moreOptionsCount = self.arrayOfOptions.count - self.optionsToShow
                if moreOptionsCount > 0 {
                    self.moreOptionsView.isHidden = false
                    self.moreOptionsLabel.text = "\(moreOptionsCount) \(LanguageManager.shared.localizedString(forKey: "more"))"
                } else {
                    self.moreOptionsView.isHidden = true
                }
            }
        }
    }
    private func updateConfirmButton() {
        let filterArray = self.getArraySelectedItem()
        if isGenAINewTheme {
            self.confirmButton.titleLabel?.font = GenAIFonts().bold()
        } else {
            self.confirmButton.titleLabel?.font = UIFont(name: fontName, size: textFontSize)
        }
        if filterArray.count > 0 {
            if !isGenAINewTheme {
                self.confirmButton.setTitleColor(VAColorUtility.receiverBubbleTextIconColor, for: .normal)
            } else {
                self.confirmView.borderColor = VAColorUtility.green_NT
                self.confirmView.layer.borderWidth = 1
                self.confirmView.backgroundColor = VAColorUtility.white
                self.confirmButton.setTitleColor(VAColorUtility.green_NT, for: .normal)
            }
            self.confirmButton.setTitle("\(self.confirmStaticText) (\(filterArray.count))", for: .normal)
        } else {
            if !isGenAINewTheme {
                self.confirmButton.setTitleColor(VAColorUtility.defaultThemeTextIconColor, for: .normal)
            } else {
                self.confirmView.borderColor = .clear
                self.confirmView.layer.borderWidth = 0
                self.confirmView.backgroundColor = VAColorUtility.borderColor_NT
                self.confirmButton.setTitleColor(VAColorUtility.white, for: .normal)
            }
            self.confirmButton.setTitle("\(self.confirmStaticText) (0)", for: .normal)
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

    @IBAction func confirmTapped(_ sender: UIButton) {
        let filterArray = self.getArraySelectedItem()
        if filterArray.count > 0 {
            self.delegate?.didTapConfirmButton(response: self.arrayOfOptions, indexPath: self.indexPath!)
        } else {}
    }
    @IBAction func moreOptionsTapped(_ sender: UIButton) {
        if isGenAINewTheme {
            self.isOptionTableExpanded = !self.isOptionTableExpanded
            let moreOptionsCount = self.arrayOfOptions.count - self.optionsLimit
            self.moreOptionsLabel.text = self.isOptionTableExpanded ?
            LanguageManager.shared.localizedString(forKey: "Less"):
            "\(moreOptionsCount) \(LanguageManager.shared.localizedString(forKey: "more"))"
            self.moreOptionsDropdownImageView.image = self.isOptionTableExpanded ?
            UIImage(named: "collapse-icon", in: Bundle.module, compatibleWith: nil) :
            UIImage(named: "minimize", in: Bundle.module, compatibleWith: nil)
            self.moreOptionsDropdownImageView.tintColor = VAColorUtility.green_NT
            self.optionsToShow = self.isOptionTableExpanded ? self.arrayOfOptions.count : self.optionsLimit
            self.setOptionsTableHeight()
        } else {
            self.delegate?.didTapMoreOptionsButton(response: self.arrayOfOptions, indexPath: self.indexPath!, isMultiSelect: self.isMultiSelect)
        }
    }
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapSkipButton(indexPath: self.indexPath!)
    }
}

// MARK: UITableViewDelegate & UITableViewDataSource

extension ChoiceCardCell: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isMultiOpsTapped {
            return 0
        } else {
            if self.arrayOfOptions.count > self.optionsToShow {
                return self.optionsToShow
            } else {
                return self.arrayOfOptions.count
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: (isGenAINewTheme ? ChoiceCardOptionCell.identifier_NT : ChoiceCardOptionCell.identifier), for: indexPath) as? ChoiceCardOptionCell {
            cell.configure(title: self.arrayOfOptions[indexPath.row].label, isMultiSelect: self.isMultiSelect, isSelect: self.arrayOfOptions[indexPath.row].isSelected, isNewGenAITheme: isGenAINewTheme)
            cell.checkboxButton.tag = indexPath.row
            cell.checkboxButton.addTarget(self, action: #selector(checkboxTapped(sender:)), for: .touchUpInside)
            if !isGenAINewTheme {
                cell.titleLabel.font = UIFont(name: fontName, size: textFontSize-1.5)
                if self.arrayOfOptions.count > optionsToShow - 1 {
                    cell.seperatorView.isHidden = false
                } else {
                    cell.seperatorView.isHidden = false
                }
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.updateChoiceArrayOnSelection(index: indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return optionsRowHeight
    }

    @objc func checkboxTapped(sender: UIButton) {
        self.updateChoiceArrayOnSelection(index: sender.tag)
    }

    private func updateChoiceArrayOnSelection(index: Int) {
        var choice: Choice = self.arrayOfOptions[index]
        if choice.isSelected {
            choice.isSelected = false
        } else {
            choice.isSelected = true
        }
        self.arrayOfOptions[index] = choice
        if self.isMultiSelect {
            self.updateConfirmButton()
        } else {
            self.delegate?.didTapConfirmButton(response: self.arrayOfOptions, indexPath: self.indexPath!)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
            self.optionsTable.reloadData()
        }
    }
}
