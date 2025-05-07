//  VAConfigurations.swift
//  Copyright © 2024 Telus Digital. All rights reserved.

import Foundation
import UIKit

/// VAConfigurations
class VAConfigurations {
     /// botId: We'll get the botId from the client app
    static var botId: String = ""
     /// customData: It contains all the custom data like language, userName, email, phone, tid etc.
    ///  It's an Optional parameter
    static var customData: VACustomData? // Client App
    static var environment: BotEnvironment? = .mqa
    static var XMPPHostName: String = ""
    static var XMPPHostPort: String = ""
    static var apiBaseURL: String = ""
    static var parentHost: String = ""
    static var language: LanguageConfiguration? = LanguageConfiguration.english
    static var arrayOfLanguages: [VAConfigLanguage] = []
    static var SSOAuthURL: String = "" // EVN SSO Auth URL
    static var OneLoginSSOAuthURL: String = "" // EVN One Login SSO Auth URL
    static var userUUID: String = "" // UUID
    static var password: String = "" // UUID
    static var vHost = "" // CONFIG API
    static var botName = "" // CONFIG API
    static var userJid: String = ""
    static var isTextToSpeechEnable: Bool = false
    static func generateUUID() -> String {
        var uuid = UserDefaultsManager.shared.getUserUUID()
        if uuid == "" {
            uuid = UUID().uuidString.lowercased()
            // uuid = UIDevice.current.identifierForVendor!.uuidString.lowercased()
            UserDefaultsManager.shared.setUserUUID(uuid)
        }
        return uuid
        // return UIDevice.current.identifierForVendor!.uuidString.lowercased()
        // return UUID().uuidString.lowercased()
    }

    static var isChatTool: Bool = false
    static var skill: String = "" // Queue Id
    static var jid: String = "" // Jid from Client App
    static var query: String = "" // From client app
    static var virtualAssistant: TDVirtualAssistant?
    static var isChatbotMinimized: Bool = false// Used to check whether chat bot is minimized or not

    static func getCurrentLanguageCode() -> String {
        if let langCode = VAConfigurations.language {
            if VAConfigurations.language == .chineseSimplified {
                return "zh_cn"
            } else if VAConfigurations.language == .chineseTraditional {
                return "zh_tw"
            } else if VAConfigurations.language == .tagalog {
                return "tl"
            } else {
                return langCode.rawValue
            }
        } else {
            return "en"
        }
    }

}

/// This struct is accessible in client app and is used to send information to chatbot. 
/// User can fill this info in prechat form.
public struct VACustomData {
    var userName: String = ""
    var displayName: String = ""
    var email: String = ""
    var phone: String = ""
    var language: LanguageConfiguration? = .english
    var businessDomain: String = ""
    var province: String = ""
    var tid: String = ""
    var brand: String = ""
    var productType: String = ""
    var extraData: [String: Any] = [:]
    var isGroupSSO: Bool = false
    var groupSssoJid: String = ""
    var groupSsoToken: String = ""
    public init(userName: String? = "",
                displayName: String? = "",
                email: String? = "",
                phone: String? = "",
                language: String = "",
                businessDomain: String? = "",
                province: String? = "",
                tid: String? = "",
                brand: String? = "",
                productType: String? = "",
                extraData: [String: Any]? = [:],
                isGroupSSO: Bool = false,
                groupSssoJid: String = "",
                groupSsoToken: String = "") {
        
        let lang = LanguageConfiguration(rawValue: language)
        self.userName = userName ?? ""
        self.displayName = displayName ?? ""
        self.email = email ?? ""
        self.phone = phone ?? ""
        self.language = lang
        self.businessDomain = businessDomain ?? ""
        self.province = province ?? ""
        self.tid = tid ?? ""
        self.brand = brand ?? ""
        self.productType = productType ?? ""
        self.extraData = extraData ?? [:]
        self.isGroupSSO = isGroupSSO
        self.groupSssoJid = groupSssoJid
        self.groupSsoToken = groupSsoToken
        
        if displayName?.isEmpty ?? true {
            if tid?.isEmpty ?? true {
                if email?.isEmpty ?? true {
                    if phone?.isEmpty ?? true {
                        if userName?.isEmpty ?? true {
                            self.displayName = VAConfigurations.userUUID
                        } else {
                            self.displayName = userName ?? ""
                        }
                    } else {
                        self.displayName = phone ?? ""
                    }
                } else {
                    self.displayName = email ?? ""
                }
            } else {
                self.displayName = tid ?? ""
            }
        }
    }
}

/// SSO supported in chatbot
struct SSOType {
    static let oauth = "oauth"
    static let oneLogin = "one_login"
    static let saml = "saml"
}
