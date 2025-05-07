/*
 MIT License
 
 Copyright (c) 2017-2018 MessageKit
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation
import AVKit

/// Quick reply/button card
private struct QuickReplyCard: QuickReplyProtocol {
    var quickReplyProtocol: QuickReply?
    init(quickReply: QuickReply) {
        self.quickReplyProtocol = quickReply
    }
}

/// Url card
private struct UrlCard: URLProtocol {
    var urlProtocol: URLItem?
    init(urlItem: URLItem) {
        self.urlProtocol = urlItem
    }
}

/// Text card
private struct TextCard: TextProtocol {
    var textProtocol: TextItem?
    init(textItem: TextItem) {
        self.textProtocol = textItem
    }
}

/// Image card
private struct ImageCard: ImageProtocol {
    var imageProtocol: ImageItem?
    init(imageItem: ImageItem) {
        self.imageProtocol = imageItem
    }
}

/// Source card
private struct PropCard: PropProtocol {
    var propProtocol: PropItem?
    init(prop: PropItem) {
        self.propProtocol = prop
    }
}

/// Video card
private struct VideoCard: VideoProtocol {
    var videoProtocol: VideoItem?
    init(videoItem: VideoItem) {
        self.videoProtocol = videoItem
    }
}

/// Agent message card
private struct AgentMessageCard: AgentProtocol {
    var agentMessage: AgentTextItem?
    init(agentItem: AgentTextItem) {
        self.agentMessage = agentItem
    }
}

/// Agent status card
private struct AgentStatusCard: AgentStatusProtocol {
    var statusMessage: AgentStatusItem?
    init(agentStatusItem: AgentStatusItem) {
        self.statusMessage = agentStatusItem
    }
}

/// Choice card
private struct MultiOpsStructure: MultiOpsProtocol {
    var multiOps: MultiOps?
    init(multiOps: MultiOps) {
        self.multiOps = multiOps
    }
}

/// Carousel card
private struct CarouselObject: CarouselProtocol {
    var carousel: Carousal?
    init(carousel: Carousal) {
        self.carousel = carousel
    }
}

internal struct MockMessage: MessageType {
    var messageId: String
    var sender: Sender
    var sentDate: Date
    var kind: MessageKind
    var isFeedback: Bool = false
    var isThumbsUpFeedback: Bool = false
    var isMultiSelect: Bool = false
    var allowSkip: Bool = false
    var isMultiOpsTapped: Bool = false
    var showBotImage: Bool = true
    var isAgent: Bool = false
    var sentiment: Int = 0
    var selectedCarouselItemIndex: Int = 0
    var context: [Dictionary<String, Any>] = []
    var isHideQuickReplyButtons: Bool = false
    var repliedMessageDict: [String: Any] = [:]
    var delay: Double = 0
    var messageSequance: Int = 0
    var isQuickReplyMsg: Bool = false
    var masked: Bool?
    var preventTyping: Bool = false
    var isPrompt: Bool = false
    var responseType: String = ""
    var replyIndex: Int = 0
    var allowSign: Bool = false
    var location: Bool = false
    var qrCode: Bool = false
    var isCustomFormInFlow: Bool = false
    var enableSpecificMsgReply: Bool = false
    var customForm: CustomForm? = nil
    var userMsgId: Int? = 0
    var isTextFeedbackProvided: Bool = false
    var isShowTypingEffectAnimation: Bool = false

    private init(kind: MessageKind, sender: Sender, messageId: String, date: Date) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }

    init(text: String, isFormFields: Bool = false, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .text(text, isFormFields), sender: sender, messageId: messageId, date: date)
    }

    init(quickReply: QuickReply, sender: Sender, messageId: String, date: Date) {
        let item = QuickReplyCard(quickReply: quickReply)
        self.init(kind: .quickReply(item), sender: sender, messageId: messageId, date: date)
    }

    init(urlItem: URLItem, sender: Sender, messageId: String, date: Date) {
        let item = UrlCard(urlItem: urlItem)
        self.init(kind: .urlItem(item), sender: sender, messageId: messageId, date: date)
    }

    init(textItem: TextItem, sender: Sender, messageId: String, date: Date) {
        let item = TextCard(textItem: textItem)
        self.init(kind: .textItem(item), sender: sender, messageId: messageId, date: date)
    }

    init(imageItem: ImageItem, sender: Sender, messageId: String, date: Date) {
        let item = ImageCard(imageItem: imageItem)
        self.init(kind: .imageItem(item), sender: sender, messageId: messageId, date: date)
    }

    init(propItem: PropItem, sender: Sender, messageId: String, date: Date) {
        let prop = PropCard(prop: propItem)
        self.init(kind: .source(prop), sender: sender, messageId: messageId, date: date)
    }

    init(carousel: Carousal, sender: Sender, messageId: String, date: Date) {
        let carouselObj = CarouselObject(carousel: carousel)
        self.init(kind: .carouselItem(carouselObj), sender: sender, messageId: messageId, date: date)
    }

    init(dateFeedback: Any?, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .dateFeedback(dateFeedback), sender: sender, messageId: messageId, date: date)
    }

    init(custom: Any?, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .custom(custom), sender: sender, messageId: messageId, date: date)
    }

    init(multiOptional: MultiOps, sender: Sender, messageId: String, date: Date) {
        let multiOps = MultiOpsStructure(multiOps: multiOptional)
        self.init(kind: .multiOps(multiOps), sender: sender, messageId: messageId, date: date)
    }

    init(videoUrlString: String, sender: Sender, messageId: String, date: Date) {
        let videoItem = VideoItem(urlStr: videoUrlString)
        let videoProtocol = VideoCard(videoItem: videoItem)
        self.init(kind: .video(videoProtocol), sender: sender, messageId: messageId, date: date)
    }

    init(agentName: String, agentMessage: String, doNotRespond: Bool, sender: Sender, messageId: String, date: Date) {
        let item = AgentTextItem(agentName: agentName, message: agentMessage, doNotRespond: doNotRespond)
        let agentProtocol = AgentMessageCard(agentItem: item)
        self.init(kind: .agentMessage(agentProtocol), sender: sender, messageId: messageId, date: date)
    }

    init(agentName: String, agentStatus: String, sender: Sender, messageId: String, date: Date) {
        let item = AgentStatusItem(agentName: agentName, status: agentStatus)
        let agentProtocol = AgentStatusCard(agentStatusItem: item)
        self.init(kind: .agentStatus(agentProtocol), sender: sender, messageId: messageId, date: date)
    }
    
    init(dateItem: String, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .dateItem(""), sender: sender, messageId: messageId, date: date)
    }
    
    init(feedbackItem: String, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .feedbackItem(""), sender: sender, messageId: messageId, date: date)
    }
}
