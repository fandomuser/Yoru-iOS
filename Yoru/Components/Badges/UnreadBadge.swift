import SwiftUI

public struct UnreadBadge: View {
    @Environment(\.yoruTheme) private var theme
    private let count: Int32
    private let isMuted: Bool

    public init(count: Int32, isMuted: Bool = false) {
        self.count = count
        self.isMuted = isMuted
    }

    public var body: some View {
        if count > 0 {
            Text(count > 999 ? "999+" : "\(count)")
                .font(.yoruCyberBadge)
                .foregroundColor(isMuted ? theme.textSecondary : theme.textInverse)
                .padding(.horizontal, 6)
                .frame(minWidth: 20, height: 20)
                .background(
                    Capsule()
                        .fill(isMuted ? theme.backgroundElevated : theme.accentPrimary)
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                )
                .yoruNeonGlow(color: theme.neonGlow, radius: 4, isActive: !isMuted)
        }
    }
}
