import SwiftUI

public enum YoruThemes {
    // 1. Tokyo Night (東京の夜)
    public static let tokyoNight = YoruTheme(
        id: .tokyoNight,
        name: "Tokyo Night",
        kanji: "東京の夜",
        backgroundPrimary: Color(hex: "#0B0C10"),
        backgroundSecondary: Color(hex: "#141724"),
        backgroundElevated: Color(hex: "#1F2335"),
        glassSurface: Color(hex: "#1A1D2E"),
        accentPrimary: Color(hex: "#9D4EDD"),
        accentSecondary: Color(hex: "#00F5D4"),
        neonGlow: Color(hex: "#9D4EDD"),
        textPrimary: Color(hex: "#F0F2FA"),
        textSecondary: Color(hex: "#9AA5CE"),
        textTertiary: Color(hex: "#565F89"),
        textInverse: Color(hex: "#0B0C10"),
        bubbleOutgoing: Color(hex: "#7928CA"),
        bubbleOutgoingText: Color(hex: "#FFFFFF"),
        bubbleIncoming: Color(hex: "#1E2238"),
        bubbleIncomingText: Color(hex: "#E2E8F0"),
        onlineStatus: Color(hex: "#00F5D4"),
        glowRadius: 10.0,
        cornerRadius: 18.0
    )

    // 2. Sakura Dream (桜の夢)
    public static let sakuraDream = YoruTheme(
        id: .sakuraDream,
        name: "Sakura Dream",
        kanji: "桜の夢",
        backgroundPrimary: Color(hex: "#151015"),
        backgroundSecondary: Color(hex: "#221622"),
        backgroundElevated: Color(hex: "#2E1C2E"),
        glassSurface: Color(hex: "#281728"),
        accentPrimary: Color(hex: "#FF70A6"),
        accentSecondary: Color(hex: "#FF9770"),
        neonGlow: Color(hex: "#FF70A6"),
        textPrimary: Color(hex: "#FFF0F5"),
        textSecondary: Color(hex: "#D4A5B8"),
        textTertiary: Color(hex: "#825C6E"),
        textInverse: Color(hex: "#151015"),
        bubbleOutgoing: Color(hex: "#E05388"),
        bubbleOutgoingText: Color(hex: "#FFFFFF"),
        bubbleIncoming: Color(hex: "#2B1A2A"),
        bubbleIncomingText: Color(hex: "#FDE2E4"),
        onlineStatus: Color(hex: "#70D6FF"),
        glowRadius: 8.0,
        cornerRadius: 20.0
    )

    // 3. Midnight Blue (深夜の青)
    public static let midnightBlue = YoruTheme(
        id: .midnightBlue,
        name: "Midnight Blue",
        kanji: "深夜の青",
        backgroundPrimary: Color(hex: "#060A12"),
        backgroundSecondary: Color(hex: "#0B1526"),
        backgroundElevated: Color(hex: "#11223D"),
        glassSurface: Color(hex: "#0F1E38"),
        accentPrimary: Color(hex: "#00E8FC"),
        accentSecondary: Color(hex: "#2E67F8"),
        neonGlow: Color(hex: "#00E8FC"),
        textPrimary: Color(hex: "#EBF4FF"),
        textSecondary: Color(hex: "#8CB4E6"),
        textTertiary: Color(hex: "#436594"),
        textInverse: Color(hex: "#060A12"),
        bubbleOutgoing: Color(hex: "#0D58CF"),
        bubbleOutgoingText: Color(hex: "#FFFFFF"),
        bubbleIncoming: Color(hex: "#11223B"),
        bubbleIncomingText: Color(hex: "#DCEAFE"),
        onlineStatus: Color(hex: "#00F5D4"),
        glowRadius: 9.0,
        cornerRadius: 16.0
    )

    // 4. Crimson Moon (紅月)
    public static let crimsonMoon = YoruTheme(
        id: .crimsonMoon,
        name: "Crimson Moon",
        kanji: "紅月",
        backgroundPrimary: Color(hex: "#0F070A"),
        backgroundSecondary: Color(hex: "#1A0D12"),
        backgroundElevated: Color(hex: "#29121B"),
        glassSurface: Color(hex: "#240E17"),
        accentPrimary: Color(hex: "#FF1E56"),
        accentSecondary: Color(hex: "#FFAC41"),
        neonGlow: Color(hex: "#FF1E56"),
        textPrimary: Color(hex: "#FFF2F4"),
        textSecondary: Color(hex: "#D196A3"),
        textTertiary: Color(hex: "#784752"),
        textInverse: Color(hex: "#0F070A"),
        bubbleOutgoing: Color(hex: "#B80E38"),
        bubbleOutgoingText: Color(hex: "#FFFFFF"),
        bubbleIncoming: Color(hex: "#260F17"),
        bubbleIncomingText: Color(hex: "#FFE0E6"),
        onlineStatus: Color(hex: "#FFAC41"),
        glowRadius: 10.0,
        cornerRadius: 18.0
    )

    // 5. Manga Mono (漫画モノ)
    public static let mangaMono = YoruTheme(
        id: .mangaMono,
        name: "Manga Mono",
        kanji: "漫画モノ",
        backgroundPrimary: Color(hex: "#080808"),
        backgroundSecondary: Color(hex: "#141414"),
        backgroundElevated: Color(hex: "#222222"),
        glassSurface: Color(hex: "#1A1A1A"),
        accentPrimary: Color(hex: "#FFFFFF"),
        accentSecondary: Color(hex: "#B0B0B0"),
        neonGlow: Color(hex: "#EEEEEE"),
        textPrimary: Color(hex: "#FFFFFF"),
        textSecondary: Color(hex: "#A0A0A0"),
        textTertiary: Color(hex: "#606060"),
        textInverse: Color(hex: "#000000"),
        bubbleOutgoing: Color(hex: "#ECECEC"),
        bubbleOutgoingText: Color(hex: "#000000"),
        bubbleIncoming: Color(hex: "#1C1C1C"),
        bubbleIncomingText: Color(hex: "#E5E5E5"),
        onlineStatus: Color(hex: "#FFFFFF"),
        glowRadius: 6.0,
        cornerRadius: 14.0
    )

    public static func theme(for id: ThemeID) -> YoruTheme {
        switch id {
        case .tokyoNight: return tokyoNight
        case .sakuraDream: return sakuraDream
        case .midnightBlue: return midnightBlue
        case .crimsonMoon: return crimsonMoon
        case .mangaMono: return mangaMono
        }
    }
}
