//  VAEnvironmentManager.swift
//  Copyright © 2024 Telus Digital. All rights reserved.

import Foundation

/**It contains pre-defined enironemnts details such as api url, xmpp host, xmpp port etc. User has the ability to provide its own details instead of picking from the predefined. Select type custom to add your own values.**/
public enum BotEnvironment {
    case mdev
    case mqa
    case stage
    case tiiaProd
    case tvaProd
    case kvaProd
    case chatGPT
    case custom(apiUrl: String, xmppHost: String, xmppPort: String)
}

class VAEnvironmentManager {
    static let shared = VAEnvironmentManager()
    typealias EnvironmentDetails = (apiBaseUrl: String, xmppHost: String,
                                    xmppPort: String, ssoAuthURL: String,
                                    parentHost: String, oneLoginSSOAuthURL: String)

    func getEnvironmentDetails (_ environment: BotEnvironment) -> EnvironmentDetails {

        switch environment {
        case .mdev:
            let apiUrl = "https://mdev.xavlab.xyz"
            let xmppHost = "34.69.252.215"
            let xmppPort = "5222"
            let ssoAuthUrl = "https://widget-mdev.xavlab.xyz/auth.html"
            let oneLoginSSOAuthUrl = "https://mdev.xavlab.xyz/auth.html"
            let parentHost = "widget-mdev.xavlab.xyz"
            return EnvironmentDetails(apiUrl, xmppHost, xmppPort, ssoAuthUrl, parentHost, oneLoginSSOAuthUrl)

        case .mqa:
            let apiUrl = "https://mqa2.xavlab.xyz"
            let xmppHost = "appmqa.xavlab.xyz"
//            let xmppHost = "34.9.127.204"
            let xmppPort = "5222"
            let ssoAuthUrl = "https://widget-mqa2.xavlab.xyz/auth.html"
            let oneLoginSSOAuthUrl = "https://mqa2.xavlab.xyz/auth.html"
            let parentHost = "widget-mqa2.xavlab.xyz"
            return EnvironmentDetails(apiUrl, xmppHost, xmppPort, ssoAuthUrl, parentHost, oneLoginSSOAuthUrl)
        case .stage:
            let apiUrl = "https://kb.xavlab.xyz"
            let xmppHost = "34.67.248.68"
            let xmppPort = "5222"
            let ssoAuthUrl = "https://widget-kb.xavlab.xyz/auth.html"
            let oneLoginSSOAuthUrl = "https://kb.xavlab.xyz/auth.html"
            let parentHost = "widget-kb.xavlab.xyz"
            return EnvironmentDetails(apiUrl, xmppHost, xmppPort, ssoAuthUrl, parentHost, oneLoginSSOAuthUrl)
        /// SARA  TIP Bot
        case .tiiaProd:
            let apiUrl = "https://wbot.itia.ai"
            let xmppHost = "34.172.134.116"
            let xmppPort = "5222"
            let ssoAuthUrl = "https://widget.bot.itia.ai"
            let oneLoginSSOAuthUrl = "https://bot.itia.ai/auth.html"
            let parentHost = "widget.bot.itia.ai"
            return EnvironmentDetails(apiUrl, xmppHost, xmppPort, ssoAuthUrl, parentHost, oneLoginSSOAuthUrl)

        case .tvaProd:
            let apiUrl = "https://tva.tiia.ai"
            let xmppHost = "wss://tva.tiia.ai/ws"
            let xmppPort = "5222"
            let ssoAuthUrl = "https://w-tva.tiia.ai/auth.html"
            let oneLoginSSOAuthUrl = "https://tva.tiia.ai/auth.html"
            let parentHost = "w-tva.tiia.ai"
            return EnvironmentDetails(apiUrl, xmppHost, xmppPort, ssoAuthUrl, parentHost, oneLoginSSOAuthUrl)

        case .kvaProd:
            let apiUrl = "https://kva.tiia.ai"
            let xmppHost = "wss://kva.tiia.ai/ws"
            let xmppPort = "5222"
            let ssoAuthUrl = "https://w-kva.tiia.ai/auth.html"
            let oneLoginSSOAuthUrl = "https://kva.tiia.ai/auth.html"
            let parentHost = "w-kva.tiia.ai"
            return EnvironmentDetails(apiUrl, xmppHost, xmppPort, ssoAuthUrl, parentHost, oneLoginSSOAuthUrl)

        case .chatGPT:
            let apiUrl = "https://widget-demo.itia.ai"
            let xmppHost = "35.224.164.189"
            let xmppPort = "5222"
            let ssoAuthUrl = ""
            let oneLoginSSOAuthUrl = ""
            let parentHost = ""
            return EnvironmentDetails(apiUrl, xmppHost, xmppPort, ssoAuthUrl, parentHost, oneLoginSSOAuthUrl)
            
        case .custom(let api, let host, let port):
            let apiUrl = api.last == "/" ? String(api.dropLast()) : api
            let apiSeperated = apiUrl.components(separatedBy: "://")
            let xmppHost = host
            let port = port
            var ssoAuthUrl = ""
            var parentHost = ""
            var oneLoginSSOAuthUrl = ""
            if !apiSeperated.isEmpty && apiSeperated.count > 1 {
                ssoAuthUrl = (apiSeperated.first ?? "") + "://widget-" + apiSeperated[1] + "/auth.html"
                parentHost = "widget-" + apiSeperated[1]
                oneLoginSSOAuthUrl = apiUrl + "/auth.html"
            }
            return EnvironmentDetails(apiUrl, xmppHost, port, ssoAuthUrl, parentHost, oneLoginSSOAuthUrl)
        }
    }
}
