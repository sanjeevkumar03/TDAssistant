// ChatBubble.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import Foundation
import UIKit

class ChatBubble {
    /// This function is used to create resizable chat bubble
    /// - Parameter isBotMsg: This is used to identify wheter tail will be on left or right side of bubble
    /// - Returns: Strechable image
    static func createChatBubble(isBotMsg: Bool) -> UIImage {
        let bubbleImage = isBotMsg ? 
        UIImage(named: "leftChatBubble-shadow", in: Bundle.module, with: nil) :
        UIImage(named: "righChatBubble-shadow", in: Bundle.module, with: nil)
        let resizableImage = bubbleImage!
            .resizableImage(withCapInsets:
                                UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20),
                            resizingMode: .stretch)
            .withRenderingMode(.alwaysTemplate)
        return resizableImage
    }
    static func createRoundedChatBubble() -> UIImage {
        let bubbleImage = UIImage(named: "roundChatBubble", in: Bundle.module, with: nil)
        let resizableImage = bubbleImage!
            .resizableImage(withCapInsets:
                                UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                            resizingMode: .stretch)
            .withRenderingMode(.alwaysTemplate)
        return resizableImage
    }

    static func getChatBubbleWidth() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            if UIScreen.main.bounds.width <= 320 {
                return UIScreen.main.bounds.width*0.85
            } else if UIScreen.main.bounds.width <= 375 {
                return UIScreen.main.bounds.width*0.85
            } else {
                return UIScreen.main.bounds.width*0.8
            }
        } else {
            return UIScreen.main.bounds.width*0.5
        }
    }
}
