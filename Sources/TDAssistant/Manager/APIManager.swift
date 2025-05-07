//  APIManager.swift
//  Copyright © 2024 Telus Digital. All rights reserved.

import Foundation
import UIKit

class APIManager {

    /// ApiEndPoint Enum
    enum ApiEndPoint: String {
        case getConfiguration = "/api/v2/config/bot/"
        case getSuggestion = "/genbot/SERVICE_NAME/bot/autocomplete/v1"/// SERVICE_NAME will be replaced with the value we are getting in config api under nlu_service.
        case postTranscript = "/api/account/chat/history"
    }
    // end

    static let sharedInstance = APIManager()
    

    // MARK: - Initiliazation
    private init() {
    }
    // end
    
    func getUrlSession() -> URLSession {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 30.0
        return URLSession(configuration: sessionConfig)
    }

    // MARK: - Get Configuration
    /// This function is used to call the api and get the configuration data from server.
    ///  It contails all the infomation required to run the chatbot whether it is UI related,
    /// SSO related, feedback related etc.
    /// - Parameters:
    ///   - successBlock: successBlock returns VAConfigurationModel
    ///   - failureBlock: failureBlock returns Error (String)
    func getConfiguration(successBlock: @escaping (_ response: VAConfigurationModel?) -> Void, failureBlock: @escaping (_ error: String, _ isRetry: Bool) -> Void) {
        let url = URL(string: "\(VAConfigurations.apiBaseURL)\(ApiEndPoint.getConfiguration.rawValue)\(VAConfigurations.botId)")
        let session = getUrlSession()
        session.dataTask(with: url!, completionHandler: { (data, _, error) in
            if error != nil {
                failureBlock(error?.localizedDescription ?? "Error", false)
            } else {
                do {
                    let configData = try JSONDecoder().decode(VAConfigurationModel.self, from: data!)
                    if configData.status == "ok"{
                        successBlock(configData)
                    } else {
                        failureBlock(LanguageManager.shared.localizedString(forKey: "Failure"), true)
                    }
                } catch let error as NSError {
                    failureBlock(error.description, false)
                }
            }
        }).resume()
    }
    // end

    /// This api retuns suggestion related to user typed text.
    /// - Parameters:
    ///   - service: This defines from where we want to get suggestions whether it is nlu1 or s0
    ///   - text: user typed text
    ///   - contextId: Id of context for which we need suggestion
    ///   - languageCode: current language code
    ///   - successBlock: success block returns the response after successful execution of api
    ///   - failureBlock: returns error while executing api
    func getSuggestion(service: String, text: String, contextId: Int, languageCode: String,
                       successBlock: @escaping (_ response: [Suggestion]?) -> Void,
                       failureBlock: @escaping (_ error: String) -> Void) {
        let textString = text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        let apiEndPoint = ApiEndPoint.getSuggestion.rawValue.replacingOccurrences(of: "SERVICE_NAME", with: service)
        let url = URL(string: "\(VAConfigurations.apiBaseURL)\(apiEndPoint)?bot_uid=\(VAConfigurations.botId)&language=\(languageCode)&text=" + textString + "&context_id=\(contextId)")
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, _, error) in
            if error != nil {
                debugPrint("error")
            } else {
//                if let data = data {
//                    let response = String(decoding: data, as: UTF8.self)
//                    print(response)
//                }
                do {
                    let configData = try JSONDecoder().decode([Suggestion].self, from: data!)
                    if configData.count != 0 {
                        successBlock(configData)
                    } else {
                        failureBlock("Auto complete Failure")
                    }
                } catch let error as NSError {
                    failureBlock(error.description)
                }
            }
        }).resume()
    }

    /// This api is used to send transcript of chat to user's provided email address
    /// - Parameters:
    ///   - botId: id of bot used for conversation
    ///   - email: email address where chat transcript will be sent
    ///   - language: current bot language
    ///   - sessionId: session id of the chat
    ///   - user: JID used in chat
    ///   - resultString: response from api after execution
    func postTranscript(botId: String,
                        email: String,
                        language: String,
                        sessionId: String,
                        user: String,
                        resultString: @escaping (_ resultStr: String) -> Void) {

        let parameters = ["bot_id": botId,
                          "email": email,
                          "lang": language,
                          "session_id": Int(sessionId) ?? 0,
                          "user": user,
                          "channel": "mobile",
                          "device": "mobile",
                          "version": UIDevice.current.systemVersion, "os": "iOS"] as [String: Any]

        let url = URL(string: "\(VAConfigurations.apiBaseURL)\(ApiEndPoint.postTranscript.rawValue)")!
        let session = URLSession.shared

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            resultString(error.localizedDescription)
            debugPrint(error.localizedDescription)
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, _, error in

            guard error == nil else {
                resultString(error?.localizedDescription ?? "")
                return
            }
            guard let data = data else {
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    // debugPrint(json)
                    if json["status"] as? String ?? "" == "ok" {
                        resultString((json["result"] as? [String: Any])?["message"] as? String ?? "")
                    } else if json["status"] as? String ?? "" == "err" {
                        let apiError = ((json["result"] as? [String: Any])?["errors"] as? [String])?.first ?? LanguageManager.shared.localizedString(forKey: "Unable to send chat transcript.")
                        resultString(apiError)
                    } else {
                        resultString(LanguageManager.shared.localizedString(forKey: "Unable to send chat transcript."))
                    }
                }
            } catch let error {
                resultString(error.localizedDescription)
                debugPrint(error.localizedDescription)
            }
        })
        task.resume()
    }

    /// This api is used to submit feedback provided by user after chat
    /// - Parameters:
    ///   - reason: It defines reasons based on your current selected score/rating.
    ///   - score: Rating selected by user. It can range from 1-10 in numeric and happy to sad in emoji representation. 
    ///   It is sent to server in numeric format
    ///   - feedback: feedback provided by user
    ///   - issue_resolved: defined whether issue is resolved or not: true/false
    ///   - resultString: response from api after execution
    func submitNPSSurveyFeedback(reason: [String],
                                 score: Int,
                                 feedback: String,
                                 issueResolved: String,
                                 resultString: @escaping (_ resultStr: String) -> Void) {

        var parameters = ["reason": reason,
                          "score": score,
                          "feedback": feedback,
                          "issue_resolved": issueResolved] as [String: Any]

        parameters["session"] = VAConfigurations.userJid
        parameters["segment"] = "bot"
        parameters["kind"] = "mobile"
        parameters["bot_id"] = VAConfigurations.botId
        parameters["lang"] = VAConfigurations.getCurrentLanguageCode()
        let sessionId = UserDefaultsManager.shared.getSessionID()
        parameters["session_id"] = Int(sessionId)
        parameters["channel"] = "mobile"
        parameters["device"] = "mobile"
        parameters["version"] = UIDevice.current.systemVersion
        parameters["os"] = "iOS"
        if VAConfigurations.isChatTool {
            parameters["technician_name"] = VAConfigurations.customData?.userName
            parameters["queue_id"] = VAConfigurations.customData?.extraData["queue"]
        }
        // debugPrint(parameters)

        let url = VAConfigurations.isChatTool ? URL(string: "\(VAConfigurations.apiBaseURL)/api/v1/queue-feedback")! : URL(string: "\(VAConfigurations.apiBaseURL)/api/v2/nps")!
        // debugPrint(url)

        let session = URLSession.shared

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            resultString(error.localizedDescription)
            debugPrint(error.localizedDescription)
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        debugPrint(request)

        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, _, error in
            guard error == nil else {
                resultString(error?.localizedDescription ?? "")
                return
            }
            guard let data = data else {
                return
            }
            do {
                if let _ = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    // debugPrint(json)
                    resultString(LanguageManager.shared.localizedString(forKey: "Feedback successfully posted."))
                }
            } catch let error {
                resultString(error.localizedDescription)
                debugPrint(error.localizedDescription)
            }
        })
        task.resume()
    }
}
