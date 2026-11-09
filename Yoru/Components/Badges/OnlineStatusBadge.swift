import SwiftUI

public struct OnlineStatusBadge: View {
    @Environment(\.yoruTheme) private var theme
    private let isOnline: Bool

    public init(isOnline: Bool) {
        self.isOnline = isOnline
    }

    public var body: some View {
        Circle()
            .fill(isOnline ? theme.onlineStatus : theme.textTertiary)
            .frame(width: 10, height: 10)
            .overlay(
                Circle()
                    .stroke(theme.backgroundPrimary, lineWidth: 2)
            )
            .yoruNeonGlow(color: theme.onlineStatus, radius: 3, isActive: isOnline)
    }
}
