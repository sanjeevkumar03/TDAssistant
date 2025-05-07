// VAColorUtility.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import Foundation
import UIKit
/// This class is used to handle color in the all screen of library
final class VAColorUtility: UIColor {
    // MARK: - Properties
    static var themeColor: UIColor = defaultThemeColor
    static var receiverBubbleColor: UIColor = defaultReceiverBubbleColor
    static var senderBubbleColor: UIColor = defaultSenderBubbleColor
    static var carouselColor: UIColor = defaultCarouselColor
    static var buttonColor: UIColor = defaultButtonColor

    static var themeTextIconColor: UIColor = defaultThemeTextIconColor
    static var receiverBubbleTextIconColor: UIColor = defaultReceiverBubbleTextIconColor
    static var senderBubbleTextIconColor: UIColor = defaultSenderBubbleTextIconColor
    static var carouselTextIconColor: UIColor = defaultCarouselTextIconColor

    // Default Properties
    static private let defaultThemeColor: UIColor = "#ffffff".hexToUIColor
    static private let defaultReceiverBubbleColor: UIColor = "#e8e8eb".hexToUIColor
    static let defaultSenderBubbleColor: UIColor = "#4B286D".hexToUIColor
    static private let defaultCarouselColor: UIColor = "#e8e8eb".hexToUIColor
    static let defaultButtonColor: UIColor = "#4B286D".hexToUIColor
    static let defaultThemeTextIconColor: UIColor = "#CBCBCB".hexToUIColor
    static private let defaultReceiverBubbleTextIconColor: UIColor = "#000000".hexToUIColor
    static private let defaultSenderBubbleTextIconColor: UIColor = "#ffffff".hexToUIColor
    static private var defaultCarouselTextIconColor: UIColor = "#000000".hexToUIColor

    static let defaultGreenColor: UIColor = "#4E8E29".hexToUIColor
    static let defaultHeaderColor: UIColor = .white
    static let defaultTextInputColor: UIColor = .white
    
    //New theme
    static let green_NT: UIColor = "#2b8000".hexToUIColor
    static let lightGrey_NT: UIColor = "#f4f4f7".hexToUIColor
    static let borderColor_NT: UIColor = "#E3E6E8".hexToUIColor
    static let greyCharcoal_NT: UIColor = "#414547".hexToUIColor
    static let greyShuttle_NT: UIColor = "#676E73".hexToUIColor
    static let errorRedColor_NT: UIColor = "#C12335".hexToUIColor
    static let errorRedBG_NT: UIColor = "#FFF6F8".hexToUIColor
    static let lightSilver_NT: UIColor = "#D9D9D9".hexToUIColor
    static let purple_NT: UIColor = "#7C53A5".hexToUIColor
    static let lightPurple_NT: UIColor = "#eae4f0".hexToUIColor
    static let alabaster_NT: UIColor = "#FAFAFA".hexToUIColor

    // end

    // MARK: - Initilize with VAConfigResultModel
    static func initWithConfigurationData(model: VAConfigIntegration?) {
        themeColor = model?.settings?.themeColor?.hexToUIColor ?? defaultThemeColor
        receiverBubbleColor = model?.settings?.responseBubble?.hexToUIColor ?? defaultReceiverBubbleColor
        senderBubbleColor = model?.settings?.senderBubble?.hexToUIColor ?? defaultSenderBubbleColor
        carouselColor = model?.settings?.carouselColor?.hexToUIColor ?? defaultCarouselColor
        buttonColor = model?.settings?.buttonColor?.hexToUIColor ?? defaultButtonColor

        themeTextIconColor = model?.settings?.widgetTextColor?.hexToUIColor ?? defaultThemeTextIconColor
        receiverBubbleTextIconColor = model?.settings?.responseTextIcon?.hexToUIColor ?? defaultReceiverBubbleTextIconColor
        senderBubbleTextIconColor = model?.settings?.senderTextIcon?.hexToUIColor ?? defaultSenderBubbleTextIconColor
        carouselTextIconColor = model?.settings?.carouselTextColor?.hexToUIColor ?? defaultCarouselTextIconColor
    }
    // end
}

// MARK: - String Extension: HexToUIColor
/// String extension for Color
/// This will return UIColor from Hex string code
extension String {
    var hexToUIColor: UIColor! {
        var cString: String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        if (cString.count) != 6 {
            return UIColor.gray
        }
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
