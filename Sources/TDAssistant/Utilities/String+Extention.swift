//  String+Extention.swift
//  Copyright © 2024 Telus Digital. All rights reserved.

import Foundation
import UIKit
import CommonCrypto

extension String {

    /// Converts html to attributed string
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            // return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
            if let attributedString = try? NSAttributedString(
                                                                data: data,
                                                                options: [.documentType: NSAttributedString.DocumentType.html,
                                                                .characterEncoding: String.Encoding.utf8.rawValue],
                                                                documentAttributes: nil) {
                let mutableAttrStr = NSMutableAttributedString(attributedString: attributedString)
                let noSpaceAttributedString = mutableAttrStr.trimmedAttributedString(set: CharacterSet.whitespacesAndNewlines)
                return noSpaceAttributedString
            }
            return NSAttributedString()
        }
    }

    /// Converts html to string
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }

    /// Converts base64 string to normal string
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    /// Converts normal string to base64 string
    /// - Returns: base64 string
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

    /// Converts html to attributed string
    private var convertHtmlToNSAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    /// Converts html to attributed string
    /// - Parameters:
    ///   - font: text font
    ///   - csscolor: text color
    ///   - lineheight: text line height
    ///   - csstextalign: text alignment
    /// - Returns: attributed string
    public func convertHtmlToAttributedStringWithCSS(font: UIFont?, csscolor: String, lineheight: Int, csstextalign: String) -> NSAttributedString? {
        guard let font = font else {
            return convertHtmlToNSAttributedString
        }
        let modifiedString = """
<style>body{font-family: '\(font.fontName)'; font-size:\(font.pointSize)px; color: \(csscolor);
line-height: \(lineheight)px; text-align: \(csstextalign); }</style>\(self)
"""
        guard let data = modifiedString.data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print(error)
            return nil
        }
    }
}

extension String {
    /// This function trims html tags present in string
    /// - Returns: Returns string without html tags
    public func trimHTMLTags() -> String? {
        guard let htmlStringData = self.data(using: String.Encoding.utf8) else {
            return nil
        }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        let attributedString = try? NSAttributedString(data: htmlStringData, options: options, documentAttributes: nil)
        let string = attributedString?.string.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        return string
    }
}

extension String {
    /// trims html tags present in string
    var withoutHtmlTags: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options:
                .regularExpression, range: nil).replacingOccurrences(of: "&[^;]+;", with:
                                                                        "", options: .regularExpression, range: nil)
    }
}

extension String {
    /// Convert text to attributed string from html
    /// - Returns: attributed string
    func convertToAttributedFromHTML() -> NSAttributedString? {
        var attributedText: NSAttributedString?
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue]
        if let data = data(using: .unicode, allowLossyConversion: true), let attrStr = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            attributedText = attrStr
        }
        return attributedText
    }
}

extension NSAttributedString {

    /// Used to create attributed string and add provided attributes to it.
    /// - Parameters:
    ///   - html: HTML string
    ///   - font: text font
    ///   - useDocumentFontSize: text font size
    ///   - useDocumentFontColor: text font color
    convenience init(htmlString html: String, font: UIFont? = nil, useDocumentFontSize: Bool = true, useDocumentFontColor: Bool = true) throws {
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        let data = html.data(using: .utf8, allowLossyConversion: true)
        guard data != nil, let fontFamily = font?.familyName, let attr = try? NSMutableAttributedString(data: data!, options: options, documentAttributes: nil) else {
            try self.init(data: data ?? Data(html.utf8), options: options, documentAttributes: nil)
            return
        }

        let fontSize: CGFloat? = useDocumentFontSize ? nil : font!.pointSize
        let range = NSRange(location: 0, length: attr.length)
        attr.enumerateAttribute(.font, in: range, options: .longestEffectiveRangeNotRequired) { attrib, range, _ in
            if let htmlFont = attrib as? UIFont {
                let traits = htmlFont.fontDescriptor.symbolicTraits
                var descrip = htmlFont.fontDescriptor.withFamily(fontFamily)

                if (traits.rawValue & UIFontDescriptor.SymbolicTraits.traitBold.rawValue) != 0 {
                    descrip = descrip.withSymbolicTraits(.traitBold)!
                }

                if (traits.rawValue & UIFontDescriptor.SymbolicTraits.traitItalic.rawValue) != 0 {
                    descrip = descrip.withSymbolicTraits(.traitItalic)!
                }

                var attributes = [NSAttributedString.Key: AnyObject]()
                if !useDocumentFontColor {
                    attributes[.foregroundColor] = UIColor.white
                }
                attributes[.font] = UIFont(descriptor: descrip, size: fontSize ?? htmlFont.pointSize)
                attr.addAttributes(attributes, range: range)
            }
        }

        self.init(attributedString: attr)
    }

}

extension String {
    /// This function is used to calculate width and height of string
    /// - Parameter font: font used
    /// - Returns: returns width and height of string
    func size(OfFont font: UIFont) -> CGSize {
        return (self as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
    }
}

extension NSAttributedString {

    /// This func calculates height of text
    /// - Parameter containerWidth: width of view where text is added/displayed
    /// - Returns: height of text
    func height(containerWidth: CGFloat) -> CGFloat {

        let rect = self.boundingRect(with: CGSize.init(width: containerWidth, height: CGFloat.greatestFiniteMagnitude),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     context: nil)
        return ceil(rect.size.height)
    }

    /// This func calculates width of text
    /// - Parameter containerHeight: height of view where text is added/displayed
    /// - Returns: width of text
    func width(containerHeight: CGFloat = 40) -> CGFloat {
        let rect = self.boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: containerHeight),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     context: nil)
        return ceil(rect.size.width + 20)
    }
}

extension String {
    /// This func create cryptographic hash sha1
    /// - Returns: cryptographic hash sha1 string
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}

extension String {
    /// This function parses the json
    /// - Returns: returns a response in the form of MessageData model
    func parseJsonResponse() -> MessageData {
        var messageData: MessageData = MessageData(messageData: [:])
        // var responseList:[Response] = []
        if let data = self.data(using: .utf8) {
            do {
                if let jsonDict = try? (JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any]) {
                    if let content = jsonDict["content"] as? [String: Any] as NSDictionary? as? [AnyHashable: Any] {
                        print("Received message response:\n\(jsonDict)")
                        messageData = MessageData(messageData: content as NSDictionary)
                        // ******To show source for text card only
                        let isTextCard = (messageData.responseList.filter({$0.responseType == "text"}).count) > 0
                        if isTextCard == false {
                            // Excluding source from messages as source will only display with text card
                            let updatedResponseList = messageData.responseList.filter({$0.responseType != "props"})
                            messageData.responseList = updatedResponseList
                        } else {
                            // Adding source field inside text card
                            let source = messageData.responseList.filter({$0.responseType == "props"})
                            if source.count > 0 {
                                let index = messageData.responseList.firstIndex(where: {$0.prop == source[0].prop})
                                if index != nil {
                                    messageData.responseList.remove(at: index!)
                                }
                            }
                            //
                            if source.first?.prop?.onesource != ""/*Remove source if link is empty*/ {
                                let textCardIndex = messageData.responseList.lastIndex(where: {$0.responseType == "text"})
                                if textCardIndex != nil {
                                    messageData.responseList[textCardIndex!].prop = source.first?.prop
                                }
                            }
                        }
                        // ******
                        // print(messageData as Any)
                        return messageData
                    } else if jsonDict["contexts"] != nil {
                        print("Received message response:\n\(jsonDict)")
                        messageData = MessageData(messageData: jsonDict as NSDictionary)
                        // ******To show source for text card only
                        let isTextCard = (messageData.responseList.filter({$0.responseType == "text"}).count) > 0
                        if isTextCard == false {
                            // Excluding source from messages as source will only display with text card
                            let updatedResponseList = messageData.responseList.filter({$0.responseType != "props"})
                            messageData.responseList = updatedResponseList
                        } else {
                            // Adding source field inside text card
                            let source = messageData.responseList.filter({$0.responseType == "props"})
                            if source.count > 0 {
                                let index = messageData.responseList.firstIndex(where: {$0.prop == source[0].prop})
                                if index != nil {
                                    messageData.responseList.remove(at: index!)
                                }
                            }
                            //
                            if source.first?.prop?.onesource != ""/*Remove source if link is empty*/ {
                                let textCardIndex = messageData.responseList.lastIndex(where: {$0.responseType == "text"})
                                if textCardIndex != nil {
                                    messageData.responseList[textCardIndex!].prop = source.first?.prop
                                }
                            }
                        }
                        // ******
                        // print(messageData as Any)
                        return messageData
                    }
                }
            }
        }
        return messageData
    }

    /// Returns string after stripping html tags
    public var withoutHtml: String {
        guard let data = self.data(using: .utf8) else {
            return self
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }

        return attributedString.string
    }
}

extension NSMutableAttributedString {

    /// this func returns trimmed attributed string
    /// - Parameter set: set of unicode compliant charactes eg. white space, newline etc
    /// - Returns: atribbuted string
    func trimmedAttributedString(set: CharacterSet) -> NSMutableAttributedString {
        let invertedSet = set.inverted
        var range = (string as NSString).rangeOfCharacter(from: invertedSet)
        let loc = range.length > 0 ? range.location : 0
        range = (string as NSString).rangeOfCharacter(
            from: invertedSet, options: .backwards)
        let len = (range.length > 0 ? NSMaxRange(range) : string.count) - loc
        let attrStr = self.attributedSubstring(from: NSRange(location: loc, length: len))
        return NSMutableAttributedString(attributedString: attrStr)
    }
}

/// This function is used  to check the email validation
func isValidEmail(_ email: String) -> Bool {
    let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    return email.range(of: emailPattern, options: .regularExpression) != nil
}

/// This func checks if a string has html text or not
func isHTMLText(_ text: String) -> Bool {
    guard !text.isEmpty else { return false }
    let htmlPattern = "<.+?>"
    return text.range(of: htmlPattern, options: .regularExpression) != nil
}

/// Create attributed string from plain text
/// - Parameter text: input string
/// - Returns: attributed string
func createNormalAttributedString(text: String, isNewGenAITheme: Bool) -> NSMutableAttributedString {
    /*var completeText = text
     completeText = "<span style=\"font-family: Helvetica; font-size: 16px\">\(completeText)</span>"
     var normalAttributedString = NSMutableAttributedString(string: "")
     if let attributedText = completeText.htmlToAttributedString as? NSMutableAttributedString {
     normalAttributedString = attributedText
     normalAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: VAColorUtility.receiverBubbleTextIconColor, range: NSRange(location: 0, length: normalAttributedString.length))
     }
     return normalAttributedString*/
    var completeText: String = text
    var completeAttributedText = NSMutableAttributedString(string: "")

    let parsedHtml = parseIFrameTag(htmlText: completeText)

    completeText = parsedHtml

    // completeText = completeText.replacingOccurrences(of: "</p><p><br>", with: "")
    // removing extra bullets
    completeText = completeText.replacingOccurrences(of: "<br><li>", with: "<li>")
    completeText = completeText.replacingOccurrences(of: "<br></ul>", with: "</ul>")
    // Fix mailto, call tags
    completeText = completeText.replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">").replacingOccurrences(of: "/a&gt", with: "/a>")
    if !completeText.contains("‎")/*checking for empty character*/ {
        completeText = completeText.replacingOccurrences(of: "<ol><li>", with: "‎‎<br><ol><li>").replacingOccurrences(of: "<ul><li>", with: "‎‎<br><ul><li>")
    }
    if isNewGenAITheme {
        completeText = "<span style=\"font-family: Helvetica; font-size: 14px\">\(completeText)</span>"
    } else {
        completeText = "<span style=\"font-family: Helvetica; font-size: 16px\">\(completeText)</span>"
    }
    if let attributedText = completeText.htmlToAttributedString as? NSMutableAttributedString {
        completeAttributedText = attributedText
        if !isNewGenAITheme {
            completeAttributedText.addAttribute(NSAttributedString.Key.foregroundColor,
                                                value: VAColorUtility.receiverBubbleTextIconColor,
                                                range: NSRange(location: 0, length: completeAttributedText.length))
        }
        return completeAttributedText
    }
    return completeAttributedText
}
/// Create attributed string from plain text
/// - Parameter text: input string
/// - Returns: attributed string
func createAttributedString(text: String, isNewGenAITheme: Bool) -> NSMutableAttributedString {
    // Remove iframe tag and add video url
    var completeAttributedText = NSMutableAttributedString(string: "")
    var completeText = text
    let parsedHtml = parseIFrameTag(htmlText: completeText)
    completeText = parsedHtml
     completeText = completeText.replacingOccurrences(of: "<br><br>", with: "<br>")
    // removing extra bullets
    completeText = completeText.replacingOccurrences(of: "<br><li>", with: "<li>")
    completeText = completeText.replacingOccurrences(of: "<br></ul>", with: "</ul>")

    // Fix mailto, call tags
    completeText = completeText.replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">").replacingOccurrences(of: "/a&gt", with: "/a>")
    // MARK: Used below link to add hidden character in html text to handle alignment issue in ordered and unordered list
    // Empty character is added before <br> tag
    // https://emptycharacter.com
    if !completeText.contains("‎")/*checking for empty character*/ {
        completeText = completeText.replacingOccurrences(of: "<ol><li>", with: "‎‎<br><ol><li>").replacingOccurrences(of: "<ul><li>", with: "‎‎<br><ul><li>")
    }
    // completeText = completeText.replacingOccurrences(of: "<ol>", with: "<ol style=\"max-width:1%; margin:auto; padding: 0; list-style-position: inside; text-align: left\">")
    // completeText = completeText.replacingOccurrences(of: "<ul>", with: "<ul style=\"max-width:1%; margin:auto; padding: 0; list-style-position: inside; text-align: left\">")
    // completeText = completeText.replacingOccurrences(of: "<li>", with: "<li list-style-position: inside; list-style-type: circle;>")

    // Adding custom font  to html string
    if isNewGenAITheme {
        completeText = "<span style=\"font-family: Helvetica; font-size: 14px\">\(completeText)</span>"
    } else {
        completeText = "<span style=\"font-family: Helvetica; font-size: 16px\">\(completeText)</span>"
    }
    // let images = completeText.regex("<img[^>]+src*=\".*?\"['/']>")
    if let attributedText = completeText.htmlToAttributedString as? NSMutableAttributedString {
        completeAttributedText = attributedText
        completeAttributedText = adjustImageInTextCardIfExist(text: completeAttributedText)
        /*completeAttributedText.addAttribute(NSAttributedString.Key.foregroundColor,
                                            value: VAColorUtility.receiverBubbleTextIconColor,
                                            range: NSRange(location: 0, length: completeAttributedText.length))*/
    }
    return completeAttributedText
}

/// This func add dimenstions to image if exist in attributed string
/// - Parameter text: original attributed text
/// - Returns: modified attributed text with image dimensions
func adjustImageInTextCardIfExist(text: NSMutableAttributedString) -> NSMutableAttributedString {
    let attributedText = text
    attributedText.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: attributedText.length), options: []) { (value, range, _) in

        if value is NSTextAttachment {
            let attachment: NSTextAttachment? = (value as? NSTextAttachment)
            var image: UIImage?

            if (attachment?.image) != nil {
                image = attachment?.image
            } else {
                image = attachment?.image(forBounds: (attachment?.bounds)!, textContainer: nil, characterIndex: range.location)
                let attachment = NSTextAttachment()
                attachment.image = image

                /*let newWidth = textView.bounds.width - 20
                 let scale = newWidth / (image?.size.width ?? 0.0)
                 let newHeight = (image?.size.height ?? 0.0) * scale*/
                // print("Image Dimension: \(image?.size)")
                let textViewWidth: CGFloat = 175
                let newWidth = (image?.size.width ?? 0.0) > textViewWidth ? textViewWidth : image?.size.width ?? 0.0
                let adjustedHeight: CGFloat = 250
                let newHeight = (image?.size.height ?? 0.0) > adjustedHeight ? adjustedHeight : (image?.size.height ?? adjustedHeight)
                /*if newWidth > 50 {
                 newHeight = newWidth
                 }*/
                attachment.bounds = CGRect.init(x: 0, y: 0, width: newWidth, height: newHeight)
                let attrString = NSAttributedString(attachment: attachment)
                attributedText.replaceCharacters(in: range, with: attrString)
            }

        }
    }
    return attributedText
}

/// This func gets the image urls from html text
func getImagesFromHtml(for regex: String!, in text: String!) -> [String] {
    do {
        let regex = try NSRegularExpression(pattern: regex, options: [])
        let nsString = text as NSString
        let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
        return results.map { nsString.substring(with: $0.range)}
    } catch let error as NSError {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

/// This func parses the iframe tag to extract video url from html text
/// - Parameter htmlText: input html text
/// - Returns: parsed video url
func parseIFrameTag(htmlText: String) -> String {
    var modifiedString = ""
    let htmls = htmlText.components(separatedBy: "<iframe")
    for item in htmls {
        if item.contains("</iframe>") {
            let subItems = item.components(separatedBy: "</iframe>")
            for subItem in subItems {
                if subItem.contains("src=") {
                    let iFrameSources = subItem.components(separatedBy: "src=")
                    for source in iFrameSources {
                        if source.contains("http") {
                            let sources = source.components(separatedBy: "\"")
                            var urlStr = ""
                            for src in sources {
                                if src.isValidURL {
                                    urlStr = src
                                    break
                                }
                            }
                            let url = URL(string: urlStr)
                            let fileExtension = url?.pathExtension
                            if urlStr != "" && (fileExtension == "mp4" || fileExtension == "webm" || fileExtension == "mov" || fileExtension == "avi") {
                                let modifiedSource = "<p><a class=\"urlLink\" href=\"\(url!)\" data-displaylinkname=\"\(url!)\">\(url!)</a></p>"
                                modifiedString += modifiedSource
                            } else {
                                if !modifiedString.contains(subItem) {
                                    modifiedString += subItem
                                }
                            }

                        }
                    }
                } else {
                    modifiedString += subItem
                }
            }
        } else {
            modifiedString += item
        }
    }
    return modifiedString
}

/// This function formats the date
/// - Parameter date: Input date
/// - Returns: returns formatted date
 func getMessageTime(date: Date) -> String {
    let currentDateTime = date
    let formatter = DateFormatter()
    //formatter.dateFormat = "MM/dd/yyyy, h:mm:ss a"
    formatter.dateFormat = "dd MMM, h:mm a"
    return formatter.string(from: currentDateTime)
}

///Regex validation
extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

extension NSAttributedString {
    func characterCountIncludingImages() -> Int {
        var count = 0
        self.enumerateAttributes(in: NSRange(location: 0, length: self.length), options: []) { attributes, range, _ in
            if attributes[.attachment] is NSTextAttachment {
                // Count images (NSTextAttachment) as a single character
                count += 1
            } else {
                // Count the length of the text in the range
                count += range.length
            }
        }
        return count
    }
}
