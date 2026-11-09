import SwiftUI

public enum YoruButtonStyle {
    case primary
    case secondary
    case destructive
    case ghost
}

public struct YoruButton: View {
    @Environment(\.yoruTheme) private var theme
    private let title: String
    private let kanji: String?
    private let icon: String?
    private let style: YoruButtonStyle
    private let isLoading: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        kanji: String? = nil,
        icon: String? = nil,
        style: YoruButtonStyle = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.kanji = kanji
        self.icon = icon
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                        .scaleEffect(0.9)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                    }
                    Text(title)
                        .font(.yoruHeadline)

                    if let kanji = kanji {
                        Text(kanji)
                            .font(.system(size: 13, weight: .heavy, design: .serif))
                            .opacity(0.8)
                    }
                }
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(backgroundView)
            .overlay(borderOverlay)
            .yoruNeonGlow(color: glowColor, radius: 8, isActive: shouldGlow)
        }
        .disabled(isLoading)
        .buttonStyle(YoruButtonPressStyle())
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return theme.textInverse
        case .secondary: return theme.accentPrimary
        case .destructive: return Color.white
        case .ghost: return theme.textPrimary
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            LinearGradient(
                colors: [theme.accentPrimary, theme.accentPrimary.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(CyberCutoutShape(cornerCut: 10))
        case .secondary:
            theme.glassSurface.opacity(0.85)
                .clipShape(CyberCutoutShape(cornerCut: 10))
        case .destructive:
            theme.destructive
                .clipShape(CyberCutoutShape(cornerCut: 10))
        case .ghost:
            Color.clear
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        switch style {
        case .primary:
            CyberCutoutShape(cornerCut: 10)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        case .secondary:
            CyberCutoutShape(cornerCut: 10)
                .stroke(theme.accentPrimary.opacity(0.6), lineWidth: 1.5)
        case .destructive:
            CyberCutoutShape(cornerCut: 10)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        case .ghost:
            EmptyView()
        }
    }

    private var glowColor: Color {
        switch style {
        case .primary: return theme.neonGlow
        case .secondary: return theme.accentPrimary
        case .destructive: return theme.destructive
        case .ghost: return Color.clear
        }
    }

    private var shouldGlow: Bool {
        style == .primary || style == .destructive
    }
}

private struct YoruButtonPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
