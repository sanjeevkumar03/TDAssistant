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
import UIKit

/// A protocol used to represent the data for a media message.
 protocol MediaItem {
    var urlStr: String? { get }

    /// The url where the media is located.
    var url: URL? { get }

    /// The image.
    var image: UIImage? { get }

    /// A placeholder image for when the image is obtained asychronously.
    var placeholderImage: UIImage { get }

    /// The size of the media item.
    var size: CGSize { get }

}

/// Video
protocol VideoProtocol {
    var videoProtocol: VideoItem? { get }
}

/// Quick Reply/Button
protocol QuickReplyProtocol {
    var quickReplyProtocol: QuickReply? { get set }
}

/// URL
protocol URLProtocol {
   var urlProtocol: URLItem? { get }
}

/// Text
protocol TextProtocol {
   var textProtocol: TextItem? { get }
}

/// Image
protocol ImageProtocol {
   var imageProtocol: ImageItem? { get }
}

/// Source
 protocol PropProtocol {
    var propProtocol: PropItem? { get }
}

/// Carousel
protocol CarouselProtocol {
    var carousel: Carousal? { get set }
}

/// Choice Card.
 protocol MultiOpsProtocol {
    var multiOps: MultiOps? { get }
}

/// Agent Text
protocol AgentProtocol {
    var agentMessage: AgentTextItem? {get}
}

/// Agent Status Text
protocol AgentStatusProtocol {
    var statusMessage: AgentStatusItem? {get}
}
