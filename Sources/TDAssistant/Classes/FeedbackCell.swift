//  FeedbackCell.swift
//  TIVirtualAssistant
//  Created by Sanjeev Kumar on 07/02/25.
//  Copyright © 2025 Telus International. All rights reserved.

import UIKit
import ProgressHUD
import IQKeyboardManagerSwift

// MARK: Protocol definition
protocol FeedbackCellDelegate: AnyObject {
    func didTapOnFeedbackViewOptions(indexPath: IndexPath)
    func didTapOnSendFeedbackMsg(feedbackText: String, indexPath: IndexPath)
    func didTapThumbsUpFeedbackGenAI(indexPath: IndexPath)
    func didTapThumbsDownFeedbackGenAI(indexPath: IndexPath)
}


class FeedbackCell: UITableViewCell {

    @IBOutlet weak var thumbsUpImgView: UIImageView!
    @IBOutlet weak var thumbsDownImgView: UIImageView!
    @IBOutlet weak var feedbackThanksView: UIView!
    @IBOutlet weak var thankYouLabel: UILabel!
    @IBOutlet weak var rateFeedbackView: UIView!
    @IBOutlet weak var describeYourExpLabel: UILabel!
    @IBOutlet weak var rateExpDropDownImgView: UIImageView!
    @IBOutlet weak var feedbackDetailView: UIView!
    @IBOutlet weak var ratingOptionsView: UIView!
    @IBOutlet weak var ratingOptionsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var sendFeedbackBGView: UIView!
    @IBOutlet weak var sendFeedbackImgView: UIImageView!
    @IBOutlet weak var sendFeedbackMsgButton: UIButton!
    @IBOutlet weak var thumbsUpButton: UIButton!
    @IBOutlet weak var thumbsDownButton: UIButton!
    @IBOutlet weak var feedbackTextView: UITextView!{
        didSet {
            self.feedbackTextView.delegate = self
            self.feedbackTextView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            self.feedbackTextView.textContainer.lineFragmentPadding = 0
            self.feedbackTextView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    static let identifier = "FeedbackCell"
    static let nibName = "FeedbackCell"
    var isFeedbackInputViewExpanded: Bool = false
    var feedbackTextProgress: ProgressBarView?
    var configurationModal: VAConfigurationModel?
    weak var delegate: FeedbackCellDelegate?
    var feedbackPlaceholder: String = ""
    var feedbackMaxCharCount = 0
    var indexPath: IndexPath?
    var feedbackOptions: [GenAIFeedbackOptions] = []
    var selectedFeedbackOption = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setFeedbackTextProgress()
        self.closeAllViewsOfFeedback()
        self.thankYouLabel.text = LanguageManager.shared.localizedString(forKey: "Thank you for your valuable feedback.")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: Button actions
    @IBAction func thumbsUpTapped(_ sender: Any) {
        self.setThumbsUpSelectedImage()
        self.handleUserClick(isThumbsUp: true)
        if let indexPath = indexPath {
            self.delegate?.didTapThumbsUpFeedbackGenAI(indexPath: indexPath)
        }
    }
    
    @IBAction func thumbsDownTapped(_ sender: Any) {
        self.setThumbsDownSelectedImage()
        self.handleUserClick(isThumbsUp: false)
        if let indexPath = indexPath {
            self.delegate?.didTapThumbsDownFeedbackGenAI(indexPath: indexPath)
        }
    }
    
    @IBAction func expandCollapseRatingExpViewTapped(_ sender: Any) {
        if self.isFeedbackInputViewExpanded {
            self.closeFeedbackDetailsView()
            self.rateExpDropDownImgView.image = UIImage(named: "downArrow-NT", in: Bundle.module, with: nil)
        } else {
            
            self.openFeedbackDetailsView()
            self.rateExpDropDownImgView.image = UIImage(named: "upArrow-NT", in: Bundle.module, with: nil)
        }
        self.isFeedbackInputViewExpanded.toggle()
    }
    
    @IBAction func sendFeedbackTapped(_ sender: Any) {
        self.feedbackTextView.resignFirstResponder()
        var completeText = self.feedbackTextView.text == feedbackPlaceholder ? "" : self.feedbackTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !self.selectedFeedbackOption.isEmpty {
            completeText = completeText.isEmpty ? self.selectedFeedbackOption : (self.selectedFeedbackOption + ": " + completeText)
        }
        self.openThanksForYourFeedbackView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.closeAllViewsOfFeedback()
        }
        self.resetFeedbackCircularProgress()
        if let indexPath = indexPath {
            self.delegate?.didTapOnSendFeedbackMsg(feedbackText: completeText, indexPath: indexPath)
        }
    }
    
    //MARK: Custom methods
    func configureFeedbackCell(isThumbsUpFeedback: Bool, isTextFeedbackProvided: Bool) {
        isThumbsUpFeedback ? self.setThumbsUpSelectedImage() : self.setThumbsDownSelectedImage()
        if !isTextFeedbackProvided {
            self.handleUserClick(isThumbsUp: isThumbsUpFeedback, isHistoryMsg: true)
        }
    }
    
    func setThumbsUpSelectedImage() {
        self.thumbsDownImgView.alpha = 0.5
        self.thumbsUpImgView.image = UIImage(named: "thumbsUpSelected-NT", in: Bundle.module, with: nil)
        self.disableButtonIntractions()
    }
    func setThumbsDownSelectedImage() {
        self.thumbsUpImgView.alpha = 0.5
        self.thumbsDownImgView.image = UIImage(named: "thumbsDownSelected-NT", in: Bundle.module, with: nil)
        self.disableButtonIntractions()
    }
    func disableButtonIntractions() {
        self.thumbsUpButton.isUserInteractionEnabled = false
        self.thumbsDownButton.isUserInteractionEnabled = false
    }
    func handleUserClick(isThumbsUp: Bool, isHistoryMsg: Bool = false) {
        if self.configurationModal?.result?.genAITextFeedback ?? false {
            var hasValues: Bool = false
            if isThumbsUp {
                if let filtered = self.configurationModal?.result?.genAISettings?.genAIFeedback?.filter({$0.type == "up"}) {
                    hasValues = !filtered.isEmpty
                    if hasValues {
                        self.describeYourExpLabel.text = filtered.first?.title ?? ""
                        self.feedbackOptions = filtered.first?.options ?? []
                    }
                }
            } else {
                if let filtered = self.configurationModal?.result?.genAISettings?.genAIFeedback?.filter({$0.type == "down"}) {
                    hasValues = !filtered.isEmpty
                    if hasValues {
                        self.describeYourExpLabel.text = filtered.first?.title ?? ""
                        self.feedbackOptions = filtered.first?.options ?? []
                    }
                }
            }
            if hasValues {
                self.openRateYourExperienceView(isHistoryMsg: isHistoryMsg)
            }
        }
    }
    func openRateYourExperienceView(isHistoryMsg: Bool = false) {
        self.feedbackThanksView.isHidden = true
        self.rateFeedbackView.isHidden = false
        self.feedbackDetailView.isHidden = true
        if isHistoryMsg {
            return
        }
        if let indexPath = indexPath {
            self.delegate?.didTapOnFeedbackViewOptions(indexPath: indexPath)
        }
    }
    func openFeedbackDetailsView() {
        if feedbackTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.resetFeedbackTextView()
        }
        IQKeyboardManager.shared.enable = true
        self.feedbackThanksView.isHidden = true
        self.rateFeedbackView.isHidden = false
        self.feedbackDetailView.isHidden = false
        self.setupRatingOptionsView()
        if let indexPath = indexPath {
            self.delegate?.didTapOnFeedbackViewOptions(indexPath: indexPath)
        }
    }
    func closeFeedbackDetailsView() {
        IQKeyboardManager.shared.enable = false
        self.feedbackDetailView.isHidden = true
        if let indexPath = indexPath {
            self.delegate?.didTapOnFeedbackViewOptions(indexPath: indexPath)
        }
    }
    func openThanksForYourFeedbackView() {
        self.feedbackThanksView.isHidden = false
        self.rateFeedbackView.isHidden = true
        self.feedbackDetailView.isHidden = true
        if let indexPath = indexPath {
            self.delegate?.didTapOnFeedbackViewOptions(indexPath: indexPath)
        }
    }
    func closeAllViewsOfFeedback() {
        self.feedbackThanksView.isHidden = true
        self.rateFeedbackView.isHidden = true
        self.feedbackDetailView.isHidden = true
        if let indexPath = indexPath {
            self.delegate?.didTapOnFeedbackViewOptions(indexPath: indexPath)
        }
    }
    func resetFeedbackTextView() {
        feedbackTextView.text = feedbackPlaceholder
        feedbackTextView.textColor = UIColor.lightGray
    }
    // MARK: - Set Circular Progress
    func setFeedbackTextProgress() {
        self.feedbackTextProgress = ProgressBarView(frame: self.sendFeedbackMsgButton.bounds)
        self.feedbackTextProgress!.trackLyrLineWidth = 2.0
        self.feedbackTextProgress!.trackClr = VAColorUtility.defaultThemeTextIconColor
        self.feedbackTextProgress!.progressClr = VAColorUtility.defaultSenderBubbleColor
        self.feedbackTextProgress!.isUserInteractionEnabled = false
        self.feedbackTextProgress!.backgroundColor = .clear
        self.sendFeedbackMsgButton.addSubview(self.feedbackTextProgress!)
        self.resetFeedbackCircularProgress()
    }
    func resetFeedbackCircularProgress() {
        self.feedbackTextProgress?.progress = 0
        self.selectedFeedbackOption = ""
        self.resetFeedbackTextView()
        self.updateSendFeedbackButton()
    }
    func setupRatingOptionsView() {
        for view in ratingOptionsView.subviews {
            view.removeFromSuperview()
        }
        let containerWidth = UIScreen.main.bounds.width - 65
        let textMaxWidth: CGFloat = containerWidth/2
        var xAxis: CGFloat = 0
        var yAxis: CGFloat = 0
        let citationHeight: CGFloat = 30
        
        for (index, feedbackOption) in feedbackOptions.enumerated() {
            let text = feedbackOption.label ?? ""
            var viewWidth: CGFloat = 0
            let citationView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: citationHeight))
            citationView.layer.cornerRadius = 4
            citationView.layer.borderWidth = 1
            citationView.clipsToBounds = true
            citationView.tag = 100 + index
            citationView.layer.borderColor = VAColorUtility.borderColor_NT.cgColor
            citationView.backgroundColor = feedbackOption.isSelected ? VAColorUtility.borderColor_NT : UIColor.white

            let titleLabel = UILabel(frame: CGRect(x: 6, y: 0, width: 0, height: citationHeight))
            titleLabel.text = text
            titleLabel.textAlignment = .left
            titleLabel.font = GenAIFonts().normal(fontSize: 14)
            titleLabel.backgroundColor = .clear
            titleLabel.textColor = VAColorUtility.greyCharcoal_NT
            titleLabel.numberOfLines = 1
            var textWidth = text.size(withAttributes: [.font: titleLabel.font!]).width + 2
            textWidth = textWidth > textMaxWidth ? textMaxWidth : textWidth
            titleLabel.frame.size.width = textWidth
            
            viewWidth += titleLabel.frame.origin.x+textWidth//x+textwidth
            
            citationView.addSubview(titleLabel)
            citationView.frame.size.width = viewWidth+6
            
            let citationButton = UIButton(type: .custom)
            citationButton.frame = CGRect(x: citationView.bounds.origin.x, y: citationView.bounds.origin.y, width: citationView.bounds.width, height: citationView.bounds.height)
            citationButton.titleLabel?.text = ""
            citationButton.backgroundColor = .clear
            citationView.addSubview(citationButton)
            citationButton.tag = index
            citationButton.addTarget(self, action: #selector(feedbackOptionClicked), for: .touchUpInside)
            
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
            ratingOptionsView.addSubview(citationView)
            ratingOptionsViewHeight.constant = yAxis+citationHeight
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
    @objc func feedbackOptionClicked(sender: UIButton) {
        self.feedbackOptions = self.feedbackOptions.map({ item in
            var mutableItem = item
            mutableItem.isSelected = false
            return mutableItem
        })
        for index in 0..<self.feedbackOptions.count {
            if let view = viewWithTag(100+index) {
                if index == sender.tag {
                    view.backgroundColor = VAColorUtility.borderColor_NT
                    self.selectedFeedbackOption = self.feedbackOptions[index].value ?? ""
                    self.updateSendFeedbackButton()
                } else {
                    view.backgroundColor = UIColor.white
                }
            }
        }
        self.feedbackOptions[sender.tag].isSelected = true
    }
}

//MARK: UITextViewDelegate
extension FeedbackCell: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == self.feedbackPlaceholder || textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            textView.text = ""
            self.feedbackTextView.textColor = VAColorUtility.greyCharcoal_NT
        }
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            self.resetFeedbackTextView()
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        self.setCircularProgressForEnteredText(message: textView.text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text).trimmingCharacters(in: .whitespacesAndNewlines)
        if text == "\n"{
            if newText.isEmpty {
                textView.endEditing(true)
                return false
            } else {
                return true
            }
        }
        self.updateSendFeedbackButton(feedbackText: newText)
        return newText.count <= feedbackMaxCharCount
    }
    
    func updateSendFeedbackButton(feedbackText: String = "") {
        if !feedbackText.isEmpty || !self.selectedFeedbackOption.isEmpty {
            self.sendFeedbackImgView.tintColor = UIColor.white
            self.sendFeedbackBGView.backgroundColor = VAColorUtility.green_NT
            self.sendFeedbackMsgButton.isUserInteractionEnabled = true
        } else {
            self.sendFeedbackImgView.tintColor = VAColorUtility.greyCharcoal_NT
            self.sendFeedbackBGView.backgroundColor = VAColorUtility.lightSilver_NT
            self.sendFeedbackMsgButton.isUserInteractionEnabled = false
        }
    }

    /// Update the progress of view based on the number of charactes entered
    private func setCircularProgressForEnteredText(message: String) {
        let value = Float(message.count)
        let isOverLimit = message.count > feedbackMaxCharCount
        if isOverLimit == false {
            self.feedbackTextProgress?.progress = (value)/Float(feedbackMaxCharCount)
        }
    }
}
