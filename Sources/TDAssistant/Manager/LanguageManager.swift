//  LanguageManager.swift
//  Copyright © 2024 Telus Digital. All rights reserved.

import UIKit

/// Supported Languages in TDVirtualAssistant
enum LanguageConfiguration: String, CaseIterable {
    case english = "en"
    case chineseTraditional = "zh-Hant"// zh_tw
    case chineseSimplified = "zh-Hans"// zh_cn
    case french = "fr"
    case german = "de"
    case spanish = "es"
    case turkish = "tr"
    case punjabi = "pa"
    case dutch = "nl"
    case persian = "fa"
    case tagalog = "fil-PH"// tl
    case japanese = "ja"
}
// end

class LanguageManager {

    /// shared instance for language manager
    class var shared: LanguageManager {
        struct Global {
            static let instance = LanguageManager()
        }
        return Global.instance
    }

    /// This function returns the language code of supported language in chatbot
    func languageKey() -> String? {
        let lang = VAConfigurations.language?.rawValue ?? "en"
        if lang == "en" {
            return "en"
        } else if lang == "zh-Hant" {
            return "zh-Hant"
        } else if lang == "zh-Hans" {
            return "zh-Hans"
        } else if lang == "fr" {
            return "fr"
        } else if lang == "de" {
            return "de"
        } else if lang == "es" {
            return "es"
        } else if lang == "tr" {
            return "tr"
        } else if lang == "pa" {
            return "pa"
        } else if lang == "nl" {
            return "nl"
        } else if lang == "fa" {
            return "fa"
        } else if lang == "fil-PH" {
            return "fil-PH"
        } else if lang == "ja" {
            return "ja"
        }
        return "en"
    }

    /// This function returns the localized string for current language.
    func localizedString(forKey key: String) -> String {
        var path: String?
        let bundlePath = Bundle.module//Bundle(for: VAChatViewController.self)
        if self.languageKey() == "en" {
            path = bundlePath.path(forResource: "en", ofType: "lproj")
        } else if self.languageKey() == "zh-Hant" {
            path = bundlePath.path(forResource: "zh-Hant", ofType: "lproj")
        } else if self.languageKey() == "zh-Hans" {
            path = bundlePath.path(forResource: "zh-Hans", ofType: "lproj")
        } else if self.languageKey() == "fr" {
            path = bundlePath.path(forResource: "fr", ofType: "lproj")
        } else if self.languageKey() == "de" {
            path = bundlePath.path(forResource: "de", ofType: "lproj")
        } else if self.languageKey() == "es" {
            path = bundlePath.path(forResource: "es", ofType: "lproj")
        } else if self.languageKey() == "tr" {
            path = bundlePath.path(forResource: "tr", ofType: "lproj")
        } else if self.languageKey() == "pa" {
            path = bundlePath.path(forResource: "pa", ofType: "lproj")
        } else if self.languageKey() == "nl" {
            path = bundlePath.path(forResource: "nl", ofType: "lproj")
        } else if self.languageKey() == "fa" {
            path = bundlePath.path(forResource: "fa", ofType: "lproj")
        } else if self.languageKey() == "fil-PH" {
            path = bundlePath.path(forResource: "fil-PH", ofType: "lproj")
        } else if self.languageKey() == "ja" {
            path = bundlePath.path(forResource: "ja", ofType: "lproj")
        }
        let languageBundle = Bundle(path: path ?? "")
        let str = languageBundle?.localizedString(forKey: key, value: "", table: nil)
        return str ?? ""
    }
}
