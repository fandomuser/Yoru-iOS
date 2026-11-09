import Foundation

// MARK: - Enums & Types for Yoru Labs

public enum AvatarShape: String, CaseIterable, Identifiable, Codable {
    case circle
    case squircle
    case hexagon
    case cyberCut

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .circle: return "Classic Circle (円)"
        case .squircle: return "Soft Squircle (角丸)"
        case .hexagon: return "Cyber Hexagon (六角)"
        case .cyberCut: return "Tactical Cyber-Cut (切子)"
        }
    }
}

public enum FilterAction: String, CaseIterable, Identifiable, Codable {
    case blur
    case collapse
    case hide

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .blur: return "Anime Spoiler Blur"
        case .collapse: return "Collapsed Warning Bar"
        case .hide: return "Drop Completely (Silent)"
        }
    }
}

public enum QuickAction: String, CaseIterable, Identifiable, Codable {
    case reactHeart
    case reactFire
    case reactLightning
    case reply
    case copy
    case translate

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .reactHeart: return "Quick Reaction: ❤️"
        case .reactFire: return "Quick Reaction: 🔥"
        case .reactLightning: return "Quick Reaction: ⚡"
        case .reply: return "Inline Reply"
        case .copy: return "Copy Message"
        case .translate: return "Instant Translate"
        }
    }
}

public enum TranslationProvider: String, CaseIterable, Identifiable, Codable {
    case appleTranslate
    case deepl
    case google
    case mockLocal

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .appleTranslate: return "Apple System Translation"
        case .deepl: return "DeepL High-Precision API"
        case .google: return "Google Neural Engine"
        case .mockLocal: return "On-Device Offline Dictionary"
        }
    }
}

public enum AIProvider: String, CaseIterable, Identifiable, Codable {
    case appleIntelligence
    case localOnDevice
    case customEndpoint

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .appleIntelligence: return "Apple Intelligence (iOS 18+)"
        case .localOnDevice: return "Local On-Device CoreML"
        case .customEndpoint: return "Custom Cyber Neural Gateway"
        }
    }
}

public enum BiometricLockTimeout: Int, CaseIterable, Identifiable, Codable {
    case immediate = 0
    case oneMinute = 60
    case fiveMinutes = 300
    case fifteenMinutes = 900

    public var id: Int { rawValue }

    public var displayName: String {
        switch self {
        case .immediate: return "Immediately on Exit"
        case .oneMinute: return "After 1 Minute"
        case .fiveMinutes: return "After 5 Minutes"
        case .fifteenMinutes: return "After 15 Minutes"
        }
    }
}

// MARK: - Module Settings Structs

public struct PrivacyActivitySettings: Codable, Equatable {
    public var stealthModeEnabled: Bool = false
    public var suppressTypingIndicator: Bool = true
    public var suppressVoiceRecordIndicator: Bool = true
    public var localBiometricsEnabled: Bool = false
    public var biometricLockTimeout: BiometricLockTimeout = .immediate
    public var incognitoChatPreviews: Bool = true

    public init() {}
}

public struct MessageHistorySettings: Codable, Equatable {
    public var antiRecallEnabled: Bool = true
    public var markDeletedMessages: Bool = true
    public var trackEditHistory: Bool = true
    public var historyRetentionDays: Int = 30

    public init() {}
}

public struct MessageFilterSettings: Codable, Equatable {
    public var filterEnabled: Bool = true
    public var blockedKeywords: [String] = ["crypto giveaway", "presale", "airdrop claim", "100x gem"]
    public var regexPatterns: [String] = [#"(?i)\b(t\.me\/\+[a-zA-Z0-9_\-]+)\b"#]
    public var action: FilterAction = .collapse
    public var blockChannelsAdPosts: Bool = true

    public init() {}
}

public struct AppearanceCustomizationSettings: Codable, Equatable {
    public var avatarShape: AvatarShape = .squircle
    public var bubbleCornerRadius: Double = 18.0
    public var hidePhoneNumber: Bool = false
    public var hideUsernames: Bool = false
    public var hideAvatarsInChat: Bool = false
    public var hideQuickReactionsBar: Bool = false
    public var customFontScale: Double = 1.0

    public init() {}
}

public struct ChatEnhancementsSettings: Codable, Equatable {
    public var sendConfirmationChannel: Bool = true
    public var sendConfirmationSupergroup: Bool = false
    public var sendConfirmationVoice: Bool = true
    public var doubleTapAction: QuickAction = .reactLightning
    public var directShareButton: Bool = true

    public init() {}
}

public struct TranslationSettings: Codable, Equatable {
    public var translationEnabled: Bool = true
    public var provider: TranslationProvider = .appleTranslate
    public var targetLanguage: String = "en"
    public var autoTranslateChannels: Bool = false

    public init() {}
}

public struct AIToolsSettings: Codable, Equatable {
    public var aiEnabled: Bool = true
    public var provider: AIProvider = .localOnDevice
    public var smartRepliesEnabled: Bool = true
    public var chatSummarizationEnabled: Bool = true
    public var animePersonaPrompt: String = "Tokyo Night tactical anime assistant."

    public init() {}
}

public struct AdvancedSettings: Codable, Equatable {
    public var streamerModeEnabled: Bool = false
    public var showDebugTDLibConsole: Bool = false
    public var disableAnimations: Bool = false
    public var customUserAgent: String = "YoruClient/0.1.0 iOS"

    public init() {}
}

// MARK: - Aggregate Settings

public struct YoruLabsSettings: Codable, Equatable {
    public var privacy: PrivacyActivitySettings = PrivacyActivitySettings()
    public var history: MessageHistorySettings = MessageHistorySettings()
    public var filters: MessageFilterSettings = MessageFilterSettings()
    public var appearance: AppearanceCustomizationSettings = AppearanceCustomizationSettings()
    public var chat: ChatEnhancementsSettings = ChatEnhancementsSettings()
    public var translation: TranslationSettings = TranslationSettings()
    public var ai: AIToolsSettings = AIToolsSettings()
    public var advanced: AdvancedSettings = AdvancedSettings()

    public init() {}
}
