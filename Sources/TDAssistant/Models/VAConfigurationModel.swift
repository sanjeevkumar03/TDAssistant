//  VAConfigurationModel.swift
//  Copyright © 2024 Telus Digital. All rights reserved.

import Foundation
/// Configuration api model 
struct VAConfigurationModel: Codable {
    let status: String?
    let result: VAConfigResultModel?
    let meta: VAConfigMetaModel?

    enum CodingKeys: String, CodingKey {
        case status
        case result
        case meta = "_meta"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        result = try values.decodeIfPresent(VAConfigResultModel.self, forKey: .result)
        meta = try values.decodeIfPresent(VAConfigMetaModel.self, forKey: .meta)
    }
}

struct VAConfigMetaModel: Codable {
    let ip: String?

    enum CodingKeys: String, CodingKey {
        case ip
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        ip = try values.decodeIfPresent(String.self, forKey: .ip)
    }
}

struct VAConfigResultModel: Codable {
    let uid: String?
    let name: String?
    let note: String?
    let wlcmMsg: String?
    let timezone: String?
    let confidence: Int?
    let lifeSpan: Int?
    let flatNlu: Bool?
    let avatar: String?
    let headerLogo: String?
    let bgImg: String?
    let theme: String?
    let btnTheme: String?
    let themeColor: String?
    let language: [VAConfigLanguage]?
    let vhost: String?
    let broker: String?
    let jid: String?
    let nluBackend: String?
    let genAIApiTimeout: Int?
    let autoReply: Bool?
    let autoReplyCount: Int?
    let resetContext: Bool?
    let nluService: String?
    let nluDns: String?
    let nluTrainedStatus: Bool?
    let quickReply: Bool?
    let quickReplyVisited: Bool?
    let smallTalk: Bool?
    let autoLangDetection: Bool?
    let offTheRecord: Bool?
    let additionalSecurity: Bool?
    let chatHistory: Bool?
    let enableNps: Bool?
    let enableAvatar: Bool?
    let emailConv: Bool?
    let feedbackMsg: VAConfigFeedback?
    let autoReplyMsg: VAConfigAutoReplyMsg?
    let pId: String?
    let botKind: String?
    let enableFeedback: Bool?
    let createdBy: Int?
    let updatedAt: String?
    let updatedBy: Int?
    let ips: VAConfigIPS?
    let translateWidget: Bool?
    let syncedAt: String?
    let trainedAt: String?
    let trained: Bool?
    let sso: Bool?
    let ssoAuthUrl: String?
    let redirectUrl: String?
    let ssoType: String?
    let integration: [VAConfigIntegration]?
    let npsSettings: VAConfigNPSSettings?
    let ssoActive: Bool?
    let platformType: String?
    let botUid: String?
    let botId: Int?
    let projectId: String?
    let privateKey: String?
    let clientEmail: String?
    let tokenUrl: String?
    let connectionAllowed: Bool?
    let connectionFullMsg: VAConfigConnectionFullMsg?
    let reconnectionTimer: Int?
    var customForm: CustomForm?
    let enableCitation: Bool?
    let enableRelatedQueries: Bool?
    let genAISettings: GenAISettings?
    let genAITextFeedback: Bool?
    let genAIThumbsFeedback: Bool?
    let genAINewTheme: Bool?
    let genAITypeWritingEffect: Bool?
    let genAITypeWritingEffectSpeed: Int?

    enum CodingKeys: String, CodingKey {
        case uid
        case name
        case note
        case wlcmMsg = "wlcm_msg"
        case timezone
        case confidence
        case lifeSpan = "life_span"
        case flatNlu = "flat_nlu"
        case avatar
        case headerLogo = "header_logo"
        case bgImg = "bg_img"
        case theme
        case btnTheme = "btn_theme"
        case themeColor = "theme_colour"
        case language
        case vhost
        case broker
        case jid
        case nluBackend = "nlubackend"
        case genAIApiTimeout = "gen_ai_api_timeout"
        case autoReply = "auto_reply"
        case autoReplyCount = "auto_reply_count"
        case resetContext = "reset_context"
        case nluService = "nlu_service"
        case nluDns = "nlu_dns"
        case nluTrainedStatus = "nlu_trained_status"
        case quickReply = "quick_reply"
        case quickReplyVisited = "quick_reply_visited"
        case smallTalk = "small_talk"
        case autoLangDetection = "auto_lang_detection"
        case offTheRecord = "off_the_record"
        case additionalSecurity = "additional_security"
        case chatHistory = "chat_history"
        case enableNps = "enable_nps"
        case enableAvatar = "enable_avatar"
        case emailConv = "email_conv"
        case feedbackMsg = "feedback_msg"
        case autoReplyMsg = "auto_reply_msg"
        case pId = "p_id"
        case botKind = "bot_kind"
        case enableFeedback = "enable_feedback"
        case createdBy = "created_by"
        case updatedAt = "updated_at"
        case updatedBy = "updated_by"
        case ips
        case translateWidget = "translate_widget"
        case syncedAt = "synced_at"
        case trainedAt = "trained_at"
        case trained
        case sso
        case ssoAuthUrl = "sso_auth_url"
        case redirectUrl = "redirect_url"
        case ssoType = "sso_type"
        case integration
        case npsSettings = "nps_settings"
        case ssoActive = "sso_active"
        case platformType = "platform_type"
        case botUid = "bot_uid"
        case botId = "bot_id"
        case projectId = "project_id"
        case privateKey = "private_key"
        case clientEmail = "client_email"
        case tokenUrl = "token_url"
        case connectionAllowed = "connection_allowed"
        case connectionFullMsg = "connection_full_msg"
        case reconnectionTimer = "reconnection_timer"
        case customForm = "custom_form"
        case enableCitation = "enable_citation"
        case enableRelatedQueries = "enable_related_queries"
        case genAISettings = "gen_ai_settings"
        case genAITextFeedback = "gen_ai_text_feedback"
        case genAIThumbsFeedback = "gen_ai_thumbs_feedback"
        case genAINewTheme = "new_gen_ai_card_interface"
        case genAITypeWritingEffect = "enable_genai_type_writing"
        case genAITypeWritingEffectSpeed = "typing_speed"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uid = try values.decodeIfPresent(String.self, forKey: .uid)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        note = try values.decodeIfPresent(String.self, forKey: .note)
        wlcmMsg = try values.decodeIfPresent(String.self, forKey: .wlcmMsg)
        timezone = try values.decodeIfPresent(String.self, forKey: .timezone)
        confidence = try values.decodeIfPresent(Int.self, forKey: .confidence)
        lifeSpan = try values.decodeIfPresent(Int.self, forKey: .lifeSpan)
        flatNlu = try values.decodeIfPresent(Bool.self, forKey: .flatNlu)
        avatar = try values.decodeIfPresent(String.self, forKey: .avatar)
        headerLogo = try values.decodeIfPresent(String.self, forKey: .headerLogo)
        bgImg = try values.decodeIfPresent(String.self, forKey: .bgImg)
        theme = try values.decodeIfPresent(String.self, forKey: .theme)
        btnTheme = try values.decodeIfPresent(String.self, forKey: .btnTheme)
        themeColor = try values.decodeIfPresent(String.self, forKey: .themeColor)
        language = try values.decodeIfPresent([VAConfigLanguage].self, forKey: .language)
        vhost = try values.decodeIfPresent(String.self, forKey: .vhost)
        broker = try values.decodeIfPresent(String.self, forKey: .broker)
        jid = try values.decodeIfPresent(String.self, forKey: .jid)
        nluBackend = try values.decodeIfPresent(String.self, forKey: .nluBackend)
        genAIApiTimeout = try values.decodeIfPresent(Int.self, forKey: .genAIApiTimeout)
        autoReply = try values.decodeIfPresent(Bool.self, forKey: .autoReply)
        autoReplyCount = try values.decodeIfPresent(Int.self, forKey: .autoReplyCount)
        resetContext = try values.decodeIfPresent(Bool.self, forKey: .resetContext)
        nluService = try values.decodeIfPresent(String.self, forKey: .nluService)
        nluDns = try values.decodeIfPresent(String.self, forKey: .nluDns)
        nluTrainedStatus = try values.decodeIfPresent(Bool.self, forKey: .nluTrainedStatus)
        quickReply = try values.decodeIfPresent(Bool.self, forKey: .quickReply)
        quickReplyVisited = try values.decodeIfPresent(Bool.self, forKey: .quickReplyVisited)
        smallTalk = try values.decodeIfPresent(Bool.self, forKey: .smallTalk)
        autoLangDetection = try values.decodeIfPresent(Bool.self, forKey: .autoLangDetection)
        offTheRecord = try values.decodeIfPresent(Bool.self, forKey: .offTheRecord)
        additionalSecurity = try values.decodeIfPresent(Bool.self, forKey: .additionalSecurity)
        chatHistory = try values.decodeIfPresent(Bool.self, forKey: .chatHistory)
        enableNps = try values.decodeIfPresent(Bool.self, forKey: .enableNps)
        enableAvatar = try values.decodeIfPresent(Bool.self, forKey: .enableAvatar)
        emailConv = try values.decodeIfPresent(Bool.self, forKey: .emailConv)
        feedbackMsg = try values.decodeIfPresent(VAConfigFeedback.self, forKey: .feedbackMsg)
        autoReplyMsg = try values.decodeIfPresent(VAConfigAutoReplyMsg.self, forKey: .autoReplyMsg)
        pId = try values.decodeIfPresent(String.self, forKey: .pId)
        botKind = try values.decodeIfPresent(String.self, forKey: .botKind)
        enableFeedback = try values.decodeIfPresent(Bool.self, forKey: .enableFeedback)
        createdBy = try values.decodeIfPresent(Int.self, forKey: .createdBy)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        updatedBy = try values.decodeIfPresent(Int.self, forKey: .updatedBy)
        ips = try values.decodeIfPresent(VAConfigIPS.self, forKey: .ips)
        translateWidget = try values.decodeIfPresent(Bool.self, forKey: .translateWidget)
        syncedAt = try values.decodeIfPresent(String.self, forKey: .syncedAt)
        trainedAt = try values.decodeIfPresent(String.self, forKey: .trainedAt)
        trained = try values.decodeIfPresent(Bool.self, forKey: .trained)
        sso = try values.decodeIfPresent(Bool.self, forKey: .sso)
        ssoAuthUrl = try values.decodeIfPresent(String.self, forKey: .ssoAuthUrl)
        redirectUrl = try values.decodeIfPresent(String.self, forKey: .redirectUrl)
        ssoType = try values.decodeIfPresent(String.self, forKey: .ssoType)
        integration = try values.decodeIfPresent([VAConfigIntegration].self, forKey: .integration)
        npsSettings = try values.decodeIfPresent(VAConfigNPSSettings.self, forKey: .npsSettings)
        ssoActive = try values.decodeIfPresent(Bool.self, forKey: .ssoActive)
        platformType = try values.decodeIfPresent(String.self, forKey: .platformType)
        botUid = try values.decodeIfPresent(String.self, forKey: .botUid)
        botId = try values.decodeIfPresent(Int.self, forKey: .botId)
        projectId = try values.decodeIfPresent(String.self, forKey: .projectId)
        privateKey = try values.decodeIfPresent(String.self, forKey: .privateKey)
        clientEmail = try values.decodeIfPresent(String.self, forKey: .clientEmail)
        tokenUrl = try values.decodeIfPresent(String.self, forKey: .tokenUrl)
        connectionAllowed = try values.decodeIfPresent(Bool.self, forKey: .connectionAllowed)
        connectionFullMsg = try values.decodeIfPresent(VAConfigConnectionFullMsg.self, forKey: .connectionFullMsg)
        reconnectionTimer = try values.decodeIfPresent(Int.self, forKey: .reconnectionTimer)
        customForm = try values.decodeIfPresent(CustomForm.self, forKey: .customForm)
        genAITextFeedback = try values.decodeIfPresent(Bool.self, forKey: .genAITextFeedback)
        genAIThumbsFeedback = try values.decodeIfPresent(Bool.self, forKey: .genAIThumbsFeedback)
        genAINewTheme = try values.decodeIfPresent(Bool.self, forKey: .genAINewTheme)
        enableCitation = try values.decodeIfPresent(Bool.self, forKey: .enableCitation)
        enableRelatedQueries = try values.decodeIfPresent(Bool.self, forKey: .enableRelatedQueries)
        genAITypeWritingEffect = try values.decodeIfPresent(Bool.self, forKey: .genAITypeWritingEffect)
        genAISettings = try values.decodeIfPresent(GenAISettings.self, forKey: .genAISettings)
        genAITypeWritingEffectSpeed = try values.decodeIfPresent(Int.self, forKey: .genAITypeWritingEffectSpeed)
    }
}

struct VAConfigLanguage: Codable {
    let lang: String?
    let displayName: String?
    let confidence: Int?
    let threshold: Int?

    enum CodingKeys: String, CodingKey {
        case lang
        case displayName
        case confidence
        case threshold
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lang = try values.decodeIfPresent(String.self, forKey: .lang)
        displayName = try values.decodeIfPresent(String.self, forKey: .displayName)
        confidence = try values.decodeIfPresent(Int.self, forKey: .confidence)
        threshold = try values.decodeIfPresent(Int.self, forKey: .threshold)
    }
}

struct VAConfigFeedback: Codable {
    let enThumbsUp: String?

    enum CodingKeys: String, CodingKey {
        case enThumbsUp = "en_thumbs_up"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        enThumbsUp = try values.decodeIfPresent(String.self, forKey: .enThumbsUp)
    }
}

struct VAConfigAutoReplyMsg: Codable {
    let en: String?
    let fr: String?

    enum CodingKeys: String, CodingKey {
        case en
        case fr
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        en = try values.decodeIfPresent(String.self, forKey: .en)
        fr = try values.decodeIfPresent(String.self, forKey: .fr)
    }
}

struct VAConfigIntegration: Codable {
    let uid: String?
    let settings: VAConfigIntegrationSettings?
    let botId: Int?
    let readMoreLimit: VAConfigIntegrationReadMoreLimit?
    let transactionDetailVisibility: Bool?
    let settingVisiblity: Bool?
    let privacyVisiblity: Bool?
    let privacyUrl: String?
    let liveAgntVisiblity: Bool?
    let tplId: String?
    let tplName: String?
    let redaction: [VAConfigIntegrationRedaction]?
    let ixId: String?
    let ixName: String?
    let transferAgent: Bool?
    let chatTranscript: Bool?
    let editEmail: Bool?
    let historyCustom: Bool?
    let voiceEnable: Bool?
    let chatHistoryDuration: Int?
    let chatAliveDuration: Int?
    let sessionExpiredDuration: Int?
    let createdBy: Int?
    let updatedAt: String?
    let updatedBy: Int?
    let horizontalQuickReply: Bool?
    let created: String?

    enum CodingKeys: String, CodingKey {
        case uid
        case settings
        case botId = "bot_id"
        case readMoreLimit = "read_more_limit"
        case transactionDetailVisibility = "transaction_detail_visibility"
        case settingVisiblity = "setting_visiblity"
        case privacyVisiblity = "privacy_visiblity"
        case privacyUrl = "privacy_url"
        case liveAgntVisiblity = "live_agnt_visiblity"
        case tplId = "tpl_id"
        case tplName = "tpl_name"
        case redaction
        case ixId = "ix_id"
        case ixName = "ix_name"
        case transferAgent = "transfer_agent"
        case chatTranscript = "chat_transcript"
        case editEmail = "edit_email"
        case historyCustom = "history_custom"
        case voiceEnable = "voice_enable"
        case chatHistoryDuration = "chat_history_duration"
        case chatAliveDuration = "chat_alive_duration"
        case sessionExpiredDuration = "session_expired_duration"
        case createdBy = "created_by"
        case updatedAt = "updated_at"
        case updatedBy = "updated_by"
        case horizontalQuickReply = "horizontal_quick_reply"
        case created
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uid = try values.decodeIfPresent(String.self, forKey: .uid)
        settings = try values.decodeIfPresent(VAConfigIntegrationSettings.self, forKey: .settings)
        botId = try values.decodeIfPresent(Int.self, forKey: .botId)
        readMoreLimit = try values.decodeIfPresent(VAConfigIntegrationReadMoreLimit.self, forKey: .readMoreLimit)
        transactionDetailVisibility = try values.decodeIfPresent(Bool.self, forKey: .transactionDetailVisibility)
        settingVisiblity = try values.decodeIfPresent(Bool.self, forKey: .settingVisiblity)
        privacyVisiblity = try values.decodeIfPresent(Bool.self, forKey: .privacyVisiblity)
        privacyUrl = try values.decodeIfPresent(String.self, forKey: .privacyUrl)
        liveAgntVisiblity = try values.decodeIfPresent(Bool.self, forKey: .liveAgntVisiblity)
        tplId = try values.decodeIfPresent(String.self, forKey: .tplId)
        tplName = try values.decodeIfPresent(String.self, forKey: .tplName)
        redaction = try values.decodeIfPresent([VAConfigIntegrationRedaction].self, forKey: .redaction)
        ixId = try values.decodeIfPresent(String.self, forKey: .ixId)
        ixName = try values.decodeIfPresent(String.self, forKey: .ixName)
        transferAgent = try values.decodeIfPresent(Bool.self, forKey: .transferAgent)
        chatTranscript = try values.decodeIfPresent(Bool.self, forKey: .chatTranscript)
        editEmail = try values.decodeIfPresent(Bool.self, forKey: .editEmail)
        historyCustom = try values.decodeIfPresent(Bool.self, forKey: .historyCustom)
        voiceEnable = try values.decodeIfPresent(Bool.self, forKey: .voiceEnable)
        chatHistoryDuration = try values.decodeIfPresent(Int.self, forKey: .chatHistoryDuration)
        chatAliveDuration = try values.decodeIfPresent(Int.self, forKey: .chatAliveDuration)
        sessionExpiredDuration = try values.decodeIfPresent(Int.self, forKey: .sessionExpiredDuration)
        createdBy = try values.decodeIfPresent(Int.self, forKey: .createdBy)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        updatedBy = try values.decodeIfPresent(Int.self, forKey: .updatedBy)
        horizontalQuickReply = try values.decodeIfPresent(Bool.self, forKey: .horizontalQuickReply)
        created = try values.decodeIfPresent(String.self, forKey: .created)
    }
}

struct VAConfigIntegrationSettings: Codable {
    let autoSuggestionFont: AutosuggestionFont?
    let buttonColor: String?
    let carouselColor: String?
    let carouselTextColor: String?
    let customFont: Bool?
    let customFontTitle: String?
    let customFontUrl: String?
    let dateTimeFont: DatetimeFont?
    let settingDefault: Bool?
    let fontFamily: FontFamily?
    let responseBubble: String?
    let responseTextIcon: String?
    let senderBubble: String?
    let senderTextIcon: String?
    let textFont: TextFont?
    let themeColor: String?
    let widgetTextColor: String?

    enum CodingKeys: String, CodingKey {
        case autoSuggestionFont = "autosuggestion_font"
        case buttonColor = "button_colour"
        case carouselColor = "carousel_color"
        case carouselTextColor = "carousel_textcolour"
        case customFont = "custom_font"
        case customFontTitle = "custom_font_title"
        case customFontUrl = "custom_font_url"
        case dateTimeFont = "datetime_font"
        case settingDefault = "default"
        case fontFamily = "font_family"
        case responseBubble = "response_bubble"
        case responseTextIcon = "response_text_icon"
        case senderBubble = "sender_bubble"
        case senderTextIcon = "sender_text_icon"
        case textFont = "text_font"
        case themeColor = "theme_colour"
        case widgetTextColor = "widget_textcolour"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        autoSuggestionFont = try values.decodeIfPresent(AutosuggestionFont.self, forKey: .autoSuggestionFont)
        buttonColor = try values.decodeIfPresent(String.self, forKey: .buttonColor)
        carouselColor = try values.decodeIfPresent(String.self, forKey: .carouselColor)
        carouselTextColor = try values.decodeIfPresent(String.self, forKey: .carouselTextColor)
        customFont = try values.decodeIfPresent(Bool.self, forKey: .customFont)
        customFontTitle = try values.decodeIfPresent(String.self, forKey: .customFontTitle)
        customFontUrl = try values.decodeIfPresent(String.self, forKey: .customFontUrl)
        dateTimeFont = try values.decodeIfPresent(DatetimeFont.self, forKey: .dateTimeFont)
        settingDefault = try values.decodeIfPresent(Bool.self, forKey: .settingDefault)
        fontFamily = try values.decodeIfPresent(FontFamily.self, forKey: .fontFamily)
        responseBubble = try values.decodeIfPresent(String.self, forKey: .responseBubble)
        responseTextIcon = try values.decodeIfPresent(String.self, forKey: .responseTextIcon)
        senderBubble = try values.decodeIfPresent(String.self, forKey: .senderBubble)
        senderTextIcon = try values.decodeIfPresent(String.self, forKey: .senderTextIcon)
        textFont = try values.decodeIfPresent(TextFont.self, forKey: .textFont)
        themeColor = try values.decodeIfPresent(String.self, forKey: .themeColor)
        widgetTextColor = try values.decodeIfPresent(String.self, forKey: .widgetTextColor)
    }
}

struct AutosuggestionFont: Codable {
    let label: String?
    let value: String?

    enum CodingKeys: String, CodingKey {
        case label
        case value
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        label = try values.decodeIfPresent(String.self, forKey: .label)
        value = try values.decodeIfPresent(String.self, forKey: .value)
    }
}

struct DatetimeFont: Codable {
    let label: String?
    let value: String?

    enum CodingKeys: String, CodingKey {
        case label
        case value
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        label = try values.decodeIfPresent(String.self, forKey: .label)
        value = try values.decodeIfPresent(String.self, forKey: .value)
    }
}

struct FontFamily: Codable {
    let label: String?
    let value: String?

    enum CodingKeys: String, CodingKey {
        case label
        case value
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        label = try values.decodeIfPresent(String.self, forKey: .label)
        value = try values.decodeIfPresent(String.self, forKey: .value)
    }
}

struct TextFont: Codable {
    let label: String?
    let value: String?

    enum CodingKeys: String, CodingKey {
        case label
        case value
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        label = try values.decodeIfPresent(String.self, forKey: .label)
        value = try values.decodeIfPresent(String.self, forKey: .value)
    }
}

struct VAConfigIntegrationReadMoreLimit: Codable {
    let readMore: Bool?
    let characterCount: Int?
    let expandText: Bool?

    enum CodingKeys: String, CodingKey {
        case readMore = "read_more"
        case characterCount = "character_count"
        case expandText = "expand_text"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        readMore = try values.decodeIfPresent(Bool.self, forKey: .readMore)
        characterCount = try values.decodeIfPresent(Int.self, forKey: .characterCount)
        expandText = try values.decodeIfPresent(Bool.self, forKey: .expandText)
    }
}

struct VAConfigIntegrationRedaction: Codable {
    let uid: String?
    let key: String?
    let active: Bool?
    let regex: String?
    let title: String?

    enum CodingKeys: String, CodingKey {
        case uid
        case key
        case active
        case regex
        case title
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uid = try values.decodeIfPresent(String.self, forKey: .uid)
        key = try values.decodeIfPresent(String.self, forKey: .key)
        active = try values.decodeIfPresent(Bool.self, forKey: .active)
        regex = try values.decodeIfPresent(String.self, forKey: .regex)
        title = try values.decodeIfPresent(String.self, forKey: .title)
    }
}

struct VAConfigNPSSettings: Codable {
    let botId: String?
    let data: [VAConfigNPSSettingsData]?
    let issueResolved: Bool?
    let additionalFeedback: Bool?
    let ratings: Bool?
    let customTheme: Bool?

    enum CodingKeys: String, CodingKey {
        case botId = "bot_id"
        case data
        case issueResolved = "issue_resolved"
        case additionalFeedback = "additional_feedback"
        case ratings
        case customTheme = "custom_theme"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        botId = try values.decodeIfPresent(String.self, forKey: .botId)
        data = try values.decodeIfPresent([VAConfigNPSSettingsData].self, forKey: .data)
        issueResolved = try values.decodeIfPresent(Bool.self, forKey: .issueResolved)
        additionalFeedback = try values.decodeIfPresent(Bool.self, forKey: .additionalFeedback)
        ratings = try values.decodeIfPresent(Bool.self, forKey: .ratings)
        customTheme = try values.decodeIfPresent(Bool.self, forKey: .customTheme)
    }
}

struct VAConfigNPSSettingsData: Codable {
    let ratingWiseQuestions: [NPSSettingsDataRatingWiseQuestions]?
    let lang: String?
    let message: String?
    let minLabel: String?
    let maxLabel: String?
    let ratingType: String?
    let ratingScale: String?
    let ratingViewOrder: String?

    enum CodingKeys: String, CodingKey {
        case ratingWiseQuestions = "rating_wise_questions"
        case lang
        case message
        case minLabel = "min_label"
        case maxLabel = "max_label"
        case ratingType = "rating_type"
        case ratingScale = "rating_scale"
        case ratingViewOrder = "rating_view_order"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        ratingWiseQuestions = try values.decodeIfPresent([NPSSettingsDataRatingWiseQuestions].self, forKey: .ratingWiseQuestions)
        lang = try values.decodeIfPresent(String.self, forKey: .lang)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        minLabel = try values.decodeIfPresent(String.self, forKey: .minLabel)
        maxLabel = try values.decodeIfPresent(String.self, forKey: .maxLabel)
        ratingType = try values.decodeIfPresent(String.self, forKey: .ratingType)
        ratingScale = try values.decodeIfPresent(String.self, forKey: .ratingScale)
        ratingViewOrder = try values.decodeIfPresent(String.self, forKey: .ratingViewOrder)
    }
}

struct NPSSettingsDataRatingWiseQuestions: Codable {
    let score: Int?
    let question: String?
    let answerTags: [String]?

    enum CodingKeys: String, CodingKey {
        case score
        case question
        case answerTags = "answer_tags"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        score = try values.decodeIfPresent(Int.self, forKey: .score)
        question = try values.decodeIfPresent(String.self, forKey: .question)
        answerTags = try values.decodeIfPresent([String].self, forKey: .answerTags)
    }
}

struct VAConfigIPS: Codable {
    let enable: Bool?

    enum CodingKeys: String, CodingKey {
        case enable
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        enable = try values.decodeIfPresent(Bool.self, forKey: .enable)
    }
}

struct VAConfigConnectionFullMsg: Codable {
    let en: String?
    let fr: String?

    enum CodingKeys: String, CodingKey {
        case en
        case fr
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        en = try values.decodeIfPresent(String.self, forKey: .en)
        fr = try values.decodeIfPresent(String.self, forKey: .fr)
    }
}

// MARK: - CustomForm
struct CustomForm: Codable {
    let uid, name: String?
    var settings: Settings?
    let active: Bool?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case uid, name, settings, active
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uid = try values.decodeIfPresent(String.self, forKey: .uid)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        settings = try values.decodeIfPresent(Settings.self, forKey: .settings)
        active = try values.decodeIfPresent(Bool.self, forKey: .active)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
    }
}


// MARK: - Settings
struct Settings: Codable {
    var props: [Prop]?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        props = try values.decodeIfPresent([Prop].self, forKey: .props)
    }
}

struct GenAISettings: Codable {
    let citationsMaxLimit: Int?
    let relatedQueriesMaxLimit: Int?
    let widgetEnteredTextMaxLimit: Int?
    let genAIFeedback: [GenAIFeedback]?
    
    enum CodingKeys: String, CodingKey {
        case citationsMaxLimit = "citation_max_limit"
        case relatedQueriesMaxLimit = "related_queries_max_limit"
        case widgetEnteredTextMaxLimit = "widget_entered_text_max_limit"
        case genAIFeedback = "feedback"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        citationsMaxLimit = try values.decodeIfPresent(Int.self, forKey: .citationsMaxLimit)
        relatedQueriesMaxLimit = try values.decodeIfPresent(Int.self, forKey: .relatedQueriesMaxLimit)
        widgetEnteredTextMaxLimit = try values.decodeIfPresent(Int.self, forKey: .widgetEnteredTextMaxLimit)
        genAIFeedback = try values.decodeIfPresent([GenAIFeedback].self, forKey: .genAIFeedback)
    }
}
struct GenAIFeedback: Codable {
    let title: String?
    let type: String?
    let options: [GenAIFeedbackOptions]?
    
    enum CodingKeys: String, CodingKey {
        case title = "feedback_title"
        case type
        case options = "chips"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        options = try values.decodeIfPresent([GenAIFeedbackOptions].self, forKey: .options)
    }
}

struct GenAIFeedbackOptions: Codable {
    let label: String?
    let value: String?
    var isSelected: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case label
        case value
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        label = try values.decodeIfPresent(String.self, forKey: .label)
        value = try values.decodeIfPresent(String.self, forKey: .value)
    }
}

// MARK: - Prop
struct Prop: Codable {
    let inputName: String?
    let inputType: InputType?
    let label: String?
    let maxLength: MaxLength?
    let options: [InputType]?
    let placeHolder: String?
    let propRequired: Bool?
    let uid, validation: String?
    let regexBoxValue: String?
    var userInputValue: String? = ""
    var hasValidUserInput: Bool = false

    enum CodingKeys: String, CodingKey {
        case inputName = "input_name"
        case inputType = "input_type"
        case label
        case maxLength = "max_length"
        case options
        case placeHolder = "place_holder"
        case propRequired = "required"
        case uid, validation
        case regexBoxValue = "regex-box-value"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        inputName = try values.decodeIfPresent(String.self, forKey: .inputName)
        inputType = try values.decodeIfPresent(InputType.self, forKey: .inputType)
        label = try values.decodeIfPresent(String.self, forKey: .label)
        maxLength = try values.decodeIfPresent(MaxLength.self, forKey: .maxLength)
        options = try values.decodeIfPresent([InputType].self, forKey: .options)
        placeHolder = try values.decodeIfPresent(String.self, forKey: .placeHolder)
        propRequired = try values.decodeIfPresent(Bool.self, forKey: .propRequired)
        uid = try values.decodeIfPresent(String.self, forKey: .uid)
        validation = try values.decodeIfPresent(String.self, forKey: .validation)
        regexBoxValue = try values.decodeIfPresent(String.self, forKey: .regexBoxValue)
    }
}

// MARK: - InputType
struct InputType: Codable {
    let label, value: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        label = try values.decodeIfPresent(String.self, forKey: .label)
        value = try values.decodeIfPresent(String.self, forKey: .value)
    }
}

enum MaxLength: Codable {
    case integer(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(MaxLength.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for MaxLength"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

struct Suggestion: Codable {
    let originalText: String?
    let displayText: String?
    let intent_id: Int?
    let intent_uid: String?
    var isLocalSearch: Bool? = false
    var type: String?
    var intentName: String?
    var allChoiceOptions: [Choice]?
    var filteredChoiceOptions: [Choice]?
}
