//  VAChatView+SpeechRecognizer.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import Foundation
import AVFoundation
import Speech
import AVKit

// MARK: - Speech to text implementation
extension VAChatViewController {

    func checkSpeechPermissions() {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .notDetermined:
            self.requestSpeechRecognizerPermission()
        case .denied, .restricted:
            self.showPermissionDeclinedAlert(title: LanguageManager.shared.localizedString(forKey: "Permission Denied"), message: LanguageManager.shared.localizedString(forKey: "Speech recognition permission is declined. Please allow access from settings."))
        case .authorized:
            self.checkMicrophonePermission()
        @unknown default:
            break
        }
    }
    
    func requestSpeechRecognizerPermission() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.checkMicrophonePermission()
                case .notDetermined:
                    self.requestSpeechRecognizerPermission()
                case .denied, .restricted:
                    self.showPermissionDeclinedAlert(title: LanguageManager.shared.localizedString(forKey: "Permission Denied"), message: LanguageManager.shared.localizedString(forKey: "Speech recognition permission is declined. Please allow access from settings."))
                @unknown default:
                    break
                }
            }
        }
    }
    
    func checkMicrophonePermission() {
        switch self.audioSession.recordPermission {
        case .undetermined:
            self.audioSession.requestRecordPermission { granted in
                if granted {
                    self.enableSpeechMode()
                }
            }
        case .denied:
            self.showPermissionDeclinedAlert(title: LanguageManager.shared.localizedString(forKey: "Permission Denied"), message: LanguageManager.shared.localizedString(forKey: "Mike permission is declined. Please allow access from settings."))
        case .granted:
            self.enableSpeechMode()
        @unknown default:
            break
        }
    }
    
    func showPermissionDeclinedAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: LanguageManager.shared.localizedString(forKey: "Settings"), style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: LanguageManager.shared.localizedString(forKey: "Cancel"), style: .cancel)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    func enableSpeechMode() {
        self.isListeningToSpeech = true
        do {
            // try audioSession.setCategory(AVAudioSession.Category.record, mode: AVAudioSession.Mode.measurement, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.microphoneImage.tintColor = self.isNewGenAITheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.themeTextIconColor
            self.startListeningToSpeech()
        }
    }
    
    func startListeningToSpeech() {
        self.startRecording()
        self.txtViewMessage.endEditing(true)
    }

    func startRecording() {
        // Clear all previous session data and cancel task
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask?.finish()
            recognitionTask = nil
        }
        //Audio session
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        self.recognitionRequest?.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }

        self.recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal = false
            if result != nil {
                self.filterCommandsFromTranscriptedTextIfAvailable(transcriptionStr: result?.bestTranscription.formattedString ?? "")
                isFinal = (result?.isFinal)!
            }
            if error != nil || isFinal {
                self.disableSpeechMode()
                // self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        /*let inputNode = audioEngine.inputNode
        let sampleRate = inputNode.inputFormat(forBus: 0).sampleRate // the default sample rate from mic is 48000
        let channelCount = inputNode.inputFormat(forBus: 0).channelCount // 1
        let recordingFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: channelCount, interleaved: false)*/

        // FIXME: - Mike crash issue fixation
         let recordingFormat = inputNode.outputFormat(forBus: 0)
        // let recordingFormat = inputNode.inputFormat(forBus: 0)
        // let recordingFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
        //if recordingFormat.sampleRate > 0 {
            inputNode.reset()
            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
                self.recognitionRequest?.append(buffer)
            }
        //}
        if !audioEngine.isRunning {
            self.audioEngine.prepare()
            do {
                try self.audioEngine.start()
            } catch {
                print("audioEngine couldn't start because of an error.")
            }
        }
    }
    
    func disableSpeechMode() {
        DispatchQueue.main.async {
            self.invalidateSpeechDelayTimer()
            if self.audioEngine.isRunning {
                self.audioEngine.stop()
                self.recognitionRequest?.endAudio()
            }
            if self.recognitionTask != nil {
                self.recognitionTask?.cancel()
                self.recognitionTask?.finish()
                self.recognitionTask = nil
            }
        }
        self.isListeningToSpeech = false
        self.microphoneImage.tintColor = .lightGray
    }
    
    @objc func stopListeningToSpeech() {
        if translatedText != "" {
            self.btnSendMessageTapped(UIButton())
        }
    }
    
    func filterCommandsFromTranscriptedTextIfAvailable(transcriptionStr: String) {
        switch transcriptionStr.lowercased() {
        case "clear context", "clear flow", "reset context":
            self.speechCommandToClearContext()
        case "change channel to mobile", "change channel mobile":
            self.speechCommandToChangeChannel("mobile")
        case "close chatbot", "close chat bot", "close chat-bot", "close bot":
            self.speechCommandToCloseChatbot()
        case "change language to english", "please change language to english":
            let isLanguageEnabledFromAdmin = VAConfigurations.arrayOfLanguages.filter({$0.displayName?.lowercased() == "english"}).count > 0
            if isLanguageEnabledFromAdmin {
                self.utterTheText("Bot language changed to english")
                self.speechCommandToChangeLanguage("english")
            }
        case "change language to french", "please change language to french":
            let isLanguageEnabledFromAdmin = VAConfigurations.arrayOfLanguages.filter({$0.displayName?.lowercased() == "french"}).count > 0
            if isLanguageEnabledFromAdmin {
                self.utterTheText("Bot language changed to french")
                self.speechCommandToChangeLanguage("french")
            }
        case "change language to chinese simplified", "change language to chinese-simplified", "change language to simplified-chinese", "change language to simplified chinese", "please change language to chinese simplified", "please change language to chinese-simplified", "please change language to simplified-chinese", "please change language to simplified chinese":
            let isLanguageEnabledFromAdmin = VAConfigurations.arrayOfLanguages.filter({$0.displayName?.lowercased() == "simplified chinese"}).count > 0
            if isLanguageEnabledFromAdmin {
                self.utterTheText("Bot language changed to simplified chinese")
                self.speechCommandToChangeLanguage("simplified chinese")
            }
        case "change language to chinese traditional", "change language to chinese-traditional", "change language to traditional-chinese", "change language to traditional chinese", "please change language to chinese traditional", "please change language to chinese-traditional", "please change language to traditional-chinese", "please change language to traditional chinese":
            let isLanguageEnabledFromAdmin = VAConfigurations.arrayOfLanguages.filter({$0.displayName?.lowercased() == "traditional chinese"}).count > 0
            if isLanguageEnabledFromAdmin {
                self.utterTheText("Bot language changed to traditional chinese")
                self.speechCommandToChangeLanguage("traditional chinese")
            }
        case "change language to german", "please change language to german":
            let isLanguageEnabledFromAdmin = VAConfigurations.arrayOfLanguages.filter({$0.displayName?.lowercased() == "german"}).count > 0
            if isLanguageEnabledFromAdmin {
                self.utterTheText("Bot language changed to german")
                self.speechCommandToChangeLanguage("german")
            }
        case "change language to spanish", "please change language to spanish":
            let isLanguageEnabledFromAdmin = VAConfigurations.arrayOfLanguages.filter({$0.displayName?.lowercased() == "spanish"}).count > 0
            if isLanguageEnabledFromAdmin {
                self.utterTheText("Bot language changed to spanish")
                self.speechCommandToChangeLanguage("spanish")
            }
        case "change language to dutch", "please change language to dutch":
            let isLanguageEnabledFromAdmin = VAConfigurations.arrayOfLanguages.filter({$0.displayName?.lowercased() == "dutch"}).count > 0
            if isLanguageEnabledFromAdmin {
                self.utterTheText("Bot language changed to dutch")
                self.speechCommandToChangeLanguage("dutch")
            }
        case "change language to tagalog", "please change language to tagalog", "change language to filipino", "please change language to filipino":
            let isLanguageEnabledFromAdmin = VAConfigurations.arrayOfLanguages.filter({$0.displayName?.lowercased() == "tagalog"}).count > 0
            if isLanguageEnabledFromAdmin {
                self.utterTheText("Bot language changed to tagalog")
                self.speechCommandToChangeLanguage("tagalog")
            }
        case "change language to turkish", "please change language to turkish":
            let isLanguageEnabledFromAdmin = VAConfigurations.arrayOfLanguages.filter({$0.displayName?.lowercased() == "turkish"}).count > 0
            if isLanguageEnabledFromAdmin {
                self.utterTheText("Bot language changed to turkish")
                self.speechCommandToChangeLanguage("turkish")
            }
        case "change language to punjabi", "please change language to punjabi":
            let isLanguageEnabledFromAdmin = VAConfigurations.arrayOfLanguages.filter({$0.displayName?.lowercased() == "punjabi"}).count > 0
            if isLanguageEnabledFromAdmin {
                self.utterTheText("Bot language changed to punjabi")
                self.speechCommandToChangeLanguage("punjabi")
            }
        case "change language to japanese", "please change language to japanese":
            let isLanguageEnabledFromAdmin = VAConfigurations.arrayOfLanguages.filter({$0.displayName?.lowercased() == "japanese"}).count > 0
            if isLanguageEnabledFromAdmin {
                self.utterTheText("Bot language changed to japanese")
                self.speechCommandToChangeLanguage("japanese")
            }
        case "change language to persian", "please change language to persian":
            let isLanguageEnabledFromAdmin = VAConfigurations.arrayOfLanguages.filter({$0.displayName?.lowercased() == "persian"}).count > 0
            if isLanguageEnabledFromAdmin {
                self.utterTheText("Bot language changed to persian")
                self.speechCommandToChangeLanguage("persian")
            }
        default:
            self.sendTranscriptedTextToBotForProcessing(transcriptionStr)
        }
    }
    func sendTranscriptedTextToBotForProcessing(_ transcriptionStr: String) {
        if transcriptionStr != self.translatedText {
            self.translatedText = transcriptionStr
            if self.viewModel.messageData?.masked ?? false {
                if self.viewModel.isSecured == true {
                    self.txtViewMessage.text = String(repeating: "•", count: self.translatedText.count)
                } else {}
                if self.txtViewMessage.text.count < self.viewModel.textViewOriginalText.count {
                    if self.viewModel.textViewOriginalText.count > 0 {
                        self.viewModel.textViewOriginalText.removeLast()
                    }
                }
            } else {
                self.txtViewMessage.text = transcriptionStr
            }
            self.viewModel.textViewOriginalText = transcriptionStr
            self.txtViewMessage.textColor = VAColorUtility.black
            self.restartSpeechDelayTimer()
            self.setCircularProgressForEnteredText(message: self.txtViewMessage.text)
        }
    }

    func invalidateSpeechDelayTimer() {
        if self.speechDelayTimer?.isValid ?? true {
            self.speechDelayTimer?.invalidate()
            self.speechDelayTimer = nil
        }
    }

    func restartSpeechDelayTimer() {
        self.invalidateSpeechDelayTimer()
        let fireDate = Date().addingTimeInterval(TimeInterval(1.0))
        self.speechDelayTimer = Timer(fireAt: fireDate, interval: 1.0, target: self, selector: #selector(self.stopListeningToSpeech), userInfo: nil, repeats: true)
        RunLoop.main.add(self.speechDelayTimer!, forMode: RunLoop.Mode.common)
    }

    func speechCommandToClearContext() {
        print("speechCommandToClearContext")
        self.utterTheText("Bot context cleared")
        self.disableSpeechMode()
        if self.viewModel.configurationModel?.result?.resetContext ?? false {
            self.btnRefreshTapped(UIButton())
        }
    }

    func speechCommandToChangeChannel(_ channel: String) {
        print("speechCommandToChangeChannel")
        self.utterTheText("Channel changed to \(channel)")
        self.disableSpeechMode()
        self.resetMessageInputView()
    }

    func speechCommandToCloseChatbot() {
        print("speechCommandToCloseChatbot")
        self.disableSpeechMode()
        self.btnCloseTapped(UIButton())
    }

    func speechCommandToChangeLanguage(_ language: String) {
        print("speechCommandToChangeLanguage")
        self.disableSpeechMode()
        self.resetMessageInputView()
        DispatchQueue.main.async {
            let oldSelectedLanguage = self.getCurrentLanguage().lowercased()
            if language.lowercased() == "english" {
                VAConfigurations.language = .english
            } else if language.lowercased() == "traditional chinese" {
                VAConfigurations.language = .chineseTraditional
            } else if language.lowercased() == "simplified chinese" {
                VAConfigurations.language = .chineseSimplified
            } else if language.lowercased() == "french" {
                VAConfigurations.language = .french
            } else if language.lowercased() == "german" {
                VAConfigurations.language = .german
            } else if language.lowercased() == "spanish" {
                VAConfigurations.language = .spanish
            } else if language.lowercased() == "dutch"{
                VAConfigurations.language = .dutch
            } else if language.lowercased() == "tagalog"{
                VAConfigurations.language = .tagalog
            } else if language.lowercased() == "turkish"{
                VAConfigurations.language = .turkish
            } else if language.lowercased() == "punjabi"{
                VAConfigurations.language = .punjabi
            } else if language.lowercased() == "japanese"{
                VAConfigurations.language = .japanese
            } else if language.lowercased() == "persian"{
                VAConfigurations.language = .persian
            }
            if oldSelectedLanguage != language {
                UserDefaultsManager.shared.setBotLanguage(VAConfigurations.language?.rawValue ?? "")
                NotificationCenter.default.post(name: Notification.Name("LanguageChangedFromSettings"), object: nil)
                self.setLocalization()
            }
        }
    }
    func getCurrentLanguage() -> String {
        let filteredData = VAConfigurations.arrayOfLanguages.filter { languageModel in
            if languageModel.lang == VAConfigurations.getCurrentLanguageCode() {
                return true
            } else {
                return false
            }
        }
        if filteredData.count > 0 {
            return filteredData[0].displayName ?? "English"
        } else {
            return "English"
        }
    }
    func resetMessageInputView() {
        self.searchedText = ""
        self.txtViewMessage.resignFirstResponder()
        self.txtViewMessage.text = self.viewModel.defaultPlaceholder
        self.txtViewMessage.textColor = VAColorUtility.defaultThemeTextIconColor
        self.setCircularProgress()
    }

    /// Text to speech
    func utterTheText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        // utterance.voice = AVSpeechSynthesisVoice(language: "en-US")//en-US,en-GB
        utterance.rate = 0.5// AVSpeechUtteranceDefaultSpeechRate
        utterance.volume = 0.75
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.speechSynthesizer.speak(utterance)
        }
    }
}

// MARK: SFSpeechRecognizerDelegate
extension VAChatViewController: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
    }
}

// MARK: AVSpeechSynthesizerDelegate
extension VAChatViewController: AVSpeechSynthesizerDelegate {

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.speechToTextButton.isEnabled = true
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        self.speechToTextButton.isEnabled = false
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        self.speechToTextButton.isEnabled = true
    }
}
