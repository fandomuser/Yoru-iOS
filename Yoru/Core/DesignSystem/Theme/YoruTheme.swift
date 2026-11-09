import SwiftUI

public enum ThemeID: String, CaseIterable, Identifiable, Codable {
    case tokyoNight = "tokyo_night"
    case sakuraDream = "sakura_dream"
    case midnightBlue = "midnight_blue"
    case crimsonMoon = "crimson_moon"
    case mangaMono = "manga_mono"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .tokyoNight: return "Tokyo Night (東京の夜)"
        case .sakuraDream: return "Sakura Dream (桜の夢)"
        case .midnightBlue: return "Midnight Blue (深夜の青)"
        case .crimsonMoon: return "Crimson Moon (紅月)"
        case .mangaMono: return "Manga Mono (漫画モノ)"
        }
    }

    public var subtitle: String {
        switch self {
        case .tokyoNight: return "Neo-Tokyo Cyberpunk with electric violet & cyan"
        case .sakuraDream: return "Soft Japanese blossom with pastel rose accents"
        case .midnightBlue: return "Deep naval abyss and stark tactical cyan"
        case .crimsonMoon: return "Dark fantasy scarlet with amber embers"
        case .mangaMono: return "Classic screentone ink with sharp monochrome contrast"
        }
    }
}

public struct YoruTheme: Identifiable, Equatable {
    public let id: ThemeID
    public let name: String
    public let kanji: String

    // Backgrounds
    public let backgroundPrimary: Color
    public let backgroundSecondary: Color
    public let backgroundElevated: Color
    public let glassSurface: Color

    // Accents & Brand
    public let accentPrimary: Color
    public let accentSecondary: Color
    public let neonGlow: Color

    // Text & Content
    public let textPrimary: Color
    public let textSecondary: Color
    public let textTertiary: Color
    public let textInverse: Color

    // Chat Specific
    public let bubbleOutgoing: Color
    public let bubbleOutgoingText: Color
    public let bubbleIncoming: Color
    public let bubbleIncomingText: Color

    // Status
    public let onlineStatus: Color
    public let destructive: Color
    public let warning: Color

    // Visual attributes
    public let glassOpacity: Double
    public let glowRadius: CGFloat
    public let cornerRadius: CGFloat

    public init(
        id: ThemeID,
        name: String,
        kanji: String,
        backgroundPrimary: Color,
        backgroundSecondary: Color,
        backgroundElevated: Color,
        glassSurface: Color,
        accentPrimary: Color,
        accentSecondary: Color,
        neonGlow: Color,
        textPrimary: Color,
        textSecondary: Color,
        textTertiary: Color,
        textInverse: Color,
        bubbleOutgoing: Color,
        bubbleOutgoingText: Color,
        bubbleIncoming: Color,
        bubbleIncomingText: Color,
        onlineStatus: Color = Color(hex: "#00F5D4"),
        destructive: Color = Color(hex: "#FF3366"),
        warning: Color = Color(hex: "#FFBE0B"),
        glassOpacity: Double = 0.75,
        glowRadius: CGFloat = 8.0,
        cornerRadius: CGFloat = 16.0
    ) {
        self.id = id
        self.name = name
        self.kanji = kanji
        self.backgroundPrimary = backgroundPrimary
        self.backgroundSecondary = backgroundSecondary
        self.backgroundElevated = backgroundElevated
        self.glassSurface = glassSurface
        self.accentPrimary = accentPrimary
        self.accentSecondary = accentSecondary
        self.neonGlow = neonGlow
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.textTertiary = textTertiary
        self.textInverse = textInverse
        self.bubbleOutgoing = bubbleOutgoing
        self.bubbleOutgoingText = bubbleOutgoingText
        self.bubbleIncoming = bubbleIncoming
        self.bubbleIncomingText = bubbleIncomingText
        self.onlineStatus = onlineStatus
        self.destructive = destructive
        self.warning = warning
        self.glassOpacity = glassOpacity
        self.glowRadius = glowRadius
        self.cornerRadius = cornerRadius
    }
}
