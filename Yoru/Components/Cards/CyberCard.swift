import SwiftUI

public struct CyberCard<Content: View>: View {
    @Environment(\.yoruTheme) private var theme
    private let cornerCut: CGFloat
    private let content: () -> Content

    public init(cornerCut: CGFloat = 14, @ViewBuilder content: @escaping () -> Content) {
        self.cornerCut = cornerCut
        self.content = content
    }

    public var body: some View {
        content()
            .padding(16)
            .background(
                theme.glassSurface.opacity(theme.glassOpacity)
                    .background(.ultraThinMaterial)
            )
            .clipShape(CyberCutoutShape(cornerCut: cornerCut))
            .overlay(
                CyberCutoutShape(cornerCut: cornerCut)
                    .stroke(
                        LinearGradient(
                            colors: [
                                theme.accentPrimary.opacity(0.4),
                                Color.white.opacity(0.08),
                                theme.accentSecondary.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}
