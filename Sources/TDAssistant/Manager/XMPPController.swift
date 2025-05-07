//  XMPPController.swift
//  Created by Andres on 7/21/16.
//  Copyright © 2016 Andres. All rights reserved.

import Foundation
import XMPPFramework
import SwiftyXMLParser

/// Tutorial link:
/// https://mongooseim.readthedocs.io/en/3.4.0/user-guide/iOS_tutorial/
/// https://esl.github.io/MongooseDocs/3.7.1/user-guide/iOS_tutorial/

/// XMPPControllerError enum
enum XMPPControllerError: Error {
    case wrongUserJID
}

class XMPPController: NSObject {
    // Object declaration of xmppcontroller class
    var xmppStream: XMPPStream
    let xmppRosterStorage = XMPPRosterCoreDataStorage.sharedInstance()
    var xmppRoster: XMPPRoster!
    var xmppReconnect: XMPPReconnect

    let hostName: String
    let userJID: XMPPJID
    let hostPort: UInt16
    let password: String

    init(hostName: String, userJIDString: String, hostPort: UInt16 = UInt16(VAConfigurations.XMPPHostPort)!, password: String) throws {
        guard let userJID = XMPPJID(string: userJIDString) else {
            throw XMPPControllerError.wrongUserJID
        }
        self.hostName = hostName
        self.userJID = userJID
        self.hostPort = hostPort
        self.password = password

        // Stream Configuration
        self.xmppStream = XMPPStream()
        self.xmppStream.hostName = hostName
        self.xmppStream.hostPort = hostPort
        self.xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicy.allowed
        self.xmppStream.myJID = userJID
        self.xmppStream.keepAliveInterval = 80///seconds

        self.xmppReconnect = XMPPReconnect()
        self.xmppReconnect.autoReconnect = true
        self.xmppReconnect.reconnectDelay = DEFAULT_XMPP_RECONNECT_DELAY
                
        super.init()
        self.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        self.xmppReconnect.addDelegate(self, delegateQueue: DispatchQueue.main)
    }

    /// This function is used to connect with xmpp server
    func connect() {
        if !self.xmppStream.isDisconnected {
            return
        }
        try? self.xmppStream.connect(withTimeout: 30)
    }
}

// MARK: XMPPStreamDelegate
extension XMPPController: XMPPStreamDelegate {
    func xmppStreamDidConnect(_ stream: XMPPStream) {
        let auth = XMPPPlainAuthentication(stream: stream, password: self.password)
        try? stream.authenticate(auth)
    }

    func xmppStreamDidRegister(_ stream: XMPPStream) {
        debugPrint("xmppStreamDidRegister ====== Stream: Connected")
    }

    func xmppStream(_ sender: XMPPStream, didNotRegister error: DDXMLElement) {
        debugPrint("didNotRegister========\(error.description)")
    }

    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        debugPrint("xmppStreamDidAuthenticate ===== Stream: Authenticated")
        self.xmppStream.send(XMPPPresence())
    }

    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
        debugPrint("Stream: Fail to Authenticate")
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        let presenceType = presence.type
        let username = sender.myJID?.user
        let presenceFromUser = presence.from?.user
        if presenceFromUser != username {
            if presenceType == "subscribe" {
                self.xmppRoster.subscribePresence(toUser: presence.from!)
            }
        }
    }
}

// MARK: XMPPReconnectDelegate
extension XMPPController: XMPPReconnectDelegate {
    func xmppReconnect(_ sender: XMPPReconnect, didDetectAccidentalDisconnect connectionFlags: SCNetworkConnectionFlags) {
        debugPrint("xmppReconnect - didDetectAccidentalDisconnect")
    }

    func xmppReconnect(_ sender: XMPPReconnect, shouldAttemptAutoReconnect connectionFlags: SCNetworkConnectionFlags) -> Bool {
        debugPrint("xmppReconnect - shouldAttemptAutoReconnect")
        return true
    }
}
