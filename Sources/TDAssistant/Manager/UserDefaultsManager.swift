// UserDefaultManager.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import Foundation

final class UserDefaultsManager {

    /// Shared instance of UserDefaults
    static let shared = UserDefaultsManager()

    /// Declared user defaults keys
    enum UserDefaultsKeys: String {
        case chatBotInitialized = "ChatBotInitialized"
        case userSelectedLanguage = "UserSelectedLanguage"
        case userUUID = "UserUUID"
        case sessionID = "SessionId"
    }
    // end

    /// Used to set userdefaults value to true for chatBotInitialized key
    func initializeChatBot() {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.chatBotInitialized.rawValue)
    }
    /// Used to set userdefaults value to false for chatBotInitialized key
    func deInitializeChatBot() {
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.chatBotInitialized.rawValue)
    }
    /// Used to get userdefaults value of chatBotInitialized key
    func isChatBotInitialized() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKeys.chatBotInitialized.rawValue)
    }
    /// Used to set userdefaults string value  for userUUID key
    func setUserUUID(_ uuid: String) {
        UserDefaults.standard.set(uuid, forKey: UserDefaultsKeys.userUUID.rawValue)
    }
    /// Used to get userdefaults string value  for userUUID key
    func getUserUUID() -> String {
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.userUUID.rawValue) ?? ""
    }
    /// Used to set userdefaults string value  for userUUID key to empty string
    func resetUserUUID() {
        UserDefaults.standard.set("", forKey: UserDefaultsKeys.userUUID.rawValue)
    }
    /// Used to set userdefaults string value  for sessionID key
    func setSessionID(_ sessionId: String) {
        UserDefaults.standard.set(sessionId, forKey: UserDefaultsKeys.sessionID.rawValue)
    }
    /// Used to get userdefaults string value  for sessionID key
    func getSessionID() -> String {
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.sessionID.rawValue) ?? "0"
    }
    /// Used to set userdefaults string value  for sessionID key to empty string
    func resetSessionID() {
        UserDefaults.standard.set("0", forKey: UserDefaultsKeys.sessionID.rawValue)
    }
    /// Used to set userdefaults string value  for userSelectedLanguage key
    func setBotLanguage(_ language: String) {
        UserDefaults.standard.set(language, forKey: UserDefaultsKeys.userSelectedLanguage.rawValue)
    }
    /// Used to get userdefaults string value  for userSelectedLanguage key
    func getBotLanguage() -> String {
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.userSelectedLanguage.rawValue) ?? ""
    }

    /// This function is used to reset all userdefaults values
    func resetAllUserDefaults() {
        // self.deInitializeChatBot()
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        VAConfigurations.userUUID = ""
        VAConfigurations.userJid = ""
        dictionary.keys.forEach { key in
            if key != UserDefaultsKeys.userSelectedLanguage.rawValue {
                defaults.removeObject(forKey: key)
            }
        }
    }
}
