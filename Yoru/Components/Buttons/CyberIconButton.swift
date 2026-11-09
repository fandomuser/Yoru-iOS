import SwiftUI

public struct CyberIconButton: View {
    @Environment(\.yoruTheme) private var theme
    private let icon: String
    private let size: CGFloat
    private let iconColor: Color?
    private let backgroundColor: Color?
    private let action: () -> Void

    public init(
        icon: String,
        size: CGFloat = 44,
        iconColor: Color? = nil,
        backgroundColor: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.iconColor = iconColor
        self.backgroundColor = backgroundColor
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill((backgroundColor ?? theme.glassSurface).opacity(0.8))
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )

                Image(systemName: icon)
                    .font(.system(size: size * 0.42, weight: .semibold))
                    .foregroundColor(iconColor ?? theme.textPrimary)
            }
        }
        .buttonStyle(.plain)
    }
}
