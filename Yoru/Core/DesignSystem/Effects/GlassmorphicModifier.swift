import SwiftUI

public struct GlassmorphicModifier: ViewModifier {
    public let cornerRadius: CGFloat
    public let surfaceColor: Color
    public let opacity: Double
    public let borderColor: Color
    public let borderWidth: CGFloat

    public init(
        cornerRadius: CGFloat = 16,
        surfaceColor: Color = Color(hex: "#1A1D2E"),
        opacity: Double = 0.7,
        borderColor: Color = Color.white.opacity(0.12),
        borderWidth: CGFloat = 1
    ) {
        self.cornerRadius = cornerRadius
        self.surfaceColor = surfaceColor
        self.opacity = opacity
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }

    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(surfaceColor.opacity(opacity))
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                borderColor.opacity(0.35),
                                borderColor.opacity(0.05),
                                borderColor.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: borderWidth
                    )
            )
    }
}

public extension View {
    func yoruGlassmorphic(
        cornerRadius: CGFloat = 16,
        surfaceColor: Color = Color(hex: "#1A1D2E"),
        opacity: Double = 0.7,
        borderColor: Color = Color.white.opacity(0.15),
        borderWidth: CGFloat = 1
    ) -> some View {
        modifier(GlassmorphicModifier(
            cornerRadius: cornerRadius,
            surfaceColor: surfaceColor,
            opacity: opacity,
            borderColor: borderColor,
            borderWidth: borderWidth
        ))
    }
}
