import SwiftUI

public struct NeonGlowModifier: ViewModifier {
    public let color: Color
    public let radius: CGFloat
    public let isActive: Bool

    public init(color: Color, radius: CGFloat = 8, isActive: Bool = true) {
        self.color = color
        self.radius = radius
        self.isActive = isActive
    }

    public func body(content: Content) -> some View {
        if isActive {
            content
                .shadow(color: color.opacity(0.55), radius: radius, x: 0, y: 0)
                .shadow(color: color.opacity(0.25), radius: radius * 2, x: 0, y: 0)
        } else {
            content
        }
    }
}

public extension View {
    public func yoruNeonGlow(color: Color, radius: CGFloat = 8, isActive: Bool = true) -> some View {
        modifier(NeonGlowModifier(color: color, radius: radius, isActive: isActive))
    }
}
