import SwiftUI
import Combine
import Observation

@Observable
public final class ThemeManager {
    public static let shared = ThemeManager()

    public var currentThemeID: ThemeID {
        didSet {
            UserDefaults.standard.set(currentThemeID.rawValue, forKey: "yoru_theme_id")
            currentTheme = YoruThemes.theme(for: currentThemeID)
        }
    }

    public private(set) var currentTheme: YoruTheme

    // Customization flags
    public var enableNeonGlow: Bool {
        didSet { UserDefaults.standard.set(enableNeonGlow, forKey: "yoru_neon_glow") }
    }

    public var enableAnimeTransitions: Bool {
        didSet { UserDefaults.standard.set(enableAnimeTransitions, forKey: "yoru_anime_transitions") }
    }

    public var bubbleCornerRadius: CGFloat {
        didSet { UserDefaults.standard.set(bubbleCornerRadius, forKey: "yoru_bubble_radius") }
    }

    public init() {
        let savedThemeRaw = UserDefaults.standard.string(forKey: "yoru_theme_id") ?? ThemeID.tokyoNight.rawValue
        let themeID = ThemeID(rawValue: savedThemeRaw) ?? .tokyoNight
        self.currentThemeID = themeID
        self.currentTheme = YoruThemes.theme(for: themeID)

        let glow = UserDefaults.standard.object(forKey: "yoru_neon_glow") as? Bool ?? true
        let transitions = UserDefaults.standard.object(forKey: "yoru_anime_transitions") as? Bool ?? true
        let radius = UserDefaults.standard.object(forKey: "yoru_bubble_radius") as? CGFloat ?? 18.0

        self.enableNeonGlow = glow
        self.enableAnimeTransitions = transitions
        self.bubbleCornerRadius = radius
    }

    public func selectTheme(_ themeID: ThemeID) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            self.currentThemeID = themeID
        }
    }
}

// SwiftUI Environment Key
public struct YoruThemeKey: EnvironmentKey {
    public static let defaultValue: YoruTheme = YoruThemes.tokyoNight
}

public extension EnvironmentValues {
    public var yoruTheme: YoruTheme {
        get { self[YoruThemeKey.self] }
        set { self[YoruThemeKey.self] = newValue }
    }
}
