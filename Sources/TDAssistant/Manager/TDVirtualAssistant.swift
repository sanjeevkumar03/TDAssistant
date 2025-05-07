//  TDVirtualAssistant.swift
//  Copyright © 2024 Telus Digital. All rights reserved.

import Foundation
import UIKit

/// TDVirtualAssistant Protocols
@objc public protocol TDVirtualAssistantDelegate {
    /// This function is called once chatbot is closed
    func didTapCloseChatbot()
    /*
    /// This function is called once user taps on minimize button of chatbot
    func didTapMinimizeChatbot()
    /// This function is called once user taps on maximize button of chatbot
    func didTapMaximizeChatbot()*/
    /// Native(Internal) call transfer - Genesys
    @objc optional func initiateNativeCallTransfer(data: [String: Any]?)
    /// This delegate method is called once user is not able to claim existing session in case of chat tool
    @objc optional func oldSessionNotClaimedStartNewConversationWithNewJID()
    /// This delegate method is called once chat is closed by agent.
    @objc optional func chatClosedByAgent()
}

public class TDVirtualAssistant {
    public init() {}
    public var delegate: TDVirtualAssistantDelegate?

    
    /// This function is used to initialize chatbot with all the required details.
    /// - Parameters:
    ///   - botId: Unique id of bot
    ///   - environment: Details such as api url, xmpp host, xmpp port etc. required to run the bot.
    ///   - customData: Data that we want to pass from client app to chatbot.
    ///   - query: Jump to a specific flow in chatbot by skipping the welcome msg from chatbot
    ///   - isStartNewSession: Tells chatbot to launch new session or reclaim the old one if session not expired.
    public func initWith(botId: String,
                         environment: BotEnvironment? = .mqa,
                         customData: VACustomData? = nil,
                         isChatTool: Bool = false,
                         jid: String = "",
                         query: String = "",
                         isStartNewSession: Bool = false) -> UIViewController {

        // Update VAConfigurations
        VAConfigurations.botId = botId
        VAConfigurations.customData = customData
        VAConfigurations.environment = environment
        VAConfigurations.language = customData?.language
        VAConfigurations.isChatTool = isChatTool
        VAConfigurations.jid = jid
        VAConfigurations.query = query
        
        if (VAConfigurations.isChatTool || VAConfigurations.customData?.isGroupSSO == true), VAConfigurations.jid.isEmpty == false {
            //Get UUID from Jid
            let splitJid = VAConfigurations.jid.split(separator: "@")
            if splitJid.count > 1 {
                VAConfigurations.userUUID = String(splitJid[0])
            } else {
                VAConfigurations.userUUID = VAConfigurations.jid
            }
        } else {
            VAConfigurations.userUUID = VAConfigurations.generateUUID()
        }
        if isStartNewSession {
            UserDefaultsManager().resetSessionID()
        }
        debugPrint("User UUID: \(VAConfigurations.userUUID)")
        if VAConfigurations.customData != nil {
            if VAConfigurations.customData?.extraData.count ?? 0 > 0 {
                if let skill = VAConfigurations.customData?.extraData["queue"] as? String {
                    VAConfigurations.skill = skill
                }
            }
        }
        VAConfigurations.password = VAConfigurations.userUUID

        let env = VAEnvironmentManager.shared.getEnvironmentDetails(environment ?? .mqa)
        VAConfigurations.XMPPHostName = env.xmppHost
        VAConfigurations.XMPPHostPort = env.xmppPort
        VAConfigurations.apiBaseURL = env.apiBaseUrl
        VAConfigurations.SSOAuthURL = env.ssoAuthURL
        VAConfigurations.OneLoginSSOAuthURL = env.oneLoginSSOAuthURL
        VAConfigurations.parentHost = env.parentHost
        VAConfigurations.virtualAssistant = self

        // Open ChatViewController
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: VAChatViewController.self))
        /*for resource in Bundle.module.paths(forResourcesOfType: nil, inDirectory: nil) {
            print("🔍 Bundle.module contains: \(resource)")
        }
        if let path = Bundle.module.path(forResource: "Main", ofType: "storyboardc") {
            print("✅ Found Main.storyboardc at: \(path)")
        } else {
            print("❌ Could NOT find Main.storyboardc in Bundle.module")
        }*/
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.module)
        let chatViewController = storyboard.instantiateViewController(withIdentifier: "VAChatViewController")
        return chatViewController
    }
}
